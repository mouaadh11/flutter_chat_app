import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/my_textfield.dart';
import 'package:flutter_chat_app/themes/light_mode.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightTheme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.chat_bubble,
              size: 100,
              color: lightTheme.colorScheme.inversePrimary,
            ),  

            //welcome back, you've been missed!
            const Text(
              "Welcome back, you've been missed!",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            //email and password text field
                myTextField(hintText: "Email", prefixIcon: Icons.email),

                myTextField(hintText: "Password", prefixIcon: Icons.lock, obscureText: true),
            //login button
            ElevatedButton(
              onPressed: () {
                //go to home page
              },
              child: const Text("Login"),
            ),
            //go to register page
          ],
        ),
      ),
    );
  }
}
