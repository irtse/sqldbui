import 'dart:async';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterSelector.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/function_math_row.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';

Map<String, List<DropdownMenuItem<String>>> schemeItems = {};
Map<String, Map<String,String>> fastTranslation = {};
bool isFilter() {
  return currentView != null && globalOrder.containsKey(viewID) && globalFilter.containsKey(viewID)
  && (globalOrder[viewID]!.isNotEmpty || (globalFilter[viewID] != null && globalFilter[viewID]!.size() > 0));
}
class Value {
  Map<String, model.SchemaField> schema = {};
  String cellID;
  String? dataRef;
  bool isNew = false;
  bool isDraft = false;
  bool isLink = false;
  bool readOnly = false;
  String schemaID;
  model.Sharing? sharing;
  
  Map<String, dynamic> valuesMany = {};
  Map<String, dynamic> values = {};
  Value({ 
    required this.dataRef,
    required this.cellID, 
    required this.isDraft, 
    required this.schemaID,
    this.valuesMany = const {},
    this.values = const {}, 
    this.isLink = true, 
    this.readOnly = false, 
    this.sharing, 
    this.isNew = false,
    required this.schema,
  });
}
bool tempRemoval = false;
bool noFilterRetrieval = false;
int globalLimit = 10;
int globalOffset = 0;
List<String> unselectedGrid = [];
List<String> selectedGrid = []; 
bool allSelected = true;
Map<String?, int> filterIDName = <String, int>{};
Map<String?, String> filterRestr = <String, String>{};
GlobalKey<GridWidgetState> globalGridKey = GlobalKey<GridWidgetState>();
GlobalKey<DatagridWidgetState> globalGridWidgetKey = GlobalKey<DatagridWidgetState>();
// ignore: must_be_immutable
List<FunctionMathRowWidget> functionMathRowsWidget = [];
List<FilterRowWidget> filterRowsWidget = [];
// ignore: must_be_immutable
class DatagridWidget extends StatefulWidget {
  final model.View? view; 
  bool isSelected = true;
  Map<String, dynamic> lines = {};
  GlobalKey<ViewWidgetState>? viewKey;
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};

  DatagridWidget ({ super.key, this.view, this.viewKey });
  @override
  DatagridWidgetState createState() => DatagridWidgetState();
}
bool showMore = true;
class DatagridWidgetState extends State<DatagridWidget> {
  List<DropdownMenuItem<String>> dpItems = <DropdownMenuItem<String>>[];

  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    searchCtrl = {};
    await fillSchemeItem();
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    List<Value> datas = <Value>[];
    Map<String, String> links = <String, String>{};
    dpItems = [];
    if (widget.view != null) {
      schema = widget.view!.schema;
    }
    if ( globalOrder[viewID] == null || globalOrder[viewID]!.isEmpty ) {
      datas.sort( (a, b) =>  (b.values["id"] != null ? int.parse( b.values["id"]) : 0) -  (a.values["id"] != null ? int.parse(a.values["id"]) : 0) );
    }
    return Column( children: [ 
      Container( 
        color: Theme.of(context).primaryColorLight, 
        constraints: const BoxConstraints(minHeight: 40), 
        width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
        child: Column( children: [
          FilterSelectorWidget(
            schema: schema, 
            filterMain: globalFilter[viewID], 
            schemaName: widget.view?.schemaName ?? ""
          ),
          GridWidget( 
            view: widget.view, 
            links: links,
            key: globalGridKey, 
            schema: schema,
            viewKey: widget.viewKey, 
            isSelected: widget.isSelected,
            subWidthSize: menuSize,
            showColumnHeaderIconOnHover: true,
            schemaID: "${currentView?.schemaID}", 
            borderColor: Theme.of(context).splashColor,
            maxLength: realOrder(widget.view, false, false, [], null).length,
            isEnum: schema.keys.where((element) => !["name", "label", "id"].contains(element)).isEmpty,
            contextWidth: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
          ) 
        ])
      ),
    ]);
  }
  Future<void> fillSchemeItem() async {
    var order = realOrder(widget.view, false, false, null, null);
    if (!schemeItems.containsKey(viewID)) {
      schemeItems[viewID ?? ""] = [];
      fastTranslation[viewID ?? ""] = {};
      for (var o in ["id", ...order]) {
        var scheme = widget.view?.schema[o];
    
        var t = scheme?.label ?? o;
        if (scheme?.translatable ?? false) {
          t = (await getOnFlow(t)).toLowerCase();
        }
        fastTranslation[viewID ?? ""]?[scheme?.label ?? o] = t;
        if (schemeItems[viewID ?? ""]!.where( (e) => e.value == o ).isEmpty) {
          schemeItems[viewID ?? ""]?.add(DropdownMenuItem<String>(value: o, child: Text(t, overflow: TextOverflow.ellipsis)));
        }
      }
    }
  }
}


