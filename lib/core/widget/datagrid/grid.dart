import 'dart:async';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/row.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/cell.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/value.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/column.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/bottom_column.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';

String? isNew;
double refWidth = 0;
double maxWidth = 0;
Map<String?, Map<String, String>?> colFunction = {};
Map<String, int> modeIndex  = {};
Map<String?, List<String>> notNew = {};
Map<String?, Map<String, Rect>> rects = {};
List<GridRowWidget> rows = [];
List<GridColumnWidget> columns = []; 
// ignore: s
class GridWidget extends StatefulWidget {
  final model.View? view; 
  List<dynamic>? forceOrder;
  bool subTable = false;
  GlobalKey<ViewWidgetState>? viewKey; 
  bool showColumnHeaderIconOnHover;
  
  String schemaID;
  int maxLength;
  bool isEnum;
  Map<String, model.SchemaField> schema = {};
  double subWidthSize;
  bool showCheckboxColumn; 
  bool isSelected = true;
  Color backgroundColor; 
  double contextWidth;
  double borderWidth; 
  Color borderColor;
  Map<String, String> links = {};
  double scroll = 0;
  var schemeItems = <DropdownMenuItem<String>>[];

  GridWidget({ super.key,
    required this.subWidthSize,
    required this.view, 
    required this.schemaID, 
    required this.schema,
    required this.maxLength, 
    required this.contextWidth, 
    this.subTable = false,
    this.forceOrder,
    this.links = const {}, 
    this.viewKey,
    this.isEnum = false,
   
    this.showColumnHeaderIconOnHover = false,
    this.isSelected = true,
    this.showCheckboxColumn = true, 
    this.borderWidth = 1, 
    this.borderColor = Colors.grey, 
    this.backgroundColor = Colors.transparent 
  });
  @override GridWidgetState createState() => GridWidgetState();
}
class GridWidgetState extends State<GridWidget> {
  final min = 160;
  double lastOffset = 0;
  double lastWidth = 0;
  Timer? _scrollTimer;
   bool _isMouseDown = false;
  Offset _mousePosition = Offset.zero;
  final ScrollController _horizontal = ScrollController(), _vertical = ScrollController();

  void _startAutoScroll() {
    const scrollSpeed = 10.0;
    const edgeThreshold = 50.0;

    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      if (!_isMouseDown) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) return;
      final localPos = box.globalToLocal(_mousePosition);
      final width = box.size.width;
        
