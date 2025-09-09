library fast_http;

import 'dart:async';
import 'core/API/generic_request.dart';
export './core/API/header_manager.dart';
export './core/Error/error_message_model.dart';
export './core/Error/exceptions.dart';
export './core/Error/failures.dart';

class FastHttp {
  static StreamController<(int?, int?)> requestProgressStream = StreamController<(int?, int?)>.broadcast();
  static Function(int)? onGetStatusCode;
  static String Function(dynamic)? staticGetErrorMessageFromResponse;
  static bool Function(dynamic)? staticCheckResponseIsSuccess;

  static void initialize({
    String? checkStatusKey,
    String? genericDataKey,
    required bool Function(dynamic)? checkResponseIsSuccess,
    required Function(int) onGetResponseStatusCode,
    String Function(dynamic)? getErrorMessageFromResponse,
  }) {
    staticCheckResponseIsSuccess = checkResponseIsSuccess;
    staticGetErrorMessageFromResponse = getErrorMessageFromResponse;
    onGetStatusCode = onGetResponseStatusCode;
    if(genericDataKey != null) GenericRequest.init(keyData: genericDataKey);
  }
}
