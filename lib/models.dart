class LocalizationData {
  double latitude;
  double longitude;
  double accuracy;
  double speed;
  double altitude;
  double heading;
  LocalizationData({
    this.latitude = 0,
    this.longitude = 0,
    this.accuracy = 0,
    this.speed = 0,
    this.altitude = 0,
    this.heading = 0,
  });
  @override
  String toString() {
    return """$latitude <=> $longitude <=> $accuracy <=> $speed <=> $altitude <=> $heading
""";
  }
}
