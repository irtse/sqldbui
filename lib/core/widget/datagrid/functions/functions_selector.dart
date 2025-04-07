

import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/popup_button.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/function_math_row.dart';

Map<String?, bool> showFunctions = {};
Map<String?, String> mathColName = {};
Map<String?, String> editMode = {};
Map<String?, String> commands = {};
// ignore: must_be_immutable
class FunctionsSelectorWidget extends StatefulWidget {
  String mode = TranslateConstants.edit.toLowerCase(); 
  var mathAllowed = true;
  String value = TranslateConstants.total.toLowerCase();
  List<DropdownMenuItem<String>> items = [];
  FunctionsSelectorWidget ({ super.key, required this.mathAllowed, required this.items });
  @override FunctionsSelectorWidgetState createState() => FunctionsSelectorWidgetState();
}
class FunctionsSelectorWidgetState extends State<FunctionsSelectorWidget> {
  @override Widget build(BuildContext context) {
    var toggles = [TranslateConstants.edit.toLowerCase(), TranslateConstants.math.toLowerCase()];
    Map<String, model.SchemaField> fields = {};
    if (mathColName[viewID] == null) { mathColName[viewID] = TranslateConstants.total.toLowerCase(); 
    } else { widget.value = mathColName[viewID] ?? TranslateConstants.total.toLowerCase(); }
    if (editMode[viewID] == null) { editMode[viewID] = TranslateConstants.edit.toLowerCase(); }
    if (editMode[viewID] == TranslateConstants.math.toLowerCase()) {
      for (var item in widget.items) {
        if (currentView!.schema[item.value] != null) { fields[item.value!] = currentView!.schema[item.value]!; 
        } else if (item.value != null) { fields[item.value!] = model.SchemaField(label: item.value!); }
      }
      fields[mathColName[viewID] ?? TranslateConstants.total.toLowerCase()] = model.SchemaField(label: mathColName[viewID] ?? TranslateConstants.total.toLowerCase());
      if (functionMathRowsWidget.isEmpty) {
        functionMathRowsWidget.add(FunctionMathRowWidget(items: widget.items));
        Future.delayed(const Duration(milliseconds: 100), () { globalGridWidgetKey.currentState?.setState(() { }); });
      } 
    } 
    GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();
    if (showFunctions[viewID] == null) { showFunctions[viewID] = false; }
    return Row( children: [ 
      Padding( padding: const EdgeInsets.only(top: 2), 
        child: InkWell( mouseCursor: SystemMouseCursors.click,
          onTap: () { globalGridWidgetKey.currentState?.setState(() { showFunctions[viewID] = !showFunctions[viewID]!; },); },
          child: Icon( showFunctions[viewID]! ? Icons.calculate : Icons.calculate_outlined, size: 25, color: Theme.of(context).splashColor) ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 20, top: 2), 
        child: MouseRegion( 
          cursor: SystemMouseCursors.click,
          child: ToggleSwitch( 
            labels: toggles, 
            minHeight: 27.5, 
            minWidth: 60, 
            fontSize: 12, 
            cornerRadius: 5,
            initialLabelIndex: toggles.indexWhere((element) => element.toLowerCase() == editMode[viewID]),
            dividerColor: Colors.white, inactiveFgColor: Theme.of(context).splashColor,
            totalSwitches: toggles.length, inactiveBgColor: Theme.of(context).secondaryHeaderColor,
            onToggle: (index) { 
              rects.remove(viewID);
              filterTempOrderView.remove(viewID);
              editMode[viewID] = toggles[index ?? 0]; 
              globalGridWidgetKey.currentState?.setState(() { });
            }),
      )),
      editMode[viewID] == TranslateConstants.math.toLowerCase() ? Container( margin: const EdgeInsets.only(left: 20, right: 10, top: 2), height: 25,  
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
              borderSide: BorderSide(color: Theme.of(context).splashColor, 
              width: 0)
            ),
            isDense: true, 
            hintStyle: TextStyle(fontSize: 13, color: Theme.of(context).splashColor, fontWeight: FontWeight.w300), // you need this
            floatingLabelBehavior: FloatingLabelBehavior.always, 
            filled: true, fillColor: Theme.of(context).secondaryHeaderColor,
            contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
            suffixIcon: const Icon(Icons.text_fields), 
            hintText: TranslateConstants.mathPlaceholder.toLowerCase(),  
            labelText: "",
            errorStyle: const TextStyle(fontSize: 0,),
          ),
          onChanged: (String? value) { 
            Future.delayed(const Duration(seconds: 2), () { 
              if (value == widget.value && formKey.currentState != null && formKey.currentState!.validate()) {
                var keysToChange = cacheChanges.keys.where((element) => element.contains(mathColName[viewID] ?? TranslateConstants.total.toLowerCase())).toList();
                for (var key in keysToChange) {
                  cacheChanges[key.replaceAll(mathColName[viewID] ?? TranslateConstants.total.toLowerCase(), value ?? TranslateConstants.total.toLowerCase())] = cacheChanges[key];
                  cacheChanges.remove(key);
                }
                mathColName[viewID] = value ?? TranslateConstants.total.toLowerCase();
                globalGridWidgetKey.currentState?.setState(() { }); 
              }
            });
            widget.value = value ?? TranslateConstants.total.toLowerCase(); 
          },
          validator: (String? value) {
            if (value == null) { return TranslateConstants.mathValuePlaceholder.toLowerCase(); }  
            if (currentView!.schema.containsKey(value) || value == "id") {
              return TranslateConstants.mathError.toLowerCase();
            }
            return null; 
          }))
        : Container(),
        editMode[viewID] == TranslateConstants.math.toLowerCase() ? Padding(
          padding: const EdgeInsets.only(left: 5, top: 4), 
          child: SizedBox( 
            height: 25, 
            child: PopupButtonWidget(
              tooltip: (currentView!.isList ? TranslateConstants.exportMathList : TranslateConstants.exportMathList).toLowerCase(),
              icon: Icons.file_download,
              widget: MappingPopUpWidget(isExport: true, format: "csv", forcedSchema: fields),
            )
          )
        ) : Container()
    ]);
  }
}
