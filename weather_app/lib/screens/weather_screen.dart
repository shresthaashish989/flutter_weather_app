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
  Map<String, dynamic>? weatherData;
  final TextEditingController cityController = TextEditingController();
  bool isLoading = false;

  bool isDarkMode = false; // for demo toggle in settings

  @override
  void initState() {
    super.initState();
    cityController.text = city;
    fetchWeather(city);
  }

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });

    const apiKey = 'e8dd5ae2bbe1da0b7cbfda7b8ac8230b';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          weatherData = json;
          isLoading = false;
        });
      } else {
        setState(() {
          weatherData = null;
          isLoading = false;
        });
        _showError("City not found or failed to fetch weather.");
      }
    } catch (e) {
      setState(() {
        weatherData = null;
        isLoading = false;
      });
      _showError("Error fetching weather: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _getBackgroundColor() {
    if (isDarkMode) return Colors.grey[900]!;

    if (weatherData == null) return Colors.blue.shade300;

    final weatherMain = weatherData!['weather'][0]['main'].toString().toLowerCase();

    if (weatherMain.contains('cloud')) return Colors.blueGrey.shade400;
    if (weatherMain.contains('rain') || weatherMain.contains('drizzle'))
      return Colors.indigo.shade700;
    if (weatherMain.contains('clear')) return Colors.orange.shade400;
    if (weatherMain.contains('snow')) return Colors.lightBlue.shade100;

    return Colors.blue.shade300;
  }

  String? _getWeatherIconUrl() {
    if (weatherData == null) return null;
    final iconCode = weatherData!['weather'][0]['icon'];
    return 'https://openweathermap.org/img/wn/$iconCode@4x.png';
  }

  Widget weatherDetails() {
    if (isLoading) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (weatherData == null) {
      return const Text(
        "No data available.",
        style: TextStyle(fontSize: 22, color: Colors.white),
        textAlign: TextAlign.center,
      );
    }

    final main = weatherData!['main'];
    final weather = weatherData!['weather'][0];
    final coord = weatherData!['coord'];
    final sys = weatherData!['sys'];

    return Card(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${weatherData!['name']}, ${sys['country']}",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            if (_getWeatherIconUrl() != null)
              Image.network(
                _getWeatherIconUrl()!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            Text(
              weather['description'].toString().toUpperCase(),
              style: TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "🌡 Temperature: ${main['temp']} °C",
              style: TextStyle(fontSize: 20, color: isDarkMode ? Colors.white : Colors.black87),
            ),
            Text(
              "💧 Humidity: ${main['humidity']}%",
              style: TextStyle(fontSize: 20, color: isDarkMode ? Colors.white : Colors.black87),
            ),
            Text(
              "📍 Coordinates: [Lat: ${coord['lat']}, Lon: ${coord['lon']}]",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: isDarkMode ? Colors.white60 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          isDarkMode: isDarkMode,
          onToggleDarkMode: (val) {
            setState(() {
              isDarkMode = val;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: const Text("Weather App"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchWeather(cityController.text.trim());
            },
            tooltip: "Refresh",
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: "Settings",
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.indigo,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  _openSettings();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'Weather App',
                    applicationVersion: '1.0.0',
                    children: [
                      const Text('A Flutter Weather App by Ashish Shrestha'),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              TextField(
                controller: cityController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Enter city name",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black45),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black54),
                    onPressed: () {
                      final inputCity = cityController.text.trim();
                      if (inputCity.isNotEmpty) {
                        fetchWeather(inputCity);
                        FocusScope.of(context).unfocus(); // dismiss keyboard
                      }
                    },
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => fetchWeather(cityController.text.trim()),
        child: const Icon(Icons.refresh),
        tooltip: "Refresh weather",
      ),
    );
  }
}

// Settings Screen with Dark Mode toggle
class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDarkMode,
              onChanged: onToggleDarkMode,
              secondary: const Icon(Icons.brightness_6),
            ),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Flutter Weather App by Ashish Shrestha'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Weather App',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text('This app shows real-time weather data using OpenWeatherMap API.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
