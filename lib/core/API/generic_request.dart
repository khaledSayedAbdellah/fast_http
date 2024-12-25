import 'dart:typed_data';
import 'package:fast_http/core/API/request_method.dart';
import 'package:fast_http/core/Error/error_message_model.dart';
import 'package:fast_http/core/Error/exceptions.dart';

abstract interface class ModelValidation {
  String? validate();
}


class GenericRequest<T> {
  static String _keyData = "data";
  void init({required String keyData}){
    _keyData = keyData;
  }

  static T _emptyFromMap<T>(empty)=> empty;

  final T Function(dynamic) fromMap;
  final RequestApi method;

  GenericRequest({required this.fromMap, required this.method});
  GenericRequest.source({required this.method}): fromMap = _emptyFromMap;

  ServerException errorModel(dynamic response, String statusMessage, ExpectType expectType) => ServerException(
      errorMessageModel: RequestErrorModel.modelValidation(
      validateModelName: T.toString(),
      expectType: expectType,
      requestApi: method,
      responseApi: response,
      statusMessage: statusMessage,
    ),
  );

  Future<dynamic> _fireRequest({bool getResponseBytes = false})async{
    if (method.isMultipartRequest || method.files.isNotEmpty || method.body is Map<String,String>) {
      return await method.request(getResponseBytes: getResponseBytes);
    } else {
      return await method.requestJson(getResponseBytes: getResponseBytes);
    }
  }

  Future<T> getObject() async {
    dynamic response = await _fireRequest();

    if (response is! Map || response[_keyData] is! Map) {
      throw errorModel(response, "data is not compatible with expected data", ExpectType.object);
    }
    try {
      T result = fromMap(response[_keyData]);
      if (T is ModelValidation) {
        String? validateError = (result as ModelValidation).validate();
        if (validateError != null) {
          throw errorModel(response, validateError, ExpectType.object);
        }
      }
      return result;
    } catch (e) {
      throw errorModel(response, e.toString(), ExpectType.object);
    }
  }

  Future<List<T>> getList() async {
    dynamic response = await _fireRequest();

    if (!(response is List || response[_keyData] is List || response[_keyData][_keyData] is List)) {
      throw errorModel(response, "data is not compatible with expected data", ExpectType.list);
    }
    final List<dynamic> responseList;
    if(response is List) {
      responseList = response;
    } else if(response[_keyData] is List){
      responseList = response[_keyData];
    }else if(response[_keyData][_keyData] is List){
      responseList = response[_keyData][_keyData];
    }else{
      responseList = [];
    }
    try {
      List<T> resultList = List<T>.from(responseList.map((e) => fromMap(e)));
      if (T is ModelValidation) {
        for (T item in resultList) {
          String? validateError = (item as ModelValidation).validate();
          if (validateError != null) {
            throw errorModel(response, validateError, ExpectType.list);
          }
        }
      }
      return resultList;
    } catch (e) {
      throw errorModel(response, e.toString(), ExpectType.list);
    }
  }

  Future<T> getResponse() async {
    dynamic response = await _fireRequest();
    try {
      T result = fromMap(response);
      if (T is ModelValidation) {
        String? validateError = (result as ModelValidation).validate();
        if (validateError != null) {
          throw errorModel(response, validateError, ExpectType.response);
        }
      }
      return result;
    } catch (e) {
      throw errorModel(response, e.toString(), ExpectType.response);
    }
  }

  Future<Uint8List> getBytes() async {
    dynamic response = await _fireRequest(getResponseBytes: true) as Uint8List;
    try {
      return response;
    } catch (e) {
      throw errorModel(response, e.toString(), ExpectType.bytes);
    }
  }


}
