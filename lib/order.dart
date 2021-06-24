import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'data.dart';
import 'home.dart';


class Order extends StatefulWidget {
  final String table;
  final String tabledoc;
  Order(this.table,this.tabledoc);

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {

  int select;

  List<Category>category=[];
  List<Items>i=[];
  List<Items>items=[];
  List<CartData>cart=[];

  Future _getCategory()async{
    CollectionReference reference=Firestore.instance.collection('Category');
    try{
      QuerySnapshot snapshot=await reference.getDocuments();
      snapshot.documents.map((e) {
        setState(() {
          category.add(Category(e.data['name'], e.data['image'], e.documentID));
        });
      }).toList();
    }catch(e){

    }
  }

  Future _get()async{
    CollectionReference reference=Firestore.instance.collection('Items');
    try{
      QuerySnapshot querySnapshot=await reference.getDocuments();
      querySnapshot.documents.map((e){
        setState(() {
          i.add(Items(e.data['name'], e.data['price'], e.data['profit'], e.data['filter'],e.data['type'], e.documentID));
          items=List.from(i);
        });
      }).toList();
    }catch(e){
      print(e.toString());
    }
  }

  onItemChanged(String value){
    setState(() {
      items=i.where((test)=>test.name.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }


  onItemChange(String value){
    setState(() {
      items=i.where((test)=>test.category.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _getCategory();
    _get();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(elevation: 0,title: Text('Choose Items'),
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(64.0),
          child: Container(width: MediaQuery.of(context).size.width,
            height: 60,
            padding: const EdgeInsets.all(8.0),
            child: Container(color: Colors.white,
              padding: EdgeInsets.only(left: 8),
              child: TextField(onChanged: onItemChanged,
                showCursor: true,textAlign: TextAlign.left,
                decoration: InputDecoration(suffixIcon: Icon(Icons.search_rounded),
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF666666),),
                  hintText: "Search items no (ex. Biryani..)",
                ),
              ),
            ),
          )
      ),),
      body: ListView(children: [
        Container(height: 160,width: 140,
          child: ListView(physics: BouncingScrollPhysics(),shrinkWrap: true,scrollDirection: Axis.horizontal,
            children: List.generate(category.length, (index)  => Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: Container(width: 140,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),boxShadow: [
                  BoxShadow(color: select==index?Colors.lightBlue:Colors.grey.shade200,spreadRadius: 2)
                ]),
                child: Stack(children: [
                  Container(height: 160,child: ClipRRect(borderRadius:BorderRadius.circular(8),
                      child: category[index].image!=null?CachedNetworkImage(imageUrl: category[index].image,fit: BoxFit.cover,):Center(child: Icon(Icons.image_not_supported)))),
                  Align(alignment: Alignment.bottomCenter,
                    child: Container(width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2),borderRadius: BorderRadius.only(bottomRight: Radius.circular(8),bottomLeft: Radius.circular(8))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${category[index].name}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                      ),),
                  )
                ],),),
              onTap: (){
                setState(() {
                  select=index;
                });
                onItemChange(category[index].name);
              },
            ),
          )).toList(),),
        ),
        ListView(shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: category.map((e) => items.where((element) => element.category.toLowerCase().contains(e.name.toLowerCase())).toList().isNotEmpty?
            Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${e.name}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                ),
                Container(width: MediaQuery.of(context).size.width,
                  child: ListView(shrinkWrap: true,physics: BouncingScrollPhysics(),children: items.where((element) => element.category.toLowerCase().contains(e.name.toLowerCase())).map((e) => Column(children: [
                    ListTile(leading:  e.type=='Veg'?Image.asset('assets/veg.png',width: 20,height: 20,):Image.asset('assets/nonveg.png',width: 20,height: 20,),
                        title: Text(e.name,style: TextStyle(fontWeight: FontWeight.w500),),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('₹${e.price}',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black),),
                            )
                          ],
                        ),
                        trailing: !cart.where((element) => element.product.contains(e.doc)).isNotEmpty?Container(constraints: BoxConstraints(maxWidth: 60.0, minHeight: 20.0,maxHeight: 30.0),
                          child: RaisedButton(elevation: 1,
                            onPressed: ()async{
                              setState(() {
                                cart.add(CartData(e.name, e.price, e.profit, 1, e.price, e.profit, e.doc,e.category));
                              });
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                            padding: EdgeInsets.all(0.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Color(0xff5BAAFA),Colors.lightBlueAccent],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0)
                              ),
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 60.0, minHeight: 20.0,maxHeight: 30.0),
                                alignment: Alignment.center,
                                child: Text(
                                  "Add",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ):cart.where((element) => element.product.contains(e.doc)).map((c) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container( constraints: BoxConstraints(maxWidth: 80.0, minHeight: 20.0,maxHeight: 30.0),
                            child: Row(children: [
                              Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                                child: IconButton(padding: EdgeInsets.all(0),icon: Icon(Icons.remove),
                                  onPressed: (){
                                    if(c.count>1){
                                      setState(() {
                                        cart.insert(cart.indexOf(c).toInt(),CartData(e.name, e.price, e.profit, c.count-1, ((c.count-1)*int.parse(e.price)).toString(), ((c.count-1)*int.parse(e.profit)).toString(), e.doc,e.category));
                                        cart.removeAt(cart.indexOf(c).toInt());
                                      });
                                    }
                                    else{
                                      setState(() {
                                        cart.removeAt(cart.indexOf(c).toInt());
                                      });
                                    }
                                  },),
                              ),),
                              Expanded(child: Container(height: MediaQuery.of(context).size.height,alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Colors.blueAccent,border: Border.all(color: Colors.grey.shade300)),
                                  child: Text('${c.count}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),),
                              Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                                child: IconButton(padding: EdgeInsets.all(0),
                                  icon: Icon(Icons.add),
                                  onPressed: (){
                                    setState(() {
                                      cart.insert(cart.indexOf(c).toInt(),CartData(e.name, e.price, e.profit, c.count+1, ((c.count+1)*int.parse(e.price)).toString(), ((c.count+1)*int.parse(e.profit)).toString(), e.doc,e.category));
                                      cart.removeAt(cart.indexOf(c).toInt());
                                    });
                                  },),
                              ),)
                            ],),
                          ),
                        ),).first),
                    Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16),
                      child: Divider(),
                    ),
                  ],)).toList(),),
                ),
              ],
            ):Container(),).toList()),
      ],),
      bottomNavigationBar:  Padding(
        padding: const EdgeInsets.only(top: 16,bottom: 16),
        child: Container(width: MediaQuery.of(context).size.width*0.6,
          margin: EdgeInsets.only(left: 16,right: 16),
          child: RaisedButton(elevation: 1,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>CheckOut(cart, widget.table, widget.tabledoc)));
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
}


