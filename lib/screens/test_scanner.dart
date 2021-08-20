import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import 'package:majascan/majascan.dart';
import 'package:nfc_manager/nfc_manager.dart';

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

  Future<void> nfcScanner() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

// Start Session
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // Do something with an NfcTag instance.
        print('Tag Data: ');
        print(tag.data);
        setState(() {
          result = tag.data.toString();
        });
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('Dispose is executed!******************');
    widget.channel.write("F\n");
    // widget.channel.close();
    // Stop Nfc Session
    NfcManager.instance.stopSession();

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
    //Implement after testing

    // if (!_supportsNFC) {
    //   return ElevatedButton(
    //     child: const Text("Your device does not support NFC"),
    //     onPressed: null,
    //   );
    // }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Center(child: Text("SCANNER           ")),
      ),
      backgroundColor: Colors.black54,
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
                  child: Text(
                    result,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              //NFC Button
              Container(
                child: FloatingActionButton.extended(
                  icon: Icon(Icons.wifi),
                  backgroundColor: Colors.blueAccent,
                  label: Text("NFC-SCANNER"),
                  onPressed: () async {
                    await nfcScanner();
                    print('RESULTS: --> $result');
                  },
                ),
              ),
              SizedBox(
                height: 80.0,
              ),
              //QR CODE button
              Container(
                child: FloatingActionButton.extended(
                  icon: Icon(
                    Icons.camera_alt_outlined,
                  ),
                  backgroundColor: Colors.blueAccent,
                  label: Text("QR-CODE"),
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
              ),
              SizedBox(
                height: 80.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
