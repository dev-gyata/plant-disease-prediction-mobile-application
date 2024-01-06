import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:plant_disease_prediction/config/constants.dart';
import 'package:plant_disease_prediction/enums/plant_type.dart';
import 'package:plant_disease_prediction/models/api_response.dart';

class ApiService {
  static ApiService instance = ApiService._();
  late Dio _dio;
  ApiService._() {
    _dio = Dio();
  }

  Future<ApiResponse?> getPrediction(
      {required File file, required PlantType plantType}) async {
    try {
      log(file.toString());
      log(BASE_URL);
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });
      var res = await _dio.post('$BASE_URL${plantType.name.toLowerCase()}',
          data: formData);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {}
  }
}
