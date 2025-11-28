import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';

import 'package:alert_banner/exports.dart';
import 'package:injectable/injectable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/utils/button.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/services/trigger_cache.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/workflow/workflowPanel.dart';
import 'package:sqldbui2/core/widget/form/convertors/consent.dart';


import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/widget/dialog/alert.dart';
import 'package:sqldbui2/core/widget/form/widget/error_formulary.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/page/translate.dart';

List<String> errors = [];
@lazySingleton
class ActionService {
  static void Function() pressed(ButtonWidgetState? widget, bool isList, String schemaName, String url, 
                                 List<dynamic>? parameters, Map<String,model.SchemaField> schema, 
                                 String method, bool isDraft, BuildContext context, Map<String,dynamic> overrideMap, 
                                 bool overrideDest, bool explicitDraft, bool avoidConsent, bool ignore, bool noRedirection) {
      redirection = null;
      errors = [];

      return pressedForm(widget, mainForm, schemaName, url, schema, method, context, isDraft, overrideDest, overrideMap, explicitDraft, avoidConsent, ignore, noRedirection);
  }
  static void Function() pressedList(ButtonWidget widget, String schemaName, String url, 
                                     Map<String,model.SchemaField> schema, String method, BuildContext context) { return () async {}; }
  static void Function() pressedForm(ButtonWidgetState? widget, GlobalKey<FormWidgetState> form, String schemaName, String url, 
                                Map<String,model.SchemaField> schema, String method, BuildContext context, bool isDraft, bool overrideDest, 
                                Map<String,dynamic> overrideMap, bool explicitDraft, bool avoidConsent, bool ignore, bool noRedirection) { 
      return () async {
        widget?.loading();
        if (mainForm.currentState != null ) {
          var v = await pressedFormFuture(mainForm.currentState!.widget, schemaName, url, schema, method, context, overrideMap, isDraft, overrideDest, explicitDraft, avoidConsent, ignore);
          if ((redirection ?? "") != "" && !noRedirection)  { 
              var splitted = redirection?.split("?rows=");
              if ((splitted?.length ?? 0) >= 2) {
                if (method == "delete") {
                  viewID = "#${splitted![1]}";
                  subViewID = null;
                  confirmCache = {};
                  navigate = true;   
                  Future.delayed(Duration(seconds: 1), () {
                    Future.delayed(Duration(seconds: 1), () { globalActionBar.currentState?.setState(() {}); });
                    AppRouter.navigateTo("$viewID");
                    // globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true); 
                  });
                } else if (splitted != null) {
                  viewID = "@${splitted[0].split("/").last}";
                  subViewID = splitted[1];
                  navigate = true;  
                  confirmCache = {}; 
                  Future.delayed(Duration(seconds: 2), () {
                    Future.delayed(Duration(seconds: 1), () { globalActionBar.currentState?.setState(() {}); });
                    AppRouter.navigateTo("$viewID:$subViewID");
                    //globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true); 
                  });
                }
              }
            }   
            if (v.isNotEmpty) {
              showAlertBanner(context, durationOfStayingOnScreen: Duration(seconds: 5), () {}, 
                          InfoAlertBannerChild(text: " success"), alertBannerLocation:  AlertBannerLocation.bottom);
            } 
        }
        widget?.loaded();
      };
  }
  static String? redirection;
  static Future<List<model.View>> pressedFormFuture(DataFormWidget form, String schemaName, String url, 
                                                    Map<String,model.SchemaField> schema, String method, 
                                                    BuildContext context, Map<String, dynamic> add, 
                                                    bool isDraft, bool overrideDest, bool explicitDraft, bool avoidConsent, bool ignore) async {  
    var body = <String, dynamic>{};
    var resp = await formSubForms(form.wrappers, {}, method, schemaName, context, true, false, isDraft, overrideDest, explicitDraft, avoidConsent, ignore);
    if (resp.isNotEmpty  && !overrideDest) {
      if (resp.first.items.isNotEmpty) { 
        body["dbdest_table_id"]=resp.first.items[0].values["id"]; 
      }
      body["dbschema_id"]=resp.first.schemaID;
    }
  
    for (var v in (oneToManiesForm[form.view?.name] ?? {}).entries) {
      for (var vv in v.value) {
        if (!(vv.formKey.currentState?.validate() ?? true)) {
          errorFormKey[form.formKey]?.currentState?.widget.error = await getOnFlow(TranslateConstants.errorRequire);
          errorFormKey[form.formKey]?.currentState?.setState((){});
          errors = ["form is not valid !"]; 
          break;
        }
      }
    }
    for (var v in schema.keys) {
      if (((schema[v]?.type.toLowerCase().contains("onetomany") ?? false) 
      && (schema[v]?.require ?? false) && (oneToManiesForm[form.view?.name]?[v] ?? []).isEmpty) && !avoidConsent) {
        errorFormKey[form.formKey]?.currentState?.widget.error = await getOnFlow(TranslateConstants.errorRequire);
        errorFormKey[form.formKey]?.currentState?.setState((){});
        errors = ["form is not valid !"]; 
        for ( var o in oneToManiesStateForm[form.view?.name] ?? [] ) {
          Future.delayed(Duration(seconds: 1), () { 
            o.setState((){});
          });
        }
        break;
      }
    }
    if (method != "delete" && errors.isEmpty && !ignore) {
      if ((form.formKey.currentState == null || !(form.formKey.currentState?.validate() ?? true)) && !avoidConsent) { 
        if (form.formKey.currentState != null && form.subForm) {
          errorFormKey[form.formKey]?.currentState?.widget.error = await getOnFlow(TranslateConstants.errorRequire);
          errorFormKey[form.formKey]?.currentState?.setState((){});
          errors = ["form is not valid !"]; 
        }
      } else { form.formKey.currentState?.save(); }
    } 
    if (consentCache[viewID]?[form.view?.name] != null && !avoidConsent) {
      for (var consent in (consentCache[viewID]?[form.view?.name]?.values.toList() ?? [])) {
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

    if (isDraft && ((form.view?.schemaName.contains("request") ?? false ) || (form.view?.schemaName.contains("task") ?? false))) {
      return views;
    }

    var path = url;
    if (cacheForm[form.view?.name]?["id"] != null) { 
      body["id"]=int.parse(cacheForm[form.view?.name]?["id"]); 
      if (method.toUpperCase() == "DELETE" || method.toUpperCase() == "PUT") { path = path.replaceAll("rows=all", "rows=${body["id"]}"); }
    } else if (method.toUpperCase() == "PUT") { method = "post"; }
    body = await getBody(method, { ...(cacheForm[form.view?.name] ?? {})}, body, schema, oneToManiesForm[form.view?.name] ?? {}, context);
    var files = await getFiles(method, { ...(cacheForm[form.view?.name] ?? {})}, schema, context);
    if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var k in add.keys) { body[k] = add[k]; }
        if (globalWorkflowPanelWidgetKey.currentState != null && form.view?.id == mainForm.currentState?.widget.view?.id) {
            List<String> nexts = [];
            for (var hub in (globalWorkflowPanelWidgetKey.currentState?.hubs.keys ?? [] as List<String>)) {
              if (globalWorkflowPanelWidgetKey.currentState?.hubs[hub]?.value ?? false) { nexts.add(hub); }
            }
            body["nexts"]=nexts.join(",");
        }
      }
      if (explicitDraft) {
        body["is_draft"]=isDraft;
      }
      if ((body.isNotEmpty || !["put", "post"].contains(method))) {
        // ignore: use_build_context_synchronously
        if ((method.toUpperCase() == "POST" || method.toUpperCase() == "PUT")) {
          for (var pathFile in files.keys) {
            await submitFile(pathFile, files[pathFile]!, context);
          }
        }
        await APIService().call<model.View>(path, method, body, true, null).then((value) async {
          if(value.data != null && (value.data ?? []).isNotEmpty) {
            views.add(value.data!.first);
            bool killConsent = false;
            if ((consentCache[viewID]?[form.view?.name]?.length ?? 0) > 0 && !avoidConsent) {
              for (var consent in (consentCache[viewID]![form.view?.name]?.values.toList() ?? [])) {
                if (consent.body == null || consent.body!["dbschema_id"] != value.data?.first.schemaID) {
                  continue;
                }
                killConsent = true;
                if (value.data!.first.items.isNotEmpty) { 
                  consent.body!["dbdest_table_id"]=value.data?.first.items[0].values["id"]; 
                }
                consent.body!["dbschema_id"]=value.data?.first.schemaID;
                consent.body!["is_consenting"]=consent.consent;
                await APIService().post(consent.actionPath!, consent.body!, context);
              } 
            }
            if (killConsent) {
              consentCache.remove(viewID);
            }
             
            onSuccessMethod(method, views.last, { ...(cacheForm[form.view?.name] ?? {})}, views.last.schema, context);
            if (views.last.items.isNotEmpty) {
              if (form.view?.isEmpty ?? false) { 
                isNew = value.data![0].items[0].values["id"]; 
              }
            }

            if (views.last.innerRedirection != "" && ((redirection ?? "") == "")) {
              redirection = views.last.innerRedirection;
            }
          }
          // ignore: invalid_return_type_for_catch_error
        }).catchError( (e) {
          errors = [ "${schemaName.replaceAll("_", " ").replaceAll("db", "")} : ${e.toString()}" ];
          APIResponse<model.View>(data: null);
        });
                       
      }
    if (form.view?.id == mainForm.currentState?.widget.view?.id) {
        var errorStr = "";
        for (var error in errors) { errorStr += "- ${error.replaceAll("Exception: ", "")} \n"; }
        if (errorStr != "") {
          // ignore: use_build_context_synchronously
          showAlertBanner(context, durationOfStayingOnScreen: Duration(minutes: 1), () {}, AlertAlertBannerChild(text: errorStr), // <-- Put any widget here you want!
                          alertBannerLocation:  AlertBannerLocation.top,);
        }
        // if (form.view != null && (form.view?.isEmpty ?? false) && errorStr == "") { globalMenuKey.currentState?.refresh(true); }
    }
    return views;
  }
  static onSuccessMethod(String method, model.View view, Map<String, dynamic> values, 
    Map<String, model.SchemaField> schema, BuildContext context) async {
    if (view.items.isNotEmpty) {            
      values["id"]=view.items.first.values["id"];
    }

    if ((method.toUpperCase() == "POST" || (method.toUpperCase() == "PUT")) && view.triggers.isNotEmpty) {
      TriggerCacheService.setTriggers(view.triggers);
    }
  }

