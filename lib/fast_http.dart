library fast_http;

import 'dart:async';

class RequestProgressModel {
  final int? bytes, totalBytes;
  RequestProgressModel({this.bytes, this.totalBytes});
}

class FastHttp {
  static StreamController<RequestProgressModel> requestProgressStream = StreamController<RequestProgressModel>.broadcast();
  static Function(int)? onGetStatusCode;
  static String Function(dynamic)? staticFetErrorMessageFromResponse;
  static String staticCheckStatusKey = "status";

  static void initialize({
    String? checkStatusKey,
    required Function(int) onGetResponseStatusCode,
    String Function(dynamic)? getErrorMessageFromResponse,
  }) {
    if(checkStatusKey != null) staticCheckStatusKey = checkStatusKey;
    staticFetErrorMessageFromResponse = getErrorMessageFromResponse;
    onGetStatusCode = onGetResponseStatusCode;
  }
}
