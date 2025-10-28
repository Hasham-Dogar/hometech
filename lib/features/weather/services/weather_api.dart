import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherApi {
  WeatherApi._();
  static final WeatherApi instance = WeatherApi._();

  /// Keep compatibility with callers that instantiate WeatherApi()
  factory WeatherApi() => instance;

  final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  final String _baseUrl =
      dotenv.env['BASE_URL'] ?? 'https://api.weatherapi.com/';

  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    if (_apiKey.isEmpty) {
      throw StateError(
        'WEATHER_API_KEY is not set. Make sure to load dotenv before using WeatherApi.',
      );
    }

    // remove trailing slashes from base URL to avoid double-slash in path
    final base = _baseUrl.replaceAll(RegExp(r'/+$'), '');
    final endpoint = '$base/v1/current.json';
    final uri = Uri.parse(
      endpoint,
    ).replace(queryParameters: {'key': _apiKey, 'q': city, 'aqi': 'no'});

    if (kDebugMode) {
      // ignore: avoid_print
      print('WeatherApi: requesting $uri');
    }

    final resp = await http.get(uri);

    if (kDebugMode) {
      // Helpful debug output for diagnosing 4xx/5xx responses
      // ignore: avoid_print
      print('WeatherApi: response status=${resp.statusCode} body=${resp.body}');
    }

    if (resp.statusCode != 200) {
      // include body to help diagnose 4xx errors
      throw http.ClientException(
        'Failed to fetch weather: ${resp.statusCode} ${resp.reasonPhrase} - ${resp.body}',
      );
    }

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return body;
  }

  /// Fetch a multi-day forecast for [city]. [city] may be a city name,
  /// a postal code, or a latitude,longitude pair (e.g. '51.5,-0.1').
  /// Returns the decoded JSON response from the /v1/forecast.json endpoint.
  Future<Map<String, dynamic>> fetchForecast(
    String city, {
    int days = 3,
  }) async {
    if (_apiKey.isEmpty) {
      throw StateError(
        'WEATHER_API_KEY is not set. Make sure to load dotenv before using WeatherApi.',
      );
    }

    final base = _baseUrl.replaceAll(RegExp(r'/+$'), '');
    final endpoint = '$base/v1/forecast.json';
    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'key': _apiKey,
        'q': city,
        'days': days.toString(),
        'aqi': 'no',
        'alerts': 'no',
      },
    );

    if (kDebugMode) {
      // ignore: avoid_print
      print('WeatherApi: requesting forecast $uri');
    }

    final resp = await http.get(uri);

    if (kDebugMode) {
      // ignore: avoid_print
      print('WeatherApi: forecast status=${resp.statusCode} body=${resp.body}');
    }

    if (resp.statusCode != 200) {
      throw http.ClientException(
        'Failed to fetch forecast: ${resp.statusCode} ${resp.reasonPhrase} - ${resp.body}',
      );
    }

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return body;
  }
}
