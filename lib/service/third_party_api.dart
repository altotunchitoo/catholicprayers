import 'package:catholic_prayers/util/secret.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ThirdPartyApi {
  late Dio _dio;

  ThirdPartyApi() {
    _dio = Dio();
    _dio.options.baseUrl = EVANGELIZO_HOSTNAME;
    _dio.options.connectTimeout = 10000;
    _dio.options.followRedirects = true;
    _dio.options.maxRedirects = 3;
    _dio.options.receiveDataWhenStatusError = true;
  }

  Future<Response?> getRomanOrdinaryCalenderDays() async {
    try {
      final DateTime now = DateTime.now();
      final String today = DateFormat('yyyy-MM-dd').format(now);
      return await _dio.request(
        'AM/days/$today?include=readings,commentary',
        options: Options(method: "POST"),
      );
    } on DioError {
      return null;
    }
  }
}
