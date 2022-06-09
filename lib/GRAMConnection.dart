import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'Dialogs.dart';
import 'GRAMMessage.dart';
import 'RangeMode.dart';
import 'package:sprintf/sprintf.dart';
import 'dart:io';
import 'dart:async';
import 'GRAMModel.dart';
import 'Scale.dart';
//import 'package:wifi_configuration/wifi_configuration.dart';
import 'Log.dart';
import 'package:udp/udp.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

enum GRAMConnectionState {
  notConnected,
  tryingToGetNetwork,
  tryingToConnect,
  connected,
  streaming
}

enum GRAMConnectionType { TCP, UDP, SERIAL }

enum GRAMConnectionMode { normal, scan }

extension IntToString on int {
  String toHex() => '0x${toRadixString(16)}';
  String toPadded([int width = 3]) => toString().padLeft(width, '0');
  String toTransport() {
    switch (this) {
      case SerialPortTransport.usb:
        return 'USB';
      case SerialPortTransport.bluetooth:
        return 'Bluetooth';
      case SerialPortTransport.native:
        return 'Native';
      default:
        return 'Unknown';
    }
  }
}

class GRAMConnection {
  BuildContext context;

  bool active = true;
  GRAMConnectionType protocol = GRAMConnectionType.UDP;
  GRAMConnectionMode mode = GRAMConnectionMode.normal;

  Duration connectionTimeout =
      const Duration(seconds: 30); // Time to establish a TCP Connection
  Duration retryTimeout = const Duration(seconds: 1); // Time to receive message answer, triggers resend
  Duration watchdogTimeout = const Duration(seconds: 20); // Time to receive messages to maintain connection
  Duration afterWifiTimeout = const Duration(seconds: 2); // Time to wait after changing WiFi to establish connection
  Duration streamTimeout = const Duration(seconds: 10); // Time to change from streaming to connected

  // IP Connection

  Socket socket;
  UDP receiver;
  UDP sender;
  Future udpFuture;

  // Serial Port Connection

  SerialPort serialPort;
  SerialPortReader serialPortReader;
  StreamSubscription serialStreamSubscription;

  StreamController streamController = StreamController();

  Queue<GRAMMessage> messageQueue = Queue<GRAMMessage>();

  GRAMMessage currentMessage;

  Timer retryTimer; // Esecutes if the scale doesn't answers a message
  Timer connectionTimer; // Just to give connection establishment a maximum time
  Timer
      watchdogTimer; // Checks if scale is sending data. Just because some TCP cpnnections refuse to stop
  Timer
      streamTimer; // To change from streaming to connected states and just show "----" in the screen
  Timer
      afterWifiTimer; // Wait some time before trying to cennect afte WiFi chage

  Timer serialReadTimer; //Timer for reading serial data
  Duration serialReadInterval = Duration(milliseconds : 30);

  Timer hashTimer;  // Timer per enviar els hash. Quelcom entre 1s i 5s
  Duration hashTimerInterval = Duration(seconds: 3);

  List<int> buffer = [];

  GRAMConnectionState connectionState = GRAMConnectionState.notConnected;
  GRAMModel model = GRAMModel.shared;

  int connectionRetries = 0;
  int maxConnectionRetries = 3;

  GRAMConnection(this.context);

  // Timer management

  void stopRetryTimer() {
    if (retryTimer != null) {
      retryTimer.cancel();
      retryTimer = null;
    }
  }

  void startRetryTimer() {
    stopRetryTimer();
    retryTimer = Timer(retryTimeout, retryHandler);
  }

  void stopConnectionTimer() {
    if (connectionTimer != null) {
      connectionTimer.cancel();
      connectionTimer = null;
    }
  }

  void startconnectionTimer() {
    stopConnectionTimer();
    connectionTimer = Timer(connectionTimeout, connectionFailedHandler);
  }

  void stopWatchdogTimer() {
    if (watchdogTimer != null) {
      watchdogTimer.cancel();
      watchdogTimer = null;
    }
  }

  void startWatchdogTimer() {
    stopWatchdogTimer();
    watchdogTimer = Timer(watchdogTimeout, watchdogHandler);
  }

  void stopStreamTimer() {
    if (streamTimer != null) {
      streamTimer.cancel();
      streamTimer = null;
    }
  }

