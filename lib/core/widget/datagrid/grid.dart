import 'dart:developer' as developer;
import 'package:sqldbui2/core/widget/datagrid/functions/functionMathRow.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functionsSelector.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/dialog/filter_popup.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:sqldbui2/core/widget/utils/fork/tranformablebox.dart' as fork;

String? isNew;
bool wait = false;
double refWidth = 0;
double maxWidth = 0;
Map<String?, bool> isEditMode = {};
Map<String?, List<String>> notNew = {};
Map<String?, Map<String, Rect>> rects = {};
// ignore: must_be_immutable
class GridWidget extends StatefulWidget {
  Map<String, model.Shallowed> contentShallowed;
  GlobalKey<ViewWidgetState>? viewKey; 
  bool showColumnHeaderIconOnHover;
  List<GridColumnWidget> columns; 
  bool showCheckboxColumn; 
  bool isSelected = true;
  Color backgroundColor; 
  double contextWidth;
  double borderWidth; 
  List<Value> source;
  Color borderColor;
  String schemaID;
  int maxLength;
  bool isEnum;
   
  GridWidget({ Key? key,
    required this.columns, 
    required this.source, 
    required this.schemaID, 
    required this.contentShallowed, 
    required this.maxLength, 
    required this.contextWidth, 
    this.viewKey,
    this.isSelected = true,
    this.isEnum = false,
    this.showCheckboxColumn = false, 
    this.showColumnHeaderIconOnHover = false,
    this.borderWidth = 1, 
    this.borderColor = Colors.grey, 
    this.backgroundColor = Colors.transparent }): super(key: key);
  @override GridWidgetState createState() => GridWidgetState();
}
class GridWidgetState extends State<GridWidget> {
  final min = 160;
  final ScrollController _horizontal = ScrollController(), _vertical = ScrollController();
  @override Widget build(BuildContext context) { 
    if (viewID == null) { return Container(); }
    List<Widget> additionnalContent = [];
    if (currentView != null && viewID != null) { notNew[viewID] = []; }
    List<GridRowWidget> rows = buildRows(widget.columns, widget.source);
    if (widget.isSelected && selectedGrid.isEmpty) { 
      for (var row in rows) { 
        selectedGrid.add(row); 
        row.isSelected = true;
      }
    }
    if (widget.showCheckboxColumn) {
      additionnalContent.add(
        Padding(padding: const EdgeInsets.only(left: 5), child: Container(width: 75, height: 50, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(right: BorderSide( color: widget.borderColor, width: widget.borderWidth ),)),
          child: CheckboxListTile(enabled: true,
          value: widget.isSelected, 
            onChanged: (value) { 
              widget.isSelected=value ?? false; 
              globalGridWidgetKey.currentState!.widget.isSelected = widget.isSelected;
              selectedGrid = []; unselectedGrid = []; 
              // setState(() {});
              globalGridWidgetKey.currentState!.setState(() { });
            })
        ))); 
    }
    var count = 0;
    maxWidth = 0;
    for (var _ in widget.columns.where((col) => rects[viewID]?[col.columnName] == null)) { rects.remove(viewID); }
    for (var col in widget.columns) { 
      col.grid = this; 
      if (count < widget.columns.length - 1) { 
        col.nextColumn = (widget.columns[count + 1].key! as GlobalKey<GridColumnWidgetState>); 
      }
      if (count == widget.columns.length - 1) {  col.last = true;  }
      col.prefetch();  
      count++; 
    }
    if ((maxWidth < MediaQuery.of(context).size.width - 350)) { 
      rects.remove(viewID); 
      for (var col in widget.columns) { col.prefetch(); }
    }
    var t = show ? (filterRowsWidget.length * 45 < 138 ? filterRowsWidget.length * 45 : 138) : 0;

