
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqldbui2/model/view.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/datagrid_button.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';

// ignore: must_be_immutable
class UpdaterRowWidget extends StatefulWidget implements ConvertorWidget {
  late GlobalKey<UpdaterRowWidgetState> rowKey;
  String type = "text"; 
  List<String> beforeColumn = [];
  String? columnName, label, name;
  @override dynamic value;
  bool isNull = false;
  Map<String, SchemaField> schema;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  UpdaterRowWidget ({ 
    required this.schema, 
    this.label, 
    this.type = "text", 
    this.beforeColumn = const [],
    this.columnName, 
    this.value, 
  }): super(key: GlobalKey<UpdaterRowWidgetState>()) {
     rowKey = key as GlobalKey<UpdaterRowWidgetState>;
  }

  @override UpdaterRowWidgetState createState() => UpdaterRowWidgetState();
}

class UpdaterRowWidgetState extends State<UpdaterRowWidget> {
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
      child: SizedBox( 
        height: 40, 
        child: UpdaterSubRowWidget(
              widget: this,
              schema: widget.schema,
              label: widget.label,
              type: widget.type, 
              columnName: widget.columnName,    
            )
          )
        );
  }
}

// ignore: must_be_immutable
class UpdaterSubRowWidget extends StatefulWidget {
  UpdaterRowWidgetState widget;
  String type = "text"; 
  String? columnName, label;
  int depth;
  bool isNull = false;
  int index;
  bool isSub = false;
  Map<String, SchemaField> schema;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  UpdaterSubRowWidget ({ 
    super.key,
    this.depth = 0,
    required this.widget,
    this.index = 1,
    required this.schema, 
    this.label, 
    this.type = "text", 
    this.isSub = false,
    this.columnName, 
  });

  @override UpdaterSubRowWidgetState createState() => UpdaterSubRowWidgetState();
}

