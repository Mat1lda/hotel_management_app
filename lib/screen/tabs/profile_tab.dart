import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utility/app_colors.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Hồ sơ'),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Profile Tab - Chưa có nội dung',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
