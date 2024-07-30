import 'dart:convert';
import 'dart:typed_data';
import 'package:easy_http/core/API/request_method.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


class CacheResponseManager extends CacheManager {
  static const key = "request-api-cache";

  static CacheResponseManager? _instance;

  factory CacheResponseManager() {
    _instance ??= CacheResponseManager._();
    return _instance!;
  }

  CacheResponseManager._()
      : super(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Cache for 7 days
      maxNrOfCacheObjects: 20,
    ),
  );

  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return join(directory.path, key);
  }

  Future<Uint8List?> getCachedResponseBytes(RequestApi request) async {
    try {
      FileInfo? fileInfo = await getFileFromCache("${request.uri.toString()}-${json.encode(request.body)}-${json.encode(request.bodyJson)}}");
      if (fileInfo != null && fileInfo.file.existsSync()) return fileInfo.file.readAsBytesSync();
      return null;
    }catch(_){return null;}
  }

  Future<String?> getCachedResponseText(RequestApi request) async {
   try{
     FileInfo? fileInfo = await getFileFromCache("${request.uri.toString()}-${json.encode(request.body)}-${json.encode(request.bodyJson)}}");
     if (fileInfo == null || !fileInfo.file.existsSync()) return null;

     List<int> byteList = fileInfo.file.readAsBytesSync();
     return utf8.decode(byteList);
   }catch(_){return null;}
  }

  Future<void> setCachedResponseBytes({required RequestApi request,required Uint8List responseBytes}) async {
   try{
     await putFile(
       "${request.uri.toString()}-${json.encode(request.body)}-${json.encode(request.bodyJson)}}",
       responseBytes,
       key: "${request.uri.toString()}-${json.encode(request.body)}-${json.encode(request.bodyJson)}}",
       fileExtension: 'txt',
     );
   }catch(_){}
  }

  Future<void> setCachedResponseText({required RequestApi request,required String responseText}) async {
   try{
     List<int> bytes = utf8.encode(responseText);
     Uint8List jsonBytes = Uint8List.fromList(bytes);
     await putFile(
       "${request.uri.toString()}-${json.encode(request.body)}-${json.encode(request.bodyJson)}}",
       jsonBytes,
       key: "${request.uri.toString()}-${json.encode(request.body)}-${json.encode(request.bodyJson)}}",
       fileExtension: 'txt',
     );
   }catch(_){}
  }

}