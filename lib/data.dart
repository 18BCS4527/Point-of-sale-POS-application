

class TableData{
  String table;
  String level;
  String doc;
  bool status;
  TableData(this.table, this.level, this.doc,this.status);
}


class Category{
  String name;
  String image;
  String doc;

  Category(this.name, this.image, this.doc);
}

class Items{
  String name;
  String price;
  String profit;
  String category;
  String type;
  String doc;

  Items(this.name, this.price, this.profit, this.category,this.type, this.doc);
}

class CartData{
  String name;
  String price;
  String profit;
  int count;
  String total;
  String sellerTotal;
  String product;
  String filter;
  CartData( this.name,this.price, this.profit, this.count,this.total,this.sellerTotal,this.product,this.filter);
}


class OrderData{
  int id;
  int time;
  String table;
  String sub;
  String gst;
  String total;
  String payment;
  String guest;
  String doc;

  OrderData(this.id, this.time, this.table,this.sub,this.gst,this.total, this.payment, this.guest,this.doc);
}


class WaiterData{
  String name;
  String mail;
  String number;
  String profile;

  WaiterData(this.name, this.mail, this.number, this.profile);
}