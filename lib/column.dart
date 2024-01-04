  class Column {
final String name;
final String type;

Column(this.name, this.type);

factory Column.fromJson(Map<String, dynamic> json) {
  return Column(
    json['name'],
    json['type'],
    );
}

}