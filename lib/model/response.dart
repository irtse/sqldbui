import 'dart:convert';
import 'package:sqldbui2/model/abstract.dart';
import 'package:sqldbui2/model/user.dart';
import 'package:sqldbui2/model/view.dart';
import 'dart:developer' as developer;

Map<Type, SerializerDeserializer> refs = <Type, SerializerDeserializer> {
  User : User(),
  Item : Item(),
  View : View(),
  Shallowed : Shallowed(),
  SchemaField : SchemaField(),
};

class APIResponse<T extends SerializerDeserializer> {
  APIResponse({
    this.data,
    this.error = "",
  });

  List<T>? data ;
  String? error = "";

  SerializerDeserializer? getTypeString() {
    for (var ref in refs.keys) {
      if ('$ref' == '$T') { return refs[ref]; }
    }
    return null;
  }

  APIResponse<T> deserialize(Map<String, dynamic> j) {
    developer.log('LOG URL ${T}', name: 'my.app.category');
    return APIResponse<T>(
      data: fromListJson<T>(j["data"], refs[T]!), 
      error: j.containsKey("error") && j["error"] != null ? j["error"] : "",
    );
  }
}