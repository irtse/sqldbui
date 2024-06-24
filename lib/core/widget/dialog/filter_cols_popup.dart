import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
// ignore: must_be_immutable
Map<String?, List<dynamic>> filterOrderView = <String?, List<dynamic>>{};
Map<String?, List<dynamic>> filterTempOrderView = <String?, List<dynamic>>{};
Map<String?, String?> filterView = <String?, String?>{};
Map<String?, int> filterViewIDName = <String, int>{};
GlobalKey<FilterColsPopUpState> filterColsPopUpKey = GlobalKey<FilterColsPopUpState>();
// ignore: must_be_immutable
class FilterColsPopUpWidget extends StatefulWidget{
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  FilterColsPopUpWidget ({ Key? key, required this.schema }): super(key: key);
  @override
  FilterColsPopUpState createState() => FilterColsPopUpState();
}

class FilterColsPopUpState extends State<FilterColsPopUpWidget> {
  bool force = false;
  @override Widget build(BuildContext context) {
    if (viewID == null) { return Container(); }
    return FutureBuilder(future: APIService().get<model.Shallowed>("${currentView!.filterPath}&is_view=true", firstAPI | force, null), 
    builder: (BuildContext context, AsyncSnapshot<APIResponse<model.Shallowed>> snapshot) {
      var dpItems = <DropdownMenuItem<String>>[];
      force = true;
      if (snapshot.hasData && snapshot.data!.data != null && snapshot.data!.data!.isNotEmpty) {
        for (var i in snapshot.data!.data!) { 
          if (filterView[viewID] == "") { filterView[viewID] = i.label ?? ""; }
          if (i.selected && (i.label ?? i.name) == filterView[viewID]) { 
            filterOrderView[viewID] = i.fields.map((e) => e.column).toList();
          }
          filterViewIDName[i.label!] = i.id!;
          dpItems.add(DropdownMenuItem<String>(value: i.label, child: Text(i.label!, overflow: TextOverflow.ellipsis,),));
        }
      }
      return PopupMenuButton(
      color: Colors.white,
      tooltip: "filter view columns",
      icon: Icon(size: 18, Icons.settings, color: Theme.of(context).highlightColor),
      onSelected: (value) { },
      itemBuilder: (BuildContext bc) { 
        return [ PopupMenuItem(enabled: false, 
            child: MenuColsPopUpWidget(items: dpItems, schema: widget.schema,)) ]; });
    }); 
  }
}

class MenuColsPopUpWidget extends StatefulWidget{
  List<DropdownMenuItem<String>> items = [];
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  MenuColsPopUpWidget ({ Key? key, required this.schema, required this.items }): super(key: key);
  @override
  MenuColsPopUpState createState() => MenuColsPopUpState();
}

class MenuColsPopUpState extends State<MenuColsPopUpWidget> {
  bool force = false;
  bool noSelection =false;
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(top: 20, bottom: 20), child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column( children: [ 
                  Padding( padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10), 
                  child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ const Padding( padding: EdgeInsets.only(right: 10), child: Icon(Icons.list)), 
                    Text("LIST VIEW COLUMNS", style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor)) ])),
                  Divider(color: Theme.of(context).splashColor,),
                  // select all
                  ColsPopUpWidget(schema: widget.schema, items: widget.items, comp: this),
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: Divider(color: Theme.of(context).splashColor,)),
                  Row( mainAxisAlignment: MainAxisAlignment.center, children : [ Padding( padding: const EdgeInsets.only(right: 10), 
                    child: TextButton(onPressed: () { 
                      if (filterView[viewID] != null && filterView[viewID] != "") { filterView[viewID] = filterView[viewID];  }
                      globalOffset = 0; 
                      rects.remove(viewID);
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                  }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)), 
                    child: const Padding( padding: EdgeInsets.all(10), 
                      child: Text("APPLY", style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 12))))),
                  filterView[viewID] != null && filterView[viewID] != "" ? 
                  Padding( padding: const EdgeInsets.only(right: 10), 
                    child: TextButton(onPressed: () async { 
                    await APIService().put<model.View>(currentView!.filterPath.replaceAll("rows=all", 
                      "rows=${filterViewIDName[filterView[viewID]]}"), <String, dynamic> { "is_selected" : false }, null);
                      setState((){
                        filterView[viewID] = "";
                        filterOrderView.remove(viewID);
                        noSelection=true;
                      });
                      Future.delayed(const Duration(seconds: 1), () => globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true) );
                  }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)), child: const Padding( padding: EdgeInsets.all(10), 
                  child: Text("CANCEL", style: TextStyle(color: Colors.white, fontSize: 12))),))
                  : TextButton(onPressed: () {
                    List<Map<String, dynamic>> fields = [];
                    for (var (index, fieldName) in filterOrderView[viewID]!.indexed) {
                      fields.add(<String, dynamic>{ "name" : fieldName, "index" : index });
                    }
                    var body = <String, dynamic>{ "link" : currentView!.schemaName, "view_fields" : fields  };
                    APIService().post<model.View>(currentView!.filterPath, body, null).then((value) { 
                      globalOffset = 0; 
                      rects.remove(viewID);
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                      if (value.data != null && value.data!.isNotEmpty && value.data![0].items.isNotEmpty) { 
                        filterView[viewID] = value.data![0].items[0].values["name"];
                      }
                      widget.items.add(DropdownMenuItem<String>(value: filterView[viewID], 
                                        child: Text(filterView[viewID] ?? "", overflow: TextOverflow.ellipsis,),));
                      setState((){});
                    });
                  }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)), child: Padding( padding: EdgeInsets.all(10), 
                  child: Text("SAVE & APPLY", style: const TextStyle(color: Colors.white, fontSize: 12))),) ])
      ]); } ) );
  }
}

