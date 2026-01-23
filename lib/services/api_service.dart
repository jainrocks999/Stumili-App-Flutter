import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:weather_app/core/app_constants.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,

    ),
  );

  /// Generic GET request
  static Future<Response> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return await dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  /// Generic POST request
  static Future<Response> postRequest(
    String endpoint, {
    required Map<String, dynamic> body,
    String contentType = 'multipart/form-data',
    Map<String, dynamic>? headers,
  }) async {
    dynamic data;

    if (contentType == 'multipart/form-data') {
      data = FormData.fromMap(body);
    } else {
      data = body;
    }
debugPrint("ttttt$data");
    return await dio.post(
      endpoint,
      data: data,
      options: Options(headers: {
        'Content-Type': contentType,
        if (headers != null) ...headers,
      }),
    );
  }

  /// Generic PUT request
  static Future<Response> putRequest(
    String endpoint, {
    required Map<String, dynamic> body,
    String contentType = 'multipart/form-data',
    Map<String, dynamic>? headers,
  }) async {
    dynamic data;

    if (contentType == 'multipart/form-data') {
      data = FormData.fromMap(body);
    } else {
      data = body;
    }

    return await dio.put(
      endpoint,
      data: data,
      options: Options(headers: {
        'Content-Type': contentType,
        if (headers != null) ...headers,
      }),
    );
  }

  /// Generic PATCH request
  static Future<Response> patchRequest(
    String endpoint, {
    required Map<String, dynamic> body,
    String contentType = 'multipart/form-data',
    Map<String, dynamic>? headers,
  }) async {
    dynamic data;

    if (contentType == 'multipart/form-data') {
      data = FormData.fromMap(body);
    } else {
      data = body;
    }

    return await dio.patch(
      endpoint,
      data: data,
      options: Options(headers: {
        'Content-Type': contentType,
        if (headers != null) ...headers,
      }),
    );
  }

 static Future<Response> postWithToken(
    String endpoint, {
    required Map<String, dynamic> body,
    String contentType = 'multipart/form-data',
    String? token,
  }) async {
    final headers = <String, dynamic>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    dynamic data;
    if (contentType == 'multipart/form-data') {
      data = FormData.fromMap(body);
    } else {
      data = body;
    }

    return await dio.post(
      endpoint,
      data: data,
      options: Options(headers: {'Content-Type': contentType, ...headers}),
    );
  }

   static Future<Response> getWithToken(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    final headers = <String, dynamic>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }


}

