import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pos/printer.dart';
import 'package:pos/update.dart';

import 'data.dart';
import 'edit.dart';


class OrderView extends StatefulWidget {
  final OrderData data;

  OrderView(this.data);

  @override
  _OrderViewState createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {

  List<CartData>items=[];

  Future _get()async{
    CollectionReference reference=Firestore.instance.collection('OrderItems');
    try{
      QuerySnapshot snapshot=await reference.where('order',isEqualTo: widget.data.id).getDocuments();
      snapshot.documents.map((e){
        setState(() {
          items.add(CartData(e.data['item'], e.data['price'], e.data['profit'], e.data['count'], e.data['total'], e.data['sellerTotal'], e.documentID, e.data['filter']));

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
    return Scaffold(appBar: AppBar(elevation: 0,title: Text('${widget.data.id}'),
      actions: [
        IconButton(onPressed: () {
          if(items!=null&&items.isNotEmpty){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>Edit(items, widget.data)));
          }else{
            Fluttertoast.showToast(msg: 'Something went wrong!');
          }
        }, icon: Icon(Icons.edit_outlined),)
      ],),
      body: MediaQuery.of(context).size.width<400?ListView(shrinkWrap: true,physics: BouncingScrollPhysics(),children: [
        _left(),
        _right()
      ],):ListView(shrinkWrap: true,physics: BouncingScrollPhysics(),children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
          Expanded(flex: 4,child: _left(),),
          Expanded(flex: 6,child: _right(),)
        ],)
      ],),);
  }

  _left(){
    return ListView(physics: BouncingScrollPhysics(),shrinkWrap: true,children: [
      Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(title: Text('${widget.data.id}'),
            subtitle: Text('${DateFormat(DateFormat.YEAR_MONTH_DAY, 'en_US').format(DateTime.fromMicrosecondsSinceEpoch(widget.data.time*1000))}'),
            trailing: Text('₹${widget.data.total}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16,top: 8),
            child: Text('Guest Details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          ),
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(left: 16,top: 8,bottom: 8),
              child: Image.asset('assets/table.png',width: 25,height: 25,color: Colors.grey.shade900,),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16,top: 8,bottom: 8),
              child: Text('Table No: ${widget.data.table}',style: TextStyle(fontSize: 16),),
            ),
          ],),
          Row(children: [
            Padding(
                padding: const EdgeInsets.only(left: 16,top: 8,bottom: 8),
                child: Icon(Icons.group_outlined)
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16,top: 8,bottom: 8),
              child: Text('No.of Guest: ${widget.data.guest}',style: TextStyle(fontSize: 16),),
            ),
          ],),
          Padding(
            padding: const EdgeInsets.only(left: 16,top: 8),
            child: Text('Payment Method',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          ),
          widget.data.payment=='Cash'?ListTile(leading: CachedNetworkImage(imageUrl: 'https://firebasestorage.googleapis.com/v0/b/diatus-pos.appspot.com/o/paying.png?alt=media&token=3485f90f-78ec-42c1-b99b-6a2c37fc71d7',width: 30,height: 30,),
            title: Text('Cash Payment',style: TextStyle(fontWeight: FontWeight.w500)
            ),
          ):ListTile(leading: Icon(Icons.credit_card,color: Colors.blue,size: 25,),
            title: Text('Online/Card Payment',style: TextStyle(fontWeight: FontWeight.w500)
            ),
          ),
        ],
      ),
      ),
    ],);
  }

  _right(){
    return ListView(physics: BouncingScrollPhysics(),shrinkWrap: true,children: [
      Padding(
        padding: const EdgeInsets.only(left: 16,top: 16),
        child: Text('Items Summary',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
      ),
      DataTable(columnSpacing: 8,columns: [
        DataColumn(label: Text("Name",style: TextStyle(fontSize: 16),)),
        DataColumn(label: Container(child: Text("Quantity",style: TextStyle(fontSize: 16),))),
        DataColumn(label: Container(child: Text("Price",style: TextStyle(fontSize: 16),))),
        DataColumn(label: Container(child: Text("Total",style: TextStyle(fontSize: 16),))),
      ],
          rows: items.map((list)=>DataRow(cells: [
            DataCell(Container(width: 100,child: Text('${list.name}',maxLines: 2,overflow: TextOverflow.ellipsis,))),
            DataCell(Container(width: 40,child: Text(list.count.toString()))),
            DataCell(Container(width: 40,child: Text('${list.price}'))),
            DataCell(Container(width: 40,child: Text('${list.total}')))
          ])).toList()
      ),
      Divider(),
      Container(width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 16),
        child:  Text('GST 5% : ₹${widget.data.gst}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade600),textAlign: TextAlign.right,),
      ),
      Container(width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 16,top: 16),
        child:  Text('Sub Total : ₹${widget.data.sub}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade600),textAlign: TextAlign.right,),
      ),
      Container(width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 16,top: 16),
        child:  Text('Total Price : ₹${widget.data.total}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),textAlign: TextAlign.right,),
      ),
      SizedBox(height: 10,),
      Row(children: [
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 16,bottom: 16),
          child: Container(width: MediaQuery.of(context).size.width*0.6,
            margin: EdgeInsets.only(left: 8,right: 8),
            child: RaisedButton.icon(elevation: 1,
              icon: Icon(Icons.keyboard_arrow_up_outlined),
              onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> Update(int.parse(widget.data.sub),  double.parse(widget.data.gst), double.parse(widget.data.total),widget.data.id, widget.data.doc)));
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(16.0),
              color: Colors.red,
              label: Text(
                "Update Bill",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
          ),
        ),),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 16,bottom: 16),
          child: Container(width: MediaQuery.of(context).size.width*0.6,
            margin: EdgeInsets.only(left: 8,right: 8),
            child: RaisedButton.icon(elevation: 1,
              icon: Icon(Icons.print),
              onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>Printer(widget.data, items)));
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(16.0),
              color: Colors.green,
              label: Text(
                "Print Bill",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
          ),
        ),)
      ],)
    ],);
  }
}
