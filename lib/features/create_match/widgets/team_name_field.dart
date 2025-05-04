import 'package:flutter/material.dart';
import 'package:sportzy/core/utils/screen_size.dart';

class TeamNameField extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final String? Function(String?)? validator; // Add validator parameter

  const TeamNameField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.validator, // Add this parameter
  });

  @override
  State<TeamNameField> createState() => _TeamNameFieldState();
}

class _TeamNameFieldState extends State<TeamNameField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      validator: widget.validator, // Use the validator parameter
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.group),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.018,
          horizontal: screenWidth * 0.04,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onChanged: widget.onChanged,
    );
  }
}
