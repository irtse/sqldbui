import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';

int globalLimit = 20;
int globalOffset = 0;
GlobalKey<DatagridWidgetState> globalGridWidgetKey = GlobalKey<DatagridWidgetState>();
GlobalKey<GridWidgetState> globalGridKey = GlobalKey<GridWidgetState>();
// ignore: must_be_immutable
class DatagridWidget extends StatefulWidget {
  // final DataGridController dataGridController = DataGridController();
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
    if (schema.keys.contains("description")) { count++; }
    if (schema.keys.contains("description")) { count++; }
    for (var fieldName in schema.keys) {
      if (fieldName == "description" || fieldName == "name" || schema[fieldName]!.type.contains("many")) { continue; }
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
              contextWidth: MediaQuery.of(context).size.width - 250,
              maxLength: maxCount(schema),
              borderColor: Theme.of(context).splashColor,
              label: GridValueWidget(fontSize: 15, icon: Icons.tag)
          ));
      if (schema.keys.contains("description")) {
        columns.add(GridColumnWidget(context: context,
          type: "varchar", 
          maxLength: maxCount(schema),
          contextWidth: MediaQuery.of(context).size.width  - 250,
          width: columnWidths.containsKey("description") ? columnWidths["id"]! : 70,
          allowSorting: false,
          allowFiltering: false,
          columnName: "description",
          borderColor: Theme.of(context).splashColor,
          label: GridValueWidget(fontSize: 15, icon: Icons.search)
        ));
      }
      if (schema.keys.contains("name")) {
            columns.add(GridColumnWidget(context: context,
              maxLength: maxCount(schema),
              type: "varchar",
              borderColor: Theme.of(context).splashColor,
              width: columnWidths.containsKey("name") ? columnWidths["name"]! : 300,
              contextWidth: MediaQuery.of(context).size.width  - 250,
              columnName: "name",
              allowFiltering: !(datas.isEmpty && !isFilter()),
              allowSorting: !(datas.isEmpty && !isFilter()),
              label: GridValueWidget(fontSize: 15, value: "name"),
            ));
          }
      
      for (var fieldName in schema.keys) {
        if (fieldName == "description" || fieldName == "name" || schema[fieldName]!.type.contains("many")) { continue; }
        columns.add(GridColumnWidget(context: context,
              type: schema[fieldName]!.type,
              contextWidth: MediaQuery.of(context).size.width - 250,
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
    if (globalOrder[currentView!.id] == null || globalOrder[currentView!.id]!.isEmpty ) {
      datas.sort( (a, b) =>  (b["id"] != null ? int.parse( b["id"]) : 0) -  (a["id"] != null ? int.parse(a["id"]) : 0) );
    } 
    return Column( children: [Container( 
      height: MediaQuery.of(context).size.height - 80,
      width: MediaQuery.of(context).size.width - 250,
      color: Theme.of(context).highlightColor,
      child : GridWidget(
          key: globalGridKey,
          links: links, 
          contextWidth: MediaQuery.of(context).size.width - 250,
          maxLength: maxCount(schema),
          contentShallowed: contentShallowed, 
          borderColor: Theme.of(context).splashColor,
          viewKey: widget.viewKey,
          // allowColumnsDragging: true,
          showCheckboxColumn: true,
          // controller: widget.dataGridController,
          showColumnHeaderIconOnHover: true,
          /* onColumnDragging: (DataGridColumnDragDetails details) {
          if (details.action == DataGridColumnDragAction.dropped &&
              details.to != null) {
              final GridColumn rearrangeColumn = columns[details.from];
              columns.removeAt(details.from);
              columns.insert(details.to!, rearrangeColumn);
              dataSource.buildDataGridRows(columns, datas);
              dataSource.refreshDataGrid();
            }
            return true;
          },*/
          // allowColumnsResizing: true,
          // columnResizeMode: ColumnResizeMode.onResizeEnd,
          /* onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
            setState(() { columnWidths[details.column.columnName] = details.width; });
            return true;
          },*/
          source: datas,
          //columnWidthMode: ColumnWidthMode.fill,
          columns: columns,
          // defaultColumnWidth: 300,
      ),
    ),]);
  }

  List<String> order(List<String>mainOrder, int index, String fieldName) {
    if(mainOrder[index] == "") { mainOrder[index] = fieldName; 
    } else { mainOrder = order(mainOrder, index + 1, fieldName); }
    return mainOrder;
  }
}