    return  Padding( 
      padding: EdgeInsets.only(left: rows.isEmpty ? 0 : 3), child:  Scrollbar(
      controller: _horizontal,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 10,
      notificationPredicate: (notif) => notif.depth > -1,
      child: SingleChildScrollView(
        controller: _horizontal,
        scrollDirection: Axis.horizontal, 
        child: Stack(fit: StackFit.loose, children: [
          Container( margin: const EdgeInsets.only(top: 55),
            child: Scrollbar(
                controller: _vertical,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: !globalLoading,
                notificationPredicate: (notif) => notif.depth > -1,
                child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification) {
                        if (currentView != null && currentView!.items.length < currentView!.max) {
                          if (currentView?.items.length == globalOffset + globalLimit) { globalOffset += globalLimit; }
                          globalMainViewKey.currentState!.refreshUrl(currentView!.linkPath, null, false); 
                        } 
                      }
                      return true;
                    },
                    child: SingleChildScrollView(
                      controller: _vertical,
                      scrollDirection: Axis.vertical,
                      child: rows.isEmpty ? 
                      Container(decoration: BoxDecoration( color: Theme.of(context).splashColor, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(7))),
                        width: maxWidth + 81.5, 
                        height: MediaQuery.of(context).size.height - (180 + t) > 0 ? MediaQuery.of(context).size.height - (180 + t) : 0, 
                      child: Center(child: Text("EMPTY DATA", style: TextStyle(fontSize: 70, color: Theme.of(context).highlightColor),)))
                      : Column(children: [...rows,const SizedBox(height: 10, child: null)]))))),
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
    ],))));
  }

  List<GridRowWidget> buildRows(List<GridColumnWidget> columns, List<Value> datas) {
    return datas.map<GridRowWidget>((mapped) {
      bool found = true;
      try {
        selectedGrid.firstWhere((element) => element.cells.first.value == mapped.values["id"]);
        found = true;
      } catch (e) { found = false; }
      return GridRowWidget( borderWidth: widget.borderWidth, 
        borderColor: widget.borderColor, 
        isSelected: found, 
        maxLength: widget.maxLength, 
        contextWidth: widget.contextWidth, 
        isEnum : widget.isEnum, 
        cells: columns.map<GridCell>((column) {
        return GridCell( width: column.width, 
          readOnly: mapped.readOnly,
          borderWidth: widget.borderWidth, 
          borderColor: widget.borderColor, 
          backgroundColor: widget.backgroundColor, 
          type: column.type,
          columnName: column.columnName, 
          wasValue: Map.from(mapped.values)[column.columnName],
          value: mapped.values[column.columnName], );
      }, ).toList(), 
      showCheckboxColumn: widget.showCheckboxColumn, 
      contentShallowed: widget.contentShallowed, 
      schemaID: widget.schemaID, 
      viewKey: widget.viewKey,);
    }).toList();
  }
}
// ignore: must_be_immutable
class GridRowWidget extends StatefulWidget {
  var isHovered = false; 
  var isEnum = false;
  Color borderColor; 
  bool isSelected; 
  int maxLength; 
  double contextWidth;
  GlobalKey<ViewWidgetState>? viewKey; 
  double borderWidth; 
  String schemaID; 
  Map<String, model.Shallowed> contentShallowed;
  List<GridCell> cells;  
  List<GridCellWidget> widgetCells = [];  
  bool showCheckboxColumn; 
  GridRowWidget ({ Key? key, 
    required this.cells, 
    required this.schemaID, 
    required this.contentShallowed,
    required this.maxLength, 
    required this.contextWidth, 
    this.isEnum = false, 
    this.showCheckboxColumn = false, 
    this.viewKey, 
    this.borderColor = Colors.grey, 
    this.borderWidth = 1, 
    this.isSelected = true }): super(key: key);
  @override GridRowWidgetState createState() => GridRowWidgetState();
}
class GridRowWidgetState extends State<GridRowWidget> {
  @override Widget build(BuildContext context) { 
    var edit = (isEditMode[viewID] ?? false);
    return edit ? Row(children: getCellsContent(context)) : MouseRegion(
      onEnter: (b) { setState(() { widget.isHovered = true; }); },
      onExit: (b) { setState(() { widget.isHovered = false; }); },
      child: Row(children: getCellsContent(context)),);
  }

  int getLength(dynamic letter, bool edit) {
    letter = letter.toString();
    var length = 0;
    for (var l in letter.split("")) {
      final regExp = RegExp('[A-Z]');
      length += (regExp.hasMatch(l) ? 28 : 26);
    }
    return length;
  }

