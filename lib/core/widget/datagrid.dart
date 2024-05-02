import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/utils/grid.dart';

int globalLimit = 20;
int globalOffset = 0;
GlobalKey<DatagridWidgetState> globalGridWidgetKey = GlobalKey<DatagridWidgetState>();
GlobalKey<GridWidgetState> globalGridKey = GlobalKey<GridWidgetState>();
// ignore: must_be_immutable
class DatagridWidget extends StatefulWidget {
  List<String> selected = [];
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};
  final model.View? view; 
  GlobalKey<ViewWidgetState>? viewKey;
  DatagridWidget ({ Key? key, this.view, this.viewKey }): super(key: key);
  @override
  DatagridWidgetState createState() => DatagridWidgetState();
}
class DatagridWidgetState extends State<DatagridWidget> {
  late Map<String, double> columnWidths = {};
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
      developer.log("DatagridWidget ${datas.length}", name: "DatagridWidget");
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
      for (var fieldName in currentView!.order) {
        if (schema[fieldName]!.type.contains("many") || !schema[fieldName]!.active) { continue; }
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
    if ( currentView!.actions.contains("post") ) {
      if (currentView != null && currentView!.isList) {
        buttons.add(Column( children: [IconButton( constraints: const BoxConstraints(),
          tooltip: "upload datas file", style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) { return Colors.green; }
                              return Theme.of(context).primaryColor;
                            }), ),
          icon: Icon( Icons.upload, color: Theme.of(context).highlightColor, ),
          onPressed: () {  showDialog<void>(context: context,
                      builder: (BuildContext context) { return MappingPopUpWidget(isExport: false, format: "csv"); });
          })]));}
      buttons.add(Column(
            children: [IconButton( constraints: const BoxConstraints(),
              tooltip: "export ${currentView!.isList ? "selected " : ""}rows",
              style: ButtonStyle( overlayColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) { return Colors.green; }
                          return Theme.of(context).primaryColor;
                        }), ),
              icon: Icon( Icons.file_download, color: Theme.of(context).highlightColor, ),
              onPressed: () {  
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) { return MappingPopUpWidget(isExport: true, format: "csv"); },
                );
              },
            )],
          ));
    }
    return Column( children: [
    Container( color: Theme.of(context).selectedRowColor,  height: 40, width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
      child: Stack( children: [ 
        Positioned( top: 10, left: 32, child: Row( children: [ Icon(Icons.filter_alt, color: Colors.white, size: 20) ] )),
        Row( mainAxisAlignment: MainAxisAlignment.end, children : [ Padding(padding: const EdgeInsets.symmetric(horizontal: 30), 
          child: Row(children: [ ...buttons, FilterColsPopUpWidget(key: filterColsPopUpKey, schema: schema) ])) ]) ])),
    Container( 
      height: MediaQuery.of(context).size.height - 150 > 0 ? MediaQuery.of(context).size.height - 150 : 0,
      width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
      decoration: BoxDecoration( color:  Theme.of(context).highlightColor,  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(7),)),
      child : GridWidget(
          key: globalGridKey,
          links: links, 
          contextWidth: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
          maxLength: maxCount(schema),
          contentShallowed: contentShallowed, 
          borderColor: Theme.of(context).splashColor,
          viewKey: widget.viewKey,
          // allowColumnsDragging: true,
          showCheckboxColumn: true,
          // controller: widget.dataGridController,
          showColumnHeaderIconOnHover: true,
          source: datas,
          //columnWidthMode: ColumnWidthMode.fill,
          columns: columns,
          // defaultColumnWidth: 300,
      ) ),]);
  }

  List<String> order(List<String>mainOrder, int index, String fieldName) {
    if(mainOrder[index] == "") { mainOrder[index] = fieldName; 
    } else { mainOrder = order(mainOrder, index + 1, fieldName); }
    return mainOrder;
  }
}