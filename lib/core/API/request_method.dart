import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../easy_http.dart';
export 'package:dartz/dartz.dart';


class RequestApi {

  final Uri uri;
  final Map<String, String> body;
  final Map<String, dynamic> bodyJson;
  final List<http.MultipartFile> files;
  final Map<String, String>? headers;
  final String method;
  final bool enableCache;

  RequestApi._({required this.uri, required this.body, required this.bodyJson, required this.files, this.headers, required this.method,required this.enableCache});

  RequestApi copyWith({Uri? uri, Map<String, String>? body, Map<String, dynamic>? bodyJson,
    List<http.MultipartFile>? files, Map<String, String>? headers, String? method,bool? enableCache}){
    return RequestApi._(
      files: files ?? this.files,
      body: body ?? this.body,
      bodyJson: bodyJson ?? this.bodyJson,
      uri: uri ?? this.uri,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      enableCache: enableCache ?? this.enableCache
    );
  }

  RequestApi.post({
    required String url,
    required this.body,
    this.files = const [],
    this.headers,
    this.enableCache = false,
  })  : method = "POST",
        uri = Uri.parse(url),
        bodyJson = {};
  RequestApi.postJson({
    required String url,
    required this.bodyJson,
    this.headers,
    this.enableCache = false,
  })  : method = "POST",
        uri = Uri.parse(url),
        files = [],
        body = {};

  RequestApi.postUri({
    required this.uri,
    this.bodyJson = const {},
    this.body = const {},
    this.files = const [],
    this.headers,
    this.enableCache = false,
  })  : method = "POST" ;

  RequestApi.put({
    required String url,
    required this.body,
    this.files = const [],
    this.headers,
  })  : method = "PUT",
        uri = Uri.parse(url),
        bodyJson = {},
        enableCache = false;
  RequestApi.putJson({
    required String url,
    required this.bodyJson,
    this.headers,
  })  : method = "PUT",
        uri = Uri.parse(url),
        files = [],
        body = {},
        enableCache = false;

  RequestApi.get({
    required String url,
    this.headers,
    this.enableCache = false,
  })  : method = "GET",
        body = {},
        files = [],
        uri = Uri.parse(url),
        bodyJson = {};
  RequestApi.getUri({
    required this.uri,
    this.headers,
    this.enableCache = false,
  })  : method = "GET",
        body = {},
        files = [],
        bodyJson = {};

  RequestApi.delete({
    required String url,
    this.headers,
  })  : method = "DELETE",
        body = {},
        files = [],
        uri = Uri.parse(url),
        bodyJson = {},
        enableCache = false;
  RequestApi.deleteUri({
    required this.uri,
    this.headers,
  })  : method = "DELETE",
        body = {},
        files = [],
        bodyJson = {},
        enableCache = false;

  RequestApi.customMethod({
    required this.method,
    this.bodyJson = const {},
    required String url,
    this.headers,
    this.files = const [],
    this.body = const {},
    this.enableCache = false,
  }) : uri = Uri.parse(url);
  RequestApi.customMethodUri({
    required this.method,
    required this.uri,
    this.bodyJson = const {},
    this.headers,
    this.files = const [],
    this.body = const {},
    this.enableCache = false,
  });

  Future<dynamic> request({bool getResponseBytes = false}) async {
    debugPrint(uri.toString());
    debugPrint(json.encode(body));
    http.MultipartRequest request = MultipartRequest(method, uri, onProgress: (int? bytes, int? totalBytes) {
      EasyHttp.requestProgressStream.add(RequestProgressModel(bytes: bytes,totalBytes: totalBytes));
    });
    request.fields.addAll(body);
    request.files.addAll(files);
    if (headers != null) request.headers.addAll(headers!);
    return await _ApiBaseHelper(request: request,requestApi: this,getResponseBytes: getResponseBytes,enableCache: enableCache).httpSendRequest();
  }

