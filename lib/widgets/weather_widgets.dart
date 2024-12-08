import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;

class MyWeatherWidget extends StatefulWidget {
  const MyWeatherWidget({super.key});

  @override
  State<MyWeatherWidget> createState() => _MyWeatherWidgetState();
}

class _MyWeatherWidgetState extends State<MyWeatherWidget> {
  String apiKey = "078a06182d919b5b0777084107822a10";
  // double lat = 22.9006;
  // double long = 89.5024;
  String tempCelsius = "";
  String areaName = "";
  String weatherDescription = "";
  String weatherDescriptionKey = "";

  late DateTime dateTime;

  bool foundError = false;
  bool isReady = false;
  String errorTxt = "";

  Map<String, String> weatherDisplayText = {
    "thunderstorm with light rain": "🌩️ Thunderstorm with Light Rain",
    "thunderstorm with rain": "🌩️ Thunderstorm with Rain",
    "thunderstorm with heavy rain": "🌩️ Thunderstorm with Heavy Rain",
    "light drizzle": "🌦️ Light Drizzle",
    "drizzle": "🌦️ Drizzle",
    "light rain": "🌧️ Light Rain",
    "moderate rain": "🌧️ Moderate Rain",
    "heavy rain": "🌧️ Heavy Rain",
    "light snow": "❄️ Light Snow",
    "snow": "❄️ Snow",
    "clear sky": "☀️ Clear Sky",
    "few clouds": "⛅ Few Clouds",
    "scattered clouds": "🌤️ Scattered Clouds",
    "broken clouds": "☁️ Broken Clouds",
    "overcast clouds": "☁️ Overcast Clouds",
  };

  Map<String, String> weatherIcons = {
    "thunderstorm with light rain": "⛈️",
    "thunderstorm with rain": "⛈️",
    "thunderstorm with heavy rain": "⛈️",
    "light drizzle": "🌦️",
    "drizzle": "🌦️",
    "light rain": "🌧️",
    "moderate rain": "🌧️",
    "heavy rain": "🌧️",
    "light snow": "🌨️",
    "snow": "❄️",
    "clear sky": "☀️",
    "few clouds": "⛅",
    "scattered clouds": "🌤️",
    "broken clouds": "☁️",
    "overcast clouds": "☁️",
  };

  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getWeather() async {
    setState(() {
      isReady = false;
    });
    _determinePosition()
        .then((p) => getWeatherOnLocation(p))
        .onError((error, stackTrace) {
      setState(() {
        dateTime = DateTime.now();
        errorTxt = error.toString();
        isReady = true;
        foundError = true;
      });
    });
  }

  Future<void> getWeatherOnLocation(Position p) async {
    var lat = p.latitude;
    var lon = p.longitude;
    final String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // json decoding
        final data = jsonDecode(response.body);

        double temp = data['main']['temp'];
        tempCelsius = temp.toStringAsFixed(2);
        areaName = data['name'];
        weatherDescriptionKey = data['weather'][0]['description'];

        weatherDescription =
            weatherDisplayText[weatherDescriptionKey] ?? weatherDescription;

        setState(() {
          dateTime = DateTime.now();
          isReady = true;
          foundError = false;
        });
      } else {
        print('Failed to load weather data: ${response.statusCode}');
        setState(() {
          dateTime = DateTime.now();
          errorTxt = "Server error: ${response.statusCode}";
          foundError = true;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        dateTime = DateTime.now();
        errorTxt = "Make sure your internet is working";
        foundError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    getWeather();
  }

  Widget loadingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}',
          style: const TextStyle(
            color: Color(0xFF304022),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 0,
          ),
        ),
        const Text(
          "Refreshing",
          style: TextStyle(
            color: Color(0xFF304022),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 0,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Please wait...',
          style: TextStyle(
            color: Color(0xFF304022),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 0,
          ),
        ),
      ],
    );
  }

  Widget onErrorView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}',
                style: const TextStyle(
                  color: Color(0xFF304022),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Couldn't fetch weather data",
                style: TextStyle(
                  color: Color(0xFF304022),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                errorTxt,
                style: const TextStyle(
                  color: Color(0xFF304022),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              foundError = false;
              getWeather();
            });
          },
          icon: const Icon(Icons.replay_outlined),
        ),
      ],
    );
  }

  Widget weatherPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, $areaName',
                  style: const TextStyle(
                    color: Color(0xFF304022),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '$tempCelsius° Celsius',
                  style: const TextStyle(
                    color: Color(0xFF304022),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              weatherIcons[weatherDescriptionKey] ?? "",
              style: const TextStyle(
                fontSize: 40,
              ),
            ),
          ],
        ),
        Text(
          weatherDescription,
          style: const TextStyle(
            color: Color(0xFF304022),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: const Color.fromARGB(76, 158, 158, 158),
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        width: double.infinity,
        child: isReady && !foundError
            ? weatherPanel()
            : (foundError ? onErrorView() : loadingView()),
      ),
    );
  }
}
