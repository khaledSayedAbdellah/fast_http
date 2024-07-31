library fast_http;
import 'dart:async';
export 'package:fast_http/core/API/generic_request.dart';
export 'package:fast_http/core/API/cache_response_manager.dart';
export 'package:fast_http/core/error/exceptions.dart';
export 'package:fast_http/core/error/error_message_model.dart';
export 'package:fast_http/core/error/failures.dart';

class RequestProgressModel{
  final int? bytes, totalBytes;
  RequestProgressModel({this.bytes,this.totalBytes});
}

class FastHttp {

  static StreamController<RequestProgressModel> requestProgressStream = StreamController<RequestProgressModel>.broadcast();
  static Map<String,String> staticHeaders = {};
  static Function(int)? onGetStatusCode;

  void initialize({required Function(int) onGetResponseStatusCode,Map<String,String>? headers}){
    onGetStatusCode = onGetResponseStatusCode;
   if(headers != null) staticHeaders = headers;
  }

  void setConstHeader({required Map<String,String> headers}){
    staticHeaders = headers;
  }
}
