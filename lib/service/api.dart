import 'dart:io';

import 'package:catholic_prayers/util/log.dart';
import 'package:catholic_prayers/util/secret.dart';
import 'package:dio/dio.dart';

class API {
  late Dio dio;

  API() {
    dio = Dio();
    dio.options.baseUrl = API_HOSTNAME;
    dio.options.connectTimeout = 10000;
    dio.options.followRedirects = true;
    dio.options.maxRedirects = 3;
    dio.options.receiveDataWhenStatusError = true;
  }

  Future<Response?> getAllPrayers() async {
    try {
      return await dio.request(
        "prayers",
        data: FormData.fromMap(API_KEY_DATA),
        options: Options(method: "POST"),
      );
    } on DioError catch (e) {
      Log.e(e.message);
      return null;
    }
  }

  Future<Response?> getBanners() async {
    try {
      return await dio.request(
        "prayer-banners",
        data: FormData.fromMap(API_KEY_DATA),
        options: Options(method: "POST"),
      );
    } on DioError {
      return null;
    }
  }

  Future<Response?> getPrayerCategory() async {
    try {
      return await dio.request(
        "prayer-category",
        data: FormData.fromMap(API_KEY_DATA),
        options: Options(method: "POST"),
      );
    } on DioError {
      return null;
    }
  }

  Future<Response?> getVerse() async {
    try {
      return await dio.request(
        "prayer-verse",
        data: FormData.fromMap(API_KEY_DATA),
        options: Options(method: "POST"),
      );
    } on DioError {
      return null;
    }
  }

  Future<Response?> getLatestVersionCode() async {
    try {
      final String os = Platform.isAndroid ? "android" : "ios";
      return await dio.request(
        "prayer-version-code?os=$os",
        data: FormData.fromMap(API_KEY_DATA),
        options: Options(method: "POST"),
      );
    } on DioError {
      return null;
    }
  }
}