  void startStreamTimer() {
    stopStreamTimer();
    streamTimer = Timer(streamTimeout, streamHandler);
  }

  void startHashTimer(){
    clearHashTimer();
    hashTimer = Timer(hashTimerInterval, () {

      insertMessage(GRAMMessage.getHashMessage());
      if(currentMessage == null){
        processNextMessage();
      }

    });
  }

  void clearHashTimer(){
    if(hashTimer != null){
      hashTimer.cancel();
    }

  }

  // Queue checking

  bool isQueued(GRAMMessage message) {
    GRAMMessage m =
        messageQueue.firstWhere((e) => message.iseq(e), orElse: () => null);
    return (m != null);
  }

  // Connection

  void cleanConnection() async {
    clearHashTimer();
    stopConnectionTimer();
    stopRetryTimer();
    stopWatchdogTimer();
    stopStreamTimer();

    if (serialReadTimer != null) {
      serialReadTimer.cancel();
    }

    messageQueue.clear();


    if (socket != null ) {
      socket.destroy();
      socket = null;
      buffer = []; // Clean the buffer
    }
    if (receiver != null) {
      receiver.close();
      sender.close();
      receiver = null;
      sender = null;

      buffer = []; // Clean the buffer
    }


      if (serialStreamSubscription != null) {
        var a = await serialStreamSubscription.cancel();
        serialStreamSubscription = null;
      }
      if (serialPortReader != null) {
        serialPortReader.close();
        serialPortReader = null;
      }

      if (serialPort != null) {

        serialPort.close();
        serialPort.dispose();
        serialPort = null;
        serialReadTimer = null;
      }


    model.modes = [RangeMode(0.0, 0.0), RangeMode(0.0, 0.0)];
    model.scaleName = "";
    currentMessage = null;
  }

  void addAvailablePorts() {
    // Test de Serial port

    var speeds = [115200];

    try {
      Log.shared.trace("logAvailablePorts", "Starting port detection");
      var availablePorts = SerialPort.availablePorts;

      for (final address in availablePorts) {
        final port = SerialPort(address);
        var desc = "Port " +
            port.description +
            " " +
            port.transport.toTransport() +
            " " +
            address;
        String name = port.description;

        // Now add data to the scale database

          var someScale = Scale(
              name: name,
              ssid: address,
              networkName: "tty",
              port: 115200);
          model.scalesDatabase.add(someScale);
         Log.shared.info("logAvailablePorts", desc);
      }
    } on SerialPortError catch (e) {
      Log.shared.error("logAvailablePorts", e.message);
    }
  }

  void connect({Function() callback}) async {
    connectionRetries = 0;
    await _connect(callback: callback);
  }

  void _connect({Function() callback}) async {
    if (GRAMModel.shared.appState != AppLifecycleState.resumed || !active) {
      disconnect();
      return;
    }

    if (connectionState == GRAMConnectionState.connected ||
        connectionState == GRAMConnectionState.streaming) {
      disconnect();
    }

    connectionState = GRAMConnectionState.tryingToGetNetwork;
    model.didReceiveData();

    cleanConnection();

    // First try to get the wifi name

    if (mode == GRAMConnectionMode.normal) {
      protocol = model.scale.type();
    } else {
      protocol = GRAMConnectionType.UDP;
    }

    if (protocol == GRAMConnectionType.SERIAL &&
        mode == GRAMConnectionMode.normal) {
      protocol = GRAMConnectionType.SERIAL;
      _doSERIALConnection(callback: callback);
    } else if (protocol == GRAMConnectionType.TCP) {
      _doTCPConnection(); // No need to wait if already in same netork

    } else if (protocol == GRAMConnectionType.UDP) {
      await _doUDPConnection(callback: callback);
    } else if (protocol == GRAMConnectionType.SERIAL) {
      _doSERIALConnection(callback: callback);
    }
  }

