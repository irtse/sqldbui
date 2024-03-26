import 'dart:developer' as developer;
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/filter_popup.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:sqldbui2/page/page.dart';

String? isNew;

class Filter {
  dynamic value;
  String? connector;
  Filter({required this.value, this.connector});
}

bool globalNew = false;
Map<String, List<Filter>> globalFilter = <String, List<Filter>>{};
Map<String, String> globalOrder = <String, String>{};
void resetFilter(String columnName) {
  globalOrder.remove(columnName); 
  globalFilter.remove(columnName); 
  globalNew = false;
}
bool isFilter() {
  return globalOrder.isNotEmpty || globalFilter.isNotEmpty || globalNew;
}
void resetAllFilter() {
  globalOrder = {}; 
  globalFilter = {}; 
  globalNew = false;
  globalOffset = 0;
}
// ignore: must_be_immutable
class GridWidget extends StatefulWidget {
  GlobalKey<ViewWidgetState>? viewKey; 
  bool isSelected = false;
  Map<String,String> links; 
  Map<String, model.Shallowed> contentShallowed;
  List<GridColumnWidget> columns; 
  List<Map<String, dynamic>> source;
  bool showCheckboxColumn; 
  bool showColumnHeaderIconOnHover; 
  Color backgroundColor; 
  double borderWidth; 
  Color borderColor;
  int maxLength; double contextWidth;
  GridWidget({ Key? key, required this.columns, required this.source,
    required this.maxLength, required this.contextWidth,
    this.showCheckboxColumn = false, this.showColumnHeaderIconOnHover = false,
    required this.links, required this.contentShallowed, this.viewKey,
    this.borderWidth = 1, this.borderColor = Colors.grey, this.backgroundColor = Colors.transparent }): super(key: key);
  @override GridWidgetState createState() => GridWidgetState();
}
class GridWidgetState extends State<GridWidget> {
  final ScrollController _horizontal = ScrollController(), _vertical = ScrollController();
  @override Widget build(BuildContext context) { 
    List<Widget> additionnalContent = [];
    var rows = buildRows(widget.columns, widget.source);
    if (widget.showCheckboxColumn) {
      additionnalContent.add(
        Padding(padding: const EdgeInsets.only(left: 5), child: Container(width: 75, height: 50, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(right: BorderSide( color: widget.borderColor, width: widget.borderWidth ),)),
          child: CheckboxListTileFormField(enabled: true, initialValue: false, 
                    onChanged: (value) { 
                      widget.isSelected=value; 
                      setState(() {});
                    },
                    onSaved: (value) { widget.isSelected=value ?? false; },)
        ))); 
    }
    return Scrollbar(
      controller: _horizontal,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontal,
        scrollDirection: Axis.horizontal, 
        child: Stack(children: [
        Container( margin: const EdgeInsets.only(top: 55),
        child: Scrollbar(
            controller: _vertical,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notif) => notif.depth == 1,
            child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    if (globalOffset <= currentView!.max) {
                      globalOffset += (globalOffset + globalLimit) >= currentView!.max ? currentView!.max : globalOffset + globalLimit;
                      APIService().get<model.View>(currentView!.linkPath, true, context).then((value) {
                        if (value.data != null && value.data!.isNotEmpty) {
                          globalMenuKey.currentState!.setState(() {});
                        }
                      });
                    }
                  }
                  return true;
                },
                child: SingleChildScrollView(
                  controller: _vertical,
                  scrollDirection: Axis.vertical,
                  child: rows.isEmpty ? 
                  Container(width: MediaQuery.of(context).size.width - 250, height: MediaQuery.of(context).size.height - 135, 
                  color: Theme.of(context).splashColor, child: Center(child: Text("EMPTY DATAS", style: TextStyle(fontSize: 70, color: Theme.of(context).highlightColor),))) 
                  : Column(children: []..addAll(rows)..add(SizedBox(height: 10, child: null)))),),)),
      Container(  
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 3,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(children:additionnalContent..addAll(widget.columns))),
    ],)));
  }

  List<GridRowWidget> buildRows(List<GridColumnWidget> columns, List<Map<String, dynamic>> datas) {
    return datas.map<GridRowWidget>((mapped) {
      return GridRowWidget( borderWidth: widget.borderWidth, borderColor: widget.borderColor, isSelected: widget.isSelected, 
        maxLength: widget.maxLength, contextWidth: widget.contextWidth,
        cells: columns.map<GridCell>((column) {
        return GridCell( width: column.getWidth() + 42, borderWidth: widget.borderWidth, borderColor: widget.borderColor,
          backgroundColor: widget.backgroundColor, columnName: column.columnName, value: mapped[column.columnName], );
      }, ).toList(), showCheckboxColumn: widget.showCheckboxColumn, contentShallowed: widget.contentShallowed, links: widget.links, viewKey: widget.viewKey,);
    }).toList();
  }
}
// ignore: must_be_immutable
class GridRowWidget extends StatefulWidget {
  GlobalKey<ViewWidgetState>? viewKey; double borderWidth; Color borderColor; bool isSelected; int maxLength; double contextWidth;
  Map<String,String> links; Map<String, model.Shallowed> contentShallowed;
  List<GridCell> cells;  bool showCheckboxColumn; 
  GridRowWidget ({ Key? key, required this.cells, required this.links, required this.contentShallowed, this.isSelected = false,
    required this.maxLength, required this.contextWidth,
    this.showCheckboxColumn = false, this.viewKey, this.borderColor = Colors.grey, this.borderWidth = 1 }): super(key: key);
  @override GridRowWidgetState createState() => GridRowWidgetState();
}
class GridRowWidgetState extends State<GridRowWidget> {
  @override Widget build(BuildContext context) { 
    List<Widget> additionnalContent = [];
    if (widget.showCheckboxColumn) {
      additionnalContent.add(
        Padding(padding: const EdgeInsets.only(left: 5), 
        child: Container(width: 73, height: 50, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: widget.borderWidth, color: widget.borderColor))),
          child: CheckboxListTile(value: widget.isSelected, onChanged: (value) {
             setState(() {  widget.isSelected=value ?? false;  });
          },)
        ))); 
    }
    return InkWell(
      onHover: (b) {},
      child: Row(children: additionnalContent..addAll(getCellsContent(context)),)); 
  }

  List<Widget> getCellsContent(BuildContext context) {
    if (widget.cells.isEmpty) { return []; }
    String cellID = '${widget.cells[0].value}';
    List<Widget> widgets = [];
    double? maxheight;
    for (var e in widget.cells) {
      var h = e.getWidth(widget.maxLength, widget.contextWidth) > (e.width + 42) && "${e.value}".contains(" ") && e.columnName != "description" ? ((e.fontSize * "${e.value}".split(" ").length) * (e.getWidth(widget.maxLength, widget.contextWidth)) / e.width) : null;
      if (h != null && (maxheight == null || maxheight < h)) { 
        maxheight = h; 
        if (( 48 - maxheight) < 20 ) { maxheight = 48; }
      }
    }
    var first = true;
    for (var e in widget.cells) {
      var shal = widget.contentShallowed["${e.columnName}:$cellID"];
      List<dynamic> ids = [];
      if (categories[homeKey.currentState!.widget.category] != null) {
        for( var v in categories[homeKey.currentState!.widget.category]!) {
          if (homeKey.currentState != null && "${v.id}" == homeKey.currentState!.widget.viewID) { ids=v.newIds; break; }
        }
      }
      var child = e.columnName != "description" ? ListTile(
        onTap: () { 
          APIService().get<model.View>(widget.links[cellID]!, firstAPI, null).then((resp) { 
            if (widget.viewKey != null && widget.viewKey!.currentState != null && resp.data != null) {
              globalPageKey.currentState!.setState(() {
                isNew = null;
                beforeView = currentView;
                currentView = resp.data![0];
                currentView!.readOnly = beforeView!.readOnly;
                homeKey.currentState!.widget.subViewID=cellID;
              }); } }); },
        hoverColor: Colors.red, 
        title :  SizedBox(height: maxheight != null ? maxheight - 20 : null, 
                      child: Center(child: Text(shal != null ? (shal.label ?? shal.name ?? "${shal.id}") : e.value != null ? e.value.toString().replaceAll("true", "yes").replaceAll("false", "no") : "no info...", 
                        textAlign: TextAlign.center, style: TextStyle(fontSize: e.fontSize, color: Theme.of(context).selectedRowColor))))
      ) : Padding(padding: const EdgeInsets.only(top: 4,), child: IconButton( tooltip: e.value != null ? e.value.toString() : "no info...", 
                  icon: const Icon(Icons.info,), onPressed: () {},));
      List<Widget> badges = [];
      if (ids.contains(cellID) && first || isNew == cellID && first) {
        first = false;
        badges.add(Positioned(left: 10, top: 5, child: Container(
                          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                    color: Theme.of(context).primaryColor),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2), child: Text("NEW", 
                            style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ),))
                        )));
      }
      widgets.add(Stack(
        children: [Container( alignment: Alignment.center,
          decoration: BoxDecoration(color: ids.contains(cellID) || isNew == cellID ? Theme.of(context).splashColor : Colors.white,
          border: Border(left: BorderSide( color: e.borderColor, width: e.borderWidth),)),
          width: e.width.isNaN ? 300 : e.width, 
          height: maxheight,
          child: child)]..addAll(badges) ));
    }  
    return widgets;
  }
}
// ignore: must_be_immutable
class GridCell {
  double height = 100; double width; String columnName; dynamic value; Color backgroundColor; 
  double borderWidth; Color borderColor; double fontSize;
  GridCell({ required this.columnName, required this.value, required this.width, this.fontSize = 15,
     this.borderWidth = 1, this.borderColor = Colors.grey, this.backgroundColor = Colors.transparent});
  
