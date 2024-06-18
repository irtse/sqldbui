import 'dart:developer' as developer;
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/dialog/filter_popup.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:sqldbui2/core/widget/fork/tranformablebox.dart' as fork;

double maxWidth = 0;
String? isNew;
Map<String?, List<String>> notNew = {};
double refWidth = 0;
Map<String?, Map<String, Rect>> rects = {};
bool wait = false;
// ignore: must_be_immutable
class GridWidget extends StatefulWidget {
  GlobalKey<ViewWidgetState>? viewKey; 
  bool isSelected = true;
  Map<String, model.Shallowed> contentShallowed;
  List<GridColumnWidget> columns; 
  List<Map<String, dynamic>> source;
  bool showCheckboxColumn; 
  bool showColumnHeaderIconOnHover; 
  Color backgroundColor; 
  double borderWidth; 
  Color borderColor;
  bool isEnum;
  String schemaID;
  int maxLength; double contextWidth;
  GridWidget({ Key? key,required this.columns, required this.source,
    required this.maxLength, required this.contextWidth, this.isEnum = false,
    this.showCheckboxColumn = false, this.showColumnHeaderIconOnHover = false,
    required this.schemaID, required this.contentShallowed, this.viewKey,
    this.borderWidth = 1, this.borderColor = Colors.grey, this.backgroundColor = Colors.transparent }): super(key: key);
  @override GridWidgetState createState() => GridWidgetState();
}
class GridWidgetState extends State<GridWidget> {
  final min = 160;
  final ScrollController _horizontal = ScrollController(), _vertical = ScrollController();
  @override Widget build(BuildContext context) { 
    if (viewID == null) { return Container(); }
    List<Widget> additionnalContent = [];
    if (currentView != null && viewID != null) { notNew[viewID] = []; }
    List<Widget> rows = buildRows(widget.columns, widget.source);
    if (widget.showCheckboxColumn) {
      additionnalContent.add(
        Padding(padding: const EdgeInsets.only(left: 5), child: Container(width: 75, height: 50, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(right: BorderSide( color: widget.borderColor, width: widget.borderWidth ),)),
          child: CheckboxListTile(enabled: true,
          value: widget.isSelected, 
            onChanged: (value) { 
              widget.isSelected=value ?? false; 
              if (!widget.isSelected) { globalGridWidgetKey.currentState!.widget.selected = []; }
              setState(() {});
              globalActionBar.currentState!.setState(() {});
            })
        ))); 
    }
    var count = 0;
    maxWidth = 0;
    for (var col in widget.columns) { 
      if(rects[viewID]?[col.columnName] == null) { rects.remove(viewID); break; }
    }
    for (var col in widget.columns) { 
      col.grid = this; 
      if (count < widget.columns.length - 1) { col.nextColumn = (widget.columns[count + 1].key! as GlobalKey<GridColumnWidgetState>); }
      if (count == widget.columns.length - 1) {  col.last = true;  }
      col.prefetch();  
      count++; 
    }
    if ((maxWidth < MediaQuery.of(context).size.width - 350)) { 
      rects.remove(viewID); 
      for (var col in widget.columns) { col.prefetch(); }
    }
    var t = show ? (filterRowsWidget.length * 45 < 138 ? filterRowsWidget.length * 45 : 138) : 0;

