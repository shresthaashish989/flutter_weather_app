import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = "Kathmandu";
  String weatherInfo = "Fetching...";
  final TextEditingController cityController = TextEditingController();

  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    cityController.text = city;
    fetchWeather(city);
  }

  Future<void> fetchWeather(String city) async {
    const apiKey = 'e8dd5ae2bbe1da0b7cbfda7b8ac8230b';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        setState(() {
          weatherData = json;
          weatherInfo = ""; // clear error or previous text
        });
      } else {
        setState(() {
          weatherInfo = "City not found or Failed to fetch weather.";
          weatherData = null;
        });
      }
    } catch (e) {
      setState(() {
        weatherInfo = "Error: $e";
        weatherData = null;
      });
    }
  }

  Widget weatherDetails() {
    if (weatherData == null) {
      return Text(weatherInfo, style: const TextStyle(fontSize: 24));
    }

    final main = weatherData!['main'];
    final weather = weatherData!['weather'][0];
    final coord = weatherData!['coord'];
    final sys = weatherData!['sys'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${weatherData!['name']}, ${sys['country']}",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "🌡 Temperature: ${main['temp']} °C",
          style: const TextStyle(fontSize: 22),
        ),
        Text(
          "💧 Humidity: ${main['humidity']}%",
          style: const TextStyle(fontSize: 22),
        ),
        Text(
          "🌥 Condition: ${weather['description']}",
          style: const TextStyle(fontSize: 22),
        ),
        Text(
          "📍 Coordinates: [Lat: ${coord['lat']}, Lon: ${coord['lon']}]",
          style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather App")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: "Enter city name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final inputCity = cityController.text.trim();
                    if (inputCity.isNotEmpty) {
                      fetchWeather(inputCity);
                      FocusScope.of(context).unfocus(); // dismiss keyboard
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  fetchWeather(value.trim());
                }
              },
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: weatherDetails(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
