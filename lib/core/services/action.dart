import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/services/api_service.dart';

@lazySingleton
class ActionService {
  static void Function() pressed(ActionBarWidget widget, bool isList, String schemaName, String url, 
                                 List<dynamic>? parameters, Map<String,model.SchemaField> schema, String method, BuildContext context) {
      if (!isList && widget.form != null) { return pressedForm(widget, mainForm, schemaName, url, schema, method, context); }
      if (isList && widget.grid != null) { return pressedList(widget, schemaName, url, schema, method, context); }
      return () {};
    }
  static void Function() pressedList(ActionBarWidget widget, String schemaName, String url, 
                                     Map<String,model.SchemaField> schema, String method, BuildContext context) { return () async { }; }
  static void Function() pressedForm(ActionBarWidget widget, GlobalKey<FormWidgetState> form, String schemaName, String url, 
                                Map<String,model.SchemaField> schema, String method, BuildContext context,) { 
      return () async {
        if (mainForm.currentState != null) {
          await pressedFormFuture(mainForm.currentState!.widget, schemaName, url, schema, method, context, {});
        }
      };
  }
  static Future<List<model.View>> pressedFormFuture(DataFormWidget form,  String schemaName, String url, 
                                                    Map<String,model.SchemaField> schema, String method, BuildContext context, Map<String, dynamic> add) async {  
    if (form.formKey.currentState == null || !form.formKey.currentState!.validate()) {  return []; 
    } else { form.formKey.currentState!.save(); }
    var body = <String, dynamic>{};
    List<model.View> views = [];
    var resp = await formSubForms(form.wrappers, {}, method, schemaName, context, true, false);
    if (resp.isNotEmpty) {
      if (resp.first.items.isNotEmpty) { body["dbdest_table_id"]=resp.first.items[0].values["id"]; }
      body["dbschema_id"]=resp.first.schemaID;
    }
    var path = url;
    for (var values in form.cacheForm) {
      if (values["id"] != null) { body["id"]=int.parse(values["id"]); }
      if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var fieldName in schema.keys) {
          if (values[fieldName] == null && method.toUpperCase() == "PUT") { continue; }
          if (!["dbschema_id", "dbdest_table_id"].contains(fieldName) 
          && !(method.toUpperCase() == "PUT" && schema[fieldName]!.readonly)
          && values[fieldName] is! List) { body[fieldName]=values[fieldName]; }
        }
      }
      developer.log('LOG URL ${form.view!.actions.contains(method.toLowerCase())} $path $body', name: 'my.app.category');
      if (form.view!.actions.contains(method.toLowerCase())) {
        // ignore: use_build_context_synchronously
        await APIService().call<model.View>(path, method, body, true, context).then((value) async {
          formSubForms(form.oneToManiesForm, {}, method, schemaName, context, false, false); // ignore: use_build_context_synchronously
          formSubForms(form.existingOneToManiesForm, {}, method, schemaName, context, false, false); // ignore: use_build_context_synchronously
          formSubForms(form.oneToManiesFormDelete, {}, method, schemaName, context, false, true); // ignore: use_build_context_synchronously
          if (value.data != null && value.data!.isNotEmpty) {
            views.add(value.data![0]); 
            values["id"]=value.data![0].items[0].values["id"];
            listSubForms(schema, values, method, schemaName, context);
          } 
          // ignore: invalid_return_type_for_catch_error
        }).catchError( (e) {
          listSubForms(schema, values, method, schemaName, context);
          formSubForms(form.oneToManiesForm, {}, method, schemaName, context, false, false); // ignore: use_build_context_synchronously
          formSubForms(form.existingOneToManiesForm, {}, method, schemaName, context, false, false); // ignore: use_build_context_synchronously
          formSubForms(form.oneToManiesFormDelete, {}, method, schemaName, context, false, true); // ignore: use_build_context_synchronously
          APIResponse<model.View>(data: null);
        });      
      }
      if (form.view!.id == mainForm.currentState!.widget.view!.id) {
        mainForm.currentState!.additionnal = [];
        firstAPI=true;
      }
    }
    return views;
  }
  static listSubForms(Map<String, model.SchemaField> schema, Map<String, dynamic> values, String method, String schemaName, BuildContext context) async {
    for (var fieldName in schema.keys) {
      if (values[fieldName] is List) {
        await APIService().delete("${schema[fieldName]!.actionPath}&${schemaName}_id=${values["id"]}", context).catchError( (e) => APIResponse<model.View>(data: null));
        for (var item in values[fieldName] as List) {
          var newBody = <String, dynamic> {};
          for (var f in schema[fieldName]!.schema.keys) {
            if (f.contains(schemaName) && values["id"] != null) { newBody[f]=values["id"]; 
            } else if (f.contains("_id")) { newBody[f]=item["id"];  }
          } 
          // ignore: use_build_context_synchronously
          await APIService().call<model.View>(schema[fieldName]!.actionPath, method, newBody, true, context).catchError( (e) => APIResponse<model.View>(data: null));
        }
      }
    }
  }
  static Future<List<model.View>> formSubForms(List<DataFormWidget> widgets, Map<String, dynamic> values, String method, 
                                                 String schemaName, BuildContext context, bool add, bool delete) async {
    List<model.View> views = [];
    for (var many in widgets) { 
      if (delete && many.view != null && many.view!.actions.contains("delete") 
      && (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT")) {
        // ignore: use_build_context_synchronously
        await APIService().delete("${many.view!.actionPath}&id=${many.view!.items[0].values["id"]}", context).catchError( (e) => APIResponse<model.View>(data: null));
      } else if (many.view != null && many.view!.actions.contains(method)) {
        // ignore: use_build_context_synchronously
        if (add) { views.addAll(await pressedFormFuture(many, many.view!.schemaName, many.view!.actionPath != "" ? many.view!.actionPath: many.view!.linkPath, 
                                                        many.view!.schema, method, context, values["id"] != null ? { "${schemaName}_id" : values["id"] } : {}));
        } else { await pressedFormFuture(many, many.view!.schemaName, many.view!.actionPath != "" ? many.view!.actionPath: many.view!.linkPath, 
                                         many.view!.schema, method, context, values["id"] != null ? { "${schemaName}_id" : values["id"] } : {});
        } 
      }
    }
    return views;
  }
}
// detect change + debug manyto oneto + loader