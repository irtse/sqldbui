
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/popup_button.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
bool setLatest = false;
Map<String?, List<dynamic>> filterOrderView = <String?, List<dynamic>>{};
Map<String?, List<dynamic>> filterTempOrderView = <String?, List<dynamic>>{};
Map<String?, String?> filterView = <String?, String?>{};
Map<String?, int> filterViewIDName = <String, int>{};
GlobalKey<FilterColsPopUpState> filterColsPopUpKey = GlobalKey<FilterColsPopUpState>();
// ignore: must_be_immutable
class FilterColsPopUpWidget extends StatefulWidget{
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};

  FilterColsPopUpWidget ({ super.key, required this.schema });
  @override
  FilterColsPopUpState createState() => FilterColsPopUpState();
}

class FilterColsPopUpState extends State<FilterColsPopUpWidget> {
  bool force = false;
  @override Widget build(BuildContext context) {
    if (viewID == null) { return Container(); }
    return FutureBuilder(future: APIService().get<model.Shallowed>("${currentView!.filterPath}&is_view=true", true, null), 
    builder: (BuildContext context, AsyncSnapshot<APIResponse<model.Shallowed>> snapshot) {
      force = true;
      if (snapshot.hasData && snapshot.data!.data != null && snapshot.data!.data!.isNotEmpty) {
        return FutureMenuColsPopUpWidget(comp: this, datas: snapshot.data!.data!, schema: widget.schema);
      }
      return FutureMenuColsPopUpWidget(comp: this, datas: [], schema: widget.schema);
    }); 
  }
}

class FutureMenuColsPopUpWidget extends StatefulWidget{
  FilterColsPopUpState comp;
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  List<model.Shallowed> datas = [];
  FutureMenuColsPopUpWidget ({ 
    super.key, 
    required this.comp,
    required this.schema, 
    required this.datas });
  @override
  FutureMenuColsPopUpState createState() => FutureMenuColsPopUpState();
}

class FutureMenuColsPopUpState extends State<FutureMenuColsPopUpWidget> {
  bool force = false;
  bool noSelection =false;
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
      var dpItems = <DropdownMenuItem<String>>[];
      force = true;
        for (var i in widget.datas) { 
          if (setLatest) {
            filterView[viewID] = i.label ?? i.name;
            setLatest = false;
          }
          if (i.selected && (i.label ?? i.name) == filterView[viewID]) { 
            for (var field in i.fields) {
              if (filterTempOrderView[viewID] == null) { filterTempOrderView[viewID] = []; }
              if (rects[viewID] == null) { rects[viewID] = {}; }
              filterTempOrderView[viewID]!.add(field.column);
              if (field.width != null) { rects[viewID]![field.column!] = Rect.fromCenter(
                center: MediaQuery.of(context).size.center(Offset.zero),
                width: field.width!, height: 55,
              ); }
            }
            filterTempOrderView[viewID] = i.fields.map((e) => e.column).toList();
          }
          filterViewIDName[i.label!] = i.id!;
          var filterLabel = await getOnFlow(i.label ?? i.name ?? "");
          dpItems.add(DropdownMenuItem<String>(value: await getOnFlow(i.label ?? i.name ?? ""), 
            child: Text(filterLabel.toLowerCase(), overflow: TextOverflow.ellipsis,),));
        }
      return PopupButtonWidget(
        color: Colors.white,
        width: 280,
        tooltip: TranslateConstants.filterViewPlaceholder.toLowerCase(), 
        icon: Icons.settings, 
        widget: MenuColsPopUpWidget(comp: widget.comp, items: dpItems, schema: widget.schema,),
      ); 
  }
}

// ignore: must_be_immutable
class MenuColsPopUpWidget extends StatefulWidget{
  FilterColsPopUpState comp;
  List<DropdownMenuItem<String>> items = [];
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  MenuColsPopUpWidget ({ 
    super.key, 
    required this.comp,
    required this.schema, 
    required this.items });
  @override
  MenuColsPopUpState createState() => MenuColsPopUpState();
}

