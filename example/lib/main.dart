import 'package:flutter/material.dart';
import 'package:flutter_calendar_pager/flutter_calendar_pager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar Pager Demo',
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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Calendar Pager Home Page'),
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
  DateTime selectedTime = DateTime.now();
  ViewType viewType = ViewType.MONTH;

  GlobalKey<CalendarState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              key.currentState.switchViewType();
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text('切换'),
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            child: Calendar(
              key: key,
              viewType: viewType,
              initialDate: selectedTime,
              child: Container(
                margin: EdgeInsets.all(25),
                child: Text('selected date is ${selectedTime.toString()}'),
              ),
              onDateChanged: (dateTime) {
                setState(() {
                  selectedTime = dateTime;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
