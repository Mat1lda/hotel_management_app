import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/navigation_provider.dart';
import '../widget/bottom_navigation.dart';
import '../utility/app_colors.dart';
import 'tabs/home_tab.dart';
import 'tabs/my_booking_tab.dart';
import 'tabs/message_tab.dart';
import 'tabs/profile_tab.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: _buildBody(currentTab),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }

  Widget _buildBody(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.home:
        return const HomeTab();
      case NavigationTab.myBooking:
        return const MyBookingTab();
      case NavigationTab.message:
        return const MessageTab();
      case NavigationTab.profile:
        return const ProfileTab();
      default:
        return const HomeTab();
    }
  }
}