      if (localPos.dx >= width - edgeThreshold) {
        _horizontal.jumpTo(
          (_horizontal.offset + scrollSpeed).clamp(
          0.0, _horizontal.position.maxScrollExtent),
        );
        if ((rects[viewID]?[columns.last.columnName]?.width ?? columns.last.width) > lastWidth) {
          setState( () {
            widget.scroll += scrollSpeed;
            if (rects[viewID]?[columns.last.columnName] != null) {
              rects[viewID]![columns.last.columnName] =  Rect.fromCenter(center: MediaQuery.of(context).size.center(Offset.zero),
                width: rects[viewID]![columns.last.columnName]!.width + scrollSpeed, 
                height: rects[viewID]![columns.last.columnName]!.height
              );
            } else {
              columns.last.width += scrollSpeed;
            }
          });
        } else if ((rects[viewID]?[columns.last.columnName]?.width ?? columns.last.width) < lastWidth && widget.scroll > 0) {
          setState( () {
            widget.scroll -= scrollSpeed;
          });
        }
      }
    });
  }

  @override Widget build(BuildContext context) {
    if (viewID == null) { return Container(); }
    if (modeIndex[viewID] == null) {
      modeIndex[viewID ?? ""] = 0;
    }
    columns = [];
    if (widget.view != null) {
      var order = realOrder(widget.view, widget.subTable, false, widget.forceOrder, null);
      for (var fieldName in order) {
        if ((widget.schema[fieldName]?.valuesPath ?? "") != "") {
          APIService().get(widget.schema[fieldName]!.valuesPath, false, context);
        }
        columns = getColumn( columns, widget.schemeItems, widget.schema, fieldName, [], order);   
      }
    }
    if (columns.isNotEmpty) {
      lastWidth = rects[viewID]?[columns.last.columnName]?.width ?? columns.last.width;
    }
    

    List<Widget> bottomColumns = [];
    List<Widget> additionnalContent = [];
    var subSize = showMore ? ((filterRowsWidget[viewID] ?? []).length * 45 < 138 ? (filterRowsWidget[viewID] ?? []).length * 45 : 138) : (!(editMode[viewID] == "math") ? 0 : 138);

    if (widget.showCheckboxColumn) {
      allSelected = widget.isSelected;
      if (modeIndex[viewID] == 1 && showFunctions[viewID] == true) {
        bottomColumns.add(Container( decoration: BoxDecoration(border: Border(right: BorderSide(color: Theme.of(context).splashColor)), 
        color: Theme.of(context).primaryColorLight), width: 79, height: 40, child: null));
      }
      additionnalContent.add(MainCheckWidget()); 
    }
    for (var col in columns) {
        var k = GlobalKey<GridBottomColumnResultWidgetState>();
        bottomColumns.add(GridBottomColumnResultWidget(
          key: k, 
          columnName: col.columnName, 
          value: "NaN",
          type: col.type,
          borderWidth: col.borderWidth, 
          borderColor: col.borderColor));
        col.resultKey = k;
    }
    List<Widget> bottom = [];
    bottom.add(Positioned( bottom: 0, right: 0, 
      child: Column( children: [
        if (modeIndex[viewID]  == 1 && showFunctions[viewID] == true) 
          Row(children: bottomColumns),
        if (!widget.subTable)
          getBottomBar(widget.schema),
      ]))
    );
    return Container( 
        height: widget.subTable ? null : currentHeigth - (120 + subSize) > 0 ?  currentHeigth - (120 + subSize) : 0,
        width: (currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0),
        decoration: BoxDecoration( 
          color:  Theme.of(context).highlightColor
        ), 
        child :  Stack( children: [ 
      Listener(
        onPointerDown: (event) {
          _isMouseDown = true;
          _mousePosition = event.position;
          _startAutoScroll();
        },
        onPointerMove: (event) {
          _mousePosition = event.position;
        },
        onPointerUp: (_) {
          _isMouseDown = false;
          _scrollTimer?.cancel();
        },
        child: MouseRegion(
          onHover: (event) {
            _mousePosition = event.position;
          },
          child:  ScrollConfiguration(
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
                  margin: EdgeInsets.only(top: modeIndex[viewID]  == 1 && showFunctions[viewID] == true ? 95 : 55),
                  child:ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(Colors.grey),
                      thickness: WidgetStateProperty.all(8),
                      radius: const Radius.circular(10),
                    ),
                    child: SubGridWidget(
                        scroll: widget.scroll,
                        view: widget.view, schema: widget.schema, subWidthSize: widget.subWidthSize, schemaID: widget.schemaID,
                        contextWidth: widget.contextWidth, isSelected: widget.isSelected, showCheckboxColumn: widget.showCheckboxColumn,
                        borderColor: widget.borderColor, borderWidth: widget.borderWidth, backgroundColor: widget.backgroundColor,
                        subTable: widget.subTable, viewKey: widget.viewKey, maxLength: widget.maxLength, isEnum: widget.isEnum, subSize: subSize,
                      ),
                      
                    
                )
              ),
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
                        ]),
                        child: Row(children:additionnalContent..addAll(columns))
                      ),
            ])
          ))
        )
      )),
      ...bottom,
    ]));
  }
  Widget getBottomBar(Map<String, model.SchemaField> schema) {
    var toggles = [
        Icons.remove_red_eye,
        Icons.edit,
    ];
    if (widget.view?.actions.contains("delete") ?? false) {
      toggles.add(Icons.delete);
    } 
    if (toggles.length <= (modeIndex[viewID ?? ""] ?? 0) ) {
      modeIndex[viewID ?? ""]  = 0;
    }
      var w = Padding( 
      padding: const EdgeInsets.only(right: 10), 
      child: Tooltip( message: "mode", child: ToggleSwitch( 
        icons: toggles, 
        minHeight: 27.5, 
        minWidth: 50, 
        fontSize: 12, 
        cornerRadius: 5,
        initialLabelIndex: modeIndex[viewID] ,
        dividerColor: Colors.white, 
        inactiveFgColor: Theme.of(context).splashColor,
        totalSwitches: toggles.length, 
        inactiveBgColor: Theme.of(context).secondaryHeaderColor,
        onToggle: (index) async {
          modeIndex[viewID ?? ""]  = index ?? 0;
          globalOffset = 0;
          var defaultPath = viewID != null ? "${APIConstants.genericEndpost}${subViewID != null ? viewID!.substring(1) : "dbview"}?rows=${subViewID != null ? "$subViewID" : viewID!.substring(1)}" : "";
          widget.view?.items = [];
          var e = await APIService().getWithOffset<model.View>(widget.view?.linkPath ?? defaultPath, true, context);
          for (var view in e.data ?? []) { 
            widget.view?.max = view?.max;
            for (var item in view.items) { 
              if ((widget.view?.items.where((element) => element.values['id'] == item.values['id']) ?? []).isEmpty) { 
                widget.view?.items.add(item); 
              }
            }
          }
          Future.delayed(Duration(seconds: 1), () {
            globalActionBar.currentState?.setState(() {
              globalActionBar.currentState?.widget.view = widget.view;
            });
            if (mounted) {
              setState(() { });
            }
            
          }); 
        }
      ))
    );
    if (modeIndex[viewID]  != 1) {
      return Container( 
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.transparent, 
        constraints: const BoxConstraints(minHeight: 40), 
        width: 202,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [ w ]
        )
      );
    }
    return Container( 
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).primaryColorLight, 
        constraints: const BoxConstraints(minHeight: 40), 
        width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
        child: Stack( 
          children: [
          SizedBox( 
            width: (currentWidth - menuSize > 0 ? currentWidth - menuSize - 202 : 0),
            child: FunctionsSelectorWidget(schema: schema, mathAllowed: realOrder(widget.view, false, false, null, null).length > 2),
          ),
          Positioned(
            right: 0,
            top: 7,
            child: w
          ),
        ])
    );
  }

  List<GridColumnWidget> getColumn(List<GridColumnWidget> columns, List<DropdownMenuItem<String>> schemeItems, 
    Map<String, model.SchemaField> schema, String? fieldName, List<Value> datas, List<dynamic> order) {
    bool isNotValidCol = fieldName == null && fieldName == "id";
    String? lab = (schema[fieldName]?.label ?? "") != "" ? schema[fieldName]!.label : fieldName;
    String type = fieldName == null ? "float" : (fieldName == "id" ? "integer" : schema[fieldName]?.type ?? "float");
    String label = (fieldName == "id" ? "id" : (lab ?? mathColName[viewID] ?? TranslateConstants.total.toLowerCase())
    ).replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ');
    if (!isNotValidCol && !(filterTempOrderView[viewID]?.contains(fieldName) ?? true)) { 
      filterTempOrderView[viewID]?.add(fieldName); 
    }

    var realLabel = fastTranslation[viewID ?? ""]?[label] ?? label;
    schemeItems.add(DropdownMenuItem<String>(value: fieldName, child: Text(
      realLabel.toLowerCase(), overflow: TextOverflow.ellipsis)));
      columns.add( GridColumnWidget(
        view: widget.view!,
        context: context, 
        width: double.nan,
        items: schemeItems, 
        maxLength: order.length + (modeIndex[viewID]  == 1 && editMode[viewID] == "math" ? 1 : 0),
        borderColor: Theme.of(context).splashColor, 
        allowSorting: !(datas.isEmpty && !isFilter()) && modeIndex[viewID]  != 1,
        columnName: fieldName ??  mathColName[viewID] ?? TranslateConstants.total.toLowerCase(),
        allowFiltering: !(schema[fieldName]?.type.contains("many") ?? false), 
        type:  schema[fieldName]?.schema != null && schema[fieldName]!.schema.isNotEmpty && type.contains("int") ? "link" : type,
        url: schema[fieldName]?.valuesPath != "" ? schema[fieldName]?.valuesPath : null,
        contextWidth: currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0,
        label: label == "id" ? GridValueWidget(fontSize: 13, icon: Icons.tag) : GridValueWidget(fontSize: 13, value: realLabel),
      ));
    return columns;
  }
}


