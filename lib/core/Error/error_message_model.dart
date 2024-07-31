import 'package:equatable/equatable.dart';
import 'package:fast_http/core/API/request_method.dart';

enum ExpectType { object, list, bytes, response }

class ErrorMessageModel extends Equatable {
  final RequestApi requestApi;
  final dynamic responseApi;
  final ExpectType? expectType;
  final int? statusCode;
  final String statusMessage;
  final String? validateModelName;

  String get statusCodeName => getStatusCodeName(statusCode);

  static String getStatusCodeName(int? statusCode) {
    switch (statusCode) {
      case 100:
        return 'Continue';
      case 101:
        return 'Switching Protocols';
      case 102:
        return 'Processing';
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 202:
        return 'Accepted';
      case 203:
        return 'Non-Authoritative Information';
      case 204:
        return 'No Content';
      case 205:
        return 'Reset Content';
      case 206:
        return 'Partial Content';
      case 207:
        return 'Multi-Status';
      case 208:
        return 'Already Reported';
      case 226:
        return 'IM Used';
      case 300:
        return 'Multiple Choices';
      case 301:
        return 'Moved Permanently';
      case 302:
        return 'Found';
      case 303:
        return 'See Other';
      case 304:
        return 'Not Modified';
      case 305:
        return 'Use Proxy';
      case 307:
        return 'Temporary Redirect';
      case 308:
        return 'Permanent Redirect';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 402:
        return 'Payment Required';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 405:
        return 'Method Not Allowed';
      case 406:
        return 'Not Acceptable';
      case 407:
        return 'Proxy Authentication Required';
      case 408:
        return 'Request Timeout';
      case 409:
        return 'Conflict';
      case 410:
        return 'Gone';
      case 411:
        return 'Length Required';
      case 412:
        return 'Precondition Failed';
      case 413:
        return 'Payload Too Large';
      case 414:
        return 'URI Too Long';
      case 415:
        return 'Unsupported Media Type';
      case 416:
        return 'Range Not Satisfiable';
      case 417:
        return 'Expectation Failed';
      case 418:
        return 'I\'m a teapot';
      case 421:
        return 'Misdirected Request';
      case 422:
        return 'Unprocessable Entity';
      case 423:
        return 'Locked';
      case 424:
        return 'Failed Dependency';
      case 425:
        return 'Too Early';
      case 426:
        return 'Upgrade Required';
      case 428:
        return 'Precondition Required';
      case 429:
        return 'Too Many Requests';
      case 431:
        return 'Request Header Fields Too Large';
      case 451:
        return 'Unavailable For Legal Reasons';
      case 500:
        return 'Internal Server Error';
      case 501:
        return 'Not Implemented';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      case 504:
        return 'Gateway Timeout';
      case 505:
        return 'HTTP Version Not Supported';
      case 506:
        return 'Variant Also Negotiates';
      case 507:
        return 'Insufficient Storage';
      case 508:
        return 'Loop Detected';
      case 510:
        return 'Not Extended';
      case 511:
        return 'Network Authentication Required';
      default:
        return 'Unknown Status Code';
    }
  }

  ErrorMessageModel(
      {required this.statusCode,
      String? statusMessage,
      required this.requestApi,
      this.responseApi,
      this.expectType})
      : validateModelName = null,
        statusMessage = statusMessage ?? getStatusCodeName(statusCode);

  const ErrorMessageModel.modelValidation({
    required this.validateModelName,
    required this.expectType,
    required this.requestApi,
    required this.statusMessage,
    required this.responseApi,
  }) : statusCode = null;

  ErrorMessageModel.local({
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
  List<Object?> get props => [
        statusCode,
        statusMessage,
      ];
}
