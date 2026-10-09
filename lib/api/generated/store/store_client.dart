// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'store_client.g.dart';

@RestApi()
abstract class StoreClient {
  factory StoreClient(Dio dio, {String? baseUrl}) = _StoreClient;

  /// Returns pet counts by status
  @GET('/store/inventory')
  Future<Map<String, int>> getInventory();
}