    return  Padding( padding: EdgeInsets.only(left: rows.isEmpty ? 0 : 3), child:  Scrollbar(
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
                  : Column(children: [...rows,const SizedBox(height: 10, child: null)])),),)),
      Container(  
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0, blurRadius: 3,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(children:additionnalContent..addAll(widget.columns))),
    ],))));
  }

  List<GridRowWidget> buildRows(List<GridColumnWidget> columns, List<Map<String, dynamic>> datas) {
    return datas.map<GridRowWidget>((mapped) {
      return GridRowWidget( borderWidth: widget.borderWidth, borderColor: widget.borderColor, isSelected: widget.isSelected, 
        maxLength: widget.maxLength, contextWidth: widget.contextWidth, isEnum : widget.isEnum,
        cells: columns.map<GridCell>((column) {
          if (column.columnName == "id" && widget.isSelected && mapped[column.columnName] != null
          && !globalGridWidgetKey.currentState!.widget.selected.contains(mapped[column.columnName])) {
            globalGridWidgetKey.currentState!.widget.selected.add(mapped[column.columnName]);
          }
        return GridCell( width: column.width, borderWidth: widget.borderWidth, borderColor: widget.borderColor,
          backgroundColor: widget.backgroundColor, columnName: column.columnName, value: mapped[column.columnName], );
      }, ).toList(), showCheckboxColumn: widget.showCheckboxColumn, contentShallowed: widget.contentShallowed, schemaID: widget.schemaID, viewKey: widget.viewKey,);
    }).toList();
  }
}
// ignore: must_be_immutable
class GridRowWidget extends StatefulWidget {
  var isHovered = false; var isEnum = false;
  GlobalKey<ViewWidgetState>? viewKey; double borderWidth; Color borderColor; bool isSelected; int maxLength; double contextWidth;
  String schemaID; Map<String, model.Shallowed> contentShallowed;
  List<GridCell> cells;  bool showCheckboxColumn; 
  GridRowWidget ({ Key? key, required this.cells, required this.schemaID, required this.contentShallowed, this.isSelected = true,
    required this.maxLength, required this.contextWidth, this.isEnum = false,
    this.showCheckboxColumn = false, this.viewKey, this.borderColor = Colors.grey, this.borderWidth = 1 }): super(key: key);
  @override GridRowWidgetState createState() => GridRowWidgetState();
}
class GridRowWidgetState extends State<GridRowWidget> {
  @override Widget build(BuildContext context) { 
    return MouseRegion(
          onEnter: (b) { setState(() { widget.isHovered = true; }); },
          onExit: (b) { setState(() { widget.isHovered = false; }); },
          child: Row(children: getCellsContent(context)),);
  }

