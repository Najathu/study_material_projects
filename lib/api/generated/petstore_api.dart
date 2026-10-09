// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'pet/pet_client.dart';
import 'store/store_client.dart';

/// Petstore (study copy) `v1.0.0`.
///
/// A small slice of https://petstore3.swagger.io used to learn OpenAPI.
class PetstoreApi {
  PetstoreApi(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0.0';

  PetClient? _pet;
  StoreClient? _store;

  PetClient get pet => _pet ??= PetClient(_dio, baseUrl: _baseUrl);

  StoreClient get store => _store ??= StoreClient(_dio, baseUrl: _baseUrl);
}
