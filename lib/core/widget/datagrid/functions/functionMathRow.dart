import 'dart:math';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functionsSelector.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';

String cmdToSQLRow(String command) {
  command = command.toLowerCase().replaceAll("[", "").replaceAll("]", "");
  if (command.contains("pi")) { command = command.replaceAll("pi", "PI()"); 
    } else if (command.contains("e")) { command = command.replaceAll("E", "2.71828182845904523536"); 
    } else if (command.contains("ln10")) { command = command.replaceAll("ln10", "2.302585092994046"); 
    } else if (command.contains("ln2")) { command = command.replaceAll("ln2", "0.6931471805599453"); 
    } else if (command.contains("log10e")) { command = command.replaceAll("log10e", "0.4342944819032518"); 
    } else if (command.contains("log2e")) { command = command.replaceAll("log2e", "1.4426950408889634"); }
    final regexpFunc = RegExp(r'\w+\([0-9\,\s\.]+\)'); 
    List<String> matchesFunc = regexpFunc.allMatches(command).map((e) =>  command.toString().substring(e.start, e.end)).toList();
    for( var match in matchesFunc) {
      if (match.contains("acos(")) { 
        command = command.replaceAll(match, acos(double.parse(match.replaceAll("acos(", "ACOS("))).toString()); 
      } else if (match.contains("asin(")) { 
        command = command.replaceAll(match, asin(double.parse(match.replaceAll("asin(", "ASIN()"))).toString()); 
      } else if (match.contains("atan(")) { 
        command = command.replaceAll(match, atan(double.parse(match.replaceAll("atan(", "ATAN("))).toString()); 
      } else if (match.contains("cos(")) { 
        command = command.replaceAll(match, cos(double.parse(match.replaceAll("cos(", "COS("))).toString()); 
      } else if (match.contains("exp(")) { 
        command = command.replaceAll(match, exp(double.parse(match.replaceAll("exp(", "EXP("))).toString()); 
      } else if (match.contains("log(")) { 
        command = command.replaceAll(match, log(double.parse(match.replaceAll("log(", "LOG("))).toString()); 
      } else if (match.contains("sin(")) { 
        command = command.replaceAll(match, sin(double.parse(match.replaceAll("sin(", "SIN("))).toString()); 
      } else if (match.contains("sqrt(")) { 
        command = command.replaceAll(match, sqrt(double.parse(match.replaceAll("sqrt(", "SQRT("))).toString()); 
      } else if (match.contains("tan(")) { 
        command = command.replaceAll(match, tan(double.parse(match.replaceAll("TAN(", ""))).toString()); 
      } else if (match.contains("atan2(")) { 
        command = command.replaceAll(match, tan(double.parse(match.replaceAll("atan2(", "ATN2("))).toString()); 
      } else if (match.contains("pow(")) { 
        command = command.replaceAll(match, tan(double.parse(match.replaceAll("pow(", "POWER("))).toString()); 
      }
    }
    return "$command as ${mathColName[viewID] ?? "total"}";
}
void evalCmd(String? value, List<GridCell> cells) {
  if (value == null || value == "") { return; }
  final regexp = RegExp(r'\[\w+\]'); 
  final matches = regexp.allMatches(value).map((e) => value.substring(e.start + 1, e.end - 1)).toList();
  var command = value ?? "";
  var id = cells.first.value;
  try {
    for (var match in matches) {
      var col = cells.firstWhere((element) => match == element.columnName);
      if (cacheChanges["$id:${col.columnName}"] != null) { 
        command = command.replaceAll("[${col.columnName}]", cacheChanges["$id:${col.columnName}"]); 
      } else if (col.value != null) { 
        command = command.replaceAll("[${col.columnName}]", col.value.toString());
      }
    }
    command = command.toLowerCase();
    // MODIF CONST ALLOWED
    if (command.contains("pi")) { command = command.replaceAll("pi", "3.14159265358979323846"); 
    } else if (command.contains("e")) { command = command.replaceAll("E", "2.71828182845904523536"); 
    } else if (command.contains("ln10")) { command = command.replaceAll("ln10", "2.302585092994046"); 
    } else if (command.contains("ln2")) { command = command.replaceAll("ln2", "0.6931471805599453"); 
    } else if (command.contains("log10e")) { command = command.replaceAll("log10e", "0.4342944819032518"); 
    } else if (command.contains("log2e")) { command = command.replaceAll("log2e", "1.4426950408889634"); }
    final regexpFunc = RegExp(r'\w+\([0-9\,\s\.]+\)'); 
    List<String> matchesFunc = regexpFunc.allMatches(command).map((e) =>  command.toString().substring(e.start, e.end)).toList();
    for( var match in matchesFunc) {
      if (match.contains("acos(")) { 
        command = command.replaceAll(match, acos(double.parse(match.replaceAll("acos(", "").replaceAll(")", ""))).toString()); 
      } else if (match.contains("asin(")) { 
        command = command.replaceAll(match, asin(double.parse(match.replaceAll("asin(", "").replaceAll(")", ""))).toString()); 
      } else if (match.contains("atan(")) { 
        command = command.replaceAll(match, atan(double.parse(match.replaceAll("atan(", "").replaceAll(")", ""))).toString()); 
      } else if (match.contains("cos(")) { 
        command = command.replaceAll(match, cos(double.parse(match.replaceAll("cos(", "").replaceAll(")", ""))).toString()); 
      } else if (match.contains("exp(")) { 
        command = command.replaceAll(match, exp(double.parse(match.replaceAll("exp(", "").replaceAll(")", ""))).toString()); 
      } else if (match.contains("log(")) { 
        command = command.replaceAll(match, log(double.parse(match.replaceAll("log(", "").replaceAll(")", ""))).toString()); 
      } else if (match.contains("sin(")) { 
        command = command.replaceAll(match, sin(double.parse(match.replaceAll("sin(", "").replaceAll(")", ""))).toString()); 
      } else if (match.contains("sqrt(")) { 
        command = command.replaceAll(match, sqrt(double.parse(match.replaceAll("sqrt(", "").replaceAll(")", ""))).toString()); 
      } else if (match.contains("tan(")) { 
        command = command.replaceAll(match, tan(double.parse(match.replaceAll("tan(", "").replaceAll(")", ""))).toString()); 
      } else if (match.contains("atan2(")) { 
                    var both = match.replaceAll("atan2(", "").replaceAll(")", "").split(",");
                    var d = both.map((e) => double.parse(e)).toList();
                    command = command.replaceAll(match, atan2(d[0], d[1]).toString()).toString(); 
                  } else if (match.contains("pow(")) { 
                    var both = match.replaceAll("pow(", "").replaceAll(")", "").split(",");
                    var d = both.map((e) => double.parse(e)).toList();
                    command = command.replaceAll(match, pow(d[0], d[1]).toString()).toString(); 
                  }
    }
    cacheChanges["$id:${mathColName[viewID] ?? "total"}"]= eval(command); 
  } catch (e) {  cacheChanges["$id:${mathColName[viewID] ?? "total"}"]= "NaN"; }
}

