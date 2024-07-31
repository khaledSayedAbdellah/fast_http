library easy_http;
import 'dart:async';
export './core/API/generic_request.dart';
export './core/API/cache_response_manager.dart';
export './core/error/exceptions.dart';
export './core/error/error_message_model.dart';
export './core/error/failures.dart';

class RequestProgressModel{
  final int? bytes, totalBytes;
  RequestProgressModel({this.bytes,this.totalBytes});
}

class EasyHttp {

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
