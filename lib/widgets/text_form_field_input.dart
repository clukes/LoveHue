import 'package:flutter/material.dart';

class TextFormFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isObscured;
  final String hintText;
  final TextInputType textInputType;
  final FormFieldValidator? validator;

  const TextFormFieldInput({
    Key? key,
    required this.textEditingController,
    this.isObscured = false,
    required this.hintText,
    required this.textInputType,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText: isObscured,
      validator: validator,
    );
  }
}
