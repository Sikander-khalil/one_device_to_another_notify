

import 'package:flutter/material.dart';


import '../services/gs.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleService googleService = GoogleService();
  // bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // isLoading = true;
            final user = await googleService.signInWithGoogle(context);
            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => DashBoardScreen(),
                ),
              );
            }
            // setState(() {
            //   isLoading = false;
            // });
          },
          child:  Text("Sign In with Google",
              style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }
}
