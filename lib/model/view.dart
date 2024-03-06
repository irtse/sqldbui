import 'package:sqldbui2/model/abstract.dart';
import 'dart:developer' as developer;
import 'dart:convert';

const emptyStr = <String>[];
const emptySchema = <String, SchemaField>{};

class SchemaField extends SerializerDeserializer<SchemaField> {
  SchemaField({
    this.label = "",
    this.type = "",
    this.index = 0,
    this.placeholder = "",
    this.description = "",
    this.readonly = false,
    this.require = false,
    this.defaultValue,
    this.valuesPath = "",
    this.actionPath = "",
    this.actions = emptyStr,
    this.schema = emptySchema,
  });

  String label;
  String type;
  int index;
  String description;
  String placeholder;
  dynamic defaultValue;
  bool readonly;
  bool require;
  String valuesPath;
  String actionPath;
  List<dynamic> actions;
  Map<String, SchemaField> schema;

  @override Map<String, dynamic> serialize() => { };

  @override SchemaField deserialize(Map<String, dynamic> json) => SchemaField(
    actionPath: json.containsKey("action_path") && json["action_path"] != null ? json["action_path"] : <String>[], 
    actions: json.containsKey("actions") && json["actions"] != null ? json["actions"] : <String>[], 
    schema: json.containsKey("data_schema") && json["data_schema"] != null ?  fromMapJson(json["data_schema"], SchemaField()) : emptySchema, 
    label : json.containsKey("label") && json["label"] != null ? json["label"] : "Unknown label",
    index : json.containsKey("index") && json["index"] != null ? json["index"] : 0,
    type : json.containsKey("type") && json["type"] != null ? json["type"] : "varchar(250)",
    placeholder : json.containsKey("placeholder") && json["placeholder"] != null ? json["placeholder"] : "...",
    description : json.containsKey("description") && json["description"] != null ? json["description"] : "no description...",
    readonly : json.containsKey("readonly") && json["readonly"] != null ? json["readonly"] : false,
    require : json.containsKey("required") && json["required"] != null ? json["required"] : false,
    defaultValue : json.containsKey("default_value") && json["default_value"] != null ? json["default_value"] : null,
    valuesPath : json.containsKey("values_path") && json["values_path"] != null ? json["values_path"] : "",
  );
}
const emptyValues = <String, Shallowed>{};
const emptyDyn = <String, dynamic>{};
const emptyManyValues = <String, List<Shallowed>>{};
class Item extends SerializerDeserializer<Item> {
  Item({
    this.dataPath = "",
    this.valuesShallow = emptyValues,
    this.linkPath= "",
    this.valuesManyPath = emptyDyn,
    this.values = emptyDyn,
    this.valuesMany = emptyManyValues,
  });
  Map<String,dynamic> valuesManyPath;
  Map<String,dynamic> values;
  String linkPath = "";
  String dataPath = "";
  Map<String,Shallowed> valuesShallow;
  Map<String,List<Shallowed>>valuesMany;

  @override Map<String, dynamic> serialize() => {};

  @override deserialize(Map<String, dynamic> json) {
    return  Item(
      valuesShallow: json.containsKey("values_shallow") && json["values_shallow"] != null ? fromMapJson<Shallowed>(json["values_shallow"], Shallowed()) : <String, Shallowed>{}, 
      dataPath: json.containsKey("data_path") && json["data_path"] != null ? json["data_path"] : "", 
      valuesMany: json.containsKey("values_many") && json["values_many"] != null ? fromMapListJson<Shallowed>(json["values_many"], Shallowed()) : <String, List<Shallowed>>{}, 
      linkPath: json.containsKey("link_path") && json["link_path"] != null ? json["link_path"] : "",  
      values: json.containsKey("values") && json["values"] != null ? json["values"] : <String,dynamic>{}, 
      valuesManyPath: json.containsKey("values_path_many") && json["values_path_many"] != null ? json["values_path_many"] : <String,dynamic>{},
    );
} }

const emptyitem = <Item>[];
class View extends SerializerDeserializer<View> {
  View({
    this.actions = emptyStr,
    this.items = emptyitem,
    this.name = "",
    this.label,
    this.category = "",
    this.description = "",
    this.isList = false,
    this.schema = emptySchema,
    this.schemaName = "",
    this.linkPath = "",
    this.id = -1,
    this.readOnly = false,
    this.wrapperSchema,
    this.wrapper,
    this.actionPath = "",
    this.order = emptyStr, 
    this.schemaID,
    this.isEmpty = false,
  });

