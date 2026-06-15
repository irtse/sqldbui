import 'package:flutter/foundation.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/src/multi_dropdown.dart';
import 'package:sqldbui2/core/widget/utils/text_button.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/column.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';
// ignore: must_be_immutable
class FilterPopUpWidget extends StatefulWidget {
  model.View view;
  String columnName; 
  String label;
  String type;
  bool? ascOrder;
  String? searchValue;
  GridColumnWidgetState component; 
  List<DropdownMenuItem<String>> items;
  Map<String, model.SchemaField> schema;
  FilterPopUpWidget ({ 
    super.key, 
    required this.view,
    required this.items,
    required this.columnName, 
    required this.component, 
    required this.label, 
    required this.type,
    required this.schema,
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
    final trad = await Future.wait([
      getOnFlow(TranslateConstants.filterApply),
      getOnFlow(TranslateConstants.filterCancel),
      getOnFlow(TranslateConstants.sortASC),
      getOnFlow(TranslateConstants.sortDesc),
    ]);
    var apply = trad[0];
    var filter = trad[1];
    var asc = trad[2];
    var desc = trad[3];
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
                  List<String> d = filter.realName?.split(".") ?? [];
                  if (d.length > 1) {
                    d = d.sublist(1, d.length);
                  }
                  advancedSearch.add(FilterSearchWidget(
                    innerIndex: advancedSearch.length, 
                    state: setState, 
                    subName: d,
                    type: widget.type,
                    filter: this, 
                    columnName: widget.columnName, 
                    label: widget.label, 
                    value: filter.value, 
                    connector: filter.connector, 
                    comparator: filter.comparator, 
                    schema: widget.schema,));
                }
              }
            }
            if (advancedSearch.isEmpty) {
              advancedSearch.add(FilterSearchWidget(
                filter: this,
                innerIndex: 0, 
                subName: [],
                state: setState, 
                schema: widget.schema,
                type: widget.type,
                columnName: widget.columnName, 
                label: widget.label));
            } else if (advancedSearch.length == 1) {
              advancedSearch.add(FilterSearchWidget(
                filter: this, 
                subName: advancedSearch.first.subName,
                schema: advancedSearch.first.schema, 
                innerIndex: 0, 
                state: setState, 
                type: widget.type,
                columnName: widget.columnName, 
                label: widget.label, 
                value: advancedSearch.first.value,
                comparator: advancedSearch.first.comparator));
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
                      globalFilter[viewID]?.remove(widget.columnName);
                      var founded = filterRowsWidget[viewID]?.where((element) => element.columnName == widget.columnName).toList() ?? [];
                     
                      for (var search in advancedSearch) { 
                        if ((search.globalKey.currentState?.validate() ?? true) && search.value != null && search.value != "") {
                          if ((filterRowsWidget[viewID] ?? []).length > 1 && filterRowsWidget[viewID]?.last.connector == "") { 
                            filterRowsWidget[viewID]?.last.connector = "and"; 
                          }
                          if (founded.isEmpty) { 
                            filterRowsWidget[viewID]?.add(FilterRowWidget(
                              view: widget.view,
                              beforeColumn: [search.columnName, ...search.subName],
                              schema: currentView!.schema, 
                              columnName: search.columnName, type: search.type,
                              value: search.value, comparator: search.comparator, connector: search.connector,
                              label:  search.label == "" ? search.columnName : search.label, index: (filterRowsWidget[viewID] ?? []).length));
                            globalFilter[viewID]?.add( 
                              search.columnName, Filter(
                                realName: [search.columnName, ...search.subName].join("."),
                                column: search.columnName, label: search.label == "" ? search.columnName : search.label, index: globalFilter[viewID]!.size(), 
                                type: search.type, value: search.value, connector: search.connector, comparator: search.comparator)); 
                            search.index = globalFilter[viewID]?.size();
                          } else {
                            filterRowsWidget[viewID]?[founded.first.index] = FilterRowWidget(
                              view: widget.view,
                              beforeColumn: [search.columnName, ...search.subName],
                              schema: currentView!.schema, columnName: search.columnName, type: search.type,
                              value: search.value, comparator: search.comparator, connector: search.connector,
                              label:  search.label == "" ? search.columnName : search.label, index: founded.first.index);
                            globalFilter[viewID]?.add( search.columnName, Filter(
                              realName: [search.columnName, ...search.subName].join("."),
                              column: search.columnName, label: search.label == "" ? search.columnName : search.label, index: founded.first.index, 
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
                    Navigator.of(context).pop();
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
  FilterSearchState? comp;
  String columnName; 
  String label;
  String type;
  String connector = "";
  String comparator = "=";
  String? url;
  FilterPopUpState filter;
  int innerIndex;
  int? index;
  Map<String, model.SchemaField> schema;
  StateSetter state;
  var globalKey = GlobalKey<FormState>();
  var fieldText = TextEditingController();

  int depth = 0;
  List<String> subName = [];

  FilterSearchWidget ({ 
    super.key, 
    this.url,
    this.comp,
    this.value,
    this.depth = 0,
    required this.subName,
    required this.type, 
    required this.label,
    required this.state, 
    required this.filter, 
    required this.innerIndex, 
    required this.columnName,
    required this.schema, 
    
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
          widget.filter.advancedSearch.add(FilterSearchWidget(
            filter: widget.filter, 
            state: widget.state,
            subName: widget.subName,
            innerIndex: widget.filter.advancedSearch.length, 
            schema: widget.schema,
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
    if (widget.type.contains("onetomany") && widget.schema[widget.columnName] != null) {
      MultiSelectController<String> ctrls = MultiSelectController<String>();
      List<DropdownItem<String>> items = [];
      final entries = widget.schema[widget.columnName]!.schema.entries.where((e) => !e.value.hidden).toList();
      final entryLabels = await Future.wait(entries.map((o) => getOnFlow(o.value.label)));
      if (!context.mounted) return Container();
      for (var (i, o) in entries.indexed) {
        items.add(DropdownItem<String>(value: o.key,
          label: entryLabels[i],
          selected: widget.subName.length > widget.depth && o.key == widget.subName[widget.depth]));
        ctrls.addItem(items.last);
      }
      Widget w = Container();
      if (widget.subName.isNotEmpty) {
         w = FilterSearchWidget(
            comp: widget.comp ?? this,
            subName: widget.subName,
            depth: widget.depth + 1,
            columnName: widget.subName[widget.depth], 
            type:  widget.schema[widget.columnName]?.schema[widget.subName[widget.depth]]?.type ?? "", 
            label: widget.schema[widget.columnName]?.schema[widget.subName[widget.depth]]?.label ?? "", 
            state: widget.state, 
            value: widget.value,
            filter: widget.filter, 
            innerIndex: widget.innerIndex, 
            schema: widget.schema[widget.columnName]?.schema ?? {});
      }
      final uiTrad = await Future.wait([
        getOnFlow("select a field"),
        getOnFlow(TranslateConstants.search),
        getOnFlow(TranslateConstants.selectValue),
      ]);
      if (!context.mounted) return Container();
      return Column( children: [
        Padding( padding: EdgeInsets.only(bottom: 20), child: MultiDropdown<String>(
        controller: ctrls,
        singleSelect: true,
        items: items,
        label: "tp",
        searchEnabled: true,
        style: TextStyle(color: Theme.of(context).secondaryHeaderColor ),
        chipDecoration: ChipDecoration(
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
        ),
        fieldDecoration: FieldDecoration(
          padding: kIsWeb ? EdgeInsets.only(left: 12, right: 12, top: 12) : EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(fontSize: 0),
          hintText: uiTrad[0].toLowerCase(),
          hintStyle: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w300),
          prefixIcon: Icon(Icons.list, color: Colors.grey),
          showClearIcon: false,
          border:  OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0)),
          focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0)),
        ),
        searchDecoration: SearchFieldDecoration(
          hintText: "       ${uiTrad[1].toLowerCase()}",
          border : const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          focusedBorder : const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(5))
          )
        ),
        dropdownDecoration: DropdownDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          marginTop: 2,
          maxHeight: 400,
          header: Padding(
            padding: EdgeInsets.all(8),
              child: Text(
                "       ${uiTrad[2].toLowerCase()}",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          dropdownItemDecoration: DropdownItemDecoration(
            backgroundColor: Theme.of(context).highlightColor,
            selectedIcon: const Icon(Icons.check_box, color: Colors.green),
            disabledIcon: Icon( Icons.lock, color: Colors.grey.shade300) ),
            validator: (value) {
              if ((value == null || value.isEmpty)) {
                return '';
              }
              return null;
            },
            onSelectionChange: (values) {
                if (values.isEmpty)  { return; }
                Future.delayed(Duration(milliseconds: widget.subName.length - 1 == widget.depth ? 100 : 0), () {
                  setState(() {
                    if (widget.subName.length <= widget.depth) {
                      widget.subName.add(values[0]);
                    } else {
                      widget.subName[widget.depth] = values[0];
                    }
                    widget.value = null;
                    widget.comp?.widget.value = null;
                    widget.comp?.widget.subName = widget.subName;
                  });
                });
                setState(() {
                  if (widget.subName.length - 1 == widget.depth) {
                    widget.subName.removeLast();
                  }
                  widget.value = null;
                  widget.comp?.widget.value = null;
                  widget.comp?.widget.subName = widget.subName;
                });
              },
            )),
            w,
        
      ]);
    }
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
    String url = widget.schema[widget.columnName] == null ? "" : "${widget.schema[widget.columnName]?.actionPath}&shallow=enable";
    String valuesP = widget.schema[widget.columnName] == null ? "" : widget.schema[widget.columnName]!.valuesPath;
    Widget w = await Convertor.filterFieldByType(
      context, ( widget.comp?.widget ?? widget) as ConvertorWidget, widget.type, "", TranslateConstants.valueFilterPlaceholder.toLowerCase(), 
      this, false, false, url, valuesP, "", []
    );
    var togglesMode = [TranslateConstants.value.toUpperCase(), 'NULL'];
    if (!isText) { 
      togglesMode.add("MATH"); 
    }
    var toggles = isMath ? [">", "<", '<=', ">=" ] : (widget.type.contains("enum") || widget.type.contains("link") ? ['=', "!=" ] : ( widget.type.contains("upload") ? ["LIKE", "!LIKE"] : ["LIKE", "!LIKE", '=', "!=" ]));
    if (widget.comparator == "") { widget.comparator = widget.type.contains("enum") || widget.type == "link" ? "=" : "like"; }
    var index = 0; 
    try {
      index = togglesMode.indexWhere((element) => element.toLowerCase().contains(isMath ? "math" : isNull ? "null" : TranslateConstants.value.toLowerCase()));
    } catch(e){}
    return Column(children: [ 
      Container( 
      margin: const EdgeInsets.only(bottom: 20, top: 10),  
      child: ToggleSwitch( 
        minHeight: 25,
        initialLabelIndex: index,
        fontSize: 11, 
        totalSwitches: togglesMode.length,
        dividerColor: Colors.white, 
        inactiveFgColor: Colors.grey, 
        minWidth: 220 / togglesMode.length,
        labels: togglesMode, 
        inactiveBgColor: Theme.of(context).splashColor,
        onToggle: (index) { setState(() {
          if (togglesMode.length < (index ?? 0)) {
            isNull = togglesMode[index ?? 0].toLowerCase().contains("null");
            isMath = togglesMode[index ?? 0].toLowerCase().contains("math");
          }
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