  List<Widget> getCellsContent(BuildContext context) {
    if (widget.cells.isEmpty) { return []; }
    String cellID = '${widget.cells[0].value}';
    List<Widget> widgets = [];
    double maxheight = 48;
    for (var e in widget.cells) {
      if (currentView == null || !rects.containsKey(viewID)) { continue; }
      bool readOnly = (currentView!.schema[e.columnName] != null && currentView!.schema[e.columnName]!.readonly);
      var edit = (isEditMode[viewID] ?? false) && !["id", "description", mathColName[viewID] ?? "total"].contains(e.columnName) && !e.readOnly && !readOnly;
      double? h = rects[viewID]![e.columnName] != null && getLength(e.value ?? "", edit) > (rects[viewID]![e.columnName]!.width) 
                  ? (getLength(e.value ?? "", edit) ~/ (rects[viewID]![e.columnName]!.width) * 25) : null;
      if (h != null && (maxheight < h)) { maxheight = h; }
    }
    if (maxheight < 48) { maxheight = 48; }
    var first = true;
    if (widget.showCheckboxColumn) {
      widgets.add(
        Padding(padding: const EdgeInsets.only(left: 5), 
        child: Container( width: 73, height: maxheight, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: widget.borderWidth, color: widget.borderColor))),
          child: CheckboxListTile(value: widget.isSelected, onChanged: (value) {
            widget.isSelected=value ?? false;
            if (widget.isSelected) { 
              selectedGrid.add(widget);
              if (globalGridWidgetKey.currentState!.widget.isSelected) { 
                unselectedGrid.removeWhere((e) => e.cells.isNotEmpty && e.cells.first.value == cellID);
              } else { unselectedGrid = []; }
            } else {  
              selectedGrid.removeWhere( (e) => e.cells.isNotEmpty && e.cells.first.value == cellID); 
              if (globalGridWidgetKey.currentState!.widget.isSelected) { unselectedGrid.add(widget); 
              } else { unselectedGrid = []; }
            }
            globalGridWidgetKey.currentState!.setState(() {});
          },)
        ))); 
    }
    for (var e in widget.cells) {
      bool readOnly = currentView!.schema[e.columnName] != null && currentView!.schema[e.columnName]!.readonly;
      List<dynamic> ids = [];
      if (categories[category] != null) {
        for( var v in categories[category]!.where( (v) => "${v.id}" == viewID?.substring(1))) {
          ids=v.newIds.where((element) => notNew[viewID] == null || !notNew[viewID]!.contains(element)).toList();
        }
      }
      List<Widget> badges = [];
      if (notNew[viewID] != null && notNew[viewID]!.contains(cellID)) { first = false; }
      if (ids.contains(cellID) && first || isNew == cellID && first) {
        first = false;
        badges.add(Positioned(left: 10, top: 5, child: Container(
          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)), 
          color: Theme.of(context).primaryColor),
          child: Padding( padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2), 
            child: Text("NEW", style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ),)))));
      }
      var v = e.value;
      if (commands[viewID] != null) { 
        evalCmd(commands[viewID], widget.cells);
        if (cacheChanges["$cellID:${mathColName[viewID] ?? "total"}"] != null) {
          v = cacheChanges["$cellID:${mathColName[viewID] ?? "total"}"];
        }
      }
      widget.widgetCells.add(GridCellWidget(cell: e, readOnly: readOnly, schemaID: widget.schemaID, cellID: cellID, 
                             value: v, shal: widget.contentShallowed["${e.columnName}:$cellID"], maxheight: maxheight));
      widgets.add(Stack( children: [Container( alignment: Alignment.center, height: maxheight,
          decoration: BoxDecoration( color: ids.contains(cellID) || isNew == cellID 
            || ((isEditMode[viewID] ?? false) && (e.readOnly || readOnly || ["id", "description", mathColName[viewID] ?? "total"].contains(e.columnName))) ? 
            (widget.isHovered ? Colors.grey : Theme.of(context).splashColor) : (widget.isHovered ? Theme.of(context).splashColor  : Colors.white),
            border: Border(left: BorderSide( color: e.borderColor, width: e.borderWidth), bottom: BorderSide(width: widget.borderWidth, color: widget.borderColor))),
          width: currentView != null && rects.containsKey(viewID) && rects[viewID]!.containsKey(e.columnName) ? rects[viewID]![e.columnName]!.width : 200, 
          child: widget.widgetCells.last), ...badges] ));
    }  
    return widgets;
  }
}
class GridCellWidget extends StatefulWidget implements ConvertorWidget {
  model.Shallowed? shal;
  bool readOnly;
  String cellID;
  String schemaID;
  double maxheight;
  GridCell cell;
  @override dynamic value;
  GridCellWidget ({ Key? key, required this.cell, required this.readOnly, required this.schemaID,
    required this.cellID, required this.shal, required this.maxheight, required this.value }): super(key: key);
  @override GridCellWidgetState createState() => GridCellWidgetState();
}
class GridCellWidgetState extends State<GridCellWidget> {
  @override Widget build(BuildContext context) { 
    if (cacheChanges["${widget.cellID}:${widget.cell.columnName}"] != null) { 
      widget.cell.value = cacheChanges["${widget.cellID}:${widget.cell.columnName}"]; 
    }
    widget.value = widget.cell.value != null ? widget.cell.value.toString().replaceAll("true", "yes").replaceAll("false", "no") : "no info...";
    widget.value = widget.shal != null ? (widget.shal!.label ?? widget.shal!.name ?? "${widget.shal!.id}") : widget.value;
    var edit = (isEditMode[viewID] ?? false) && !["id", "description", mathColName[viewID] ?? "total"].contains(widget.cell.columnName)
                && !widget.cell.readOnly && !widget.readOnly;
    String url = currentView!.schema[widget.cell.columnName] == null || currentView!.schema[widget.cell.columnName]!.actionPath == "" ? 
      "" : "${currentView!.schema[widget.cell.columnName]!.actionPath}&shallow=enable";
    return edit ? Convertor.filterFieldByType(
      context, widget, widget.cell.type, "", this, false, true, url, "${widget.cellID}:${widget.cell.columnName}") : 
      ListTile( mouseCursor: isEditMode[viewID] ?? false ? MouseCursor.defer : null, 
          enabled: !widget.cell.type.contains("enum"), onTap: () {
          if (widget.cell.type.contains("enum") || (isEditMode[viewID] ?? false)) { return; }
          try {
            var v = (categories[category] ?? []).firstWhere( (v) => "${v.id}" == viewID?.substring(1));
            if (isNew == widget.cellID) { isNew = null; }
            if (!notNew.containsKey(viewID)) { notNew[viewID] = [widget.cellID]; } else { notNew[viewID]!.add(widget.cellID); }
            v.newIds.remove(widget.cellID); 
          } catch (e) { /* */ }
          globalMenuKey.currentState!.setState(() {});
          AppRouter.navigateTo("@${widget.schemaID}:${widget.cellID}");
        }, title : widget.cell.columnName == "description" ? IconButton( tooltip: widget.cell.value != null ? widget.cell.value.toString() : "no info...", 
          icon: const Icon(Icons.info), onPressed: () {},) : SizedBox(height: widget.maxheight - 20, 
        child: Center(child: Text(widget.value, 
          textAlign: TextAlign.center, 
          style: TextStyle(fontSize: widget.cell.fontSize, 
          color: Theme.of(context).primaryColorLight))))
      );
  }
}
// ignore: must_be_immutable
class GridCell {
  double height = 100; 
  double width; 
  dynamic wasValue;
  String columnName; 
  dynamic value; 
  Color backgroundColor; 
  double borderWidth; 
  Color borderColor; 
  double fontSize; 
  String type; 
  bool readOnly = false;
  GridCell({ 
    required this.columnName, 
    required this.wasValue,
    required this.value, 
    required this.width, 
    this.fontSize = 15, 
    this.type = "text",
    this.readOnly = false, 
    this.borderWidth = 1, 
    this.borderColor = Colors.grey, 
    this.backgroundColor = Colors.transparent});
  