// ignore: must_be_immutable
class SubGridWidget extends StatefulWidget {
  int subSize;
  Map<String, model.SchemaField> schema = {};
  final model.View? view; 
  double subWidthSize;
  String schemaID;
  bool isSelected = true;
  Color backgroundColor; 
  double contextWidth;
  double borderWidth; 
  Color borderColor;
  bool showCheckboxColumn = true;
  Map<String, String> links = {};
  bool subTable = false;
  GlobalKey<ViewWidgetState>? viewKey; 
  int maxLength;
  bool isEnum;
  double scroll = 0;

  Map<String, String> contentShallowed = {};
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};

  SubGridWidget({ super.key,
    required this.subSize,
    required this.scroll,
    required this.view, 
    required this.subWidthSize,
    required this.schema,
    required this.schemaID, 
    required this.contextWidth,
    required this.isSelected,
    required this.showCheckboxColumn, 
    required this.borderWidth, 
    required this.borderColor, 
    required this.backgroundColor,
    required this.subTable,
    required this.viewKey,
    required this.maxLength,
    required this.isEnum,
  });
  @override SubGridWidgetState createState() => SubGridWidgetState();
}
class SubGridWidgetState extends State<SubGridWidget> {
  final ScrollController _vertical = ScrollController();

  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    
    if (currentView != null && viewID != null) { notNew[viewID] = []; }
    rows = buildRows(getDatas());
    if (allSelected && selectedGrid.isEmpty) { 
      for (var row in rows) { 
        selectedGrid.add(row.cellID); 
        row.isSelected = true;
      }
    }
    if (currentWidth <= 1000) { widget.subSize = 0; }
    var count = 0;
    maxWidth = 0;
    for (var col in columns) { 
      if (count < columns.length - 1) { 
        col.nextColumn = (columns[count + 1].key! as GlobalKey<GridColumnWidgetState>); 
      }
      if (count == columns.length - 1) {  col.last = true;  }
      col.prefetch();  
      count++; 
    }
    if ((maxWidth < currentWidth - 350)) { 
      rects.remove(viewID); 
      for (var col in columns) { col.prefetch(); }
    }
    