class UpdaterSubRowWidgetState extends State<UpdaterSubRowWidget> {
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
      widget.type = widget.schema[widget.columnName]?.type ?? "text";
    }
    String url = widget.schema[widget.columnName] != null && widget.schema[widget.columnName]?.actionPath != ""  ? "${widget.schema[widget.columnName]!.actionPath}&shallow=enable" : "";
    Widget w = FutureBuilder<Widget>(future: Convertor.filterFieldByType(
      context, 
      widget.widget.widget as ConvertorWidget, 
      widget.type, 
      widget.columnName ?? "",
      TranslateConstants.valueFilterPlaceholder.toLowerCase(), this, true, false, url, 
      (widget.schema[widget.columnName]?.valuesPath ?? "") != "" ? widget.schema[widget.columnName]!.valuesPath : url, widget.columnName ?? "",
      currentView?.rules ?? []
      ), 
      builder: (a,b) {
        if ((b.data != null)) {
          return b.data!;
        }
        return Container();
    });

    Widget? w2;
    List<String> order = (widget.isSub ? widget.schema : realOrderMap(widget.schema.keys.toList(), widget.schema, false)).keys.where(
      (e) => !(widget.schema[e]?.hidden ?? false) ).toList();
    if (widget.schema[widget.columnName] != null && widget.schema[widget.columnName]!.type.contains("onetomany")) {
      String? column;
      if (widget.widget.widget.beforeColumn.length > widget.depth + 1) {
        column = widget.widget.widget.beforeColumn[ widget.depth + 1];
      }
      w2 = Padding( padding: EdgeInsets.only(left: 10), child: UpdaterSubRowWidget(
        widget: widget.widget,
        columnName: column,
        schema: widget.schema[widget.columnName]?.schema ?? {},
        depth: widget.depth + 1,
        isSub: true,
      ));
    } else if (widget.widget.widget.beforeColumn.length > widget.depth + 1) {
       widget.widget.widget.beforeColumn.sublist(0, widget.depth + 1);
    }
    MultiSelectController<String> ctrls = MultiSelectController<String>();
    List<DropdownItem<String>> items = [];
    for (var o in widget.schema.entries.where((e) => order.contains(e.key)).where( (o) => !o.value.readonly )) {
      if (items.where( (e) => e.value == o.key).isEmpty) {
          items.add(DropdownItem<String>(value: o.key, label: await getOnFlow(o.value.label), selected: widget.columnName == o.key));
          ctrls.addItem(items.last);
      }
    }
    return Row( 
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children : [    
      DatagridButtonWidget(selectedGrid: selectedGrid, schema: currentView?.schema ?? {}, mode: "edit field"),
      Container(
        padding: EdgeInsets.only(left: 10),
        height: 25,  
        width: (MediaQuery.of(context).size.width - menuSize) / 4, 
        child: MultiDropdown<String>(
        controller: ctrls,
        singleSelect: true,
        items: items,
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
                          hintText: (await getOnFlow("select an option")).toLowerCase(),
                          hintStyle: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 13, color:Theme.of(context).splashColor, fontWeight: FontWeight.w300),
                          prefixIcon: Icon(Icons.list, color: Theme.of(context).splashColor),
                          showClearIcon: false,
                          border:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                          focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
        ),
        searchDecoration: SearchFieldDecoration(
                          hintText: "       ${(await getOnFlow(TranslateConstants.search)).toLowerCase()}",
                          border : const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          focusedBorder : const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(5)))
        ),
        dropdownDecoration: DropdownDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          marginTop: 2,
                          maxHeight: 400,
                          header: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "       ${(await getOnFlow(TranslateConstants.selectValue)).toLowerCase()}",
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
                          selectedIcon:
                              const Icon(Icons.check_box, color: Colors.green),
                          disabledIcon:
                              Icon(Icons.lock, color: Colors.grey.shade300),
                        ),
                        validator: (value) {
                          if ((value == null || value.isEmpty)) {
                            return '';
                          }
                          return null;
                        },
                        onSelectionChange: (values) {
                          if (values.isEmpty) { return; }
                          setState(() {
                            widget.columnName = values.first;
                            cacheChanges[widget.columnName ?? ""] = null;
                            detectChanges[widget.columnName ?? ""] = GlobalKey();
                            widget.label = widget.schema[values.first]?.label;
                            widget.type = values.first == "id" ? "integer" : widget.schema[values.first]?.type ?? "text";
                          });
                        },
            )),
            ...(w2 != null ? [ w2 ] : [
              widget.columnName == null || widget.columnName == "" ? Container() : Padding( padding: const EdgeInsets.symmetric(horizontal: 10), 
                child: SizedBox( height: 25,  width: widget.type == "boolean" ? 100 : ((MediaQuery.of(context).size.width - menuSize) / 3) , child: 
                widget.isNull ? DropdownButtonFormField<String>( items: const [
                      DropdownMenuItem<String>(value: "NULL", child: Text("NULL", overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem<String>(value: "NOT NULL", child: Text("NOT NULL", overflow: TextOverflow.ellipsis))], 
                    value: cacheChanges[widget.columnName ?? ""], hint: Text((await getOnFlow(TranslateConstants.colNullFilter)).toLowerCase(), overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    validator: (value) { if (value == null) { return ""; } return null; },
                    onChanged: (value) { 
                      cacheChanges[widget.columnName ?? ""] = value ?? "NULL"; 
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
                    cacheChanges[widget.columnName ?? ""] = null;
                    widget.isNull = value ?? false; 
                  }),
                  activeColor: Theme.of(context).primaryColor, overlayColor:  WidgetStateProperty.resolveWith((states) => Theme.of(context).splashColor),
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(2.0), side: BorderSide.none ),
                  fillColor: WidgetStateProperty.resolveWith((states) => Theme.of(context).splashColor) )),
                Padding(padding: const EdgeInsets.only(right: 20), child: Text("null mode", style: TextStyle(fontSize: 12, color: Theme.of(context).splashColor))),
              ]),
          ]),
    ]);
  }
}