import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'data.dart';

class TableView extends StatefulWidget {
  @override
  _TableViewState createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {


  List<TableData>tables=[];
  TextEditingController table=new TextEditingController();
  TextEditingController level=new TextEditingController();

  Future _get()async{
    tables=[];
    CollectionReference reference=Firestore.instance.collection('Tables');
    try{
      QuerySnapshot snapshot=await reference.getDocuments();
      snapshot.documents.map((e){
        setState(() {
          tables.add(TableData(e.data['table'], e.data['level'], e.documentID,e.data['status']));
        });
      }).toList();
    }catch(e){
      print(e.toString());
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    _get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(elevation: 0,title: Text('Tables'),
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(55.0),
          child: Container(width: MediaQuery.of(context).size.width,
            height: 60,
            padding: const EdgeInsets.all(8.0),
            child: Container(color: Colors.white,
              padding: EdgeInsets.only(left: 8),
              child: TextField(
                showCursor: true,textAlign: TextAlign.left,
                decoration: InputDecoration(suffixIcon: Icon(Icons.search_rounded),
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF666666),),
                  hintText: "Search Table no (ex. T01..)",
                ),
              ),
            ),
          )
      ),),
      body: ListView.builder(physics: BouncingScrollPhysics(),shrinkWrap: true,
        itemCount: tables.length+1,
        itemBuilder: (BuildContext context, int index) {
          return tables!=null&&tables.length>index?Column(
            children: [
              ListTile(leading: CircleAvatar(radius: 35,
                child: Image.asset('assets/table.png',fit: BoxFit.contain,width: 40,height: 40,),
              ),
                title: Text('${tables[index].table}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                subtitle: Text('${tables[index].level}'),
                trailing: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CircleAvatar(backgroundColor: tables[index].status?Colors.green:Colors.red,radius: 6,),
                    ),
                  ],
                ),
                onLongPress: (){
                if(!tables[index].status){
                  _clear(tables[index].doc);
                }else{
                  Fluttertoast.showToast(msg: 'Not yet reserved!');
                }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18,right: 18),
                child: Divider(),
              )
            ],
          ):Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade400,blurRadius: 6)
                ]),
              padding: EdgeInsets.all(4),
              child: IconButton(icon: Icon(Icons.add), onPressed: () {
                _dailog();
              },),),
          );
        },),);
  }

  void _clear(String id){
    showDialog(context: context, builder: (context)=>Center(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Column(  mainAxisSize: MainAxisSize.min,children: [
          Padding(
            padding: const EdgeInsets.only(left: 32,top: 32,right: 32,bottom: 32),
            child: Text('Are you sure to clear Table?',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16,bottom: 16),
            child: Container(width: MediaQuery.of(context).size.width*0.3,
              margin: EdgeInsets.only(left: 8,right: 8),
              child: RaisedButton(elevation: 1,
                onPressed: () {
                _delete(id);
                Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                padding: EdgeInsets.all(16.0),
                color: Colors.green,
                child: Text(
                  "Clear",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          )
        ],),),
    ));
  }


  Future _delete(String doc)async{
    CollectionReference reference=Firestore.instance.collection('Tables');
    try{
      reference.document(doc).setData({'status':true},merge: true);
      _get();
    }catch(e){
      Fluttertoast.showToast(msg: 'Status Updated');
    }
  }


  void _dailog(){
    showDialog(context: context, builder: (context)=>Center(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 18,right: 18,top: 25,bottom: 8),
                child: Container(padding: EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                      border: Border.all(color: Colors.black38)),
                  child: TextField(controller: table,
                    showCursor: true,textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Color(0xFF666666),),
                      hintText: "Table No.",
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18,right: 18,top: 8,bottom: 18),
                child: Container(padding: EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                      border: Border.all(color: Colors.black38)),
                  child: TextField(controller: level,
                    showCursor: true,textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Color(0xFF666666),),
                      hintText: "Level no",
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
                        child: Text("Save", style: TextStyle(color: Colors.white),),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _upload();
                      }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future _upload()async{
    CollectionReference reference=Firestore.instance.collection('Tables');
    try{
      reference.document().setData({
        'table':table.text,
        'level':level.text,
        'status':true
      },merge: true);
      _get();
      _success();
    }catch(e){
      print(e.toString());
    }
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
