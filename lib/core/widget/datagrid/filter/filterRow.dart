
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';

Map<String, List<GlobalKey<FormState>>> formRowFilterKeys = <String,List<GlobalKey<FormState>>>{};

class FilterRowWidget extends StatefulWidget implements ConvertorWidget {
  String connector = ""; 
  String comparator = "like"; 
  int index;
  List<DropdownMenuItem<String>> items;
  String dir = "asc";
  String? columnName;
  String? label;
  String type = "text";
  int? ref;
  @override dynamic value;
  Map<String, dynamic> schema;
  bool isNull = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FilterRowWidget ({ Key? key, required this.schema, required this.items,
  this.label, this.type = "text", this.ref, this.comparator = "like",
  required this.index, this.dir = "asc", this.columnName, this.value, this.connector = ""}): super(key: key);
  @override FilterRowWidgetState createState() => FilterRowWidgetState();
}
class FilterRowWidgetState extends State<FilterRowWidget> {
  @override Widget build(BuildContext context) {
    if (viewID == null || MediaQuery.of(context).size.width < 1000) { return SizedBox(height: 45, width: MediaQuery.of(context).size.width - menuSize,); }
    bool isText = widget.type.contains("text") || widget.type.contains("varchar") || widget.type.contains("link");
    String url = currentView!.schema[widget.columnName] == null ? "" : "${currentView!.schema[widget.columnName]!.actionPath}&shallow=enable";
    Widget w = Convertor.filterFieldByType(
      context, widget as ConvertorWidget, widget.type, "value to filter on...", this, true, false, url, "");
    if(widget.value == "NULL" || widget.value == "NOT NULL") { widget.isNull = true; }
    var conn = widget.type.contains("enum") || widget.type == "link" ?  [
      DropdownMenuItem<String>(value: "=", child: Text("=", overflow: TextOverflow.ellipsis,)),
      DropdownMenuItem<String>(value: "!=", child: Text("!=", overflow: TextOverflow.ellipsis,)) ] 
      : [ DropdownMenuItem<String>(value: "like", child: Text("like", overflow: TextOverflow.ellipsis,)),
          DropdownMenuItem<String>(value: "not like", child: Text("not like", overflow: TextOverflow.ellipsis,)),
          DropdownMenuItem<String>(value: "=", child: Text("=", overflow: TextOverflow.ellipsis,)),
          DropdownMenuItem<String>(value: "!=", child: Text("!=", overflow: TextOverflow.ellipsis,)) ];
    if (!isText) {
      conn.addAll([
        DropdownMenuItem<String>(value: "<", child: Text("<", overflow: TextOverflow.ellipsis,)),
        DropdownMenuItem<String>(value: ">", child: Text(">", overflow: TextOverflow.ellipsis,)),
        DropdownMenuItem<String>(value: "<=", child: Text("<", overflow: TextOverflow.ellipsis,)),
        DropdownMenuItem<String>(value: ">=", child: Text(">", overflow: TextOverflow.ellipsis,))
      ]);
    }
    if (!["=", "!="].contains(widget.comparator)) {
      widget.comparator = widget.type.contains("enum") || widget.type == "link"  ? "=" : widget.comparator;
    }
    return Form( key: widget.formKey, autovalidateMode: AutovalidateMode.always, 
      child: SizedBox(height: 45, child: Row(children: [
              Padding( padding: const EdgeInsets.only(left: 37, right: 10, top: 0), child: Text("${widget.index}", style : TextStyle( color: Theme.of(context).splashColor, fontSize: 15))),
              Padding( padding: const EdgeInsets.only(left: 0, right: 20, top: 0), child: Icon(Icons.circle, color: Theme.of(context).splashColor, size: 15)),
              SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 6, child: DropdownButtonFormField<String>( items: widget.items, 
                    value: widget.columnName, 
                    hint: Text("select a column to filter...", overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    validator: (value) { if (value == null) { return "please select a column to filter..."; } return null; },
                    onChanged: (value) { 
                      setState(() {
                        widget.columnName = value ?? "";
                        widget.value = null;
                        widget.label = currentView?.schema[value ?? ""]?.label;
                        widget.type = value == "id" ? "integer" : currentView?.schema[value ?? ""]?.type ?? "text";
                      });
                    }, 
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(fontSize: 0,),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ))),
              widget.columnName == null || widget.columnName == "" ? Container() : Padding( padding: const EdgeInsets.only(left: 10), 
                child: SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 10, child: DropdownButtonFormField<String>( 
                    items: conn, value: widget.comparator, hint: Text("select a comparator to filter...", overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    onChanged: (value) { widget.comparator = value ?? "like"; },  onSaved: (value) {},
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(height: -2),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ), validator: (String? value) { return null; }))),
              widget.columnName == null || widget.columnName == "" ? Container() : Padding( padding: const EdgeInsets.symmetric(horizontal: 10), 
                child: SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 6, child: 
                widget.isNull ? DropdownButtonFormField<String>( items: const [
                      DropdownMenuItem<String>(value: "NULL", child: Text("NULL", overflow: TextOverflow.ellipsis,)),
                      DropdownMenuItem<String>(value: "NOT NULL", child: Text("NOT NULL", overflow: TextOverflow.ellipsis,))], 
                    value: widget.value, hint: Text("select a null value...", overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    validator: (value) { if (value == null) { return "please select a null to filter..."; } return null; },
                    onChanged: (value) { widget.value = value ?? "NULL"; }, 
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(fontSize: 0,),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    )): w)),
              widget.columnName == null || widget.columnName == "" || widget.type.contains("bool") || widget.columnName == "id" || currentView!.schema[widget.columnName]!.require ? Container() : Row(children: [
                Padding(padding: const EdgeInsets.only(right: 10), child:  Checkbox(value: widget.isNull, 
                  onChanged: (value) => setState(() { widget.value = null; widget.isNull = value ?? false; }),
                  activeColor: Theme.of(context).primaryColor, overlayColor:  MaterialStateColor.resolveWith((states) => Theme.of(context).splashColor),
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(2.0), side: BorderSide.none ),
                  fillColor: MaterialStateColor.resolveWith((states) => Theme.of(context).splashColor) )),
                Padding(padding: const EdgeInsets.only(right: 20), child: Text("null mode", style: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),)),
              ],),
              widget.columnName == null || widget.columnName == "" ? Container() : SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 10, child: DropdownButtonFormField<String>( 
                    items: const [ DropdownMenuItem<String>(value: "asc", child: Text("asc", overflow: TextOverflow.ellipsis,)),
                      DropdownMenuItem<String>(value: "desc", child: Text("desc", overflow: TextOverflow.ellipsis,)) ], 
                    value: widget.dir, hint: Text("select a direction to filter...", overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    onChanged: (value) { widget.dir = "value"; },  onSaved: (value) {},
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(height: -2),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ), validator: (String? value) { return null; })),
              widget.columnName == null || widget.columnName == "" ? Container() : Padding(padding: const EdgeInsets.only(left: 10), child: TextButton( onPressed: () { setState(() { 
                  widget.connector = widget.connector == "and" ? "" : "and"; 
                  noFilterRetrieval = true;
                  tempRemoval = true;
                  globalGridWidgetKey.currentState?.setState(() { 
                    if (widget.connector == "") {  filterRowsWidget = filterRowsWidget.sublist(0, widget.index + 1); 
                    } else if (filterRowsWidget.length - 1 == widget.index) {
                       filterRowsWidget.add(FilterRowWidget(schema: widget.schema, items: widget.items, index: filterRowsWidget.length));  }
                  });
                }); },
                style: ButtonStyle( backgroundColor: MaterialStateProperty.all(widget.connector == "and" ? Theme.of(context).primaryColor : Colors.transparent)), child: Padding( padding: const EdgeInsets.all(10), 
                  child: Text("AND", style: TextStyle(color: widget.connector == "and"  ? Colors.white :Colors.grey, fontSize: 11))),)),
              widget.columnName == null || widget.columnName == "" ? Container() : TextButton( onPressed: () { setState(() {  
                  widget.connector = widget.connector == "or" ? "" : "or"; 
                  noFilterRetrieval = true;
                  tempRemoval = true;
                  globalGridWidgetKey.currentState?.setState(() { 
                    if (widget.connector == "") {
                      filterRowsWidget = filterRowsWidget.sublist(0, widget.index + 1); 
                    } else if (filterRowsWidget.length - 1 == widget.index) {
                        filterRowsWidget.add(FilterRowWidget(schema: widget.schema, items: widget.items,  index: filterRowsWidget.length));
                    }
                  });
                }); },
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(widget.connector =="or" ? Theme.of(context).primaryColor : Colors.transparent)), child: Padding( padding: const EdgeInsets.all(10), 
                  child: Text("OR", style: TextStyle(color: widget.connector == "or" ? Colors.white :Colors.grey, fontSize: 11))),)
            ],)));
  }
}