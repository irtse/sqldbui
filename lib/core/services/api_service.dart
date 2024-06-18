
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:alert_banner/exports.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/abstract.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/alert.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/services/html.dart' if (kIsWeb) 'dart:html' as http;

var firstAPI = false;
var baseURL = '${const String.fromEnvironment('HOST', defaultValue: 'http://localhost:8080')}/v1';
class APIConstants {
  static String mainEndpost = '/main';
  static String genericEndpost = '/generic/';
}

@lazySingleton
class APIService {
  static Map<String, APIResponse<dynamic>> cache = <String, APIResponse<dynamic>>{};
  static String auth = "";
  static final dio = Dio(
    BaseOptions(
      baseUrl: baseURL, // you can keep this blank
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    ),
  )..interceptors.add(LogInterceptor( requestHeader: true, ),);

  static final APIService _instance = APIService._internal();
  factory APIService() { return _instance; }
  APIService._internal() { /* logic*/}

  Future<APIResponse<T>> call<T extends SerializerDeserializer>(
    String url, String method, Map<String, dynamic>? body, bool force, BuildContext? context) async {
    switch (method.toLowerCase()) {
      case 'get' : return await get(url, force, context);
      case 'post' : return await post(url, body!, context);
      case 'put' : return await put(url, body!, context);
      case 'delete' : return await delete(url, context);
      default : return await get(url, force, context);
    }
  }

  Future<Response> request<T extends SerializerDeserializer>(String url, String method, dynamic body, Options? options) async {
    switch (method.toLowerCase()) {
      case 'get' : return await dio.get(url, options: options);
      case 'post' : return await dio.post(url, data:body, options: options);
      case 'put' : return await dio.put(url, data:body!, options: options);
      case 'delete' : return await dio.delete(url, options: options);
      default : return await dio.get(url, options: options);
    }
  }
  static ValueNotifier downloadProgressNotifier = ValueNotifier(0);
  Future mainDownload(String url, String method, bool isFilter, String? extend, String savePath, bool isWeb, BuildContext context) async {
    try {
      downloadProgressNotifier.value = 0;
      dio.options.headers["authorization"] = auth;
      var orderBy = getOrderDir(url);
      var filter = getFilter(url, isFilter);
      if (isWeb) { 
        dio.get("$url${extend ?? ""}$orderBy$filter").then((value) {
          var url = http.Url.createObjectUrlFromBlob(http.Blob([value.data]));
          http.AnchorElement(href: url)..setAttribute('download', savePath.split("/").last)..click();
          downloadProgressNotifier.value = 100;
          Future.delayed(const Duration(seconds: 1), () { Navigator.of(context).pop(); });
        });
      } else {
        dio.download("$url${extend ?? ""}$orderBy$filter", savePath, onReceiveProgress: (actualBytes, int totalBytes) {
          Future.delayed(const Duration(seconds: 1), () {
            downloadProgressNotifier.value = (actualBytes / totalBytes * 100).floor();
            if (downloadProgressNotifier.value == 100) { Navigator.of(context).pop(); }
          });   
        });
      }
      
    } catch (e, s) { developer.log('LOG ERRDOWNLOAD $e $s', name: 'my.app.category'); }
  }

  String getOrderDir(String url) {
    var orderBy = "";
    var dir = "";
    if (url.contains("?")) {
      if (globalOrder.containsKey(viewID)) {
        var f = ""; var d = "";
        for (var order in globalOrder[viewID]!.keys) {
          if (orderBy.isEmpty) { 
            orderBy += "&orderby="; 
            f = order;
          } else { f = "$f,$order";  }
          if (dir.isEmpty) { 
            dir += "&dir="; 
            d = globalOrder[viewID]![order]!;
           } else { d = "$d,${globalOrder[viewID]![order]}";  }
        }
        orderBy += f;
        dir += d;
      }
    }
    return orderBy + dir;
  }

  String getColumns(String url, bool isFilter) {
    if (!isFilter) { return ""; }
    var columns = "";
    if (url.contains("?") && filterOrderView.containsKey(viewID)) {
      columns += "&columns=";
      for (var column in filterOrderView[viewID] ?? []) { columns += "$column,"; }
      columns = columns.substring(0, columns.length - 1);
    }
    return columns;
  }

  String getFilter(String url, bool isFilter) {
    var filter = "";
    if (url.contains("?") && isFilter) {
      if (globalFilter.containsKey(viewID) && globalFilter[viewID]!.sort().isNotEmpty) {
        filter = "&filter_line=";
        for (var f in globalFilter[viewID]!.sort()) {  
          if (f.column == "") { continue; } 
          if (f.comparator == "=") { filter += "${f.column}%3A${f.value}"; 
          } else if (f.comparator == "!=") { filter += "${f.column}%3C%3E${f.value}"; 
          } else if (f.comparator == "like") { filter += "${f.column}~%25${f.value}%25"; 
          } else if (f.comparator == "not like") { filter += "${f.column}%3C%3E~%25${f.value}%25"; 
          } else if (f.comparator == "<=") { filter += "${f.column}%3C%3A${f.value}";
          } else if (f.comparator == ">=") { filter += "${f.column}%3E%3A${f.value}";
          } else { filter += "${f.column}${f.comparator == "<" ? "%3C" : "%3E"}${f.value}"; }
          filter += f.connector == "and" ? "+" : ( f.connector == "or" ? "|" : "");
        }
      }
      if (globalNew[viewID] != null && globalNew[viewID] != "all") { filter += "&filter_new=${globalNew[viewID]}"; }
    }
    return filter;
  }

