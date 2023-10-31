import 'dart:async';
import 'package:attendancesystem/login-form.dart';
import 'package:flutter/material.dart';
import 'package:attendancesystem/scanner-page.dart';
import 'package:intl/intl.dart';
import 'package:attendancesystem/time.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentTime = '';
  String currentStandardTime = '';

  late Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      currentStandardTime = Time.convertTimeToStandartTime(currentTime);
    });
  }

  void fetchStatus() async {
    var url =
        Uri.https('192.168.1.87', 'scanner/profile/scanner.controller.php');
    var response = await http.get(url);
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 03, 46, 89),
            title: const Text("Attendance System"),
            centerTitle: true,
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentStandardTime,
                  style: TextStyle(
                    color: Colors.orange[900],
                    fontSize: 50,
                  ),
                ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 100,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => const QRViewExample()));

                            // fetchStatus();
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(20.0))),
                          icon: const Icon(Icons.access_time_filled),
                          label: const Text('SIGN IN'),
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 100,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const QRViewExample()));
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(20.0))),
                          icon: const Icon(Icons.access_time_filled),
                          label: const Text('SIGN OUT'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
              LoginPage.resetScript();
            },
            child: const Icon(Icons.logout),
          ),
        ));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
