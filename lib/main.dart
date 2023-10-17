import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onroadapp/firebase_options.dart';
import 'package:onroadapp/pages/login_page.dart';
import 'package:onroadapp/pages/splashscreen.dart';
import 'package:onroadapp/services/authservices.dart';

//AIzaSyCM-jWFHoLVng42WWcOxw5Hj6t6ppa65EU
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: StreamBuilder(
        stream: AuthService().firebaseAuth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const SplashScreen();
          }
          return LoginScreen();
        },
      ),
    );
  }
}
