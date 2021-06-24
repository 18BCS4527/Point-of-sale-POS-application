import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data.dart';
import 'orderview.dart';



class OrderList extends StatefulWidget {
  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {

  List<OrderData>order=[];
  List<OrderData>o=[];
  Future _get()async{
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
    CollectionReference reference=Firestore.instance.collection('Orders');
    try{
      QuerySnapshot snapshot= await reference.where('waiter',isEqualTo: user.uid).orderBy('time',descending: true).getDocuments();
      snapshot.documents.map((e) {
        setState(() {
          o.add(OrderData(e.data['id'], e.data['time'], e.data['table'],e.data['sub'].toString(),e.data['gst'].toString(), e.data['total'].toString(), e.data['payment'], e.data['guest'].toString(),e.documentID));
          order=List.from(o);
        });
      }).toList();
    }catch(e){

    }
  }

  Future _getFilter()async{
    CollectionReference reference=Firestore.instance.collection('Orders');
    try{
      QuerySnapshot snapshot= await reference.orderBy('time',descending: true).getDocuments();
      snapshot.documents.map((e) {
        setState(() {
          o.add(OrderData(e.data['id'], e.data['time'], e.data['table'],e.data['sub'].toString(),e.data['gst'].toString(), e.data['total'].toString(), e.data['payment'], e.data['guest'].toString(),e.documentID));
          order=List.from(o);
        });
      }).toList();
    }catch(e){

    }
  }

  onItemChanged(String value){
    setState(() {
      order=o.where((test)=>test.id.toString().toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0,title: Text('Orders'),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(55.0),
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
                    hintText: "Search order no (ex. 001..)",
                  ),
                ),
              ),
            )
        ),),
      body: ListView(
        padding: const EdgeInsets.all(2),
        children: [
          PaginatedDataTable(
            header: Text('Order Details'),
            showCheckboxColumn: false,
            rowsPerPage: order.length==0?1:order.length<10?order.length:10,
            columns: [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Created On')),
              DataColumn(label: Text('Time')),
              DataColumn(label: Text('Table No')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Payment')),
            ],
            source: DataSource(context,order),
          ),
        ],
      ),
    );
  }

}

class DataSource extends DataTableSource {
  DataSource(this.context,this.rows);

  final BuildContext context;
  List<OrderData> rows;
  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= rows.length) return null;
    final row = rows[index];
    return DataRow.byIndex(selected: false,
      index: index,
      onSelectChanged: (value) {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>OrderView(row)));
      },
      cells: [
        DataCell(Text('${row.id}')),
        DataCell(Text('${DateFormat(DateFormat.YEAR_MONTH_DAY, 'en_US').format(DateTime.fromMicrosecondsSinceEpoch(row.time*1000))}')),
        DataCell(Text('${DateFormat.jm().format(DateTime.fromMicrosecondsSinceEpoch(row.time*1000))}')),
        DataCell(Text('${row.table}')),
        DataCell(Text('${row.total}')),
        DataCell(Text('${row.payment}')),
      ],
    );
  }

  @override
  int get rowCount => rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

}
