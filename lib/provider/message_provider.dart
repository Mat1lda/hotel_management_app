import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageState {
  final bool initialized;

  const MessageState({
    this.initialized = false,
  });

  MessageState copyWith({
    bool? initialized,
  }) {
    return MessageState(
      initialized: initialized ?? this.initialized,
    );
  }
}

class MessageNotifier extends Notifier<MessageState> {
  @override
  MessageState build() {
    return const MessageState();
  }

  void initialize() {
    state = state.copyWith(initialized: true);
  }
}

final messageProvider = NotifierProvider<MessageNotifier, MessageState>(() {
  return MessageNotifier();
});


