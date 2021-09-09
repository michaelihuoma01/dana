import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String label, hintText, suffixText;
  final IconData iconData, prefixIconData;
  final bool obscureText, enabled;
  final String initialValue;
  final TextEditingController controller;
  final Function onChanged, onSaved, onIconTap, onFieldSubmitted;
  final String Function(String) validator;
  final TextInputType type;
  final Color borderColor;
  final Color fillColor;
  final FocusNode focusNode;
  final int maxLines;
  final TextStyle hintStyle;
  final Widget suffix;

  const TextFormFieldWidget({
    Key key,
    this.label,
    this.suffix,
    this.hintText,
    this.iconData,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.onFieldSubmitted,
    this.onSaved,
    this.obscureText = false,
    this.enabled = true,
    this.suffixText,
    this.validator,
    this.initialValue,
    this.type,
    this.onIconTap,
    this.maxLines = 1,
    this.prefixIconData,
    this.hintStyle,
    this.fillColor,
    this.borderColor,
  }) : super(key: key);

  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    );
    return TextFormField(
      keyboardType: type,
      decoration: iconData == null
          ? InputDecoration(
              fillColor: fillColor,
              filled: true,
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
              ),
              disabledBorder: inputBorder,
              errorBorder: inputBorder.copyWith(
                borderSide: BorderSide(
                  color: Theme.of(context).errorColor,
                  width: 1,
                ),
              ),
              errorStyle: TextStyle(color: Theme.of(context).errorColor),
              labelText: label,
              hintText: hintText ?? '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            )
          : InputDecoration(
              fillColor: fillColor,
              filled: true,
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
              ),
              labelText: label,
              hintText: hintText ?? '',
              hintStyle: hintStyle,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Icon(prefixIconData, color: lightColor, size: 30),
              ),
              suffixText: suffixText ?? '',
            ),
      obscureText: obscureText,
      enabled: enabled,
      onSaved: onSaved,
      initialValue: initialValue,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      controller: controller,
      validator: validator,
      focusNode: focusNode,
      maxLines: maxLines,
    );
  }
}
