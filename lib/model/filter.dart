import 'package:flutter/material.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterSelector.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/abstract.dart';
import 'package:sqldbui2/model/view.dart' as models;
import 'package:sqldbui2/page/translate.dart';

Map<String?, String> globalNew = {};
Map<String?, Filters> globalFilter = {};
Map<String?, Map<String,String>> globalOrder = {};

class Filters {
  bool isEmpty = false;
  Map<String, List<Filter>> filters = {};
  bool has(String name) => filters.containsKey(name);
  List<Filter> get(String name) => filters[name] ?? [];
  Filter? getIndex(String name, int index) {
    try {
      return filters.containsKey(name) ? filters[name]?.firstWhere((element) => element.index == index) : null;
    } catch (e) { return null; }
  }
  void remove(String name) => filters.remove(name);
  void removeIndex(String name, int index) { 
    filters[name]?.where((element) => element.index == index).forEach((element) { filters[name]!.remove(element); });
    if (filters[name] != null && filters[name]!.isEmpty) { filters.remove(name); }
  }
  int size(){
    int size = 0;
    for (var filter in filters.values) { size += filter.length; }
    return size;
  }

  void updateIndex(String fromName, int index, Filter filter) {
    filter.index = index;
    removeIndex(fromName, index);
    filters[filter.column!]!.add(filter);
  }
  void init(String name) => filters[name] = [];
  void add(String name, Filter filter) {
    if (!filters.containsKey(name)) { filters[name] = []; }
    filters[name]!.add(filter); 
  } 
  void addIndex(String name, Filter filter, int index) {
    filter.column = name;
    if (!has(name)) { filters[name] = [filter];
    } else {
      try { filters[name]?.where((element) => element.index == index).forEach((element) { element = filter; });
      } catch (e) { filters[name]!.add(filter); }
    }
    
  }
  List<Filter> sort() {
    List<Filter> orderedFilters = [];
    for (var filter in filters.values) {
      for (var f in filter) {  orderedFilters.add(f); }
    }
    orderedFilters.sort((a, b) => a.index.compareTo(b.index));
    return orderedFilters;
  }

  List<FilterRowWidget> toRow(Map<String, models.SchemaField> schema) {
    List<FilterRowWidget> rows = [];
    for (var filter in sort()) {
      rows.add(FilterRowWidget(
        schema: schema, columnName: filter.column, beforeColumn: (filter.realName ?? filter.column ?? "").split("."), 
        label: filter.label ?? filter.column, index: filter.index, 
        type: filter.type, comparator: filter.comparator, 
        connector: filter.connector, dir: filter.dir, value: filter.value));
    }
    return rows;
  }
  List<Object> serialize() {
    List<Object> rows = [];
    for (var filter in filters.values) {
      for (var f in filter) {  rows.add(f.serialize()); }
    }
    return rows;
  }
}

  void removeFilter() {
    forceFilter = true;
    filterRowsWidget = [];
    globalOffset = 0;
    noFilterRetrieval = true;
    globalNew[viewID] = "all";
    globalOrder.remove(viewID);
    globalFilter[viewID] = Filters();
  }

  void resetFilter(String columnName) {
    globalOrder[viewID]?.remove(columnName); 
    globalFilter[viewID]?.remove(columnName);  
    globalOffset = 0;
    noFilterRetrieval = true;
    List<FilterRowWidget> toRemove = filterRowsWidget.where((element) => element.columnName == columnName).toList();
    for (var filter in toRemove) { filterRowsWidget.remove(filter); }
  }

  void clearFilter() {
    filterRowsWidget = [];
    globalOffset = 0;
    globalNew = {};
    globalFilter = {}; 
    globalOrder = {};
  }

  Future<void> refreshFilter(List<Filter> fields) async {
    globalFilter[viewID] = Filters(); 
    globalOrder[viewID] = {};
    for (var field in fields) {
      globalFilter[viewID]!.add(field.column ?? "", Filter(type: field.type,
        column: field.column, index: field.index,  comparator: field.comparator, 
        value: field.value, connector: field.connector)
      );
      globalOrder[viewID]![field.column!] = field.dir;
    }
    filterRowsWidget = [];
    noFilterRetrieval = true;
    confirmCache = {};
  }

  Future<List<String>> getLabels(List<String> toogles) async {
    List<String> labels = [];
    for (var t in toogles) {
      labels.add(await getOnFlow(t));
    }
    return labels;
  }


class Filter extends SerializerDeserializer<Filter> {
  Filter({
    this.id,
    this.value,
    this.comparator = "like",
    this.index = 0,
    this.type = "text",
    this.connector = "",
    this.dir = "asc",
    this.column,
    this.label,
    this.width,
    this.realName,
  });
  String? realName;
  dynamic value;
  int index;
  String comparator;
  String connector;
  String type;
  String dir;
  int? id;
  String? column;
  String? label;
  double? width;

  @override deserialize(Map<String, dynamic> json) {
    return Filter(
    id: json.containsKey("id") ? json["id"] : null, 
    column: json.containsKey("name") ? json["name"] : null,
    width: json.containsKey("width") ? json["width"].toDouble() : null,
    label: json.containsKey("label") ? json["label"] : null,
    type: json.containsKey("type") ? json["type"] : "text",
    value: json.containsKey("value") ? json["value"] : null,
    index: json.containsKey("index") ? json["index"] : 0,
    comparator: json.containsKey("operator") && json["operator"] != null ? json["operator"] : "like",
    connector: json.containsKey("separator") && json["separator"] != null ? json["separator"] : "",
    dir: json.containsKey("dir") && json["dir"] != null ? json["dir"] : "" );
  }
  @override Map<String, dynamic> serialize() => {
    "id" : id,
    "name" : realName,
    "index" : index,
    "value" : value,
    "operator": comparator,
    "separator" : connector,
    "dir" : dir,
  };
}