  void _doSERIALConnection({Function() callback}) async {

    if (!active){
      return;
    }
    connectionState = GRAMConnectionState.tryingToConnect;
    model.didReceiveData();
    var address = model.scale.ssid;
    Log.shared.trace("GRAMConnection._doSERIALPConnection",
        "Establishing SERIAL connection to " + address);

    if (serialStreamSubscription != null) {
      var a = await serialStreamSubscription.cancel();
      serialStreamSubscription = null;
    }
    if (serialPortReader != null) {
      serialPortReader.close();
      serialPortReader = null;
    }

    if (serialPort != null) {
      serialPort.close();
      serialPort.dispose();
      serialPort = null;
    }

    // Configure a Listen port



    try {
      serialPort = SerialPort(address); // Just check if it is enough
      var desc = "Port " +
          serialPort.description +
          " " +
          serialPort.transport.toTransport() +
          " " +
          address;
      Log.shared.trace("_doSERIALConnection Opening port  " + address, desc);
      if (!serialPort.isOpen) {
        if (!serialPort.openReadWrite()){
          Log.shared.error("_doSERIALConnection Error Opening port  " + address, "Not Opened");
        }
      }
      var config = SerialPortConfig();
      config.baudRate = model.scale.port == null ? 115200 : model.scale.port;
      config.bits = 8;
      config.parity = SerialPortParity.none;
      config.stopBits = 1;
      config.setFlowControl(SerialPortFlowControl.none);

      serialPort.config = config;
    } on SerialPortError catch (e) {
      Log.shared.error(
          "_doSERIALConnection openPort error @ " + serialPort.name, e.message);
    }

    if (mode == GRAMConnectionMode.normal || true) {
        serialReadTimer = Timer(serialReadInterval, dataHandlerSerial);
    }

    connectionState = GRAMConnectionState.connected;
    GRAMModel.shared.didReceiveData();
    Log.shared.info("GRAMConnection._dSerialConnection", "Connected to Serial");

    startWatchdogTimer(); // We need someway to detect scale is hung or the connection has broken somewhere

    // Reset Hash and start sending HashMessages
    enqueueMessage(GRAMMessage.readAddress(AddressType.deviceStateInformation));
    model.resetHash();
    enqueueMessage(GRAMMessage.getHashMessage());

    // Send a start Streaming message
    if (mode == GRAMConnectionMode.normal) {
      enqueueMessage(GRAMMessage.getSerialNumber());
    } else {
      enqueueMessage(GRAMMessage.getSSIDName());
    }

    //getScaleData(); // Enqueue some commands

    processNextMessage(); // Start the show
  }

  void _doUDPConnection({Function() callback}) async {

    // Disconnect hasH Timeout if it exists

    if(hashTimer != null){
      hashTimer.cancel();
      hashTimer = null;
    }
    connectionState = GRAMConnectionState.tryingToConnect;
    model.didReceiveData();
    Log.shared.info(
        "GRAMConnection._doUDPConnection", "Establishing UDP connection ");

    // Configure a Listen port

    if (mode == GRAMConnectionMode.normal) {
      receiver =
          await UDP.bind(Endpoint.any(port: Port(model.scale.port + 1111)));
      sender = await UDP.bind(Endpoint.any(port: Port.any));
    } else {
      receiver = await UDP.bind(Endpoint.any(port: Port(5556)));
      sender = await UDP.bind(Endpoint.any(port: Port.any));
    }



    if (mode == GRAMConnectionMode.normal) {
      udpFuture = receiver.listen(dataHandlerUDP, timeout: Duration(seconds: 3600)).whenComplete(() => {
          print("Completed")
            // disconnect()
          });
    } else {
      print("Connecting for 15 seconds");
      udpFuture = receiver
          .listen(dataHandlerUDP, timeout: Duration(seconds: 5))
          .whenComplete(() {
        if (callback != null) {
          callback();
          disconnect();
        } else {
          disconnect();
        }
        // Now add to the databse the tty's

        addAvailablePorts();
      });
    }

    connectionState = GRAMConnectionState.connected;
    GRAMModel.shared.didReceiveData();
    Log.shared.info("GRAMConnection._doUDPConnection", "Connected to UDP");

    startWatchdogTimer(); // We need someway to detect scale is hung or the connection has broken somewhere

    // Send a start Streaming message
    if (mode == GRAMConnectionMode.normal) {
      enqueueMessage(GRAMMessage.getSerialNumber());
    } else {
      enqueueMessage(GRAMMessage.getSSIDName());
    }

    //getScaleData(); // Enqueue some commands

    processNextMessage(); // Start the show
  }

