import 'package:alert_banner/exports.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/trigger_cache.dart';
import 'package:sqldbui2/core/widget/form/convertors/consent.dart';
import 'package:sqldbui2/core/widget/form/convertors/dropdown.dart';
import 'package:sqldbui2/core/widget/form/convertors/manytomany.dart';
import 'package:sqldbui2/core/widget/utils/button.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:sqldbui2/core/widget/workflow/workflowPanel.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/dialog/alert.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/page/translate.dart';

List<String> errors = <String>[];
@lazySingleton
class ActionService {
  static void Function() pressed(ButtonWidgetState? widget, bool isList, String schemaName, String url, 
                                 List<dynamic>? parameters, Map<String,model.SchemaField> schema, 
                                 String method, bool isDraft, BuildContext context) {
      errors = [];
      return pressedForm(widget, mainForm, schemaName, url, schema, method, context, isDraft);
    }
  static void Function() pressedList(ButtonWidget widget, String schemaName, String url, 
                                     Map<String,model.SchemaField> schema, String method, BuildContext context) { return () async {}; }
  static void Function() pressedForm(ButtonWidgetState? widget, GlobalKey<FormWidgetState> form, String schemaName, String url, 
                                Map<String,model.SchemaField> schema, String method, BuildContext context, bool isDraft) { 
      return () async {
        widget?.loading();
        if (mainForm.currentState != null) {
          await pressedFormFuture(mainForm.currentState!.widget, schemaName, url, schema, method, context, {}, isDraft);
        }
        widget?.loaded();
        
        if (widget == null) { 
          globalMainViewKey.currentState!.refreshUrl("$baseURL${APIConstants.genericEndpost}$schemaName?rows=$subViewID", subViewID, true); 
        }
      };
  }
  static Future<List<model.View>> pressedFormFuture(DataFormWidget form,  String schemaName, String url, 
                                                    Map<String,model.SchemaField> schema, String method, 
                                                    BuildContext context, Map<String, dynamic> add, bool isDraft) async {  

    if (consentCache[viewID] != null) {
      for (var consent in consentCache[viewID]!.values) {
        if (!consent.consent && !consent.optionnal) {
          consentErrCache[viewID ?? ""]?[consent.name] = true;
          errors = ["should consent !"]; 
          consent.key?.currentState?.setState(() {});
        }
      } 
    }
    if (method != "delete" && errors.isEmpty) {
      if (form.formKey.currentState == null || !form.formKey.currentState!.validate()) { 
        if (form.formKey.currentState != null && form.subForm) {
          mainForm.currentState?.widget.error = TranslateConstants.errorRequire;
          mainForm.currentState?.setState((){});
          errors = ["form is not valid !"]; 
        }
        return []; 
      } else { form.formKey.currentState!.save(); }
    }  
    var files = <String, PlatformFile>{};       
    var body = <String, dynamic>{};
    List<model.View> views = [];
    var resp = await formSubForms(form.wrappers, {}, method, schemaName, context, true, false, isDraft);
    if (resp.isNotEmpty) {
      if (resp.first.items.isNotEmpty) { body["dbdest_table_id"]=resp.first.items[0].values["id"]; }
      body["dbschema_id"]=resp.first.schemaID;
    }
    if (newManyToManyValue.isNotEmpty && (method == "post" || method == "put")) {
      for(var url in newManyToManyValue.keys) {
          for (var name in newManyToManyValue[url]!.keys) {
            var resp = await APIService().post<model.Shallowed>("$url&shallow=enable", {
              "name" : newManyToManyValue[url]![name],
            // ignore: invalid_return_type_for_catch_error
            }, context).catchError( (e) => errors.add(e.toString()));
            if ( resp.data?.isNotEmpty ?? false) {
              body[name] = resp.data?.first.id;
            }
          }
      }
      searchCtrl = {};
      newDropDownValue = {};
    }
    if (newDropDownValue.isNotEmpty && (method == "post" || method == "put")) {
      for(var url in newDropDownValue.keys) {
          for (var name in newDropDownValue[url]!.keys) {
            var resp = await APIService().post<model.Shallowed>("$url&shallow=enable", {
              "name" : newDropDownValue[url]![name],
            // ignore: invalid_return_type_for_catch_error
            }, context).catchError( (e) => errors.add(e.toString()));
            if ( resp.data?.isNotEmpty ?? false) {
              body[name] = resp.data?.first.id;
            }
          }
      }
      searchCtrl = {};
      newDropDownValue = {};
    }
    if (errors.isNotEmpty) {
      var errorStr = "";
        for (var error in errors) { errorStr += "${error.replaceAll("Exception: ", "")} \n"; }
        if (errorStr != "") {
          // ignore: use_build_context_synchronously
          showAlertBanner(context, () {}, AlertAlertBannerChild(text: errorStr), alertBannerLocation:  AlertBannerLocation.top,);
        }
      return views;
    }

    if (form.oneToManiesForm.where((element) => element.detectChange).isNotEmpty) { form.detectChange = true; }
    if (form.existingOneToManiesForm.where((element) => element.detectChange).isNotEmpty) {
        form.detectChange = true;
        // ignore: use_build_context_synchronously
        formSubForms(form.existingOneToManiesForm, form.cacheForm, method, schemaName, context, false, false, isDraft);
    }
    if (method != "delete" && !form.detectChange && form.wrappers.where((element) => element.detectChange).isEmpty
    && (globalWorkflowPanelWidgetKey.currentState == null || !globalWorkflowPanelWidgetKey.currentState!.change)) { return views; }
    
    
    var path = url;
     if (form.cacheForm["id"] != null) { 
      body["id"]=int.parse(form.cacheForm["id"]); 
      if (method.toUpperCase() == "DELETE") { path = path.replaceAll("rows=all", "rows=${body["id"]}"); }
    } else if (method.toUpperCase() == "PUT") { method = "post"; }
    if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var fieldName in schema.keys) {
          if (form.cacheForm[fieldName] == null && method.toUpperCase() == "PUT") { continue; }
          if (schema[fieldName] != null && schema[fieldName]!.type.toLowerCase().contains("many")) { continue; }
          
          if (!["dbdest_table_id"].contains(fieldName) 
          && !(["dbschema_id"].contains(fieldName) && form.cacheForm[fieldName] == null)
          && !(method.toUpperCase() == "PUT" && schema[fieldName]!.readonly)
          && form.cacheForm[fieldName] is! List) { 
            if (form.cacheForm[fieldName] is Map<String, List<PlatformFile>>) {
              for (var fileStr in (form.cacheForm[fieldName] as Map<String, List<PlatformFile>>).keys) {
                for (var file in form.cacheForm[fieldName][fileStr] as List<PlatformFile>) {
                  files[fileStr] = file;
                  if ( body[fieldName] == null) {
                     body[fieldName] = file.name;
                  } else {
                    body[fieldName] += ",${file.name}";
                  }
                }
              }
            } else {
              body[fieldName]=form.cacheForm[fieldName]; 
            }
          }
        }
        for (var k in add.keys) { body[k] = add[k]; }
        if (globalWorkflowPanelWidgetKey.currentState != null && form.view!.id == mainForm.currentState!.widget.view!.id) {
            List<String> nexts = [];
            for (var hub in (globalWorkflowPanelWidgetKey.currentState?.hubs.keys ?? [] as List<String>)) {
              if (globalWorkflowPanelWidgetKey.currentState!.hubs[hub]!.value) { nexts.add(hub); }
            }
            body["nexts"]=nexts.join(",");
        }
      }
      body["is_draft"]=isDraft;
      if (form.view!.actions.contains(method.toLowerCase())) {
        if (!isDraft && (consentCache[viewID]?.length ?? 0) > 0) {
          for (var consent in consentCache[viewID]!.values) {
            if (consent.body == null) {
              continue;
            }
            consent.body!["is_consenting"]=consent.consent;
            await APIService().post(consent.actionPath!, consent.body!, context);
          } 
        }
        consentCache.remove(viewID);
        // ignore: use_build_context_synchronously
        await APIService().call<model.View>(path, method, body, true, null).then((value) async {
          if (value.data != null && value.data!.isNotEmpty) {            
            views.add(value.data![0]); 
            form.cacheForm["id"]=value.data![0].items[0].values["id"];
            listSubForms(schema, form.cacheForm, method, value.data![0].schemaName, context, false);
          } 
          if (form.view!.isEmpty) { isNew = value.data![0].items[0].values["id"]; }
          if (form.view!.id == mainForm.currentState!.widget.view!.id) {
            showAlertBanner(context, () {}, 
              InfoAlertBannerChild(text: "${schemaName.replaceAll("_", " ").replaceAll("db", "")} ${method == "post" ? "create" : (
                method == "put" ? TranslateConstants.filterSave.toUpperCase() : await getOnFlow(method))} datas suceed :)"), // <-- Put any widget here you want!
                                   alertBannerLocation:  AlertBannerLocation.bottom,);
          }
          if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
            TriggerCacheService.setTriggers(value.data![0].triggers);
            for (var pathFile in files.keys) {
              await submitFile(pathFile, files[pathFile]!, context);
            }
          }
          // ignore: invalid_return_type_for_catch_error
        }).catchError( (e) {
          errors.add("${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}");
          listSubForms(schema, form.cacheForm, method, schemaName, context, true);
          APIResponse<model.View>(data: null);
        });      
        formSubForms(form.oneToManiesForm, body, method, schemaName, context, false, false, isDraft); // ignore: use_build_context_synchronously
        formSubForms(form.existingOneToManiesForm, body, method, schemaName, context, false, false, isDraft); // ignore: use_build_context_synchronously
        formSubForms(form.oneToManiesFormDelete, body, method, schemaName, context, false, true, isDraft); // ignore: use_build_context_synchronously
      }
      Future.delayed(const Duration(seconds: 1), () {
        for (var state in form.oneToManiesStateForm.values) { state.setState(() { form.oneToManiesForm = []; }); }
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
        if (form.view != null && form.view!.isEmpty && errorStr == "") { globalMenuKey.currentState?.refresh(true); }
    }
    return views;
  }
  static listSubForms(Map<String, model.SchemaField> schema, Map<String, dynamic> values, String method, String schemaName, BuildContext context, bool warn) async {
    for (var fieldName in schema.keys) {
      if (values[fieldName] is List) {
        if(values["id"] != null) {
          await APIService().delete<model.View>("${schema[fieldName]!.actionPath}&${schemaName}_id=${values["id"]}", null
            ).catchError( (e) { errors.add("${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}"); return APIResponse<model.View>(data: null); });
        }
        for (var item in values[fieldName] as List) {
          var newBody = <String, dynamic> {};
          for (var f in schema[fieldName]!.schema.keys) {
            if (f.contains(schemaName) && values["id"] != null) { newBody[f]=values["id"]; 
            } else if (f.contains("_id")) { newBody[f]=item["id"];  }
          } 
          // ignore: use_build_context_synchronously
          await APIService().post<model.View>(schema[fieldName]!.actionPath, newBody, null
                                             ).catchError( (e) { errors.add("${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}"); return APIResponse<model.View>(data: null); });
        }
      }
    }
  }
  static Future<List<model.View>> formSubForms(List<DataFormWidget> widgets, Map<String, dynamic> values, String method, 
                                                 String schemaName, BuildContext context, bool add, bool delete, bool isDraft) async {
    List<model.View> views = [];
    for (var many in widgets) { 
      if (delete && many.view != null && many.view!.actions.contains("delete") && (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT")) {
        await APIService().delete<model.View>(many.view!.actionPath.replaceAll("rows=all", "rows=${many.view!.items[0].values["id"]}"), null
                                 ).catchError( (e) { errors.add("${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}"); return APIResponse<model.View>(data: null); });
      } else if (many.view != null && many.view!.actions.contains(method)) {
        if (add) { views.addAll(await pressedFormFuture(many, many.view!.schemaName, many.view!.actionPath != "" ? many.view!.actionPath: many.view!.linkPath, 
                                                        many.view!.schema, method, 
                                                        context, values["id"] != null ? { "${schemaName}_id" : values["id"] } : {}, isDraft));
        } else { 
          await pressedFormFuture(many, many.view!.schemaName, many.view!.actionPath != "" ? many.view!.actionPath: many.view!.linkPath, 
                                  many.view!.schema, method, context, values["id"] != null ? { "${schemaName}_id" : values["id"] } : {}, isDraft);
        } 
      }
    }
    return views;
  }

  static Future<void> submitFile(String path, PlatformFile file, BuildContext context) async {
    await APIService().sendPlatformFile(path, file, context);
  }
}
// debug oneto + loader main