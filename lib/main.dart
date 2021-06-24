import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'login.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  final FirebaseAuth _auth=FirebaseAuth.instance;
  Future _getData() async{
    final FirebaseUser user=await _auth.currentUser();
    Timer(Duration(seconds: 2), (){
      if(user==null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LogIn()));
      }
      else if(user!=null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>Home()));
      }
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Center(
            child: Container(width: MediaQuery.of(context).size.width*0.6,height: MediaQuery.of(context).size.height*0.4,
                alignment: Alignment.center,
                child: Image.asset('assets/icon.png')
            ),
          ),
          Align(alignment: Alignment.bottomCenter,
            child: Column(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('DiAtus Enterprise Pvt Ltd.', style: TextStyle(fontWeight: FontWeight.bold),),
                Container(width: 200,
                  padding: const EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(minHeight: 2,),
                ),
                SizedBox(height: 40,)
              ],
            ),
          )
        ],),
    ),
    );
  }
}