import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavigationTab {
  home,
  myBooking,
  message,
  profile,
}

class NavigationState {
  final NavigationTab currentTab;
  final bool isLoading;

  const NavigationState({
    this.currentTab = NavigationTab.home,
    this.isLoading = false,
  });

  NavigationState copyWith({
    NavigationTab? currentTab,
    bool? isLoading,
  }) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return const NavigationState();
  }

  void setTab(NavigationTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(() {
  return NavigationNotifier();
});

final currentTabProvider = Provider<NavigationTab>((ref) {
  return ref.watch(navigationProvider).currentTab;
});
