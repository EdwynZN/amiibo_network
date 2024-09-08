import 'dart:async';

import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final statsProvider = StreamProvider.autoDispose<List<Stat>>((ref) async* {
  final service = ref.watch(serviceProvider.notifier);
  final streamController = StreamController<Filter>();

  void listen() {
    streamController.sink.add(ref.read(filterProvider));
  }

  service.addListener(listen);

  final subscription = ref.listen(
    filterProvider,
    (previous, next) {
      if (next != previous) {
        streamController.sink.add(next);
      }
    },
    fireImmediately: true,
  );

  ref.onDispose(() {
    subscription.close();
    service.removeListener(listen);
    streamController.close();
  });

  yield* streamController.stream.asyncMap((filter) async => <Stat>[
      ...await service.fetchStats(
        categoryAttributes: filter.categoryAttributes,
        searchAttributes: filter.searchAttributes,
        hiddenCategories: filter.hiddenType,
      ),
      ...await service.fetchStats(
        group: true,
        categoryAttributes: filter.categoryAttributes,
        searchAttributes: filter.searchAttributes,
        hiddenCategories: filter.hiddenType,
      ),
    ],
  );
});