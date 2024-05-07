import 'package:sqldbui2/model/abstract.dart';
import 'dart:developer' as developer;
import 'dart:convert';

const emptyStr = <String>[];
const emptySchema = <String, SchemaField>{};

class SchemaField extends SerializerDeserializer<SchemaField> {
  SchemaField({
    this.label = "",
    this.type = "",
    this.active = true,
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
  bool active;
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
    active: json.containsKey("active") && json["active"] != null ? json["active"] : true,
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
    this.workflow,
  });
  Map<String,dynamic> valuesManyPath;
  Map<String,dynamic> values;
  String linkPath = "";
  String dataPath = "";
  Workflow? workflow;
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
      workflow: json.containsKey("workflow") && json["workflow"] != null ? Workflow().deserialize(json["workflow"]) : null, 
      valuesManyPath: json.containsKey("values_path_many") && json["values_path_many"] != null ? json["values_path_many"] : <String,dynamic>{},
    );
} }

class Step extends SerializerDeserializer<Step> {
  Step({
    this.id = "",
    this.name = "",
    this.optionnal = false,
    this.workflow,
    this.isClose = false,
    this.isCurrent = false,
    this.isDismiss = false,
    this.isSet = false,
  });
  String id = "";
  String name = "";
  bool optionnal = false;
  Workflow? workflow;
  bool isClose = false;
  bool isDismiss = false; 
  bool isCurrent = false;
  bool isSet = false;
  @override Map<String, dynamic> serialize() => {};

  @override deserialize(Map<String, dynamic> json) {
    return  Step(
      id: json.containsKey("id") && json["id"] != null ? json["id"] : "", 
      name: json.containsKey("name") && json["name"] != null ? json["name"] : "", 
      isClose: json.containsKey("is_close") && json["is_close"] != null ? json["is_close"] : false,
      isCurrent: json.containsKey("is_current") && json["is_current"] != null ? json["is_current"] : false,
      isDismiss: json.containsKey("is_dismiss") && json["is_dismiss"] != null ? json["is_dismiss"] : false,
      optionnal: json.containsKey("optionnal") && json["optionnal"] != null ? json["optionnal"] : false,
      isSet: json.containsKey("is_set") && json["is_set"] != null ? json["is_set"] : true,
      workflow: json.containsKey("workflow") && json["workflow"] != null ? Workflow().deserialize(json["workflow"]) : null, 
    );
} }
const Map<String,List<Step>> emptyMapList = {};
class Workflow extends SerializerDeserializer<Workflow> {
  Workflow({
    this.id = "",
    this.current = "",
    this.currentHub = false,
    this.isClose = false,
    this.currentClose = false,
    this.steps=emptyMapList,
    this.currentDismiss = false,
    this.isDismiss = false,
  });
  String id = "";
  bool isClose = false;
  bool isDismiss = false;
  String current = "";
  bool currentHub = false;
  bool currentClose = false;
  bool currentDismiss = false;

  Map<String,List<Step>> steps;

  @override Map<String, dynamic> serialize() => {};

  @override deserialize(Map<String, dynamic> json) {
    return  Workflow(
      id :json.containsKey("id") && json["id"] != null ? json["id"] : "", 
      current: json.containsKey("current") && json["current"] != null ? json["current"] : "", 
      currentDismiss: json.containsKey("current_dismiss") && json["current_dismiss"] != null ? json["current_dismiss"] : false, 
      currentClose: json.containsKey("current_close") && json["current_close"] != null ? json["current_close"] : false, 
      isClose: json.containsKey("is_close") && json["is_close"] != null ? json["is_close"] : false, 
      isDismiss: json.containsKey("is_dismiss") && json["is_dismiss"] != null ? json["is_dismiss"] : false, 
      currentHub: json.containsKey("current_hub") && json["current_hub"] != null ? json["current_hub"] : false, 
      steps: json.containsKey("steps") && json["steps"] != null ? fromMapListJson<Step>(json["steps"], Step()) : <String, List<Step>>{}, 
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
    this.favorizePath = "",
    this.order = emptyStr, 
    this.schemaID,
    this.isEmpty = false,
    this.viewID,
    this.newIds = emptyStr,
    this.max = 0,
    this.workflow,
    this.isFavorize = false,
    this.favorizeBody = emptyDyn,
    this.filterPath = "",
    this.shortcuts = emptyDyn,
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
  bool isFavorize;
  int id;
  String schemaName;
  String favorizePath;
  String filterPath;
  View? wrapper;
  int? schemaID;
  int? viewID;
  Map<String, SchemaField> schema;
  Map<String, SchemaField>? wrapperSchema;
  Map<String, dynamic> favorizeBody;
  List<dynamic> order;
  List<dynamic> newIds;
  int max;
  Workflow? workflow;
  Map<String, dynamic> shortcuts= <String, dynamic>{};

  @override deserialize(Map<String, dynamic> json) {
    return View(
    workflow: json.containsKey("workflow") && json["workflow"] != null ? Workflow().deserialize(json["workflow"]) : null, 
    id: json.containsKey("id") && json["id"] != null ? json["id"] : -1, 
    shortcuts: json.containsKey("shortcuts") && json["shortcuts"] != null ? json["shortcuts"] : <String, dynamic>{},
    max: json.containsKey("max") && json["max"] != null ? json["max"] : 0, 
    newIds: json.containsKey("new") && json["new"] != null ? json["new"] : <String>[], 
    favorizeBody : json.containsKey("favorize_body") && json["favorize_body"] != null ? json["favorize_body"] : {},
    favorizePath : json.containsKey("favorize_path") && json["favorize_path"] != null ? json["favorize_path"] : "",
    filterPath : json.containsKey("filter_path") && json["filter_path"] != null ? json["filter_path"] : "",
    isFavorize: json.containsKey("is_favorize") && json["is_favorize"] != null ? json["is_favorize"] : false,
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
    this.workflow,
    this.fields = emptyStr,
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
  Workflow? workflow;
  List<dynamic> fields;

  @override deserialize(Map<String, dynamic> json) {
    developer.log("Shallowed $json", name: "Shallowed");
    return Shallowed(
    id: json.containsKey("id") ? json["id"] : null, 
    fields: json.containsKey("fields") ? json["fields"] : <String>[],
    name: json.containsKey("name") ? json["name"] : null,
    label: json.containsKey("label") ? json["label"] : null,
    workflow: json.containsKey("workflow") && json["workflow"] != null ? Workflow().deserialize(json["workflow"]) : null, 
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