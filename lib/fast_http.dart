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
  static String Function(dynamic)? staticFetErrorMessageFromResponse;
  static String staticCheckStatusKey = "status";

  static void initialize({
    String? checkStatusKey,
    String? genericDataKey,
    required Function(int) onGetResponseStatusCode,
    String Function(dynamic)? getErrorMessageFromResponse,
  }) {
    if(checkStatusKey != null) staticCheckStatusKey = checkStatusKey;
    staticFetErrorMessageFromResponse = getErrorMessageFromResponse;
    onGetStatusCode = onGetResponseStatusCode;
    if(genericDataKey != null) GenericRequest.init(keyData: genericDataKey);
  }
}
