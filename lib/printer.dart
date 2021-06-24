import 'dart:async';
import 'dart:typed_data';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as IMG;
import 'package:intl/intl.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:wifi/wifi.dart';
import 'data.dart';


class Printer extends StatefulWidget {

  final OrderData data;
  final List<CartData>items;
  Printer(this.data, this.items);

  @override
  _PrinterState createState() => _PrinterState();
}

class _PrinterState extends State<Printer> {

  String localIp = '';
  List<String> devices = [];
  int found = -1;
  TextEditingController portController = TextEditingController(text: '9100');

  void discover() async {
    setState(() {
      devices.clear();
      found = -1;
    });
    Timer(Duration(seconds: 1), (){
      showDialog(context: context,builder: (context) {
        return Center(
          child: Card(margin: EdgeInsets.symmetric(horizontal: 25),
            child: Container(height: 100,width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8,),
                  CircularProgressIndicator(strokeWidth: 4,),
                  SizedBox(width: 16,),
                  Text('Scanning Printer ......',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                ],
              ),
            ),
          ),
        );
      }, barrierDismissible: false);
    });
    String ip;
    try {
      ip = await Wifi.ip;
      print('local ip:\t$ip');
    } catch (e) {
      print(e.toString());
      return;
    }
    setState(() {
      localIp = ip;
    });

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    int port = 9100;
    try {
      port = int.parse(portController.text);
    } catch (e) {
      portController.text = port.toString();
    }
    print('subnet:\t$subnet, port:\t$port');

    final stream = NetworkAnalyzer.discover2(subnet, port);

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found device: ${addr.ip}');
        setState(() {
          devices.add(addr.ip);
          found = devices.length;
        });
      }
    })
      ..onDone(() {
        setState(() {
          Navigator.pop(context);
          found = devices.length;
        });
      })
      ..onError((dynamic e) {
        Navigator.pop(context);
        print(e.toString());
      });
  }

  void testPrint(String printerIp, BuildContext ctx) async {
    // TODO Don't forget to choose printer's paper size
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      await printDemoReceipt(printer);
      printer.disconnect();
    }

    final snackBar = SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    Scaffold.of(ctx).showSnackBar(snackBar);
  }

  Future<void> printDemoReceipt(NetworkPrinter printer) async {
    // Print image
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(DateTime.fromMicrosecondsSinceEpoch(widget.data.time*1000));
    final ByteData data = await rootBundle.load('assets/logo.png');
    final Uint8List bytes = data.buffer.asUint8List();
//    final Image image = decodeImage(bytes);
//    printer.image(imgSrc);

    printer.text('DiAtus Enterprise Pvt Ltd.',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    printer.text('Mohali', styles: PosStyles(align: PosAlign.center));
    printer.text('New Town Appartment, PB',
        styles: PosStyles(align: PosAlign.center));
    printer.text('Tel: +91 6300126068',
        styles: PosStyles(align: PosAlign.center));
    printer.text('Web: www.atus.com',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    printer.text('Bill No: ${widget.data.id}',
        styles: PosStyles(align: PosAlign.left), linesAfter: 2);
    printer.text('Date: $timestamp',
        styles: PosStyles(align: PosAlign.left), linesAfter: 2);
    printer.hr();
    printer.row([
      PosColumn(text: 'Item', width: 7),
      PosColumn(text: 'Qty', width: 1),
      PosColumn(
          text: 'Price', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    widget.items.map((e){
      return printer.row([
        PosColumn(text: '${e.name}', width: 7),
        PosColumn(text: '${e.count}', width: 1),
        PosColumn(
            text: '${e.price}', width: 2, styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '${e.total}', width: 2, styles: PosStyles(align: PosAlign.right)),
      ]);
    }).toList();
    printer.hr();
    printer.row([
      PosColumn(
          text: 'Sub Total',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: '\₹ ${widget.data.sub}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    printer.row([
      PosColumn(
          text: 'GST',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: '\₹ ${widget.data.gst}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    printer.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '\₹ ${widget.data.total}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);
    printer.hr(ch: '=', linesAfter: 1);
    printer.feed(2);
    printer.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));
    printer.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);
    printer.feed(1);
    printer.cut();
  }

  @override
  void initState() {
    // TODO: implement initState
    discover();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Bill Printing'),
    actions: [
      IconButton(icon: Icon(Icons.refresh),onPressed: (){
        discover();
      },)
    ],),
      body: ListView(shrinkWrap: true,children: [
        devices!=null&&devices.isNotEmpty?ListView.builder(
          shrinkWrap: true,
          itemCount: devices.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => testPrint(devices[index], context),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.print),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${devices[index]}:${portController.text}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Click to print receipt',
                                style: TextStyle(
                                    color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            );
          },
        ):Container(height: MediaQuery.of(context).size.height,
          child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
          Icon(Icons.print,size: 60,),
          SizedBox(height: 8,),
          Text('No Printer available please try it again!')
        ],),),
      ],),
    );
  }
}
