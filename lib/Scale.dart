import 'GRAMConnection.dart';
import 'GRAMModel.dart';

class Scale {
    String name ;
    String ssid;
    String passphrase;
    String ipAddress;
    int port;
    String networkName;
    String networkPassword;
    int networkPort;


    Scale({String name : "Config",
        String ssid : "/dev/ttyS3",
        String passphrase : "12345678",
        String ipAddress : "192.168.4.1",
        int port : 4444,
        String networkName : "new",
        String networkPassword : "new",
        int networkPort : 4445}){

        if (name == "Config" && deviceType == DeviceType.terminal){
            print("Creating a tty scale");
            this.name = "ttyS3";
            this.ssid = "/dev/ttyS3";
            this.passphrase = passphrase;
            this.ipAddress = ipAddress;
            this.port = 115200;
            this.networkName = "tty";
            this.networkPassword = networkPassword;

        }else if (name == "Config" && deviceType != DeviceType.terminal){
            print("Creating a UDP scale");
            this.name = "Config";
            this.ssid = "GRAM_01";
            this.passphrase = passphrase;
            this.ipAddress = ipAddress;
            this.port = port;
            this.networkPassword = networkPassword;

        }else {
            print("Creating a generic scale");
            this.name = name;
            this.ssid = ssid;
            this.passphrase = passphrase;
            this.ipAddress = ipAddress;
            this.port = port;
            this.networkName = networkName;
            this.networkPassword = networkPassword;
            this.networkPort = networkPort;
        }
    }

    Scale.fromJson(Map<String, dynamic> json){
        name = json['name'];
        ssid = json['ssid'];
        passphrase = json['passphrase'];
        ipAddress = json['ipAddress'];
        port =   json['port'];
        networkName =   json['networkName'];
        networkPassword =   json['networkPassword'];
        networkPort =   json['networkPort'];
    }

    Map<String, dynamic> toJson() {
        return{
            'name' : name,
            'ssid' : ssid,
            'passphrase' : passphrase,
            'ipAddress' : ipAddress,
            'port' :port,
            'networkName' : networkName,
            'networkPassword' : networkPassword,
            'networkPort' : networkPort
         };
    }

    Scale duplicateWithSsid(String ssid){

        var sc = Scale();

        sc.name = ssid;
        sc.ssid = ssid;
        sc.ipAddress = this.ipAddress;
        sc.passphrase = this.passphrase;
        sc.port = this.port;
        sc.networkName = this.networkName;
        sc.networkPassword = this.networkPassword;
        sc.networkPort = this.networkPort;

        return sc;
    }

    GRAMConnectionType type(){
        if (ssid.startsWith("/dev/tty")){
            return GRAMConnectionType.SERIAL;
        }else{
            return GRAMConnectionType.UDP;
        }
    }

    int speed(){
        if (type == GRAMConnectionType.SERIAL){
            return port;
        }else {
            return 0;
        }
    }
}

