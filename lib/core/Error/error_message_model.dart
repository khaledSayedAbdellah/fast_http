import 'package:equatable/equatable.dart';
import 'package:fast_http/core/API/request_method.dart';

enum ExpectType { object, list, response, bytes }

class RequestErrorModel extends Equatable {
  final RequestApi requestApi;
  final dynamic responseApi;
  final ExpectType? expectType;
  final int? statusCode;
  final String statusMessage;
  final String? validateModelName;

  String get statusCodeName => getStatusCodeName(statusCode);


  RequestErrorModel(
      {required this.statusCode,
      String? statusMessage,
      required this.requestApi,
      this.responseApi,
      this.expectType})
      : validateModelName = null,
        statusMessage = statusMessage ?? getStatusCodeName(statusCode);

  const RequestErrorModel.modelValidation({
    required this.validateModelName,
    required this.expectType,
    required this.requestApi,
    required this.statusMessage,
    required this.responseApi,
  }) : statusCode = null;

  RequestErrorModel.local({
    required this.statusMessage,
  })  : statusCode = null,
        validateModelName = null,
        expectType = null,
        requestApi = RequestApi.customMethod(method: "_", url: "_"),
        responseApi = null;

  @override
  String toString() => validateModelName == null
      ? "API ERROR: ${statusCode == null ? "" : "statusCode: $statusCode ,"}message: $statusMessage"
      : "PARSING ERROR: modelName: $validateModelName";

  @override
  List<Object?> get props => [statusCode, requestApi.uri.toString(),requestApi.method,requestApi];


  static String getStatusCodeName(int? statusCode) {
    return switch (statusCode) {
      100 => 'Continue',
      101=> 'Switching Protocols',
      102=> 'Processing',
      200=> 'OK',
      201=> 'Created',
      202=> 'Accepted',
      203=> 'Non-Authoritative Information',
      204=> 'No Content',
      205=> 'Reset Content',
      206=> 'Partial Content',
      207=> 'Multi-Status',
      208=> 'Already Reported',
      226=> 'IM Used',
      300=> 'Multiple Choices',
      301=> 'Moved Permanently',
      302=> 'Found',
      303=> 'See Other',
      304=> 'Not Modified',
      305=> 'Use Proxy',
      307=> 'Temporary Redirect',
      308=> 'Permanent Redirect',
      400=> 'Bad Request',
      401=> 'Unauthorized',
      402=> 'Payment Required',
      403=> 'Forbidden',
      404=> 'Not Found',
      405=> 'Method Not Allowed',
      406=> 'Not Acceptable',
      407=> 'Proxy Authentication Required',
      408=> 'Request Timeout',
      409=> 'Conflict',
      410=> 'Gone',
      411=> 'Length Required',
      412=> 'Precondition Failed',
      413=> 'Payload Too Large',
      414=> 'URI Too Long',
      415=> 'Unsupported Media Type',
      416=> 'Range Not Satisfiable',
      417=> 'Expectation Failed',
      418=> 'I\'m a teapot',
      421=> 'Misdirected Request',
      422=> 'Unprocessable Entity',
      423=> 'Locked',
      424=> 'Failed Dependency',
      425=> 'Too Early',
      426=> 'Upgrade Required',
      428=> 'Precondition Required',
      429=> 'Too Many Requests',
      431=> 'Request Header Fields Too Large',
      451=> 'Unavailable For Legal Reasons',
      500=> 'Internal Server Error',
      501=> 'Not Implemented',
      502=> 'Bad Gateway',
      503=> 'Service Unavailable',
      504=> 'Gateway Timeout',
      505=> 'HTTP Version Not Supported',
      506=> 'Variant Also Negotiates',
      507=> 'Insufficient Storage',
      508=> 'Loop Detected',
      510=> 'Not Extended',
      511=> 'Network Authentication Required',
      _ => 'Unknown Status Code',
    };
  }

}
