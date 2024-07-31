import 'dart:typed_data';
import 'package:fast_http/core/API/generic_request.dart';
import 'package:fast_http/core/API/request_method.dart';
import 'package:fast_http/core/Error/exceptions.dart';
import 'package:fast_http/core/Error/failures.dart';


class APIMethod{
  static Future<Either<Failure,dynamic>> executeRequestApi({required RequestApi requestApi})async{
    try {
      dynamic response = await GenericRequest<dynamic>(
        method: requestApi,
        fromMap: (_)=> _,
      ).getResponse();
      return Right(response);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel));
    }
  }

  static Future<Either<Failure,Uint8List>> getImageData({required String imagePath})async{
    try {
      Uint8List response = await GenericRequest<dynamic>(
        method: RequestApi.get(url: imagePath,),
        fromMap: emptyFromMap,
      ).getBytes();
      return Right(response);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel));
    }
  }
}