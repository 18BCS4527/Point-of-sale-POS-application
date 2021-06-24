import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/home.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {

  TextEditingController mail=new TextEditingController();
  TextEditingController pass=new TextEditingController();
  String token;


  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ListView(children: [
      Center(
        child: Container(width: MediaQuery.of(context).size.width*0.5,height: MediaQuery.of(context).size.height*0.4,
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),
            alignment: Alignment.topCenter,
            child: Image.asset('assets/icon.png')
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(padding: EdgeInsets.only(left: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
              border: Border.all(color: Colors.black38)),
          child: TextField(controller: mail,
            showCursor: true,textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: Color(0xFF666666),),
              hintText: "Gmail ID",
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 18,right: 18,top: 4),
        child: Container(padding: EdgeInsets.only(left: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
              border: Border.all(color: Colors.black38)),
          child: TextField(controller: pass,
            showCursor: true,textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: Color(0xFF666666),),
              hintText: "Password",
            ),
          ),
        ),
      ),
      Container(alignment: Alignment.centerRight,padding: EdgeInsets.only(right: 18,top: 4,bottom: 18),
        child: GestureDetector(child: Text('Forgot Password?',style: TextStyle(fontWeight: FontWeight.bold),),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>ForgotPass()));
          },),),
      Padding(
        padding: EdgeInsets.all(18.0),
        child: Container(
          width: double.infinity,
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            gradient: new LinearGradient(
                colors: [Colors.blueAccent,Colors.lightGreen],
                begin: FractionalOffset(0.1, 0.1),
                end: FractionalOffset(0.9, 0.9),
                stops: [0.0, 2.0],
                tileMode: TileMode.mirror),
          ),
          child: MaterialButton(
              highlightColor: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                child: Text("Sign In", style: TextStyle(color: Colors.white),),
              ),
              onPressed: () {
                if(mail.text.length>10&&pass.text.length>6){
                  _sigIn();
                }else{
                  Fluttertoast.showToast(msg: 'Please provide valid information',gravity: ToastGravity.BOTTOM);
                }
              }
          ),
        ),
      ),
    ],),
    );
  }

  Future _sigIn()async{
    showDialog(context: context,builder: (context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }, barrierDismissible: false);
    FirebaseAuth auth=FirebaseAuth.instance;
    FirebaseMessaging messaging=FirebaseMessaging();
    messaging.getToken().then((onValue){
      print(onValue);
      setState(() {
        token=onValue;
      });
    });
    auth.signInWithEmailAndPassword(email: mail.text.trim(), password: pass.text.trim()).then((value){
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>Home()));
    }).catchError((onError){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: onError.toString(),gravity: ToastGravity.BOTTOM);
    });
  }
}




class ForgotPass extends StatefulWidget {
  @override
  _ForgotPassState createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {

  TextEditingController mail=new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,
      leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.black,),onPressed: (){
        Navigator.pop(context);
      },),),
      body:  Container(height: MediaQuery.of(context).size.height,
        child: ListView(children: [
          Center(
            child: Container(width: MediaQuery.of(context).size.width*0.5,height: MediaQuery.of(context).size.height*0.35,
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05),
                alignment: Alignment.topCenter,
                child: Image.asset('assets/icon.png')
            ),
          ),
          Center(child: Text('Forgot Your Password?',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),)),
          Container(margin: EdgeInsets.only(left: 35,right: 35,top: 8),child: Text("We'll send instructions on how to reset your password to the register mail address with us")),
          Padding(
            padding: const EdgeInsets.only(left: 18,right: 18,top: 25,bottom: 18),
            child: Container(padding: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                  border: Border.all(color: Colors.black38)),
              child: TextField(controller: mail,
                showCursor: true,textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF666666),),
                  hintText: "Gmail ID",
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 18,right: 18,bottom: 50),
            child: Container(
              width: double.infinity,
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                gradient: new LinearGradient(
                    colors: [Colors.blueAccent,Colors.lightGreen],
                    begin: FractionalOffset(0.1, 0.1),
                    end: FractionalOffset(0.9, 0.9),
                    stops: [0.0, 2.0],
                    tileMode: TileMode.mirror),
              ),
              child: MaterialButton(
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text("Send", style: TextStyle(color: Colors.white),),
                  ),
                  onPressed: () {
                    if(mail.text.length>10){
                      _reset();
                    }else{
                      Fluttertoast.showToast(msg: 'Please provide valid information',gravity: ToastGravity.BOTTOM);
                    }
                  }
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter,
            child: GestureDetector(
              child: RichText(textAlign: TextAlign.center,text: TextSpan(text: "Don't have an account? ",style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: 'Sign In',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.lightGreen))
                  ]),),
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>LogIn()));
              },),
          ),
        ],),
      ),
    );
  }

  void _reset(){
    showDialog(context: context,builder: (context) {
      return Center(
        child: CircularProgressIndicator(backgroundColor: Colors.amber,),
      );
    }, barrierDismissible: false);
    FirebaseAuth auth=FirebaseAuth.instance;
    auth.sendPasswordResetEmail(email: mail.text.trim()).then((value){
      Navigator.pop(context);
      _success();
    }).catchError((onError){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: onError.toString(),gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_LONG);
    });
  }

  void _success(){
    showDialog(context: context, builder: (context)=>Center(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(child: Icon(Icons.check_sharp,color: Colors.white,size: 45,),backgroundColor: Colors.lightGreen,radius: 40,),
              Text('Success',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.grey),),
              Padding(
                padding: const EdgeInsets.only(left: 25,right: 25,top: 18,bottom: 18),
                child: Text('Password reset link was send to your mail.',style: TextStyle(color: Colors.grey),textAlign: TextAlign.center,),
              ),
              Container(width: MediaQuery.of(context).size.width*0.6,
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(color: Colors.lightGreen,child: Text('Ok',style: TextStyle(color: Colors.white),),onPressed: (){
                  Navigator.pop(context);
                },),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
