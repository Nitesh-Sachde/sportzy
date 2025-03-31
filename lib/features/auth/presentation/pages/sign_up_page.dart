import 'package:flutter/material.dart';
import 'package:sportzy/widgets/custom_appbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Sign Up"),
      backgroundColor: Colors.white,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Sign Up Page',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            // Add your sign-up form or other widgets here
          ],
        ),
      ),
    );
  }
}
