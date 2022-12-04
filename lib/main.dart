import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'DatabaseHelper.dart';
import 'package:firebase_admob/firebase_admob.dart';

const String testDevice = 'Mobile_id';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TO_DO Application",
      home: todo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class todo extends StatefulWidget {
  @override
  _todoState createState() => _todoState();
}

class Todo {
  int id;
  String task;
  bool boolean;

  Todo({this.id, this.task, this.boolean});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'boolean': boolean,
    };
  }
}

class _todoState extends State<todo> {
  List<Todo> tasklist = new List();
  var id_data;
  List<String> adunitId = [
    'ca-app-pub-2705625178788280/2815459662',
    'ca-app-pub-2705625178788280/8820295501',
    'ca-app-pub-2705625178788280/8084076130',
    'ca-app-pub-2705625178788280/4881050492',
    'ca-app-pub-2705625178788280/4144831124',
    'ca-app-pub-2705625178788280/2254887153',
    'ca-app-pub-2705625178788280/9205586110',
    'ca-app-pub-2705625178788280/7892504442',
    'ca-app-pub-2705625178788280/6579422776',
    'ca-app-pub-2705625178788280/8628723815',
  ];

  // String bannerid = "ca-app-pub-2705625178788280/2820502558";
  // BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  InterstitialAd createInterstitialAd(int id) {
    return InterstitialAd(
        adUnitId: adunitId[id],
        listener: (MobileAdEvent event) {
          print("InterstitialAd $event");
        });
  }

  // BannerAd createBannerAd() {
  //   return BannerAd(
  //       adUnitId: BannerAd.testAdUnitId,
  //       size: AdSize.banner,
  //       listener: (MobileAdEvent event) {
  //         print("BannerAd $event");
  //       });
  // }

  @override
  void dispose() {
    _interstitialAd.dispose();

    // _bannerAd.dispose();

    super.dispose();
  }

  @override
  void initState() {
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-2705625178788280~8013119488');
    // _bannerAd = createBannerAd()
    //   ..load()
    //   ..show();
    super.initState();

    DataBaseHelper.instance.viewquery().then((value) {
      setState(() {
        value.forEach((element) {
          if (element['isFinish'] == 1) {
            tasklist.add(Todo(
              id: element['col_id'],
              task: element['list'],
              boolean: true,
            ));
          } else {
            tasklist.add(Todo(
              id: element['col_id'],
              task: element['list'],
              boolean: false,
            ));
          }
        });
      });
    });
    setState(() {
      id_data = tasklist.length;
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    TextEditingController _textFieldController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Add Todos....',
              style: TextStyle(color: Colors.pink.shade200),
            ),
            content: TextField(
              onChanged: (value) {},
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter the items..."),
            ),
            actions: [
              new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 4.0, right: 20.0),
                    child: CupertinoButton(
                      color: Colors.pink.shade200,
                      child: Text('Cancel'),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      padding: EdgeInsets.all(10),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 5.0, left: 30.0),
                    child: CupertinoButton(
                        color: Colors.pink.shade200,
                        child: Text('Add Items'),
                        onPressed: () async {
                          var text = _textFieldController.text;
                          int id = await getid(text);

                          setState(() {
                            tasklist.insert(
                                0, Todo(id: id, task: text, boolean: true));
                          });
                          Navigator.pop(
                            context,
                          );
                          loadad();
                        },
                        padding: EdgeInsets.all(10)),
                  ),
                ],
              )
            ],
          );
        });
  }

  loadad() async {
    var i;

    for (i = 0; i < 100; i++) {
      int inte = Random().nextInt(9);
      await Future.delayed(const Duration(milliseconds: 5000), () {
        createInterstitialAd(0)
          ..load()
          ..show();
      });
      print(inte.toString() + "=" + i.toString());
    }
  }

  getid(String text) async {
    var db =
        await DataBaseHelper.instance.insert({DataBaseHelper.coloum: text});

    return db.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.pink.shade100,
        title: Text('TO-DO Application'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              createInterstitialAd(0)
                ..load()
                ..show();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Image(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
            image: AssetImage('assets/bg.png'),
          ),
          ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.black,
                height: 1.0,
              );
            },
            itemCount: tasklist.length,
            itemBuilder: (context, index) {
              return buildListTile(index);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade600,
        child: Icon(
          Icons.add,
        ),
        elevation: 15.0,
        onPressed: () {
          _displayTextInputDialog(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // changeStyle(var index) {
  //   setState(() {
  //     tasklist[index].boolean = false;
  //   });
  // }

  bool styleOBJ = true;

  ListTile buildListTile(var index) {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.all(10),
        child: buildText(index),
      ),

      // leading: Text(tasklist[index].id.toString()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            child: Text(
              'Done',
              style: TextStyle(color: Colors.red.shade600),
            ),
            // padding: EdgeInsets.only(left: 30, right: 30),
            onPressed: () {
              changeStyle(index);
            },
          ),
          IconButton(
              color: Colors.red.shade600,
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteTask(tasklist[index].id);
              }),
        ],
      ),
    );
  }

  Text buildText(var index) {
    return Text(
      tasklist[index].task,
      style: tasklist[index].boolean
          ? TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
              fontSize: 20,
              color: Colors.teal[900])
          : TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.lineThrough,
              fontSize: 20,
              color: Colors.teal[900]),
    );
  }

  changeStyle(var index) async {
    await DataBaseHelper.instance.update({'isFinish': '0'}, index + 1);

    setState(() {
      tasklist[index].boolean = false;
    });
  }

  void _deleteTask(int id) async {
    await DataBaseHelper.instance.delete(id);
    setState(() {
      tasklist.removeWhere((element) => element.id == id);
    });
  }
}
