import 'package:alert_banner/exports.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/services/trigger_cache.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/form/convertors/consent.dart';
import 'package:sqldbui2/core/widget/form/convertors/dropdown.dart';
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
import 'package:sqldbui2/core/widget/form/widget/error_formulary.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/page/translate.dart';

List<String> errors = [];
@lazySingleton
class ActionService {
  static void Function() pressed(ButtonWidgetState? widget, bool isList, String schemaName, String url, 
                                 List<dynamic>? parameters, Map<String,model.SchemaField> schema, 
                                 String method, bool isDraft, BuildContext context, Map<String,dynamic> overrideMap, bool overrideDest, bool explicitDraft, bool avoidConsent) {
      errors = [];
      return pressedForm(widget, mainForm, schemaName, url, schema, method, context, isDraft, overrideDest, overrideMap, explicitDraft, avoidConsent);
    }
  static void Function() pressedList(ButtonWidget widget, String schemaName, String url, 
                                     Map<String,model.SchemaField> schema, String method, BuildContext context) { return () async {}; }
  static void Function() pressedForm(ButtonWidgetState? widget, GlobalKey<FormWidgetState> form, String schemaName, String url, 
                                Map<String,model.SchemaField> schema, String method, BuildContext context, bool isDraft, bool overrideDest, 
                                Map<String,dynamic> overrideMap, bool explicitDraft, bool avoidConsent) { 
      return () async {
        widget?.loading();
        if (mainForm.currentState != null) {
          await pressedFormFuture(mainForm.currentState!.widget, schemaName, url, schema, method, context, overrideMap, isDraft, overrideDest, explicitDraft, avoidConsent);
        }
        widget?.loaded();
        
        if ((widget == null || (!isDraft && !(currentView?.isEmpty ?? true))) && errors.isEmpty) { 
          Future.delayed(Duration(seconds: 1), () {
            globalMainViewKey.currentState!.refreshUrl("$baseURL${APIConstants.genericEndpost}$schemaName?rows=$subViewID", subViewID, true); 
          });
        }
      };
  }
  static bool redirection = false;
  static Future<List<model.View>> pressedFormFuture(DataFormWidget form, String schemaName, String url, 
                                                    Map<String,model.SchemaField> schema, String method, 
                                                    BuildContext context, Map<String, dynamic> add, 
                                                    bool isDraft, bool overrideDest, bool explicitDraft, bool avoidConsent) async {  
    var body = <String, dynamic>{};
    var resp = await formSubForms(form.wrappers, {}, method, schemaName, context, true, false, isDraft, overrideDest, explicitDraft, avoidConsent);
    if (resp.isNotEmpty  && !overrideDest) {
      if (resp.first.items.isNotEmpty) { 
        body["dbdest_table_id"]=resp.first.items[0].values["id"]; 
      }
      body["dbschema_id"]=resp.first.schemaID;
    }
    if (method != "delete" && errors.isEmpty) {
      if (form.formKey.currentState == null || !form.formKey.currentState!.validate()) { 
        if (form.formKey.currentState != null && form.subForm) {
          errorFormKey.currentState?.widget.error = TranslateConstants.errorRequire;
          errorFormKey.currentState?.setState((){});
          errors = ["form is not valid !"]; 
        }
        return []; 
      } else { form.formKey.currentState!.save(); }
    } 
    if (consentCache[viewID]?[form.key] != null && !avoidConsent) {
      for (var consent in consentCache[viewID]![form.key]!.values) {
        if (!consent.consent && !consent.optionnal) {
          consentErrCache[viewID ?? ""]?[consent.name] = true;
          errors = ["we need your consent"]; 
          consent.key?.currentState?.setState(() {
            consent.key?.currentState?.error = true;
          });
        }
      } 
    }
    List<model.View> views = [];
    if (errors.isNotEmpty) {
      var errorStr = "";
        for (var error in errors) { errorStr += "${error.replaceAll("Exception: ", "")} \n"; }
        if (errorStr != "") {
          // ignore: use_build_context_synchronously
          showAlertBanner(context, durationOfStayingOnScreen: Duration(minutes: 1), 
          () {}, AlertAlertBannerChild(text: errorStr), alertBannerLocation:  AlertBannerLocation.top,);
        }
      return views;
    }
    
    if (errors.isNotEmpty) {
      var errorStr = "";
        for (var error in errors) { errorStr += "${error.replaceAll("Exception: ", "")} \n"; }
        if (errorStr != "") {
          // ignore: use_build_context_synchronously
          showAlertBanner(context, durationOfStayingOnScreen: Duration(minutes: 1), () {}, AlertAlertBannerChild(text: errorStr), alertBannerLocation:  AlertBannerLocation.top,);
        }
      return views;
    }
    for (var v in form.oneToManiesForm.values) {
      for (var vv in v) {
        if (vv.detectChange) {
          form.detectChange = true; 
          break;
        }
      }
    }
    if (isDraft && form.view!.id == mainForm.currentState!.widget.view!.id) {
      mainForm.currentState?.setState(() { firstAPI = true; });
      return views;
    }

    var path = url;
    if (form.cacheForm["id"] != null) { 
      body["id"]=int.parse(form.cacheForm["id"]); 
      if (method.toUpperCase() == "DELETE" || method.toUpperCase() == "PUT") { path = path.replaceAll("rows=all", "rows=${body["id"]}"); }
    } else if (method.toUpperCase() == "PUT") { method = "post"; }
    body = await getBody(method, { ...form.cacheForm}, body, schema, form.oneToManiesForm, context);
    var files = await getFiles(method, { ...form.cacheForm}, schema, context);
    if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var k in add.keys) { body[k] = add[k]; }
        if (globalWorkflowPanelWidgetKey.currentState != null && form.view!.id == mainForm.currentState!.widget.view!.id) {
            List<String> nexts = [];
            for (var hub in (globalWorkflowPanelWidgetKey.currentState?.hubs.keys ?? [] as List<String>)) {
              if (globalWorkflowPanelWidgetKey.currentState!.hubs[hub]!.value) { nexts.add(hub); }
            }
            body["nexts"]=nexts.join(",");
        }
      }
      if (explicitDraft) {
        body["is_draft"]=isDraft;
      }
      if (form.view!.actions.contains(method.toLowerCase())) {    
        // ignore: use_build_context_synchronously
        print(body);
        await APIService().call<model.View>(path, method, body, true, null).then((value) async {
          if(value.data != null && value.data!.isNotEmpty) {
            views.add(value.data!.first);
            bool killConsent = false;
            if ((consentCache[viewID]?[form.key]?.length ?? 0) > 0) {
              for (var consent in consentCache[viewID]![form.key]!.values) {
                if (consent.body == null || consent.body!["dbschema_id"] != value.data!.first.schemaID) {
                  continue;
                }
                killConsent = true;
                if (value.data!.first.items.isNotEmpty) { 
                  consent.body!["dbdest_table_id"]=value.data!.first.items[0].values["id"]; 
                }
                consent.body!["dbschema_id"]=value.data!.first.schemaID;
                consent.body!["is_consenting"]=consent.consent;
                await APIService().post(consent.actionPath!, consent.body!, context);
              } 
            }
            if (killConsent) {
              consentCache.remove(viewID);
            }
             
            onSuccessMethod(method, views.last, { ...form.cacheForm}, views.last.schema, files, context);
            if (views.last.items.isNotEmpty) {
              if (form.view!.isEmpty) { 
                isNew = value.data![0].items[0].values["id"]; 
              }
            }
            (form.key as GlobalKey<FormWidgetState>).currentState?.setState((){});
            if (views.last.innerRedirection != "") { 
              redirection = true;
              Future.delayed(Duration(seconds: 3), () {
                  var splitted = views.last.innerRedirection.split("?rows=");
                  if (splitted.length >= 2) {
                    if (method == "delete") {
                      viewID = "#${splitted[1].split("/").last}";
                      subViewID = null;
                    } else {
                      viewID = "@${splitted[0].split("/").last}";
                      subViewID = splitted[1];
                    }
                    
                    globalActionBar.currentState?.setState(() {});
                    globalMainViewKey.currentState?.refreshUrl("$baseURL${views.last.innerRedirection}", subViewID, true); 
                  }
              });
            } else if (!form.subForm) {
              if (!redirection) {
                Future.delayed(Duration(seconds: 3), () {
                  globalMainViewKey.currentState?.setState(() { firstAPI = true; });
                  globalMenuKey.currentState?.setState(() { navigate = true; });
                  showAlertBanner(context, durationOfStayingOnScreen: Duration(seconds: 5), () {}, 
                        InfoAlertBannerChild(text: "${method == "post" ? "create" : ( method == "put" ? TranslateConstants.filterSave.toUpperCase() : method)} data suceed"), // <-- Put any widget here you want!
                                            alertBannerLocation:  AlertBannerLocation.bottom);
                });
              }
              redirection = false;
            } 
          }
          // ignore: invalid_return_type_for_catch_error
        }).catchError( (e) {
          errors = [ "${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}" ];
          APIResponse<model.View>(data: null);
        });                
      }
    if (form.view!.id == mainForm.currentState!.widget.view!.id) {
        var errorStr = "";
        for (var error in errors) { errorStr += "- ${error.replaceAll("Exception: ", "")} \n"; }
        if (errorStr != "") {
          // ignore: use_build_context_synchronously
          showAlertBanner(context, durationOfStayingOnScreen: Duration(minutes: 1), () {}, AlertAlertBannerChild(text: errorStr), // <-- Put any widget here you want!
                          alertBannerLocation:  AlertBannerLocation.top,);
        }
        if (form.view != null && form.view!.isEmpty && errorStr == "") { globalMenuKey.currentState?.refresh(true); }
    }
    return views;
  }
  static onSuccessMethod(String method, model.View view, Map<String, dynamic> values, 
    Map<String, model.SchemaField> schema, Map<String, PlatformFile> files, BuildContext context) async {
    if (view.items.isNotEmpty) {            
      values["id"]=view.items.first.values["id"];
    }
    if ((method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") && (values["id"] ?? "") != "") {
      for (var pathFile in files.keys) {
        await submitFile(pathFile.replaceAll("rows=all", "rows=${values["id"]}"), files[pathFile]!, context);
      }
    }
    TriggerCacheService.setTriggers(view.triggers); 
  }

  static Future<Map<String, PlatformFile>> getFiles(String method, Map<String, dynamic> values, 
    Map<String, model.SchemaField> schema, BuildContext context) async {
    var files = <String, PlatformFile>{};       
    if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var fieldName in schema.keys) {
          if (values[fieldName] == null && method.toUpperCase() == "PUT") { continue; }
          if (schema[fieldName] != null && schema[fieldName]!.type.toLowerCase().contains("many")) { continue; }
          
          if (!["dbdest_table_id"].contains(fieldName) 
          && !(["dbschema_id"].contains(fieldName) && values[fieldName] == null)
          && !(method.toUpperCase() == "PUT" && schema[fieldName]!.readonly)
          && values[fieldName] is! List) { 
            if (values[fieldName] is Map<String, List<PlatformFile>>) {
              for (var fileStr in (values[fieldName] as Map<String, List<PlatformFile>>).keys) {
                for (var file in values[fieldName][fileStr] as List<PlatformFile>) {
                  files[fileStr] = file;
                }
              }
            }
          }
      }
    }
    return files;
  }
  static Future<Map<String, dynamic>> getBody(String method, Map<String, dynamic> values, Map<String, dynamic> body, 
    Map<String, model.SchemaField> schema, Map<String, List<DataFormWidget>> oneToManies, BuildContext context) async {
    if (newDropDownValue.isNotEmpty && (method == "post" || method == "put")) {
      for(var url in newDropDownValue.keys) {
          for (var name in newDropDownValue[url]!.keys) {
            if (values[name]?.contains(newDropDownValue[url]![name]) ?? true) {
              continue;
            }
            var resp = await APIService().post<model.Shallowed>("$url&shallow=enable", {
              "name" : newDropDownValue[url]![name],
            // ignore: invalid_return_type_for_catch_error
            }, context);
            if ( resp.data?.isNotEmpty ?? false) {
              body[name] = resp.data?.first.id;
            }
          }
      }
      searchCtrl = {};
      newDropDownValue = {};
    }
    if (values["id"] != null) { 
      body["id"]=int.parse(values["id"]); 
    }
    if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var fieldName in schema.keys) {
          if (values[fieldName] == null && method.toUpperCase() == "PUT") { continue; }          
          if (!["dbdest_table_id"].contains(fieldName) && !(["dbschema_id"].contains(fieldName) && values[fieldName] == null)
          && !(method.toUpperCase() == "PUT" && schema[fieldName]!.readonly)) { 
            if (values[fieldName] is Map<String, List<PlatformFile>>){
              for (var fileStr in (values[fieldName] as Map<String, List<PlatformFile>>).keys) {
                for (var file in values[fieldName][fileStr] as List<PlatformFile>) {
                  if ( body[fieldName] == null) {
                     body[fieldName] = file.name;
                  } else {
                    body[fieldName] += ",${file.name}";
                  }
                }
              }
            } else if ( (oneToManies[fieldName] ?? []).isNotEmpty) {
              body[fieldName] = (oneToManies[fieldName]?.map( (e) {
                return e.cacheForm;
            }) ?? []).toList();
            } else {
              body[fieldName]=values[fieldName]; 
            }
          }
        }
    }
    return body;
  }
  static Future<List<model.View>> formSubForms(List<DataFormWidget> widgets, Map<String, dynamic> values, String method, 
                                                 String schemaName, BuildContext context, bool add, bool delete, bool isDraft, bool overrideDest, bool explicitDraft, bool avoidConsent) async {
    List<model.View> views = [];
    for (var many in widgets) { 
      if (delete && many.view != null && many.view!.actions.contains("delete") && (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT")) {
        await APIService().delete<model.View>(many.view!.actionPath.replaceAll("rows=all", "rows=${many.view!.items[0].values["id"]}"), null
                                 );
      } else if (many.view != null && many.view!.actions.contains(method)) {
        if (add) { 
          views.addAll(await pressedFormFuture(many, many.view!.schemaName, many.view!.actionPath != "" ? many.view!.actionPath: many.view!.linkPath, 
                                                        many.view!.schema, method, 
                                                        context, values["id"] != null ? { "${schemaName}_id" : values["id"] } : {}, isDraft, overrideDest, explicitDraft, avoidConsent));
        } else { 
          await pressedFormFuture(many, many.view!.schemaName, many.view!.actionPath != "" ? many.view!.actionPath: many.view!.linkPath, 
                                  many.view!.schema, method, context, values["id"] != null ? { "${schemaName}_id" : values["id"] } : {}, isDraft, overrideDest, explicitDraft, avoidConsent);
        } 
      }
    }
    return views;
  }

  static Future<void> submitFile(String path, PlatformFile file, BuildContext context) async {
    await APIService().sendFile(path, file.path ?? "", file.name, file.bytes, context);
  }
}
// debug oneto + loader main