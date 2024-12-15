import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyPasswordInputinput extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final String hintText;

  const MyPasswordInputinput({
    super.key,
    required this.text,
    required this.controller,
    required this.hintText,
  });

  @override
  State<MyPasswordInputinput> createState() => _MypasswordinputState();
}

class _MypasswordinputState extends State<MyPasswordInputinput> {
  bool _isObscure = true; // To track the obscureText state

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 30),
            Text(
              widget.text,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: TextField(
            controller: widget.controller,
            obscureText: _isObscure, // Use the current obscure state
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: Colors.grey, // Make it italic
                fontSize: 14, // Set a specific font size
                fontFamily: 'Montserrat',
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure; // Toggle the obscure state
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
