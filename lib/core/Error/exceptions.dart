import 'error_message_model.dart';

class ServerException implements Exception {
  final RequestErrorModel errorMessageModel;

  ServerException({
    required this.errorMessageModel,
  });
}

class CacheException implements Exception {}
