import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/widget/form/convertors/manytomany.dart';
import 'package:sqldbui2/core/widget/form/convertors/onetomany.dart';
import 'package:sqldbui2/core/widget/form/convertors/dropdown.dart';
import 'package:sqldbui2/core/widget/form/convertors/number.dart';
import 'package:sqldbui2/core/widget/form/convertors/text.dart';
import 'package:sqldbui2/core/widget/form/convertors/date.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';

Map<String, dynamic> cacheChanges = {};
Map<String, GlobalKey<FormFieldState>> detectChanges = {};
abstract class ConvertorWidget {
  abstract dynamic value;
}
class Convertor {
  static Widget filterFieldByType(BuildContext context, ConvertorWidget widget, String type, 
    String label, State<StatefulWidget> state, bool isDark, bool isGrid, String url, String id) {
    if (widget.value == "no info...") { widget.value = null; }
    GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();
    var dec = InputDecoration( errorStyle: const TextStyle(fontSize: 0), isDense: true, 
                suffixStyle: TextStyle(color: Theme.of(context).splashColor),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w300),
                border: const OutlineInputBorder(borderSide: BorderSide(width: 0, style: BorderStyle.none,)),
                hintText: '${type.contains("enum") ? "select" : "enter"} ${type.contains("time") || type.contains("date") ? "date" : ""} value...');
    bool isText = type.contains("text") || type.contains("varchar");
    bool isInt = type.contains("double") || type.contains("float") || type.contains("money") || type.contains("decimal") || type.contains("int");
    Widget w = Container();
    if (isText || (isInt && url == "")) { 
        w = TextFormField( key: formKey,
          textAlign: isGrid ? TextAlign.center : TextAlign.start,
          initialValue: cacheChanges[id]?.toString() ?? widget.value?.toString(),
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black, overflow: TextOverflow.ellipsis),
          enabled: true, 
          autocorrect: true,  
          expands: isGrid,
          minLines: isGrid ? null : 1,
          maxLines: isGrid ? null : 1,
          decoration: isGrid ? dec : InputDecoration(
            suffixIconColor: Theme.of(context).splashColor,
            enabledBorder: OutlineInputBorder( borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 0) ),
            border: OutlineInputBorder( borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Theme.of(context).splashColor, width: 0)),
            isDense: true, 
            hintStyle: TextStyle(fontSize: 13, color: Theme.of(context).splashColor, fontWeight: FontWeight.w300), // you need this
            floatingLabelBehavior: FloatingLabelBehavior.always, 
            filled: true, fillColor: isDark ? Theme.of(context).secondaryHeaderColor :Colors.white,
            contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
            suffixIcon: Icon(isText ? Icons.text_fields : (type.contains("money") ? Icons.euro : Icons.onetwothree)), 
            hintText: "$label...",  
            labelText: isDark ? "" : "value ${isText ? "" : "(numeric)"}",
            errorStyle: const TextStyle(fontSize: 0,),
          ),
          onChanged: (String? value) { 
            widget.value = value; 
            if (id != "") {
              detectChanges[id] = formKey;
              cacheChanges[id] = widget.value;
            }
          },
          validator: (String? value) {
            if (value == null) { return "please enter a filter value..."; }  
            if (!isText) {
              if (value.isEmpty || !RegExp(r'^-?[0-9]*\.?[0-9]*$').hasMatch(value)) { return "please enter a valid number..."; }
            }
            return null; 
          });
      } else if (type.contains("bool")) {
        var def = (cacheChanges[id]?.toString() ?? widget.value.toString()) == "true" 
          || (cacheChanges[id]?.toString() ?? widget.value.toString()) == "yes";
        ValueNotifier<bool> ctrl = ValueNotifier(def);
        w = AdvancedSwitch( key: formKey,
          width: isGrid ? 150 : (isDark ? 175 : 212), 
          initialValue: def, 
          controller: ctrl,
          activeColor: Colors.green, inactiveColor: isDark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).splashColor,
          activeChild: const Text("yes"), inactiveChild: const Text("no", style: TextStyle(color: Colors.white)),  
          borderRadius:  const BorderRadius.all(Radius.circular(15)), height: 30.0, disabledOpacity: 0.5,
          onChanged: (value) { 
            widget.value = value == true ? "true" : "false"; 
            if (id != "") {
              detectChanges[id] = formKey;
              cacheChanges[id] = widget.value;
            }
          },);
    } else if (type.contains("time") || type.contains("date")) { 
      var def = cacheChanges[id] ?? widget.value;
      w = DateTimeField( key: formKey,
        textAlign: isGrid ? TextAlign.center : TextAlign.start,
        initialValue: def == null ? null : DateTime.parse(def!),
        validator: (DateTime? value) {
          if (value == null) { return ""; }
          return null;
        },
        format: intl.DateFormat('y-M-dd'),
        // mode: widget.type == "time" ? DateTimeFieldPickerMode.time : DateTimeFieldPickerMode.date,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
        decoration: isGrid ? dec : InputDecoration(
            suffixIcon: const Icon(Icons.calendar_month, size: 18,),
            suffixIconColor: Theme.of(context).splashColor,
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
            helperStyle: const TextStyle(fontSize: 0),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            errorStyle: const TextStyle(fontSize: 0),
            hintStyle: TextStyle(fontSize: 13, color: Theme.of(context).splashColor, fontWeight: FontWeight.w300),
            border: OutlineInputBorder( borderSide: BorderSide(color: Theme.of(context).splashColor, width: 0) ),
            fillColor: isDark ? Theme.of(context).secondaryHeaderColor :Colors.white,
            contentPadding: const EdgeInsets.only(top: 1, left: 20.0, right: 20.0, bottom: 20),
            hintText: "",
            labelText: isDark ? "" : label.toLowerCase(),
          ),
        onShowPicker: (context, currentValue) { return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: widget.value == null ? currentValue : DateTime.parse(widget.value!),
              lastDate: DateTime(2100));
        },
        onChanged: (DateTime? value) { 
          state.setState(() { 
            widget.value = value?.toIso8601String(); 
            if (id != "") {
              detectChanges[id] = formKey;
              cacheChanges[id] = widget.value;
            }
          });
        },
      );
    } else if (type.contains("enum") ) {
      var items = <DropdownMenuItem<String>>[];
      for (var item in type.replaceAll("enum__", "").split("_")) { 
        if (items.where((element) => element.value == item).isEmpty) {
          items.add(DropdownMenuItem<String>(value: item, alignment: isGrid ? Alignment.center : Alignment.centerLeft, 
            child: Text(item, overflow: TextOverflow.ellipsis),));
        }
      }
      w = DropdownButtonFormField<String>( key: formKey, items: items, isExpanded: true,
        alignment: isGrid ? Alignment.center : Alignment.centerLeft,
        value: cacheChanges[id]?.toString() ?? widget.value?.toString(), elevation: 1,
        validator: (values) { if (values == null) { return "please select a value..."; } return null; },
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300,
         color: isDark ? Colors.white : Colors.black, overflow: TextOverflow.ellipsis),
        hint: Text("select value...", 
              overflow: TextOverflow.ellipsis, softWrap: true, 
              style: TextStyle(fontSize: 13, color: isGrid ? Colors.grey : Theme.of(context).splashColor)),
        onChanged: (value) { 
          widget.value = value; 
          if (isGrid) { globalGridWidgetKey.currentState?.setState(() { }); }
          if (id != "") {
            detectChanges[id] = formKey;
            cacheChanges[id] = widget.value;
          }
        }, 
        dropdownColor: isDark ? Theme.of(context).secondaryHeaderColor : null,
        decoration: isGrid ? dec : InputDecoration( 
          labelText: isDark ? "" : "value",
          errorStyle: const TextStyle(fontSize: 0),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true, constraints: const BoxConstraints(minWidth: 0),
          labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
          suffixIconColor: isDark ? Theme.of(context).splashColor : Colors.grey,
          fillColor:isDark ? Theme.of(context).secondaryHeaderColor : Colors.white, 
          contentPadding: EdgeInsets.only(top: isDark ? 10 : 17, left: 10.0, right: 10.0),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
          hintStyle: TextStyle(fontSize: 13, color: isDark && !isGrid ? Theme.of(context).splashColor : Colors.grey),
          border: OutlineInputBorder( borderSide: BorderSide(color: Theme.of(context).splashColor, width: 0) ),
        ),
      );
    } else if (type.contains("link") && url != "") {
      w = FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(url, true, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
          List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
          Map<String, model.Shallowed> mapped = <String, model.Shallowed>{};
          bool found = false;
          if (snap.hasData && snap.data!.data != null) {
            for (var item in snap.data!.data!) {
              var v = item.name ?? "${item.id}";
              
              v = v.replaceAll("db", "").replaceAll("_", " ");
              if (item.id.toString() == widget.value) { widget.value = v.toString(); }
              var t = items.where((element) => element.value == v);
              if (!mapped.containsKey(v) && t.isEmpty){
                mapped[v]=item;
                if((currentView!.isEmpty || !(currentView!.isEmpty && !item.actions.contains("post")))
                && items.where((element) => element.value == v,).isEmpty) {
                  if ( v.toString() == widget.value.toString() ) { 
                    found = true; 
                    widget.value = item.id.toString();
                  }
                  items.add(DropdownMenuItem<String>(value: item.id.toString(),  alignment: isGrid ? Alignment.center : Alignment.centerLeft,
                    child: Text(v.toString(), overflow: TextOverflow.ellipsis,),));
                }
              }
            }
          }
          if (!found &&  widget.value != null) { 
            return TextFormField(
              textAlign: isGrid ? TextAlign.center : TextAlign.start,
              initialValue: cacheChanges[id]?.toString() ?? widget.value?.toString(),
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black, 
                overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w300),
              enabled: false, 
              autocorrect: true,  
              expands: isGrid,
              minLines: null,
              maxLines: null,
              decoration: isGrid ? dec : InputDecoration(
                suffixIconColor: Theme.of(context).splashColor,
                enabledBorder: OutlineInputBorder( borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 0) ),
                border: OutlineInputBorder( borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Theme.of(context).splashColor, width: 0)),
                isDense: true, 
                hintStyle: TextStyle(fontSize: 13, color: Theme.of(context).splashColor, fontWeight: FontWeight.w300), // you need this
                floatingLabelBehavior: FloatingLabelBehavior.always, 
                filled: true, fillColor: isDark ? Theme.of(context).secondaryHeaderColor :Colors.white,
                contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
                suffixIcon: Icon(isText ? Icons.text_fields : (type.contains("money") ? Icons.euro : Icons.onetwothree)), 
                hintText: "filter $label...",  
                labelText: isDark ? "" : "value ${isText ? "" : "(numeric)"}",
                errorStyle: const TextStyle(fontSize: 0,),
              ),
              validator: (String? value) {
                if (value == null) { return "please enter a filter value..."; }  
                if (value.isEmpty || !RegExp(r'^-?[0-9]*\.?[0-9]*$').hasMatch(value)) { return "please enter a valid number..."; }
                return null; 
              });
          }
          return DropdownButtonFormField<String>( key: formKey, items: items,
            alignment: isGrid ? Alignment.center : Alignment.centerLeft, isExpanded: true,
            hint: Text("select value...", 
              overflow: TextOverflow.ellipsis, softWrap: true, 
              style: TextStyle(color: isGrid ? Colors.grey : Theme.of(context).splashColor, 
                      fontSize: 13, fontWeight: FontWeight.w300)),
            value: cacheChanges[id]?.toString() ?? widget.value?.toString(),
            validator: (values) { if (values == null) { return "please select a value..."; } return null; },
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black, 
              overflow: TextOverflow.ellipsis),
            onChanged: (value) { 
              widget.value = value; 
              if (id != "") {
                detectChanges[id] = formKey;
                cacheChanges[id] = widget.value;
              }
            }, 
            dropdownColor: isDark ? Theme.of(context).secondaryHeaderColor : null,
            decoration: isGrid ? dec : InputDecoration( 
              labelText: isDark ? "" : "value",
              errorStyle: const TextStyle(fontSize: 0),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              filled: true, constraints: const BoxConstraints(minWidth: 0),
              labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              suffixIconColor: isDark ? Theme.of(context).splashColor : Colors.grey,
              fillColor:isDark ? Theme.of(context).secondaryHeaderColor : Colors.white, 
              contentPadding: EdgeInsets.only(top: isDark ? 10 : 17, left: 20.0, right: 20.0),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
              hintStyle: TextStyle(fontSize: 13, color: isDark && !isGrid ? Theme.of(context).splashColor : Colors.grey, fontWeight: FontWeight.w300),
              border: OutlineInputBorder( borderSide: BorderSide(color: Theme.of(context).splashColor, width: 0) ),
            ),
          );
      });
    }
    return w;
  }

  static Widget? formFieldByType(Map<String, dynamic> form, BuildContext context, String schemaName, String type, String name, String label, 
  String description, bool require, bool readOnly, dynamic value, String? url, String path, double maxWidth, FormWidgetState comp) {
    type = type.toLowerCase();
    bool isLink = false;
    try { isLink = (int.tryParse(value ?? "") != null ? false : true) || url != null; } catch(e) { /* */ }
    if (type.contains("text") || type.contains("varchar") || ((type.contains("time") || type.contains("date")) && readOnly)) { 
      return TextWidget(
        form : form, 
        schemaName: schemaName, 
        name: name,
        readOnly: readOnly, 
        value: value, 
        label: label, 
        require: require, 
        type: type, 
        component: comp
      );
    } else if (["int", "double", "float", "money", "decimal"].contains(type)) { 
      return NumberWidget(
        form: form, 
        schemaName: 
        schemaName, 
        name: name,
        readOnly: 
        readOnly, 
        value: value, 
        label: label, 
        require: 
        require, 
        type: type, 
        component: comp
      );
    } else if (type.contains("bool")) {
      if (form[name] != null) { value = form[name]; }
        ValueNotifier<bool> ctrl = ValueNotifier(value ?? false);
        return AdvancedSwitch( width : 200,
          initialValue: value ?? false,
          enabled: !readOnly,
          controller: ctrl,
          activeColor: Colors.green, inactiveColor: Colors.grey,
          activeChild: Text("${label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${require ? '*' : ''}"), 
          inactiveChild: Text("${label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${require ? '*' : ''}"), 
          borderRadius:  const BorderRadius.all(Radius.circular(15)),
          height: 30.0, disabledOpacity: 0.5,
          onChanged: (value) {
            comp.widget.detectChange = true;
            form[name]=value;
            ctrl.value = value;
          }
        );
    } else if (type.contains("time") || type.contains("date")) { 
        return DateWidget(
          form: form, 
          type: type, 
          schemaName: schemaName, 
          require: require, 
          name: name,
          readOnly: readOnly, 
          value: value, 
          label: label, 
          component: comp,);
    } else if ((isLink && (type.contains("int")) || type == "link") || type.contains("enum") ) {
        return DropDownWidget(
          form: form, 
          schemaName: schemaName, 
          name: name, 
          readOnly: readOnly, 
          value: value, 
          label: label, 
          require: require, 
          type: type, 
          url: url, 
          path: path, 
          component: comp);
    } else if (type == "link") {
      return TextWidget(
        form : form, 
        schemaName: schemaName, 
        name: name,
        readOnly: readOnly, 
        value: value, 
        label: label, 
        require: require, 
        type: type, 
        component: comp
      );
    } else if (type.contains("onetomany")) {
        return OneToManyWidget(
          schemaName: schemaName, 
          name: name, 
          readOnly: readOnly, 
          value: value, 
          label: label, 
          require: require, 
          type: type, 
          url: url, 
          component: comp);
    } else if (type.contains("manytomany")) {
      return ManyToManyWidget(
        form: form, 
        schemaName: schemaName, 
        name: name, 
        readOnly: readOnly, 
        value: value, 
        label: label, 
        require: require, 
        type: type, 
        url: url, 
        component: comp);
    }
    return null;
  }
}