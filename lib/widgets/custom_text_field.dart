import 'package:flutter/material.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final bool isEnabled;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon; // Added parameter
  final bool obscureText; // Added parameter
  final int? maxLines; // Added parameter
  final Function(String)? onChanged; // Added parameter for password strength

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.isPassword = false,
    this.isEnabled = true,
    this.validator,
    this.prefixIcon,
    this.suffixIcon, // New parameter
    this.obscureText = false, // New parameter
    this.maxLines = 1, // New parameter
    this.onChanged, // New parameter
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Use either the explicit obscureText parameter or fall back to isPassword behavior
    _obscureText = widget.obscureText || widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenSize.screenWidth(context);
    double screenHeight = ScreenSize.screenHeight(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenWidth * 0.02),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          // Use either the explicit parameter or the internal state
          obscureText: widget.isPassword ? _obscureText : widget.obscureText,
          enabled: widget.isEnabled,
          validator: widget.validator,
          maxLines:
              widget.isPassword
                  ? 1
                  : widget.maxLines, // Passwords always single line
          onChanged: widget.onChanged, // Add onChanged handler
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppColors.grey,
              fontSize: screenWidth * 0.04,
            ),
            suffixIconColor: AppColors.textSecondary,
            prefixIcon:
                widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, color: AppColors.grey)
                    : null,
            suffixIcon:
                // Use the provided suffixIcon if available
                widget.suffixIcon ??
                (widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                    : null),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: AppColors.grey,
                width: screenWidth * 0.002,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: AppColors.lightBlue,
                width: screenWidth * 0.004,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.01,
              horizontal: screenWidth * 0.05,
            ),
          ),
        ),
      ],
    );
  }
}
