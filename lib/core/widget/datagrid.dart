import 'dart:async';
import 'dart:developer' as developer;
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/utils/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/utils/filterRow.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';

bool isDelete = false;
Map<String, bool> filterRestrLoad = <String, bool>{};
Map<String, String> filterRestr = <String, String>{};
int globalLimit = 20;
int globalOffset = 0;
Map<String, int> filterIDName = <String, int>{};
GlobalKey<DatagridWidgetState> globalGridWidgetKey = GlobalKey<DatagridWidgetState>();
GlobalKey<GridWidgetState> globalGridKey = GlobalKey<GridWidgetState>();
// ignore: must_be_immutable
class DatagridWidget extends StatefulWidget {
  List<String> selected = [];
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};
  final model.View? view; 
  List<Widget> filterWidget = <Widget>[];
  GlobalKey<ViewWidgetState>? viewKey;
  DatagridWidget ({ Key? key, this.view, this.viewKey }): super(key: key);
  @override
  DatagridWidgetState createState() => DatagridWidgetState();
}
class DatagridWidgetState extends State<DatagridWidget> {
  Map<String, List<model.Filter>> filterConfs = {};
  late Map<String, double> columnWidths = {};
  List<DropdownMenuItem<String>> dpItems = <DropdownMenuItem<String>>[];
  int maxCount(Map<String, model.SchemaField> schema) {
    var count = 1;
    for (var fieldName in schema.keys) {
      if (schema[fieldName]!.type.contains("many") || !schema[fieldName]!.active) { continue; }
      count++;
    }
    return count;
  }
  @override Widget build(BuildContext context) {
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    var schemeItems = <DropdownMenuItem<String>>[];
    List<GridColumnWidget> columns = <GridColumnWidget>[];
    List<Map<String, dynamic>> datas = <Map<String, dynamic>>[];
    Map<String, String> links = <String, String>{};
    Map<String, model.Shallowed> contentShallowed = <String, model.Shallowed>{};
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
          datas.add(item.values); 
        }
      }
      schema = widget.view!.schema;
      columns.add(GridColumnWidget(context: context,
              width: columnWidths.containsKey("id") ? columnWidths["id"]! : double.nan,
              allowSorting: !(datas.isEmpty && !isFilter()),
              allowFiltering: !(datas.isEmpty && !isFilter()),
              columnName: "id",
              type: "integer",
              contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
              maxLength: maxCount(schema),
              borderColor: Theme.of(context).splashColor,
              label: GridValueWidget(fontSize: 15, icon: Icons.tag)
          ));
      // if (globalFilter[viewID] != null && globalFilter[viewID]!.isNotEmpty) { widget.filterWidget = []; }
      for (var fieldName in currentView!.order) {
        if (schema[fieldName]!.type.contains("many") || !schema[fieldName]!.active) { continue; }
        schemeItems.add(DropdownMenuItem<String>(value: schema[fieldName]!.label, child: Text(schema[fieldName]!.label, overflow: TextOverflow.ellipsis,)));
        if (!isDelete && widget.filterWidget.isEmpty && viewID != null && globalFilter[viewID] != null && globalFilter[viewID]!.containsKey(fieldName)) {
          for (var filter in  globalFilter[viewID]![fieldName]!) {
            if (widget.filterWidget.isEmpty) { widget.filterWidget.add(Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)); }
            widget.filterWidget.add(FilterRowWidget(datagrid: this, index: widget.filterWidget.length, 
            items: schemeItems, columnName: fieldName, value: filter.value, 
            connector: filter.connector ?? "", dir: globalOrder[viewID]!.containsKey(fieldName) ? globalOrder[viewID]![fieldName] ?? "asc" : "asc"));
          }
        }
        isDelete = false;
        columns.add(GridColumnWidget(context: context,
              type: schema[fieldName]!.type,
              contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
              width: columnWidths.containsKey(fieldName) ? columnWidths[fieldName]! : double.nan,
              borderColor: Theme.of(context).splashColor,
              allowSorting: !(datas.isEmpty && !isFilter()),
              allowFiltering: !(datas.isEmpty && !isFilter()),
              columnName: fieldName,
              maxLength: maxCount(schema),
              label: GridValueWidget(fontSize: 15, value: schema[fieldName]!.label.replaceAll('db', '').replaceAll('_', ' ').replaceAll('id', ''),),
          ));
      }
    }
    if (globalOrder[viewID] == null || globalOrder[viewID]!.isEmpty ) {
      datas.sort( (a, b) =>  (b["id"] != null ? int.parse( b["id"]) : 0) -  (a["id"] != null ? int.parse(a["id"]) : 0) );
    } 
    var buttons = <Widget>[];
    if (currentView != null && currentView!.isList && currentView!.actions.contains("import")) {
      buttons.add(Column( children: [ PopupMenuButton(
          constraints: BoxConstraints.tightFor( width: MediaQuery.of(context).size.width / 1.1),
          color: Theme.of(context).secondaryHeaderColor, tooltip: "upload datas file",
          icon: Icon(size: 20, Icons.upload, color: Theme.of(context).highlightColor),
          onSelected: (value) { },
          itemBuilder: (BuildContext bc) {
            return [
              PopupMenuItem(enabled: false, child: StatefulBuilder( builder: (BuildContext context, StateSetter setState) {
                    return MappingPopUpWidget(isExport: false, format: "csv");
            })) ]; 
          }) ]));
    }
    buttons.add(Column( children: [ PopupMenuButton(
          constraints: BoxConstraints.tightFor( width: MediaQuery.of(context).size.width / 1.1),
          color: Theme.of(context).secondaryHeaderColor, tooltip:  "export ${currentView!.isList ? "selected " : ""}rows",
          icon: Icon(size: 20, Icons.file_download, color: Theme.of(context).highlightColor),
          onSelected: (value) { },
          itemBuilder: (BuildContext bc) {
            return [
              PopupMenuItem(enabled: false, child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return MappingPopUpWidget(isExport: true, format: "csv");
                  })) ]; 
        }) ]));
    var len = widget.filterWidget.isNotEmpty ? widget.filterWidget.length - 1 : 0;
    var t = (len * 45 < 138 ? len * 45 : 138);
    return Column( children: [
    Container( color: Theme.of(context).primaryColorLight, constraints: const BoxConstraints(minHeight: 40), 
      width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
      child: Column( children: [ Stack( children: [ 
        MediaQuery.of(context).size.width > 1000 ? Positioned( top: 3.5, left: 32, child: Row( children: [ 
        Padding( padding: const EdgeInsets.only(right: 10), child : Icon(Icons.filter_alt, color: Theme.of(context).splashColor, size: 20)),
        FutureBuilder(future: APIService().get<model.Shallowed>("${currentView!.filterPath}&is_view=false", true, null), 
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.Shallowed>> snapshot) {
          if (snapshot.hasData && snapshot.data!.data != null && snapshot.data!.data!.isNotEmpty) {
            for (var i in snapshot.data!.data!) { 
              filterIDName[i.label!] = i.id!;
              filterConfs[i.label!] = i.fields;
              print(" FILTER $filterConfs");
              if (i.selected && !isDelete) { filterRestr[viewID!] = i.label!; }
              if (i.selected && viewID != null && filterRestr[viewID!] == i.label!) { 
                globalFilter[viewID!] = <String, List<Filter>>{};
                for (var field in i.fields) {
                  if (!globalFilter[viewID!]!.containsKey(field.name)) { globalFilter[viewID!]![field.name!] = []; }
                  globalFilter[viewID!]![field.name]!.add(Filter(value: field.value, connector: field.separator));
                  if (!globalOrder.containsKey(viewID)) { globalOrder[viewID!] = <String, String>{}; }
                  globalOrder[viewID!]![field.name!] = field.dir ?? "asc";
                }
                if (globalOrder[viewID] == null || globalOrder[viewID]!.isEmpty ) {
                  datas.sort( (a, b) =>  (b["id"] != null ? int.parse( b["id"]) : 0) -  (a["id"] != null ? int.parse(a["id"]) : 0) );
                } 
                if (widget.filterWidget.isEmpty && !(filterRestr.containsKey(viewID) && (filterRestr[viewID] == i.label)))  { 
                  for (var fieldName in currentView!.order) {
                    if (!globalFilter[viewID]!.containsKey(fieldName) || schema[fieldName]!.type.contains("many") || !schema[fieldName]!.active) { continue; }
                    for (var filter in globalFilter[viewID]![fieldName]!) {
                      if(widget.filterWidget.isEmpty) { widget.filterWidget.add(Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)); }
                      widget.filterWidget.add(FilterRowWidget(datagrid: this, index: widget.filterWidget.length, items: schemeItems, columnName: fieldName, value: filter.value, 
                        connector: filter.connector ?? "", dir: globalOrder[viewID]!.containsKey(fieldName) ? globalOrder[viewID]![fieldName] ?? "asc" : "asc"));
                    }
                  }
                  filterRestrLoad[viewID!] = true;
                  Future.delayed(const Duration(seconds: 1), () => setState(() {}));  
                }
              }
              if (dpItems.where((element) => element.value == i.label).isEmpty) {
                dpItems.add(DropdownMenuItem<String>(value: i.label, child: Text(i.label!, overflow: TextOverflow.ellipsis,),));
              }
            }
          }
          return SizedBox( height: 25,
            width: (MediaQuery.of(context).size.width - menuSize) / 3, child: DropdownButtonFormField<String>( items: dpItems, 
                    value: filterRestr[viewID!],
                    hint: Text("select an existing filter...", overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    onChanged: (value) async {
                      if (value != null) { 
                        filterRestr[viewID!] = value; 
                        filterRestrLoad[viewID!] = true;
                        widget.filterWidget = [];
                      }
                      APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[value]}"), <String, dynamic> { "is_selected" : true }, null).then(
                        (value) => globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true),);
                    }, dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration(
                      suffixIconColor: Theme.of(context).primaryColor,  errorStyle: const TextStyle(height: -2),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true,
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ),
                    validator: (String? value) { return null; }));
        }), 
        widget.filterWidget.isEmpty ? Container() : Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: "apply filter", style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.check, size: 17, color: Theme.of(context).highlightColor, ),
          onPressed: () { 
            if (viewID != null && formRowFilterKeys.containsKey(viewID)) {
              for (var key in formRowFilterKeys[viewID]!) {
                if (key.currentState != null && key.currentState!.validate()) { 
                  key.currentState!.save(); 
                  globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                }
              }
            }
          })),
        widget.filterWidget.isEmpty ? Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: "new filter", style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.add, size: 17, color: Theme.of(context).highlightColor, ),
          onPressed: () {  setState(() { 
            widget.filterWidget.add(Divider(height: 1, color: Theme.of(context).secondaryHeaderColor));
            widget.filterWidget.add(FilterRowWidget(datagrid: this, index: widget.filterWidget.length, items: schemeItems)); 
          }); })) : Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: "save filter", style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.save, size: 18, color: Theme.of(context).highlightColor, ),
          onPressed: () async { 
            if (viewID != null && formRowFilterKeys.containsKey(viewID)) {
                for (var key in formRowFilterKeys[viewID]!) {
                  if (key.currentState != null) { 
                    if (key.currentState!.validate()) {key.currentState!.save();} else { return; }
                  } 
                }
              }
            List<dynamic> fields = [];
            for (var filter in widget.filterWidget) {
              if (filter is FilterRowWidget) {
                fields.add(model.Filter(name: filter.columnName, value: filter.value, dir: filter.dir, opera: "like", separator: filter.connector).serialize());     
              }
            }
            if (viewID != null && filterRestr.containsKey(viewID) && filterRestr[viewID] != null) {
              APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[filterRestr[viewID]]}"), 
                { "link" : widget.view?.schemaName, "filter_fields" : fields }, context).then((value){
                  if (value.data != null && viewID != null && value.data!.isNotEmpty) {
                    var fields = value.data![0].fields;
                    for (var field in fields) {
                      if (!globalFilter.containsKey(viewID)) { globalFilter[viewID!] = <String, List<Filter>>{}; }
                      if (!globalFilter[viewID!]!.containsKey(field.name)) { globalFilter[viewID!]![field.name!] = []; }
                      globalFilter[viewID!]![field.name]!.add(Filter(value: field.value, connector: field.separator));
                      if (!globalOrder.containsKey(viewID)) { globalOrder[viewID!] = <String, String>{}; }
                      globalOrder[viewID!]![field.name!] = field.dir ?? "asc";
                    }
                    globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                  }
                });
            } else { 
            APIService().post<model.Shallowed>(currentView!.filterPath, 
            { "link" : widget.view?.schemaName, "is_selected" : true, "filter_fields" : fields }, context).then((value) {
                if (value.data != null && viewID != null && value.data!.isNotEmpty) {
                  var fields = value.data![0].fields;
                  for (var field in fields) {
                    if (!globalFilter.containsKey(viewID)) { globalFilter[viewID!] = <String, List<Filter>>{}; }
                    if (!globalFilter[viewID!]!.containsKey(field.name)) { globalFilter[viewID!]![field.name!] = []; }
                    globalFilter[viewID!]![field.name]!.add(Filter(value: field.value, connector: field.separator));
                    if (!globalOrder.containsKey(viewID)) { globalOrder[viewID!] = <String, String>{}; }
                    globalOrder[viewID!]![field.name!] = field.dir ?? "asc";
                  }
                  globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                }
              }
            ); }
          })),
        viewID == null || !filterRestr.containsKey(viewID) ? Container() : Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: "delete filter", style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon(Icons.delete, size: 18, color: Theme.of(context).highlightColor, ),
          onPressed: () { setState(() { 
            APIService().delete(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[filterRestr[viewID]]}"), context).then((value) {
              widget.filterWidget = []; 
              isDelete = true;
              filterRestr.remove(viewID);
              if (viewID != null && globalFilter.containsKey(viewID)) { 
                globalOrder.remove(viewID);
                globalFilter.remove(viewID);
                globalNew = false;
                globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
              }
            },); 
          });  })) ,
        widget.filterWidget.isEmpty ? Container() : Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: viewID != null && globalFilter.containsKey(viewID) && globalFilter[viewID!]!.isNotEmpty ? "reset filter" : "close new filter", style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( viewID != null && globalFilter.containsKey(viewID) && globalFilter[viewID!]!.isNotEmpty ? Icons.filter_alt_off : Icons.close, size: 18, color: Theme.of(context).highlightColor, ),
          onPressed: () async { 
            print(filterRestr[viewID]);
            if (filterRestr[viewID] == null || filterRestr[viewID] == "") {
              widget.filterWidget = []; 
                dpItems = [];
                filterRestr.remove(viewID);
                if (viewID != null && globalFilter.containsKey(viewID)) { 
                  globalOrder.remove(viewID);
                  globalFilter.remove(viewID);
                  globalNew = false;
                }
                globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
              return;
            }
            APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[filterRestr[viewID]]}"), <String, dynamic> { "is_selected" : false }, null).then((value) {
              setState(() { 
                widget.filterWidget = []; 
                dpItems = [];
                filterRestr.remove(viewID);
                if (viewID != null && globalFilter.containsKey(viewID)) { 
                  globalOrder.remove(viewID);
                  globalFilter.remove(viewID);
                  globalNew = false;
                }
                Future.delayed(const Duration(seconds: 1), () => globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true));
            },);   
          });  })),
      ] )) : Container(),
      Row( mainAxisAlignment: MainAxisAlignment.end, children : [ Padding(padding: const EdgeInsets.symmetric(horizontal: 30), 
          child: Row(children: [ ...buttons, FilterColsPopUpWidget(key: filterColsPopUpKey, schema: schema) ])) ]) ]), 
          Container( constraints: BoxConstraints( maxHeight:  (MediaQuery.of(context).size.height > (120 + t) ? t : MediaQuery.of(context).size.height - 120).toDouble()), 
          child: SingleChildScrollView( child: Column( children : widget.filterWidget ))) ])),
    Container( 
      height: MediaQuery.of(context).size.height - (120 + t) > 0 ? MediaQuery.of(context).size.height - (120 + t) : 0,
      width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
      decoration: BoxDecoration( color:  Theme.of(context).highlightColor), child : GridWidget(
          key: globalGridKey, links: links, isEnum: schema.keys.where((element) => !["name", "label", "id"].contains(element)).isEmpty,
          contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
          maxLength: maxCount(schema), contentShallowed: contentShallowed,   borderColor: Theme.of(context).splashColor,
          viewKey: widget.viewKey, showCheckboxColumn: true, showColumnHeaderIconOnHover: true,
          source: datas, columns: columns,
      ) ),]);
  }

  List<String> order(List<String>mainOrder, int index, String fieldName) {
    if(mainOrder[index] == "") { mainOrder[index] = fieldName; 
    } else { mainOrder = order(mainOrder, index + 1, fieldName); }
    return mainOrder;
  }
}