import 'dart:ui';

extension ColorX on Color {

  int get colorValue {
    int floatToInt8(double x) => (x * 255.0).round() & 0xff;
    return floatToInt8(a) << 24 |
        floatToInt8(r) << 16 |
        floatToInt8(g) << 8 |
        floatToInt8(b) << 0;
  }
}