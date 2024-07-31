[![pub package](https://img.shields.io/badge/easy_http-red?logoSize=github&label=0.0.1&color=blue)](https://pub.dev/packages/easy_http)

simple request APIs  that ensure your request has no errors and handle request errors.


## Using

The easiest way to use this library is via the top-level functions. They allow
you to make individual HTTP requests with minimal hassle:

```dart
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
```


### 1. Add the EASY HTTP.

To add a package compatible with the Dart SDK to your project, use `dart pub add`.

```terminal
dart pub add easy_http
```