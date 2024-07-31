import 'dart:convert';
import 'dart:typed_data';
import 'package:fast_http/core/API/request_method.dart';
import 'package:fast_http/core/Error/error_message_model.dart';
import 'package:fast_http/core/Error/exceptions.dart';
import 'cache_response_manager.dart';

abstract interface class ModelValidation{
  String? validate();
}

dynamic emptyFromMap = (Map<String, dynamic> a)=> a;
class GenericRequest<T> {
  final T Function(Map<String, dynamic> json) fromMap;
  final RequestApi method;

  GenericRequest({required this.fromMap, required this.method});

  ServerException errorModel(dynamic response,String statusMessage,ExpectType expectType)=> ServerException(
    errorMessageModel: ErrorMessageModel.modelValidation(
      validateModelName: T.toString(),
      expectType: expectType,
      requestApi: method,
      responseApi: response,
      statusMessage: statusMessage,
    )
  );

  Future<T> getObject({bool usingCache = false}) async {
    Map<String, dynamic> response;
    if(!usingCache) {
      if (method.body.isNotEmpty) {
        response = await method.request() as Map<String, dynamic>;
      } else {
        response = await method.requestJson() as Map<String, dynamic>;
      }
    }else{
      String? cachedResponse = await CacheResponseManager().getCachedResponseText(method);
      if(cachedResponse == null) throw errorModel(cachedResponse,"NO-CACHED",ExpectType.list);
      response = jsonDecode(cachedResponse) as Map<String,dynamic>;
    }
    if (response["data"] is! Map) {
      throw errorModel(response,"data is not compatible with expected data",ExpectType.object);
    }
    try{
      T result = fromMap(response["data"] as Map<String,dynamic>);
      if(T is ModelValidation){
        String? validateError = (result as ModelValidation).validate();
        if(validateError!=null) throw errorModel(response,validateError,ExpectType.object);
      }
      return result;
    }catch(e){
      throw errorModel(response,e.toString(),ExpectType.object);
    }
  }

  Future<List<T>> getList({bool usingCache = false}) async {
    Map<String, dynamic> response;
    if(!usingCache){
      if (method.body.isNotEmpty  || method.files.isNotEmpty) {
        response = await method.request() as Map<String, dynamic>;
      } else {
        response = await method.requestJson() as Map<String, dynamic>;
      }
    }else{
      String? cachedResponse = await CacheResponseManager().getCachedResponseText(method);
      if(cachedResponse == null) throw errorModel(cachedResponse,"NO-CACHED",ExpectType.list);
      response = jsonDecode(cachedResponse) as Map<String,dynamic>;
    }
    if (!(response["data"] is List || response["data"]["data"] is List)) throw errorModel(response,"data is not compatible with expected data",ExpectType.list);
    final List<Map<String, dynamic>> responseList = ((response["data"] is List)? response["data"] : response["data"]["data"]) as List<Map<String, dynamic>>;
    try{
      List<T> resultList =  List<T>.from(responseList.map((e) => fromMap(e)));
      if(T is ModelValidation){
        for (var item in resultList) {
          String? validateError = (item as ModelValidation).validate();
          if(validateError!=null) throw errorModel(response,validateError,ExpectType.list);
        }
      }
      return resultList;
    }catch(e){
      throw errorModel(response,e.toString(),ExpectType.object);
    }
  }

  Future<Uint8List> getBytes({bool usingCache = false}) async {
    Uint8List response;
    if(!usingCache){
      if (method.body.isNotEmpty  || method.files.isNotEmpty) {
        response = await method.request(getResponseBytes: true) as Uint8List;
      } else {
        response = await method.requestJson(getResponseBytes: true) as Uint8List;
      }
    }else{
      Uint8List? cachedResponse = await CacheResponseManager().getCachedResponseBytes(method);
      if(cachedResponse == null) throw errorModel(cachedResponse,"NO-CACHED",ExpectType.list);
      response = cachedResponse;
    }

    try{
      return response;
    }catch(e){
      throw errorModel(response,e.toString(),ExpectType.bytes);
    }
  }

  Future<T> getResponse({bool usingCache = false}) async {
    Map<String, dynamic> response;
    if(!usingCache){
      if (method.body.isNotEmpty || method.files.isNotEmpty) {
        response = await method.request() as Map<String, dynamic>;
      } else {
        response = await method.requestJson() as Map<String, dynamic>;
      }
    }else{
      String? cachedResponse = await CacheResponseManager().getCachedResponseText(method);
      if(cachedResponse == null) throw errorModel(cachedResponse,"NO-CACHED",ExpectType.list);
      response = jsonDecode(cachedResponse) as Map<String,dynamic>;
    }


    try{
      T result = fromMap(response);
      if(T is ModelValidation){
        String? validateError = (result as ModelValidation).validate();
        if(validateError!=null) throw errorModel(response,validateError,ExpectType.response);
      }
      return result;
    }catch(e){
      throw errorModel(response,e.toString(),ExpectType.response);
    }
  }

}
