import 'package:flutter/foundation.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/popup_button.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';


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
  model.View? view;
  Map<String, model.SchemaField> schema;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FilterRowWidget ({ 
    required this.schema, 
    this.label, 
    required this.view,
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
                view: widget.view,
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
  model.View? view;
  String? columnName, label;
  @override dynamic value;
  int? ref;
  int depth;
  bool isNull = false;
  int index;
  bool isSub = false;
  Map<String, model.SchemaField> schema;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FilterSubRowWidget ({ 
    super.key,
    required this.view,
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
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    if ((widget.columnName ?? "") != "") {
      widget.type = (widget.schema[widget.columnName]?.type ?? "text");
    }
    String url = widget.schema[widget.columnName] != null && widget.schema[widget.columnName]?.actionPath != ""  ? "${widget.schema[widget.columnName]!.actionPath}&shallow=enable" : "";
    Widget w = FutureBuilder<Widget>(future: Convertor.filterFieldByType(
      context, 
      widget.widget.widget as ConvertorWidget, 
      widget.type, 
      widget.columnName ?? "",
      TranslateConstants.valueFilterPlaceholder.toLowerCase(), this, true, false, url, 
      (widget.schema[widget.columnName]?.valuesPath ?? "") != "" ? widget.schema[widget.columnName]!.valuesPath : url, "", currentView?.rules ?? []), 
      builder: (a,b) {
        if ((b.data != null)) {
          return b.data!;
        }
        return Container();
    });
    Widget? w2;
    List<dynamic> order = widget.isSub ? widget.schema.keys.toList() : realOrder(widget.view, false, false, null, widget.view!.max);
    if (order.isEmpty) {
      order = realOrderMap(widget.schema.keys.toList(), widget.schema, false).keys.where( (e) => !(widget.schema[e]?.hidden ?? false) ).toList();
    }
    if (widget.schema[widget.columnName] != null && widget.schema[widget.columnName]!.type.contains("onetomany")) {
      String? column;
      if (widget.widget.widget.beforeColumn.length > widget.depth + 1) {
        column = widget.widget.widget.beforeColumn[ widget.depth + 1];
      }
      w2 = Padding( padding: EdgeInsets.only(left: 10), child: FilterSubRowWidget(
        view: widget.view,
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
    MultiSelectController<String> ctrls = MultiSelectController<String>();
    List<DropdownItem<String>> items = [];
    final schemaEntries = widget.schema.entries.where((e) => order.contains(e.key)).toList();
    final results = await Future.wait([
      Future.wait(schemaEntries.map((o) => getOnFlow(o.value.label))),
      Future.wait([
        getOnFlow("select a field"),
        getOnFlow(TranslateConstants.search),
        getOnFlow(TranslateConstants.selectValue),
      ]),
    ]);
    final schemaLabels = results[0];
    final dropTrad = results[1];
    for (var (i, o) in schemaEntries.indexed) {
      if (items.where( (e) => e.value == o.key).isEmpty) {
          items.add(DropdownItem<String>(value: o.key, label: schemaLabels[i], selected: o.key == widget.columnName ));
      }
    }
    List<DropdownMenuItem<String>> conn = [];
    var indications = widget.type.contains("enum") || widget.type.contains("link") || widget.type.contains("many") ? ["=", "!="] : (  
      widget.type.contains("link")  ? ["like", "not like"] : ["like", "not like", "=", "!="]);
    for (var indication in ( widget.type.contains("text") || widget.type.contains("varchar") || widget.type.contains("upload") ||  widget.type.contains("link") || widget.type.contains("enum") || widget.type.contains("many") ? indications : [...indications, "<", ">", "<=", ">="])) {
      conn.add( DropdownMenuItem<String>(
        value: indication, 
        child: Text(indication, overflow: TextOverflow.ellipsis)
      ));
    }
    if (!["=", "!="].contains(widget.comparator)) {
      widget.comparator = widget.type.contains("enum") || widget.type == "link"  ? "=" : widget.comparator;
    }
    if (widget.type.contains("upload")) {
      conn.add( DropdownMenuItem<String>(
        value: "in file", 
        child: Text(await getOnFlow("in document"), overflow: TextOverflow.ellipsis)
      ));
    }

    return Row( children : [
      Container(
        padding: EdgeInsets.only(left: 10),
        height: 25,  
        width: (MediaQuery.of(context).size.width - menuSize) / 6, 
        child: MultiDropdown<String>(
        controller: ctrls,
        singleSelect: true,
        items: items,
        label: "tp",
        searchEnabled: true,
        style: TextStyle(color: Colors.white ),
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
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          labelStyle: TextStyle(fontSize: 0),
          hintText: dropTrad[0].toLowerCase(),
          hintStyle: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 13, color:Theme.of(context).splashColor, fontWeight: FontWeight.w300),
          prefixIcon: Icon(Icons.list, color: Theme.of(context).splashColor),
          showClearIcon: false,
          border:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
          focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
        ),
        searchDecoration: SearchFieldDecoration(
          hintText: "       ${dropTrad[1].toLowerCase()}",
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
                "       ${dropTrad[2].toLowerCase()}",
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
              setState(() {
                widget.columnName = values[0];
                widget.widget.widget.columnName = values[0];
                if (widget.widget.widget.beforeColumn.length > (widget.depth)) {
                  widget.widget.widget.beforeColumn[widget.depth] =  widget.columnName!;
                  widget.widget.widget.beforeColumn = widget.widget.widget.beforeColumn.sublist(0, widget.depth + 1);
                } else {
                  widget.widget.widget.beforeColumn = [...widget.widget.widget.beforeColumn, ...(widget.columnName != null ? [ widget.columnName! ] : [])];
                }
                widget.value = null;
                widget.label = widget.schema[values[0]]?.label;
                widget.type = values[0] == "id" ? "integer" : widget.schema[values[0]]?.type ?? "text";
                widget.comparator = (widget.type.contains("enum") || widget.type.contains("link") || widget.type.contains("many") ? ["=", "!="] : (  
                            widget.type.contains("link")  ? ["like", "not like"] : ["like", "not like", "=", "!="])).first;
                widget.widget.widget.value = null;
                widget.widget.widget.label = widget.schema[values[0]]?.label;
                widget.widget.widget.type = values[0] == "id" ? "integer" : widget.schema[values[0]]?.type ?? "text";
                widget.widget.widget.comparator = (widget.type.contains("enum") || widget.type.contains("link") || widget.type.contains("many") ? ["=", "!="] : (  
                            widget.type.contains("link") ? ["like", "not like"] : ["like", "not like", "=", "!="])).first;
                });
              },
            )
          ),  
          ...(w2 != null ? [ w2 ] : [
              widget.columnName == null || widget.columnName == "" ? Container() : Padding( padding: const EdgeInsets.only(left: 10), 
                child: SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 9, child: DropdownButtonFormField<String>( 
                    items: conn, 
                    value: widget.comparator, 
                    hint: Text((await getOnFlow(TranslateConstants.colCompFilter)).toLowerCase(), 
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
                child: SizedBox( height: 25,  width: widget.type == "boolean" ? 100 : ((MediaQuery.of(context).size.width - menuSize) / 5) , child: 
                widget.isNull ? DropdownButtonFormField<String>( items: const [
                      DropdownMenuItem<String>(value: "NULL", child: Text("NULL", overflow: TextOverflow.ellipsis,)),
                      DropdownMenuItem<String>(value: "NOT NULL", child: Text("NOT NULL", overflow: TextOverflow.ellipsis,))], 
                    value: widget.value, hint: Text((await getOnFlow(TranslateConstants.colNullFilter)).toLowerCase(), overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    validator: (value) { if (value == null) { return ""; } return null; },
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
                Padding(padding: const EdgeInsets.only(right: 10), child:  Checkbox(
                  value: widget.isNull, 
                  onChanged: (value) => setState(() { 
                    widget.value = null;
                    widget.isNull = value ?? false; 

                    widget.widget.widget.value = null; 
                    widget.widget.widget.isNull = value ?? false; 
                  }),
                  activeColor: Theme.of(context).primaryColor, overlayColor:  WidgetStateProperty.resolveWith((states) => Theme.of(context).splashColor),
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(2.0), side: BorderSide.none ),
                  fillColor: WidgetStateProperty.resolveWith((states) => Theme.of(context).splashColor) )),
                Padding(padding: const EdgeInsets.only(right: 20), child: Text("null mode", style: TextStyle(fontSize: 12, color: Theme.of(context).splashColor))),
              ]),
              widget.columnName == null || widget.columnName == "" ? Container() : SizedBox( height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 10, child: DropdownButtonFormField<String>( 
                    items: const [ DropdownMenuItem<String>(value: "asc", child: Text("asc", overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem<String>(value: "desc", child: Text("desc", overflow: TextOverflow.ellipsis)) ], 
                    value: widget.dir, hint: Text((await getOnFlow(TranslateConstants.colDirFilter)).toLowerCase(), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
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
                    if (widget.connector == "") {  filterRowsWidget[viewID ?? ""] = (filterRowsWidget[viewID] ?? []).sublist(0, widget.index + 1); }
                  });
                }); 
              },
              style: ButtonStyle( backgroundColor: WidgetStateProperty.all(widget.connector == "and" ? Theme.of(context).primaryColor : Colors.transparent)), child: Padding( padding: const EdgeInsets.all(10), 
                child: Text((await getOnFlow(TranslateConstants.and)).toUpperCase(), style: TextStyle(color: widget.connector == "and"  ? Colors.white :Colors.grey, fontSize: 11))))),
              widget.columnName == null || widget.columnName == "" ? Container() : TextButton( onPressed: () { setState(() {  
                  widget.connector = widget.connector == "or" ? "" : "or"; 
                  widget.widget.widget.connector = widget.connector;
                  noFilterRetrieval = true;
                  tempRemoval = true;
                  confirmCache = {};
                  navigate = true;
                  globalMainViewKey.currentState?.setState(() { 
                    if (widget.connector == "") {
                      filterRowsWidget[viewID ?? ""] = (filterRowsWidget[viewID] ?? []).sublist(0, widget.index + 1); 
                    }
                  });
                }); 
              },
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(widget.connector =="or" ? Theme.of(context).primaryColor : Colors.transparent)), child: Padding( padding: const EdgeInsets.all(10), 
                child: Text((await getOnFlow(TranslateConstants.or)).toUpperCase(), style: TextStyle(color: widget.connector == "or" ? Colors.white :Colors.grey, fontSize: 11))),)
          ])
    ]);
  }
}
  
  Future<List<Widget>> getButtons() async {
    var buttons = <Widget>[];
    
    if (currentView != null && currentView!.isList && currentView!.actions.contains("import")) {
      buttons.add(
        PopupButtonWidget(
          tooltip: TranslateConstants.rowsImport,
          icon: Icons.upload,
          widget: MappingPopUpWidget(isExport: true, format: "csv")
        )
      );
    }
    return buttons;
  }