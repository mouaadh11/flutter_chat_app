import 'package:flutter/material.dart';

TextField myTextField({
  required String hintText,
  required IconData prefixIcon,
  bool obscureText = false,
}) {
  return TextField(
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      border: const OutlineInputBorder(),
    ),
  );
}
