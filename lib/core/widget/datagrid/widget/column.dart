import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/dialog/filter_popup.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/value.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/bottom_column.dart';
import 'package:sqldbui2/core/widget/utils/fork/tranformablebox.dart' as fork;
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
// ignore: must_be_immutable
class GridColumnWidget extends StatefulWidget {
  GlobalKey<GridBottomColumnResultWidgetState>? resultKey;
  final BuildContext context;
  GridWidgetState? grid; 
  List<DropdownMenuItem<String>> items = [];
  GlobalKey<GridColumnWidgetState>? nextColumn;
  
  bool show = false;
  bool last = false;
  bool allowSorting; 
  bool allowFiltering; 
  bool isEditMode= false;

  String? url;
  String type; String columnName; 
  GridValueWidget label; 
  int maxLength; 

  final double minimal = 130;
  double contextWidth;
  double borderWidth; 
  double width;

  Color iconColor;  
  Color borderColor; 
  Color backgroundColor;

  GridColumnWidget ({ 
    required this.columnName, 
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
    this.isEditMode = false,
    this.iconColor = Colors.grey,
    this.borderColor = Colors.grey, 
    this.backgroundColor = Colors.transparent, 
    this.url }): super(key: GlobalKey<GridColumnWidgetState>());

  @override
  GridColumnWidgetState createState() => GridColumnWidgetState();
  double getWidth(bool avoid) {
    double width = (getTotal() /  maxLength); 
    if (width < minimal) { 
      width = (label.value.length * 6); 
      if (width < minimal) { width = minimal; }
    }
    return width;
  }

  bool isLower() {
    double width = (label.value.length * 8);
    if (width < minimal) { width = minimal; }
    return (width * maxLength) <= getTotal();
  }

  double getTotal() { return contextWidth - (76 + maxLength); }