    var t = showMore ? ((filterRowsWidget[viewID] ?? []).length * 44 < 138 ? (filterRowsWidget[viewID] ?? []).length * 44 : 138) : 0;
    t += modeIndex[viewID]  == 1 ? 40 : 0;
    t += modeIndex[viewID]  == 1 && showFunctions[viewID] == true ? ( editMode[viewID] == "math" ? 115 : 70 ) : 0;
    
    return Scrollbar(
      controller: _vertical,
      thumbVisibility: true,
      trackVisibility: true,
      scrollbarOrientation: ScrollbarOrientation.left,
      interactive: true,
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
              width: maxWidth +  widget.scroll + 86.5,
              child: Center(
                child: Text((await getOnFlow(TranslateConstants.emptyData)).toLowerCase(), 
                  style: TextStyle(fontSize: 70, color: Theme.of(context).highlightColor))
                )
              ) : Column(
                children: [
                  ...rows, 
                  currentView != null && currentView!.items.length < currentView!.max 
                  ? Center(
                    child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10), 
                                child: VisibilityDetector(
                                  key: Key("my-widget"),
                                  onVisibilityChanged: (VisibilityInfo info) async {
                                    if (info.visibleFraction > 0) {
                                      if (currentView != null && currentView!.items.length < currentView!.max) {
                                        if ((currentView?.items.length ?? 0) >= globalOffset) { 
                                          globalOffset = globalOffset + globalLimit; 
                                        }
                                        var defaultPath = viewID != null ? "${APIConstants.genericEndpost}${subViewID != null ? viewID!.substring(1) : "dbview"}?rows=${subViewID != null ? "$subViewID" : viewID!.substring(1)}" : "";
                                        var e = await APIService().getWithOffset<model.View>(widget.view?.linkPath ?? defaultPath, false, context);
                                        if ((e.data ?? []).isEmpty) {
                                          widget.view?.max = widget.view?.items.length ?? 0;
                                        }
                                        for (var view in (e.data ?? [])) { 
                                          if (view.items.isEmpty || ((widget.view?.max ?? 0) <= globalOffset && (widget.view?.max ?? 0) > (widget.view?.items.length ?? 0))) {
                                            widget.view?.max = widget.view?.items.length ?? 0;
                                          }
                                          for (var item in view.items) { 
                                            if ((widget.view?.items.where((element) => element.values['id'] == item.values['id']) ?? []).isEmpty) { 
                                              widget.view?.items.add(item); 
                                            }
                                          }
                                        }
                                        Future.delayed(Duration(milliseconds: 100), () {
                                          globalActionBar.currentState?.setState(() {
                                            globalActionBar.currentState?.widget.view = widget.view;
                                          });
                                          setState(() { });
                                        });
                                      }
                                    }
                                  },
                                  child: SpinKitCircle(color: Theme.of(context).primaryColor))))
                              : const SizedBox(height: 10, child: null)
                            ])
        )
      )
    );
  }

  List<Value> getDatas() {
    List<Value> datas = <Value>[];
    if (widget.view != null) {
      for (var item in (widget.view?.items ?? [] as List<model.Item>)) {
        if (!widget.cache.containsKey(widget.view!.schemaName)) { 
          widget.cache[widget.view!.schemaName]=<String,dynamic>{}; 
        } 
        if (!widget.cache.containsKey("id")) { 
          widget.cache[widget.view!.schemaName]!["id"]=item.values["id"];
          if (item.linkPath != "") {  widget.links[item.values['id']] = item.linkPath; }
          for (var key in item.valuesShallow.keys) { 
            widget.contentShallowed['$key:${item.schemaID}:${item.values["id"]}'] = (item.valuesShallow[key]?.label ?? item.valuesShallow[key]?.name ?? "${item.valuesShallow[key]?.id}");  
            if (modeIndex[viewID]  == 1 && ["id", "description", mathColName[viewID] ?? "total"].contains(key)  && !item.readonly) {
              widget.contentShallowed['$key:${item.schemaID}:${item.values["id"]}'] = "${item.valuesShallow[key]?.id}"; 
            }
          }
        } else { widget.cache[widget.view!.schemaName]!["id"] += ",${item.values['id']}"; }
        if (!widget.view!.isEmpty && item.values.values.where((e) => e != null).toList().isEmpty) { 
          continue; 
        }
        datas.add(Value(
          sharedBy: item.sharedBy,
          sharedTo: item.sharedTo,
          dataRef: item.dataRef,
          schemaID: item.schemaID,
          schema: widget.schema,
          valuesMany: item.valuesMany,
          isNew: item.news,
          isDraft: item.isDraft,
          cellID: item.values["id"],
          values: item.values, 
          sharing: item.sharing,
          isLink: item.linkPath != "", 
          readOnly: item.readonly )); 
      }
    }
    return datas;
  }

  

  List<GridRowWidget> buildRows(List<Value> datas) {
    return datas.map<GridRowWidget>((mapped) {
      bool found = selectedGrid.where((cellID) => cellID == mapped.values["id"]).isNotEmpty;
      return GridRowWidget( 
        schemaID: mapped.schemaID,
        news: mapped.isNew,
        sharedBy: mapped.sharedBy,
        sharedTo: mapped.sharedTo,
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
          dataRef: mapped.dataRef,
          schemaID: mapped.schemaID,
          isNew: mapped.isNew,
          schemaField: mapped.schema[column.columnName],
          translatable: mapped.schema[column.columnName]?.translatable ?? false,
          isDraft: mapped.isDraft,
          cellID: mapped.cellID,
          width: column.width, 
          readOnly: mapped.readOnly && !(mapped.schema[column.columnName]?.forceNotReadOnly ?? false),
          borderWidth: widget.borderWidth, 
          borderColor: widget.borderColor,
          backgroundColor: widget.backgroundColor, 
          type: column.type,
          isLink: mapped.isLink,
          columnName: column.columnName, 
          wasValue: Map.from(mapped.values)[column.columnName],
          value: mapped.valuesMany[column.columnName]?.map( (e) {
            return (e as model.Shallowed).name;
          }).toList().join(",") ?? mapped.values[column.columnName], 
        );
      }, ).toList(), 
      showCheckboxColumn: widget.showCheckboxColumn, 
      contentShallowed: widget.contentShallowed, 
      viewKey: widget.viewKey);
    }).toList();
  }
}

