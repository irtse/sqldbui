
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/datagrid/main_grid.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/model/view.dart';
import 'package:sqldbui2/page/translate.dart';

Map<String, List<GlobalKey<FormState>>> formRowFilterKeys = <String,List<GlobalKey<FormState>>>{};

// ignore: must_be_immutable
class FilterRowWidget extends StatefulWidget implements ConvertorWidget {
  late GlobalKey<FilterRowWidgetState> rowKey;
  String comparator = "like";  
  String connector = ""; 
  String type = "text"; 
  String dir = "asc";
  List<String> beforeColumn = [];
  String? columnName, label, name;
  @override dynamic value;
  int index; int? ref;
  bool isNull = false;
  Map<String, SchemaField> schema;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FilterRowWidget ({ 
    required this.schema, 
    this.label, 
    this.type = "text", 
    this.ref, 
    this.beforeColumn = const [],
    this.comparator = "like",
    required this.index, 
    this.dir = "asc", 
    this.columnName, 
    this.value, 
    this.connector = ""
  }): super(key: GlobalKey<FilterRowWidgetState>()) {
     rowKey = key as GlobalKey<FilterRowWidgetState>;
  }

  @override FilterRowWidgetState createState() => FilterRowWidgetState();
}

class FilterRowWidgetState extends State<FilterRowWidget> {
  @override Widget build(BuildContext context) {
    if (viewID == null || MediaQuery.of(context).size.width < 1000) { 
      return SizedBox(height: 45, width: MediaQuery.of(context).size.width - menuSize,); 
    }  
    if ((widget.columnName ?? "").contains(".")) {
      widget.beforeColumn = widget.columnName!.split(".");
      widget.columnName = widget.beforeColumn.first;
    }
    return Form( 
      key: widget.formKey, 
      autovalidateMode: AutovalidateMode.always, 
      child: SizedBox(height: 45, child: Row(children: [
              Padding(  padding: const EdgeInsets.only(left: 37, right: 10, top: 0), 
                child: Text("${widget.index}", style : TextStyle( color: Theme.of(context).splashColor, fontSize: 15))),
              Padding( padding: const EdgeInsets.only(left: 0, right: 20, top: 0), child: Icon(Icons.circle, color: Theme.of(context).splashColor, size: 15)),
              FilterSubRowWidget(
                widget: this,
                schema: widget.schema,
                label: widget.label,
                type: widget.type, 
                ref: widget.ref,  
                comparator: widget.comparator,  
                dir: widget.dir,   
                columnName: widget.columnName,    
                value: widget.value, 
                connector: widget.connector, 
              )
            ])
          )
        );
  }
}

// ignore: must_be_immutable
class FilterSubRowWidget extends StatefulWidget implements ConvertorWidget {
  FilterRowWidgetState widget;
  String comparator = "like";  
  String connector = ""; 
  String type = "text"; 
  String dir = "asc";
  String? columnName, label;
  @override dynamic value;
  int? ref;
  int depth;
  bool isNull = false;
  int index;
  bool isSub = false;
  Map<String, SchemaField> schema;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FilterSubRowWidget ({ 
    super.key,
    this.depth = 0,
    required this.widget,
    this.index = 1,
    required this.schema, 
    this.label, 
    this.type = "text", 
    this.ref, 
    this.isSub = false,
    this.comparator = "like",
    this.dir = "asc", 
    this.columnName, 
    this.value, 
    this.connector = ""
  });

  @override FilterSubRowWidgetState createState() => FilterSubRowWidgetState();
}

