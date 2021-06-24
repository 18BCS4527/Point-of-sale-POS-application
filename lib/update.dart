import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'order_list.dart';


class Update extends StatefulWidget {
  final int sub;
  final double gst;
  final double total;
  final int id;
  final String doc;
  Update(this.sub, this.gst, this.total, this.id,this.doc);

  @override
  _UpdateState createState() => _UpdateState();
}

class _UpdateState extends State<Update> {

  int select;

  List<Category>category=[];
  List<Items>i=[];
  List<Items>items=[];
  List<CartData>cart=[];
  int subtotal=0;
  double gst=0;
  double total=0;

  Future _calculate()async{
    subtotal=0;
    gst=0;
    total=0;
    cart.map((e) {
      setState(() {
        subtotal=subtotal+int.parse(e.total);
      });
    }).toList();
    gst=subtotal*5/100;
    total=double.parse(subtotal.toString())+gst;
    setState(() {

    });
  }

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
    _get();
    _getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(elevation: 0,title: Text('Update Items'),
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
                              _calculate();
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
                                    _calculate();
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
                                    _calculate();
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
      cart.map((e) {
        reference.document().setData({
          'order':widget.id,
          'item':e.name,
          'price':e.price,
          'count':e.count,
          'total':e.total,
          'profit':e.profit,
          'filter':e.filter
        },merge: true);
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
      reference.document(widget.doc).setData({
        'gst':gst+widget.gst,
        'sub':subtotal+widget.sub,
        'total':total+widget.total,
      },merge: true);
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>OrderList()));
    }catch(e){
      Navigator.pop(context);
      print(e.toString());
    }
  }
}
