import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


void main() {
  runApp(const DemoApplication());
}

class DataValue {
  final DateTime date;
  final double height;

  DataValue({required this.date, required this.height});
}

class Data {
  
  final String tideGauge;
  final List<DataValue> astronomical;
  final List<DataValue> readings;

  Data({required this.tideGauge, required this.astronomical, required this.readings});

  factory Data.fromJson(Map<String, dynamic> json) {
    List<DataValue> astronomical = [];
    List<DataValue> readings = [];

    for (var item in json['astronomica']) {
      astronomical.add(DataValue(date: DateTime.parse(item['fecha']), height: item['altura']));
    }

    for (var item in json['lecturas']) {
      readings.add(DataValue(date: DateTime.parse(item['fecha']), height: item['altura']));
    }

    return Data(
      tideGauge: json['mareografo'],
      astronomical: astronomical,
      readings: readings,
    );
  }
}

class DemoApplication extends StatelessWidget {
  const DemoApplication({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Caca Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Flutter Demo Cocohuec Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  Data? futureData;
  
  Future<http.Response> fetchData() {
    return http.get(Uri.parse('https://www.hidro.gov.ar/api/v1/AlturasHorarias/ValoresGrafico/SFER/202404150857'));
  }

  void _incrementCounter() async {
    final response = await fetchData();
    if (response.statusCode == 200) {
      // If the server returns an OK response, then parse the JSON.
      final data = Data.fromJson(jsonDecode(response.body));
      setState(() {
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below
        // so that the display can reflect the updated values. If we changed
        // _counter without calling setState(), then the build method would not be
        // called again, and so nothing would appear to happen.
        futureData = data;
      });  
    } else {
      // If the server returns an error response, then throw an exception.
      throw Exception('Failed to load data');
    }
    
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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Please push the button many times as you want:',
            ),
            Text(
              futureData?.readings.map((e) => '${DateFormat('yyyy-MM-dd kk:mm').format(e.date)}: ${e.height}m').join('\n') ?? 'No data',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Push it',
        child: const Icon(Icons.push_pin_sharp),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
