import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class ProfileState {
  final bool initialized;
  final bool isRefreshing;
  final String? errorMessage;

  const ProfileState({
    this.initialized = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    bool? initialized,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return ProfileState(
      initialized: initialized ?? this.initialized,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> initialize() async {
    if (state.initialized) return;
    state = state.copyWith(initialized: true);
    await refresh();
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true, errorMessage: null);

    final message = await ref.read(authProvider.notifier).refreshMe();
    state = state.copyWith(
      isRefreshing: false,
      errorMessage: message,
    );
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

