import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/export.dart';
import 'dio_provider.dart';

// This file is where the layers meet:
//
//   OpenAPI spec ──swagger_parser──▶ PetstoreApi (Retrofit + Freezed models)
//                                         │ uses
//                                        Dio  (dioProvider)
//                                         │ exposed to the UI by
//                                     Riverpod providers below

/// The generated root client, built on top of our shared Dio instance.
final petstoreApiProvider = Provider<PetstoreApi>((ref) {
  return PetstoreApi(ref.watch(dioProvider));
});

/// FutureProvider + family: one cached result per status.
/// `autoDispose` drops the cache when no widget is listening anymore.
final petsByStatusProvider = FutureProvider.autoDispose
    .family<List<Pet>, PetStatus>((ref, status) async {
      final api = ref.watch(petstoreApiProvider);
      final pets = await api.pet.findPetsByStatus(status: status);
      // The public Petstore is shared by everyone, so it contains junk.
      // Keep a readable, de-duplicated list.
      final seen = <int>{};
      return pets
          .where((p) => p.id != null && p.id! > 0 && seen.add(p.id!))
          .take(60)
          .toList();
    });

final petByIdProvider = FutureProvider.autoDispose.family<Pet, int>((ref, id) {
  return ref.watch(petstoreApiProvider).pet.getPetById(petId: id);
});

final inventoryProvider = FutureProvider.autoDispose<Map<String, int>>((ref) {
  return ref.watch(petstoreApiProvider).store.getInventory();
});
