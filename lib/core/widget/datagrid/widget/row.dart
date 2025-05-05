
// ignore: must_be_immutable
import 'package:sqldbui2/core/widget/datagrid/widget/cell.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/dialog/link_box.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/function_math_row.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class GridRowWidget extends StatefulWidget {
  var isHovered = false; 
  var isEnum = false;
  Color borderColor; 
  bool isSelected; 
  int maxLength; 
  double contextWidth;
  model.Sharing? sharing;
  GlobalKey<ViewWidgetState>? viewKey; 
  double borderWidth; 
  String schemaID; 
  Map<String, model.Shallowed> contentShallowed;
  List<GridCell> cells;  
  List<GridCellWidget> widgetCells = [];  
  bool showCheckboxColumn; 

  GridRowWidget ({ 
    super.key, 
    required this.cells, 
    required this.schemaID, 
    required this.contentShallowed,
    required this.maxLength, 
    required this.contextWidth, 
    required this.sharing,
    this.isEnum = false, 
    this.showCheckboxColumn = false, 
    this.viewKey, 
    this.borderColor = Colors.grey, 
    this.borderWidth = 1, 
    this.isSelected = true 
  });
  @override GridRowWidgetState createState() => GridRowWidgetState();
}
class GridRowWidgetState extends State<GridRowWidget> {
  @override Widget build(BuildContext context) { 
    var edit = (isEditMode[viewID] ?? false);
    return edit ? Row(children: getCellsContent(context)) : MouseRegion(
      onEnter: (b) { setState(() { widget.isHovered = true; }); },
      onExit: (b) { setState(() { widget.isHovered = false; }); },
      child: Stack( alignment: Alignment.center, children: [ 
        Row(children: getCellsContent(context)),
        widget.showCheckboxColumn ? Positioned( left : 57.5, child: LinkBoxWidget(
          path: "@${widget.schemaID}:${widget.cells.first.value}",
          sharing: widget.sharing,
        )) : Container(),
      ])
    );
  }

  List<Widget> getCellsContent(BuildContext context) {
    if (widget.cells.isEmpty) { return []; }
    String cellID = '${widget.cells[0].columnName != "id" ? widget.cells[0].cellID : widget.cells[0].value}';
    List<Widget> widgets = [];
    double maxheight = 48;
    for (var e in widget.cells) {
      if (currentView == null || !rects.containsKey(viewID)) { continue; }
      double h = 40;
      var maxLetterPerLine = (rects[viewID]![e.columnName]!.width) / (e.fontSize - 5);
      double textLines = ((e.value?.toString() ?? "").length / maxLetterPerLine).ceilToDouble();
      if (textLines < 1) {
        textLines = 1;
      }
      h = h + ((textLines * 1.1) * (e.fontSize + 5));
      if (maxheight < h) { maxheight = h; }
    }    
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
      bool readOnly = currentView?.schema[e.columnName] != null && (currentView?.schema[e.columnName]?.readonly ?? false);
      List<dynamic> ids = [];
      for( var cat in categories.values) {
        for( var v in cat.where( (v) => "${v.id}" == viewID?.substring(1))) {
          ids=v.newIds.where((element) => notNew[viewID] == null || !notNew[viewID]!.contains(element)).toList();
        }
      }
      if (notNew[viewID] != null && notNew[viewID]!.contains(cellID)) { first = false; }
      List<Widget> bs = [];
      if (ids.contains(cellID) && first || isNew == cellID && first) {
        bs.add(Container(
          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)), color: Theme.of(context).primaryColor),
          child: Padding( padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2), 
            child: Text(TranslateConstants.newT.toLowerCase(), 
              style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor )
            )
          )
        ));
      }
      if (e.isDraft && first) {
        bs.add(Container(
          margin: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)), color: Colors.grey),
          child: Padding( padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2), 
            child: Text(TranslateConstants.draftT.toLowerCase(), 
              style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor )
            )
          )
        ));
      }
      if (first) {
        first = false;
      }
      List<Widget> badges = [Positioned(left: 10, top: 5, child: Row( children: bs ))];

      var v = e.value;
      if (commands[viewID] != null) { 
        evalCmd(commands[viewID]!, widget.cells);
        if (cacheChanges["$cellID:${mathColName[viewID] ?? "total"}"] != null) {
          v = cacheChanges["$cellID:${mathColName[viewID] ?? "total"}"];
        }
      }
      widget.widgetCells.add(
        GridCellWidget(
          cell: e, 
          value: v, 
          cellID: cellID, 
          isLink: e.isLink,
          readOnly: readOnly, 
          maxheight: maxheight,
          schemaID: widget.schemaID, 
          schemaField: e.schemaField,
          translatable: e.translatable,
          shal: widget.contentShallowed["${e.columnName}:$cellID"], 
        )
      );
      widgets.add(
        Stack( children: [
          Container( 
            height: maxheight,
            alignment: Alignment.center, 
            decoration: BoxDecoration( color: ids.contains(cellID) || isNew == cellID 
            || ((isEditMode[viewID] ?? false) && (e.readOnly || readOnly || ["id", "description", mathColName[viewID] ?? "total"].contains(e.columnName))) ? 
              (widget.isHovered ? Colors.grey : Theme.of(context).splashColor) : (widget.isHovered ? Theme.of(context).splashColor  : Colors.white),
            border: Border(left: BorderSide( color: e.borderColor, width: e.borderWidth), bottom: BorderSide(width: widget.borderWidth, color: widget.borderColor))),
            width: currentView != null && rects.containsKey(viewID) && rects[viewID]!.containsKey(e.columnName) ? rects[viewID]![e.columnName]!.width : 200, 
            child: widget.widgetCells.last
          ), 
          ...badges
        ])
      );
    }  
    return widgets;
  }
}