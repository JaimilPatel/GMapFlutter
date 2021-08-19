import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:gmap_flutter/model/error_model.dart';

import 'google_api_service.dart';

class ApiManager {
  final GoogleApiService _googleApiService = GoogleApiService();

  Future<dynamic> getPlaces(String url, BuildContext context) async {
    try {
      final response = await _googleApiService.get(url, context);
      return response;
    } on DioError catch (error) {
      throw ErrorModel.fromJson(error.response?.data);
    }
  }
}