  void _doTCPConnection() {
    connectionState = GRAMConnectionState.tryingToConnect;
    model.didReceiveData();
    Log.shared.info("GRAMConnection._doTCPConnection",
        "Connecting to IP '${model.scale.ipAddress}:${model.scale.port}");

    // Schedule connectionTimer so we may cancel connection if it takes too long
    connectionTimer = Timer(connectionTimeout, this.connectionFailedHandler);

    Socket.connect(
            InternetAddress(model.scale.ipAddress,
                type: InternetAddressType.IPv4),
            model.scale.port)
        .then((Socket sock) {
      // Got as connection. Don't need connectionTimer anymore
      stopConnectionTimer();
      connectionRetries = 0;

      socket = sock;
      connectionState = GRAMConnectionState.connected;
      GRAMModel.shared.didReceiveData();

      Log.shared.info("GRAMConnection._doTCPConnection",
          "Connected to IP '${model.scale.ipAddress}:${model.scale.port}");

      socket.listen(dataHandlerTCP,
          onDone: doneHandler, onError: errorHandler, cancelOnError: false);

      startWatchdogTimer(); // We need someway to detect scale is hung or the connection has broken somewhere

      // Send a start Streaming message
      enqueueMessage(GRAMMessage.getSerialNumber());

      //getScaleData(); // Enqueue some commands

      processNextMessage(); // Start the show
    }).catchError((error, trace) {
      Log.shared
          .error("GRAMConnection._doTCPConnection.catchError", "Error '$error");
      connectionRetries += 1;

      connectionState = GRAMConnectionState.notConnected;
      GRAMModel.shared.didReceiveData();

      cleanConnection(); // Bad lack

      if (connectionRetries < maxConnectionRetries) {
        afterWifiTimer = Timer(this.afterWifiTimeout, this._doTCPConnection);
      } else {
        displayAlert(context, "No puc conectarme",
            "No puc conectar-me amb error $error. Conexions $connectionRetries");
      }
    });
  }

  void disconnect() {

    connectionState = GRAMConnectionState.notConnected;
    mode = GRAMConnectionMode.normal;
    cleanConnection();
    GRAMModel.shared.didReceiveData();
  }

  void scanScales(Function() callback) {
    disconnect();
    protocol = GRAMConnectionType.UDP;

    mode = GRAMConnectionMode.scan;
    connect(callback: callback);
  }

  void dataHandlerTCP(data) {
    buffer.addAll(data); // Add data to the end
    dataHandlerCommon(model.scale.ipAddress);
  }

  void dataHandlerUDP(data) {
    if (mode == GRAMConnectionMode.normal &&
        data.address.address != model.scale.ipAddress) {
      return;
    }
    buffer.addAll(data.data); // Add data to the end
    dataHandlerCommon(data.address.address);
  }


  void dataHandlerSerial() {
    serialReadTimer.cancel();

    try {
      if (serialPort.bytesAvailable > 0) {
        var data = serialPort.read(serialPort.bytesAvailable, timeout: 1000);
        Log.shared.trace("dataHandlerSerial", data.toString());

        buffer.addAll(data); // Add data to the end

        if (buffer.contains(0x0a)) {
          Log.shared.trace("dataHandlerSerial", "Packet added");
          dataHandlerCommon("tty");
        }
      }

     }catch(error){
      Log.shared.error("dataHandlerSerial", error.toString());
    }

    serialReadTimer = Timer(serialReadInterval, dataHandlerSerial);


  }

  void dataHandlerCommon(String ipOrigin) {
    // Get data for a frame. Dispose characters till 0x02 and copy till 0x03

    for (List<int> messageData = nextMessage();
        messageData != null;
        messageData = nextMessage()) {
      // Here we must process the messages

      if(messageData[0] == 0x55){
        clearHashTimer();
        model.procesaRespostaHash(messageData);
        startHashTimer();
        return;
      }

      GRAMMessage message = GRAMMessage.fromData(messageData, ipOrigin);


      if (message.address != AddressType.measurementData) {
        Log.shared.trace("GRAMConnection.dataHandler",
            "Received message ${message.function} for addres ${message.address}");
      }

      if (message.address == AddressType.measurementData ||
          message.address == AddressType.deviceStateInformation ||
          message.address == AddressType.streamData) {
        startStreamTimer();
        connectionState = GRAMConnectionState.streaming;
      }

      startWatchdogTimer(); // Got some data, restart watchdog!!!

      // Received message from same address (possible an answer)!
      if (currentMessage != null && message.address == currentMessage.address) {
        stopRetryTimer(); // Got an answer, stop retry timer and clean current nessage
        currentMessage = null;
      }

      if (message != null && message.from != -1) {
        streamController.sink.add(message); // Send the message to analysis
      }
    }
  }

