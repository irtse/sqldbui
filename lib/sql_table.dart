import 'column.dart';

class SqlTable {
  final String name;
  final List<Column> columns;

  SqlTable(this.name, this.columns);

  factory SqlTable.fromJson(Map<String, dynamic> json) {
    var mp =  json['columns'] as Map<String,dynamic>;
    List<Column> lst = List.empty(growable: true);
    for (var k in mp.keys) {
      print("Key : $k, value : ${mp[k]}");
      lst.add(Column(k, mp[k] as String));
    }
    return SqlTable(
      json['name'],
      lst,
    );
  }
}