class MenuColsPopUpState extends State<MenuColsPopUpWidget> {
  bool force = false;
  bool noSelection =false;
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column( children: [ 
            Padding( 
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10), 
              child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ const Padding( padding: EdgeInsets.only(right: 10), child: Icon(Icons.list)), 
                    Text(TranslateConstants.filterTitle.toUpperCase(), style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor)) ])),
                  Divider(color: Theme.of(context).splashColor,),
                  // select all
                  ColsPopUpWidget(schema: widget.schema, items: widget.items, comp: this),
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: Divider(color: Theme.of(context).splashColor,)),
                  Row( mainAxisAlignment: MainAxisAlignment.center, children : [ Padding( padding: const EdgeInsets.only(right: 10), 
                    child: TextButton(onPressed: () { 
                      filterOrderView[viewID] = filterTempOrderView[viewID]!;
                      globalOffset = 0; 
                      rects.remove(viewID);
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                  }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
                    child: Padding( padding: EdgeInsets.all(10), 
                      child: Text(TranslateConstants.filterApply.toUpperCase(), style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 12))))),
                  filterView[viewID] != null && filterView[viewID] != "" ? 
                  Padding( padding: const EdgeInsets.only(right: 10), 
                    child: TextButton(onPressed: () async { 
                    await APIService().put<model.View>(currentView!.filterPath.replaceAll("rows=all", 
                      "rows=${filterViewIDName[filterView[viewID]]}"), <String, dynamic> { "is_selected" : false }, null);
                      filterView[viewID] = null;
                      filterOrderView.remove(viewID);
                      filterTempOrderView.remove(viewID);  
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);    
                      Future.delayed(const Duration(seconds: 1), () {
                        setState((){});
                      });
                  }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
                  child: Padding( padding: EdgeInsets.all(10), 
                  child: Text(TranslateConstants.filterCancel.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 12))),))
                  : TextButton(onPressed: () {
                    List<Map<String, dynamic>> fields = [];
                    for (var (index, fieldName) in filterTempOrderView[viewID]!.indexed) {
                      fields.add(<String, dynamic>{ "name" : fieldName, "index" : index, "width" : rects[viewID]?[fieldName]?.width, });
                    }
                    filterOrderView[viewID] = filterTempOrderView[viewID]!;
                    var body = <String, dynamic>{ "link" : currentView!.schemaName, "view_fields" : fields  };
                    APIService().post<model.Shallowed>(currentView!.filterPath, body, null).then((v) async { 
                        globalOffset = 0; 
                        rects.remove(viewID);
                        widget.comp.setState((){  });
                        setLatest = true;
                        if (v.data != null && v.data!.isNotEmpty) {
                          var i = v.data?[0];
                          filterView[viewID] = i!.label ?? i.name ?? "";
                          var filterLabel = await getOnFlow(i.label ?? i.name ?? "");
                          widget.items.add(DropdownMenuItem<String>(value: i.label ?? i.name, child: Text(
                            (await getOnFlow(filterLabel)), overflow: TextOverflow.ellipsis,),));
                        }
                        setState((){});
                        Future.delayed( const Duration(seconds: 1), () {
                          globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                        });
                    });
                  }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
                  child: Padding( padding: EdgeInsets.all(10), 
                  child: Text(TranslateConstants.filterSave.toUpperCase(), 
                    style: const TextStyle(color: Colors.white, fontSize: 12))),) ])
      ]); } ) );
  }
}

// ignore: must_be_immutable
class ColsPopUpWidget extends StatefulWidget{
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  List<DropdownMenuItem<String>> items = [];
  MenuColsPopUpState comp;
  ColsPopUpWidget ({ super.key, required this.schema, required this.items, required this.comp });
  @override
  ColsPopUpState createState() => ColsPopUpState();
}

class ColsPopUpState extends State<ColsPopUpWidget> {
  List<String> order = [];
  bool force = false;
  bool noSelection =false;
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    String? fView;
    if (filterView[viewID] != null) {
      var f = await getOnFlow(filterView[viewID]!);
      fView = f.toLowerCase();
    }
    
