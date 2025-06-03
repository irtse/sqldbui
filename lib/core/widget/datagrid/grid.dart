import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/row.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/cell.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/column.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/bottom_column.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';

String? isNew;
bool wait = false;
double refWidth = 0;
double maxWidth = 0;
Map<String?, Map<String, String>?> colFunction = {};
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
   
  GridWidget({ super.key,
    required this.columns, 
    required this.source, 
    required this.schemaID, 
    required this.contentShallowed, 
    required this.maxLength, 
    required this.contextWidth, 
    this.viewKey,
    this.isSelected = true,
    this.isEnum = false,
    this.showCheckboxColumn = true, 
    this.showColumnHeaderIconOnHover = false,
    this.borderWidth = 1, 
    this.borderColor = Colors.grey, 
    this.backgroundColor = Colors.transparent });
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
    List<Widget> bottomColumns = [];
    if (widget.showCheckboxColumn) {
      if (isEditMode[viewID] == true && showFunctions[viewID] == true) {
        bottomColumns.add(Container( decoration: BoxDecoration(border: Border(right: BorderSide(color: Theme.of(context).splashColor)), 
        color: Theme.of(context).primaryColorLight), width: 79, height: 40, child: null));
      }
      additionnalContent.add(
        Padding(padding: const EdgeInsets.only(left: 5), child: Container(
          width: 75, height: isEditMode[viewID] == true && showFunctions[viewID] == true ? 90 : 50, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(right: BorderSide( color: widget.borderColor, width: widget.borderWidth ),)),
          child: CheckboxListTile(
            enabled: true,
          value: widget.isSelected, 
            onChanged: (value) { 
              widget.isSelected=value ?? false; 
              globalGridWidgetKey.currentState!.widget.isSelected = widget.isSelected;
              selectedGrid = []; unselectedGrid = []; 
              globalGridWidgetKey.currentState!.setState(() { });
            }
          )
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
    if ((maxWidth < currentWidth - 350)) { 
      rects.remove(viewID); 
      for (var col in widget.columns) { col.prefetch(); }
    }
    var t = show ? (filterRowsWidget.length * 44 < 138 ? filterRowsWidget.length * 44 : 138) : 0;
    t += isEditMode[viewID] == true && showFunctions[viewID] == true ? ( editMode[viewID] == "math" ? 115 : 70 ) : 0;
    for (var col in widget.columns) {
        var k = GlobalKey<GridBottomColumnResultWidgetState>();
        bottomColumns.add(GridBottomColumnResultWidget(key: k, columnName: col.columnName, value: "NaN", type: col.type,
                            isEditMode: col.isEditMode, borderWidth: col.borderWidth, borderColor: col.borderColor));
        col.resultKey = k;
    }
    List<Widget> bottom = [];
    if (isEditMode[viewID] == true && showFunctions[viewID] == true) {
      bottom.add(Positioned( bottom: 0, left: 0, child: Row(children: bottomColumns)));
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scrollbar(
      controller: _horizontal,
      thumbVisibility: true,
      interactive: true, //
      child: SingleChildScrollView(
        controller: _horizontal,
        scrollDirection: Axis.horizontal, 
        child: Stack(children: [
          Container(
            margin: EdgeInsets.only(top: isEditMode[viewID] == true && showFunctions[viewID] == true ? 95 : 55),
            child: Scrollbar(
                controller: _vertical,
                thumbVisibility: true,
                interactive: !globalLoading,
                notificationPredicate: (notif) => notif.depth > -1,
                child:  SizedBox( 
                    height: currentHeigth - (178 + t) > 0 ? currentHeigth - (178 + t) : 0, 
                    child: SingleChildScrollView(
                      controller: _vertical,
                      scrollDirection: Axis.vertical,
                      child: rows.isEmpty ? 
                      Container(
                        height: currentHeigth - (178 + t) > 0 ? currentHeigth - (178 + t) : 0,
                        decoration: BoxDecoration( color: Theme.of(context).splashColor), 
                        width: maxWidth + 81.5,
                        child: Center(
                          child: Text(TranslateConstants.emptyData, 
                            style: TextStyle(fontSize: 70, color: Theme.of(context).highlightColor))
                        )
                      ) : Column(children: [
                        ...rows, 
                        currentView != null && currentView!.items.length < currentView!.max 
                        ? Center(child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10), 
                          child: VisibilityDetector(
                            key: Key('my-widget-key'),
                            onVisibilityChanged: (VisibilityInfo info) {
                              if (info.visibleFraction > 0) {
                                if (currentView != null && currentView!.items.length < currentView!.max) {
                                  if ((currentView?.items.length ?? 0) >= globalOffset) { 
                                    globalOffset = globalOffset + globalLimit; 
                                  }
                                  globalMainViewKey.currentState!.refreshUrl(currentView!.linkPath, null, false); 
                                }
                              }
                            },
                            child: SpinKitCircle(color: Theme.of(context).primaryColor))))
                        : const SizedBox(height: 10, child: null)
                      ])
                    )
                  )
            )),
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
      ...bottom,
    ],))));
  }

  List<GridRowWidget> buildRows(List<GridColumnWidget> columns, List<Value> datas) {
    return datas.map<GridRowWidget>((mapped) {
      bool found = selectedGrid.where((element) => element.cellID == mapped.values["id"]).isNotEmpty;
      return GridRowWidget( 
        news: mapped.isNew,
        cellID: "${mapped.values["id"]}",
        sharing: mapped.sharing,
        borderWidth: widget.borderWidth, 
        borderColor: widget.borderColor, 
        isSelected: found, 
        maxLength: widget.maxLength, 
        contextWidth: widget.contextWidth, 
        isEnum : widget.isEnum, 
        cells: columns.map<GridCell>((column) {
        return GridCell( 
          schemaID: mapped.schemaID,
          isNew: mapped.isNew,
          schemaField: mapped.schema[column.columnName],
          translatable: mapped.schema[column.columnName]?.translatable ?? true,
          isDraft: mapped.isDraft,
          cellID: mapped.cellID,
          width: column.width, 
          readOnly: mapped.readOnly,
          borderWidth: widget.borderWidth, 
          borderColor: widget.borderColor,
          backgroundColor: widget.backgroundColor, 
          type: column.type,
          isLink: mapped.isLink,
          columnName: column.columnName, 
          wasValue: Map.from(mapped.values)[column.columnName],
          value: mapped.values[column.columnName], 
        );
      }, ).toList(), 
      showCheckboxColumn: widget.showCheckboxColumn, 
      contentShallowed: widget.contentShallowed, 
      schemaID: widget.schemaID, 
      viewKey: widget.viewKey,);
    }).toList();
  }
}