class ColsPopUpWidget extends StatefulWidget{
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  List<DropdownMenuItem<String>> items = [];
  MenuColsPopUpState comp;
  ColsPopUpWidget ({ Key? key, required this.schema, required this.items, required this.comp }): super(key: key);
  @override
  ColsPopUpState createState() => ColsPopUpState();
}

class ColsPopUpState extends State<ColsPopUpWidget> {
  bool force = false;
  bool noSelection =false;
  @override Widget build(BuildContext context) {
    List<Widget> items = [];
    if (filterOrderView[viewID] == null) { filterOrderView[viewID] = currentView != null ? currentView!.order : []; }
    var t = widget.schema.keys.where((element) => !filterOrderView[viewID]!.contains(element)).toList();
    var list = [...filterOrderView[viewID]!, ...t];
    for (var (index,fieldName) in list.where( (el) => widget.schema[el] != null).indexed) {
        var scheme =  widget.schema[fieldName]!; 
        var label = scheme.label;
        items.add(Center( child: Padding( padding: const EdgeInsets.symmetric(vertical: 5), child:  Row( children : [ 
          index == 0 ? Container(width: 44,) : Padding( padding: const EdgeInsets.symmetric(horizontal: 10), child: InkWell(
            onTap: () {
              var tmp = filterOrderView[viewID]!;
              var i = tmp.removeAt(index);
              var b = tmp.sublist(0, index - 1);
              b.add(i);
              b.addAll(tmp.sublist(index - 1, tmp.length));
              setState(() { filterOrderView[viewID] = b; }); 
            }, child: const Icon(Icons.arrow_upward))),
          Padding( padding: const EdgeInsets.only(right: 10), 
          child: AdvancedSwitch(
            initialValue: filterOrderView[viewID]!.contains(fieldName),
            activeColor: Colors.green, inactiveColor: Colors.grey,
            activeChild: Text(label), inactiveChild: Text(label), 
            borderRadius:  const BorderRadius.all(Radius.circular(15)),
            width: 165, height: 30.0, disabledOpacity: 0.5,
            onChanged: (value) { 
              if (value) { filterOrderView[viewID]?.add(fieldName); } else { filterOrderView[viewID]?.remove(fieldName); }
            },)),
          index == list.length -1 ? Container() : Padding( padding: const EdgeInsets.only(right: 10), child:  InkWell(onTap: () {
              var tmp = filterOrderView[viewID]!;
              var i = tmp.removeAt(index);
              var b = tmp.sublist(0, index + 1);
              b.add(i);
              b.addAll(tmp.sublist(index + 1, tmp.length));
              setState(() { filterOrderView[viewID] = b; }); 
            }, child: Icon(Icons.arrow_downward))),
        ]))));
      }
    return Column(children: [
      DropdownButtonFormField<String>( items: widget.items, 
                    value: filterView[viewID] != null && filterView[viewID] != "" ? filterView[viewID] : null,
                    hint: const Text("select an existing view filter...", overflow: TextOverflow.ellipsis,),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    onChanged: (value) async {
                      await APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll(
                        "rows=all", "rows=${filterViewIDName[value]}"), <String, dynamic> { "is_selected" : true }, null).then((v) {
                        globalOffset = 0; 
                        rects.remove(viewID);
                        filterView[viewID] = value;
                        filterOrderView.remove(viewID);
                        noSelection=false;
                        if (v.data != null && v.data!.isNotEmpty) { 
                          filterOrderView[viewID] = v.data![0].fields.map((e) => e.column).toList();
                        } 
                        setState((){});
                        widget.comp.setState((){});
                        globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                      });
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
                  Row(mainAxisAlignment: MainAxisAlignment.center, 
                    children: filterView[viewID] != null && filterView[viewID] != "" ? [
                    IconButton(onPressed: () {
                      List<Map<String, dynamic>> fields = [];
                      var body = <String, dynamic>{ "name" : filterView[viewID], "link" : currentView!.schemaName, "view_fields" : fields  };
                      APIService().put<model.View>(currentView!.filterPath, body, null);
                    }, icon: const Icon(Icons.save), color: Theme.of(context).secondaryHeaderColor),
                    IconButton(onPressed: () { 
                      showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "delete filter", validate: () {
                        APIService().delete<model.View>("${currentView!.filterPath}".replaceAll("rows=all", "rows=${filterViewIDName[filterView[viewID]]}"), null).then((value) {
                          widget.items.removeWhere((element) => element.value == filterView[viewID]);
                          setState((){
                            filterView[viewID] = "";
                            filterOrderView.remove(viewID);
                            noSelection=true;
                          });
                          Future.delayed(const Duration(milliseconds: 500), () => setState((){ force = true; }));
                        },);
                      }));
                    }, icon: const Icon(Icons.delete), color: Theme.of(context).secondaryHeaderColor),
                  ] : [],),
                  Divider(color: Theme.of(context).splashColor,),
                  Container( constraints: const BoxConstraints(maxHeight: 200), child: SingleChildScrollView( child: Column(children: items,))),
    ]);
  }
}