import 'package:flutter/material.dart';
import 'GRAMModel.dart';
import 'LabeledSwitch.dart';
import 'LabeledTextField.dart';
import 'GRAMMessage.dart';

class NetworkOptions extends StatefulWidget {
  _NetworkOptionsState createState() => _NetworkOptionsState();
}

class _NetworkOptionsState extends State<NetworkOptions> {
  GRAMModel model = GRAMModel.shared;

  @override
  void initState() {
    super.initState();
    model.addSubscriptor(this, tecnic: true);
  }

  void dispose() {
    model.removeSubscriptors(this);
    super.dispose();
  }

  void setNetworkAddress(String newValue) {
    print("Network IP Address : ${[newValue]}");
    model.connection.enqueueMessage(GRAMMessage.netIp(newValue));
  }

  void setNetworkDHCP(bool newValue) {
    print("Network DHCP : ${[newValue]}");
    model.connection.enqueueMessage(GRAMMessage.netDhcp(newValue));
    
  }
  
  void setTCPServerPort(String newValue){

    print("tcpServerPort : ${[newValue]}");
    int port = int.parse(newValue);
    model.tcpServerPort = port;
    model.connection.enqueueMessage(GRAMMessage.tcpServerPort(port));
  }

 
  void setUDPRemotePort(String newValue) {
    print("UDP Remote Port : ${[newValue]}");
    int port = int.parse(newValue);
    model.udpRemotePort = port;
    model.connection.enqueueMessage(GRAMMessage.udpRemotePort(port));

  }

  void setUDPLocalPort(String newValue) {
    print("UDP Local Port : ${[newValue]}");
    int port = int.parse(newValue);
    model.udpLocalPort = port;
    model.connection.enqueueMessage(GRAMMessage.udpLocalPort(port));

  }


  void setMyNetworkDHCP(bool newValue) {
    print("Network DHCP : ${[newValue]}");
    model.connection.enqueueMessage(GRAMMessage.netDhcp(newValue));
    model.netDhcp = newValue;
  }

  void resetNetwork() {
    print("Resetting Network");
  }


  // Access Point

  void setAPSSID(String newValue) {
    model.connection.enqueueMessage(GRAMMessage.ssidName(newValue));
    model.scaleName = newValue;
    print("Setting AP SSID to ${newValue}");
  }

  void setAPPassword(String newValue) {
    model.connection.enqueueMessage(GRAMMessage.ssidPassword(newValue));
    model.apPassword = newValue;
    print("set AP Password to ${newValue}");
  }

  void setAPIPAddress(String newValue) {
    model.connection.enqueueMessage(GRAMMessage.ipAddress(newValue));
    model.ipBaseAddress = newValue;
    print("set IP Base Address to ${newValue}");
  }

  void setAccessPoint(bool newValue) {
    model.connection.enqueueMessage(GRAMMessage.accessPoint(newValue));
    model.isAccessPoint = newValue;
    print("Set Access point to ${newValue}");
  }

  // STA

  void setNetworkName(String newValue) {
    model.connection.enqueueMessage(GRAMMessage.networkName(newValue));
    model.netName = newValue;
    print("Setting Network SSID to ${newValue}");
  }

  void setNetworkPassword(String newValue) {
    model.connection.enqueueMessage(GRAMMessage.networkPassword(newValue));
    model.netPassword = newValue;
    print("set Network Password to ${newValue}");
  }


  void tecnicUpdated(AddressType type, String data) {
    if (type == AddressType.netDhcp) {
      setState(() {

      });
    }
    if (type == AddressType.accessPoint) {
      setState(() {

      });
    }


  }

  Widget buildNetwork() {
    return Wrap(
      runSpacing: 10.0,
      children: [
        labeledTextField(model.tr.localize("Network IP address"),
            model.netIp, setNetworkAddress),
        labeledSwitch(model.tr.localize("Network DHCP"), model.netDhcp,
            setMyNetworkDHCP), // TODO: Assign var
        labeledNumericField(model.tr.localize("TCP Server port"),
            model.tcpServerPort.toString(), setTCPServerPort),
        labeledNumericField(model.tr.localize("UDP remote port (PC side)"),
            model.udpRemotePort.toString(), setUDPRemotePort),
        labeledNumericField(model.tr.localize("UDP local port (XTREM side)"),
            model.udpLocalPort.toString(), setUDPLocalPort),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Spacer(),
          OutlinedButton(
            onPressed: resetNetwork,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
            ),
            child: Text(
              model.tr.localize("Reset network with current settings"),
            ),
          ),
          Spacer(),
        ]),
      ],
    );
  }

  Widget buildWiFi() {
    return Wrap(
      runSpacing: 10.0,
      children: [
        Text("AP"),
        labeledTextField(model.tr.localize("SSID as access point"),
            model.scaleName, setAPSSID),
        labeledTextField(model.tr.localize("Password"),
            model.apPassword, setAPPassword),

        labeledTextField(model.tr.localize("IP base address"),
            model.ipBaseAddress, setAPIPAddress),

        labeledSwitch(model.tr.localize("Access Point"), model.isAccessPoint,
            setAccessPoint), // TODO: Assign var



        Text("STA"),


        labeledTextField(model.tr.localize("Network  SSID"),
            model.netName, setNetworkName),
        labeledTextField(model.tr.localize("Network Password"),
            model.netPassword, setNetworkPassword),

        labeledTextField(model.tr.localize("Network IP address"),
            model.netIp, setNetworkAddress),

        labeledSwitch(model.tr.localize("Network DHCP"), model.netDhcp,
            setNetworkDHCP), // TODO: Assign var

        Text("PORTS"),

        labeledNumericField(model.tr.localize("TCP Server port"),
            model.tcpServerPort.toString(), setTCPServerPort),
        labeledNumericField(model.tr.localize("UDP remote port (PC side)"),
            model.udpRemotePort.toString(), setUDPRemotePort),
        labeledNumericField(model.tr.localize("UDP local port (XTREM side)"),
            model.udpLocalPort.toString(), setUDPLocalPort),



      ],
    );
  }

  Widget build(BuildContext context) {
    switch (model.optionalBoard) {
      case "01":
        return buildNetwork();
        break;

      case "02":
        return buildWiFi();
        break;

      default:
        return buildWiFi();

        break;
    }
  }
}