  double getWidth(int maxLength, double contextWidth) {
    double width = ("$value".length * 19);
    if ((width * maxLength) < contextWidth) { 
      width = (((contextWidth  - (81.5 * maxLength)) - (42 * maxLength) - (borderWidth * maxLength)) /  maxLength); 
    }
    return width;
  }
}
// ignore: must_be_immutable
class GridColumnWidget extends StatefulWidget {
  final double minimal = 185;
  final BuildContext context;
  List<DropdownMenuItem<String>> items = [];
  GridWidgetState? grid; GlobalKey<GridColumnWidgetState>? nextColumn; bool last = false;
  double width; bool allowSorting; bool allowFiltering; bool show = false; String? url;
  String type;  String columnName; GridValueWidget label; int maxLength; double contextWidth;
  double borderWidth; Color iconColor;  Color borderColor; Color backgroundColor;
  GridColumnWidget ({ required this.columnName, 
    required this.type, 
    this.width = 300.0, 
    required this.context,
    required this.items, 
    this.allowSorting = false, 
    required this.maxLength, 
    required this.contextWidth,
    this.allowFiltering = false, 
    required this.label, 
    this.borderWidth = 1, 
    this.iconColor = Colors.grey,
    this.borderColor = Colors.grey, 
    this.backgroundColor = Colors.transparent, 
    this.url }): 
      super(key: GlobalKey<GridColumnWidgetState>());
  @override
  GridColumnWidgetState createState() => GridColumnWidgetState();
  double getWidth(bool avoid) {
    double width = (getTotal() /  maxLength); 
    if (width < minimal) { 
      width = (label.value.length * 17); 
      if (width < minimal) { width = minimal; }
    }
    return width;
  }

