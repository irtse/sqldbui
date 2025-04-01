import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:sqldbui2/core/utils.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/cell.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';

String transform(String match, String prefix) {
  return match.replaceAll("$prefix(", "").replaceAll(")", "");
}

String cmdToSQLRow(String command) {
  command = command.toLowerCase().replaceAll("[", "").replaceAll("]", "");
  command = convertMath(command);
  final regexpFunc = RegExp(r'\w+\([0-9\,\s\.]+\)'); 
  List<String> matchesFunc = regexpFunc.allMatches(command).map((e) =>  command.toString().substring(e.start, e.end)).toList();
  for( var match in matchesFunc) {
    for (var prefix in ["acos", "asin", "atan", "cos", "exp", "log", "sin", "sqrt", "tan", "atan2", "pow", "atan2", "pow"]) {
      if (match.contains("$prefix(")) { 
        String compare = (prefix == "atan2" ? "atn2" : ( prefix == "pow" ? "power" : prefix)).toUpperCase();
        command = command.replaceAll(match, getMathFunc(prefix)(double.parse(match.replaceAll("$prefix(", "$compare("))).toString()); 
      }
    }
  }
  return "${command.replaceAll("+", "%2B")} as ${mathColName[viewID] ?? "total"}";
}

void evalCmd(String command, List<GridCell> cells) {
  if (command == "") { return; }
  command = command.toLowerCase();
  try {
    for (var match in RegExp(r'\[\w+\]').allMatches(command).map((e) => command.substring(e.start + 1, e.end - 1)).toList()) {
      var col = cells.firstWhere((element) => match == element.columnName);
      var replaced = cacheChanges["${cells.first.value}:${col.columnName}"] ?? col.value;
      if (replaced != null) { command = command.replaceAll("[${col.columnName}]", replaced);}
    }
    command = convertMath(command);
    for( var match in RegExp(r'\w+\([0-9\,\s\.]+\)').allMatches(command).map(
      (e) => command.toString().substring(e.start, e.end)).toList()
    ) {
      for (var prefix in ["acos", "asin", "atan", "cos", "exp", "log", "sin", "sqrt", "tan", "atan2", "pow"]) {
        if (match.contains("atan2(") || match.contains("pow(")) { 
          var both = transform(match, prefix).split(",").map((e) => double.parse(e)).toList();
          command = command.replaceAll(match, getMathDoubleFunc(prefix)(both[0], both[1]).toString()).toString(); 
        } else { command = command.replaceAll(match, getMathFunc(prefix)(double.parse(transform(match, prefix))).toString());  }
      }
    }
    cacheChanges["${cells.first.value}:${mathColName[viewID] ?? "total"}"]= eval(command); 
  } catch (e) {  cacheChanges["${cells.first.value}:${mathColName[viewID] ?? "total"}"]= "NaN"; }
}

// ignore: must_be_immutable
class FunctionMathRowWidget extends StatefulWidget implements ConvertorWidget {
  String? addColumnName;
  List<DropdownMenuItem<String>> items = [];
  @override dynamic value = "";
  FunctionMathRowWidget ({ super.key, required this.items });
  @override FunctionMathRowWidgetState createState() => FunctionMathRowWidgetState();
}
class FunctionMathRowWidgetState extends State<FunctionMathRowWidget> {
  @override Widget build(BuildContext context) {
    if (commands[viewID] != null && widget.value == "") { widget.value = commands[viewID]; }
    return Container( 
      height: 45,
      width: MediaQuery.of(context).size.width - menuSize,
      padding: const EdgeInsets.only(left: 48), child: Row(children: [
        Icon(Icons.functions, size: 20, color: Theme.of(context).splashColor),
        Container( 
          height: 25,
          margin: const EdgeInsets.only(left: 10, right: 10), 
          width: (MediaQuery.of(context).size.width - menuSize) / 2, 
          child: Convertor.filterFieldByType(context, widget, "varchar", "enter math operation", this, true, false, "", "")
        ),
        InkWell(onTap: () {
            commands[viewID] = widget.value;
            globalGridWidgetKey.currentState!.setState(() { });
          }, 
          mouseCursor: SystemMouseCursors.click,
          child: const Icon(Icons.check, color: Colors.white, size: 20,)
        ),
        Container( 
          height: 25, 
          margin: const EdgeInsets.only(left: 10, right: 10),
          width: (MediaQuery.of(context).size.width - menuSize) / 6, 
          child: DropdownButtonFormField<String>( 
              items: widget.items.where((element) => element.value != "id").toList(), 
              value: widget.addColumnName, 
              hint: Text("select a column to filter...", overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
              isExpanded: true, 
              style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
              validator: (value) { if (value == null) { return "select a column to add to command..."; } return null; },
              onChanged: (value) { setState(() { widget.addColumnName = value ?? ""; }); }, 
            dropdownColor: Theme.of(context).secondaryHeaderColor,
            decoration: InputDecoration( 
              suffixIconColor: Theme.of(context).primaryColor, 
              errorStyle: const TextStyle(fontSize: 0,),
              floatingLabelBehavior: FloatingLabelBehavior.always, 
              filled: true, 
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
              fillColor: (Theme.of(context).secondaryHeaderColor),  
              hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
              border: const OutlineInputBorder(), 
              contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
            )
          )
        ),
        InkWell(
          onTap: () {
            if (widget.addColumnName == null || widget.addColumnName == "") { return; }
            setState(() { widget.value = widget.value + "[" + widget.addColumnName! + "] "; });
          }, 
          mouseCursor: SystemMouseCursors.click,
          child: const Icon(Icons.add, color: Colors.white, size: 20)
        ),
    ]));
  }
}