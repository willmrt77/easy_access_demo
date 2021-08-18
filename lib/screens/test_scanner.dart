import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_access_demo/components/rounded_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easy_access_demo/main.dart';
import 'package:majascan/majascan.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

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
  bool _supportsNFC = true;
  bool _reading = false;
  StreamSubscription<NDEFMessage> _stream;

  @override
  void initState() {
    super.initState();
    // Check if the device supports NFC reading, Implement after testing//
    NFC.isNDEFSupported.then((bool isSupported) {
      setState(() {
        _supportsNFC = isSupported;
      });
    });
  }

  Future<void> nfcScanner() {
    if (_reading) {
      _stream?.cancel();
      setState(() {
        _reading = false;
      });
    } else {
      setState(() {
        _reading = true;
        // Start reading using NFC.readNDEF()
        _stream = NFC
            .readNDEF(
          once: true,
          // This is to use a virutal reader
          //readerMode: NFCDispatchReaderMode(),
          throwOnUserCancel: false,
        )
            .listen((NDEFMessage message) {
          print("read NDEF message: ${message.payload}");
          if (message.payload != null) {
            widget.channel.write("O\n");
            result = message.payload;
          }
        }, onError: (e) {
          // Check error handling guide below
        });
      });
    }
  }

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
    //Implement after testing

    if (!_supportsNFC) {
      return ElevatedButton(
        child: const Text("You device does not support NFC"),
        onPressed: null,
      );
    }
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
