import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/column.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/value.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class MainGridWidget extends StatefulWidget {
  List<dynamic>? forceOrder;
  int max = 5;
  var schemeItems = <DropdownMenuItem<String>>[];
  final model.View? view; 
  bool isSelected = true;
  Map<String, String> links = {};
  bool subTable = false;
  int subSize;
  double subWidthSize;
  GlobalKey<ViewWidgetState>? viewKey;
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};

  MainGridWidget ({ super.key, this.view, this.viewKey, required this.subWidthSize, this.forceOrder, this.max = 5,
    this.links = const {}, this.isSelected = false, required this.subSize, this.subTable = false });
  @override
  MainGridWidgetState createState() => MainGridWidgetState();
}
bool show = true;
class MainGridWidgetState extends State<MainGridWidget> {
  @override Widget build(BuildContext context) {
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    List<GridColumnWidget> columns = <GridColumnWidget>[];
    List<Value> datas = <Value>[];
    Map<String, model.Shallowed> contentShallowed = <String, model.Shallowed>{};
    if (widget.view != null) {
      schema = widget.view!.schema;
      for (var item in (widget.view?.items ?? [] as List<model.Item>)) {
        if (!widget.cache.containsKey(widget.view!.schemaName)) { widget.cache[widget.view!.schemaName]=<String,dynamic>{}; } 
        if (!widget.cache.containsKey("id")) { 
          widget.cache[widget.view!.schemaName]!["id"]=item.values["id"];
          if (item.linkPath != "") {  widget.links[item.values['id']] = item.linkPath; }
          for (var key in item.valuesShallow.keys) { 
            contentShallowed['$key:${item.values["id"]}'] = item.valuesShallow[key]!; 
          }
        } else { widget.cache[widget.view!.schemaName]!["id"] += ",${item.values['id']}"; }
        if (!widget.view!.isEmpty && item.values.values.where((e) => e != null).toList().isEmpty) { continue; }
        datas.add(Value(
          dataRef: item.dataRef,
          schemaID: item.schemaID,
          schema: schema,
          valuesMany: item.valuesMany,
          isNew: item.news,
          isDraft: item.isDraft,
          cellID: item.values["id"],
          values: item.values, 
          sharing: item.sharing,
          isLink: item.linkPath != "", 
          readOnly: currentView!.readOnly || item.readonly)); 
      }
      var order = realOrder(widget.view, widget.subTable, false, widget.forceOrder, widget.max);
      print(widget.view?.schema.keys);
      for (var fieldName in order) {
          columns = getColumn(columns, widget.schemeItems, schema, fieldName, datas, order);
      }
    }
    return Container( 
        height: widget.subTable ? null : currentHeigth - (120 + widget.subSize) > 0 ? 
          currentHeigth - (120 + widget.subSize) : 0,
        width: (currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0),
        decoration: BoxDecoration( 
          color:  Theme.of(context).highlightColor
        ), 
        child : GridWidget( 
          source: datas, 
          columns: columns,
          key: globalGridKey, 
          viewKey: widget.viewKey, 
          showCheckboxColumn: !widget.subTable, 
          isSelected: widget.isSelected,
          showColumnHeaderIconOnHover: true,
          contentShallowed: contentShallowed,  
          schemaID: "${currentView?.schemaID}", 
          borderColor: Theme.of(context).splashColor,
          isEnum: schema.keys.where((element) => !["name", "label", "id"].contains(element)).isEmpty,
          maxLength: realOrder(widget.view, widget.subTable, false, widget.forceOrder, widget.max).length, 
          contextWidth: currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0,
        ) 
      );
  }
  

