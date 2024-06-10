import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/utils/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/utils/filterRow.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';

bool tempRemoval = false;
bool noFilterRetrieval = false;
int globalLimit = 20;
int globalOffset = 0;
Map<String, List<Filter>> filterConfs = {};
Map<String, int> filterIDName = <String, int>{};
Map<String, String> filterRestr = <String, String>{};
GlobalKey<GridWidgetState> globalGridKey = GlobalKey<GridWidgetState>();
GlobalKey<DatagridWidgetState> globalGridWidgetKey = GlobalKey<DatagridWidgetState>();
// ignore: must_be_immutable
List<FilterRowWidget> filterRowsWidget = [];
class DatagridWidget extends StatefulWidget {
  List<String> selected = [];
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};
  final model.View? view; 
  GlobalKey<ViewWidgetState>? viewKey;
  DatagridWidget ({ Key? key, this.view, this.viewKey }): super(key: key);
  @override
  DatagridWidgetState createState() => DatagridWidgetState();
}
bool show = false;
class DatagridWidgetState extends State<DatagridWidget> {
  late Map<String, double> columnWidths = {};
  List<DropdownMenuItem<String>> dpItems = <DropdownMenuItem<String>>[];
  int maxCount(Map<String, model.SchemaField> schema) {
    return schema.keys.where((element) => !schema[element]!.type.contains("many") && schema[element]!.active).length + 1;
  }
  @override Widget build(BuildContext context) {
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    var schemeItems = <DropdownMenuItem<String>>[];
    List<GridColumnWidget> columns = <GridColumnWidget>[];
    List<Map<String, dynamic>> datas = <Map<String, dynamic>>[];
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
          datas.add(item.values); 
        }
      }
      schema = widget.view!.schema;
      for (var fieldName in ["id", ...currentView!.order]) {
        var label = fieldName == "id" ? "id" : schema[fieldName]!.label;
        var type = fieldName == "id" ? "integer" : schema[fieldName]!.type;
        var sch = fieldName == "id" ? null : schema[fieldName]!.schema;
        var active = fieldName == "id" ? true : schema[fieldName]!.active;
        if (type.contains("many") || !active) { continue; }
        schemeItems.add(DropdownMenuItem<String>(value: fieldName, child: Text(label, overflow: TextOverflow.ellipsis,)));
        columns.add(GridColumnWidget(context: context, items: schemeItems,
              type: sch != null && sch.isNotEmpty && type.contains("int") ? "link" : type,
              contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
              width: columnWidths.containsKey(fieldName) ? columnWidths[fieldName]! : double.nan,
              borderColor: Theme.of(context).splashColor, columnName: fieldName, maxLength: maxCount(schema),
              allowSorting: !(datas.isEmpty && !isFilter()), allowFiltering: !(datas.isEmpty && !isFilter()),
              label: label == "id" ? GridValueWidget(fontSize: 15, icon: Icons.tag) : GridValueWidget(fontSize: 15, value: label.replaceAll('db', '').replaceAll('_', ' ').replaceAll('id', ''),),
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
            return [ PopupMenuItem(enabled: false, child: StatefulBuilder( builder: (BuildContext context, StateSetter setState) {
              return MappingPopUpWidget(isExport: false, format: "csv"); })) ]; 
          }) ]));
    }
    buttons.add(Column( children: [ PopupMenuButton(
          constraints: BoxConstraints.tightFor( width: MediaQuery.of(context).size.width / 1.1),
          color: Theme.of(context).secondaryHeaderColor, tooltip:  "export ${currentView!.isList ? "selected " : ""}rows",
          icon: Icon(size: 20, Icons.file_download, color: Theme.of(context).highlightColor), onSelected: (value) { },
          itemBuilder: (BuildContext bc) {
            return [ PopupMenuItem(enabled: false, child: StatefulBuilder(  builder: (BuildContext context, StateSetter setState) {
                    return MappingPopUpWidget(isExport: true, format: "csv"); })) ]; 
        }) ]));
    Filters? filterMain = globalFilter[viewID!];
    if (filterRestr[viewID!] != null && filterRestr[viewID!] != "" && !tempRemoval) { // THERE IS A FILTER
      filterRowsWidget = filterMain?.toRow(schemeItems, schema) ?? [];
    } else if (tempRemoval) { tempRemoval = false; }
    var t = show ? (filterRowsWidget.length * 45 < 138 ? filterRowsWidget.length * 45 : 138) : 0;
    var index = 0;
    for (var i in filterRowsWidget) { 
      if (filterRowsWidget.length - 1 > index && i.connector == "") { 
        filterRowsWidget[index] = FilterRowWidget(schema: schema, items: schemeItems, index: i.index, connector: "and", label: i.label, 
          type: i.type, columnName: i.columnName, value: i.value, comparator: i.comparator, dir: i.dir);
      }
      index++;
    }
    return Column( children: [ Container( color: Theme.of(context).primaryColorLight, constraints: const BoxConstraints(minHeight: 40), 
      width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
      child: Column( children: [ Stack( children: [ 
        MediaQuery.of(context).size.width > 1000 ? Positioned( top: 3.5, left: 32, child: Row( children: [ 
          
        Padding( padding: const EdgeInsets.only(right: 10), child : InkWell( child : Icon( show ? Icons.filter_alt : Icons.filter_alt_outlined, 
          color: show ? Colors.white : Theme.of(context).splashColor, size: 20), onTap: () { setState(() { show = !show; }); },),
        ),
        filterRestr[viewID] != "" && filterRestr[viewID] != null ? Padding(padding: const EdgeInsets.only(left: 5), 
        child:  IconButton( constraints: const BoxConstraints(), tooltip: "save filter", 
        style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.save, size: 18, color: Theme.of(context).splashColor, ),
          onPressed: () async { 
            globalFilter[viewID!] = Filters(); // empty filter to refill with new
            for (var filter in filterRowsWidget) {
              if (filter.formKey.currentState == null || !filter.formKey.currentState!.validate()) { return; }
              globalFilter[viewID!]?.add(filter.columnName ?? "", Filter(column: filter.columnName, label: filter.label ?? filter.columnName,
                type: filter.type, value: filter.value, index: filter.index, connector: filter.connector, comparator: filter.comparator));
            }
            noFilterRetrieval = true;
            var body = { "link" : widget.view?.schemaName, "is_selected" : true, "filter_fields" : globalFilter[viewID!]?.serialize() }; 
            if (currentView == null) { return; }
            (viewID != null && filterRestr[viewID] != null ? APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[filterRestr[viewID]]}"), body, context) :
            APIService().post<model.Shallowed>(currentView!.filterPath, body, context)).then((value) => refreshFilter(value.data != null && value.data!.isNotEmpty ? value.data![0].fields : []));
          })) : Container(),
        filterRestr[viewID!] != null && filterRestr[viewID!] != "" ? Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), 
        tooltip: "delete filter", style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon(Icons.delete, size: 18, color: Theme.of(context).splashColor, ),
          onPressed: () { setState(() { 
            APIService().delete(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[filterRestr[viewID]]}"), context).then((value) {
              removeFilter(); 
              filterRestr[viewID!] = ""; 
              Future.delayed(const Duration(seconds: 1), 
              () => globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true));
            },); });  })) : Container() ,
        FutureBuilder(future: APIService().get<model.Shallowed>("${currentView!.filterPath}&is_view=false", true, null), 
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.Shallowed>> snapshot) {
          if (snapshot.hasData && snapshot.data!.data != null && snapshot.data!.data!.isNotEmpty) { 
            for (var i in snapshot.data!.data!) { 
              if (dpItems.where((element) => element.value == i.label).isEmpty) {
                dpItems.add(DropdownMenuItem<String>(value: i.label, child: Text(i.label!, overflow: TextOverflow.ellipsis,),));
              }
              filterIDName[i.label!] = i.id!; filterConfs[i.label!] = i.fields;
              if (i.selected && filterRestr[viewID!] != "") {  filterRestr[viewID!] = i.label!;  }
              if ((i.selected && (filterMain == null || filterMain.isEmpty) && filterRestr[viewID!] != ""
              && filterRestr[viewID!] != null && !noFilterRetrieval)
              || (filterRowsWidget.isEmpty && i.fields.isNotEmpty && filterRestr[viewID!] != "" && filterRestr[viewID!] != null)) { 
                Future.delayed(const Duration(milliseconds: 500), () => refreshFilter(i.fields)); 
              }
              if (filterRestr[viewID!] == "") { filterRestr.remove(viewID); }
            }
          } 
          return SizedBox( height: 25, width: (MediaQuery.of(context).size.width - menuSize) / 3, 
            child: DropdownButtonFormField<String>( items: dpItems, value: filterRestr[viewID!],
                    hint: Text("select an existing filter...", overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    onChanged: (value) async {
                      if (value == null) { return; }
                      noFilterRetrieval = false;
                      filterRestr[viewID!] = value; 
                      APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[value]}"), 
                        <String, dynamic> { "is_selected" : true }, null).then( (value) => refreshFilter(value.data != null && value.data!.isNotEmpty ? value.data![0].fields : []));
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
        filterRowsWidget.isEmpty ? Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: "new filter", 
        style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.add, size: 17, color: Theme.of(context).highlightColor, ),
          onPressed: () { setState(() { 
            show = true;
            filterRowsWidget.add(FilterRowWidget(schema: schema, items: schemeItems, index: filterRowsWidget.length)); }); })) : Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: "apply filter", 
          style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) { return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.check, size: 17, color: Theme.of(context).highlightColor, ),
          onPressed: () {
            globalFilter[viewID!] = Filters(); // empty filter to refill with new
            for (var filter in filterRowsWidget) {
              if (filter.formKey.currentState == null || !filter.formKey.currentState!.validate()) { return; }
              globalFilter[viewID!]?.add(filter.columnName ?? "", Filter(column: filter.columnName, label: filter.label ?? filter.columnName,
                type: filter.type, value: filter.value, index: filter.index, connector: filter.connector, comparator: filter.comparator));
            }
            noFilterRetrieval = true;
            globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
          })),
        filterRowsWidget.isNotEmpty || (filterRestr[viewID!] != null && filterRestr[viewID!] != "" ) || globalNew ? Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: "reset filter", style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.filter_alt_off, size: 18, color: Theme.of(context).highlightColor, ),
          onPressed: () async { 
            removeFilter();
            if (filterRestr[viewID] == null || filterRestr[viewID] == "") { 
              filterRestr[viewID!] = ""; 
              return Future.delayed(const Duration(seconds: 1), 
                () => globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true)); 
            }
            APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[filterRestr[viewID]]}"), <String, dynamic> { "is_selected" : false }, null).then((value) {
              filterRestr[viewID!] = "";
              Future.delayed(const Duration(seconds: 1), 
                () => globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true));
          });  })) : Container(),
          Padding(padding: const EdgeInsets.only(left: 10), 
        child: AdvancedSwitch( width: 140, initialValue: globalNew, activeColor: Colors.green, inactiveColor: Theme.of(context).secondaryHeaderColor,
                    activeChild: Text("only new"), inactiveChild: Text("not only new", style: TextStyle(color: Theme.of(context).splashColor)),  
                    borderRadius:  const BorderRadius.all(Radius.circular(15)), height: 25.0, disabledOpacity: 0.5,
                    onChanged: (value) { 
                      globalNew = value; 
                      Future.delayed(const Duration(seconds: 1), () => globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true));
                    },),
        )
      ] )) : Container(),
      Row( mainAxisAlignment: MainAxisAlignment.end, children : [ Padding(padding: const EdgeInsets.symmetric(horizontal: 30), 
          child: Row(children: [ ...buttons, FilterColsPopUpWidget(key: filterColsPopUpKey, schema: schema) ])) ]) ]), 
          Container( constraints: BoxConstraints( maxHeight:  (MediaQuery.of(context).size.height > (120 + t) ? t : MediaQuery.of(context).size.height - 120).toDouble()), 
          child: SingleChildScrollView( child: Column( children : [ filterRowsWidget.isEmpty ? 
            Container() : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor),  ...(show ? filterRowsWidget : []) ] ))) ])),
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