  Future<dynamic> requestJson({bool getResponseBytes = false}) async {
    debugPrint(uri.toString());
    debugPrint(json.encode(bodyJson));
    http.Request request = http.Request(method, uri);
    if(bodyJson.isNotEmpty) request.body = json.encode(bodyJson);
    if (headers != null) request.headers.addAll(headers!);
    return await _ApiBaseHelper(request: request,requestApi: this,getResponseBytes: getResponseBytes,enableCache: enableCache).httpSendRequest();
  }
}

class MultipartRequest extends http.MultipartRequest {
  MultipartRequest(super.method, super.url, {required this.onProgress});

  final void Function(int? bytes, int? totalBytes) onProgress;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();

    final total = contentLength;
    int bytes = 0;

    final t = StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (data, sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
      handleDone: (sink) {
        sink.close();
        onProgress(null,null);
      },
      handleError: (error, stackTrace, sink) {
        sink.addError(error, stackTrace);
        onProgress(null,null);
      },
    );

    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}

class _ApiBaseHelper {
  final http.BaseRequest request;
  final RequestApi requestApi;
  final bool getResponseBytes;
  final bool enableCache;

  _ApiBaseHelper({required this.request, required this.requestApi,this.getResponseBytes = false,this.enableCache = false});

  static CacheResponseManager cacheManager = CacheResponseManager();

  Future<dynamic> httpSendRequest() async {
    http.StreamedResponse response;
    Uint8List? responseBytes;
    String? responseText;
    try {
      request.headers.addAll(EasyHttp.staticHeaders);

      response = await request.send().timeout(const Duration(minutes: 5));
      if(getResponseBytes) responseBytes = await response.stream.toBytes();
      if(!getResponseBytes) responseText = await response.stream.bytesToString();

      AnsiPen pen = AnsiPen()..green(bold: true);
      debugPrint(pen("statusCode: ${response.statusCode}"));
     try{
       if(enableCache) _setCachedResponse(responseBytes: responseBytes,responseText: responseText);
     }catch(_){}
    } catch (e) {
      log(e.toString());
      throw ServerException(
        errorMessageModel: ErrorMessageModel(
          statusCode: 0,
          statusMessage: e.toString(),
          requestApi: requestApi,
        ),
      );
    }
    if(getResponseBytes) return responseBytes;
    return _returnResponse(response.statusCode,responseText??"",requestApi);
  }

  static Future<dynamic> _returnResponse(int statusCode,String resStream,RequestApi requestApi) async {
    EasyHttp.onGetStatusCode?.call(statusCode);
    Map<String,dynamic> jsonResponse = {};

    ServerException serverException({String? message}) => ServerException(
      errorMessageModel: ErrorMessageModel(
          statusCode: statusCode,
          statusMessage: message,
          requestApi: requestApi,
          responseApi: jsonResponse
      ),
    );

    try{
      jsonResponse = jsonDecode(resStream) as Map<String,dynamic>;
    }catch(e){
      throw ServerException(
        errorMessageModel: ErrorMessageModel(
            statusCode: statusCode,
            requestApi: requestApi,
            responseApi: {"_THIS_KEY_FROM_APP_THERE_IS_NO_KEY_GETTING_":resStream}
        ),
      );
    }
    AnsiPen pen = AnsiPen()..green(bold: true);
    log(pen("$jsonResponse"));

    switch (statusCode) {
      case 200:{
        if (jsonResponse["success"] == false) {
          throw serverException(message: jsonResponse["message"]);
        }
        return jsonResponse;
      }
      default: throw serverException(message: jsonResponse["message"]);
    }
  }

  Future<dynamic> _setCachedResponse({Uint8List? responseBytes,String? responseText})async{
    if(getResponseBytes){
      if(responseBytes != null) cacheManager.setCachedResponseBytes(request: requestApi,responseBytes: responseBytes);
    }else{
      if(responseText != null) cacheManager.setCachedResponseText(request: requestApi,responseText: responseText);
    }
  }
}
