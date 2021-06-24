import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'data.dart';
import 'order.dart';

class NewBill extends StatefulWidget {
  @override
  _NewBillState createState() => _NewBillState();
}

class _NewBillState extends State<NewBill> {


  List<TableData>tables=[];
  TextEditingController table=new TextEditingController();
  TextEditingController level=new TextEditingController();
  String grid='grid';

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
    return Scaffold(appBar: AppBar(elevation: 0,title: Text('Select Table'),
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(64.0),
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
      ),
      actions: [
        grid!='grid'?IconButton(icon: Icon(Icons.grid_view),onPressed: (){
          setState(() {
            grid='grid';
          });
        },):IconButton(icon: Icon(Icons.list),onPressed: (){
          setState(() {
            grid='list';
          });
        },)
      ],
    ),
        body: grid=='list'?ListView.builder(physics: BouncingScrollPhysics(),shrinkWrap: true,
          itemCount: tables.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
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
                  onTap: (){
                    if(tables[index].status){
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>Order(tables[index].table,tables[index].doc)));
                    }else{
                      Fluttertoast.showToast(msg: 'This table was already reserved');
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18,right: 18),
                  child: Divider(),
                )
              ],
            );
          },):GridView.count(crossAxisCount: MediaQuery.of(context).size.width>400?5:3,
          childAspectRatio: 3/2.5,
          children: List.generate(tables!=null&&tables.isNotEmpty?tables.length:0,
                  (index) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                  child: Container(decoration: BoxDecoration(color: Colors.white,shape: BoxShape.circle,
                      border: Border.all(color: tables[index].status?Colors.green:Colors.red,width: 3),boxShadow: [
                        BoxShadow(blurRadius: 8,color: Colors.grey.shade300)
                      ]),
                    child: Column(children: [
                      Image.asset('assets/table.png',fit: BoxFit.contain,width: 40,height: 40,),
                      Text('${tables[index].table}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                      Text('${tables[index].level}',style: TextStyle(color: Colors.grey.shade600),),
                    ],),
                  ),
                  onTap: (){
                    if(tables[index].status){
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>Order(tables[index].table,tables[index].doc)));
                    }else{
                      Fluttertoast.showToast(msg: 'This table was already reserved');
                    }
                  },
                ),
              )
          ),
        )
    );
  }

}