  // Modificació per agafar buffers de la forma 0x02.....0x03 0x0d 0x0a
  // i buffers de la forma 0x55....0x0d 0x0a

  List<int> nextMessage() {
    // skip till first 0x02

    if (buffer == null || buffer.length == 0) {
      return null;
    }

    // skip till first 0x02
    while (buffer.length > 0 && buffer[0] != 0x02 && buffer[0] != 0x55) { // 0xaa es per el nou sistema de checks
      buffer.removeAt(0);
    }

    int i = 0;

    for (i = 0; i < buffer.length; i++) {
      if ( buffer[i] == 0x0a) { // En princip podem sempre esperar al 0x0a en comptes de buffer[i] == 0x03
        List<int> frame = buffer.sublist(0, i - 1); // Elimina el cr/nl del final
        buffer.removeRange(0, i); // El 2 correspon al  CR/NL al final



        return frame;
      }
    }

    return null;
  }

  void errorHandler(error, StackTrace trace) {
    var errorReceived = error.toString();
    Log.shared.error(
        "GRAMConnection.errorHandler", "Error al rebre dades", [errorReceived]);
    disconnect();
  }

  void doneHandler() {
    Log.shared.warning("GRAMConnection.doneHandler",
        "Connection terminated when $connectionRetries");
    disconnect();

    connectionRetries += 1;
    if (connectionRetries < maxConnectionRetries) {
      afterWifiTimer = Timer(this.afterWifiTimeout, this._connect);
    } else {
      displayAlert(context, "Cannot connect to scale",
          "Too many connection retries $connectionRetries");
    }
  }

  void watchdogHandler() {
    Log.shared.warning(
        "GRAMConnection.watchdogHandler", "Timeout waiting for messages");
    //disconnect();
    connect();  // Changed so we retry connection
  }

  void connectionFailedHandler() {
    Log.shared.error("GRAMConnection.connectionFailedHandler",
        "Connection failed. Retries $connectionRetries");

    connectionRetries = connectionRetries + 1;
    if (connectionRetries < maxConnectionRetries) {
      _connect();
    } else {
      disconnect();
      displayAlert(context, "Not Connected",
          "Failed to connect after $connectionRetries retries");
    }
  }

  void streamHandler() {
    stopStreamTimer();
    Log.shared.warning("GRAMConnection.streamHandler",
        "Timeout waiting for streaming. Changing to connected");

    // Send a stream message

    connectionState = GRAMConnectionState.connected;
    GRAMModel.shared.didReceiveData();
    enqueueMessage(GRAMMessage.startStreaming());
  }

  void enqueueMessage(GRAMMessage message) {

    if (!isQueued(message) || true) {
      messageQueue.add(message);
      Log.shared.trace("GRAMConnection.enqueueMessage",
          "Queues ${message.function} for ${message.address}");
    } else {
      Log.shared.error("GRAMConnection.enqueueMessage",
          "Already queued ${message.function} for ${message.address}");
    }
  }
  void insertMessage(GRAMMessage message) {

    if (!isQueued(message) || true) {
      messageQueue.addFirst(message);
      Log.shared.trace("GRAMConnection.enqueueMessage",
          "Queues ${message.function} for ${message.address}");
    } else {
      Log.shared.error("GRAMConnection.enqueueMessage",
          "Already queued ${message.function} for ${message.address}");
    }
  }
  Future<void> sendSERIALMessage(GRAMMessage message) async {

    if(message.address == AddressType.hashMessage){
      clearHashTimer();

      if(!model.hashOk ){

        try{
          Log.shared.warning(
              "GRAMConnection.sendSERIALMessage", sprintf("Resetting Hash Message. Last rot %d  ", [model.lastRotation[0]]) );

          String dat = GRAMMessage.readAddress(AddressType.deviceStateInformation).data();
          serialPort.write(Uint8List.fromList(dat.codeUnits));
          serialPort.write(Uint8List.fromList(dat.codeUnits));
          model.resetHash();


        }catch (error) {
          Log.shared.error("GRAMConnection.sendSERIALMessage",  "Error when resetting Hash message ",  [error.toString()]);
        }
      }

      var msg = model.buildHashPacket(model.currentHash);
      try{
        serialPort.write(Uint8List.fromList(msg));

        var restartMessage = GRAMMessage.startStreaming().data();
        serialPort.write(Uint8List.fromList(restartMessage.codeUnits));
      }catch (error) {
        Log.shared.error("GRAMConnection.sendSERIALMessage",
            "Error when sending Hash message", [error.toString()]);
      }

      model.hashOk = false;
      currentMessage = null;

      startHashTimer();
      return Future.delayed(Duration(seconds: 0));

    }

    stopRetryTimer();
    String dat = message.data();
    try {

      serialPort.write(Uint8List.fromList(dat.codeUnits));
    } on Exception catch (e) {
      Log.shared.error("GRAMConnection.sendSERIALMessage",
          "Exception when sending message " + e.toString());
    } catch (error) {
      Log.shared.error("GRAMConnection.sendSERIALMessage",
          "Error when sending message", [error.toString()]);
    }
    currentMessage = message;
    startRetryTimer();

    Log.shared.trace("GRAMConnection.sendSERIALMessage",
        "Written message ${message.function} for address ${message.address}");
  }

