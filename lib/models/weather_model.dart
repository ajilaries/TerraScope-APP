class WeatherModel {
  final double temp;
  final int humidity;
  final double wind;
  final int rainChance;
  final String condition;
  final String location;

  WeatherModel({
    required this.temp,
    required this.humidity,
    required this.wind,
    required this.rainChance,
    required this.condition,
    required this.location,
  });
}
