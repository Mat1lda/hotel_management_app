import 'package:flutter/material.dart';
import 'app_colors.dart';

class SearchHeader extends StatelessWidget {
  final String hintText;
  final Function(String)? onChanged;
  final bool showFilterIcon;
  final VoidCallback? onFilterPressed;
  final EdgeInsets? margin;
  final TextEditingController? controller;

  const SearchHeader({
    super.key,
    this.hintText = 'Tìm kiếm...',
    this.onChanged,
    this.showFilterIcon = true,
    this.onFilterPressed,
    this.margin,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search input
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: showFilterIcon
                    ? IconButton(
                        onPressed: onFilterPressed,
                        icon: const Icon(
                          Icons.tune,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
