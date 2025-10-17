import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
// ignore: must_be_immutable
class MainGridWidget extends StatefulWidget {
  int subSize;
  double subWidthSize;
  bool subTable = false;
  final model.View? view; 
  bool isSelected = true;
  List<dynamic>? forceOrder;
  Map<String, String> links = {};
  GlobalKey<ViewWidgetState>? viewKey;
  Map<String, model.SchemaField> schema = {};

  MainGridWidget ({ super.key, 
    this.view, 
    this.viewKey, 
    required this.schema,
    required this.subWidthSize, 
    this.forceOrder,
    this.links = const {}, 
    this.isSelected = false, 
    required this.subSize, 
    this.subTable = false 
  });
  @override
  MainGridWidgetState createState() => MainGridWidgetState();
}
class MainGridWidgetState extends State<MainGridWidget> {
  @override Widget build(BuildContext context) {
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    Map<String, model.Shallowed> contentShallowed = <String, model.Shallowed>{};
    return Container( 
        height: widget.subTable ? null : currentHeigth - (120 + widget.subSize) > 0 ? 
          currentHeigth - (120 + widget.subSize) : 0,
        width: (currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0),
        decoration: BoxDecoration( 
          color:  Theme.of(context).highlightColor
        ), 
        child : GridWidget( 
          view: widget.view, 
          links: widget.links,
          key: globalGridKey, 
          schema: widget.schema,
          viewKey: widget.viewKey, 
          forceOrder: widget.forceOrder,
          isSelected: widget.isSelected,
          subWidthSize: widget.subWidthSize,
          showColumnHeaderIconOnHover: true,
          contentShallowed: contentShallowed,  
          schemaID: "${currentView?.schemaID}", 
          showCheckboxColumn: !widget.subTable, 
          borderColor: Theme.of(context).splashColor,
          maxLength: realOrder(widget.view, widget.subTable, false, [], 5).length,
          isEnum: schema.keys.where((element) => !["name", "label", "id"].contains(element)).isEmpty,
          contextWidth: currentWidth - widget.subWidthSize > 0 ? currentWidth - widget.subWidthSize : 0,
        ) 
      );
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

List<dynamic> realOrder(model.View? view, bool subtable, bool forceMath, List<dynamic>? forceOrder, int max) {
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
        filterTempOrderView[viewID] = (forceOrder ?? view.order).sublist(0, (forceOrder ?? view.order).length < max ? (forceOrder ?? view.order).length : max);

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