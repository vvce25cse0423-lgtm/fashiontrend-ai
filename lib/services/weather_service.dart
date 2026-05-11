import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Weather data model
class WeatherData {
  final String city;
  final double temperature;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final String fashionTip;

  const WeatherData({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.fashionTip,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final temp = (json['main']['temp'] as num).toDouble() - 273.15; // K → °C
    final condition = json['weather'][0]['main'] as String;
    final windSpeed = (json['wind']['speed'] as num).toDouble();

    return WeatherData(
      city: json['name'] as String,
      temperature: temp,
      condition: condition,
      icon: json['weather'][0]['icon'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: windSpeed,
      fashionTip: _getFashionTip(condition, temp),
    );
  }

  /// Returns fashion advice based on weather
  static String _getFashionTip(String condition, double temp) {
    if (condition == 'Rain' || condition == 'Drizzle') {
      return '🌧️ Rainy day! Layer up with a waterproof jacket or trench coat. Opt for ankle boots instead of sneakers.';
    } else if (condition == 'Snow') {
      return '❄️ Snowy day! Bundle up with a heavy coat, thermal layers, and waterproof boots.';
    } else if (condition == 'Clear' && temp > 30) {
      return '☀️ Hot and sunny! Light linen or cotton in breathable colors. Sunglasses and a hat are a must.';
    } else if (condition == 'Clear' && temp > 20) {
      return '🌤️ Perfect weather! A casual tee + chinos or a light dress will nail the day.';
    } else if (temp < 15) {
      return '🧥 Cool weather! Layer a hoodie under a jacket. Boots and dark denim are your friends.';
    } else if (condition == 'Clouds') {
      return '☁️ Cloudy day! Smart casual with a light jacket is your go-to look.';
    } else if (condition == 'Thunderstorm') {
      return '⛈️ Stay in and style comfortably! A cozy knit sweater and joggers are perfect.';
    }
    return '👔 Great day to rock your favorite outfit! Check your style score first.';
  }

  String get temperatureDisplay => '${temperature.round()}°C';
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

/// Service for fetching weather data
class WeatherService {
  final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  /// Get weather by GPS coordinates
  Future<WeatherData> getWeatherByLocation() async {
    // Check & request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return getWeatherByCity('Mumbai'); // fallback
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    return _fetchWeather('lat=${pos.latitude}&lon=${pos.longitude}');
  }

  /// Get weather by city name
  Future<WeatherData> getWeatherByCity(String city) async {
    return _fetchWeather('q=${Uri.encodeComponent(city)}');
  }

  Future<WeatherData> _fetchWeather(String query) async {
    if (_apiKey.isEmpty) return _mockWeather();

    try {
      final url = '$_baseUrl?$query&appid=$_apiKey';
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return WeatherData.fromJson(jsonDecode(response.body));
      }
      return _mockWeather();
    } catch (_) {
      return _mockWeather();
    }
  }

  WeatherData _mockWeather() {
    return const WeatherData(
      city: 'Your City',
      temperature: 28.0,
      condition: 'Clear',
      icon: '01d',
      humidity: 60,
      windSpeed: 10.0,
      fashionTip: '🌤️ Perfect weather! A casual tee + chinos will nail the day.',
    );
  }
}

final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService());

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  final service = ref.watch(weatherServiceProvider);
  return service.getWeatherByLocation();
});
