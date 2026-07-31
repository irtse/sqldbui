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
import 'package:sqldbui2/core/widget/utils/loading_overlay.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/bottom_column.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';

String? isNew;
double refWidth = 0;
double maxWidth = 0;

// Two independent sources can be reloading the grid at once: the main view
// fetch driven by MainViewWidgetState, and an explicit filter-apply driven by
// FilterSelectorWidgetState.resetList(). They're tracked separately so one
// finishing early can never clobber the other's still-in-flight state for the
// safety-valve timer below. But only the explicit source drives GridWidget's
// own nested overlay (see `if (_explicitReloadCount > 0)` further down):
// while the main view is reloading, MainViewWidgetState already covers the
// whole view with its own overlay, and that one must win — showing this
// nested one on top of it would double it up.
bool _mainViewReloading = false;
int _explicitReloadCount = 0;

// Safety valve: whatever chain of rebuilds/retriggers is keeping the grid in
// a "reloading" state, it should never take more than a couple seconds for a
// single reload to actually land. If it's still "on" after that, force it
// off rather than let the loader stay stuck — this is a backstop independent
// of tracking down every possible retrigger path.
Timer? _gridReloadSafety;
void _armGridReloadSafety() {
  if (_gridReloadSafety != null) { return; }
  _gridReloadSafety = Timer(const Duration(seconds: 2, milliseconds: 500), () {
    _gridReloadSafety = null;
    _mainViewReloading = false;
    _explicitReloadCount = 0;
    // ignore: invalid_use_of_protected_member
    globalGridKey.currentState?.setState(() {});
  });
}
void _disarmGridReloadSafetyIfIdle() {
  if (!_mainViewReloading && _explicitReloadCount == 0) {
    _gridReloadSafety?.cancel();
    _gridReloadSafety = null;
  }
}
void setMainViewReloading(bool value) {
  _mainViewReloading = value;
  if (value) { _armGridReloadSafety(); } else { _disarmGridReloadSafetyIfIdle(); }
}
void beginExplicitGridReload() {
  _explicitReloadCount++;
  _armGridReloadSafety();
}
void endExplicitGridReload() {
  if (_explicitReloadCount > 0) {
    _explicitReloadCount--;
  }
  _disarmGridReloadSafetyIfIdle();
}

// Predictive flag: MainViewWidgetState (view.dart) sets this the moment its
// own fetch starts, since — if the resolved view turns out to be a list —
// the GridWidget it hands off to will freshly mount SubGridWidget, which
// runs its own local FutureBuilder and briefly shows a differently-styled
// standalone loader while it does. Holding the main overlay up until that
// settles avoids the flicker of the main loader disappearing to reveal that
// other loader for a frame before final content. Cleared by
// SubGridWidgetState once it has real content, or by MainViewWidgetState
// itself when the resolved view isn't going to mount a grid at all (nothing
// would ever clear it in that case).
bool _gridInitialLoading = false;
bool get gridInitialLoading => _gridInitialLoading;
Timer? _gridInitialLoadSafety;
void setGridInitialLoading(bool value) {
  _gridInitialLoading = value;
  _gridInitialLoadSafety?.cancel();
  _gridInitialLoadSafety = null;
  if (value) {
    _gridInitialLoadSafety = Timer(const Duration(seconds: 3), () {
      _gridInitialLoadSafety = null;
      _gridInitialLoading = false;
      // ignore: invalid_use_of_protected_member
      globalMainLoaderKey.currentState?.setState(() {});
    });
  }
}

