import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<QRViewExample> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? result;
  QRViewController? controller;
  late Map<String, dynamic> decodedFetchResult;
  String fetchResult = '';

  bool _showConfirmation = false;
  bool _showStatus = false;

  void executeFetch(Barcode scanData) async {
    var url =
        Uri.https('192.168.43.65', 'scanner/profile/scanner.controller.php');

    var data = {
      "request": "scan",
      "student_id": scanData.code,
    };

    try {
      var response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        setState(() {
          fetchResult = response.body;
          decodedFetchResult = json.decode(fetchResult);
        });
      }
    } catch (error) {
      print(error);
    }
  }

  void _confirmationDialog(bool value, BuildContext context) {
    if (!value) {
      _showStatus = true;

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Confirmation'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_box,
                    size: Checkbox.width,
                  ),
                  Text('Confirmed!'),
                ],
              ),
            );
          });

      Future.delayed(const Duration(seconds: 2), () {
        _showConfirmation = false;
        _showStatus = false;
        Navigator.pop(context);
      });
    }
  }

  void onQrCodeScanned(Map<String, dynamic> value) {
    if (value.isNotEmpty) {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.noHeader,
          animType: AnimType.topSlide,
          body: Center(
              child: Column(
            children: [
              const CircleAvatar(
                radius: 50.0,
                backgroundImage: NetworkImage(
                    'https://hips.hearstapps.com/hmg-prod/images/justin-bieber-gettyimages-1202421980.jpg?crop=1xw:1.0xh;center,top&resize=640:*'),
              ),
              if (value['result'] != null &&
                  value['student_information'] == null)
                Text(value['result']),
              if (value['student_information'] != null &&
                  value['result'] == null)
                Column(
                  children: [
                    Text(value['student_information']['name']),
                    Text(value['student_information']['course']),
                    Text(value['student_information']['year_level']),
                  ],
                ),
            ],
          )),
          btnCancelOnPress: () async {
            _showConfirmation = false;
            fetchResult = '';
          },
          btnOkOnPress: () async {
            _confirmationDialog(_showStatus, context);
            fetchResult = '';
          }).show();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(' Data: ${result!.code}')
                  : const Text('Scan a code'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back)),
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        executeFetch(scanData);
        setState(() {
          result = scanData;
        });
        if (!_showConfirmation && fetchResult.isNotEmpty) {
          onQrCodeScanned(decodedFetchResult);
          _showConfirmation = true;
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