  List<Widget> getCellsContent(BuildContext context) {
    if (widget.cells.isEmpty) { return []; }
    String cellID = '${widget.cells[0].value}';
    List<Widget> widgets = [];
    double maxheight = 48;
    for (var e in widget.cells) {
      if (currentView == null || !rects.containsKey(viewID)) { continue; }
      double? h = rects[viewID]![e.columnName] != null && ("${e.value}".length * 18) > (rects[viewID]![e.columnName]!.width) 
                  ? (("${e.value}".length * 18) / (rects[viewID]![e.columnName]!.width) * 27.5) : null;
      if (h != null && (maxheight < h)) { maxheight = h; }
    }
    if (maxheight < 48) { maxheight = 48; }
    var first = true;
    if (widget.showCheckboxColumn) {
      if (globalGridWidgetKey.currentState!.widget.selected.contains(widget.cells.first.value)) { widget.isSelected = true; }
      widgets.add(
        Padding(padding: const EdgeInsets.only(left: 5), 
        child: Container( width: 73, height: maxheight, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: widget.borderWidth, color: widget.borderColor))),
          child: CheckboxListTile(value: widget.isSelected, onChanged: (value) {
            widget.isSelected=value ?? false;
            if (widget.isSelected) { globalGridWidgetKey.currentState!.widget.selected.add(widget.cells.first.value);
            } else { 
              globalGridKey.currentState!.widget.isSelected = false;
              globalGridWidgetKey.currentState!.widget.selected.remove(widget.cells.first.value); 
            }
            globalActionBar.currentState!.setState(() {});
            globalGridKey.currentState!.setState(() {});
            setState(() { });
          },)
        ))); 
    }
    for (var e in widget.cells) {
      var shal = widget.contentShallowed["${e.columnName}:$cellID"];
      List<dynamic> ids = [];
      if (categories[category] != null) {
        for( var v in categories[category]!.where( (v) => "${v.id}" == viewID?.substring(1))) {
          ids=v.newIds.where((element) => notNew[viewID] == null || !notNew[viewID]!.contains(element)).toList();
        }
      }
      var transform = e.value != null ? e.value.toString().replaceAll("true", "yes").replaceAll("false", "no") : "no info...";
      var child = ListTile( enabled: !widget.isEnum, onTap: () {
          if (!widget.isEnum) { return; }
          try {
            var v = (categories[category] ?? []).firstWhere( (v) => "${v.id}" == viewID?.substring(1));
            if (isNew == cellID) { isNew = null; }
            if (!notNew.containsKey(viewID)) { notNew[viewID] = [cellID]; } else { notNew[viewID]!.add(cellID); }
            v.newIds.remove(cellID); 
          } catch (e) { /* */ }
          globalMenuKey.currentState!.setState(() {});
          AppRouter.navigateTo("@${widget.schemaID}:$cellID");
        }, title : e.columnName == "description" ? IconButton( tooltip: e.value != null ? e.value.toString() : "no info...", 
          icon: const Icon(Icons.info), onPressed: () {},) : SizedBox(height: maxheight - 20, 
        child: Center(child: Text(shal != null ? (shal.label ?? shal.name ?? "${shal.id}") : transform, textAlign: TextAlign.center, 
          style: TextStyle(fontSize: e.fontSize, color: widget.isHovered ? Colors.white : Theme.of(context).primaryColorLight))))
      );
      List<Widget> badges = [];
      if (notNew[viewID] != null && notNew[viewID]!.contains(cellID)) { first = false; }
      if (ids.contains(cellID) && first || isNew == cellID && first) {
        first = false;
        badges.add(Positioned(left: 10, top: 5, child: Container(
          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)), color: Theme.of(context).primaryColor),
          child: Padding( padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2), 
            child: Text("NEW", style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor ),)))));
      }
      widgets.add(Stack(
        children: [Container( alignment: Alignment.center, height: maxheight,
          decoration: BoxDecoration( color: ids.contains(cellID) || isNew == cellID ? 
            (widget.isHovered ? Colors.grey : Theme.of(context).splashColor  ) : (widget.isHovered ? Colors.grey : Colors.white),
            border: Border(left: BorderSide( color: e.borderColor, width: e.borderWidth), bottom: BorderSide(width: widget.borderWidth, color: widget.borderColor))),
          width: currentView != null && rects.containsKey(viewID) && rects[viewID]!.containsKey(e.columnName) ? rects[viewID]![e.columnName]!.width : 200, 
          child: child), ...badges] ));
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
    double width = ("$value".length * 19);
    if ((width * maxLength) < contextWidth) { 
      width = (((contextWidth  - (81.5 * maxLength)) - (42 * maxLength) - (borderWidth * maxLength)) /  maxLength); 
    }
    return width;
  }
}
// ignore: must_be_immutable
class GridColumnWidget extends StatefulWidget {
  final double minimal = 165;
  final BuildContext context;
  List<DropdownMenuItem<String>> items = [];
  GridWidgetState? grid; GlobalKey<GridColumnWidgetState>? nextColumn; bool last = false;
  double width; bool allowSorting; bool allowFiltering; bool show = false; String? url;
  String type;  String columnName; GridValueWidget label; int maxLength; double contextWidth;
  double borderWidth; Color iconColor;  Color borderColor; Color backgroundColor;
  GridColumnWidget ({ required this.columnName, required this.type, this.width = 300.0, required this.context,
    required this.items, this.allowSorting = false, required this.maxLength, required this.contextWidth,
    this.allowFiltering = false, required this.label, this.borderWidth = 1, this.iconColor = Colors.grey,
    this.borderColor = Colors.grey, this.backgroundColor = Colors.transparent, this.url }): 
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
    decoration: BoxDecoration( color: widget.backgroundColor, border: Border(right: BorderSide( width: widget.borderWidth, color: widget.borderColor,))),
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
              width: newWidth,
              height: 55);
            widget.width = newWidth;
            var total = rects[viewID]!.values.fold<double>(0, (previousValue, element) => previousValue + element.width);
            if (widget.nextColumn != null && widget.contextWidth > total) {
              var diff = widget.contextWidth - 81.4 - total;
              var last = widget.nextColumn!.currentState!;
              if (rects[viewID]![last.widget.columnName]!.width + diff < (((buttons.length + 1) * 40) + 60)) { 
                rects[viewID]![last.widget.columnName] = Rect.fromCenter(
                  center: MediaQuery.of(context).size.center(Offset.zero),
                  width: (((buttons.length + 1) * 40) + 60),
                  height: 55,
                );
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
        }); } 
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