import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final bool initialized;

  const ProfileState({
    this.initialized = false,
  });

  ProfileState copyWith({
    bool? initialized,
  }) {
    return ProfileState(
      initialized: initialized ?? this.initialized,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  void initialize() {
    state = state.copyWith(initialized: true);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});