  List<GridColumnWidget> getColumn(List<GridColumnWidget> columns, List<DropdownMenuItem<String>> schemeItems, 
    Map<String, model.SchemaField> schema, String? fieldName, List<Value> datas, List<dynamic> order) {
    bool isEdit = isEditMode[viewID] ?? false;
    bool isNotValidCol = fieldName == null && fieldName == "id";
    String? lab = (schema[fieldName]?.label ?? "") != "" ? schema[fieldName]!.label : fieldName;
    String type = fieldName == null ? "float" : (fieldName == "id" ? "integer" : schema[fieldName]!.type);
    String label = (fieldName == "id" ? "id" : (lab ?? mathColName[viewID] ?? TranslateConstants.total.toLowerCase())).replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ');
    if (!isNotValidCol && !(filterTempOrderView[viewID]?.contains(fieldName) ?? true)) { 
      filterTempOrderView[viewID]?.add(fieldName); 
    }

    var realLabel = fastTranslation[viewID ?? ""]?[label] ?? label;
    schemeItems.add(DropdownMenuItem<String>(value: fieldName, child: Text(
      realLabel.toLowerCase(), overflow: TextOverflow.ellipsis,)));
    columns.add( GridColumnWidget(
        context: context, 
        width: double.nan,
        items: schemeItems, 
        isEditMode: isEdit,
        maxLength: order.length + (isEditMode[viewID] == true && editMode[viewID] == TranslateConstants.math.toLowerCase() ? 1 : 0),
        borderColor: Theme.of(context).splashColor, 
        allowSorting: !(datas.isEmpty && !isFilter()) && !isEdit,
        columnName: fieldName ??  mathColName[viewID] ?? TranslateConstants.total.toLowerCase(),
        allowFiltering: !(datas.isEmpty && !isFilter()) && !isEdit, 
        type:  schema[fieldName]?.schema != null && schema[fieldName]!.schema.isNotEmpty && type.contains("int") ? "link" : type,
        url: schema[fieldName]?.valuesPath != "" ? schema[fieldName]?.valuesPath : null,
        contextWidth: currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0,
        label: label == "id" ? GridValueWidget(fontSize: 13, icon: Icons.tag) : GridValueWidget(fontSize: 13, value: realLabel),
      ));
    return columns;
  }
}

Map<String,String> realOrderMap(model.View? view, bool subtable) {
    if (view == null) { return {}; }
    var schema = view.schema;
    bool isMath = isEditMode[viewID] == true && editMode[viewID] == TranslateConstants.math.toLowerCase();
    List<String> seen = [];
    if (!(filterTempOrderView[viewID] != null && isEditMode[viewID] == true && editMode[viewID] == TranslateConstants.math.toLowerCase())
    && filterOrderView[viewID] == null) {
      filterTempOrderView[viewID] = view.order.sublist(0, view.order.length < 5 ? view.order.length : 5);
    }
    var order = filterTempOrderView[viewID] ?? filterOrderView[viewID] ?? view.order;
    List<dynamic> o = [  ...order.where( (e) => e != "id")].where( (f) {
      String type = f == null ? "float" : (f == "id" ? "integer" : schema[f]?.type ?? "varchar");
      bool active = f == null && f == "id" ? true : schema[f]?.active ?? false;
      bool ok = (f == "id" && !subtable) || !seen.contains(f) && (active && f != "description" && schema[f] != null
          && ((isMath && ["float", "double", "int", "money", "decimal"].contains(type)) || !isMath));
      seen.add(f);
      return ok;
    }).toList();
    if (filterTempID[viewID] ?? false) {
      o = ["id", ...o];
    }
    Map<String,String> newOrder = {};
    for (var oo in o) {
      newOrder[oo] = view.schema[oo]?.label ?? oo;
    }
    return newOrder;
  }

List<dynamic> realOrder(model.View? view, bool subtable, bool forceMath, List<dynamic>? forceOrder, int max) {
    if (view == null) { return []; }
    var schema = view.schema;
    bool isMath = forceMath || (isEditMode[viewID] == true && editMode[viewID] == TranslateConstants.math.toLowerCase());
    List<String> seen = [];
    if (!(filterTempOrderView[viewID] != null && isEditMode[viewID] == true && editMode[viewID] == TranslateConstants.math.toLowerCase())
    && filterOrderView[viewID] == null) {
      filterTempOrderView[viewID] = (forceOrder ?? view.order).sublist(0, (forceOrder ?? view.order).length < max ? (forceOrder ?? view.order).length : max);
    }
    var order = forceOrder ?? filterTempOrderView[viewID] ?? filterOrderView[viewID] ?? view.order;
    List<dynamic> o = [  ...order.where( (e) => e != "id")].where( (f) {
      
      String type = f == null ? "float" : (f == "id" ? "integer" : schema[f]?.type ?? "varchar");
      bool ok = (f == "id" && !subtable) || !seen.contains(f) && (f != "description" && schema[f] != null
          && ((isMath && ["float", "double", "int", "money", "decimal"].contains(type)) || !isMath));
      seen.add(f);
      return !(schema[f]?.hidden ?? false) && (ok);
    }).toList();
    if (filterTempID[viewID] ?? false) {
      o = ["id", ...o];
    }
    return o;
  }