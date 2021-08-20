import 'package:easy_access_demo/screens/nfc_manager.dart';
import 'package:flutter/material.dart';
import 'package:easy_access_demo/screens/welcome_screen.dart';
import 'package:easy_access_demo/screens/login_screen.dart';
import 'dart:io';
import 'screens/test_scanner.dart';
import 'screens/nfc_manager.dart';

void main() async {
  Socket sock = await Socket.connect('192.168.0.164', 80);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(EasyAccessDemo(sock));
  WidgetsFlutterBinding.ensureInitialized();
}

class EasyAccessDemo extends StatelessWidget {
  Socket socket;
  EasyAccessDemo(Socket s) {
    this.socket = s;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark().copyWith(
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.black54),
          ),
        ),
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id: (context) => WelcomeScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          NfcScanner.id: (context) => NfcScanner(
                channel: socket,
              ),
          TestScanner.id: (context) => TestScanner(
                channel: socket,
              ),
        });
  }
}
