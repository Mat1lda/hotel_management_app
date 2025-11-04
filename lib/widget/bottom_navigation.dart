import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/navigation_provider.dart';
import '../utility/app_colors.dart';

class CustomBottomNavigation extends ConsumerWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: BottomNavigationBar(
              currentIndex: _getCurrentIndex(currentTab),
              onTap: (index) => _onTabTapped(index, ref),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.cardBackground,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24),
                activeIcon: Icon(Icons.home, size: 24),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined, size: 24),
                activeIcon: Icon(Icons.calendar_today, size: 24),
                label: 'My Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline, size: 24),
                activeIcon: Icon(Icons.chat_bubble, size: 24),
                label: 'Message',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 24),
                activeIcon: Icon(Icons.person, size: 24),
                label: 'Profile',
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.home:
        return 0;
      case NavigationTab.myBooking:
        return 1;
      case NavigationTab.message:
        return 2;
      case NavigationTab.profile:
        return 3;
      default:
        return 0;
    }
  }

  void _onTabTapped(int index, WidgetRef ref) {
    final notifier = ref.read(navigationProvider.notifier);

    switch (index) {
      case 0:
        notifier.setTab(NavigationTab.home);
        break;
      case 1:
        notifier.setTab(NavigationTab.myBooking);
        break;
      case 2:
        notifier.setTab(NavigationTab.message);
        break;
      case 3:
        notifier.setTab(NavigationTab.profile);
        break;
    }
  }
}
