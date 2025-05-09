import 'package:flutter/material.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonVisible;
  final bool showDelete;
  final bool showShare;
  final VoidCallback? onBack;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final List<Widget>? actions; // Add this line

  const CustomAppBar({
    required this.title,
    required this.isBackButtonVisible,
    this.showDelete = false,
    this.showShare = false,
    this.onBack,
    this.onDelete, // Add this line
    this.onShare,
    this.actions, // Add this line
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = ScreenSize.screenWidth(context) * 0.06;

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading:
          isBackButtonVisible
              ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.background,
                  size: iconSize,
                ),
                onPressed: onBack ?? () => Navigator.pop(context),
              )
              : null,
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.background,
          fontSize: ScreenSize.screenWidth(context) * 0.05,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions:
          actions ??
          [
            if (showDelete)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            if (showShare)
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: AppColors.background,
                  size: iconSize,
                ),
                onPressed: onShare,
              ),
          ], // Add this line to use the actions parameter
    );
  }

  @override
  Size get preferredSize {
    double screenHeight =
        WidgetsBinding
            .instance
            .platformDispatcher
            .views
            .first
            .physicalSize
            .height /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return Size.fromHeight(screenHeight * 0.08);
  }
}