  double getWidth(int maxLength, double contextWidth) {
    double width = ("$value".length * fontSize);
    if ((width * maxLength) < contextWidth) { 
      width = (((contextWidth  - (81.5 * maxLength)) - (42 * maxLength) - (borderWidth * maxLength)) /  maxLength); 
    }
    return width;
  }
}
// ignore: must_be_immutable
class GridColumnWidget extends StatefulWidget {
  double width; bool allowSorting;  bool allowFiltering; bool show = false;
  String type;  String columnName; GridValueWidget label; int maxLength; double contextWidth;
  double borderWidth; Color iconColor;  Color borderColor; Color backgroundColor;
  GridColumnWidget ({ Key? key, required this.columnName, required this.type, this.width = 300.0,
                                this.allowSorting = false, required this.maxLength, required this.contextWidth,
                                this.allowFiltering = false, required this.label, this.borderWidth = 1, this.iconColor = Colors.grey,
                                this.borderColor = Colors.grey, this.backgroundColor = Colors.transparent }): super(key: key);
  @override
  GridColumnWidgetState createState() => GridColumnWidgetState();
  double getWidth() {
    var width = (label.value.length * label.fontSize) + (20 * 2);
    if ((width * maxLength) < (contextWidth)) { 
      width = columnName != "description" ? (((contextWidth - (81.5 * maxLength)) - (borderWidth * maxLength)) /  maxLength) : 50; 
    }
    return width + 20;
  }
}
class GridColumnWidgetState extends State<GridColumnWidget> {
  double height = 100; bool orderASC = true; 
  @override Widget build(BuildContext context) {
    var width = widget.getWidth();
    var height = (widget.label.fontSize)  + (10 * 2);
    List<Widget> buttons = [];
    if (widget.allowSorting && widget.show) { 
      buttons.add(IconButton(onPressed: () async { 
        globalOrder[widget.columnName] = globalOrder[widget.columnName] == "desc" || globalOrder[widget.columnName] == null  ? "asc" : "desc";
        APIService().get<model.View>(currentView!.linkPath, true, context).then((value){
          if (value.data != null && value.data!.isNotEmpty) {
            homeKey.currentState!.setState(() { 
              currentView = value.data![0];
            });
          }
        },);
      }, 
      icon: Icon(globalOrder[widget.columnName] == "desc" || globalOrder[widget.columnName] == null ? Icons.arrow_upward : Icons.arrow_downward, color: widget.iconColor, size: 18,)));
    } 
    if (widget.allowFiltering && widget.show) { buttons.add(FilterPopUpWidget( 
      label: widget.label.value, columnName: widget.columnName, component: this,)); }
    if (((widget.allowSorting && globalOrder.containsKey(widget.columnName))
    || (widget.allowFiltering && (globalFilter.containsKey(widget.columnName)) || globalNew)) && widget.show) { 
      buttons.add(IconButton(onPressed: () async { 
        homeKey.currentState!.setState(() { resetFilter(widget.columnName); });
      },
      icon: Icon(Icons.filter_alt_off, color: widget.iconColor, size: 18,)));
    } 
    widget.width = width + 42;
    return InkWell(
    onTap: () => { },
    onHover: (b) { setState(() { widget.show = b; });}, // todo if datas lenght == 0
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: width.isNaN ? 300 : width + 42,
      decoration: BoxDecoration( color: widget.backgroundColor, 
        border: Border(right: BorderSide( width: widget.borderWidth, color: widget.borderColor,))),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20,), 
        child: Row( children: [SizedBox( width: width.isNaN ? 300 : width - (buttons.length * 40), height: height.isNaN ? 30 : height + 20 ,
                                        child: Center(child: widget.label),)]..add(
                                          Row(children: buttons ))))));
  }
}

// ignore: must_be_immutable
class GridValueWidget extends StatefulWidget {
  double fontSize; String value; IconData? icon;
  GridValueWidget ({ Key? key, required this.fontSize, this.value = " ", this.icon }): super(key: key);
  @override
  GridValueWidgetState createState() => GridValueWidgetState();
}
class GridValueWidgetState extends State<GridValueWidget> {
  @override Widget build(BuildContext context) {
    return widget.value == " " && widget.icon != null ? FittedBox(fit: BoxFit.fitWidth, 
      child: Icon(widget.icon, size: widget.fontSize * 1.5, color: Theme.of(context).primaryColor,))
    : Container(padding: const EdgeInsets.all(16.0), alignment: Alignment.center,
                  child: Text( widget.value.toUpperCase(), softWrap: true, 
                               style: TextStyle(color: Theme.of(context).primaryColor, fontSize: widget.fontSize)));
  }
}

/*
          key: globalGridKey,
          allowColumnsDragging: true,
          showCheckboxColumn: true,
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
*/