class FilterSubRowWidgetState extends State<FilterSubRowWidget> {
  @override Widget build(BuildContext context) {
    if ((widget.columnName ?? "") != "") {
      widget.type = widget.schema[widget.columnName]?.type ?? "text";
    }
    widget.isNull = widget.value == "NULL" || widget.value == "NOT NULL";
    String url = widget.schema[widget.columnName] != null && widget.schema[widget.columnName]?.actionPath != ""  ? "${widget.schema[widget.columnName]!.actionPath}&shallow=enable" : "";
    print("TYPEEEE ${widget.type} ${widget.columnName ?? ""} $url ${widget.widget.widget.value}");
    Widget w = FutureBuilder<Widget>(future: Convertor.filterFieldByType(
      context, 
      widget.widget.widget as ConvertorWidget, 
      widget.type, 
      widget.columnName ?? "",
      TranslateConstants.valueFilterPlaceholder.toLowerCase(), this, true, false, url, 
      (widget.schema[widget.columnName]?.valuesPath ?? "") != "" ? widget.schema[widget.columnName]!.valuesPath : url, ""), 
      builder: (a,b) {
        if ((b.data != null)) {
          return b.data!;
        }
        return Container();
    }) ;
    Widget? w2;
    List<String> order = (widget.isSub ? widget.schema : realOrderMap(widget.schema.keys.toList(), widget.schema, false)).keys.where(
      (e) => !(widget.schema[e]?.hidden ?? false) ).toList();
    if (widget.schema[widget.columnName] != null && widget.schema[widget.columnName]!.type.contains("onetomany")) {
      String? column;
      if (widget.widget.widget.beforeColumn.length > widget.depth + 1) {
        column = widget.widget.widget.beforeColumn[ widget.depth + 1];
      }
      w2 = Padding( padding: EdgeInsets.only(left: 10), child: FilterSubRowWidget(
        widget: widget.widget,
        columnName: column,
        schema: widget.schema[widget.columnName]?.schema ?? {},
        ref: widget.ref,  
        depth: widget.depth + 1,
        comparator: widget.comparator,  
        dir: widget.dir,   
        value: widget.value, 
        isSub: true,
        connector: widget.connector, 
      ));
    } else if (widget.widget.widget.beforeColumn.length > widget.depth + 1) {
       widget.widget.widget.beforeColumn.sublist(0, widget.depth + 1);
    }
    List<DropdownMenuItem<String>> items = [];
    for (var o in widget.schema.entries.where((e) => order.contains(e.key))) {
      if (items.where( (e) => e.value == o.key).isEmpty) {
          items.add(DropdownMenuItem<String>(value: o.key, child: FutureBuilder(future: getOnFlow(o.value.label), builder: (a,s) {
            if (s.data != null) {
              return Text(s.data!.toLowerCase(), overflow: TextOverflow.ellipsis);
            }
            return Text(o.value.label.toLowerCase(), overflow: TextOverflow.ellipsis);
            })
        ));
      }
    }
    List<DropdownMenuItem<String>> conn = [];
    var indications = widget.type.contains("enum") || widget.type.contains("link") || widget.type.contains("many") ? ["=", "!="] : (  
      widget.type.contains("link")  ? ["like", "not like"] : ["like", "not like", "=", "!="]);
    for (var indication in ( widget.type.contains("text") || widget.type.contains("varchar") || widget.type.contains("link") || widget.type.contains("enum") || widget.type.contains("many") ? indications : [...indications, "<", ">", "<=", ">="])) {
      conn.add( DropdownMenuItem<String>(
        value: indication, 
        child: Text(indication, overflow: TextOverflow.ellipsis)
      ));
    }
    if (!["=", "!="].contains(widget.comparator)) {
      widget.comparator = widget.type.contains("enum") || widget.type == "link"  ? "=" : widget.comparator;
    }
    return Row( children : [
      SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 7, 
                child: DropdownButtonFormField<String>( 
                  items: items, 
                    value: widget.columnName, 
                    hint: Text(TranslateConstants.colFilter.toLowerCase(), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    validator: (value) { if (value == null) { return TranslateConstants.colErrFilter.toLowerCase(); } return null; },
                    onChanged: (value) { 
                      setState(() {
                        widget.columnName = value ?? "";
                        if (widget.widget.widget.beforeColumn.length > (widget.depth)) {
                          widget.widget.widget.beforeColumn[widget.depth] =  widget.columnName!;
                          widget.widget.widget.beforeColumn = widget.widget.widget.beforeColumn.sublist(0, widget.depth + 1);
                        } else {
                          widget.widget.widget.beforeColumn = [...widget.widget.widget.beforeColumn, ...(widget.columnName != null ? [ widget.columnName! ] : [])];
                        }
                        widget.value = null;
                        widget.label = widget.schema[value ?? ""]?.label;
                        widget.type = value == "id" ? "integer" : widget.schema[value ?? ""]?.type ?? "text";
                        widget.comparator = (widget.type.contains("enum") || widget.type.contains("link") || widget.type.contains("many") ? ["=", "!="] : (  
                          widget.type.contains("link")  ? ["like", "not like"] : ["like", "not like", "=", "!="])).first;
                        widget.widget.widget.value = null;
                        widget.widget.widget.label = widget.schema[value ?? ""]?.label;
                        widget.widget.widget.type = value == "id" ? "integer" : widget.schema[value ?? ""]?.type ?? "text";
                        widget.widget.widget.comparator = (widget.type.contains("enum") || widget.type.contains("link") || widget.type.contains("many") ? ["=", "!="] : (  
                          widget.type.contains("link") ? ["like", "not like"] : ["like", "not like", "=", "!="])).first;
                      });
                    }, 
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(fontSize: 0,),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ))),
            ...(w2 != null ? [ w2 ] : [
              widget.columnName == null || widget.columnName == "" ? Container() : Padding( padding: const EdgeInsets.only(left: 10), 
                child: SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 10, child: DropdownButtonFormField<String>( 
                    items: conn, 
                    value: widget.comparator, 
                    hint: Text(TranslateConstants.colCompFilter.toLowerCase(), 
                    overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    onChanged: (value) { 
                      widget.comparator = value ?? "like";
                      widget.widget.widget.comparator = value ?? "like";
                    },  onSaved: (value) {},
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(height: -2),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ), validator: (String? value) { return null; }))),
              widget.columnName == null || widget.columnName == "" ? Container() : Padding( padding: const EdgeInsets.symmetric(horizontal: 10), 
                child: SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / ( widget.type == "boolean" ? 6 : 5) , child: 
                widget.isNull ? DropdownButtonFormField<String>( items: const [
                      DropdownMenuItem<String>(value: "NULL", child: Text("NULL", overflow: TextOverflow.ellipsis,)),
                      DropdownMenuItem<String>(value: "NOT NULL", child: Text("NOT NULL", overflow: TextOverflow.ellipsis,))], 
                    value: widget.value, hint: Text(TranslateConstants.colNullFilter.toLowerCase(), overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    validator: (value) { if (value == null) { return TranslateConstants.colNullErrFilter.toLowerCase(); } return null; },
                    onChanged: (value) { 
                      widget.value = value ?? "NULL"; 
                      widget.widget.widget.value = value ?? "NULL"; 
                    }, 
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(fontSize: 0,),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    )): w)),
              widget.columnName == null || widget.columnName == "" || widget.type.contains("bool") || widget.columnName == "id" || widget.schema[widget.columnName]!.require ? Container() : Row(children: [
                Padding(padding: const EdgeInsets.only(right: 10), child:  Checkbox(value: widget.isNull, 
                  onChanged: (value) => setState(() { 
                    widget.value = null;
                    widget.isNull = value ?? false; 

                    widget.widget.widget.value = value; 
                    widget.widget.widget.isNull = value ?? false; 
                  }),
                  activeColor: Theme.of(context).primaryColor, overlayColor:  WidgetStateProperty.resolveWith((states) => Theme.of(context).splashColor),
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(2.0), side: BorderSide.none ),
                  fillColor: WidgetStateProperty.resolveWith((states) => Theme.of(context).splashColor) )),
                Padding(padding: const EdgeInsets.only(right: 20), child: Text("null mode", style: TextStyle(fontSize: 12, color: Theme.of(context).splashColor))),
              ]),
              widget.columnName == null || widget.columnName == "" ? Container() : SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 10, child: DropdownButtonFormField<String>( 
                    items: const [ DropdownMenuItem<String>(value: "asc", child: Text("asc", overflow: TextOverflow.ellipsis,)),
                      DropdownMenuItem<String>(value: "desc", child: Text("desc", overflow: TextOverflow.ellipsis,)) ], 
                    value: widget.dir, hint: Text(TranslateConstants.colDirFilter.toLowerCase(), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    onChanged: (value) { 
                      widget.dir = value ?? "asc"; 
                      widget.widget.widget.dir = value ?? "asc"; 
                    },  onSaved: (value) {},
                    dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(height: -2),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ), validator: (String? value) { return null; })),
              widget.columnName == null || widget.columnName == "" ? Container() : Padding(padding: const EdgeInsets.only(left: 10), child: TextButton( onPressed: () { setState(() { 
                  widget.connector = widget.connector == "and" ? "" : "and"; 
                  widget.widget.widget.connector = widget.connector;
                  noFilterRetrieval = true;
                  tempRemoval = true;
                  confirmCache = {};
                  navigate = true;
                  globalMainViewKey.currentState?.setState(() { 
                    if (widget.connector == "") {  filterRowsWidget = filterRowsWidget.sublist(0, widget.index + 1); }
                  });
                }); 
              },
              style: ButtonStyle( backgroundColor: WidgetStateProperty.all(widget.connector == "and" ? Theme.of(context).primaryColor : Colors.transparent)), child: Padding( padding: const EdgeInsets.all(10), 
                child: Text(TranslateConstants.and.toUpperCase(), style: TextStyle(color: widget.connector == "and"  ? Colors.white :Colors.grey, fontSize: 11))))),
              widget.columnName == null || widget.columnName == "" ? Container() : TextButton( onPressed: () { setState(() {  
                  widget.connector = widget.connector == "or" ? "" : "or"; 
                  widget.widget.widget.connector = widget.connector;
                  noFilterRetrieval = true;
                  tempRemoval = true;
                  confirmCache = {};
                  navigate = true;
                  globalMainViewKey.currentState?.setState(() { 
                    if (widget.connector == "") {
                      filterRowsWidget = filterRowsWidget.sublist(0, widget.index + 1); 
                    }
                  });
                }); 
              },
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(widget.connector =="or" ? Theme.of(context).primaryColor : Colors.transparent)), child: Padding( padding: const EdgeInsets.all(10), 
                child: Text(TranslateConstants.or.toUpperCase(), style: TextStyle(color: widget.connector == "or" ? Colors.white :Colors.grey, fontSize: 11))),)
          ])
    ]);
  }
}