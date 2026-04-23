import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/my_button.dart';
import 'package:flutter_chat_app/components/my_textfield.dart';
import 'package:flutter_chat_app/themes/light_mode.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.onTap});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Function()? onTap;

  void login() {
    print("Login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightTheme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.chat_rounded,
                size: 100,
                color: lightTheme.colorScheme.primary,
              ),
              //welcome back, you've been missed!
              const Text(
                "Welcome back, you've been missed!",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 35),

              //email and password text field
              MyTextfield(
                hintText: "Email",
                prefixIcon: Icons.email,
                controller: emailController,
              ),

              MyTextfield(
                hintText: "Password",
                prefixIcon: Icons.lock,
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 25),

              //login button
              MyButton(text: "Login", onTap: login),

              //go to register page
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member?",
                    style: TextStyle(color: lightTheme.colorScheme.primary),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onTap,

                    child: const Text(
                      "Register now",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
