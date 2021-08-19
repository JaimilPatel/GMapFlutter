import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GoogleApiService {
  Dio? _dio;
  String tag = "Google API :";
  static final Dio mDio = Dio();

  static final GoogleApiService _instance = GoogleApiService._internal();

  factory GoogleApiService() {
    return _instance;
  }

  GoogleApiService._internal() {
    _dio = initApiServiceDio();
  }

  Dio initApiServiceDio() {
    final baseOption = BaseOptions(
      connectTimeout: 45 * 1000,
      receiveTimeout: 45 * 1000,
      baseUrl: 'https://maps.googleapis.com/maps/api/place/',
      contentType: 'application/json',
    );
    mDio.options = baseOption;

    final mInterceptorsWrapper =
        InterceptorsWrapper(onRequest: (options, handler) {
      debugPrint(
          "$tag ${options.method} "
          "${options.baseUrl.toString() + options.path}",
          wrapWidth: 1024);

      debugPrint("$tag ${options.headers.toString()}", wrapWidth: 1024);
      debugPrint("$tag ${options.queryParameters.toString()}", wrapWidth: 1024);
      debugPrint("$tag ${options.data.toString()}", wrapWidth: 1024);
      return handler.next(options); //continue
    }, onResponse: (response, handler) {
      debugPrint("Code  ${response.statusCode.toString()}", wrapWidth: 1024);
      debugPrint("Response ${response.toString()}", wrapWidth: 1024);
      return handler.next(response); // continue
    }, onError: (DioError e, handler) {
      debugPrint("$tag ${e.error.toString()}", wrapWidth: 1024);
      debugPrint("$tag ${e.response.toString()}", wrapWidth: 1024);
      return handler.next(e); //continue
    });

    mDio.interceptors.add(mInterceptorsWrapper);
    return mDio;
  }

  Future<Response> get(
    String endUrl,
    BuildContext context, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    try {
      var isConnected = await checkInternet();
      if (!isConnected) {
        return Future.error("Internet not connected");
      }
      return await (_dio!.get(
        endUrl,
        queryParameters: params,
        options: options,
      ));
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        return Future.error("Poor internet connection");
      }
      rethrow;
    }
  }

  Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
