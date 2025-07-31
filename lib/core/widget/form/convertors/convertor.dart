import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:sqldbui2/core/widget/form/convertors/manytomany.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/widget/form/convertors/onetomany.dart';
import 'package:sqldbui2/core/widget/form/convertors/dropdown.dart';
import 'package:sqldbui2/core/widget/form/convertors/boolean.dart';
import 'package:sqldbui2/core/widget/form/convertors/number.dart';
import 'package:sqldbui2/core/widget/form/convertors/html.dart';
import 'package:sqldbui2/core/widget/form/convertors/text.dart';
import 'package:sqldbui2/core/widget/form/convertors/date.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/form/convertors/upload.dart';
import 'package:sqldbui2/core/widget/form/widget/subformulary.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';

Map<String, dynamic> cacheChanges = {};
Map<String, GlobalKey<FormFieldState>> detectChanges = {};
abstract class ConvertorWidget {
  abstract dynamic value;
}
class Convertor {
  static Future<Widget> filterFieldByType(
    BuildContext context, 
    ConvertorWidget widget, 
    String type, 
    String name, 
    String label, 
    State<StatefulWidget> state, 
    bool isDark, 
    bool isGrid, 
    String url, 
    String subUrl,
    String id
  ) async {
    if (widget.value == "no info...") { widget.value = null; }
    print("$name $type $subUrl ${widget.value}");
    GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();
    var dec = InputDecoration( 
                errorStyle: const TextStyle(fontSize: 0), 
                isDense: true, 
                suffixStyle: TextStyle(color: Theme.of(context).splashColor),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w300),
                border: const OutlineInputBorder(borderSide: BorderSide(width: 0, style: BorderStyle.none,)),
                hintText: (await getOnFlow('${type.contains("enum") ? "select" : "enter"} ${type.contains("time") || type.contains("date") ? "date" : ""} value...')).toLowerCase());
    bool isText = type.contains("text") || type.contains("varchar") || type.contains("upload") || (type.contains("link") && url == "");
    bool isInt = type.contains("double") || type.contains("float") || type.contains("money") || type.contains("decimal") || type.contains("int");
    Widget w = Container();
    if (type.contains("manytomany")) {
      if ((widget.value ?? "") != "") {
        w = FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get<model.Shallowed>("${(subUrl).replaceAll("rows=all", "rows=${widget.value}")}&shallow=enable", firstAPI, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> s) {
          return FutureBuilder<APIResponse<model.Shallowed>>(
            future: APIService().get(subUrl, true, null), 
            builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
              return FutureBuilder<Widget>(
              future: getLink(subUrl, context, widget, id, dec,  formKey, name, label, 
                type, snap.data?.data?..addAll(s.data?.data ?? []), isGrid, isDark, isText), 
              builder: (BuildContext c, AsyncSnapshot<Widget> q) {
                if (q.data != null) {
                  return q.data!;
                }
                return Container();
              });
            }
          );   
        });
      } else {
        w = FutureBuilder<APIResponse<model.Shallowed>>(
          future: APIService().get(subUrl, true, null), 
          builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
            return FutureBuilder<Widget>(
            future: getLink(subUrl, context, widget, id, dec,  formKey, name, label, 
              type, snap.data?.data, isGrid, isDark, isText), 
            builder: (BuildContext c, AsyncSnapshot<Widget> q) {
              if (q.data != null) {
                return q.data!;
              }
              return Container();
            });
          }
        );
      }
    } else if ((isText || (isInt && url == "")) && !type.contains("enum")) { 
        w = TextFormField( key: formKey,
          textAlign: isGrid ? TextAlign.center : TextAlign.start,
          initialValue: cacheChanges[id]?.toString() ?? widget.value?.toString(),
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Theme.of(context).secondaryHeaderColor , overflow: TextOverflow.ellipsis),
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
            suffixIcon: Icon(isText ? (type.contains("upload") ? Icons.manage_search_outlined : Icons.text_fields)  : (type.contains("money") ? Icons.euro : Icons.onetwothree)), 
            hintText: (await getOnFlow("$label...")).toLowerCase(),  
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
        w = SizedBox( width: 100, child: AdvancedSwitch( key: formKey,
          width: 100, 
          initialValue: def, 
          controller: ctrl,
          activeColor: Colors.green, inactiveColor: isDark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).splashColor,
          activeChild: Text(TranslateConstants.yes.toLowerCase()), inactiveChild: Text(
            TranslateConstants.no.toLowerCase(), 
            style: TextStyle(color: Colors.white)),  
          borderRadius:  const BorderRadius.all(Radius.circular(15)), height: 30.0, disabledOpacity: 0.5,
          onChanged: (value) { 
            widget.value = value == true ? "true" : "false"; 
            if (id != "") {
              detectChanges[id] = formKey;
              cacheChanges[id] = widget.value;
            }
          }));
    } else if (type.contains("time") || type.contains("date")) { 
      var def = cacheChanges[id] ?? widget.value;
      DateTime? d;
      try {
        d = DateTime.parse(def!);
      } catch(e) {
        return Container();
      }
      w = DateTimeField( key: formKey,
        textAlign: isGrid ? TextAlign.center : TextAlign.start,
        initialValue: def == null ? null : d,
        validator: (DateTime? value) {
          if (value == null) { return ""; }
          return null;
        },
        format: intl.DateFormat('y-M-dd'),
        // mode: widget.type == "time" ? DateTimeFieldPickerMode.time : DateTimeFieldPickerMode.date,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Theme.of(context).secondaryHeaderColor ),
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
    } else if (type.contains("enum") ) { // TODO THERE
      var items = <DropdownMenuItem<String>>[];
      for (var item in type.replaceAll("enum__", "").split("_")) { 
        if (name == "state") {
          item = item.toString().replaceAll(" (pending)", "").replaceAll(" (progressing)", "").replaceAll(" (completed)", "").replaceAll(" (dismiss)", "").replaceAll(" (refused)", "");
        }
        if (items.where((element) => element.value == item).isEmpty) {
          items.add(DropdownMenuItem<String>(value: item, alignment: isGrid ? Alignment.center : Alignment.centerLeft, 
            child: Text((await getOnFlow(item)).toLowerCase(), overflow: TextOverflow.ellipsis)));
        }
      }
      w = DropdownButtonFormField<String>( key: formKey, items: items, isExpanded: true,
        alignment: isGrid ? Alignment.center : Alignment.centerLeft,
        value: (cacheChanges[id]?.toString() ?? widget.value?.toString()), elevation: 1,
        validator: (values) { if (values == null) { return TranslateConstants.valuePlaceholder; } return null; },
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300,
         color: isDark ? Colors.white : Theme.of(context).secondaryHeaderColor , overflow: TextOverflow.ellipsis),
        hint: Text(TranslateConstants.placeHolderValue.toLowerCase(), 
              overflow: TextOverflow.ellipsis, softWrap: true, 
              style: TextStyle(fontSize: 13, color: isGrid ? Colors.grey : Theme.of(context).splashColor)),
        onChanged: (value) { 
          widget.value = value; 
          if (id != "") {
            detectChanges[id] = formKey;
            cacheChanges[id] = widget.value;
          }
          if (isGrid) { globalGridWidgetKey.currentState?.setState(() { }); }
        }, 
        dropdownColor: isDark ? Theme.of(context).secondaryHeaderColor : null,
        decoration: isGrid ? dec : InputDecoration( 
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
      print("BAM ${widget.value}");
      if ((widget.value ?? "") != "") {
        w = FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get<model.Shallowed>("${(url).replaceAll("rows=all", "rows=${widget.value}")}&shallow=enable", firstAPI, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> s) {
          print(s.data?.data ?? []);
          return FutureBuilder<APIResponse<model.Shallowed>>(
            future: APIService().get<model.Shallowed>("${(url)}&shallow=enable", firstAPI, null), 
            builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
            if (snap.data?.data != null) {
              return FutureBuilder<APIResponse<model.Shallowed>>(
                future: APIService().get(url, true, null), 
                builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
                  return FutureBuilder<Widget>(
                  future: getLink(url, context, widget, id, dec,  formKey, name, label, 
                  type, (snap.data?.data ?? [])..addAll(s.data?.data ?? []), isGrid, isDark, isText), 
                  builder: (BuildContext c, AsyncSnapshot<Widget> q) {
                    if (q.data != null) {
                      return q.data!;
                    }
                    return Container();
                  });
              });
            } else {
              return Container();
            }
          });   
        });
      } else {
          w = FutureBuilder<APIResponse<model.Shallowed>>(
            future: APIService().get(url, true, null), 
            builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
              return FutureBuilder<Widget>(
              future: getLink(url, context, widget, id, dec,  formKey, name, label, 
                type, snap.data?.data, isGrid, isDark, isText), 
              builder: (BuildContext c, AsyncSnapshot<Widget> q) {
                if (q.data != null) {
                  return q.data!;
                }
                return Container();
              });
            }
          );
      }
    }
    return w;
  }
  static Future<Widget> getLink(String url, BuildContext context, ConvertorWidget widget, String id, 
    InputDecoration? dec, GlobalKey<FormFieldState<dynamic>> formKey, String name,
    String label, String type, List<model.Shallowed>? datas,
    bool isGrid, bool isDark, bool isText) async {
    MultiSelectController<String> ctrls = MultiSelectController<String>();
    List<DropdownItem<String>> items = <DropdownItem<String>>[];
    Map<String, model.Shallowed> mapped = <String, model.Shallowed>{};
    int max = 0;
    if (datas == null || datas.isEmpty) {
      return Container();
    }
    bool found = false;
    for (var item in datas) {
      max = item.max;
      var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
      if (name == "state") {
        v = v.toString().replaceAll(" (pending)", "").replaceAll(" (progressing)", "").replaceAll(" (completed)", "").replaceAll(" (dismiss)", "").replaceAll(" (refused)", "");
      }
      var t = items.where((e) => e.value == "${item.id}"); 
      if (!mapped.containsKey(v) && t.isEmpty){
        mapped[v]=item;
        if(items.where((element) => element.value == v).isEmpty) {
          if ( v.toString() == widget.value.toString() ) { 
            widget.value = item.id.toString();
          }
          bool select = false;
          if ( item.id.toString() == widget.value.toString() ) { 
            found = true;
            select = true; 
          }
          try {
            if (item.translatable) {
              v = (await getOnFlow(v));
              if (v.toUpperCase() == v) {
                v = v.toUpperCase();
              } else {
                v = v.toLowerCase();
              }
            }
          } catch(e) {}
          try {
            items.add(DropdownItem<String>(value: "${item.id}", label: v.trim(), selected: select));
            ctrls.addItem(items.last);
          }catch(e) {}
        }
      }
    }
      if (datas.isEmpty || (widget.value ?? "") != "" && !found) {
      return Container();
    }
    GlobalKey<MultiDropdownState> formFieldKey = GlobalKey();
    var decF = FieldDecoration( 
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w300),
                border: const OutlineInputBorder(borderSide: BorderSide(width: 0, style: BorderStyle.none,)),
                hintText: (await getOnFlow('${type.contains("enum") ? "select" : "enter"} ${type.contains("time") || type.contains("date") ? "date" : ""} value...')).toLowerCase());
    print("THERE $isGrid $datas");
    return MultiDropdown<String>(
        overrideKey: formFieldKey,
        max: max,
        label: label,
        changeFunction: (dynamic value) async {
          if (value == "") {
            return;
          }
          var filters = Filters();
          filters.add("name", Filter(value: value, column: "name", realName: "name"));
          load(url, 0, 10, APIService().getFilter(url, true, filters), value, items, ctrls, mapped, label);
        },
        controller: ctrls,
        singleSelect: true,
        items: items,
        forceVerticalAlignment: isDark,
        textAlignVertical: TextAlignVertical.bottom,
        searchEnabled: max > 10,
        style: TextStyle(color: isDark ?  Colors.white : Theme.of(context).secondaryHeaderColor ),
        chipDecoration: ChipDecoration(
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
        ),
        fieldDecoration: isGrid ? decF : FieldDecoration(
                          errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                          backgroundColor: isDark ? Theme.of(context).secondaryHeaderColor : Colors.white,
                          labelStyle: TextStyle(fontSize: 0),
                          hintText: (await getOnFlow(TranslateConstants.placeHolderValue)).toLowerCase(),
                          hintStyle: TextStyle(fontSize: 13, color: isDark && !isGrid ? Theme.of(context).splashColor : Colors.grey, fontWeight: FontWeight.w300),
                          prefixIcon: Icon(Icons.list, color: isDark ? Theme.of(context).splashColor : Colors.grey),
                          showClearIcon: false,
                          border:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                          focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
        ),
        searchDecoration: SearchFieldDecoration(
                          hintText: (await getOnFlow("       ${TranslateConstants.search}")).toLowerCase(),
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
                              "       ${TranslateConstants.selectValue.toLowerCase()}",
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
                          widget.value = values[0]; 
                          if (id != "") {
                            detectChanges[id] = formFieldKey.currentState?.formFieldKey ?? GlobalKey();
                            cacheChanges[id] = widget.value;
                          }
                        },
        );
  }

  static Future<Widget?> formFieldByType(
    Map<String, dynamic> form, BuildContext context, 
    String schemaName, Map<String, dynamic> schema,
    String type, String name, String label, 
    String description, bool require, bool readOnly, 
    dynamic value, String? mainUrl, String? url, String path, 
    FormWidgetState? comp, bool isEmpty, 
    dynamic autofill, bool translatable,
    GlobalKey<SubFormularyWidgetState>? wrappers,
  ) async {
    type = type.toLowerCase();
    if (type.contains("text") || type.contains("url") || type.contains("varchar") || ((type.contains("time") || type.contains("date")) && readOnly)) { 
      return TextWidget(
        form : form, 
        schemaName: schemaName, 
        name: name,
        readOnly: readOnly, 
        value: value, 
        label: label, 
        require: require, 
        type: type, 
        component: comp,
        autofill: autofill,
        translatable: translatable,
      );
    } else if (type.contains("int") || type.contains("double") || type.contains("float") || type.contains("money") || type.contains("decimal")) { 
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
        component: comp,
        autofill: autofill,
      );
    } else if (type.contains("bool")) {
      if (form[name] != null) { value = form[name]; }
      return BooleanWidget(
        form: form, 
        type: type, 
        schemaName: schemaName, 
        require: require, 
        name: name,
        readOnly: readOnly, 
        value: value, 
        label: label, 
        component: comp,
        autofill: autofill,
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
          component: comp,
          autofill: autofill,
        );
    } else if ( type.contains("link") || type.contains("enum") ) {
        return DropDownWidget(
          mainUrl: mainUrl,
          form: form, 
          schema: schema,
          schemaName: schemaName, 
          name: name, 
          readOnly: readOnly, 
          value: value, 
          label: label, 
          require: require, 
          type: type, 
          url: url, 
          path: path, 
          component: comp,
          empty: isEmpty,
          autofill: autofill,
          translatable: translatable,
          wrappers: wrappers,
        );
    } else if (type == "html") {
      return HTMLWidget(
        form : form, 
        translatable: false,
        schemaName: schemaName, 
        name: name,
        readOnly: readOnly, 
        value: value, 
        label: label, 
        require: require, 
        type: type, 
        component: comp,
        autofill: autofill,
      );
    } else if (type.contains("upload")) {
      return UploadWidget(
        form : form, 
        url: url,
        schemaName: schemaName, 
        name: name,
        readOnly: readOnly, 
        value: value, 
        label: label, 
        require: require, 
        type: type, 
        component: comp,
        autofill: autofill,
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
          translatable: translatable,
          component: comp);
    } else if (type.contains("manytomany")) {
      return ManyToManyWidget(
        mainURL: mainUrl,
        form: form, 
        schema: schema,
        schemaName: schemaName, 
        name: name, 
        translatable: translatable,
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
  static Future<void> load(String url, int start, int interval, String filter, 
  String value, List<DropdownItem<String>> items, MultiSelectController<String> ctrls, 
  Map<String, model.Shallowed> mapped, String label) async {
    if (filter == "") { return; }
    var found = false;
      var e = await APIService().get<model.Shallowed>("$url$filter&offset=$start&limit=$interval", filter != "", null);
        if (e.data != null) {
          for (var item in e.data!) {
            if (items.where( (e) => e.value == "${item.id}").isEmpty) {
              found = true;
              var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
              try {
                if (item.translatable) {
                  v = await getOnFlow(v);
                }
              } catch(e) {}
              mapped["${item.id}"]=item;
              items.add(DropdownItem<String>(value: "${item.id}", label: v, selected: false));
              ctrls.addItem(items.last);
            }
          }
    } 
    if (ctrls.isOpen && found) {
      ctrls.closeDropdown();
      ctrls.openDropdown(value, label);
    }
  }
}

