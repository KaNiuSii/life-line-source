class LineData {
  late final double age;
  late final bool positive;
  late final String title;

  LineData({required this.age, required this.positive, required this.title});

  factory LineData.fromMap(Map<String, dynamic> map) {
    return LineData(
      age: map['age'],
      positive: map['positive'],
      title: map['title'],
    );
  }
}
