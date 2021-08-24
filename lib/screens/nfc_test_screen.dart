import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import 'package:majascan/majascan.dart';
//import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class NfcTestScreen extends StatefulWidget {
  static const String id = 'nfc_test_screen';
  final Socket channel;
  NfcTestScreen({this.channel});

  @override
  _NfcTestScreenState createState() => _NfcTestScreenState();
}

class _NfcTestScreenState extends State<NfcTestScreen> {
  bool _supportsNFC = false;
  bool _reading = false;
  StreamSubscription<NDEFMessage> _stream;

  // String result = 'START SCANNING';
  // bool showSpinner = false;
  // bool scan = true;

  // Function that runs the nfcScanner

//   Future<void> nfcScanner() async {
//     print("[+] Running the nfcScanner function");
//
//     // Check availability
//     bool isAvailable = await NfcManager.instance.isAvailable();
//     if (isAvailable) {
//       print("[+] inside the if statement");
//       setState(() {
//         result = 'Tag Data: WORKING!!!!';
//       });
//       print('Tag Data: WORKING!!!!');
//       widget.channel.write('O\n');
//       NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
//         // Manipulating tag
//         // Obtain an Ndef instance from tag
//         Ndef ndef = Ndef.from(tag);
//         // if (ndef == null) {
//         //   print('Tag is not ndef');
//         //   return;
//         // }
// // You can get an NdefMessage instance cached at discovery time
//         NdefMessage cachedMessage = ndef.cachedMessage;
//
//         // Copied code above this line, below is mine
//         print("Tag.data printed below");
//         print(tag.data);
//         print(cachedMessage);
//         setState(() {
//           result = tag.data.toString();
//         });
//       });
//     } else {
//       setState(() {
//         print("[+] Inside the ELSE statement");
//         result = 'NO SESSION AVAILABLE';
//       });
//     }
//   }
  //Future<void> nfcScanner() async {
  //   NDEFMessage message = await NFC.readNDEF(once: true).first;
  //   print("payload: ${message.payload}");
  //   if (message.payload != null) {
  //     widget.channel.write('O\n');
  //     setState(() {
  //       result = message.payload;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // Check if the device supports NFC reading
    NFC.isNDEFSupported.then((bool isSupported) {
      setState(() {
        _supportsNFC = isSupported;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('Dispose is executed!******************');
    widget.channel.write("F\n");
    // widget.channel.close();
    super.dispose();
    // Stop session and unregister callback.
    // NfcManager.instance.stopSession();   ---->
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsNFC) {
      return RaisedButton(
        child: const Text("You device does not support NFC"),
        onPressed: null,
      );
    }

    return RaisedButton(
        child: Text(_reading ? "Stop reading" : "Start reading"),
        onPressed: () {
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
                throwOnUserCancel: false,
              )
                  .listen((NDEFMessage message) {
                print("read NDEF message: ${message.payload}");
              }, onError: (e) {
                // Check error handling guide below
              });
            });
          }
        });
  }
}
//   return Scaffold(
//     appBar: AppBar(
//       backgroundColor: Colors.blueAccent,
//       title: Center(child: Text("SCANNER         ")),
//     ),
//     backgroundColor: Colors.black54,
//     body: ModalProgressHUD(
//       inAsyncCall: showSpinner,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Expanded(
//               flex: 1,
//               child: Center(
//                 child: Text(
//                   result,
//                   style: TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             //NFC Button
//             Container(
//               child: FloatingActionButton.extended(
//                 heroTag: "btn1",
//                 icon: Icon(Icons.wifi),
//                 backgroundColor: Colors.blueAccent,
//                 label: Text("NFC-SCANNER"),
//                 onPressed: () {
//                   nfcScanner();
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 80.0,
//             ),
//             //QR CODE button
//
//             SizedBox(
//               height: 80.0,
//             ),
//             Container(
//               child: FloatingActionButton.extended(
//                 heroTag: "btn2",
//                 icon: Icon(
//                   Icons.camera_alt_outlined,
//                 ),
//                 backgroundColor: Colors.blueAccent,
//                 label: Text("STOP SCANNING!"),
//                 onPressed: () {
//                   setState(() {
//                     scan == false;
//                   });
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 80.0,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