  static Future<Map<String, PlatformFile>> getFiles(String method, Map<String, dynamic> values, 
    Map<String, model.SchemaField> schema, BuildContext context) async {
    var files = <String, PlatformFile>{};       
    if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var fieldName in schema.keys) {
          if (values[fieldName] == null && method.toUpperCase() == "PUT") { continue; }
          if (schema[fieldName] != null && (schema[fieldName]?.type.toLowerCase().contains("many") ?? false)) { continue; }
          
          if (!["dbdest_table_id"].contains(fieldName) 
          && !(["dbschema_id"].contains(fieldName) && values[fieldName] == null)
          && !(method.toUpperCase() == "PUT" && (schema[fieldName]?.readonly ?? false))
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
    if (values["id"] != null) { 
      body["id"]=int.parse(values["id"]); 
    }
    if (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT") {
        for (var fieldName in schema.keys) {
          if (values[fieldName] == null && oneToManies[fieldName] == null && method.toUpperCase() == "PUT") { continue; }      
          if (!["dbdest_table_id"].contains(fieldName) && !(["dbschema_id"].contains(fieldName) && values[fieldName] == null)
          && !(method.toUpperCase() == "PUT" && (schema[fieldName]?.readonly ?? false))) { 
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
            } else if (oneToManies[fieldName] != null) {
              body[fieldName] = [];
              for (var o in (oneToManies[fieldName] ?? []).toList()) {
                var b = await getBody(method, (cacheForm[o.view?.name] ?? {}), {}, schema[fieldName]!.schema, oneToManiesForm[o.view?.name] ?? {}, context);
                body[fieldName].add(b);
              }
            } else {
              if (values[fieldName] is List) {
                body[fieldName]= [];
                for (var v in values[fieldName]) {
                  if (v is model.Shallowed) {
                    body[fieldName].add(v.serialize());
                  } else {
                    body[fieldName].add(v);
                  }
                } 
              } else {
                body[fieldName]=values[fieldName]; 
              }
            }
          }
        }
    }
    return body;
  }
  static Future<List<model.View>> formSubForms(List<DataFormWidget> widgets, Map<String, dynamic> values, String method, 
                                                 String schemaName, BuildContext context, bool add, bool delete, bool isDraft, bool overrideDest, bool explicitDraft, bool avoidConsent, bool ignore) async {
    List<model.View> views = [];
    for (var many in widgets) { 
      if (delete && many.view != null && (many.view?.actions.contains("delete") ?? false) && (method.toUpperCase() == "POST" || method.toUpperCase() == "PUT")) {
        await APIService().delete<model.View>(many.view!.actionPath.replaceAll("rows=all", "rows=${many.view?.items[0].values["id"]}"), null
                                 );
      } else if (many.view != null) {
        if (add) { 
          views.addAll(await pressedFormFuture(many, many.view!.schemaName, (many.view?.actionPath ?? "") != "" ? many.view!.actionPath: many.view!.linkPath, 
                                                        many.view!.schema, method, 
                                                        context, values["id"] != null ? { "${schemaName}_id" : values["id"] } : {}, isDraft, overrideDest, explicitDraft, avoidConsent, ignore));
        } else { 
          await pressedFormFuture(many, many.view!.schemaName, (many.view?.actionPath ?? "") != "" ? many.view!.actionPath: many.view!.linkPath, 
                                  many.view!.schema, method, context, values["id"] != null ? { "${schemaName}_id" : values["id"] } : {}, isDraft, overrideDest, explicitDraft, avoidConsent, ignore);
        } 
      }
    }
    return views;
  }

  
}
// debug oneto + loader main
Future<void> submitFile(String path, PlatformFile file, BuildContext context) async {
  await APIService().sendFile(path, file.path ?? "", file.name, file.bytes, context);
}