class FunctionMathRowWidget extends StatefulWidget implements ConvertorWidget {
  String? addColumnName;
  List<DropdownMenuItem<String>> items = [];
  @override dynamic value = "";
  FunctionMathRowWidget ({ Key? key, required this.items }): super(key: key);
  @override FunctionMathRowWidgetState createState() => FunctionMathRowWidgetState();
}
class FunctionMathRowWidgetState extends State<FunctionMathRowWidget> {
  @override Widget build(BuildContext context) {
    if (commands[viewID] != null && widget.value == "") { widget.value = commands[viewID]; }
    return Container( height: 45,
      width: MediaQuery.of(context).size.width - menuSize,
      padding: const EdgeInsets.only(left: 48), child: Row(children: [
        Icon(Icons.functions, size: 20, color: Theme.of(context).splashColor),
        Container( margin: const EdgeInsets.only(left: 10, right: 10), height: 25,  width: (MediaQuery.of(context).size.width - menuSize) / 2, 
          child: Convertor.filterFieldByType(context, widget, "varchar", "enter math operation", this, true, false, "", "")),
        InkWell(onTap: () {
          commands[viewID] = widget.value;
          globalGridWidgetKey.currentState!.setState(() { });
        }, mouseCursor: SystemMouseCursors.click,
        child: const Icon(Icons.check, color: Colors.white, size: 20,)),
        Container( height: 25, margin: const EdgeInsets.only(left: 10, right: 10),
          width: (MediaQuery.of(context).size.width - menuSize) / 6, child: DropdownButtonFormField<String>( 
            items: widget.items.where((element) => element.value != "id").toList(), 
            value: widget.addColumnName, 
            hint: Text("select a column to filter...", overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).splashColor)),
            isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
            validator: (value) { if (value == null) { return "select a column to add to command..."; } return null; },
            onChanged: (value) { setState(() { widget.addColumnName = value ?? ""; }); }, 
        dropdownColor: Theme.of(context).secondaryHeaderColor,
        decoration: InputDecoration( suffixIconColor: Theme.of(context).primaryColor, errorStyle: const TextStyle(fontSize: 0,),
          floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
          fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
          border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
        ))),
        InkWell(onTap: () {
          if (widget.addColumnName == null || widget.addColumnName == "") { return; }
          setState(() {
            widget.value = widget.value + "[" + widget.addColumnName! + "] ";
          });
        }, mouseCursor: SystemMouseCursors.click,
        child: const Icon(Icons.add, color: Colors.white, size: 20,)),
    ]));
  }
}