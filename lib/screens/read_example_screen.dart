import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class ReadExampleScreen extends StatefulWidget {
  @override
  _ReadExampleScreenState createState() => _ReadExampleScreenState();
}

class _ReadExampleScreenState extends State<ReadExampleScreen> {
  StreamSubscription<NDEFMessage> _stream;
  String result = "Testing";

  void _startScanning() {
    setState(() {
      _stream = NFC
          .readNDEF(alertMessage: "Custom message with readNDEF#alertMessage")
          .listen((NDEFMessage message) {
        if (message.isEmpty) {
          print("Read empty NDEF message");
          setState(() {
            result = "Read empty NDEF message";
          });
          return;
        }
        print("Read NDEF message with ${message.records.length} records");
        setState(() {
          result = "Read NDEF message with ${message.records.length} records";
        });
        for (NDEFRecord record in message.records) {
          print(
              "Record '${record.id ?? "[NO ID]"}' with TNF '${record.tnf}', type '${record.type}', payload '${record.payload}' and data '${record.data}' and language code '${record.languageCode}'");
          result =
              "Record '${record.id ?? "[NO ID]"}' with TNF '${record.tnf}', type '${record.type}', payload '${record.payload}' and data '${record.data}' and language code '${record.languageCode}'";
        }
      }, onError: (error) {
        setState(() {
          _stream = null;
          result = error;
        });
        if (error is NFCUserCanceledSessionException) {
          print("user canceled");
          setState(() {
            result = "user canceled";
          });
        } else if (error is NFCSessionTimeoutException) {
          print("session timed out");
          setState(() {
            result = "session timed out";
          });
        } else {
          print("error: $error");
          setState(() {
            result = "error: $error";
          });
        }
      }, onDone: () {
        setState(() {
          _stream = null;
        });
      });
    });
  }

  void _stopScanning() {
    _stream?.cancel();
    setState(() {
      _stream = null;
    });
  }

  void _toggleScan() {
    if (_stream == null) {
      _startScanning();
    } else {
      _stopScanning();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stopScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Read NFC example"),
            ),
            body: Center(
                child: ElevatedButton(
              child: const Text("Toggle scan"),
              onPressed: _toggleScan,
            )),
          ),
        ),
        Expanded(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: Container(
              child: Text(
                result,
                style: TextStyle(
                  fontSize: 40.0,
                ),
              ),
            )),
          ),
        )
      ],
    );
  }
}
