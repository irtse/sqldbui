
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/widget/utils/grid.dart';
import 'package:sqldbui2/main.dart';


Map<String, List<GlobalKey<FormState>>> formRowFilterKeys = <String,List<GlobalKey<FormState>>>{};

class FilterRowWidget extends StatefulWidget {
  String connector = ""; int index;
  List<DropdownMenuItem<String>> items;
  DatagridWidgetState datagrid;
  String dir = "asc";
  String? columnName;
  dynamic value;
  int? ref;
  FilterRowWidget ({ Key? key, required this.items, this.ref, required this.index, this.dir = "asc", required this.datagrid, this.columnName, this.value, this.connector = ""}): super(key: key);
  @override FilterRowWidgetState createState() => FilterRowWidgetState();
}
class FilterRowWidgetState extends State<FilterRowWidget> {
  @override Widget build(BuildContext context) {
    if (viewID == null) { return Container(); }
    if (!formRowFilterKeys.containsKey(viewID)) { formRowFilterKeys[viewID!] = []; }
    formRowFilterKeys[viewID!]!.add(GlobalKey<FormState>());
    return Form( key: formRowFilterKeys[viewID!]!.last, autovalidateMode: AutovalidateMode.always, 
      child: SizedBox(height: 45, child: Row(children: [
              Padding( padding: const EdgeInsets.only(left: 35, right: 20, top: 0), child: Icon(Icons.circle, color: Theme.of(context).splashColor, size: 15)),
              SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 4, child: DropdownButtonFormField<String>( items: widget.items, 
                    value: widget.columnName, hint: Text("select a column to filter...", overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    validator: (value) { if (value == null) { return "please select a column to filter..."; } return null; },
                    onChanged: (value) { widget.columnName = value; }, 
                    onSaved: (value) {
                      if (viewID != null && globalFilter.containsKey(viewID)) {
                        if ( !globalFilter[viewID]!.containsKey(widget.columnName)) { globalFilter[viewID]![widget.columnName!] = [];}
                        if (widget.ref != null) { 
                          globalFilter[viewID]![widget.columnName!]![widget.ref!] = Filter(value: value, connector: widget.connector); 
                        } else {
                          widget.ref = globalFilter[viewID]![widget.columnName!]!.length;
                          globalFilter[viewID]![widget.columnName!]!.add(Filter(value: widget.value, connector: widget.connector));
                        }
                      }
                      if (viewID != null && globalOrder.containsKey(viewID)) { globalOrder[viewID]![widget.columnName!] = widget.dir;  }
                    },
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(height: -2),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ))),
              Padding( padding: const EdgeInsets.only(left: 10), child: Text("LIKE", style: TextStyle(color: Theme.of(context).splashColor, fontSize: 11))),
              Padding( padding: const EdgeInsets.symmetric(horizontal: 10), 
                child: SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 4, child: TextFormField(
                initialValue: widget.value, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                onChanged: (value) => widget.value = value,
                onSaved: (value) {},
                validator: (value) { if (value == null) { return "please enter a filter value..."; } return null; },
                decoration: InputDecoration(suffixIcon: const Icon(Icons.text_fields, size: 20),
                  suffixIconColor: Theme.of(context).splashColor,
                  border: const OutlineInputBorder(),  enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 0)),
                  helperStyle: const TextStyle(height: -2), floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true, fillColor: Theme.of(context).secondaryHeaderColor,
                  hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).splashColor, fontWeight: FontWeight.normal),
                  contentPadding: const EdgeInsets.only(top: 0, left: 20.0, right: 20.0, bottom: 20),
                  hintText: "enter a value to filter..." ),
              ))),
              SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 8, child: DropdownButtonFormField<String>( 
                    items: const [ DropdownMenuItem<String>(value: "asc", child: Text("asc", overflow: TextOverflow.ellipsis,)),
                      DropdownMenuItem<String>(value: "desc", child: Text("desc", overflow: TextOverflow.ellipsis,)) ], 
                    value: widget.dir, hint: Text("select a direction to filter...", overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    onChanged: (value) { widget.dir = value ?? "asc"; },  onSaved: (value) {},
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(height: -2),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ), validator: (String? value) { return null; })),
              Padding(padding: const EdgeInsets.only(left: 10), child: TextButton( onPressed: () { setState(() { 
                  widget.connector = widget.connector == "and" ? "" : "and"; 
                  widget.datagrid.setState(() { 
                    if (widget.connector == "") {
                      widget.datagrid.widget.filterWidget = widget.datagrid.widget.filterWidget.sublist(0, widget.index + 1); 
                    } else {
                      if (widget.datagrid.widget.filterWidget.length - 1 == widget.index) {
                        widget.datagrid.widget.filterWidget.add(FilterRowWidget(items: widget.items, index: widget.index + 1, datagrid: widget.datagrid));
                      }
                    }
                  });
                }); },
                style: ButtonStyle( backgroundColor: MaterialStateProperty.all(widget.connector == "and" ? Theme.of(context).primaryColor : Colors.transparent)), child: Padding( padding: const EdgeInsets.all(10), 
                  child: Text("AND", style: TextStyle(color: widget.connector == "and" ? Colors.white :Colors.grey, fontSize: 11))),)),
              TextButton( onPressed: () { setState(() {  
                  widget.connector = widget.connector == "or" ? "" : "or"; 
                  widget.datagrid.setState(() { 
                    if (widget.connector == "") {
                      widget.datagrid.widget.filterWidget = widget.datagrid.widget.filterWidget.sublist(0, widget.index + 1); 
                    } else {
                      if (widget.datagrid.widget.filterWidget.length - 1 == widget.index) {
                        widget.datagrid.widget.filterWidget.add(FilterRowWidget(items: widget.items, index: widget.index + 1, datagrid: widget.datagrid));
                      }
                    }
                  });
                }); },
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(widget.connector =="or" ? Theme.of(context).primaryColor : Colors.transparent)), child: Padding( padding: const EdgeInsets.all(10), 
                  child: Text("OR", style: TextStyle(color: widget.connector == "or" ? Colors.white :Colors.grey, fontSize: 11))),)
            ],)));
  }
}