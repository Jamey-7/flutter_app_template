import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

enum AppTextFieldType {
  text,
  email,
  password,
  number,
  phone,
}

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final AppTextFieldType type;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? initialValue;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.type = AppTextFieldType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == AppTextFieldType.password;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.type == AppTextFieldType.password ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      obscureText: widget.type == AppTextFieldType.password && _obscureText,
      keyboardType: _getKeyboardType(),
      textInputAction: widget.textInputAction ?? _getTextInputAction(),
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      inputFormatters: _getInputFormatters(),
      style: context.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        counterText: widget.showCounter ? null : '',
        enabled: widget.enabled,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == AppTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return widget.suffixIcon;
  }

  TextInputType _getKeyboardType() {
    return switch (widget.type) {
      AppTextFieldType.email => TextInputType.emailAddress,
      AppTextFieldType.number => TextInputType.number,
      AppTextFieldType.phone => TextInputType.phone,
      AppTextFieldType.password => TextInputType.visiblePassword,
      AppTextFieldType.text => TextInputType.text,
    };
  }

  TextInputAction _getTextInputAction() {
    if (widget.maxLines != null && widget.maxLines! > 1) {
      return TextInputAction.newline;
    }
    return TextInputAction.next;
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.type == AppTextFieldType.number) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }
}