  bool isLower() {
    double width = (label.value.length * 18);
    if (width < minimal) { width = minimal; }
    return (width * maxLength) <= getTotal();
  }

  double getTotal() { return contextWidth - (80 + maxLength); }

  void prefetch() {
    if (currentView != null && !rects.containsKey(viewID) && viewID != null) { rects[viewID] = {}; }
    if (rects[viewID] != null && !rects[viewID]!.containsKey(columnName)) {
      double width = getWidth(false);
      late Rect rect = rects[viewID]!.containsKey(columnName) && !rects[viewID]![columnName]!.width.isNaN ? rects[viewID]![columnName]! : Rect.fromCenter(
        center: MediaQuery.of(context).size.center(Offset.zero),
        width: width.isNaN ? 130 : width, height: 55,
      );
      rects[viewID]![columnName] = rect;
    }
    maxWidth += rects[viewID] != null ? rects[viewID]![columnName]!.width : 300;
  }
}
class GridColumnWidgetState extends State<GridColumnWidget> {
  double height = 100; bool orderASC = true; bool delayed = false;
  @override Widget build(BuildContext context) {
    var width = widget.getWidth(false);
    List<Widget> buttons = [];
    if (widget.allowSorting) { 
      buttons.add(IconButton(onPressed: () async { 
        if (currentView !=  null && viewID != null) {
          globalOffset = 0;
          globalOrder[viewID]![widget.columnName] = globalOrder[viewID]![widget.columnName] == "desc" || globalOrder[viewID]![widget.columnName] == null  ? "asc" : "desc";
          APIService().get<model.View>(currentView!.linkPath, true, context).then((value){
            if (value.data != null && value.data!.isNotEmpty) {
              globalMainViewKey.currentState?.refresh(viewID, subViewID, category, value.data![0], false);
            }
          },);
        }
      }, 
      icon: Icon( currentView != null && globalOrder.containsKey(viewID) && (
        (globalOrder[viewID]![widget.columnName] == "desc" && viewID != null && globalOrder[viewID] != null)
        || globalOrder[viewID]![widget.columnName] == null) ? Icons.arrow_upward : Icons.arrow_downward, color: widget.iconColor, size: 18,)));
    } 
    if (widget.allowFiltering) { 
      buttons.add(FilterPopUpWidget(items: widget.items, label: widget.label.value, 
        columnName: widget.columnName, type: widget.type, component: this, )); }
    if (currentView !=  null && (globalOrder.containsKey(viewID) || globalFilter.containsKey(viewID))) {
      if (((globalOrder[viewID] != null && widget.allowSorting && globalOrder[viewID]!.containsKey(widget.columnName))
      || (globalFilter[viewID] != null && widget.allowFiltering && (globalFilter[viewID]!.has(widget.columnName))))) { 
        buttons.add(IconButton(onPressed: () async { 
          resetFilter(widget.columnName);
          globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
        }, icon: Icon(Icons.filter_alt_off, color: widget.iconColor, size: 18,)));
      } 
    }
    widget.width = width + 42;
    if (viewID != null && !rects.containsKey(viewID)) { rects[viewID] = {}; }
    late Rect rect = rects[viewID]!.containsKey(widget.columnName) ? rects[viewID]![widget.columnName]! : Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero), width: width.isNaN ? 300 : width + 42, height: 55 );
    if (currentView != null && rects.containsKey(viewID)) { rects[viewID]![widget.columnName] = rect; }
    return Container(width: rects[viewID] != null && rects[viewID]![widget.columnName]!.width.isNaN ? 300 : rects[viewID]![widget.columnName]!.width, height: 55,
      decoration: BoxDecoration( color: widget.backgroundColor, 
      border: Border(right: BorderSide( width: widget.borderWidth, color: widget.borderColor,))),
      child: fork.TransformableBox(
        rect: rect,
        allowFlippingWhileResizing: false,
        draggable: false,
        flip: null,
        constraints: BoxConstraints(maxHeight: 55, minWidth: widget.minimal),
        resizeModeResolver: () => ResizeMode.symmetric,
        visibleHandles: const {HandlePosition.right},
        enabledHandles: delayed || (widget.last && widget.isLower()) ? {} : const {HandlePosition.right},
        clampingRect: Offset.zero & MediaQuery.sizeOf(context),
        handleAlignment: HandleAlignment.inside,
        onChanged: (result, event) {
          if (widget.grid != null) { 
            widget.grid!.setState(() {
              double newWidth = result.rect.width > ((buttons.length + 1) * 40) + 60 ? result.rect.width : ((buttons.length + 1) * 40) + 60;
              if (newWidth < 0) { newWidth = ((buttons.length + 1) * 40) + 60; }
              if (result.rect.width <= ((buttons.length + 1) * 40) + 60) { delayed = true; }
              rects[viewID]![widget.columnName] = Rect.fromCenter(
                center: MediaQuery.of(context).size.center(Offset.zero),
                width: newWidth, height: 55);
              widget.width = newWidth;
              var total = rects[viewID]!.values.fold<double>(0, (previousValue, element) => previousValue + element.width);
              if (widget.nextColumn != null && widget.contextWidth > total) {
                var diff = widget.contextWidth - 81.4 - total;
                var last = widget.nextColumn!.currentState!;
                if (rects[viewID]![last.widget.columnName]!.width + diff < (((buttons.length + 1) * 40) + 60)) { 
                  rects[viewID]![last.widget.columnName] = Rect.fromCenter(
                    center: MediaQuery.of(context).size.center(Offset.zero),
                    width: (((buttons.length + 1) * 40) + 60), height: 55 );
                  last.setState(() {});
                  total = rects[viewID]!.values.fold<double>(0, (previousValue, element) => previousValue + element.width);
                  var diff = widget.contextWidth - 81.4 - total;
                  newWidth = (rects[viewID]![widget.columnName]!.width < 0 ? (((buttons.length + 1) * 40) + 60) : rects[viewID]![widget.columnName]!.width) + diff;
                  if (newWidth < 0) { newWidth = ((buttons.length + 1) * 40) + 60; }
                  rects[viewID]![widget.columnName] = Rect.fromCenter(
                    center: MediaQuery.of(context).size.center(Offset.zero),
                    width: newWidth, height: 55 );
                  widget.width = newWidth;
                } else {
                  newWidth = rects[viewID]![last.widget.columnName]!.width + diff;
                  if (newWidth < 0) { newWidth = ((buttons.length + 1) * 40) + 60; }
                  rects[viewID]![last.widget.columnName] = Rect.fromCenter(
                    center: MediaQuery.of(context).size.center(Offset.zero),
                    width: rects[viewID]![last.widget.columnName]!.width + diff,
                    height: 55,
                  );
                  last.setState(() {});
                }
              }
              setState(() {});
              Future.delayed(const Duration(milliseconds: 500), () => setState(() { delayed = false; }));
            }); 
          } 
        },
        contentBuilder: (context, rect, flip) {
          return MouseRegion(
          onEnter: (b) { setState(() { widget.show = true; });}, // todo if datas lenght == 0
          onExit: (b) { setState(() { widget.show = false; });}, // todo if datas lenght == 0
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20,), 
              child: Row( children: [SizedBox( 
                width: rects[viewID]![widget.columnName]!.width - 40 - (widget.show ? (buttons.length) * 40 : 0), 
                child: Center(child: widget.label),), Row(children:  widget.show ? buttons : [] )])));
      }));
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
                  child: Text( widget.value.toUpperCase(), overflow: TextOverflow.ellipsis, 
                               style: TextStyle(color: Theme.of(context).primaryColor, fontSize: widget.fontSize)));
  }
}