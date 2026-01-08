import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/navigation_provider.dart';
import '../widget/bottom_navigation.dart';
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
      body: IndexedStack(
        index: _tabIndex(currentTab),
        children: const [
          HomeTab(),
          MyBookingTab(),
          MessageTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }

  int _tabIndex(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.home:
        return 0;
      case NavigationTab.myBooking:
        return 1;
      case NavigationTab.message:
        return 2;
      case NavigationTab.profile:
        return 3;
    }
  }
}


