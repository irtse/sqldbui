import 'package:flutter/material.dart';
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
  String description, bool require, bool readOnly, dynamic value, String? url, FormWidgetState comp) {
    type = type.toLowerCase();
    if (type.contains("text") || type.contains("varchar") 
    || ((type.contains("time") || type.contains("date")) && readOnly)) { 
        return TextWidget(form : form, schemaName: schemaName, name: name,readOnly: readOnly, value: value, label: label, require: require, type: type, component: comp,);
      } else if ((type.contains("int") && url == null) || type.contains("double") || type.contains("float") || type.contains("money")) { 
        return NumberWidget(form : form, schemaName: schemaName, name: name,readOnly: readOnly, value: value, label: label, require: require, type: type, component: comp,);
      } else if (type.contains("bool")) {
    if (form[name] != null) { value = form[name]; }
        return CheckboxListTileFormField(
                    enabled: !readOnly,
                    initialValue: value ?? false,
                    title: Text("${label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${require ? '*' : ''}", style: const TextStyle(fontSize: 10)),
                    validator: (bool? value) { return null; },
                    onSaved: (value) {form[name]=value;},
                    onChanged: (value) {
                      comp.widget.detectChange = true;
                      form[name]=value;
                    },
                  );
    } else if (type.contains("time") || type.contains("date")) { 
        return DateWidget(form : form, type: type, schemaName: schemaName, name: name,readOnly: readOnly, value: value, label: label, component: comp,);
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