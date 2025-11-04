import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final bool initialized;
  final String selectedCategory;

  const HomeState({
    this.initialized = false,
    this.selectedCategory = 'all',
  });

  HomeState copyWith({
    bool? initialized,
    String? selectedCategory,
  }) {
    return HomeState(
      initialized: initialized ?? this.initialized,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState();
  }

  void initialize() {
    state = state.copyWith(initialized: true);
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});