Map<String,String> realOrderMap( List<dynamic>? ord, Map<String, model.SchemaField>? schema,  bool subtable) {
    if (schema == null) { return {}; }
    bool isMath =modeIndex == 1 && editMode[viewID] == "math";
    List<String> seen = [];
    if (!(filterTempOrderView[viewID] != null && modeIndex == 1 && editMode[viewID] == "math")
    && filterOrderView[viewID] == null) {
      var newOrder = schema.keys.where( (e) {
        return schema[e]?.inResume != null; 
      }).toList();
      newOrder.sort( (e1, e2) => (schema[e1]?.inResume ?? 1000).compareTo((schema[e2]?.inResume ?? 1000))  );
      if (newOrder.length < 5 ) {
        for (var o in (ord ?? [])) {
          if (newOrder.length == 5 ) {
            break;
          }
          if (!newOrder.contains(o)) {
            newOrder.add(o);
          }
        }
      }
      if ((ord ?? []).contains("type") && !newOrder.contains("type")) {
        newOrder = ["type", ...newOrder];
      }
      filterTempOrderView[viewID] = newOrder;
    }
    var order = filterTempOrderView[viewID] ?? filterOrderView[viewID] ?? ord ?? [];
    List<dynamic> o = [  ...order.where( (e) => e != "id")].where( (f) {
      String type = f == null ? "float" : (f == "id" ? "integer" : schema[f]?.type ?? "varchar");
      bool active = f == null && f == "id" ? true : schema[f]?.active ?? false;
      bool ok = (f == "id" && !subtable) || !seen.contains(f) && (active && f != "description" && schema[f] != null
          && ((isMath && ["float", "double", "int", "money", "decimal"].contains(type)) || !isMath));
      seen.add(f);
      if ((schema[f]?.type.contains("onetomany") ?? false) && modeIndex == 1) {
        return false;
      }
      return ok;
    }).toList();
    if (filterTempID[viewID] ?? false) {
      o = ["id", ...o];
    }
    Map<String,String> newOrder = {};
    for (var oo in o) {
      newOrder[oo] = schema[oo]?.label ?? oo;
    }
    return newOrder;
  }

List<dynamic> realOrder(model.View? view, bool subtable, bool forceMath, List<dynamic>? forceOrder, int? max) {
    if (view == null) { return []; }
    var schema = view.schema;
    bool isMath = forceMath || (modeIndex == 1 && editMode[viewID] == "math");
    List<String> seen = [];
    if (!(filterTempOrderView[viewID] != null && modeIndex == 1 && editMode[viewID] == "math")
    && filterOrderView[viewID] == null) {
      var newOrder = view.schema.keys.where( (e) {
        return view.schema[e]?.inResume != null; 
      }).toList();
      newOrder.sort( (e1, e2) => (view.schema[e1]?.inResume ?? 1000).compareTo((view.schema[e2]?.inResume ?? 1000))  );
      if (newOrder.length < 5 ) {
        for (var o in view.order) {
          if (newOrder.length == 5 ) {
            break;
          }
          if (!newOrder.contains(o)) {
            newOrder.add(o);
          }
        }
      }
      if (newOrder.isEmpty) {
        filterTempOrderView[viewID] = (forceOrder ?? view.order).sublist(0, (forceOrder ?? view.order).length < (max ?? 1000) ? (forceOrder ?? view.order).length : max);

      } else {
        if (view.order.contains("type") && !newOrder.contains("type")) {
          newOrder = ["type", ...newOrder];
        }
        filterTempOrderView[viewID] = forceOrder ?? newOrder;
      }
    }
    var order = forceOrder ?? filterTempOrderView[viewID] ?? filterOrderView[viewID] ?? view.order;
    
    List<dynamic> o = [  ...order.where( (e) => e != "id")].where( (f) {
      
      String type = f == null ? "float" : (f == "id" ? "integer" : schema[f]?.type ?? "varchar");
      bool ok = (f == "id" && !subtable) || !seen.contains(f) && (f != "description" && schema[f] != null
          && ((isMath && ["float", "double", "int", "money", "decimal"].contains(type)) || !isMath));
      seen.add(f);
      if ((schema[f]?.type.contains("onetomany") ?? false) && modeIndex == 1) {
        return false;
      }
      return !(schema[f]?.hidden ?? false) && (ok);
    }).toList();
    if (filterTempID[viewID] ?? false) {
      o = ["id", ...o];
    }
    return o;
  }