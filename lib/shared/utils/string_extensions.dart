extension FormatString on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return length > 1
      ? this.replaceRange(0, 1, this[0].toUpperCase())
      : this.toUpperCase();
  }
}