  Future<APIResponse<T>> main<T extends SerializerDeserializer>(String url, dynamic body, 
                                                                String method, String succeed, bool force, 
                                                                BuildContext? context, int? limit, int? offset, 
                                                                bool isFilter, String? extend, Options? options) async {
    var err = ""; 
    if (url != "") {
      if ((!force || noReload) && cache.containsKey(url) && cache[url] != null ) { 
        return cache[url]! as APIResponse<T>;
      }
      try {
        dio.options.headers["authorization"] = auth;
        dio.interceptors.clear(); 
        var orderBy = getOrderDir(url);
        var filter = getFilter(url, isFilter);
        var cols = getColumns(url, offset != null);
        if (currentView != null && offset != null && currentView!.max < offset) { globalOffset = offset = 0;  }
        var response = await request("$url$cols${extend ?? ""}${limit != null ? "&limit=$limit" : ""}${offset != null ? "&offset=$offset" : ""}$orderBy$filter", method, body, options);
        if (response.statusCode != null && response.statusCode! < 400) {
          if (method == "delete") { cache.remove(url); return APIResponse<T>(); }
          APIResponse<T> resp = APIResponse<T>().deserialize(response.data as Map<String, dynamic>); 
          if (resp.error == "") { 
            if (method == "get") { 
              if (limit != null && cache.containsKey(url) && offset != null && offset > 0) { 
                  cache[url]!.data!.addAll(resp.data!);
                  cache[url]!.offset = offset; 
                  return cache[url]! as APIResponse<T>;
              } else { cache[url]=resp; } 
            }
            if (context != null && succeed != "") {
              // ignore: use_build_context_synchronously
              showAlertBanner(context, () {}, InfoAlertBannerChild(text: succeed), // <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,);
            }
            if (method == "get") {  return cache[url] as APIResponse<T>;  }
            return resp; 
          }
          err = resp.error ?? "internal error";
        } 
        if (response.statusCode == 401) { err = "not authorized"; }
      } catch(e, s) {  
        print(e); print(s);
        developer.log('LOG ERR $e $s ${const String.fromEnvironment('HOST', defaultValue: 'http://localhost:8080')}', name: 'my.app.category');
        err = "${e.toString()} ${const String.fromEnvironment('HOST', defaultValue: 'http://localhost:8080')}"; }
    } else { err = "no url"; }
    if (err.contains("token") && err.contains("expired")) {  AuthService().unAuthenticate();  }
    if (context != null && err != "no url") {
      // ignore: use_build_context_synchronously
      showAlertBanner( context, () {}, AlertAlertBannerChild(text: err),// <-- Put any widget here you want!
                       alertBannerLocation:  AlertBannerLocation.bottom,);
    } 
    throw Exception(err);
  }

  Future<APIResponse<T>> sendFile<T extends SerializerDeserializer>(String url, File file, BuildContext context) async {
    FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename:file.path.split("/").last),
    });
    // ignore: use_build_context_synchronously
    return main(url, formData, "post", "send succeed", true, context, null, null, false, 
            null, Options(contentType: 'multipart/form-data'));
  }

  Future getWithDownload<T extends SerializerDeserializer>(String url, String format, Map<String,dynamic> cache, String savePath, bool isWeb, BuildContext context) async {
    String asLabel = "";
    for (var key in cache.keys) {
      if (!asLabel.contains(key)) { asLabel += "&${key}_aslabel=${cache[key]!}"; }
    }
    try { mainDownload(url, "get", true, "&export=$format$asLabel", savePath, isWeb, context);
    } catch (e) { developer.log('LOG ERR PATH $e', name: 'my.app.category'); }
  }

  Future<APIResponse<T>> getWithOffset<T extends SerializerDeserializer>(String url, bool force, BuildContext? context) async {
    return main(url, null, "get", "", force, context, globalLimit, globalOffset, true, null, null);
  }

  Future<APIResponse<T>> get<T extends SerializerDeserializer>(String url, bool force, BuildContext? context) async {
    return main(url, null, "get", "", force, context, null, null, false, null, null);
  }

  Future<APIResponse<T>> post<T extends SerializerDeserializer>(String url, Map<String, dynamic> values, BuildContext? context) async {
    return main(url, values, "post", "send succeed", true, context, null, null, false, null, null);
  }

  Future<APIResponse<T>> put<T extends SerializerDeserializer>(String url, Map<String, dynamic> values, BuildContext? context) async {
    return main(url, values, "put", "save succeed", true, context, null, null, false, null, null);
  }

  Future<APIResponse<T>> delete<T extends SerializerDeserializer>(String url, BuildContext? context) async {
    return main(url, null, "delete", "deletion succeed", true, context, null, null, false, null, null);
  }
}