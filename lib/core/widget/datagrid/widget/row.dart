
// ignore: must_be_immutable
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/cell.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/function_math_row.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';

// ignore: must_be_immutable
class GridRowWidget extends StatefulWidget {
  var isHovered = false; 
  var isEnum = false;
  Color borderColor; 
  bool isSelected; 
  int maxLength; 
  double contextWidth;
  model.Sharing? sharing;
  List<dynamic> sharedBy;
  List<dynamic> sharedTo;
  GlobalKey<ViewWidgetState>? viewKey; 
  double borderWidth; 
  String schemaID; 
  String cellID;
  bool news = false;
  Map<String, String> contentShallowed;
  List<GridCell> cells;  
  List<GridCellWidget> widgetCells = [];  
  bool showCheckboxColumn; 

  GridRowWidgetState? state; 

  GridRowWidget ({ 
    super.key, 
    required this.cellID,
    required this.news,
    required this.cells, 
    required this.schemaID, 
    required this.contentShallowed,
    required this.maxLength, 
    required this.contextWidth, 
    required this.sharing,
    required this.sharedBy,
    required this.sharedTo,
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
    widget.state = this;
    return modeIndex[viewID]  == 1 ? Row(children: [ FutureBuilder( future: getCellsContent(context), builder: (a, s) {
      if (s.data != null) {
        return s.data!;
      }
      return Container();
    }) ]) : MouseRegion(
      onEnter: (b) { setState(() { widget.isHovered = true; }); },
      onExit: (b) { setState(() { widget.isHovered = false; }); },
      child: Stack( alignment: Alignment.center, children: [ 
        Row(children: [FutureBuilder( future: getCellsContent(context), builder: (a, s) {
          if (s.data != null) {
            return s.data!;
          }
          return Container();
        })]),
        if (widget.sharedTo.isNotEmpty)
          Positioned(left: 65, top: 30, child: FutureBuilder(future: getOnFlow("shared to :"), builder: (a,s) {
            if(s.data != null) {
              return Tooltip( message: "${s.data} ${widget.sharedTo.join(",")}", child: Icon(Icons.share, color: Theme.of(context).primaryColor));
            }
            return Tooltip( message:  widget.sharedTo.join(","), child: Icon(Icons.share, color: Theme.of(context).primaryColor));
          }) ),
        if (widget.sharedBy.isNotEmpty)
           Positioned(left: 65, top: 30, child: FutureBuilder(future: getOnFlow("shared by :"), builder: (a,s) {
            if(s.data != null) {
              return Tooltip( message: "${s.data} ${widget.sharedBy.join(",")}", child: Icon(Icons.share, color: Colors.grey));
            }
            return Tooltip( message:  widget.sharedBy.join(","), child: Icon(Icons.share, color: Colors.grey));
          }) )
      ])
    );
  }

  Future<Widget> getCellsContent(BuildContext context) async {
    if (widget.cells.isEmpty) { return Stack(); }
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
      widget.isSelected = allSelected ? true : widget.isSelected ;
      widgets.add(
        Container( margin: EdgeInsets.only(left: 5), width: 73, height: maxheight, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: widget.borderWidth, color: widget.borderColor))),
          child: CheckboxListTile(
            enabled: !allSelected,
            value: widget.isSelected, 
            onChanged: (value) {
            widget.isSelected=value ?? false;
            if (widget.isSelected) { 
              selectedGrid.add(cellID);
              if (globalGridWidgetKey.currentState!.widget.isSelected) { 
                unselectedGrid.removeWhere((e) => e == cellID);
              } else { unselectedGrid = []; }
            } else {  
              selectedGrid.removeWhere( (e) => e == cellID); 
              if (globalGridWidgetKey.currentState!.widget.isSelected) { unselectedGrid.add(cellID); 
              } else { unselectedGrid = []; }
            }
            setState(() {});
            globalActionBar.currentState?.setState(() {});
          })
        )); 
    }
    String? state;
    for (var e in widget.cells) {
      if (e.columnName == "state") {
        print(widget.contentShallowed);
        print("${e.columnName}:${widget.schemaID}:$cellID");
        state = widget.contentShallowed["${e.columnName}:${widget.schemaID}:$cellID"];
        break;
      }
    }
    List<Widget> bs = [];
    for (var e in widget.cells) {
      bool readOnly = currentView?.schema[e.columnName] != null && (currentView?.schema[e.columnName]?.readonly ?? false);
      if (notNew[viewID] != null && notNew[viewID]!.contains(cellID)) { first = false; }
      
      
      if (first) {
        if (widget.news) {
          bs.add(Container(
            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)), color: Theme.of(context).primaryColor),
            child: Padding( padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2), 
              child: Text((await getOnFlow(TranslateConstants.newT)).toLowerCase(), 
                style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor )
              )
            )
          ));
        }
        if (e.isDraft) {
          bs.add(Container(
            margin: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)), color: Colors.grey),
            child: Padding( padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2), 
              child: Text((await getOnFlow(TranslateConstants.draftT)).toLowerCase(), 
                style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor )
              )
            )
          ));
        }
        if ((state ?? "") != "") {
          var s = state!.split(" ");
          if (s.length > 1) {
            s = s.sublist(0, 2);
          }
          print(state);
          try {
            bs.add(
              FutureBuilder(future: getOnFlow(s.join(" ").replaceAll(" (pending)", "").replaceAll(" (completed)", "").replaceAll(" (refused)", "").replaceAll(" (running)", "")), 
              builder: (a, s) {
                if (s.data != null) {
                  return Container(
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)), 
                    color: state!.contains("pending") || state.contains("progressing") ? Colors.orange : (state.contains("completed") ? Colors.green : (state.contains("refused") || state.contains("dismiss") ? Colors.red : Colors.grey)) ),
                    child: Padding( padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2), 
                      child: Text(s.data!.toLowerCase(), 
                        style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor )
                      )
                    )
                  );
                }
                return Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)), 
                  color: state!.contains("pending") || state.contains("progressing") ? Colors.orange : (state.contains("completed") ? Colors.green : (state.contains("refused") || state.contains("dismiss") ? Colors.red : Colors.grey))),
                  child: Padding( padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2), 
                    child: Text(state, style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor )
                    )
                  )
                );
              }
            ));
          } catch(e) { }
        }
      }
      
      if (first) {
        first = false;
      }

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
          dataRef: e.dataRef,
          isNew: e.isNew, 
          cellID: cellID, 
          isLink: e.isLink,
          readOnly: readOnly, 
          maxheight: maxheight,
          schemaID: e.schemaID, 
          schemaField: e.schemaField,
          translatable: e.translatable,
          shal: widget.contentShallowed["${e.columnName}:${widget.schemaID}:$cellID"], 
        )
      );
      widgets.add(
          Container( 
            height: maxheight,
            alignment: Alignment.center, 
            decoration: BoxDecoration( color: widget.news 
            || (modeIndex[viewID]  == 1 && (e.readOnly || readOnly || ["id", "description", mathColName[viewID] ?? "total"].contains(e.columnName))) ? 
              (widget.isHovered ? Colors.grey : Theme.of(context).splashColor) : (widget.isHovered ? Theme.of(context).splashColor  : Colors.white),
            border: Border(left: BorderSide( color: e.borderColor, width: e.borderWidth), bottom: BorderSide(width: widget.borderWidth, color: widget.borderColor))),
            width: currentView != null && rects.containsKey(viewID) && rects[viewID]!.containsKey(e.columnName) ? rects[viewID]![e.columnName]!.width : 200, 
            child: widget.widgetCells.last
          ), 
      );
    }  
    List<Widget> badges = [Positioned(left: 40, top: 5, child: Row( children: bs ))];
    return Stack( children: [ Row(children: widgets), ...badges ]);
  }
}