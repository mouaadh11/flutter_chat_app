import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/components/my_button.dart';
import 'package:flutter_chat_app/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.onTap});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Function()? onTap;

  void login(BuildContext context) async {
    //auth instance
    final auth = AuthService();
    try {
      await auth.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (error) {
      if (!context.mounted) return;
      print("Login failed: $error");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  Icon(
                    Icons.chat_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
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
                    isPassword: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 25),

                  //login button
                  MyButton(text: "Login", onTap: () => login(context)),

                  //go to register page
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member?",
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
        ),
      ),
    );
  }
}
