import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/utils/text_button.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/column.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';
// ignore: must_be_immutable
class FilterPopUpWidget extends StatefulWidget {
  String columnName; 
  String label;
  String type;
  bool? ascOrder;
  String? searchValue;
  GridColumnWidgetState component; 
  List<DropdownMenuItem<String>> items;
  FilterPopUpWidget ({ 
    super.key, 
    required this.items,
    required this.columnName, 
    required this.component, 
    required this.label, 
    required this.type 
  });
  @override FilterPopUpState createState() => FilterPopUpState();
}
class FilterPopUpState extends State<FilterPopUpWidget> {
  List<FilterSearchWidget> advancedSearch = <FilterSearchWidget>[];
  
  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    StateSetter? stateSort;
    StateSetter? stateFilter;
    var apply = (await getOnFlow(TranslateConstants.filterApply));
    var filter = await getOnFlow(TranslateConstants.filterCancel);
    var asc = await getOnFlow(TranslateConstants.sortASC);
    var desc = await getOnFlow(TranslateConstants.sortDesc);
    return PopupMenuButton(
      tooltip: (await getOnFlow(TranslateConstants.showFilter)).toLowerCase(),
      color: Colors.white,
      padding: const EdgeInsets.all(0.0),
      icon: const Icon(size: 15, Icons.filter_alt, color: Colors.grey),
      onSelected: (value) { },
      itemBuilder: (BuildContext bc) {
        if (viewID != null && globalOrder.containsKey(viewID)) {
          if (globalOrder[viewID]!.containsKey(widget.columnName)) {
            widget.ascOrder = globalOrder[viewID]![widget.columnName] == "asc"; 
          }
        }
        return [
          PopupMenuItem(enabled: false, 
            child: Padding(padding: const EdgeInsets.only(top: 20, bottom: 20), child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
              stateSort = setState;
              var rows1 = [
                      const Icon(Icons.arrow_downward, color: Colors.grey, size: 18,), 
                      Padding(padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10), 
                        child: Text(asc.toUpperCase())),
                    ];
              var rows2 = [
                      const Icon(Icons.arrow_upward, color: Colors.grey, size: 18,), 
                      Padding(padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10), 
                      child: Text(desc.toUpperCase())),
                    ];
              if (widget.ascOrder == true) { rows1.add(const Icon(Icons.task_alt, color: Colors.green, size: 18) ); }
              if (widget.ascOrder == false) { rows2.add(const Icon(Icons.task_alt, color: Colors.green, size: 18) ); }
              return Column(children: [
                TextButtonWidget(
                  onPressed: () { 
                    setState(() { 
                      widget.ascOrder = widget.ascOrder != null ? !widget.ascOrder! : true; 
                    });
                  }, rows: rows1),
                Container( margin: EdgeInsets.only(top: 10), child: TextButtonWidget(
                  onPressed: () { 
                    setState(() { 
                      widget.ascOrder =  widget.ascOrder != null ? !widget.ascOrder! : false; 
                    });
                  }, rows: rows2)),
                Padding( 
                  padding: const EdgeInsets.only(top: 10), 
                  child: Divider(color: Theme.of(context).splashColor)
                ),
              ]); }),)),
          PopupMenuItem(enabled: false, child: StatefulBuilder( builder: (BuildContext context, StateSetter setState) {
            if (currentView != null && globalFilter.containsKey(viewID)) {
              if (globalFilter[viewID]!.has(widget.columnName) && advancedSearch.isEmpty) { 
                for (var filter in globalFilter[viewID]!.get(widget.columnName)) {
                  advancedSearch.add(FilterSearchWidget(innerIndex: advancedSearch.length, state: setState, type: widget.type,
                    filter: this, columnName: widget.columnName, label: widget.label, value: filter.value, 
                    connector: filter.connector, comparator: filter.comparator));
                }
              }
            }
            if (advancedSearch.isEmpty) {
              advancedSearch.add(FilterSearchWidget(filter: this, innerIndex: 0, state: setState, 
                type: widget.type, columnName: widget.columnName, label: widget.label));
            } else if (advancedSearch.length == 1) {
              advancedSearch.add(FilterSearchWidget(filter: this, innerIndex: 0, state: setState, type: widget.type,
                columnName: widget.columnName, label: widget.label, value: advancedSearch.first.value,
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
                      if (widget.ascOrder == null) { globalOrder[viewID]?.remove(widget.columnName); }
                      globalFilter[viewID]!.remove(widget.columnName);
                      var founded = filterRowsWidget.where((element) => element.columnName == widget.columnName).toList();
                      for (var search in advancedSearch) { 
                        if (search.globalKey.currentState!.validate() && search.value != null && search.value != "") {
                          if (filterRowsWidget.length > 1 && filterRowsWidget.last.connector == "") { filterRowsWidget.last.connector = "and"; }
                          if (founded.isEmpty) { 
                            filterRowsWidget.add(FilterRowWidget(
                              schema: currentView!.schema, 
                              columnName: search.columnName, type: search.type,
                              value: search.value, comparator: search.comparator, connector: search.connector,
                              label:  search.label == "" ? search.columnName : search.label, index: filterRowsWidget.length));
                            globalFilter[viewID]!.add( search.columnName, Filter(column: search.columnName, label: search.label == "" ? search.columnName : search.label, index: globalFilter[viewID]!.size(), 
                              type: search.type, value: search.value, connector: search.connector, comparator: search.comparator)); 
                            search.index = globalFilter[viewID]!.size();
                          } else {
                            filterRowsWidget[founded.first.index] = FilterRowWidget(schema: currentView!.schema, columnName: search.columnName, type: search.type,
                              value: search.value, comparator: search.comparator, connector: search.connector,
                              label:  search.label == "" ? search.columnName : search.label, index: founded.first.index);
                            globalFilter[viewID]!.add( search.columnName, Filter(column: search.columnName, label: search.label == "" ? search.columnName : search.label, index: founded.first.index, 
                              type: search.type, value: search.value, connector: search.connector, comparator: search.comparator)); 
                            search.index = founded.first.index;
                            founded.remove(founded.first); 
                          }
                        }
                      }
                      stateSort!(() {}); stateFilter!(() {});
                    }
                    noFilterRetrieval = true;  
                    navigate = true;
                    confirmCache = {};
                    globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                  },
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), child: Padding( padding: EdgeInsets.all(10), 
                    child: Text(apply.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 12))))),
                  TextButton(onPressed: () {
                    resetFilter(widget.columnName);
                    navigate = true;
                    confirmCache = {};
                    globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                    stateSort!(() { widget.ascOrder=null; });
                    stateFilter!(() { advancedSearch = []; });
                  }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
                  child: Padding( padding: EdgeInsets.all(10), child: Text(filter.toUpperCase(), 
                    style: TextStyle(color: Colors.white, fontSize: 12
            ))))
          ],)); } )) 
        ];
      },
    );
  }
}
// ignore: must_be_immutable
class FilterSearchWidget extends StatefulWidget implements ConvertorWidget {
  @override dynamic value;
  String columnName; 
  String label;
  String type;
  String connector = "";
  String comparator = "=";
  String? url;
  FilterPopUpState filter;
  int innerIndex;
  int? index;
  StateSetter state;
  var globalKey = GlobalKey<FormState>();
  var fieldText = TextEditingController();
  FilterSearchWidget ({ 
    super.key, 
    this.url,
    this.value,
    required this.type, 
    required this.label,
    required this.state, 
    required this.filter, 
    required this.innerIndex, 
    required this.columnName, 
    
    this.comparator = "=",
    this.connector = "", 
  });
  @override
  FilterSearchState createState() => FilterSearchState();
}
class FilterSearchState extends State<FilterSearchWidget> {
  bool isNull = false;
  bool isMath = false;
  Future<Widget> connectorButton(String conn) async {
    return TextButton(onPressed: () {
        if (widget.filter.advancedSearch.length <= widget.innerIndex + 1) { 
          widget.filter.advancedSearch.add(FilterSearchWidget(filter: widget.filter, state: widget.state,
            innerIndex: widget.filter.advancedSearch.length, 
            type: widget.type, 
            columnName: widget.columnName, 
            label: widget.label));
        }
        widget.connector =  widget.connector = widget.connector == conn ? "" :  conn; 
        if (widget.connector == "") { 
          widget.filter.advancedSearch.removeRange(widget.innerIndex + 1, widget.filter.advancedSearch.length); 
        }
        widget.state(() { setState(() {});}); 
      }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(
        widget.connector == conn ? Theme.of(context).primaryColor : Colors.transparent)), 
      child: Padding( padding: const EdgeInsets.all(10), child: Text((await getOnFlow(conn)).toUpperCase(),  
        style: TextStyle(color: widget.connector == conn ? Colors.white : Colors.grey, fontSize: 11))));
  }

  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    var additionnal = <Widget>[];
    if (widget.innerIndex > 0) {
      additionnal.add(TextButton(onPressed: () {
        widget.filter.advancedSearch.removeRange(widget.innerIndex, widget.filter.advancedSearch.length);
        widget.state(() { }); 
      }, 
      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.transparent)), 
      child: Padding( padding: EdgeInsets.all(10), 
        child: Text((await getOnFlow(TranslateConstants.delete)).toUpperCase(),  style: TextStyle(color: Colors.grey, fontSize: 11)))));
    }
    bool isText = widget.type.contains("text") || widget.type.contains("varchar") || widget.type.contains("link") || widget.type.contains("enum") || widget.type.contains("upload");
    String url = currentView!.schema[widget.columnName] == null ? "" : "${currentView!.schema[widget.columnName]!.actionPath}&shallow=enable";
    
    Widget w = await Convertor.filterFieldByType(
      context, widget as ConvertorWidget, widget.type, "", TranslateConstants.valueFilterPlaceholder.toLowerCase(), 
      this, false, false, url, url, "", []
    );
    var togglesMode = [TranslateConstants.value.toUpperCase(), 'NULL'];
    var togglesLabels = [(await getOnFlow(TranslateConstants.value)).toUpperCase(), 'NULL'];
    if (!isText) { 
      togglesMode.add("MATH"); 
      togglesLabels.add(await getOnFlow("MATH")); 
    }
    var toggles = isMath ? [">", "<", '<=', ">=" ] : (widget.type.contains("enum") || widget.type.contains("link") ? ['=', "!=" ] : ( widget.type.contains("upload") ? ["LIKE", "!LIKE"] : ["LIKE", "!LIKE", '=', "!=" ]));
    if (widget.comparator == "") { widget.comparator = widget.type.contains("enum") || widget.type == "link" ? "=" : "like"; }
    return Column(children: [ 
      Container( margin: const EdgeInsets.only(bottom: 20, top: 10),  
      child: ToggleSwitch( 
        minHeight: 25,
          initialLabelIndex: togglesMode.indexWhere((element) => element.toLowerCase().contains(isMath ? "math" : isNull ? "null" : TranslateConstants.value.toLowerCase())),
          fontSize: 11, dividerColor: Colors.white, 
          inactiveFgColor: Colors.grey, 
          minWidth: 220 / togglesLabels.length,
          totalSwitches: togglesLabels.length, 
          labels: togglesLabels, 
          inactiveBgColor: Theme.of(context).splashColor,
          onToggle: (index) { setState(() {
            isNull = togglesMode[index ?? 0].toLowerCase().contains("null");
            isMath = togglesMode[index ?? 0].toLowerCase().contains("math");
          });  
        })),
      Form( key: widget.globalKey, child: Row( children : [
        SizedBox( width: 255, child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20 , bottom: 20.0), 
          child: isNull ? DropdownButtonFormField<String>( items: const [
                  DropdownMenuItem<String>(value: "NULL", child: Text("NULL", overflow: TextOverflow.ellipsis,)),
                  DropdownMenuItem<String>(value: "NOT NULL", child: Text("NOT NULL", overflow: TextOverflow.ellipsis,)) 
                ], isExpanded: true,
                hint: Text("${(await getOnFlow(TranslateConstants.select)).toLowerCase()} ${await getOnFlow(widget.label.replaceAll("db", "").replaceAll("_", " "))}...".toLowerCase(), 
                  overflow: TextOverflow.ellipsis, softWrap: true ),
                value: widget.value == "NULL" ? "NULL" : "NOT NULL",
                validator: (values) { if (values == null) { return ""; } return null; },
                style: TextStyle(fontSize: 14, color: Theme.of(context).secondaryHeaderColor, overflow: TextOverflow.ellipsis),
                onChanged: (value) { widget.value = value; }, 
                dropdownColor: Theme.of(context).highlightColor,
                decoration: InputDecoration( 
                  isDense: true,
                  suffixIconColor: Theme.of(context).primaryColor,
                  errorStyle: const TextStyle(height: -2),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true, constraints: const BoxConstraints(minWidth: 0),
                  labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                  fillColor:Colors.white, hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                  border: const OutlineInputBorder(),contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                  labelText: "${(await getOnFlow(TranslateConstants.value.toLowerCase())).toLowerCase()} ${widget.comparator.toUpperCase()}",
                )) : w)) 
      ])), 
      isNull ? Container() : Container( margin: const EdgeInsets.only(bottom: 20),  child: ToggleSwitch(
        initialLabelIndex: toggles.indexWhere((element) => element.toLowerCase() == (widget.comparator.toLowerCase() == "not like" ? "!like" : widget.comparator)),
        fontSize: 11, dividerColor: Colors.white, inactiveFgColor: Colors.grey, minWidth: 220 / toggles.length,
        customWidths: !isMath && !isNull ? [55, 55, 55, 55] : null,
        totalSwitches: toggles.length, labels: toggles, inactiveBgColor: Theme.of(context).splashColor,
        onToggle: (index) { widget.comparator = toggles[index ?? 0].toLowerCase() == "!like" ? "not like" : toggles[index ?? 0].toLowerCase(); },)),
      Divider(color: Theme.of(context).splashColor,),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding( padding: const EdgeInsets.only(right: 10), child: await connectorButton("and")),
                  await connectorButton("or"), ...additionnal
      ],), 
    ]); 
  }
}