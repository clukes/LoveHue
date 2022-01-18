class RelationshipBar {
  final int? id;
  String label;
  int value;

  RelationshipBar({
    this.id,
    required this.label,
    this.value = 100,
  });

  RelationshipBar.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        label = res["label"],
        value = res["value"];

  Map<String, dynamic> toMap() => {
    "id": id,
    "label": label,
    "value": value,
  };

  @override
  String toString() {
    return label + ": " + value.toString();
  }
}
