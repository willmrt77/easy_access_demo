import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import 'package:majascan/majascan.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcTestScreen extends StatefulWidget {
  static const String id = 'nfc_test_screen';
  final Socket channel;
  NfcTestScreen({this.channel});

  @override
  _NfcTestScreenState createState() => _NfcTestScreenState();
}

class _NfcTestScreenState extends State<NfcTestScreen> {
  String result = 'START SCANNING';
  bool showSpinner = false;
  bool scan = true;

  // Function that runs the nfcScanner

  Future<void> nfcScanner() async {
    print("[+] Running the nfcScanner function");

    // Check availability
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      print("[+] inside the if statement");
      while (isAvailable) {
        // Start session and register callback.
        print("[+] inside the while loop");
        NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          // Manipulating tag
          // Obtain an Ndef instance from tag
          Ndef ndef = Ndef.from(tag);
          if (ndef == null) {
            print('Tag is not ndef');
            return;
          } else {
            widget.channel.write('O\n');
          }

// You can get an NdefMessage instance cached at discovery time
          NdefMessage cachedMessage = ndef.cachedMessage;

          // Copied code above this line, below is mine
          print("Tag.data printed below");
          print(tag.data);
          print(cachedMessage);
          setState(() {
            result = tag.data.toString();
          });
        });
      }
    } else {
      setState(() {
        print("[+] Inside the ELSE statement");
        result = 'NO SESSION AVAILABLE';
      });
    }
  }

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('Dispose is executed!******************');
    widget.channel.write("F\n");
    // widget.channel.close();
    super.dispose();
    // Stop session and unregister callback.
    NfcManager.instance.stopSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Center(child: Text("SCANNER         ")),
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
                  heroTag: "btn1",
                  icon: Icon(Icons.wifi),
                  backgroundColor: Colors.blueAccent,
                  label: Text("NFC-SCANNER"),
                  onPressed: () {
                    nfcScanner();
                  },
                ),
              ),
              SizedBox(
                height: 80.0,
              ),
              //QR CODE button

              SizedBox(
                height: 80.0,
              ),
              Container(
                child: FloatingActionButton.extended(
                  heroTag: "btn2",
                  icon: Icon(
                    Icons.camera_alt_outlined,
                  ),
                  backgroundColor: Colors.blueAccent,
                  label: Text("STOP SCANNING!"),
                  onPressed: () {
                    setState(() {
                      scan == false;
                    });
                    Navigator.pop(context);
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
