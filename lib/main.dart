//import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show utf8;
//import 'dart:io';
//import 'package:path/path.dart';
//import 'package:async/async.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter File Upload Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Asset> images = <Asset>[];
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      // _error = error;
    });
  }

  //Future uploadmultipleimage(List images) async {
  Future uploadmultipleimage() async {
    var uri = Uri.parse("http://172.20.10.14:8081/photo");
    http.MultipartRequest request = new http.MultipartRequest('POST', uri);
    request.headers[''] = '';
    request.fields['user_id'] = '10';
    request.fields['post_details'] = 'dfsfdsfsd';
    //multipartFile = new http.MultipartFile("imagefile", stream, length, filename: basename(imageFile.path));
    List<http.MultipartFile> newList = new List<http.MultipartFile>();
    for (int i = 0; i < images.length; i++) {
      /*String filePath = await FilePicker.getFilePath(
        type: FileType.image,
      );*/
      ByteData byteData = await images[i].getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      //print("SJT:" + images[i].toString());
      //File imageFile = File(images[i].toString());
      //var stream =
      //    new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));

      //var length = await imageFile.length();
      //var multipartFile = new http.MultipartFile(
      //    "userPhoto", stream, int.parse(stream.length.toString()),
      //    filename: basename(imageFile.path));
      http.MultipartFile multipartFile = new http.MultipartFile.fromBytes(
        "userPhoto",
        imageData,
        // file name
        filename: 'some-file-name.jpg',
        // file type
        contentType: MediaType("image", "jpg"),
      );
      newList.add(multipartFile);
      //request.files.add(await http.MultipartFile.fromPath('picture', images[i].toString()));
    }
    request.files.addAll(newList);
    var response = await request.send();
    if (response.statusCode == 200) {
      print("Image Uploaded");
    } else {
      print("Upload Failed");
    }
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        /*child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),*/

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Center(child: Text('Error: $_error')),
            ElevatedButton(
              child: Text("Pick Images"),
              onPressed: loadAssets,
            ),
            ElevatedButton(
              child: Text("Upload Images"),
              onPressed: uploadmultipleimage,
            ),

            Expanded(
              child: buildGridView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
