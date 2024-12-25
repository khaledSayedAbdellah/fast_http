import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:ansicolor/ansicolor.dart';
import 'package:fast_http/core/Error/exceptions.dart';
import 'package:fast_http/fast_http.dart';
import 'package:http/http.dart' as http;
import '../Error/error_message_model.dart';
import 'header_manager.dart';
export 'package:dartz/dartz.dart';

class RequestApi {
  final Uri uri;
  final Map<String, dynamic> body;
  final List<http.MultipartFile> files;
  final Map<String, String>? headers;
  final String method;
  final bool isMultipartRequest;

  RequestApi._({
    required this.uri,
    required this.body,
    required this.files,
    this.headers,
    required this.method,
    required this.isMultipartRequest,
  });

  RequestApi copyWith({
    Uri? uri,
    Map<String, dynamic>? body,
    List<http.MultipartFile>? files,
    Map<String, String>? headers,
    String? method,
    bool? isMultipartRequest,
  }) {
    return RequestApi._(
      files: files ?? this.files,
      body: body ?? this.body,
      uri: uri ?? this.uri,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      isMultipartRequest: isMultipartRequest ?? this.isMultipartRequest,
    );
  }

  RequestApi.post({
    required String url,
    required this.body,
    this.files = const [],
    this.headers,
    this.isMultipartRequest = false,
  })  : method = "POST", uri = Uri.parse(url);

  RequestApi.postUri({
    required this.uri,
    this.body = const {},
    this.files = const [],
    this.headers,
    this.isMultipartRequest = false,
  }) : method = "POST";

  RequestApi.put({
    required String url,
    required this.body,
    this.files = const [],
    this.headers,
    this.isMultipartRequest = false,
  })  : method = "PUT", uri = Uri.parse(url);

  RequestApi.putUri({
    required this.uri,
    required this.body,
    this.files = const [],
    this.headers,
    this.isMultipartRequest = false,
  })  : method = "PUT";

  RequestApi.get({
    required String url,
    this.headers,
  })  : method = "GET", body = {}, files = [], uri = Uri.parse(url),isMultipartRequest = false;

  RequestApi.getUri({
    required this.uri,
    this.headers,
  })  : method = "GET", body = {}, files = [],isMultipartRequest = false;

  RequestApi.delete({
    required String url,
    this.headers,
  })  : method = "DELETE", body = {}, files = [], uri = Uri.parse(url),isMultipartRequest = false;
  RequestApi.deleteUri({
    required this.uri,
    this.headers,
  })  : method = "DELETE", body = {}, files = [],isMultipartRequest = false;

  RequestApi.customMethod({
    required this.method,
    required String url,
    this.headers,
    this.files = const [],
    this.body = const {},
    this.isMultipartRequest = false,
  }) : uri = Uri.parse(url);

  RequestApi.customMethodUri({
    required this.method,
    required this.uri,
    this.headers,
    this.files = const [],
    this.body = const {},
    this.isMultipartRequest = false,
  });

  Future<dynamic> request({bool getResponseBytes = false}) async {
    log(uri.toString());
    log(json.encode(body));
    http.MultipartRequest request = MultipartRequest(method, uri, onProgress: (int? bytes, int? totalBytes) {
      FastHttp.requestProgressStream.add((bytes,totalBytes));
    });
    request.fields.addAll(body as Map<String,String>);
    request.files.addAll(files);
    if (headers != null) request.headers.addAll(headers!);
    return await _ApiBaseHelper(request: request, requestApi: this, getResponseBytes: getResponseBytes,).call();
  }

  Future<dynamic> requestJson({bool getResponseBytes = false}) async {
    log(uri.toString());
    log(json.encode(body));
    http.Request request = http.Request(method, uri);
    if (body.isNotEmpty) request.body = json.encode(body);
    if (headers != null) request.headers.addAll(headers!);
    return await _ApiBaseHelper(request: request, requestApi: this, getResponseBytes: getResponseBytes).call();
  }
}

class _ApiBaseHelper {
  final http.BaseRequest request;
  final RequestApi requestApi;
  final bool getResponseBytes;

  _ApiBaseHelper({
    required this.request,
    required this.requestApi,
    this.getResponseBytes = false,
  });


  Future<dynamic> call() async {
    http.StreamedResponse response;
    Uint8List? responseBytes;
    String? responseText;
    try {
      request.headers.addAll(await FastHttpHeader().getHeaders());
      log("Request Headers: ${request.headers}");
      response = await request.send().timeout(const Duration(minutes: 5));

      if (getResponseBytes) responseBytes = await response.stream.toBytes();
      if (!getResponseBytes) responseText = await response.stream.bytesToString();


      AnsiPen pen = AnsiPen()..green(bold: true);
      log(pen("statusCode: ${response.statusCode}"));
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
    if (getResponseBytes) return responseBytes;
    return _handleResponse(response.statusCode, responseText ?? "", requestApi);
  }

  static Future<dynamic> _handleResponse(int statusCode, String resStream, RequestApi requestApi) async {
    FastHttp.onGetStatusCode?.call(statusCode);
    Map<String, dynamic> jsonResponse = {};

    ServerException serverException({String? message}) => ServerException(
      errorMessageModel: ErrorMessageModel(
        statusCode: statusCode,
        statusMessage: message,
        requestApi: requestApi,
        responseApi: jsonResponse,
      ),
    );

    try {
      jsonResponse = jsonDecode(resStream) as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        errorMessageModel: ErrorMessageModel(
            statusCode: statusCode,
            requestApi: requestApi,
            responseApi: {
              "_THIS_KEY_FROM_APP_THERE_IS_NO_KEY_GETTING_": resStream
            }),
      );
    }
    AnsiPen pen = AnsiPen()..green(bold: true);
    log(pen("$jsonResponse"));

    if(statusCode > 199 && statusCode <= 299) {
      {
        if (jsonResponse[FastHttp.staticCheckStatusKey] == false) throw serverException(message: FastHttp.staticFetErrorMessageFromResponse?.call(jsonResponse));
        return jsonResponse;
      }
    }else{
      serverException(message: FastHttp.staticFetErrorMessageFromResponse?.call(jsonResponse));
    }

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
        onProgress(null, null);
      },
      handleError: (error, stackTrace, sink) {
        sink.addError(error, stackTrace);
        onProgress(null, null);
      },
    );

    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
