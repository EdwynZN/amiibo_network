import 'package:amiibo_network/feature/collection/application/input/update_collection_input.dart';
import 'package:amiibo_network/feature/collection/domain/model/amiibo_bundle_preference_aggregate.dart';
import 'package:amiibo_network/feature/collection/domain/repository/bundle_repository.dart';
import 'package:amiibo_network/feature/collection/domain/repository/collector_repository.dart';

class const UpdateCollectionUseCase({
  required final CollectorRepository _repository,
  required final BundleRepository _bundleRepo,
}) {
  Future<void> call(UpdateCollectionInput input) async {
    if (input.amiibos.isEmpty && input.bundles.isEmpty) return;

    final bundleIds = input.bundles.map((b) => b.id);
    List<AmiiboBundlePreferenceAggregate> bundles = [];
    if (bundleIds.isNotEmpty) {
      bundles = await _bundleRepo.getByIds(bundleIds);

      if (bundles.length != bundleIds.length) {
        throw StateError('one of the bundles is incorrect');
      }
      final mapBundle = <int, AmiiboBundlePreferenceAggregate>{
        for (final e in bundles) e.id: e,
      };
      for (final bundle in input.bundles) {
        mapBundle.update(
          bundle.id,
          (v) => v
            ..preferences = switch (bundle.attributes) {
              EmptyCollectionAttributes() => null,
              WishedCollectionAttributes() => .wished(),
              OwnedCollectionAttributes(:final boxed, :final opened) => .owned(
                boxed: boxed,
                opened: opened,
              ),
            },
        );
      }
    }

    final collection = await _repository.getByUser();
    if (input.clearAll) collection.clearCollection();

    bundles.forEach(collection.updateBundle);
    input.amiibos.forEach((a) {
      final id = a.id;
      switch (a.attributes) {
        case EmptyCollectionAttributes():
          collection.removeAmiibo(id);
        case WishedCollectionAttributes():
          collection.wishAmiibo(id);
        case final OwnedCollectionAttributes attribute:
          collection.ownAmiibo(
            id,
            .new(boxed: attribute.boxed, opened: attribute.opened),
          );
      }
    });

    await _repository.save(collection);
  }
}
