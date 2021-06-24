import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'order_list.dart';


class Edit extends StatefulWidget {
  final   List<CartData>items;
  final   OrderData data;

  Edit(this.items,this.data);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {

  List<CartData>items=[];

  int subtotal=0;
  double gst=0;
  double total=0;

  Future _calculate()async{
    subtotal=0;
    gst=0;
    total=0;
    items.map((e) {
      setState(() {
        subtotal=subtotal+int.parse(e.total);
      });
    }).toList();
    gst=subtotal*5/100;
    total=double.parse(subtotal.toString())+gst;
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    items=List.from(widget.items);
    _calculate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Edit Order'),),
      body: ListView(children: items.map((e){
        return ListTile(title: Text('${e.name} (${e.count})'),
        subtitle: Text('₹${e.total}',style: TextStyle(fontSize: 16),),
        trailing: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container( constraints: BoxConstraints(maxWidth: 80.0, minHeight: 20.0,maxHeight: 30.0),
            child: Row(children: [
              Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                child: IconButton(padding: EdgeInsets.all(0),icon: Icon(Icons.remove),
                  onPressed: () async {
                    if(e.count>1){
                      setState(() {
                        items.insert(items.indexOf(e).toInt(),CartData(e.name, e.price, e.profit, e.count-1, ((e.count-1)*int.parse(e.price)).toString(), ((e.count-1)*int.parse(e.profit)).toString(), e.product,e.filter));
                        items.removeAt(items.indexOf(e).toInt());
                      });
                    }
                    else{
                      setState(() {
                        items.removeAt(items.indexOf(e).toInt());
                      });
                    }
                    _calculate();
                  },),
              ),),
              Expanded(child: Container(height: MediaQuery.of(context).size.height,alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.blueAccent,border: Border.all(color: Colors.grey.shade300)),
                  child: Text('${e.count}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),),
              Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                child: IconButton(padding: EdgeInsets.all(0),
                  icon: Icon(Icons.add),
                  onPressed: (){
                    setState(() {
                      items.insert(items.indexOf(e).toInt(),CartData(e.name, e.price, e.profit, e.count+1, ((e.count+1)*int.parse(e.price)).toString(), ((e.count+1)*int.parse(e.profit)).toString(), e.product,e.filter));
                      items.removeAt(items.indexOf(e).toInt());
                    });
                    _calculate();
                  },),
              ),)
            ],),
          ),
        ),);
      }).toList(),),
      bottomNavigationBar:  Padding(
        padding: const EdgeInsets.only(top: 16,bottom: 16),
        child: Container(width: MediaQuery.of(context).size.width*0.6,
          margin: EdgeInsets.only(left: 16,right: 16),
          child: RaisedButton(elevation: 1,
            onPressed: () {
            _items();
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
            padding: EdgeInsets.all(16.0),
            color: Colors.green,
            child: Text(
              "Continue",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _items()async{
    showDialog(context: context,builder: (context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }, barrierDismissible: false);
    CollectionReference reference=Firestore.instance.collection('OrderItems');
    try{
      widget.items.map((e) {

        if(items.where((element) => element.product.contains(e.product)).toList().isNotEmpty){
          items.where((element) => element.product.contains(e.product)).toList().map((c){
            reference.document(e.product).setData({
              'count':c.count,
              'total':c.total,
              'profit':c.profit
            },merge: true);
          }).first;
        }
        else{
          reference.document(e.product).delete();
        }
      }).toList();
      _update();
    }catch(e){
      Navigator.pop(context);
      print(e.toString());
    }
  }

  Future _update()async{
    CollectionReference reference=Firestore.instance.collection('Orders');
    try{
      reference.document(widget.data.doc).setData({
        'gst':gst,
        'sub':subtotal,
        'total':total,
      },merge: true);
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>OrderList()));
    }catch(e){
      Navigator.pop(context);
      print(e.toString());
    }
  }

}
