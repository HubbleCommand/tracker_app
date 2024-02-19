import 'package:flutter/material.dart';
import 'package:tracker_app/nav/tracker.dart';

import 'nav/recordings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Do some stuff here with NavigationDestination"),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget> [
          NavigationDestination(icon: Icon(Icons.my_location), label: "Tracking"),
          NavigationDestination(icon: Icon(Icons.query_stats), label: "Recordings"),
        ],
      ),
      body: <Widget> [
        const Card(
          shadowColor: Colors.transparent,
          margin: EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              //TODO this widget doesn't handle navigation well...
              // push to nav or something...
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TrackerWidget(),
              )
            ),
          ),
        ),
        const Card(
          shadowColor: Colors.transparent,
          margin: EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: RecordingsWidget()
            ),
          ),
        ),
        const Card(
          shadowColor: Colors.transparent,
          margin: EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                "Strava, won't do",
              ),
            ),
          ),
        ),
      ][currentPageIndex]
    );
  }
}
