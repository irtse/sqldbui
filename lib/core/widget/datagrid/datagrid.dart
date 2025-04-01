import 'dart:async';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/popup_button.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/save_button.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/column.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/row.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/value.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterSelector.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/function_math_row.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';

bool isFilter() {
  return currentView != null && globalOrder.containsKey(viewID) && globalFilter.containsKey(viewID)
  && (globalOrder[viewID]!.isNotEmpty || (globalFilter[viewID] != null && globalFilter[viewID]!.size() > 0));
}
class Value {
  bool isLink = false;
  bool readOnly = false;
  Map<String, dynamic> values = {};
  Value({ this.values = const {}, this.isLink = true, this.readOnly = false });
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
// ignore: must_be_immutable
class DatagridWidget extends StatefulWidget {
  final model.View? view; 
  bool isSelected = true;
  Map<String, dynamic> lines = {};
  GlobalKey<ViewWidgetState>? viewKey;
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};

  DatagridWidget ({ super.key, this.view, this.viewKey });
  @override
  DatagridWidgetState createState() => DatagridWidgetState();
}
bool show = true;
class DatagridWidgetState extends State<DatagridWidget> {
  List<DropdownMenuItem<String>> dpItems = <DropdownMenuItem<String>>[];

  @override Widget build(BuildContext context) {
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    var schemeItems = <DropdownMenuItem<String>>[];
    List<GridColumnWidget> columns = <GridColumnWidget>[];
    List<Value> datas = <Value>[];
    Map<String, String> links = <String, String>{};
    Map<String, model.Shallowed> contentShallowed = <String, model.Shallowed>{};
    dpItems = [];
    if (widget.view != null) {
      schema = widget.view!.schema;
      for (var item in widget.view?.items ?? []) {
        if (!widget.cache.containsKey(widget.view!.schemaName)) { widget.cache[widget.view!.schemaName]=<String,dynamic>{}; } 
        if (!widget.cache.containsKey("id")) { 
          widget.cache[widget.view!.schemaName]!["id"]=item.values["id"];
          if (item.linkPath != "") {  links[item.values['id']] = item.linkPath; }
          for (var key in item.valuesShallow.keys) { 
            contentShallowed['$key:${item.values["id"]}'] = item.valuesShallow[key]!; 
          }
        } else { widget.cache[widget.view!.schemaName]!["id"] += ",${item.values['id']}"; }
        if (!widget.view!.isEmpty && item.values.values.where((e) => e != null).toList().isEmpty) { continue; }
        datas.add(Value(values: item.values, isLink: item.linkPath != "", readOnly: currentView!.readOnly || item.readonly)); 
      }
      filterTempOrderView[viewID] = [];
      var order = realOrder();
      for (var fieldName in order) {
        columns = getColumn(columns, schemeItems, schema, fieldName, datas, order);
      }
      if (editMode[viewID] == "math") {
        columns = getColumn(columns, schemeItems, schema, null, datas, order);
      }
    }
    if ( globalOrder[viewID] == null || globalOrder[viewID]!.isEmpty ) {
      datas.sort( (a, b) =>  (b.values["id"] != null ? int.parse( b.values["id"]) : 0) -  (a.values["id"] != null ? int.parse(a.values["id"]) : 0) );
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
          filterRowsWidget[index] = FilterRowWidget(
            schema: schema, 
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
    }
    t = show ? (filterRowsWidget.length * 45 < 138 ? filterRowsWidget.length * 45 : 138) : (!(isEditMode[viewID] ?? false) ? 0 : 138);
    if (MediaQuery.of(context).size.width <= 1000) { t = 0; }
    return Column( children: [ 
      Container( 
        color: Theme.of(context).primaryColorLight, 
        constraints: const BoxConstraints(minHeight: 40), 
        width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
        child: Column( children: [
          Stack( children: [ 
            MediaQuery.of(context).size.width > 1000 ? 
            Positioned( top: 3.5, left: 32, child: (isEditMode[viewID] ?? false) ? 
                FunctionsSelectorWidget(mathAllowed: realOrder().length > 2, items: schemeItems)
              : FilterSelectorWidget(dpItems: dpItems, schemeItems: schemeItems, schema: schema, filterMain: filterMain)) 
            : Container(),
            Row( mainAxisAlignment: MainAxisAlignment.end, children : [ 
              Padding(padding: const EdgeInsets.symmetric(horizontal: 30), 
                child: Row(children: [ 
                  ...getButtons(), 
                  FilterColsPopUpWidget(key: filterColsPopUpKey, schema: schema) 
                ])) 
            ]) 
          ]), 
          MediaQuery.of(context).size.width <= 1000 ? 
              Container() 
            : Container( 
              constraints: BoxConstraints( maxHeight:  (MediaQuery.of(context).size.height > (120 + t) ? t : MediaQuery.of(context).size.height - 120).toDouble()), 
              child: SingleChildScrollView( 
                child: Column( 
                  children : [  !(isEditMode[viewID] ?? false) ? (filterRowsWidget.isEmpty ? 
                Container() : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)) : ( 
                  editMode[viewID] != "math" || functionMathRowsWidget.isEmpty ? Container() : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)
                ),  
              ...(show && !(isEditMode[viewID] ?? false) ? filterRowsWidget : (editMode[viewID] == "math" ? functionMathRowsWidget : [])) ] 
            ))) 
        ])
      ),
      Container( 
        height: MediaQuery.of(context).size.height - (120 + t) > 0 ? MediaQuery.of(context).size.height - (120 + t) : 0,
        width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
        decoration: BoxDecoration( 
          color:  Theme.of(context).highlightColor
        ), 
        child : GridWidget( 
          source: datas, 
          columns: columns,
          key: globalGridKey, 
          viewKey: widget.viewKey, 
          showCheckboxColumn: true, 
          isSelected: widget.isSelected,
          showColumnHeaderIconOnHover: true,
          contentShallowed: contentShallowed,  
          schemaID: "${currentView?.schemaID}", 
          borderColor: Theme.of(context).splashColor,
          isEnum: schema.keys.where((element) => !["name", "label", "id"].contains(element)).isEmpty,
          maxLength: realOrder().length, 
          contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
        ) 
      )
    ]);
  }

  List<Widget> getButtons() {
    var buttons = <Widget>[
      Padding( 
        padding: const EdgeInsets.only(right: 10), 
        child: AdvancedSwitch(
          initialValue: isEditMode[viewID] ?? false,
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Colors.grey,
          borderRadius:  const BorderRadius.all(Radius.circular(15)),
          activeChild: const Icon(Icons.edit, color: Colors.white, size: 15),
          inactiveChild: const Icon(Icons.remove_red_eye, color: Colors.white, size: 15),
          width: 50.0, height: 20.0, disabledOpacity: 0.5,
          onChanged: (value) => Future.delayed( const Duration(milliseconds: 500), 
            () => setState(() { 
              rects.remove(viewID);
              filterTempOrderView.remove(viewID);
              isEditMode[viewID] = value; 
            }) 
          ))) 
    ];
    if (widget.isSelected || selectedGrid.isNotEmpty) {
      if (isEditMode[viewID] ?? false) {
        buttons.add(SaveDatagridButtonWidget(selectedGrid: selectedGrid));
      } else {
        buttons.addAll([
          Padding(padding: EdgeInsets.symmetric(horizontal: 10), 
          child: Tooltip( 
            message: "delete ${currentView!.isList ? "selected " : ""}rows",
            child: InkWell( 
              onTap: () { 
                if (selectedGrid.isEmpty) { return; }
                List<String> ids = [];
                String schemaID = selectedGrid[0].schemaID;
                for (var item in selectedGrid) { 
                  ids.add(item.cells[0].value?.toString() ?? ""); 
                }
                APIService().delete("${APIConstants.genericEndpost}$schemaID?rows=${ids.join(",")}", context);
              }, 
              child: Icon(Icons.delete, color: Theme.of(context).highlightColor, size: 20)
          ))),
          PopupButtonWidget(
            tooltip: "export ${currentView!.isList ? "selected " : ""}rows",
            icon: Icons.file_download,
            widget: MappingPopUpWidget(isExport: true, format: "csv")
          )
        ]);
      }
    }
    if (currentView != null && currentView!.isList && currentView!.actions.contains("import")) {
      buttons.add(
        PopupButtonWidget(
          tooltip: "upload datas file",
          icon: Icons.upload,
          widget: MappingPopUpWidget(isExport: true, format: "csv")
        )
      );
    }
    return buttons;
  }

  List<dynamic> realOrder() {
    if (widget.view == null) { return []; }
    var schema = widget.view!.schema;
    bool isMath = isEditMode[viewID] == true && editMode[viewID] == "math";
    var order = filterTempOrderView[viewID] != null && isEditMode[viewID] == true && editMode[viewID] == "math" 
                ? filterTempOrderView[viewID]! : (filterOrderView[viewID] != null ? filterOrderView[viewID]! : widget.view!.order);
    return ["id", ...order].where( (f) {
      String type = f == null ? "float" : (f == "id" ? "integer" : schema[f]!.type);
      bool active = f == null && f == "id" ? true : schema[f]?.active ?? false;
      return f == "id" || (active && f != "description"  && !type.contains("many") && schema[f] != null
          && ((isMath && ["float", "double", "int", "money", "decimal"].contains(type)) || !isMath));
    }).toList();
  }

  List<GridColumnWidget> getColumn(List<GridColumnWidget> columns, List<DropdownMenuItem<String>> schemeItems, 
    Map<String, model.SchemaField> schema, String? fieldName, List<Value> datas, List<dynamic> order) {
    bool isEdit = isEditMode[viewID] ?? false;
    bool isNotValidCol = fieldName == null && fieldName == "id";
    String? lab = (schema[fieldName]?.label ?? "") != "" ? schema[fieldName]!.label : fieldName;
    String type = fieldName == null ? "float" : (fieldName == "id" ? "integer" : schema[fieldName]!.type);
    String label = (fieldName == "id" ? "id" : (lab ?? mathColName[viewID] ?? "total")).replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ');
    if (!isNotValidCol && !filterTempOrderView[viewID]!.contains(fieldName) && !type.contains("many")) { 
      filterTempOrderView[viewID]!.add(fieldName); 
    }
    schemeItems.add(DropdownMenuItem<String>(value: fieldName, child: Text(label, overflow: TextOverflow.ellipsis,)));
    columns.add( GridColumnWidget(
      context: context, 
      width: double.nan,
      items: schemeItems, 
      isEditMode: isEdit,
      maxLength: order.length + (isEditMode[viewID] == true && editMode[viewID] == "math" ? 1 : 0),
      borderColor: Theme.of(context).splashColor, 
      allowSorting: !(datas.isEmpty && !isFilter()) && !isEdit,
      columnName: fieldName ??  mathColName[viewID] ?? "total",
      allowFiltering: !(datas.isEmpty && !isFilter()) && !isEdit, 
      type:  schema[fieldName]?.schema != null && schema[fieldName]!.schema.isNotEmpty && type.contains("int") ? "link" : type,
      url: schema[fieldName]?.valuesPath != "" ? schema[fieldName]?.valuesPath : null,
      contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
      label: label == "id" ? GridValueWidget(fontSize: 14, icon: Icons.tag) : GridValueWidget(fontSize: 14, value: label),
    ));
    return columns;
  }
}
