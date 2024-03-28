import 'dart:developer' as developer;
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/page/page.dart';

// ignore: must_be_immutable
class FilterPopUpWidget extends StatefulWidget{
  String columnName; 
  String label;
  GridColumnWidgetState component; 
  bool? ascOrder;
  bool? descOrder;
  String? searchValue;
  bool isNew = false;
  FilterPopUpWidget ({ Key? key, required this.columnName, required this.component, required this.label }): super(key: key);
  @override
  FilterPopUpState createState() => FilterPopUpState();
}
class FilterPopUpState extends State<FilterPopUpWidget> {
  List<FilterSearchWidget> advancedSearch = <FilterSearchWidget>[];
  @override Widget build(BuildContext context) {
    StateSetter? stateSort;
    StateSetter? stateFilter;
    StateSetter? stateKind;
    return PopupMenuButton(
      color: Colors.white,
      icon: const Icon(size: 18, Icons.filter_alt, color: Colors.grey),
      onSelected: (value) { },
      itemBuilder: (BuildContext bc) {
        if (currentView != null && globalOrder.containsKey(currentView!.id)) {
          if (globalOrder[currentView!.id]!.containsKey(widget.columnName)) {
            if(globalOrder[currentView!.id]![widget.columnName] == "asc") { widget.ascOrder = true; }
            if(globalOrder[currentView!.id]![widget.columnName] == "desc") { widget.descOrder = true; }
          }
        }
        widget.isNew = globalNew; 
        return [
          PopupMenuItem(enabled: false, 
            child: Padding(padding: const EdgeInsets.only(top: 20, bottom: 20), child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
              stateSort = setState;
              var rows1 = [
                      const Icon(Icons.arrow_downward, color: Colors.grey, size: 18,), 
                      const Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10), child: Text("SORT ASCENDANT")),
                    ];
              var rows2 = [
                      const Icon(Icons.arrow_upward, color: Colors.grey, size: 18,), 
                      const Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10), child: Text("SORT DESCENDANT")),
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
                Divider(color: Theme.of(context).splashColor,)
              ]); }),)),
          PopupMenuItem(enabled: false, child: StatefulBuilder( builder: (BuildContext context, StateSetter setState) {
            if (currentView != null && globalFilter.containsKey(currentView!.id)) {
              if (globalFilter[currentView!.id]!.containsKey(widget.columnName) && advancedSearch.isEmpty) { 
                for (var filter in globalFilter[currentView!.id]![widget.columnName]!) {
                  advancedSearch.add(FilterSearchWidget(innerIndex: advancedSearch.length, state: setState,
                    filter: this, columnName: widget.columnName, label: widget.label, searchValue: filter.value, connector: filter.connector));
                }
              }
            }
            
            if (advancedSearch.isEmpty) {
              advancedSearch.add(FilterSearchWidget(filter: this, innerIndex: 0, state: setState,
                columnName: widget.columnName, label: widget.label));
            } else if (advancedSearch.length == 1) {
              advancedSearch.add(FilterSearchWidget(filter: this, innerIndex: 0, state: setState,
                columnName: widget.columnName, label: widget.label, searchValue: advancedSearch.first.searchValue,));
                advancedSearch.remove(advancedSearch.first);
            }
            stateFilter = setState;
            return Container( 
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView( child: Column(children: advancedSearch))); })),
          PopupMenuItem(enabled: false, child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) { 
                stateKind = setState;
                var rows1 = [
                      const Icon(Icons.fiber_new, color: Color.fromARGB(255, 95, 76, 76), size: 30,), 
                      const Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10), child: Text("only new datas")),
                    ];
                if (widget.isNew == true) { rows1.add(const Icon(Icons.task_alt, color: Colors.green, size: 18,), ); }
                return Column(children: [
                  Padding(padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(color: Colors.transparent, child: 
                    TextButton(
                    child: Row(children: rows1), 
                    onPressed: () { setState(() { widget.isNew = !widget.isNew;  }); },  
                  ))),
                  Divider(color: Theme.of(context).splashColor,)
                ]); })),
          PopupMenuItem(enabled: false, child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding( padding: const EdgeInsets.only(bottom: 30, top: 10), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding( padding: const EdgeInsets.only(right: 10), child: TextButton(onPressed: () {
                    homeKey.currentState!.setState(() {
                      if (currentView != null) { 
                        if (widget.ascOrder != null) { globalOrder[currentView!.id]![widget.columnName]=widget.ascOrder! ? "asc" : "desc"; }
                        if (widget.descOrder != null) { globalOrder[currentView!.id]![widget.columnName]=widget.descOrder! ? "desc" : "asc"; }
                        globalNew = widget.isNew;
                        if (widget.ascOrder == null && widget.descOrder == null) { 
                          globalOrder[currentView!.id]!.remove(widget.columnName); 
                        }
                        globalFilter[currentView!.id]!.remove(widget.columnName);
                        for (var search in advancedSearch) { search.globalKey.currentState!.save(); }
                        stateSort!(() {});
                        stateKind!(() {});
                        stateFilter!(() {});
                      }
                    });
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)), child: const Padding( padding: EdgeInsets.all(10), 
                    child: Text("SUBMIT", style: TextStyle(color: Colors.white, fontSize: 12))),)),
                  TextButton(onPressed: () {
                    globalMenuKey.currentState!.setState(() {
                      firstAPI= true; 
                      resetFilter(widget.columnName); 
                    });
                    stateSort!(() { widget.ascOrder=null;  widget.descOrder=null; });
                    stateKind!(() { widget.isNew=false; });
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
// ignore: must_be_immutable
class FilterSearchWidget extends StatefulWidget{
  String columnName; 
  String label;
  String? searchValue;
  String? connector;
  FilterPopUpState filter;
  int innerIndex;
  int? index;
  StateSetter state;
  var globalKey = GlobalKey<FormFieldState<String>>();
  var fieldText = TextEditingController();
  FilterSearchWidget ({ Key? key, required this.state, required this.columnName, required this.filter, 
  required this.innerIndex, required this.label, this.connector, this.searchValue }): super(key: key);
  @override
  FilterSearchState createState() => FilterSearchState();
}
class FilterSearchState extends State<FilterSearchWidget> {
  @override Widget build(BuildContext context) {
    var additionnal = <Widget>[];
    if (widget.innerIndex > 0) {
      additionnal.add(TextButton(onPressed: () {
                    widget.filter.advancedSearch.removeRange(widget.innerIndex, widget.filter.advancedSearch.length);
                    widget.state(() { }); 
                  }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)), 
                  child: const Padding( padding: EdgeInsets.all(10), 
                    child: Text("DELETE",  style: TextStyle(color: Colors.grey, fontSize: 11
                  )))));
    }
    
    if (widget.searchValue != null && widget.searchValue != "") { widget.fieldText.text = widget.searchValue!; }
    return Column(children: [ Padding(padding: const EdgeInsets.only(left: 20, right: 20 , bottom: 20.0),
              child: TextFormField(
                key: widget.globalKey,
                controller: widget.fieldText,
                style: const TextStyle(fontSize: 14,),
                enabled: true,
                autocorrect: true,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor)),
                  isDense: true,
                  hintStyle: const TextStyle(fontSize: 12), // you need this
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  suffixIcon: const Icon(Icons.search),
                  hintText: "filter ${widget.label}...",
                  labelText: "",
                  errorStyle: const TextStyle(fontSize: 0,),
                ),
                onChanged: (String? value) {  widget.searchValue = value; },
                onSaved: (String? value) { 
                  widget.searchValue = value;
                  if (currentView != null) {
                    if (!globalFilter[currentView!.id]!.containsKey(widget.columnName) ) { 
                      globalFilter[currentView!.id]![widget.columnName] = []; 
                    }
                    widget.index = globalFilter[currentView!.id]!.length;
                    globalFilter[currentView!.id]![widget.columnName]!.add(Filter(value: widget.searchValue, connector: widget.connector)); 
                  }
                },
                validator: (String? value) { return null; },
              )), 
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding( padding: const EdgeInsets.only(right: 10), child: TextButton(
                  onPressed: () {
                    if (widget.filter.advancedSearch.length <= widget.innerIndex + 1) { 
                      widget.filter.advancedSearch.add(FilterSearchWidget(filter: widget.filter, 
                      innerIndex: widget.filter.advancedSearch.length, state: widget.state,
                      columnName: widget.columnName, label: widget.label));
                    }
                    widget.connector = widget.connector == "and" ? null : "and"; 
                    if (widget.connector == null) { widget.filter.advancedSearch.removeRange(widget.innerIndex + 1, widget.filter.advancedSearch.length); }
                    widget.state(() { setState(() {}); }); 
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(widget.connector == "and" ? Theme.of(context).primaryColor : Colors.transparent)), child: Padding( padding: const EdgeInsets.all(10), 
                    child: Text("AND", style: TextStyle(color: widget.connector == "and" ? Colors.white :Colors.grey, fontSize: 11))),)),
                  TextButton(onPressed: () {
                    if (widget.filter.advancedSearch.length <= widget.innerIndex + 1) { 
                      widget.filter.advancedSearch.add(FilterSearchWidget(filter: widget.filter, state: widget.state,
                      innerIndex: widget.filter.advancedSearch.length, 
                      columnName: widget.columnName, label: widget.label));
                    }
                    widget.connector =  widget.connector = widget.connector == "or" ? null :  "or"; 
                    if (widget.connector == null) { widget.filter.advancedSearch.removeRange(widget.innerIndex + 1, widget.filter.advancedSearch.length); }
                    widget.state(() { setState(() {});}); 
                  }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(widget.connector == "or" ? Theme.of(context).primaryColor : Colors.transparent)), 
                  child: Padding( padding: const EdgeInsets.all(10), 
                    child: Text("OR",  style: TextStyle(color: widget.connector == "or" ? Colors.white : Colors.grey, fontSize: 11
                  ))))
              ]..addAll(additionnal),),
              Padding( padding: const EdgeInsets.only(top: 10), child: Divider(color: Theme.of(context).splashColor,))] ); 
  }
}