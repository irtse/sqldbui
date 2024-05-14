import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/widget/utils/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
// ignore: must_be_immutable
Map<String, String?> filterView = <String, String?>{};
Map<String, Map<String, ValueNotifier<bool>>> colsSchemaValid = <String, Map<String, ValueNotifier<bool>>>{};
GlobalKey<FilterColsPopUpState> filterColsPopUpKey = GlobalKey<FilterColsPopUpState>();
// ignore: must_be_immutable
class FilterColsPopUpWidget extends StatefulWidget{
  String currentFilter = "";
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  FilterColsPopUpWidget ({ Key? key, required this.schema }): super(key: key);
  @override
  FilterColsPopUpState createState() => FilterColsPopUpState();
}

class FilterColsPopUpState extends State<FilterColsPopUpWidget> {
  Map<String, List<dynamic>> filterConfs = {};
  bool force = false;
  @override Widget build(BuildContext context) {
    if (viewID == null) { return Container(); }
    if (filterView.containsKey(viewID) && filterView[viewID] != null && filterView[viewID] != "") { 
      widget.currentFilter = filterView[viewID!]!; 
    }
    return FutureBuilder(future: APIService().get<model.Shallowed>("${currentView!.filterPath}&is_view=true", firstAPI || force, null), builder: (BuildContext context, AsyncSnapshot<APIResponse<model.Shallowed>> snapshot) {
      var dpItems = <DropdownMenuItem<String>>[];
      force = true;
      List<Widget> items = [];
      double max = 0;
      if (snapshot.hasData && snapshot.data!.data != null && snapshot.data!.data!.isNotEmpty) {
        for (var i in snapshot.data!.data!) { 
          filterConfs[i.label!] = i.fields;
          dpItems.add(DropdownMenuItem<String>(value: i.label, child: Text(i.label!, overflow: TextOverflow.ellipsis,),));
        }
      }
      for (var fieldName in widget.schema.keys) {
        if (widget.schema[fieldName]!.label.length * 30 > max) { max = widget.schema[fieldName]!.label.length * 25; }
      }
      if (!colsSchemaValid.containsKey(viewID)) {  colsSchemaValid[viewID!]= <String, ValueNotifier<bool>>{}; }
      for (var fieldName in widget.schema.keys) {
        var label = widget.schema[fieldName]!.label;
        if (!colsSchemaValid[viewID!]!.containsKey(fieldName) || widget.currentFilter == "") { 
          colsSchemaValid[viewID!]![fieldName]= ValueNotifier<bool>(widget.schema[fieldName]!.active); 
        } 
        if (filterConfs.containsKey(widget.currentFilter) && filterConfs[widget.currentFilter] != null) {
          colsSchemaValid[viewID!]![fieldName]!.value = filterConfs[widget.currentFilter]!.contains(fieldName);
        }
        items.add(Padding( padding: const EdgeInsets.symmetric(vertical:  10), child: AdvancedSwitch(
                    initialValue: colsSchemaValid[viewID!]![fieldName]!.value,
                    controller: colsSchemaValid[viewID!]![fieldName],
                    activeColor: Colors.green, inactiveColor: Colors.grey,
                    activeChild: Text(label), inactiveChild: Text("$label <hide>"), 
                    borderRadius:  const BorderRadius.all(Radius.circular(15)),
                    width: max, height: 30.0, disabledOpacity: 0.5,
                    onChanged: (value) => colsSchemaValid[viewID!]![fieldName]!.value = value,)));
      }
      return PopupMenuButton(
      color: Colors.white,
      tooltip: "filter view columns",
      icon: Icon(size: 18, Icons.settings, color: Theme.of(context).highlightColor),
      onSelected: (value) { },
      itemBuilder: (BuildContext bc) { 
        return [ PopupMenuItem(enabled: false, 
            child: Padding(padding: const EdgeInsets.only(top: 20, bottom: 20), child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column( children: [ 
                  Padding( padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10), 
                  child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ const Padding( padding: EdgeInsets.only(right: 10), child: Icon(Icons.list)), 
                    Text("LIST VIEW COLUMNS", style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor)) ])),
                  Divider(color: Theme.of(context).splashColor,),
                  // select all
                  DropdownButtonFormField<String>( items: dpItems, 
                    value: widget.currentFilter != "" ? widget.currentFilter : null,
                    hint: const Text("select an existing view filter...", overflow: TextOverflow.ellipsis,),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    onChanged: (value) {
                      widget.currentFilter = value ?? ""; 
                      filterView[viewID!] = value ?? "";
                      for (var fieldName in widget.schema.keys) {
                        if (filterConfs.containsKey(widget.currentFilter) && filterConfs[widget.currentFilter] != null) {
                          colsSchemaValid[viewID!]![fieldName]!.value = filterConfs[widget.currentFilter]!.contains(fieldName);
                        }
                      } 
                      globalOffset = 0; 
                      rects.remove(viewID);
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                    },
                    dropdownColor: Theme.of(context).highlightColor,
                    decoration: InputDecoration(
                      suffixIconColor: Theme.of(context).primaryColor,
                      errorStyle: const TextStyle(height: -2),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                      fillColor: (Colors.white),
                      hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                      labelText: "view filter",
                    ),
                    validator: (String? value) { return null; },
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: widget.currentFilter != "" ? [
                    IconButton(onPressed: () {
                      List<Map<String, dynamic>> fields = [];
                      for (var fieldName in widget.schema.keys) {
                        if (colsSchemaValid[viewID!]![fieldName]!.value) { fields.add(<String, dynamic>{ "name" : fieldName }); }
                      }
                      var body = <String, dynamic>{ "name" : widget.currentFilter, "link" : currentView!.schemaName, "view_fields" : fields  };
                      APIService().put<model.View>(currentView!.filterPath, body, null);
                    }, icon: const Icon(Icons.save), color: Theme.of(context).secondaryHeaderColor),
                    IconButton(onPressed: () { 
                      APIService().delete<model.View>("${currentView!.filterPath}&name=${widget.currentFilter}", null).then((value) {
                        dpItems.removeWhere((element) => element.value == widget.currentFilter);
                        widget.currentFilter = "";
                        filterView[viewID!] = "";
                        for (var fieldName in widget.schema.keys) {
                          colsSchemaValid[viewID!]![fieldName]= ValueNotifier<bool>(widget.schema[fieldName]!.active);
                        }
                        Future.delayed(const Duration(milliseconds: 500), () => setState((){ force = true; }));
                      },);
                    }, icon: const Icon(Icons.delete), color: Theme.of(context).secondaryHeaderColor),
                  ] : [],),
                  Divider(color: Theme.of(context).splashColor,),
                  Container( constraints: const BoxConstraints(maxHeight: 200), child: SingleChildScrollView( child: Column(children: items))),
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: Divider(color: Theme.of(context).splashColor,)),
                  Row( mainAxisAlignment: MainAxisAlignment.center, children : [ Padding( padding: const EdgeInsets.only(right: 10), 
                    child: TextButton(onPressed: () { 
                      if (widget.currentFilter != "") { filterView[viewID!] = widget.currentFilter;  }
                      globalOffset = 0; 
                      rects.remove(viewID);
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                  }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)), child: const Padding( padding: EdgeInsets.all(10), 
                    child: Text("APPLY", style: TextStyle(color: Colors.white, fontSize: 12))))),
                  filterView.containsKey(viewID) && filterView[viewID] != "" ? 
                  Padding( padding: const EdgeInsets.only(right: 10), 
                    child: TextButton(onPressed: () { 
                    filterView[viewID!]="";
                    widget.currentFilter = "";
                    for (var fieldName in widget.schema.keys) {
                      colsSchemaValid[viewID!]![fieldName]= ValueNotifier<bool>(widget.schema[fieldName]!.active);
                    }
                    setState((){});
                  }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)), child: const Padding( padding: EdgeInsets.all(10), 
                    child: Text("CANCEL", style: TextStyle(color: Colors.white, fontSize: 12))),))
                   : TextButton(onPressed: () {
                    List<Map<String, dynamic>> fields = [];
                    for (var fieldName in widget.schema.keys) {
                      if (colsSchemaValid[viewID!]![fieldName]!.value) { fields.add(<String, dynamic>{ "name" : fieldName }); }
                    }
                    var body = <String, dynamic>{ "link" : currentView!.schemaName, "view_fields" : fields  };
                    APIService().post<model.View>(currentView!.filterPath, body, null).then((value) { 
                      globalOffset = 0; 
                      rects.remove(viewID);
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                      if (value.data != null && value.data!.isNotEmpty && value.data![0].items.isNotEmpty) { 
                        widget.currentFilter = value.data![0].items[0].values["name"];
                        filterView[viewID!] = value.data![0].items[0].values["name"];
                      }
                      dpItems.add(DropdownMenuItem<String>(value: widget.currentFilter, child: Text(widget.currentFilter, overflow: TextOverflow.ellipsis,),));
                      setState((){});
                    });
                  }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)), child: const Padding( padding: EdgeInsets.all(10), 
                    child: Text("SAVE & APPLY", style: TextStyle(color: Colors.white, fontSize: 12))),) ])
      ]); } ) )) ]; });
    }); 
  }
}