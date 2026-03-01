class Metadata {
  late final int age;

  Metadata({required this.age});

  factory Metadata.fromMap(Map<String, dynamic> map) {
    return Metadata(age: map['age']);
  }
}
