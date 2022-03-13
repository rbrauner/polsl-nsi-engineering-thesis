abstract class Sensor {
  bool aviable = false;

  double value = 0;
  double min = 0;
  double max = 0;

  double getPercentage() => (max - min) != 0 ? (value - min) / (max - min) : 0;
}
