import 'package:chats/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("chats")),
        /* body: Center(
          child: GestureDetector(
        onTap: () {
          AuthMethods().signInWithGoogle(context);
        },
        child: Container(
          child: const Text(
            "Sign In with your Google account",
            style: TextStyle(fontSize: 16),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color.fromARGB(255, 129, 190, 240)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      )), */

        body: Center(
          child: Align(
              alignment: Alignment(0, 0.5),
              child: Material(
                color: Colors.white,
                elevation: 8,
                borderRadius: BorderRadius.circular(28),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: InkWell(
                  splashColor: Colors.black54,
                  onTap: () {
                    AuthMethods().signInWithGoogle(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Ink.image(
                        image: AssetImage('assets/google_icon2.png'),
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      // ignore: prefer_const_constructors
                      SizedBox(
                        width: 6,
                      ),
                      const Text(
                        'Sign In with your Google account',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'EBGaramond'),
                      ),
                      // ignore: prefer_const_constructors
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              )),
        ));
  }
}
