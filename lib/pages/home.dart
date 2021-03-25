import 'package:flutter/material.dart';
import 'package:pertemuan7/helpers/dbhelper.dart';
import 'package:pertemuan7/models/item.dart';
import 'package:pertemuan7/pages/entryform.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  DbHelper dbHelper = DbHelper();
  int count = 0;
  List<Item> itemList;
  @override
  Widget build(BuildContext context) {
    if (itemList == null) {
      itemList = List<Item>();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Item'),
      ),
      body: Column(children: [
        Expanded(
          child: createListView(),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text("Tambah Item"),
              onPressed: () async {
                var item = await navigateToEntryForm(context, null);
                if (item != null) {
                  //TODO 2 Panggil Fungsi untuk Insert ke DB
                  int result = await dbHelper.insert(item);
                  if (result > 0) {
                    updateListView();
                  }
                }
              },
            ),
          ),
        ),
      ]),
    );
  }

  Future<Item> navigateToEntryForm(BuildContext context, Item item) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return EntryForm(item);
    }));
    return result;
  }

  ListView createListView() {
    TextStyle textStyle = Theme.of(context).textTheme.headline5;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          margin: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.ad_units),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    this.itemList[index].kodeBarang,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey[400]),
                  ),
                ),
                Container(
                  child: Text(
                    this.itemList[index].name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    "Rp " + this.itemList[index].price.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            trailing: GestureDetector(
              child: Icon(Icons.delete),
              onTap: () async {
                //TODO 3 Panggil Fungsi untuk Delete dari DB berdasarkan Item
                deleteItem(itemList[index]);
              },
            ),
            onTap: () async {
              var item =
                  await navigateToEntryForm(context, this.itemList[index]);
              //TODO 4 Panggil Fungsi untuk Edit data
              if (item != null) editItem(item);
            },
          ),
        );
      },
    );
  }

  //delete Item
  void deleteItem(Item object) async {
    int result = await dbHelper.delete(object.id);
    if (result > 0) {
      updateListView();
    }
  }

  //edit data
  void editItem(Item object) async {
    int result = await dbHelper.update(object);
    if (result > 0) {
      updateListView();
    }
  }

  //update List item
  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      //TODO 1 Select data dari DB
      Future<List<Item>> itemListFuture = dbHelper.getItemList();
      itemListFuture.then((itemList) {
        setState(() {
          this.itemList = itemList;
          this.count = itemList.length;
        });
      });
    });
  }
}