Map<String?, Map<String, String>?> colFunction = {};
Map<String, int> modeIndex  = {};
Map<String?, List<String>> notNew = {};
Map<String?, Map<String, Rect>> rects = {};
List<GridRowWidget> rows = [];
List<GridColumnWidget> columns = []; 
// ignore: s, must_be_immutable
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
  final ScrollController _horizontal = ScrollController();
  // realOrder()/columns are computed synchronously from whatever widget.view
  // holds at this exact build. If the columns/schema for this view are still
  // being filled in by something async and arrive a bit later, nothing
  // otherwise forces GridWidgetState to re-check — it would show "no
  // columns" forever even once real columns exist. Re-check a few times.
  int _columnsRecheckAttempts = 0;
  bool _columnsRecheckScheduled = false;
  // Keyed by columnName and reused across rebuilds (a filter-only reload
  // calls setState() on this same State, but getColumn() below rebuilds
  // `columns` from scratch every time) — without this, every
  // GridColumnWidget got a brand new GlobalKey each rebuild, which Flutter
  // has no choice but to treat as a brand new column: full teardown and
  // remount of every header, even though only the rows actually changed.
  final Map<String, GlobalKey<GridColumnWidgetState>> _columnKeys = {};
  GlobalKey<GridColumnWidgetState> _keyForColumn(String columnName) {
    return _columnKeys.putIfAbsent(columnName, () => GlobalKey<GridColumnWidgetState>());
  }

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
      _columnsRecheckAttempts = 0;
    } else if (!_columnsRecheckScheduled && _columnsRecheckAttempts < 5) {
      _columnsRecheckScheduled = true;
      _columnsRecheckAttempts++;
      Future.delayed(const Duration(milliseconds: 500), () {
        _columnsRecheckScheduled = false;
        if (mounted) { setState(() {}); }
      });
    }

    List<Widget> bottomColumns = [];
    List<Widget> additionnalContent = [];
    var subSize = showMore ? ((filterRowsWidget[viewID] ?? []).length * 45 < 138 ? (filterRowsWidget[viewID] ?? []).length * 45 : 138) : (!(editMode[viewID] == "math") ? 0 : 138);
    
    if (columns.isEmpty) {
      if (_columnsRecheckAttempts < 5) {
        // Still retrying — deliberately blank, not a loader of our own.
        // Whatever overlay is already active (the main one, or the grid's
        // explicit-reload one) covers this state when one applies; showing
        // our own spinner here instead pops in and back out on every
        // 500ms retry pass, which reads as flickering on its own.
        return SizedBox(
          height: widget.subTable ? null : currentHeigth - (120 + subSize) > 0 ?  currentHeigth - (120 + subSize) : 0,
          width: (currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0),
        );
      }
      if (gridInitialLoading) {
        setGridInitialLoading(false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ignore: invalid_use_of_protected_member
          globalMainLoaderKey.currentState?.setState(() {});
        });
      }
      // A dedicated, simple screen for "no columns at all" instead of routing
      // through SubGridWidget's column-measurement pipeline (col.prefetch(),
      // maxWidth, rects...), which assumes at least one column and was the
      // source of the loader getting stuck with nothing to measure.
      return Container(
        height: widget.subTable ? null : currentHeigth - (120 + subSize) > 0 ?  currentHeigth - (120 + subSize) : 0,
        width: (currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0),
        // highlightColor for the whole area (matching the header's normal
        // background), with splashColor only below a header-sized margin —
        // same proportions as the "no data" placeholder (SubGridWidget),
        // instead of covering the full area with splashColor (a translucent
        // tint), which reads noticeably darker over that much surface.
        decoration: BoxDecoration(color: Theme.of(context).highlightColor),
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).splashColor),
          alignment: Alignment.center,
          child: FutureBuilder(future: getOnFlow(TranslateConstants.noColumns), builder: (a, s) {
            return Text((s.data ?? TranslateConstants.noColumns).toLowerCase(),
              style: TextStyle(fontSize: 70, color: Theme.of(context).highlightColor));
          }),
        ),
      );
    }

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
                        key: globalSubGridKey,
                        scroll: widget.scroll,
                        view: widget.view, schema: widget.schema, subWidthSize: widget.subWidthSize, schemaID: widget.schemaID,
                        contextWidth: widget.contextWidth, isSelected: widget.isSelected, showCheckboxColumn: widget.showCheckboxColumn,
                        borderColor: widget.borderColor, borderWidth: widget.borderWidth, backgroundColor: widget.backgroundColor,
                        subTable: widget.subTable, viewKey: widget.viewKey, maxLength: widget.maxLength, isEnum: widget.isEnum, subSize: subSize,
                      ),
                      
                    
                )
              ),
              Container(
                height: 55,
                constraints: BoxConstraints(
                  minWidth: (currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0),
                ),
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
        // The package caches totalSwitches in initState() and never revisits
        // it on prop updates, so a switch away from a view with the same
        // ToggleSwitchState but a different icon count (delete action
        // present/absent) crashes on an out-of-range icon lookup. Force a
        // fresh state whenever the icon count changes instead of updating one.
        key: ValueKey('mode-toggle-${toggles.length}'),
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
          widget.view?.items = [];
          navigate = true;
          globalMainViewKey.currentState?.setState(() {});
          Future.delayed(Duration(seconds: 1), () {
            globalActionBar.currentState?.setState(() {
              globalActionBar.currentState?.widget.view = widget.view;
            });
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
      var resolvedColumnName = fieldName ?? mathColName[viewID] ?? TranslateConstants.total.toLowerCase();
      columns.add( GridColumnWidget(
        key: _keyForColumn(resolvedColumnName),
        schema: widget.view?.schema ?? <String, model.SchemaField>{},
        view: widget.view!,
        context: context,
        width: double.nan,
        items: schemeItems,
        maxLength: order.length + (modeIndex[viewID]  == 1 && editMode[viewID] == "math" ? 1 : 0),
        borderColor: Theme.of(context).splashColor,
        allowSorting: datas.isNotEmpty,
        columnName: resolvedColumnName,
        type:  schema[fieldName]?.schema != null && schema[fieldName]!.schema.isNotEmpty && type.contains("int") ? "link" : type,
        url: schema[fieldName]?.valuesPath != "" ? schema[fieldName]?.valuesPath : null,
        contextWidth: currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0,
        label: label == "id" ? GridValueWidget(fontSize: 13, icon: Icons.tag) : GridValueWidget(fontSize: 13, value: realLabel),
      ));
    return columns;
  }
}


// Lets a pure row/filter reload (FilterSelectorWidgetState.resetList()) target
// just the rows, bypassing GridWidgetState.build() entirely — which
// unconditionally rebuilds `columns` from scratch (getColumn() gives every
// header a fresh identity otherwise) even though a filter never changes
// which columns exist, only which rows are shown.
GlobalKey<SubGridWidgetState> globalSubGridKey = GlobalKey<SubGridWidgetState>();
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
  Widget? _lastBuilt;
  int _buildGeneration = 0;

  @override Widget build(BuildContext context) {
    final int myGeneration = ++_buildGeneration;
    final rowsContent = FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        _lastBuilt = a.data!;
        // Only the most recent build's resolution reveals — an in-between
        // one lags a rebuild that already superseded it (e.g. a
        // column-width recheck), and would flash that outdated frame
        // instead of letting the loader hold for the settled one.
        if (gridInitialLoading && myGeneration == _buildGeneration) {
          setGridInitialLoading(false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // ignore: invalid_use_of_protected_member
            globalMainLoaderKey.currentState?.setState(() {});
          });
        }
        return a.data!;
      }
      if (_lastBuilt != null) {
        return _lastBuilt!;
      }
      return SizedBox(
        width: currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0,
        height: currentHeigth - (178 + widget.subSize) > 0 ? currentHeigth - (178 + widget.subSize) : 0,
        child: const LoadingOverlayWidget(standalone: true),
      );
    });
    // A filter-only reload (FilterSelectorWidgetState.resetList()) rebuilds
    // just this State via globalSubGridKey, so its loader lives here too —
    // scoped to the rows, not the whole grid (columns/header untouched).
    if (_explicitReloadCount == 0) { return rowsContent; }
    return Stack(children: [rowsContent, const LoadingOverlayWidget()]);
  }
  Future<Widget> futureBuild(BuildContext context) async {
    
    if (currentView != null && viewID != null) { notNew[viewID] = []; }
    rows = buildRows(getDatas());
    if (allSelected && selectedGrid.isEmpty) { 
      for (var row in rows) { 
        selectedGrid.add("${row.cellID}--${row.schemaID}"); 
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
              // When there are no columns at all (maxWidth stays 0), fall back
              // to the available content width instead of collapsing to a
              // sliver; otherwise keep the original column-driven width.
              width: columns.isEmpty
                  ? (currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0)
                  : maxWidth + widget.scroll + 86.5,
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
                                            if ((widget.view?.items.where((element) => element.values['id'] == item.values['id'] && element.schemaID == item.schemaID) ?? []).isEmpty) { 
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
      bool found = selectedGrid.where((cellID) => cellID.split("--")[0] == mapped.values["id"]).isNotEmpty;
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
  const MainCheckWidget({super.key});
  @override MainCheckWidgetState createState() => MainCheckWidgetState();
}
class MainCheckWidgetState extends State<MainCheckWidget>  {
  
  @override Widget build(BuildContext context) { 
    return Container(
          width: 57, 
          height: modeIndex[viewID]  == 1 && showFunctions[viewID] == true ? 90 : 50, alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(right: BorderSide( 
            color:  globalGridKey.currentState?.widget.borderColor ?? Colors.grey, 
            width:  globalGridKey.currentState?.widget.borderWidth ?? 1 ))),
          child: Checkbox(
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
        );
  }

}
        