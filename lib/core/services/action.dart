import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/services/api_service.dart';

@lazySingleton
class ActionService {
    static void Function() pressed(ActionBarWidget widget, bool isList, String schemaName, String url, 
                            List<dynamic>? parameters, Map<String,model.SchemaField> schema, String method, BuildContext context) {
      if (!isList && widget.form != null) {
        return pressedForm(widget, mainForm, cacheForm, schemaName, url, schema, method, context);
      }
      if (isList && widget.grid != null) {
        return pressedList(widget, cacheForm, schemaName, url, parameters, schema, method, context);
      }
      return () {};
    }
    static void Function() pressedList(ActionBarWidget widget, Map<String, List<Map<String, dynamic>>> cache, String schemaName, String url, 
                                List<dynamic>? parameters, Map<String,model.SchemaField> schema, String method, BuildContext context) {
      return () async {
        var body = <String, dynamic>{};
        var path = url;
        if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
          var list = widget.grid!.dataGridController.selectedRows;
          for (var l in list) {
            for (var cell in l.getCells()) { body[cell.columnName]=cell.value; }
          }
        }
        await APIService().call<model.View>(path, method, body, true, context).then((value) {
          globalMenuKey.currentState!.setState(() {});
        });
      };
    }
  static void Function() pressedForm(ActionBarWidget widget, GlobalKey<FormWidgetState> form, Map<String, List<Map<String, dynamic>>> cache, String schemaName, String url, 
                                Map<String,model.SchemaField> schema, String method, BuildContext context,) { 
      return () async { // todo a sub future
        if (mainForm.currentState != null) {
          await pressedFormFuture(mainForm.currentState!.widget, cache, schemaName, url, schema, method, context, true);
        }
      };
  }
  static Future<List<model.View>> pressedFormFuture(DataFormWidget form, Map<String, List<Map<String, dynamic>>> cache, String schemaName, String url, 
                                Map<String,model.SchemaField> schema, String method, BuildContext context, bool once) async {  
    var body = <String, dynamic>{};
    List<model.View> views = [];
    if (form.formKey.currentState == null || !form.formKey.currentState!.validate()) {  return []; }
    for (var wrapper in form.wrappers) { 
      if (wrapper.view != null) {
        var resp = await pressedFormFuture(wrapper, cache, wrapper.view!.schemaName, 
                                           wrapper.view!.actionPath != "" ? wrapper.view!.actionPath: wrapper.view!.linkPath, 
                                           wrapper.view!.schema, method, context, true);
        if (resp.isNotEmpty) {
          if (resp.first.items.isNotEmpty) { body["dbdest_table_id"]=resp.first.items[0].values["id"]; }
          body["dbschema_id"]=resp.first.schemaID;
        }
      }
    }
    form.formKey.currentState!.save();
    var path = url;
    if (!cache.containsKey(schemaName)) { return []; }
    var valuesScheme =cache[schemaName]!;    
    for (var values in valuesScheme) {
      if (once) {
        for (var k in form.oneToManiesForm.keys) { 
          for (var many in form.oneToManiesForm[k] as List) {
            if (many.view != null && many.view!.actions.contains("post") && values["id"] != null) {
              if (cache.containsKey(many.view!.schemaName)) {
                for (var scheme in cache[many.view!.schemaName]!) { scheme["${k}_id"] = values["id"]; }
              }
              developer.log('LOG URL ${cache[many.view!.schemaName]}', name: 'my.app.category');
              // ignore: use_build_context_synchronously
              await pressedFormFuture(many, cache, many.view!.schemaName, 
                                      many.view!.actionPath != "" ? many.view!.actionPath: many.view!.linkPath, 
                                      many.view!.schema, "post", context, false);
            }
          }
        }
        for (var k in form.existingOneToManiesForm.keys) { 
          for (var many in form.existingOneToManiesForm[k] as List) {
            if (many.view != null && many.view!.actions.contains("put") && values["id"] != null) {
              // ignore: use_build_context_synchronously
              await pressedFormFuture(many, cache, many.view!.schemaName, 
                                      many.view!.actionPath != "" ? many.view!.actionPath: many.view!.linkPath, 
                                      many.view!.schema, "put", context, false);
            }
          }
        }
      }
      for (var manies in form.oneToManiesFormDelete.values) { 
        for (var many in manies) {
          if (many.view != null && many.view!.actions.contains("delete") && (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT")) {
            // ignore: use_build_context_synchronously
            await APIService().delete("${many.view!.actionPath}&id=${many.view!.items[0].values["id"]}", context).catchError( (e) => APIResponse<model.View>(data: null));
          }
        }
      }
      if (values["id"] != null && method.toUpperCase() == "PUT") { body["id"]=int.parse(values["id"]); } 
      if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var fieldName in schema.keys) {
          if (fieldName == "id" && values[fieldName] != null && method.toUpperCase() == "PUT") { body[fieldName]=int.parse(values[fieldName]); } 
          if (schema[fieldName]!.require && values[fieldName] == null && once) {
            throw Exception("$fieldName field is required !");
          }
          if (values[fieldName] == null && method.toUpperCase() == "PUT") { continue; }
          if (!(fieldName == "dbschema_id" && body["dbschema_id"] != null) && !(fieldName == "dbdest_table_id" && body["dbdest_table_id"] != null)
          && !(method.toUpperCase() == "PUT" && schema[fieldName]!.readonly)) {
            if (values[fieldName] is! List) { body[fieldName]=values[fieldName]; }
          }
        }
      }
      var found = false;
      developer.log('LOG URL ${form.view!.actions.contains(method.toLowerCase())} $path $body', name: 'my.app.category');
      if (form.view!.actions.contains(method.toLowerCase())) {
        // ignore: use_build_context_synchronously
        await APIService().call<model.View>(path, method, body, true, context).then((value) async {
          if (value.data != null && value.data!.isNotEmpty) {
            found = true;
            views.add(value.data![0]); 
            for (var fieldName in schema.keys) {
              if (!(fieldName == "dbschema_id") && !(fieldName == "dbdest_table_id")
              && !(method.toUpperCase() == "PUT" && schema[fieldName]!.readonly) && values[fieldName] is List) {
                await APIService().delete("${schema[fieldName]!.actionPath}&${schemaName}_id=${views.last.items[0].values["id"]}", context
                                        ).catchError( (e) => APIResponse<model.View>(data: null));
                for (var item in values[fieldName] as List) {
                  var s = schema[fieldName]!.schema;
                  var newBody = <String, dynamic> {};
                  for (var f in s.keys) {
                    if (f.contains(schemaName)) { newBody[f]=views.last.items[0].values["id"]; 
                    } else if (f.contains("_id")) { newBody[f]=item["id"];  }
                  } 
                  // ignore: use_build_context_synchronously
                  await APIService().call<model.View>(schema[fieldName]!.actionPath, method, newBody, true, context
                                                      ).catchError( (e) => APIResponse<model.View>(data: null));
                }
              }
            }
          } 
        // ignore: invalid_return_type_for_catch_error
        }).catchError( (e) => APIResponse<model.View>(data: null) );      
      }
      if (found) { 
        if (form.view!.id == mainForm.currentState!.widget.view!.id) {
          mainForm.currentState!.additionnal = [];
          APIService.cache = <String, APIResponse<dynamic>>{};
          cache.remove(schemaName); firstAPI=true; 
          if (method.toUpperCase() == "POST") { globalViewKey.currentState!.setState(() { }); }
        }
      }
    }
    return views;
  }
}