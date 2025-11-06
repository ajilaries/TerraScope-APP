// Return background image based on condition
String getBackgroundImage(String condition) {
  condition = condition.toLowerCase();

  if (condition.contains('clear')) {
    return 'lib/assets/images/sunny.jpeg';
  } else if (condition.contains('cloud')) {
    return 'lib/assets/images/cloudy.jpeg';
  } else if (condition.contains('rain')) {
    return 'lib/assets/images/rainy.jpeg';
  } else if (condition.contains('storm') || condition.contains('thunder')) {
    return 'lib/assets/images/storm.jpg';
  } else if (condition.contains('snow')) {
    return 'lib/assets/images/snow.png';
  } else if (condition.contains('mist') || condition.contains('fog')) {
    return 'lib/assets/images/mist.png';
  } else {
    return 'lib/assets/images/default.jpg';
  }
}
