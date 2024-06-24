import 'dart:async';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterSelector.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functionMathRow.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functionsSelector.dart';


bool isFilter() {
  return currentView != null && globalOrder.containsKey(viewID) && globalFilter.containsKey(viewID)
  && (globalOrder[viewID]!.isNotEmpty || (globalFilter[viewID] != null && globalFilter[viewID]!.size() > 0));
}
class Value {
  bool readOnly = false;
  Map<String, dynamic> values = {};
  Value({ this.values = const {}, this.readOnly = false });
}
bool tempRemoval = false;
bool noFilterRetrieval = false;
int globalLimit = 20;
int globalOffset = 0;
List<GridRowWidget> unselectedGrid = [];
List<GridRowWidget> selectedGrid = []; 
Map<String?, int> filterIDName = <String, int>{};
Map<String?, String> filterRestr = <String, String>{};
GlobalKey<GridWidgetState> globalGridKey = GlobalKey<GridWidgetState>();
GlobalKey<DatagridWidgetState> globalGridWidgetKey = GlobalKey<DatagridWidgetState>();
// ignore: must_be_immutable
List<FunctionMathRowWidget> functionMathRowsWidget = [];
List<FilterRowWidget> filterRowsWidget = [];
class DatagridWidget extends StatefulWidget {
  final model.View? view; 
  bool isSelected = true;
  Map<String, dynamic> lines = {};
  // List<GridRowWidget> selected = [];
  GlobalKey<ViewWidgetState>? viewKey;
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};

  DatagridWidget ({ Key? key, this.view, this.viewKey }): super(key: key);
  @override
  DatagridWidgetState createState() => DatagridWidgetState();
}
bool show = false;
class DatagridWidgetState extends State<DatagridWidget> {
  late Map<String, double> columnWidths = {};
  List<DropdownMenuItem<String>> dpItems = <DropdownMenuItem<String>>[];
  int maxCount(Map<String, model.SchemaField> schema, String mode) {
    return schema.keys.where((element) => !schema[element]!.type.contains("many") && schema[element]!.active
    && ( mode != "math" || (mode == "math" && (
          schema[element]!.type.contains("double") || schema[element]!.type.contains("float") 
          || schema[element]!.type.contains("money") || schema[element]!.type.contains("decimal") 
          || schema[element]!.type.contains("int"))))).length + 1 + (mode == "math" ? 1 : 0);
  }
  @override Widget build(BuildContext context) {
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    var schemeItems = <DropdownMenuItem<String>>[];
    List<GridColumnWidget> columns = <GridColumnWidget>[];
    List<Value> datas = <Value>[];
    Map<String, String> links = <String, String>{};
    Map<String, model.Shallowed> contentShallowed = <String, model.Shallowed>{};
    dpItems = [];
    if (widget.view != null) {
      if (widget.view!.items.isNotEmpty) {
        for (var item in widget.view!.items) {
          if (!widget.cache.containsKey(widget.view!.schemaName)) { widget.cache[widget.view!.schemaName]=<String,dynamic>{}; } 
          if (!widget.cache.containsKey("id")) { widget.cache[widget.view!.schemaName]!["id"]=item.values["id"];
          } else { widget.cache[widget.view!.schemaName]!["id"] += ",${item.values['id']}"; }
          if (item.values.containsKey("id") && item.linkPath != "") {  links[item.values['id']] = item.linkPath; }
          if (item.values.containsKey("id") && item.valuesShallow.isNotEmpty) {
              for (var key in item.valuesShallow.keys) { contentShallowed['$key:${item.values["id"]}'] = item.valuesShallow[key]!; }
          }
          if (!widget.view!.isEmpty && item.values.values.where((e) => e != null).toList().isEmpty) { continue; }
          datas.add(Value(values: item.values, readOnly: currentView!.readOnly || item.readonly)); 
        }
      }
      schema = widget.view!.schema;
      var order = filterTempOrderView[viewID] != null ? filterTempOrderView[viewID]! 
                  : (filterOrderView[viewID] != null ? filterOrderView[viewID]! : widget.view!.order);
      filterTempOrderView[viewID] = [];
      for (var fieldName in ["id", ...order]) {
        if ((schema[fieldName] == null && fieldName != "id")) { continue; }
        var lab = schema[fieldName]?.label != null ? schema[fieldName]!.label : fieldName;
        var label = fieldName == "id" ? "id" : lab;
        var type = fieldName == "id" ? "integer" : schema[fieldName]!.type;
        var sch = fieldName == "id" ? null : schema[fieldName]!.schema;
        var active = fieldName == "id" ? true : schema[fieldName]!.active;
        if (type.contains("many") || !active 
        || (isEditMode[viewID] == true && editMode[viewID] == "math" && !(type.contains("double") || type.contains("float") 
        || type.contains("money") || type.contains("decimal") || type.contains("int")))) { continue; }
        if (fieldName != "id" && !filterTempOrderView[viewID]!.contains(fieldName)) {filterTempOrderView[viewID]!.add(fieldName); }
        
        String? url;
        if (schema[fieldName]?.valuesPath != "") { url = schema[fieldName]?.valuesPath; }
        schemeItems.add(DropdownMenuItem<String>(value: fieldName, child: Text(label, overflow: TextOverflow.ellipsis,)));
        columns.add(GridColumnWidget(context: context, items: schemeItems, url: url,
              type: sch != null && sch.isNotEmpty && type.contains("int") ? "link" : type,
              contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
              width: columnWidths.containsKey(fieldName) ? columnWidths[fieldName]! : double.nan,
              borderColor: Theme.of(context).splashColor, columnName: fieldName, 
              maxLength: maxCount(schema, isEditMode[viewID] == null ? "all" : editMode[viewID] ?? "all"),
              allowSorting: !(datas.isEmpty && !isFilter()) && !(isEditMode[viewID] ?? false), 
              allowFiltering: !(datas.isEmpty && !isFilter()) && !(isEditMode[viewID] ?? false),
              label: label == "id" ? GridValueWidget(fontSize: 15, icon: Icons.tag) : GridValueWidget(fontSize: 15, value: label.replaceAll('db', '').replaceAll('_', ' ').replaceAll('id', ''),),
          ));
      }
      if (editMode[viewID] == "math") {
        columns.add(GridColumnWidget(context: context, items: schemeItems,
              type: "float", width: double.nan,
              contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
              borderColor: Theme.of(context).splashColor, columnName: mathColName[viewID] ?? "total", maxLength: maxCount(schema, 'math'),
              allowSorting: !(datas.isEmpty && !isFilter()) && !(isEditMode[viewID] ?? false), 
              allowFiltering: !(datas.isEmpty && !isFilter()) && !(isEditMode[viewID] ?? false),
              label: GridValueWidget(fontSize: 15, value: mathColName[viewID] ?? "total"),
          ));
      }
    }
    if (globalOrder[viewID] == null || globalOrder[viewID]!.isEmpty ) {
      datas.sort( (a, b) =>  (b.values["id"] != null ? int.parse( b.values["id"]) : 0) -  (a.values["id"] != null ? int.parse(a.values["id"]) : 0) );
    } 
    var buttons = <Widget>[
      Padding( padding: const EdgeInsets.only(right: 10), 
        child: AdvancedSwitch(
              initialValue: isEditMode[viewID] ?? false,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey,
              borderRadius:  const BorderRadius.all(Radius.circular(15)),
              activeChild: const Icon(Icons.edit, color: Colors.white, size: 15),
              inactiveChild: const Icon(Icons.remove_red_eye, color: Colors.white, size: 15),
              width: 50.0, 
              height: 20.0, 
              disabledOpacity: 0.5,
              onChanged: (value) => Future.delayed( const Duration(milliseconds: 500), 
                () => setState(() { 
                  rects.remove(viewID);
                  filterTempOrderView.remove(viewID);
                  isEditMode[viewID] = value; 
                }) )))
    ];
    if (widget.isSelected || selectedGrid.isNotEmpty) {
      if ((isEditMode[viewID] ?? false)) { buttons.add(SaveDatagridButtonWidget()); }
      if (!(isEditMode[viewID] ?? false)) {
        buttons.add(Column( children: [ PopupMenuButton(
          constraints: BoxConstraints.tightFor( width: MediaQuery.of(context).size.width / 1.1),
          color: Theme.of(context).secondaryHeaderColor, tooltip:  "export ${currentView!.isList ? "selected " : ""}rows",
          icon: Icon(size: 20, Icons.file_download, color: Theme.of(context).highlightColor), onSelected: (value) { },
          itemBuilder: (BuildContext bc) {
            return [ PopupMenuItem(enabled: false, child: StatefulBuilder(  builder: (BuildContext context, StateSetter setState) {
                    return MappingPopUpWidget(isExport: true, format: "csv"); })) ]; 
        }) ]));
      }
    }
    if (currentView != null && currentView!.isList && currentView!.actions.contains("import")) {
        buttons.add(Column( children: [ PopupMenuButton(
          constraints: BoxConstraints.tightFor( width: MediaQuery.of(context).size.width / 1.1),
          color: Theme.of(context).secondaryHeaderColor, tooltip: "upload datas file",
          icon: Icon(size: 20, Icons.upload, color: Theme.of(context).highlightColor),
          onSelected: (value) { },
          itemBuilder: (BuildContext bc) {
            return [ PopupMenuItem(enabled: false, child: StatefulBuilder( builder: (BuildContext context, StateSetter setState) {
              return MappingPopUpWidget(isExport: false, format: "csv"); })) ]; 
          }) ]));
      }
    var index = 0;
    Filters? filterMain = globalFilter[viewID];
    var t = 0;
    if (!(isEditMode[viewID] ?? false)) {
      if (filterRestr[viewID] != null && !tempRemoval) {
        filterRowsWidget = filterMain?.toRow(schemeItems, schema) ?? [];
      } else if (tempRemoval) { tempRemoval = false; }
      for (var i in filterRowsWidget) { 
        if (filterRowsWidget.length - 1 > index && i.connector == "") { 
          filterRowsWidget[index] = FilterRowWidget(schema: schema, 
                                                    items: schemeItems, 
                                                    index: i.index, 
                                                    connector: "and", 
                                                    label: i.label, 
                                                    type: i.type, 
                                                    columnName: i.columnName, 
                                                    value: i.value, 
                                                    comparator: i.comparator, 
                                                    dir: i.dir);
        }
        index++;
      }
      t = show ? (filterRowsWidget.length * 45 < 138 ? filterRowsWidget.length * 45 : 138) : 0;
    } else if (editMode[viewID] == "math") {
      t = (functionMathRowsWidget.length * 45 < 138 ? functionMathRowsWidget.length * 45 : 138);
    }
    if (MediaQuery.of(context).size.width <= 1000) { t = 0; }
    return Column( children: [ Container( 
      color: Theme.of(context).primaryColorLight, 
      constraints: const BoxConstraints(minHeight: 40), 
      width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
      child: Column( children: [ Stack( 
        children: [ MediaQuery.of(context).size.width > 1000 ? 
          Positioned( top: 3.5, left: 32, child: (isEditMode[viewID] ?? false) ? FunctionsSelectorWidget(mathAllowed: maxCount(schema, "math") > 2, items: schemeItems)
            : FilterSelectorWidget(dpItems: dpItems, schemeItems: schemeItems, schema: schema, filterMain: filterMain)) 
          : Container(),
          Row( mainAxisAlignment: MainAxisAlignment.end, children : [ Padding(padding: const EdgeInsets.symmetric(horizontal: 30), 
              child: Row(children: [ ...buttons, FilterColsPopUpWidget(key: filterColsPopUpKey, schema: schema) ])) ]) 
        ]), 
        MediaQuery.of(context).size.width <= 1000 ? Container() : Container( constraints: BoxConstraints( maxHeight:  (MediaQuery.of(context).size.height > (120 + t) ? t : MediaQuery.of(context).size.height - 120).toDouble()), 
          child: SingleChildScrollView( child: Column( children : [  !(isEditMode[viewID] ?? false) ? (filterRowsWidget.isEmpty ? 
            Container() : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)) : ( 
              editMode[viewID] != "math" || functionMathRowsWidget.isEmpty ? Container() : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)),  
            ...(show && !(isEditMode[viewID] ?? false) ? filterRowsWidget : (editMode[viewID] == "math" ? functionMathRowsWidget : [])) ] ))) ])),
    Container( 
      height: MediaQuery.of(context).size.height - (120 + t) > 0 ? MediaQuery.of(context).size.height - (120 + t) : 0,
      width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
      decoration: BoxDecoration( color:  Theme.of(context).highlightColor), child : GridWidget( key: globalGridKey, isSelected: widget.isSelected,
        schemaID: "${currentView?.schemaID}", isEnum: schema.keys.where((element) => !["name", "label", "id"].contains(element)).isEmpty,
        contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
        maxLength: maxCount(schema, isEditMode[viewID] == null ? "all" : editMode[viewID] ?? "all"), 
        contentShallowed: contentShallowed,   borderColor: Theme.of(context).splashColor,
        viewKey: widget.viewKey, showCheckboxColumn: true, showColumnHeaderIconOnHover: true, source: datas, columns: columns,
      ) ),]);
  }

  List<String> order(List<String>mainOrder, int index, String fieldName) {
    if(mainOrder[index] == "") { mainOrder[index] = fieldName; 
    } else { mainOrder = order(mainOrder, index + 1, fieldName); }
    return mainOrder;
  }
}
class SaveDatagridButtonWidget extends StatefulWidget {
  SaveDatagridButtonWidget ({ Key? key}): super(key: key);
  @override
  SaveDatagridButtonWidgetState createState() => SaveDatagridButtonWidgetState();
}
class SaveDatagridButtonWidgetState extends State<SaveDatagridButtonWidget> {
  bool change = false;
  @override Widget build(BuildContext context) {
    return change ? const Padding( padding: EdgeInsets.symmetric(horizontal: 10), 
      child: SpinKitCircle(color: Colors.white, size: 20.0,)) : IconButton(onPressed: () async {
        setState(() { change = true; });
        for (var i in selectedGrid) {
          if (i.cells.isNotEmpty) {
            Map<String, dynamic> body = {};
            for (var j in i.widgetCells) {
              if (j.cell.columnName != "id" && detectChanges["${i.cells.first.value}:${j.cell.columnName}"] != null 
              && detectChanges["${i.cells.first.value}:${j.cell.columnName}"]!.currentState != null
              && detectChanges["${i.cells.first.value}:${j.cell.columnName}"]!.currentState!.validate()) {
                body[j.cell.columnName] = detectChanges["${i.cells.first.value}:${j.cell.columnName}"]?.currentState!.value;
              }
            }
            if (body.isNotEmpty && i.cells.isNotEmpty) {
              await APIService().put<model.View>(
                currentView!.actionPath.replaceAll("rows=all", "rows=${i.cells.first.value}"), body, null);
            }
          }
        }
        globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
        setState(() { change = false; });
      }, icon: Icon(Icons.save, color: Theme.of(context).highlightColor, size: 20));
  }
}