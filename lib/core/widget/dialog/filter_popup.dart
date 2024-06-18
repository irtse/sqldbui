import 'dart:developer' as developer;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/widget/utils/grid.dart';
import 'package:sqldbui2/core/widget/utils/filterRow.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:toggle_switch/toggle_switch.dart';

// ignore: must_be_immutable
class FilterPopUpWidget extends StatefulWidget{
  String columnName; 
  String label;
  String type;
  GridColumnWidgetState component; 
  bool? ascOrder;
  bool? descOrder;
  String? searchValue;
  List<DropdownMenuItem<String>> items;
  FilterPopUpWidget ({ Key? key, required this.items,
  required this.columnName, required this.component, required this.label, required this.type }): super(key: key);
  @override FilterPopUpState createState() => FilterPopUpState();
}
class FilterPopUpState extends State<FilterPopUpWidget> {
  List<FilterSearchWidget> advancedSearch = <FilterSearchWidget>[];
  
  @override Widget build(BuildContext context) {
    StateSetter? stateSort;
    StateSetter? stateFilter;
    return PopupMenuButton(
      color: Colors.white,
      icon: const Icon(size: 18, Icons.filter_alt, color: Colors.grey),
      onSelected: (value) { },
      itemBuilder: (BuildContext bc) {
        if (viewID != null && globalOrder.containsKey(viewID)) {
          if (globalOrder[viewID]!.containsKey(widget.columnName)) {
            if(globalOrder[viewID]![widget.columnName] == "asc") { widget.ascOrder = true; }
            if(globalOrder[viewID]![widget.columnName] == "desc") { widget.descOrder = true; }
          }
        }
        return [
          PopupMenuItem(enabled: false, 
            child: Padding(padding: const EdgeInsets.only(top: 20, bottom: 20), child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
              stateSort = setState;
              var rows1 = [
                      const Icon(Icons.arrow_downward, color: Colors.grey, size: 18,), 
                      Padding(padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10), child: Text("SORT ASCENDANT")),
                    ];
              var rows2 = [
                      const Icon(Icons.arrow_upward, color: Colors.grey, size: 18,), 
                      Padding(padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10), child: Text("SORT DESCENDANT")),
                    ];
              if (widget.ascOrder == true) { rows1.add(const Icon(Icons.task_alt, color: Colors.green, size: 18,), ); }
              if (widget.descOrder == true) { rows2.add(const Icon(Icons.task_alt, color: Colors.green, size: 18,), ); }
              return Column(children: [
                Padding(padding: const EdgeInsets.only(left: 5, right: 5), child: TextButton(
                    child: Row(children: rows1), 
                    onPressed: () { 
                      setState(() { 
                        widget.ascOrder = widget.ascOrder != null ? !widget.ascOrder! : true; 
                        if (widget.ascOrder == true) { widget.descOrder = !widget.ascOrder!; 
                        } else { widget.ascOrder = null; }
                      });
                    },  
                )),
                Padding(padding: const EdgeInsets.only(left: 5, right: 5), child: TextButton(
                  child: Row(children: rows2), 
                  onPressed: () { 
                      setState(() { 
                        widget.descOrder =  widget.descOrder != null ? !widget.descOrder! : true; 
                        if (widget.descOrder == true) { widget.ascOrder = !widget.descOrder!; 
                        } else { widget.descOrder = null; }
                      }); 
                    }, )),
                Padding( padding: const EdgeInsets.only(top: 10), child: Divider(color: Theme.of(context).splashColor,)),
              ]); }),)),
          PopupMenuItem(enabled: false, child: StatefulBuilder( builder: (BuildContext context, StateSetter setState) {
            if (currentView != null && globalFilter.containsKey(viewID)) {
              if (globalFilter[viewID]!.has(widget.columnName) && advancedSearch.isEmpty) { 
                for (var filter in globalFilter[viewID]!.get(widget.columnName)) {
                  advancedSearch.add(FilterSearchWidget(innerIndex: advancedSearch.length, state: setState, type: widget.type,
                    filter: this, columnName: widget.columnName, label: widget.label, searchValue: filter.value, 
                    connector: filter.connector, comparator: filter.comparator));
                }
              }
            }
            if (advancedSearch.isEmpty) {
              advancedSearch.add(FilterSearchWidget(filter: this, innerIndex: 0, state: setState, 
                type: widget.type, columnName: widget.columnName, label: widget.label));
            } else if (advancedSearch.length == 1) {
              advancedSearch.add(FilterSearchWidget(filter: this, innerIndex: 0, state: setState, type: widget.type,
                columnName: widget.columnName, label: widget.label, searchValue: advancedSearch.first.searchValue,
                comparator: advancedSearch.first.comparator,));
                advancedSearch.remove(advancedSearch.first);
            }
            stateFilter = setState;
          return Container( 
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView( child: Column(children: [...advancedSearch, 
                                  Divider(color: Theme.of(context).splashColor,)]))); })),
              PopupMenuItem(enabled: false, child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding( padding: const EdgeInsets.only(bottom: 30, top: 10), 
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding( padding: const EdgeInsets.only(right: 10), child: TextButton(onPressed: () {
                    if (viewID != null) { 
                      if (widget.ascOrder != null) { globalOrder[viewID]![widget.columnName]=widget.ascOrder! ? "asc" : "desc"; }
                      if (widget.descOrder != null) { globalOrder[viewID]![widget.columnName]=widget.descOrder! ? "desc" : "asc"; }
                      if (widget.ascOrder == null && widget.descOrder == null) { globalOrder[viewID]?.remove(widget.columnName); }
                      globalFilter[viewID]!.remove(widget.columnName);
                      var founded = filterRowsWidget.where((element) => element.columnName == widget.columnName).toList();
                      for (var search in advancedSearch) { 
                        if (search.globalKey.currentState!.validate() && search.searchValue != null && search.searchValue != "") {
                          if (filterRowsWidget.length > 1 && filterRowsWidget.last.connector == "") { filterRowsWidget.last.connector = "and"; }
                          if (founded.isEmpty) { 
                            filterRowsWidget.add(FilterRowWidget(schema: currentView!.schema, items: widget.items, columnName: search.columnName, type: search.type,
                              value: search.searchValue, comparator: search.comparator, connector: search.connector,
                              label:  search.label == "" ? search.columnName : search.label, index: filterRowsWidget.length));
                            globalFilter[viewID]!.add( search.columnName, Filter(column: search.columnName, label: search.label == "" ? search.columnName : search.label, index: globalFilter[viewID]!.size(), 
                              type: search.type, value: search.searchValue, connector: search.connector, comparator: search.comparator)); 
                            search.index = globalFilter[viewID]!.size();
                          } else {
                            filterRowsWidget[founded.first.index] = FilterRowWidget(schema: currentView!.schema, items: widget.items, columnName: search.columnName, type: search.type,
                              value: search.searchValue, comparator: search.comparator, connector: search.connector,
                              label:  search.label == "" ? search.columnName : search.label, index: founded.first.index);
                            globalFilter[viewID]!.add( search.columnName, Filter(column: search.columnName, label: search.label == "" ? search.columnName : search.label, index: founded.first.index, 
                              type: search.type, value: search.searchValue, connector: search.connector, comparator: search.comparator)); 
                            search.index = founded.first.index;
                            founded.remove(founded.first); 
                          }
                        }
                      }
                      stateSort!(() {}); stateFilter!(() {});
                    }
                    noFilterRetrieval = true;  
                    globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)), child: const Padding( padding: EdgeInsets.all(10), 
                    child: Text("APPLY", style: TextStyle(color: Colors.white, fontSize: 12))),)),
                  TextButton(onPressed: () {
                    resetFilter(widget.columnName);
                    globalMainViewKey.currentState?.refresh(viewID, subViewID, category, null, true);
                    stateSort!(() { widget.ascOrder=null;  widget.descOrder=null; });
                    stateFilter!(() { advancedSearch = []; });
                  }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)), 
                  child: const Padding( padding: EdgeInsets.all(10), child: Text("CLEAR",  style: TextStyle(color: Colors.white, fontSize: 12
            ))))
          ],)); } )) 
        ];
      },
    );
  }
}
// ignore: must_be_immutable
class FilterSearchWidget extends StatefulWidget{
  String columnName; 
  String label;
  String type;
  String? searchValue;
  String connector = "";
  String comparator = "like";
  String? url;
  FilterPopUpState filter;
  int innerIndex;
  int? index;
  StateSetter state;
  var globalKey = GlobalKey<FormFieldState<dynamic>>();
  var fieldText = TextEditingController();
  FilterSearchWidget ({ Key? key, required this.state, this.url,
  required this.columnName, required this.filter, this.comparator = "like",
  required this.type, required this.innerIndex, required this.label, this.connector = "", this.searchValue }): super(key: key);
  @override
  FilterSearchState createState() => FilterSearchState();
}
class FilterSearchState extends State<FilterSearchWidget> {
  bool isNull = false;
  bool isMath = false;
  Widget connectorButton(String conn) {
    return TextButton(onPressed: () {
        if (widget.filter.advancedSearch.length <= widget.innerIndex + 1) { 
          widget.filter.advancedSearch.add(FilterSearchWidget(filter: widget.filter, state: widget.state,
          innerIndex: widget.filter.advancedSearch.length, type: widget.type, columnName: widget.columnName, label: widget.label));
        }
        widget.connector =  widget.connector = widget.connector == conn ? "" :  conn; 
        if (widget.connector == "") { 
          widget.filter.advancedSearch.removeRange(widget.innerIndex + 1, widget.filter.advancedSearch.length); 
        }
        widget.state(() { setState(() {});}); 
      }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(widget.connector == conn ? Theme.of(context).primaryColor : Colors.transparent)), 
      child: Padding( padding: const EdgeInsets.all(10), child: Text(conn.toUpperCase(),  
        style: TextStyle(color: widget.connector == conn ? Colors.white : Colors.grey, fontSize: 11))));
  }

  @override Widget build(BuildContext context) {
    var additionnal = <Widget>[];
    if (widget.innerIndex > 0) {
      additionnal.add(TextButton(onPressed: () {
        widget.filter.advancedSearch.removeRange(widget.innerIndex, widget.filter.advancedSearch.length);
        widget.state(() { }); 
      }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)), 
        child: const Padding( padding: EdgeInsets.all(10), 
          child: Text("DELETE",  style: TextStyle(color: Colors.grey, fontSize: 11)))));
    }
    print(widget.type);
    bool isText = widget.type.contains("text") || widget.type.contains("varchar") || widget.type.contains("link");
    Widget w = Container();
    if (isText || widget.type.contains("double") || widget.type.contains("float") || widget.type.contains("money") || widget.type.contains("decimal") || widget.type.contains("int")) { 
        if (widget.searchValue != null && widget.searchValue != "") { widget.fieldText.text = widget.searchValue!; }
        w = TextFormField( key: widget.globalKey, controller: widget.fieldText, style: const TextStyle(fontSize: 14,),
                enabled: true,  autocorrect: true,  decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor)),
                  isDense: true, hintStyle: const TextStyle(fontSize: 12), // you need this
                  floatingLabelBehavior: FloatingLabelBehavior.always, filled: true,  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  suffixIcon: const Icon(Icons.search),  hintText: "filter ${widget.label}...",  
                  labelText: "value ${isText ? "" : "(numeric)"}",
                  errorStyle: const TextStyle(fontSize: 0,),
                ),
                onChanged: (String? value) { widget.searchValue = value; },
                onSaved: (String? value) {  widget.searchValue = value; },
                validator: (String? value) {
                  if (value == null) { return "please enter a filter value..."; }  
                  if (!isText) {
                    if (value.isEmpty || !RegExp(r'^-?[0-9]*\.?[0-9]*$').hasMatch(value)) { return "please enter a valid number..."; }
                  }
                  return null; 
                });
      } else if (widget.type.contains("bool")) {
        ValueNotifier<bool> ctrl = ValueNotifier(widget.searchValue == "true");
        w = AdvancedSwitch( key: widget.globalKey, 
                    width: 200, initialValue: false, controller: ctrl,
                    activeColor: Colors.green, inactiveColor: Colors.grey,
                    activeChild: Text("active"), inactiveChild: Text("not active"),  
                    borderRadius:  const BorderRadius.all(Radius.circular(15)), height: 30.0, disabledOpacity: 0.5,
                    onChanged: (value) {
                      widget.searchValue = value == true ? "true" : "false";
                      ctrl.value = value; },);
    } else if (widget.type.contains("time") || widget.type.contains("date")) { 
      w = DateTimeField(
        initialValue: widget.searchValue == null ? null : DateTime.parse(widget.searchValue!),
        validator: (DateTime? value) {
          if (value == null) { return ""; }
          return null;
        },
        format: intl.DateFormat('y-M-dd'),
        // mode: widget.type == "time" ? DateTimeFieldPickerMode.time : DateTimeFieldPickerMode.date,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_month, size: 20,),
            suffixIconColor: Theme.of(context).primaryColor,
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
            helperStyle: const TextStyle(height: -2),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            errorStyle: const TextStyle(fontSize: 0),
            fillColor: Colors.white,
            hintStyle: const TextStyle(fontSize: 12, ),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.only(top: 1, left: 20.0, right: 20.0, bottom: 20),
            hintText: "",
            labelText: widget.label.toLowerCase(),
          ),
        onShowPicker: (context, currentValue) { return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: widget.searchValue == null ? currentValue : DateTime.parse(widget.searchValue!),
              lastDate: DateTime(2100));
        },
        onChanged: (DateTime? value) { 
          setState(() { widget.searchValue = value?.toIso8601String(); });  
        },
      );
    } else if (widget.type.contains("enum") ) {
        var items = <DropdownMenuItem<String>>[];
      var values = widget.type.replaceAll("enum__", "").split("_");
      for (var item in values) { 
        if (items.where((element) => element.value == item).isEmpty) {
          items.add(DropdownMenuItem<String>(value: item, child:  Text(item, overflow: TextOverflow.ellipsis,),));
        }
      }
      w = DropdownButtonFormField<String>( items: items, key: widget.globalKey,
        isExpanded: true,
        hint: Text("${"select a"} ${widget.label.replaceAll("db", "").replaceAll("_", " ")}...", overflow: TextOverflow.ellipsis, softWrap: true,),
        value: widget.searchValue,
        validator: (values) { if (values == null) { return "please select a value..."; } return null; },
        style: TextStyle(fontSize: 14, color: Theme.of(context).secondaryHeaderColor, overflow: TextOverflow.ellipsis),
        onChanged: (value) { widget.searchValue = value; }, 
        dropdownColor: Theme.of(context).highlightColor,
        decoration: InputDecoration( isDense: true,
          suffixIconColor: Theme.of(context).primaryColor,
          errorStyle: const TextStyle(height: -2),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true, constraints: const BoxConstraints(minWidth: 0),
          labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
          fillColor:Colors.white, hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
          border: const OutlineInputBorder(),contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
          labelText: "value ${widget.comparator.toUpperCase()}",
        ),
      );
    }
    var togglesMode = ["VALUE", 'NULL'];
    if (!isText) { togglesMode.add("MATH"); }
    var toggles = isMath ? [">", "<", '<=', ">=" ] :  ["LIKE", "!LIKE", '=', "!=" ];
    if (widget.comparator == "") { widget.comparator = "like"; }
    return Column(children: [ 
      /*CheckboxListTileFormField( title: Text("null mode"),
        onChanged: (bool value) { setState(() { isNull = value; }); }, initialValue: isNull, ),*/
      Container( margin: const EdgeInsets.only(bottom: 20),  child: ToggleSwitch( minHeight: 25,
          initialLabelIndex: togglesMode.indexWhere((element) => element.toLowerCase().contains(isMath ? "math" : isNull ? "null" : "value")),
          fontSize: 11, dividerColor: Colors.white, inactiveFgColor: Colors.grey, minWidth: 220 / togglesMode.length,
          totalSwitches: togglesMode.length, labels: togglesMode, inactiveBgColor: Theme.of(context).splashColor,
          onToggle: (index) { setState(() {
            isNull = togglesMode[index ?? 0].toLowerCase().contains("null");
            isMath = togglesMode[index ?? 0].toLowerCase().contains("math");
          });  
        })),
      Row( children : [
        SizedBox( width: 255, child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20 , bottom: 20.0), 
          child: isNull ? DropdownButtonFormField<String>( items: const [
                  DropdownMenuItem<String>(value: "NULL", child: Text("NULL", overflow: TextOverflow.ellipsis,)),
                  DropdownMenuItem<String>(value: "NOT NULL", child: Text("NOT NULL", overflow: TextOverflow.ellipsis,)) 
                ], key: widget.globalKey, isExpanded: true,
                hint: Text("${"select a"} ${widget.label.replaceAll("db", "").replaceAll("_", " ")}...", overflow: TextOverflow.ellipsis, softWrap: true,),
                value: widget.searchValue == "NULL" ? "NULL" : "NOT NULL",
                validator: (values) { if (values == null) { return "please select a value..."; } return null; },
                style: TextStyle(fontSize: 14, color: Theme.of(context).secondaryHeaderColor, overflow: TextOverflow.ellipsis),
                onChanged: (value) { widget.searchValue = value; }, 
                dropdownColor: Theme.of(context).highlightColor,
                decoration: InputDecoration( isDense: true,
                  suffixIconColor: Theme.of(context).primaryColor,
                  errorStyle: const TextStyle(height: -2),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true, constraints: const BoxConstraints(minWidth: 0),
                  labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                  fillColor:Colors.white, hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                  border: const OutlineInputBorder(),contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                  labelText: "value ${widget.comparator.toUpperCase()}",
                )) :  w)) ]), 
              isNull ? Container() : Container( margin: const EdgeInsets.only(bottom: 20),  child: ToggleSwitch(
                initialLabelIndex: toggles.indexWhere((element) => element.toLowerCase() == (widget.comparator.toLowerCase() == "not like" ? "!like" : widget.comparator)),
                fontSize: 11, dividerColor: Colors.white, inactiveFgColor: Colors.grey, minWidth: 220 / toggles.length,
                customWidths: !isMath && !isNull ? [44, 88, 44, 44] : null,
                totalSwitches: toggles.length, labels: toggles, inactiveBgColor: Theme.of(context).splashColor,
                onToggle: (index) { widget.comparator = toggles[index ?? 0].toLowerCase() == "!like" ? "not like" : toggles[index ?? 0].toLowerCase(); },)),
              Divider(color: Theme.of(context).splashColor,),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding( padding: const EdgeInsets.only(right: 10), child: connectorButton("and")),
                  connectorButton("or"), ...additionnal
              ],),
    ] ); 
  }
}