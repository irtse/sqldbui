import 'dart:developer' as developer;
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/filter_popup.dart';
import 'package:sqldbui2/core/widget/fork/tranformablebox.dart' as fork;
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';

String? isNew;

class Filter {
  dynamic value;
  String? connector;
  Filter({required this.value, this.connector});
}

bool globalNew = false;
Map<int, Map<String,List<Filter>>> globalFilter = <int, Map<String,List<Filter>>>{};
Map<int, Map<String,String>> globalOrder = <int, Map<String,String>>{};
void resetFilter(String columnName) {
  globalOrder[currentView!.id]!.remove(columnName); 
  globalFilter[currentView!.id]!.remove(columnName);  
  globalNew = false;
  globalOffset = 0;
}
bool isFilter() {
  return currentView != null && globalOrder.containsKey(currentView!.id) && globalFilter.containsKey(currentView!.id)
  && (globalOrder[currentView!.id]!.isNotEmpty || globalFilter[currentView!.id]!.isNotEmpty || globalNew);
}
void resetAllFilter() {
  if (currentView != null && globalFilter.containsKey(currentView!.id) 
      && globalOrder.containsKey(currentView!.id)) {
    globalOrder = {}; 
    globalFilter = {}; 
    rects = {}; 
  }
  globalNew = false;
  globalOffset = 0;
  rects[currentView!.id] = {};
}
Map<int, Map<String, Rect>> rects = {};
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
            }, onSaved: (value) { widget.isSelected=value ?? false; },)
        ))); 
    }
    var count = 0;
    for (var col in widget.columns) { 
      col.grid = this; 
      if (count < widget.columns.length - 1) {
        col.nextColumn = (widget.columns[count + 1].key! as GlobalKey<GridColumnWidgetState>);
      }
      if (count == widget.columns.length - 1) {  col.last = true;  }
      col.prefetch();
      count++; 
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
                    if (currentView != null && (globalOffset + globalLimit) < currentView!.max) {
                      globalOffset += globalOffset + globalLimit;
                      APIService().get<model.View>(currentView!.linkPath, true, context).then((value) {
                        if (value.data != null && value.data!.isNotEmpty) { globalMenuKey.currentState!.setState(() {}); }
                      });
                    } else {
                      globalOffset = 0;
                      APIService().get<model.View>(currentView!.linkPath, true, context).then((value) {
                        if (value.data != null && value.data!.isNotEmpty) { globalMenuKey.currentState!.setState(() {}); }
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
                  : Column(children: []..addAll(rows)..add(const SizedBox(height: 10, child: null)))),),)),
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
    ],)));
  }

  List<GridRowWidget> buildRows(List<GridColumnWidget> columns, List<Map<String, dynamic>> datas) {
    return datas.map<GridRowWidget>((mapped) {
      return GridRowWidget( borderWidth: widget.borderWidth, borderColor: widget.borderColor, isSelected: widget.isSelected, 
        maxLength: widget.maxLength, contextWidth: widget.contextWidth,
        cells: columns.map<GridCell>((column) {
        return GridCell( width: column.width, borderWidth: widget.borderWidth, borderColor: widget.borderColor,
          backgroundColor: widget.backgroundColor, columnName: column.columnName, value: mapped[column.columnName], );
      }, ).toList(), showCheckboxColumn: widget.showCheckboxColumn, contentShallowed: widget.contentShallowed, links: widget.links, viewKey: widget.viewKey,);
    }).toList();
  }
}
// ignore: must_be_immutable
class GridRowWidget extends StatefulWidget {
  var isHovered = false;
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
    return MouseRegion(
          onEnter: (b) { setState(() { widget.isHovered = true; }); },
          onExit: (b) { setState(() { widget.isHovered = false; }); },
          child: Row(children: additionnalContent..addAll(getCellsContent(context)),));
  }

  List<Widget> getCellsContent(BuildContext context) {
    if (widget.cells.isEmpty) { return []; }
    String cellID = '${widget.cells[0].value}';
    List<Widget> widgets = [];
    double? maxheight;
    for (var e in widget.cells) {
      if (currentView != null && rects.containsKey(currentView!.id)) {
        double? h = rects[currentView!.id]![e.columnName] != null && ("${e.value}".length * 55) > (rects[currentView!.id]![e.columnName]!.width) 
        && e.columnName != "description" ? 500 : null;
        if (h != null && (maxheight == null || maxheight < h)) { 
          maxheight = h; 
          if (( 48 - maxheight) < 20 ) { maxheight = 48; }
        }
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
              globalMenuKey.currentState!.setState(() {
                isNew = null;
                beforeView = currentView;
                currentView = resp.data![0];
                currentView!.readOnly = beforeView!.readOnly;
                homeKey.currentState!.widget.subViewID=cellID;
              }); } }); },
        title :  SizedBox(height: maxheight != null ? maxheight - 20 : null, 
                      child: Center(child: Text(shal != null ? (shal.label ?? shal.name ?? "${shal.id}") : e.value != null ? e.value.toString().replaceAll("true", "yes").replaceAll("false", "no") : "no info...", 
                        textAlign: TextAlign.center, style: TextStyle(fontSize: e.fontSize, color: widget.isHovered ? Colors.white : Theme.of(context).selectedRowColor))))
      ) : Padding(padding: const EdgeInsets.only(top: 4,), child: IconButton( tooltip: e.value != null ? e.value.toString() : "no info...", 
                  icon: const Icon(Icons.info), onPressed: () {},));
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
          decoration: BoxDecoration(color: ids.contains(cellID) || isNew == cellID ? (widget.isHovered ? Colors.grey : Theme.of(context).splashColor  ) : (widget.isHovered ? Colors.grey : Colors.white),
          border: Border(left: BorderSide( color: e.borderColor, width: e.borderWidth),)),
          width: currentView != null && rects.containsKey(currentView!.id) && rects[currentView!.id]!.containsKey(e.columnName) ? rects[currentView!.id]![e.columnName]!.width : 300, 
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
  final BuildContext context;
  GridWidgetState? grid; GlobalKey<GridColumnWidgetState>? nextColumn; bool last = false;
  double width; bool allowSorting;  bool allowFiltering; bool show = false;
  String type;  String columnName; GridValueWidget label; int maxLength; double contextWidth;
  double borderWidth; Color iconColor;  Color borderColor; Color backgroundColor;
  GridColumnWidget ({ required this.columnName, required this.type, this.width = 300.0, required this.context,
                                this.allowSorting = false, required this.maxLength, required this.contextWidth,
                                this.allowFiltering = false, required this.label, this.borderWidth = 1, this.iconColor = Colors.grey,
                                this.borderColor = Colors.grey, this.backgroundColor = Colors.transparent }): 
                                super(key: GlobalKey<GridColumnWidgetState>());
  @override
  GridColumnWidgetState createState() => GridColumnWidgetState();
  double getWidth(bool avoid) {
    var width = (label.value.length * label.fontSize) + (20 * 2);
    if ((width * maxLength) <= (contextWidth) && !avoid) { 
      width = columnName != "description" ? (getTotal() /  maxLength) : 50; 
    }
    return width + 20;
  }

  bool isLower() {
    var width = (label.value.length * label.fontSize) + (20 * 2);
    developer.log('LOG URL ${(width * maxLength)} ${(contextWidth - (81.5 * maxLength))}', name: 'my.app.category');
    return (width * maxLength) <= (contextWidth - (81.5 * maxLength));
  }

  double getTotal() {
    return (contextWidth - (81.5 * maxLength)) - (borderWidth * maxLength);
  }

  void prefetch() {
    if (currentView != null && !rects.containsKey(currentView!.id)) { rects[currentView!.id] = {}; }
    if (!rects[currentView!.id]!.containsKey(columnName)) {
      var width = getWidth(false);
      late Rect rect = rects[currentView!.id]!.containsKey(columnName) && !rects[currentView!.id]![columnName]!.width.isNaN ? rects[currentView!.id]![columnName]! : Rect.fromCenter(
        center: MediaQuery.of(context).size.center(Offset.zero),
        width: width.isNaN ? 300 : width + 42,
        height: 55,
      );
      rects[currentView!.id]![columnName] = rect;
    }
  }
}
class GridColumnWidgetState extends State<GridColumnWidget> {
  double height = 100; bool orderASC = true; bool delayed = false;
  @override Widget build(BuildContext context) {
    var width = widget.getWidth(false);
    List<Widget> buttons = [];
    if (currentView !=  null) {
      if (!globalFilter.containsKey(currentView!.id)) { globalFilter[currentView!.id] = {}; }
      if (!globalOrder.containsKey(currentView!.id)) { globalOrder[currentView!.id] = {}; }
    }
    if (widget.allowSorting) { 
      buttons.add(IconButton(onPressed: () async { 
        if (currentView !=  null) {
          globalOffset = 0;
          globalOrder[currentView!.id]![widget.columnName] = globalOrder[currentView!.id]![widget.columnName] == "desc" || globalOrder[currentView!.id]![widget.columnName] == null  ? "asc" : "desc";
          APIService().get<model.View>(currentView!.linkPath, true, context).then((value){
            if (value.data != null && value.data!.isNotEmpty) {
              homeKey.currentState!.setState(() { 
                currentView = value.data![0];
              });
            }
          },);
        }
      }, 
      icon: Icon( currentView != null && globalOrder.containsKey(currentView!.id) && (
        (globalOrder[currentView!.id]![widget.columnName] == "desc")
        || globalOrder[currentView!.id]![widget.columnName] == null) ? Icons.arrow_upward : Icons.arrow_downward, color: widget.iconColor, size: 18,)));
    } 
    if (widget.allowFiltering) { 
      buttons.add(FilterPopUpWidget( 
      label: widget.label.value, columnName: widget.columnName, component: this,)); }
    if (currentView !=  null && (globalOrder.containsKey(currentView!.id) || globalFilter.containsKey(currentView!.id))) {
      if (((widget.allowSorting && globalOrder[currentView!.id]!.containsKey(widget.columnName))
      || (widget.allowFiltering && (globalFilter[currentView!.id]!.containsKey(widget.columnName)) || globalNew))) { 
        buttons.add(IconButton(onPressed: () async { 
          homeKey.currentState!.setState(() { resetFilter(widget.columnName); });
        },
        icon: Icon(Icons.filter_alt_off, color: widget.iconColor, size: 18,)));
      } 
    }
    widget.width = width + 42;
    if (currentView != null && !rects.containsKey(currentView!.id)) { rects[currentView!.id] = {}; }
    late Rect rect = rects[currentView!.id]!.containsKey(widget.columnName) ? rects[currentView!.id]![widget.columnName]! : Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: width.isNaN ? 300 : width + 42,
      height: 55,
    );
    rects[currentView!.id]![widget.columnName] = rect;
    return Container(width: rects[currentView!.id]![widget.columnName]!.width.isNaN ? 300 : rects[currentView!.id]![widget.columnName]!.width, height: 55,
    decoration: BoxDecoration( color: widget.backgroundColor, 
            border: Border(right: BorderSide( width: widget.borderWidth, color: widget.borderColor,))),
    child: fork.TransformableBox(
      rect: rect,
      allowFlippingWhileResizing: false,
      draggable: false,
      flip: null,
      constraints:  BoxConstraints(maxHeight: 55, minWidth: ((buttons.length + 1) * 40) + 60),
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
            rects[currentView!.id]![widget.columnName] = Rect.fromCenter(
              center: MediaQuery.of(context).size.center(Offset.zero),
              width: newWidth,
              height: 55,
            );
            widget.width = newWidth;
            var total = rects[currentView!.id]!.values.fold<double>(0, (previousValue, element) => previousValue + element.width);
            if (widget.nextColumn != null && widget.contextWidth > total) {
              var diff = widget.contextWidth - 81.4 - total;
              var last = widget.nextColumn!.currentState!;
              if (rects[currentView!.id]![last.widget.columnName]!.width + diff < (((buttons.length + 1) * 40) + 60)) { 
                rects[currentView!.id]![last.widget.columnName] = Rect.fromCenter(
                  center: MediaQuery.of(context).size.center(Offset.zero),
                  width: (((buttons.length + 1) * 40) + 60),
                  height: 55,
                );
                last.setState(() {});
                total = rects[currentView!.id]!.values.fold<double>(0, (previousValue, element) => previousValue + element.width);
                var diff = widget.contextWidth - 81.4 - total;
                newWidth = (rects[currentView!.id]![widget.columnName]!.width < 0 ? (((buttons.length + 1) * 40) + 60) : rects[currentView!.id]![widget.columnName]!.width) + diff;
                if (newWidth < 0) { newWidth = ((buttons.length + 1) * 40) + 60; }
                rects[currentView!.id]![widget.columnName] = Rect.fromCenter(
                  center: MediaQuery.of(context).size.center(Offset.zero),
                  width: newWidth,
                  height: 55,
                );
                widget.width = newWidth;
              } else {
                newWidth = rects[currentView!.id]![last.widget.columnName]!.width + diff;
                if (newWidth < 0) { newWidth = ((buttons.length + 1) * 40) + 60; }
                rects[currentView!.id]![last.widget.columnName] = Rect.fromCenter(
                  center: MediaQuery.of(context).size.center(Offset.zero),
                  width: rects[currentView!.id]![last.widget.columnName]!.width + diff,
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
              width: rects[currentView!.id]![widget.columnName]!.width - 42 - (widget.show ? (buttons.length) * 40 : 0), 
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
                  child: Text( widget.value.toUpperCase(), softWrap: true, 
                               style: TextStyle(color: Theme.of(context).primaryColor, fontSize: widget.fontSize)));
  }
}