class CheckOut extends StatefulWidget {
  final List<CartData>cart;
  final String table;
  final String tabledoc;

  CheckOut(this.cart, this.table,this.tabledoc);

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {

  int subtotal=0;
  double gst=0;
  double total=0;
  String payment='Cash';
  int i=0;
  Future _calculate()async{
    widget.cart.map((e) {
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
    _calculate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(elevation: 0,title: Text('CheckOut'),),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16,top: 16),
          child: Text("No.of Guest's",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        ),
        GridView.count(crossAxisCount: 6,shrinkWrap: true,
        padding: EdgeInsets.only(left: 16,right: 16,top: 8,bottom: 8),
        children: List.generate(12, (index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: Container(width: 40,height:20,alignment: Alignment.center,child: Text('${index+1}'),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),color: index==i?Colors.green:Colors.grey.shade400),),
            onTap: (){
              setState(() {
                i=index;
              });
            },
          ),
        )),),
        Padding(
          padding: const EdgeInsets.only(left: 16,top: 16),
          child: Text('Payment Method',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        ),
        ListTile(leading: CachedNetworkImage(imageUrl: 'https://firebasestorage.googleapis.com/v0/b/diatus-pos.appspot.com/o/paying.png?alt=media&token=3485f90f-78ec-42c1-b99b-6a2c37fc71d7',width: 30,height: 30,),
          title: Text('Cash Payment',style: TextStyle(fontWeight: FontWeight.w500)
          ),
          onTap: (){
            setState(() {
              payment='Cash';
            });
          },
          trailing: Radio(groupValue: payment, value: 'Cash', onChanged: (value) {
            payment=value;
            setState(() {

            });
          },),
        ),
        ListTile(leading: Icon(Icons.credit_card,color: Colors.blue,size: 25,),
          title: Text('Online/Card Payment',style: TextStyle(fontWeight: FontWeight.w500)
          ),
          onTap: (){
            setState(() {
              payment='Online';
            });
          },
          trailing: Radio(groupValue: payment, value: 'Online', onChanged: (value) {
            payment=value;
            setState(() {

            });
          },),
        ),
        Divider(height: 3,),
        Padding(
          padding: const EdgeInsets.only(left: 16,top: 16),
          child: Text('Table No: #${widget.table}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        ),
        DataTable(columnSpacing: 8,columns: [
          DataColumn(label: Text("Name",style: TextStyle(fontSize: 16),)),
          DataColumn(label: Container(child: Text("Quantity",style: TextStyle(fontSize: 16),))),
          DataColumn(label: Container(child: Text("Price",style: TextStyle(fontSize: 16),))),
          DataColumn(label: Container(child: Text("Total",style: TextStyle(fontSize: 16),))),
        ],
            rows: widget.cart.map((list)=>DataRow(cells: [
              DataCell(Container(width: 100,child: Text('${list.name}',maxLines: 2,overflow: TextOverflow.ellipsis,))),
              DataCell(Container(width: 40,child: Text(list.count.toString()))),
              DataCell(Container(width: 40,child: Text('${list.price}'))),
              DataCell(Container(width: 40,child: Text('${list.total}')))
            ])).toList()
        ),
        Divider(),
        Container(width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(right: 16),
          child:  Text('GST 5% : ₹$gst',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade600),textAlign: TextAlign.right,),
        ),
        Container(width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(right: 16,top: 16),
          child:  Text('Sub Total : ₹$subtotal',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade600),textAlign: TextAlign.right,),
        ),
        Container(width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(right: 16,top: 16),
          child:  Text('Total Price : ₹$total',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),textAlign: TextAlign.right,),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16,bottom: 8),
          child: Container(width: MediaQuery.of(context).size.width*0.6,
            margin: EdgeInsets.only(left: 16,right: 16),
            child: RaisedButton(elevation: 1,
              onPressed: ()async{
              Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(16.0),
              color: Colors.red,
              child: Text(
                "Update Bill",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16,bottom: 8),
          child: Container(width: MediaQuery.of(context).size.width*0.6,
            margin: EdgeInsets.only(left: 16,right: 16),
            child: RaisedButton(elevation: 1,
              onPressed: ()async{
                _upload();
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(16.0),
              color: Colors.green,
              child: Text(
                "Save",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
          ),
        ),
      ],),
    );
  }


  Future _upload()async{
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
    CollectionReference reference=Firestore.instance.collection('Orders');
    showDialog(context: context,builder: (context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }, barrierDismissible: false);
    int value=DateTime.now().millisecondsSinceEpoch;
    try{
      reference.document().setData({
        'waiter':user.uid,
        'table':widget.table,
        'sub':subtotal,
        'guest':i+1,
        'gst':gst,
        'total':total,
        'id':value,
        'day':DateTime.now().day,
        'month':DateTime.now().month,
        'year':DateTime.now().year,
        'time':DateTime.now().millisecondsSinceEpoch,
        'payment':payment,
      },merge: true);
      _table(value);
    }catch(e){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Something went wrong! Please try Again');
    }
  }

  Future _table(int id)async{
    CollectionReference reference=Firestore.instance.collection('Tables');
    try{
      reference.document(widget.tabledoc).setData({'status':false},merge: true);
      _items(id);
    }catch(e){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Something went wrong! Please try Again');
    }
  }

  Future _items(int id)async{
    CollectionReference reference=Firestore.instance.collection('OrderItems');
    try{
      widget.cart.map((e){
        reference.document().setData({
          'order':id,
          'item':e.name,
          'price':e.price,
          'count':e.count,
          'total':e.total,
          'profit':e.profit,
          'filter':e.filter
        },merge: true);
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>Home()));
      }).toList();
    }catch(e){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Something went wrong! Please try Again');
    }
  }
}
