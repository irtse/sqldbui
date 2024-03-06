import 'dart:convert';
import 'dart:developer' as developer;

abstract class SerializerDeserializer<T> {
  T deserialize(Map<String, dynamic> json);
  Map<String, dynamic> serialize();
}

Map<String, List<T>> fromMapListJson<T extends SerializerDeserializer>(Map<String, dynamic> j, SerializerDeserializer ref) {
    var map = <String, List<T>>{};
    for (var key in j.keys) {  
      if(j[key] != null) { map[key] = fromListJson(j[key], ref); }
    }
    return map;
}

Map<String, T> fromMapJson<T extends SerializerDeserializer>(Map<String, dynamic> j, SerializerDeserializer ref) {
    var map = <String, T>{};
    for (var key in j.keys) {  
      if(j[key] != null) { map[key] = ref.deserialize(json.decode(json.encode(j[key]))); }
    }
    return map;
}

List<T> fromListJson<T extends SerializerDeserializer>(List<dynamic> jss, SerializerDeserializer ref) {
    var list = <T>[];
    for (var js in jss) {  list.add(ref.deserialize(json.decode(json.encode(js)))); } 
    return list;
}

Map<String, Map<String, dynamic>> toMapJson<T extends SerializerDeserializer>(Map<String, T> json) {
    var map = <String, Map<String, dynamic>>{};
    for (var key in json.keys) { map[key] = json[key]!.serialize(); }
    return map;
}

List<Map<String, dynamic>> toListJson<T extends SerializerDeserializer>(List<T> obj) {
    var list = <Map<String, dynamic>>[];
    for (var js in obj) { list.add(js.serialize()); }
    return list;
}
