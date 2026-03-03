class DemoPostEntity {
  final int id;
  final String title;
  final String body;

  const DemoPostEntity({
    required this.id,
    required this.title,
    required this.body,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DemoPostEntity &&
        other.id == id &&
        other.title == title &&
        other.body == body;
  }

  @override
  int get hashCode => Object.hash(id, title, body);
}