class MainCheckWidget extends StatefulWidget {
  MainCheckWidget({super.key});
  @override MainCheckWidgetState createState() => MainCheckWidgetState();
}
class MainCheckWidgetState extends State<MainCheckWidget>  {
  
  @override Widget build(BuildContext context) { 
    return Padding(padding: const EdgeInsets.only(left: 5), child: Container(
          width: 75, height: modeIndex[viewID]  == 1 && showFunctions[viewID] == true ? 90 : 50, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(right: BorderSide( 
            color:  globalGridKey.currentState?.widget.borderColor ?? Colors.grey, 
            width:  globalGridKey.currentState?.widget.borderWidth ?? 1 ),)),
          child: CheckboxListTile(
            enabled: true,
            value: globalGridKey.currentState?.widget.isSelected ?? true, 
            onChanged: (value) { 
              setState(() {
                globalGridKey.currentState?.widget.isSelected=(value ?? false); 
                  allSelected = globalGridKey.currentState?.widget.isSelected ?? (value ?? false);
                  selectedGrid = []; unselectedGrid = []; 
                  globalActionBar.currentState?.setState(() {});
                  for (var r in rows) {
                    r.state?.setState(() {
                      r.isSelected = globalGridKey.currentState?.widget.isSelected ?? (value ?? false);
                    });
                  }
                
              });
            }
          )
        ));
  }

}
        