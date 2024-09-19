library fast_http;

import 'dart:async';

class RequestProgressModel {
  final int? bytes, totalBytes;
  RequestProgressModel({this.bytes, this.totalBytes});
}

class FastHttp {
  static StreamController<RequestProgressModel> requestProgressStream =
      StreamController<RequestProgressModel>.broadcast();
  static Map<String, String> staticHeaders = {};
  static Function(int)? onGetStatusCode;

  static void initialize(
      {required Function(int) onGetResponseStatusCode,
      Map<String, String>? headers}) {
    onGetStatusCode = onGetResponseStatusCode;
    if (headers != null) staticHeaders = headers;
  }
}