  String actionPath;
  List<dynamic> actions;
  List<Item> items;
  String name;
  String? label;
  String description;
  bool isList;
  bool readOnly;
  String category;
  String linkPath;
  bool isEmpty;
  int id;
  String schemaName;
  View? wrapper;
  int? schemaID;
  Map<String, SchemaField> schema;
  Map<String, SchemaField>? wrapperSchema;
  List<dynamic> order;

  @override deserialize(Map<String, dynamic> json) {
    return View(
    id: json.containsKey("id") && json["id"] != null ? json["id"] : -1, 
    schemaID: json.containsKey("schema_id") && json["schema_id"] != null ? json["schema_id"] : null, 
    isEmpty: json.containsKey("is_empty") && json["is_empty"] != null ? json["is_empty"] : false, 
    readOnly: json.containsKey("readonly") && json["readonly"] != null ? json["readonly"] : false,  
    actionPath: json.containsKey("action_path") && json["action_path"] != null ? json["action_path"] : "", 
    actions: json.containsKey("actions") && json["actions"] != null ? json["actions"] : <String>[], 
    items: json.containsKey("items") && json["items"] != null ? fromListJson(json["items"], Item()) : <Item>[], 
    name: json.containsKey("name") && json["name"] != null ? json["name"] : "Unknown name",  
    category: json.containsKey("category") && json["category"] != null ? json["category"] : "General", 
    description: json.containsKey("description") && json["description"] != null ? json["description"] : "no description...", 
    isList: json.containsKey("is_list") && json["is_list"] != null ? json["is_list"] : false, 
    wrapperSchema: json.containsKey("wrapper_schema") && json["wrapper_schema"] != null ? fromMapJson(json["wrapper_schema"], SchemaField()) : null,
    wrapper: json.containsKey("wrapper") && json["wrapper"] != null ? View().deserialize(json["wrapper"]) : null,
    schema: json.containsKey("schema") && json["schema"] != null ? fromMapJson(json["schema"], SchemaField()) : <String,SchemaField>{},
    schemaName: json.containsKey("schema_name") && json["schema_name"] != null ? json["schema_name"] : "", 
    order: json.containsKey("order") && json["order"] != null ? json["order"] : <String>[],  
    label: json.containsKey("label") ? json["label"] : null,
    linkPath: json.containsKey("link_path") && json["link_path"] != null ? json["link_path"] : "", );
  }
  @override Map<String, dynamic> serialize() => { };
}

class Shallowed extends SerializerDeserializer<Shallowed> {
  Shallowed({
    this.id,
    this.name,
    this.label,
    this.readOnly = false,
    this.actions = emptyStr,
    this.actionPath = "",
    this.schema = emptySchema,
    this.linkPath = "",
    this.schemaName = "",
    this.order = emptyStr, 
  });
  String? label;
  String? name;
  int? id;
  bool readOnly;
  String linkPath;
  String schemaName;
  List<dynamic> order;
  String actionPath;
  List<dynamic> actions;
  Map<String, SchemaField> schema;

  @override deserialize(Map<String, dynamic> json) {
    return Shallowed(
    id: json.containsKey("id") ? json["id"] : null, 
    name: json.containsKey("name") ? json["name"] : null,
    label: json.containsKey("label") ? json["label"] : null,
    readOnly: json.containsKey("readonly") && json["readonly"] != null ? json["readonly"] : false,  
    actionPath: json.containsKey("action_path") && json["action_path"] != null ? json["action_path"] : "", 
    actions: json.containsKey("actions") && json["actions"] != null ? json["actions"] : <String>[], 
    schemaName: json.containsKey("schema_name") && json["schema_name"] != null ? json["schema_name"] : "", 
    order: json.containsKey("order") && json["order"] != null ? json["order"] : <String>[],  
    linkPath: json.containsKey("link_path") && json["link_path"] != null ? json["link_path"] : "",
    schema: json.containsKey("schema") && json["schema"] != null ? fromMapJson(json["schema"], SchemaField()) : <String,SchemaField>{});
  }
  @override Map<String, dynamic> serialize() => {
    "id" : id,
    "name" : name,
  };
}