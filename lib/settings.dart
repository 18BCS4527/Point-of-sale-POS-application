import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';


class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool v=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(elevation: 0,title: Text('Settings'),),
      body: ListView(children: [
        ListTile(title: Text('LandScape',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        trailing: FlutterSwitch(width: 40,height: 20,value: v, onToggle: (value){
          if(value){
            SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]);
            setState(() {
              v=value;
            });
          }else{
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitUp]);
            setState(() {
              v=value;
            });
          }
        }),)
      ],),
    );
  }
}
