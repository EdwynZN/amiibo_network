class StatUtils {
  const StatUtils();
  
  static final RegExp _regPercent = RegExp(r"^(\d+(?:\.\d*?[1-9](?=0|\b))?)\.?0*$");

  static String parseStat(num num, num den, {required bool usePercentage}) {
    if (usePercentage) {
      if (den == 0 || num == 0) return '0%';
      final double result = num * 100 / den.toDouble();
      return '${_regPercent.firstMatch(result.toStringAsFixed(2))![1]}%';
    }
    return '${num.toInt()}/${den.toInt()}';
  }
}