  Future<void> sendMessage(GRAMMessage message) async {
    if (protocol == GRAMConnectionType.UDP) {
      return await sendUDPMessage(message);
    } else if (protocol == GRAMConnectionType.TCP) {
      return await sendTCPMessage(message);
    } else if (protocol == GRAMConnectionType.SERIAL) {
      return  await sendSERIALMessage(message);
    }


  }

  Future<void> sendUDPMessage(GRAMMessage message) async {
    stopRetryTimer();
    String dat = message.data();
    try {
      if (mode == GRAMConnectionMode.normal) {
        Log.shared.trace(
            "GRAMConnection.sendUDPMessage", "Sending SerialMessage " + dat);
        await sender.send(
            dat.codeUnits,
            Endpoint.unicast(
                InternetAddress(model.scale.ipAddress,
                    type: InternetAddressType.IPv4),
                port: Port(model.scale.port)));
      } else {
        await sender.send(dat.codeUnits, Endpoint.broadcast(port: Port(4445)));
      }
    } on Exception catch (_) {
      Log.shared.error(
          "GRAMConnection.sendUDPMessage", "Exception when sending message");
    } catch (error) {
      Log.shared.error("GRAMConnection.sendMessage",
          "Error when sending message", [error.toString()]);
    }
    currentMessage = message;
    startRetryTimer();

    Log.shared.trace("GRAMConnection.sendUDPMessage",
        "Written message ${message.function} for address ${message.address}");

    return Future.delayed(Duration(seconds: 0));
  }

  Future<void> sendTCPMessage(GRAMMessage message) {
    stopRetryTimer();
    String dat = message.data();
    try {
      socket.write(dat);
      socket.flush();
    } on Exception catch (_) {
      Log.shared.error(
          "GRAMConnection.sendTCPMessage", "Exception when sending message");
    } catch (error) {
      Log.shared.error("GRAMConnection.sendTCPMessage",
          "Error when sending message", [error.toString()]);
    }
    currentMessage = message;
    startRetryTimer();

    Log.shared.trace("GRAMConnection.sendTCPMessage",
        "Written message ${message.function} for address ${message.address}");

    return Future.delayed(Duration(seconds: 0));
  }

  void processNextMessage() async {
    if (messageQueue.isEmpty) {
      // Log.shared.warning("processNextmessage", "Trying to process message when queue is empty");
    } else if (currentMessage != null) {
      Log.shared.warning(
          "processNextAessage",
          "Trying to process message when already currentMessage",
          [currentMessage, messageQueue.removeFirst()]);
    } else {
      var message = messageQueue.removeFirst();
      await sendMessage(message);
    }
  }

  void retryHandler() async {
    if (currentMessage != null) {
      Log.shared.trace("GRAMConnection.handleRetryTimeout",
          "Retrying message ${currentMessage.function} for address ${currentMessage.address} ");

      await sendMessage(currentMessage);
    }
  }

  // utility to get all scale data