    List<Widget> items = [];
    if (filterTempOrderView[viewID] == null) { filterTempOrderView[viewID] = currentView != null ? currentView!.order : []; }
    var list = currentView!.order.where( (fieldName) => !(widget.schema[fieldName] == null || widget.schema[fieldName]!.type.contains("many")));
    for (var (index,fieldName) in list.where( (el) => widget.schema[el] != null).indexed) {
        if (widget.schema[fieldName] == null || widget.schema[fieldName]!.type.contains("many")) { continue; }
        var scheme =  widget.schema[fieldName]!; 
        var label = await getOnFlow(scheme.label);
        items.add(Center( child: Padding( padding: const EdgeInsets.symmetric(vertical: 5), child:  Row( children : [ 
          index == 0 ? Container(width: 44) : Padding( padding: const EdgeInsets.symmetric(horizontal: 10), child: InkWell(
            onTap: () {
              var tmp = filterTempOrderView[viewID]!;
              var i = tmp.removeAt(index);
              var b = tmp.sublist(0, index > 0 ? index - 1 : 0);
              b.add(i);
              b.addAll(tmp.sublist(index > 0 ? index - 1 : 0, tmp.length));
              setState(() { filterTempOrderView[viewID] = b; }); 
            }, child: const Icon(Icons.arrow_upward))),
          Padding( padding: const EdgeInsets.only(right: 10), 
          child: AdvancedSwitch(
            initialValue: filterView[viewID] == null || filterView[viewID] == "" || filterTempOrderView[viewID]!.contains(fieldName),
            activeColor: Colors.green, inactiveColor: Colors.grey,
            activeChild: Text(label.toLowerCase()), inactiveChild: Text(label.toLowerCase()), 
            borderRadius:  const BorderRadius.all(Radius.circular(15)),
            width: 165, height: 30.0, disabledOpacity: 0.5,
            onChanged: (value) { 
              if (value) { 
                var tmp = filterTempOrderView[viewID]!;
                var b = tmp.sublist(0, index);
                b.add(fieldName);
                b.addAll(tmp.sublist(index, tmp.length));
                filterTempOrderView[viewID] = b; 
              } else { filterTempOrderView[viewID]?.remove(fieldName); }
            }
          )),
          index == list.length -1 ? Container() : Padding( padding: const EdgeInsets.only(right: 10), child:  InkWell(onTap: () {
              var tmp = filterTempOrderView[viewID]!;
              var i = tmp.removeAt(index);
              var b = tmp.sublist(0, index + 1);
              b.add(i);
              b.addAll(tmp.sublist(index + 1, tmp.length));
              widget.comp.setState(() { filterTempOrderView[viewID] = b; }); 
            }, child: const Icon(Icons.arrow_downward))),
        ]))));
      }
    return Column(children: [
      DropdownButtonFormField<String>( 
        items: widget.items, 
                    value: fView,
                    hint: Text(TranslateConstants.filterPlaceholder.toLowerCase(), overflow: TextOverflow.ellipsis,),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    onChanged: (value) async {
                      await APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll(
                        "rows=all", "rows=${filterViewIDName[value]}"), <String, dynamic> { "is_selected" : true }, null).then((v) {
                        globalOffset = 0; 
                        rects.remove(viewID);
                        filterView[viewID] = value;
                        filterTempOrderView.remove(viewID);
                        noSelection=false;
                        if (v.data != null && v.data!.isNotEmpty) { 
                          filterTempOrderView[viewID] = v.data![0].fields.map((e) => e.column).toList();
                          filterOrderView[viewID] = filterTempOrderView[viewID]!;
                        } 
                        setState((){});
                        widget.comp.setState((){});
                        globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
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
                      labelText: TranslateConstants.filterLabel.toLowerCase(),
                    ),
                    validator: (String? value) { return null; },
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, 
                    children: filterView[viewID] != null && filterView[viewID] != "" ? [
                    IconButton(onPressed: () {
                      List<Map<String, dynamic>> fields = [];
                      for (var (index, fieldName) in filterTempOrderView[viewID]!.indexed) {
                        fields.add(<String, dynamic>{ "name" : fieldName, "index" : index, "width" : rects[viewID]?[fieldName]?.width, });
                      }
                      filterOrderView[viewID] = filterTempOrderView[viewID]!;
                      var body = <String, dynamic>{  "name" : filterView[viewID], "link" : currentView!.schemaName, "view_fields" : fields  };
                      APIService().put<model.View>(currentView!.filterPath.replaceAll(
                        "rows=all", "rows=${filterViewIDName[filterView[viewID]]}"), body, null).then((value) {
                          globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                        });
                    }, icon: const Icon(Icons.save), color: Theme.of(context).secondaryHeaderColor),
                    IconButton(onPressed: () { 
                      showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "delete filter", validate: () {
                        APIService().delete<model.View>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterViewIDName[filterView[viewID]]}"), null).then((value) {
                          widget.items.removeWhere((element) => element.value == filterView[viewID]);
                          filterView[viewID] = null;
                          filterTempOrderView.remove(viewID);
                          filterOrderView.remove(viewID);
                          noSelection=true;
                          widget.comp.setState((){ });
                          globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                        },);
                      }));
                    }, icon: const Icon(Icons.delete), color: Theme.of(context).secondaryHeaderColor),
                  ] : [],),
                  Divider(color: Theme.of(context).splashColor,),
                  Container( constraints: const BoxConstraints(maxHeight: 200), child: SingleChildScrollView( child: Column(children: items,))),
    ]);
  }
}