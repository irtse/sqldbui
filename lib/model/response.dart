import 'package:sqldbui2/model/abstract.dart';
import 'package:sqldbui2/model/user.dart';
import 'package:sqldbui2/model/view.dart';

Map<Type, SerializerDeserializer> refs = <Type, SerializerDeserializer> {
  User : User(),
  Item : Item(),
  View : View(),
  DataAccess: DataAccess(),
  Shallowed : Shallowed(),
  SchemaField : SchemaField(),
  RawData : RawData(),
};

class APIResponse<T extends SerializerDeserializer> {
  APIResponse({
    this.data,
    this.error = "",
    this.offset = 0,
  });
  int offset = 0;
  List<T>? data ;
  String? error = "";

  SerializerDeserializer? getTypeString() {
    for (var ref in refs.keys) {
      if ('$ref' == '$T') { return refs[ref]; }
    }
    return null;
  }

  APIResponse<T> deserialize(Map<String, dynamic> j) {
    if (refs[T] == null || j["data"] == null) {
      return APIResponse<T>(
        data: null, 
        error: j.containsKey("error") && j["error"] != null ? j["error"] : "",
      );
    }
    return APIResponse<T>(
      data: fromListJson<T>(j["data"], refs[T]!), 
      error: j.containsKey("error") && j["error"] != null ? j["error"] : "",
    );
  }
}