import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/main.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final int _rowsPerPage = 20;
final double _dataPagerHeight = 60.0;

GlobalKey<DatagridWidgetState> globalGridWidgetKey = GlobalKey<DatagridWidgetState>();
GlobalKey<SfDataGridState> globalGridKey = GlobalKey<SfDataGridState>();
class DatagridWidget extends StatefulWidget {
  final DataGridController dataGridController = DataGridController();
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};
  final model.View? view; 
  GlobalKey<ViewWidgetState>? viewKey;
  DatagridWidget ({ Key? key, this.view, this.viewKey }): super(key: key);
  @override
  DatagridWidgetState createState() => DatagridWidgetState();
}
class DatagridWidgetState extends State<DatagridWidget> {
  late Map<String, double> columnWidths = {};
  @override Widget build(BuildContext context) {
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    List<GridColumn> columns = <GridColumn>[];
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
              for (var key in item.valuesShallow.keys) { 
                contentShallowed['$key:${item.values["id"]}'] = item.valuesShallow[key]!; 
              }
          }
          datas.add(item.values); 
        }
      }
      schema = widget.view!.schema;
      columns.add(GridColumn(
              width: columnWidths.containsKey("id") ? columnWidths["id"]! : double.nan,
              columnWidthMode: ColumnWidthMode.auto,
              allowSorting: true,
              columnName: "id",
              label: Container(padding: const EdgeInsets.all(16.0), alignment: Alignment.center,
                  child: FittedBox(
                     fit: BoxFit.fitWidth, 
                     child: Icon(Icons.tag, color: Theme.of(context).primaryColor))),
          ));
      if (schema.keys.contains("description")) {
            columns.add(GridColumn(
              width: columnWidths.containsKey("description") ? columnWidths["id"]! : 70,
              columnWidthMode: ColumnWidthMode.auto,
              allowSorting: false,
              allowFiltering: false,
              columnName: "description",
              label: Container(
                padding: const EdgeInsets.all(16.0), alignment: Alignment.center,
                  child: FittedBox(
                     fit: BoxFit.fitWidth, 
                     child: Icon(Icons.search, color: Theme.of(context).primaryColor,)),
            )));
          }
      if (schema.keys.contains("name")) {
            columns.add(GridColumn(
              width: columnWidths.containsKey("name") ? columnWidths["name"]! : 300,
              columnWidthMode: ColumnWidthMode.auto,
              columnName: "name",
              label: Container(padding: const EdgeInsets.all(16.0), alignment: Alignment.center,
                  child: Text( softWrap: true, "name", 
                      style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor))),
            ));
          }
      
      for (var fieldName in schema.keys) {
        if (fieldName == "description" || fieldName == "name" || schema[fieldName]!.type.contains("many")) { continue; }
        columns.add(GridColumn(
              width: columnWidths.containsKey(fieldName) ? columnWidths[fieldName]! : double.nan,
              columnWidthMode: schema.keys.length > 8 ? ColumnWidthMode.auto : ColumnWidthMode.fill,
              allowSorting: true,
              columnName: fieldName,
              label: Container(padding: const EdgeInsets.all(16.0), alignment: Alignment.center,
                  child: Text( softWrap: true, schema[fieldName]!.label.replaceAll('db', '').replaceAll('_', ' ').replaceAll('id', ''), 
                     style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15))),
          ));
      }
    }
    final DataSource dataSource = DataSource(data: datas, columns: columns, links: links, contentShallowed: contentShallowed, 
                                             viewKey: widget.viewKey);
    return Column( children: [Container( 
      height: MediaQuery.of(context).size.height - 80,
      width: MediaQuery.of(context).size.width - 250,
      color: Theme.of(context).highlightColor,
      child : SfDataGrid(
          key: globalGridKey,
          allowSorting: true,
          showSortNumbers: true,
          allowColumnsDragging: true,
          showCheckboxColumn: true,
          allowFiltering: true,
          controller: widget.dataGridController,
          showColumnHeaderIconOnHover: true,
          selectionMode: SelectionMode.multiple,
          gridLinesVisibility: GridLinesVisibility.both,
          onColumnDragging: (DataGridColumnDragDetails details) {
          if (details.action == DataGridColumnDragAction.dropped &&
              details.to != null) {
              final GridColumn rearrangeColumn = columns[details.from];
              columns.removeAt(details.from);
              columns.insert(details.to!, rearrangeColumn);
              dataSource.buildDataGridRows(columns, datas);
              dataSource.refreshDataGrid();
            }
            return true;
          },
          allowColumnsResizing: true,
          allowMultiColumnSorting: true,
          columnResizeMode: ColumnResizeMode.onResizeEnd,
          onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
            setState(() { columnWidths[details.column.columnName] = details.width; });
            return true;
          },
          source: dataSource,
          columnWidthMode: ColumnWidthMode.fill,
          columns: columns,
          defaultColumnWidth: 300,
      ),
    ), /*Container(
      height: _dataPagerHeight,
      child: SfDataPager(
        delegate: _orderInfoDataSource,
        pageCount: _orders.length / _rowsPerPage,
        direction: Axis.horizontal,
      ))*/]);
  }

  List<String> order(List<String>mainOrder, int index, String fieldName) {
    if(mainOrder[index] == "") { mainOrder[index] = fieldName; 
    } else { mainOrder = order(mainOrder, index + 1, fieldName); }
    return mainOrder;
  }
}
/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class DataSource extends DataGridSource {
  GlobalKey<ViewWidgetState>? viewKey;
  late Map<String,String> _links;
  late Map<String, model.Shallowed> _contentShallowed;
  List<DataGridRow> _data = [];
  @override List<DataGridRow> get rows => _data;
  String cellID = "";
  /// Creates the employee data source class with required details.
  DataSource({required List<Map<String, dynamic>> data, required List<GridColumn> columns, 
  required Map<String,String> links, required Map<String, model.Shallowed> contentShallowed, this.viewKey}) {
    _links = links;
    _contentShallowed = contentShallowed;
    _data = data.map<DataGridRow>((e) => DataGridRow(cells: buildCells(e, columns))).toList();
  }

  List<DataGridCell<String>> buildCells(Map<String, dynamic> datas, List<GridColumn> columns) {
    List<DataGridCell<String>> cells = <DataGridCell<String>>[];
    for (var schema in columns) { 
      cells.add(DataGridCell<String>(columnName: schema.columnName, 
      value: datas[schema.columnName] == null || datas.containsKey(schema.columnName) == false ? "no info..." : "${datas[schema.columnName]}"));
    }
    return cells;
  }
  refreshDataGrid() { notifyListeners(); }
  
  void buildDataGridRows(List<GridColumn> columns, List<Map<String, dynamic>> datas) {
    _data = datas.map<DataGridRow>((mapped) {
      return DataGridRow( cells: columns.map<DataGridCell>((column) {
        return DataGridCell( columnName: column.columnName, value: mapped[column.columnName], );
      }).toList());
    }).toList();
  }
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    String cellID = '${row.getCells()[0].value}';
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          if (_contentShallowed.containsKey("${e.columnName}:$cellID")) {
            var shal = _contentShallowed["${e.columnName}:$cellID"]!;
            return Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 0, left: 8.0, bottom: 14.0, right: 8.0),
                  child: Padding(padding: const EdgeInsets.only(bottom: 2),
                    child: Center( child: ListTile(
                      onTap: () { 
                        APIService().get<model.View>(_links[cellID]!, firstAPI, null).then((resp) { 
                          if (viewKey != null && viewKey!.currentState != null && resp.data != null) {
                            viewKey!.currentState!.setState(() {
                              beforeView = currentView;
                              currentView = resp.data![0];
                              homeKey.currentState!.widget.subViewID=cellID;
                            });
                          }
                        });
                      },
                      hoverColor: Colors.red, 
                      title : Center(child: Text(shal.label ?? shal.name ?? "${shal.id}", style: const TextStyle(fontSize: 15)))),
            )));
          }
          return Container(
              color: Colors.white,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 0, left: 8.0, bottom: 14.0, right: 8.0),
              child: Padding(padding: const EdgeInsets.only(bottom: 2),
              child: Center( child: Center(child: e.columnName != "description" ? ListTile(
                onTap: () { 
                  APIService().get<model.View>(_links[cellID]!, firstAPI, null).then((resp) { 
                    if (viewKey != null && viewKey!.currentState != null && resp.data != null) {
                      viewKey!.currentState!.setState(() {
                        beforeView = currentView;
                        currentView = resp.data![0];
                        currentView!.readOnly = beforeView!.readOnly;
                        homeKey.currentState!.widget.subViewID=cellID;
                      });
                    }
                  });
                },
                hoverColor: Colors.red, 
                title : Center(child: Text(e.value.toString(), style: const TextStyle(fontSize: 15)))) : 
                Padding(child: IconButton( tooltip: e.value.toString(), 
                        icon:  Icon(Icons.info,),onPressed: () {},), 
                        padding: const EdgeInsets.only(top: 4,))),
            )));
          }).toList());
  }
}