import 'package:flutter/material.dart';
import 'package:easy_access_demo/components/rounded_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easy_access_demo/main.dart';
import 'package:majascan/majascan.dart';

class TestScanner extends StatefulWidget {
  static const String id = 'test_scanner';
  final Socket channel;
  TestScanner({this.channel});

  @override
  _TestScannerState createState() => _TestScannerState();
}

class _TestScannerState extends State<TestScanner> {
  String result = 'START SCANNING';
  bool showSpinner = false;

  @override
  void dispose() {
    // TODO: implement dispose
    print('Dispose is executed!******************');
    widget.channel.write("F\n");
    // widget.channel.close();
    super.dispose();
  }

  Future _scanQR() async {
    String qrResult = await MajaScan.startScan(
        title: 'QRCODE SCANNER',
        barColor: Colors.red,
        titleColor: Colors.white,
        qRCornerColor: Colors.blue,
        qRScannerColor: Colors.red,
        flashlightEnable: true,
        scanAreaScale: 0.7

        /// value 0.0 to 1.0
        );
    setState(() {
      result = qrResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Center(child: Text("QR SCANNER           ")),
      ),
      backgroundColor: Colors.white54,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Center(
                  child: (result != null)
                      ? Text('Data: ${result}')
                      : Text('Keep Scanning'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        backgroundColor: Colors.blueAccent,
        label: Text("Scan"),
        onPressed: () async {
          await _scanQR();
          // widget.channel.write("O\n");
          print(result);
          if (result == '011880') {
            widget.channel.write("O\n");
            result = 'START SCANNING';
          }
          print('After the if else');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}