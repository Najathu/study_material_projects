// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/pet.dart';
import '../models/pet_status.dart';

part 'pet_client.g.dart';

@RestApi()
abstract class PetClient {
  factory PetClient(Dio dio, {String? baseUrl}) = _PetClient;

  /// Finds pets by status
  @GET('/pet/findByStatus')
  Future<List<Pet>> findPetsByStatus({
    @Query('status') required PetStatus status,
  });

  /// Find pet by ID
  @GET('/pet/{petId}')
  Future<Pet> getPetById({@Path('petId') required int petId});

  /// Add a new pet to the store
  @POST('/pet')
  Future<Pet> addPet({@Body() required Pet body});
}
