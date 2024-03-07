import 'dart:developer' as developer;
import 'package:alert_banner/exports.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/dialog/alert.dart';
import 'package:sqldbui2/core/services/api_service.dart';

List<String> errors = <String>[];
@lazySingleton
class ActionService {
  static void Function() pressed(ActionBarWidget widget, bool isList, String schemaName, String url, 
                                 List<dynamic>? parameters, Map<String,model.SchemaField> schema, String method, BuildContext context) {
      errors = [];
      if (!isList && widget.form != null) { return pressedForm(widget, mainForm, schemaName, url, schema, method, context); }
      if (isList && widget.grid != null) { return pressedList(widget, schemaName, url, schema, method, context); }
      return () {};
    }
  static void Function() pressedList(ActionBarWidget widget, String schemaName, String url, 
                                     Map<String,model.SchemaField> schema, String method, BuildContext context) { return () async { }; }
  static void Function() pressedForm(ActionBarWidget widget, GlobalKey<FormWidgetState> form, String schemaName, String url, 
                                Map<String,model.SchemaField> schema, String method, BuildContext context,) { 
      return () async {
        globalActionBar.currentState!.loading(method);
        if (mainForm.currentState != null) {
          await pressedFormFuture(mainForm.currentState!.widget, schemaName, url, schema, method, context, {});
        }
        globalActionBar.currentState!.loaded(method);
      };
  }
  static Future<List<model.View>> pressedFormFuture(DataFormWidget form,  String schemaName, String url, 
                                                    Map<String,model.SchemaField> schema, String method, 
                                                    BuildContext context, Map<String, dynamic> add) async {  
    if (form.formKey.currentState == null || !form.formKey.currentState!.validate()) {  return []; 
    } else { form.formKey.currentState!.save(); }
    var body = <String, dynamic>{};
    List<model.View> views = [];
    var resp = await formSubForms(form.wrappers, {}, method, schemaName, context, true, false);
    if (resp.isNotEmpty) {
      if (resp.first.items.isNotEmpty) { body["dbdest_table_id"]=resp.first.items[0].values["id"]; }
      body["dbschema_id"]=resp.first.schemaID;
    }
    if (errors.isNotEmpty) {
      var errorStr = "";
        for (var error in errors) { errorStr += "${error.replaceAll("Exception: ", "")} \n"; }
        if (errorStr != "") {
          // ignore: use_build_context_synchronously
          showAlertBanner(context, () {}, AlertAlertBannerChild(text: errorStr), // <-- Put any widget here you want!
                          alertBannerLocation:  AlertBannerLocation.top,);
        }
      return views;
    }
    if (form.existingOneToManiesForm.where((element) => element.detectChange).isNotEmpty) {
        form.detectChange = true;
        // ignore: use_build_context_synchronously
        formSubForms(form.existingOneToManiesForm, form.cacheForm, method, schemaName, context, false, false);
    }
    if (!form.detectChange && form.wrappers.where((element) => element.detectChange).isEmpty) {
      if (form.view!.id == mainForm.currentState!.widget.view!.id) {
        // ignore: use_build_context_synchronously
        showAlertBanner(context, () {}, const InfoAlertBannerChild(text: "Nothing has change :)"), // <-- Put any widget here you want!
                      alertBannerLocation:  AlertBannerLocation.bottom,);
      }
      return views; 
    }
    var path = url;
      if (form.cacheForm["id"] != null) { body["id"]=int.parse(form.cacheForm["id"]); }
      if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var fieldName in schema.keys) {
          if (form.cacheForm[fieldName] == null && method.toUpperCase() == "PUT") { continue; }
          if (!["dbschema_id", "dbdest_table_id"].contains(fieldName) 
          && !(method.toUpperCase() == "PUT" && schema[fieldName]!.readonly)
          && form.cacheForm[fieldName] is! List) { body[fieldName]=form.cacheForm[fieldName]; }
        }
        for (var k in add.keys) { body[k] = add[k]; }
      }
      if (form.view!.actions.contains(method.toLowerCase())) {
        // ignore: use_build_context_synchronously
        await APIService().call<model.View>(path, method, body, true, null).then((value) async {
          if (value.data != null && value.data!.isNotEmpty) {
            views.add(value.data![0]); 
            form.cacheForm["id"]=value.data![0].items[0].values["id"];
            listSubForms(schema, form.cacheForm, method, schemaName, context);
          } 
          formSubForms(form.oneToManiesForm, form.cacheForm, method, schemaName, context, false, false); // ignore: use_build_context_synchronously
          formSubForms(form.existingOneToManiesForm, form.cacheForm, method, schemaName, context, false, false); // ignore: use_build_context_synchronously
          formSubForms(form.oneToManiesFormDelete, form.cacheForm, method, schemaName, context, false, true); // ignore: use_build_context_synchronously
          if (form.view!.id == mainForm.currentState!.widget.view!.id) {
            showAlertBanner(context, () {}, 
              InfoAlertBannerChild(text: "${schemaName.replaceAll("_", " ").replaceAll("db", "")} ${method == "post" ? "create" : (method == "put" ? "save" : method)} datas suceed :)"), // <-- Put any widget here you want!
                                   alertBannerLocation:  AlertBannerLocation.bottom,);
          }
          // ignore: invalid_return_type_for_catch_error
        }).catchError( (e) {
          errors.add("${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}");
          listSubForms(schema, form.cacheForm, method, schemaName, context);
          formSubForms(form.oneToManiesForm, {}, method, schemaName, context, false, false); // ignore: use_build_context_synchronously
          formSubForms(form.existingOneToManiesForm, {}, method, schemaName, context, false, false); // ignore: use_build_context_synchronously
          formSubForms(form.oneToManiesFormDelete, {}, method, schemaName, context, false, true); // ignore: use_build_context_synchronously
          APIResponse<model.View>(data: null);
        });      
      }
      
      if (form.view!.id == mainForm.currentState!.widget.view!.id) { APIService.cache = {}; }
      Future.delayed(const Duration(seconds: 1), () {
        for (var state in form.oneToManiesStateForm.values) { state.setState(() { 
          form.oneToManiesForm = [];
        }); }
        form.oneToManiesStateForm = {};
    });
    if (form.view!.id == mainForm.currentState!.widget.view!.id) {
        var errorStr = "";
        for (var error in errors) { errorStr += "- ${error.replaceAll("Exception: ", "")} \n"; }
        if (errorStr != "") {
          // ignore: use_build_context_synchronously
          showAlertBanner(context, () {}, AlertAlertBannerChild(text: errorStr), // <-- Put any widget here you want!
                          alertBannerLocation:  AlertBannerLocation.top,);
        }
        if (form.view != null && form.view!.isEmpty && errorStr == "") { globalActionBar.currentState!.refresh(); }
    }
    return views;
  }
  static listSubForms(Map<String, model.SchemaField> schema, Map<String, dynamic> values, String method, String schemaName, BuildContext context) async {
    for (var fieldName in schema.keys) {
      if (values[fieldName] is List) {
        await APIService().delete<model.View>("${schema[fieldName]!.actionPath}&${schemaName}_id=${values["id"]}", null
                                 ).catchError( (e) { errors.add("${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}"); return APIResponse<model.View>(data: null); });
        for (var item in values[fieldName] as List) {
          var newBody = <String, dynamic> {};
          for (var f in schema[fieldName]!.schema.keys) {
            if (f.contains(schemaName) && values["id"] != null) { newBody[f]=values["id"]; 
            } else if (f.contains("_id")) { newBody[f]=item["id"];  }
          } 
          // ignore: use_build_context_synchronously
          await APIService().call<model.View>(schema[fieldName]!.actionPath, method, newBody, true, null
                                             ).catchError( (e) { errors.add("${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}"); return APIResponse<model.View>(data: null); });
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
        await APIService().delete<model.View>(many.view!.actionPath.replaceAll("rows=all", "rows=${many.view!.items[0].values["id"]}"), null
                                 ).catchError( (e) { errors.add("${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}"); return APIResponse<model.View>(data: null); });
      } else if (many.view != null && many.view!.actions.contains(method)) {
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
// debug oneto + loader main