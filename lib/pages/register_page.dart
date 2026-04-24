import 'package:flutter/material.dart';
import 'package:flutter_chat_app/auth/auth_service.dart';
import 'package:flutter_chat_app/components/my_button.dart';
import 'package:flutter_chat_app/components/my_textfield.dart';
import 'package:flutter_chat_app/themes/light_mode.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, required this.onTap});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final void Function()? onTap;
  void register(BuildContext context) async {
    //auth instance
    final _auth = AuthService();
    if (passwordController.text == confirmPasswordController.text) {
      try {
        await _auth.registerWithEmailAndPassword(
          emailController.text,
          passwordController.text,
        );
      } catch (e) {
        print("Registration failed: $e");
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
      return;
    } else {
      print("Passwords do not match");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightTheme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
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
                  "Let's create an account for you!",
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
                MyTextfield(
                  hintText: "Confirm Password",
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  controller: confirmPasswordController,
                ),
                const SizedBox(height: 25),

                //login button
                MyButton(text: "Register", onTap: () => register(context)),

                //go to register page
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: lightTheme.colorScheme.primary),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onTap,
                      child: const Text(
                        "Login now",
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
      ),
    );
  }
}