  void prefetch() {
    if (currentView != null 
    && !rects.containsKey(viewID) 
    && viewID != null) { rects[viewID] = {}; }
  
    if (rects[viewID] != null 
    && !rects[viewID]!.containsKey(columnName)) {
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
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    var width = widget.getWidth(false);
    List<Widget> buttons = [];
    if (widget.allowSorting) { 
      buttons.add(SizedBox( 
        width: 30, 
        height: 30.0, 
        child: Tooltip( message: (await getOnFlow(currentView != null && globalOrder.containsKey(viewID) && (
        (globalOrder[viewID]![widget.columnName] == "asc" && viewID != null && globalOrder[viewID] != null)
        || globalOrder[viewID]![widget.columnName] == null) ? TranslateConstants.sortDesc : TranslateConstants.sortDesc)).toLowerCase(), 
        child: IconButton(
          onPressed: () async { 
            if (currentView !=  null && viewID != null) {
              globalOffset = 0;
              globalOrder[viewID]![widget.columnName] = globalOrder[viewID]![widget.columnName] == "asc"  ? "desc" : "asc";
              navigate = true;
              confirmCache = {};
              globalMainViewKey.currentState?.refresh(viewID, subViewID, currentView, false);
            }
          }, 
          icon: Icon( currentView != null && globalOrder.containsKey(viewID) && (
        (globalOrder[viewID]![widget.columnName] == "asc" && viewID != null && globalOrder[viewID] != null)
        || globalOrder[viewID]![widget.columnName] == null) ? Icons.arrow_upward : Icons.arrow_downward, color: widget.iconColor, size: 15,))
      )));
    } 
    if (widget.allowFiltering) { 
      buttons.add(SizedBox( width: 30, height: 30.0,  child: FilterPopUpWidget(
        items: widget.items, label: widget.label.value, 
        columnName: widget.columnName, type: widget.type, component: this, ))); }
    if (currentView !=  null && (globalOrder.containsKey(viewID) || globalFilter.containsKey(viewID))) {
      if (((globalOrder[viewID] != null && widget.allowSorting && globalOrder[viewID]!.containsKey(widget.columnName))
      || (globalFilter[viewID] != null && widget.allowFiltering && (globalFilter[viewID]!.has(widget.columnName))))) { 
        buttons.add(SizedBox( width: 30, height: 30.0, child: Tooltip( 
          message: (await getOnFlow(TranslateConstants.filterResetT)).toLowerCase(),  child: IconButton(
        onPressed: () async { 
          resetFilter(widget.columnName);
          navigate = true;
          confirmCache = {};
          globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
        }, icon: Icon(Icons.filter_alt_off, color: widget.iconColor, size: 15,)))));
      } 
    }
    widget.width = width + 32;
    if (viewID != null && !rects.containsKey(viewID)) { rects[viewID] = {}; }
    late Rect rect = rects[viewID]!.containsKey(widget.columnName) ? rects[viewID]![widget.columnName]! : Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero), width: width.isNaN ? 300 : width + 32, height: 55 );
    if (currentView != null && rects.containsKey(viewID)) { 
      rects[viewID]![widget.columnName] = rect; 
    }
    List<DropdownMenuItem<String>> dpItems = []; 
    if (widget.isEditMode && showFunctions[viewID] == true) {
      List<String> t = widget.columnName == "id" ? [] : ["count"];
      bool isDate = widget.type.contains("date") || widget.type.contains("time");
      if (widget.columnName != "id" && (isDate || widget.type.contains("double") || widget.type.contains("float") 
          || widget.type.contains("money") || widget.type.contains("decimal") || widget.type.contains("int"))) {
        t.addAll(["min", "max"]);
        if (!isDate) { t.addAll(["sum", "avg"]); }
      }
      for (var func in t) { 
        dpItems.add(DropdownMenuItem<String>(value: func, 
            child: FutureBuilder<String>( future: getOnFlow(func), builder: (a,s) {
              if (s.data != null) {
                return Text(s.data!.toLowerCase(), style: const TextStyle(color: Colors.white));
              }
              return Text(func.toLowerCase(), style: const TextStyle(color: Colors.white));
        })));
      }
    }
    return Column( mainAxisSize: MainAxisSize.min, children: [ 
      Container( 
        decoration: BoxDecoration( color: Theme.of(context).primaryColor, 
          border: Border(right: BorderSide( width: widget.borderWidth, color: widget.borderColor))),
        alignment: Alignment.center,
        width: !widget.isEditMode && showFunctions[viewID] == true ? 0 : (rects[viewID] != null && rects[viewID]![widget.columnName]!.width.isNaN ? 300 : rects[viewID]![widget.columnName]!.width), 
        height: widget.isEditMode && showFunctions[viewID] == true ? 40 : 0, 
        padding: const EdgeInsets.all(10),
        child: dpItems.isEmpty ? null : DropdownButtonFormField<String>( 
            value: colFunction[viewID]?[widget.columnName],
            alignment: Alignment.center, items: dpItems, 
            icon: Icon(Icons.functions, color: Theme.of(context).splashColor, size: 14,),
            hint: Opacity( opacity: .5,
              child: Text((await getOnFlow(TranslateConstants.funcColErr)).toLowerCase(), 
                textAlign: TextAlign.center, 
                overflow: TextOverflow.ellipsis, 
                style: TextStyle(color: Theme.of(context).highlightColor))),
            isExpanded: true, style: const TextStyle(fontSize: 14, color: Colors.white),
            validator: (value) { return null; },
            onChanged: (value) { setState(() { 
              if (colFunction[viewID] == null) { colFunction[viewID] = {}; }
              colFunction[viewID]?[widget.columnName] = value ?? "";
              widget.resultKey?.currentState?.setState(() { });
            }); }, 
        dropdownColor: Theme.of(context).secondaryHeaderColor,
        decoration: InputDecoration( suffixIconColor: Theme.of(context).highlightColor, 
          errorStyle: const TextStyle(fontSize: 0,),
          floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, 
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.0)),
          fillColor: (Theme.of(context).primaryColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor),
          border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
        ))),
      Container(width: rects[viewID] != null && rects[viewID]![widget.columnName]!.width.isNaN ? 300 : rects[viewID]![widget.columnName]!.width, height: 55,
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
          var size = (rects[viewID]![widget.columnName]?.width ??  300 ) - 40 - (widget.show ? (buttons.length) * 40 : 0);
          return MouseRegion(
            onEnter: (b) { setState(() { widget.show = true; });}, // todo if datas lenght == 0
            onExit: (b) { setState(() { widget.show = false; });}, // todo if datas lenght == 0
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,), 
              child: Stack( children: [ 
                ...(size <= 0 ? [] : [ SizedBox( width: size, child: Tooltip( message: widget.label.value, child: Center(child: widget.label)))] ), 
                Positioned( right: 0, top: 10, 
                  child: Row( 
                    mainAxisAlignment: MainAxisAlignment.end, 
                    children:  widget.show ? buttons : [] 
                  )
                )]
              )));
      })) ] );
  }
}