  void getScaleData() {
    enqueueMessage(GRAMMessage.readAddress(AddressType.sealing));
    enqueueMessage(GRAMMessage.getSSIDName());
    //enqueueMessage(GRAMMessage.getSerialNumber()); Automatically called from serialNumber!!!
    enqueueMessage(GRAMMessage.getDeviceId());
    enqueueMessage(GRAMMessage.getModuleBoardCode());
    enqueueMessage(GRAMMessage.getFirmwareVersion());
    enqueueMessage(GRAMMessage.getOptionalBoard());
    enqueueMessage(GRAMMessage.getOutputRate());
    enqueueMessage(GRAMMessage.getBaudRate());

    enqueueMessage(GRAMMessage.getScaleUnit());
    enqueueMessage(GRAMMessage.getDecimalPointPosition());
    enqueueMessage(GRAMMessage.getResolutionFactor());
    enqueueMessage(GRAMMessage.getRangeMode());
    enqueueMessage(GRAMMessage.getMax1());
    enqueueMessage(GRAMMessage.gete1());
    enqueueMessage(GRAMMessage.getMax2());
    enqueueMessage(GRAMMessage.gete2());


    enqueueMessage(GRAMMessage.getAllowNegativeWeight());

    enqueueMessage(GRAMMessage.getInitialZero());
    enqueueMessage(GRAMMessage.getInitialZeroRange());
    enqueueMessage(GRAMMessage.getTareOnStability());
    enqueueMessage(GRAMMessage.getAutoTare());
    enqueueMessage(GRAMMessage.getZeroTracking());
    enqueueMessage(GRAMMessage.getZeroTrackingRange());
    enqueueMessage(GRAMMessage.getFilterLevel());
    enqueueMessage(GRAMMessage.getLivestockFilter());
    enqueueMessage(GRAMMessage.getMotionFilter());
    enqueueMessage(GRAMMessage.getStabilityRange());

    enqueueMessage(GRAMMessage.getGeoCode());
    enqueueMessage(GRAMMessage.getGeoCodeAdjustment());
    enqueueMessage(GRAMMessage.getAdSpeed());


   }

  void getNetworkData(){

      enqueueMessage(GRAMMessage.getNetDhcp());
      enqueueMessage(GRAMMessage.getNetIp());
      enqueueMessage(GRAMMessage.getNetworkName());
      enqueueMessage(GRAMMessage.getNetworkPassword());


      enqueueMessage(GRAMMessage.getSSIDPassword());
      enqueueMessage(GRAMMessage.getIPAddress());

      enqueueMessage(GRAMMessage.getUDPLocalPort());
      enqueueMessage(GRAMMessage.getUDPRemotePort());


      enqueueMessage(GRAMMessage.getTCPServerPort());
      enqueueMessage(GRAMMessage.getAccessPoint());


      enqueueMessage(GRAMMessage.startStreaming());


  }

  void getRanges(){

  }
  void getSetupData() {

    return; // Ara ho recollim tot al començar

    enqueueMessage(GRAMMessage.readAddress(AddressType.sealing));

    enqueueMessage(GRAMMessage.getSerialNumber());
    enqueueMessage(GRAMMessage.getDeviceId());
    enqueueMessage(GRAMMessage.getSSIDName());
    enqueueMessage(GRAMMessage.getModuleBoardCode());
    enqueueMessage(GRAMMessage.getFirmwareVersion());
    enqueueMessage(GRAMMessage.getOptionalBoard());


    enqueueMessage(GRAMMessage.getNetworkName());
    enqueueMessage(GRAMMessage.getNetworkPassword());
    enqueueMessage(GRAMMessage.getNetDhcp());
    enqueueMessage(GRAMMessage.getNetIp());

    enqueueMessage(GRAMMessage.getInitialZero());
    enqueueMessage(GRAMMessage.getInitialZeroRange());
    enqueueMessage(GRAMMessage.getTareOnStability());
    enqueueMessage(GRAMMessage.getAutoTare());
    enqueueMessage(GRAMMessage.getZeroTracking());
    enqueueMessage(GRAMMessage.getZeroTrackingRange());
    enqueueMessage(GRAMMessage.getFilterLevel());
    enqueueMessage(GRAMMessage.getLivestockFilter());
    enqueueMessage(GRAMMessage.getMotionFilter());
    enqueueMessage(GRAMMessage.getStabilityRange());
  }

  void destroy() {
    streamController.close();
  }
}
