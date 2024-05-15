import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/widget/convertors/date.dart';
import 'package:sqldbui2/core/widget/convertors/dropdown.dart';
import 'package:sqldbui2/core/widget/convertors/manytomany.dart';
import 'package:sqldbui2/core/widget/convertors/number.dart';
import 'package:sqldbui2/core/widget/convertors/onetomany.dart';
import 'package:sqldbui2/core/widget/convertors/text.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'dart:developer' as developer;

import 'package:sqldbui2/core/widget/form.dart';
class Convertor {
  static Widget? formFieldByType(Map<String, dynamic> form, BuildContext context, String schemaName, String type, String name, String label, 
  String description, bool require, bool readOnly, dynamic value, String? url, double maxWidth, FormWidgetState comp) {
    type = type.toLowerCase();
    if (type.contains("text") || type.contains("varchar") 
    || ((type.contains("time") || type.contains("date")) && readOnly)) { 
        return TextWidget(form : form, schemaName: schemaName, name: name,readOnly: readOnly, value: value, label: label, require: require, type: type, component: comp,);
      } else if ((type.contains("int") && url == null) || type.contains("double") || type.contains("float") || type.contains("money") || type.contains("decimal")) { 
        return NumberWidget(form : form, schemaName: schemaName, name: name,readOnly: readOnly, value: value, label: label, require: require, type: type, component: comp,);
      } else if (type.contains("bool")) {
    if (form[name] != null) { value = form[name]; }
        ValueNotifier<bool> ctrl = ValueNotifier(value ?? false);
        return AdvancedSwitch(
                    initialValue: value ?? false,
                    enabled: !readOnly,
                    controller: ctrl,
                    activeColor: Colors.green, inactiveColor: Colors.grey,
                    activeChild: Text("${label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${require ? '*' : ''}"), 
                    inactiveChild: Text("${label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${require ? '*' : ''}"), 
                    borderRadius:  const BorderRadius.all(Radius.circular(15)),
                    width: 200, height: 30.0, disabledOpacity: 0.5,
                    onChanged: (value) {
                      comp.widget.detectChange = true;
                      form[name]=value;
                      ctrl.value = value;
                    },);
    } else if (type.contains("time") || type.contains("date")) { 
        return DateWidget(form : form, type: type, schemaName: schemaName, require: require, name: name,readOnly: readOnly, value: value, label: label, component: comp,);
    } else if ((url != null && type.contains("int")) || type.contains("enum") ) {
        return DropDownWidget(form: form, schemaName: schemaName, name: name, readOnly: readOnly, value: value, label: label, require: require, 
                    type: type, url: url, component: comp);
    } else if (type.contains("onetomany")) {
        return OneToManyWidget(schemaName: schemaName, name: name, readOnly: readOnly, value: value, label: label, require: require, 
                               type: type, url: url, component: comp);
    } else if (type.contains("manytomany")) {
      return ManyToManyWidget(form: form, schemaName: schemaName, name: name, readOnly: readOnly, value: value, label: label, require: require, 
                               type: type, url: url, component: comp);
    }
    return null;
  }
}