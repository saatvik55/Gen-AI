import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'topic_model.dart';
import 'topic_service.dart';

final topicServiceProvider = Provider<TopicService>((ref) {
  return TopicService();
});

final topicListProvider =
    StateNotifierProvider<TopicNotifier, AsyncValue<List<Topic>>>(
  (ref) => TopicNotifier(ref),
);

class TopicNotifier extends StateNotifier<AsyncValue<List<Topic>>> {
  TopicNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchTopics();
  }

  final Ref _ref;

  Future<void> fetchTopics() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(topicServiceProvider);
      final topics = await service.fetchTopics();
      state = AsyncValue.data(topics);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTopic(String title, {String? notes}) async {
    final current = state.value ?? [];
    try {
      final service = _ref.read(topicServiceProvider);
      final newTopic = await service.addTopic(title: title, notes: notes);
      state = AsyncValue.data([...current, newTopic]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

