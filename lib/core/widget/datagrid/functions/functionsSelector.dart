import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functionMathRow.dart';

Map<String?, String> mathColName = {};
Map<String?, String> editMode = {};
Map<String?, String> commands = {};
class FunctionsSelectorWidget extends StatefulWidget {
  String mode = "all"; 
  var mathAllowed = true;
  String value = "total";
  List<DropdownMenuItem<String>> items = [];
  FunctionsSelectorWidget ({ Key? key, required this.mathAllowed, required this.items }): super(key: key);
  @override FunctionsSelectorWidgetState createState() => FunctionsSelectorWidgetState();
}
class FunctionsSelectorWidgetState extends State<FunctionsSelectorWidget> {
  @override Widget build(BuildContext context) {
    var toggles = ["all", "math"];
    Map<String, model.SchemaField> fields = {};
    if (mathColName[viewID] == null) { mathColName[viewID] = "total"; 
    } else { widget.value = mathColName[viewID] ?? "total"; }
    if (editMode[viewID] == null) { editMode[viewID] = "all"; }
    if (editMode[viewID] == "math") {
      for (var item in widget.items) {
        if (currentView!.schema[item.value] != null) { fields[item.value!] = currentView!.schema[item.value]!; 
        } else { fields[item.value!] = model.SchemaField(label: item.value!); }
      }
      fields[mathColName[viewID] ?? "total"] = model.SchemaField(label: mathColName[viewID] ?? "total");
      if (functionMathRowsWidget.isEmpty) {
        functionMathRowsWidget.add(FunctionMathRowWidget(items: widget.items));
        Future.delayed(const Duration(milliseconds: 100), () { globalGridWidgetKey.currentState?.setState(() { }); });
      } 
    } 
    GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();
    return Row( children: [ 
      widget.mathAllowed ? Padding(padding: const EdgeInsets.only(left: 10, top: 2), 
        child: MouseRegion( cursor: SystemMouseCursors.click,
          child: ToggleSwitch( labels: toggles, minHeight: 27.5, minWidth: 60, fontSize: 12, cornerRadius: 5,
          initialLabelIndex: toggles.indexWhere((element) => element.toLowerCase() == editMode[viewID]),
          dividerColor: Colors.white, inactiveFgColor: Theme.of(context).splashColor,
          totalSwitches: toggles.length, inactiveBgColor: Theme.of(context).secondaryHeaderColor,
          onToggle: (index) { 
            rects.remove(viewID);
            filterTempOrderView.remove(viewID);
            editMode[viewID] = toggles[index ?? 0]; 
            globalGridWidgetKey.currentState?.setState(() { });
          },),
      )) : Container(),
      editMode[viewID] == "math" ? Container( margin: const EdgeInsets.only(left: 20, right: 10, top: 2), height: 25,  
        width: (MediaQuery.of(context).size.width - menuSize) / 4, 
          child: TextFormField( key: formKey,
          textAlign: TextAlign.start,
          initialValue: mathColName[viewID]?.toString() ?? widget.value,
          style: const TextStyle(fontSize: 14, color:  Colors.white, overflow: TextOverflow.ellipsis),
          enabled: true, 
          autocorrect: true,  
          decoration: InputDecoration(
            suffixIconColor: Theme.of(context).splashColor,
            enabledBorder: OutlineInputBorder( borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 0) ),
            border: OutlineInputBorder( borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Theme.of(context).splashColor, width: 0)),
            isDense: true, 
            hintStyle: TextStyle(fontSize: 13, color: Theme.of(context).splashColor, fontWeight: FontWeight.w300), // you need this
            floatingLabelBehavior: FloatingLabelBehavior.always, 
            filled: true, fillColor: Theme.of(context).secondaryHeaderColor,
            contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
            suffixIcon: const Icon(Icons.text_fields), 
            hintText: "enter result column name...",  
            labelText: "",
            errorStyle: const TextStyle(fontSize: 0,),
          ),
          onChanged: (String? value) { 
            Future.delayed(const Duration(seconds: 2), () { 
              if (value == widget.value && formKey.currentState != null && formKey.currentState!.validate()) {
                var keysToChange = cacheChanges.keys.where((element) => element.contains(mathColName[viewID] ?? "total")).toList();
                for (var key in keysToChange) {
                  cacheChanges[key.replaceAll(mathColName[viewID] ?? "total", value ?? "total")] = cacheChanges[key];
                  cacheChanges.remove(key);
                }
                mathColName[viewID] = value ?? "total";
                globalGridWidgetKey.currentState?.setState(() { }); 
              }
            });
            widget.value = value ?? "total"; 
          },
          validator: (String? value) {
            if (value == null) { return "please enter a result column value..."; }  
            if (currentView!.schema.containsKey(value) || value == "id") {
              return "column name already exists in the schema... can't choose this name";
            }
            return null; 
          }))
        : Container(),
        editMode[viewID] == "math" ? Padding(padding: const EdgeInsets.only(left: 5, top: 4), child: Container( height: 25, child: PopupMenuButton( splashRadius: 1,
          constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width / 1.1), padding: const EdgeInsets.all(0),
          color: Theme.of(context).secondaryHeaderColor, tooltip:  "export ${currentView!.isList ? "selected " : ""}rows with math operation...",
          icon: Icon(size: 20, Icons.file_download, color: Theme.of(context).highlightColor), onSelected: (value) { },
          itemBuilder: (BuildContext bc) {
            return [ PopupMenuItem(enabled: false, child: StatefulBuilder(  
              builder: (BuildContext context, StateSetter setState) {
                return MappingPopUpWidget(isExport: true, format: "csv", forcedSchema: fields,
              ); })) ]; 
        }))) : Container()
    ]);
  }
}
