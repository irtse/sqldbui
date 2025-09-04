
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
 import 'package:http_parser/http_parser.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';

import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:alert_banner/exports.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/abstract.dart';
import 'package:sqldbui2/core/widget/dialog/alert.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/function_math_row.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
import 'package:sqldbui2/core/services/html.dart' if (kIsWeb) 'dart:html' as http;
import 'package:sqldbui2/model/view.dart';
import 'package:url_launcher/url_launcher.dart';

var firstAPI = false;
var baseURL = '${const String.fromEnvironment('HOST', defaultValue: 'http://localhost:8082')}/v1';
class APIConstants {
  static String filterLine = "";
  static String downloadEndpost = '/main/download';
  static String mainEndpost = '/main';
  static String genericEndpost = '/generic/';
}

@lazySingleton
class APIService {
  static Map<String, APIResponse<dynamic>> cache = <String, APIResponse<dynamic>>{};
  static String auth = "";
  static final dio = Dio(
    BaseOptions(
      connectTimeout: Duration.zero, // No timeout on connection
      receiveTimeout: Duration.zero, // No timeout on receiving response
      sendTimeout: Duration.zero, 
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
      case 'put' : return await dio.put(url, data: body!, options: options);
      case 'delete' : return await dio.delete(url, options: options);
      default : return await dio.get(url, options: options);
    }
  }
  static ValueNotifier downloadProgressNotifier = ValueNotifier(0);
  Future mainDownload(String url, String format, String method, bool isFilter, String? extend, String savePath, bool isWeb, BuildContext? context) async {
    try {
      downloadProgressNotifier.value = 0;
      dio.options.headers["authorization"] = auth;
      var cmdCol = getCmdCol();
      var columns = getColumns(url, true);
      var orderBy = getOrderDir(url);
      var filter = getFilter(url, isFilter, globalFilter[viewID]);
      var command = "";
      if (commands[viewID] != null && isEditMode[viewID] == true && editMode[viewID] == "math") { command = "&command_row=${cmdToSQLRow(commands[viewID]!)}"; }
      if (isWeb) { 
        dio.get("$url${extend ?? ""}$columns$cmdCol$command$orderBy$filter", options: Options(responseType: ResponseType.bytes)).then((value) async {
          var url = http.Url.createObjectUrlFromBlob(http.Blob([value.data]));
          http.AnchorElement(href: url)..setAttribute('download', savePath.split("/").last)..click();
          downloadProgressNotifier.value = 100;
          await FilePicker.platform.saveFile(fileName: savePath.split("/").last, bytes: Uint8List.fromList(value.data));
          Future.delayed(const Duration(seconds: 1), () { 
            if (context != null) {
              Navigator.of(context).pop(); 
            }  
          });
        });
      } else {
        dio.download("$url${extend ?? ""}$columns$cmdCol$command$orderBy$filter", savePath, onReceiveProgress: (actualBytes, int totalBytes) {
          Future.delayed(const Duration(seconds: 1), () {
            downloadProgressNotifier.value = (actualBytes / totalBytes * 100).floor();
            if (downloadProgressNotifier.value == 100) { 
              if (context != null) {
                Navigator.of(context).pop(); 
              }
            }
          });   
        });
      }
      
    } catch (e, s) { developer.log('LOG ERRDOWNLOAD $e $s', name: 'my.app.category'); }
  }

  Uint8List? convertToBytes(dynamic data) {
    if (data is Uint8List) {
      return data;
    } else if (data is List<int>) {
      return Uint8List.fromList(data);
    } else if (data is String) {
      return Uint8List.fromList(utf8.encode(data));
    }
    return null; // Unsupported type
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
  String getCmdCol() {
    var command = "";
    for (var column in (filterTempOrderView[viewID] ?? [])) {
      if (colFunction[viewID] != null && isEditMode[viewID] == true) {
        if (colFunction[viewID]![column] != null && colFunction[viewID]![column] != "") {
          command += "$column:${colFunction[viewID]![column]},";
        }
      }
    }
    if (isEditMode[viewID] == true) {
      var col = mathColName[viewID] ?? "total";
      if (colFunction[viewID] != null && colFunction[viewID]![col] != null && colFunction[viewID]![col] != "") {
        command += "$col:${colFunction[viewID]![col]},";
      }
    }
    if (command != "") {
        command = command.substring(0, command.length - 1);
        command = "&command_columns=$command";
    }
    return command;
  }
  String getColumns(String url, bool isFilter) {
    if (!isFilter || subViewID != null) { return ""; }
    var columns = ""; 
    if (url.contains("?") && filterOrderView.containsKey(viewID)) {
      columns += "&columns=";
      for (var column in (filterOrderView[viewID] ?? [])) { columns += "$column,"; }
      columns = columns.substring(0, columns.length - 1);
    }
    return columns;
  }

  String getFilter(String url, bool isFilter, Filters? filters) {
    var filter = "";
    if (url.contains("?") && isFilter) {
      if (filters != null && filters.sort().isNotEmpty) {
        filter = "&filter_line=";
        for (var f in filters.sort()) {  
          if ((f.realName ?? "") == "" && (f.column ?? "") == "") { continue; } 
          if (f.comparator == "=") { filter += "${f.realName ?? f.column}%3A${f.value}"; 
          } else if (f.comparator == "!=") { filter += "${f.realName ?? f.column}%3C%3E${f.value}"; 
          } else if (f.comparator == "like") { filter += "${f.realName ?? f.column}~%25${f.value}%25"; 
          } else if (f.comparator == "not like") { filter += "${f.realName ?? f.column}%3C%3E~%25${f.value}%25"; 
          } else if (f.comparator == "<=") { filter += "${f.realName ?? f.column}%3C%3A${f.value}";
          } else if (f.comparator == ">=") { filter += "${f.realName ?? f.column}%3E%3A${f.value}";
          } else { filter += "${f.realName ?? f.column}${f.comparator == "<" ? "%3C" : "%3E"}${f.value}"; }
          filter += f.connector == "and" ? "+" : ( f.connector == "or" ? "|" : "");
        }
      }
      if (globalNew[viewID] != null && globalNew[viewID] != "all") { filter += "&filter_status=${globalNew[viewID]}"; }
    }
    if (APIConstants.filterLine != "") {
      filter = "&filter_line=${APIConstants.filterLine}";
      APIConstants.filterLine = "";
    }
    return filter;
  }

  Future<APIResponse<T>> main<T extends SerializerDeserializer>(String url, dynamic body, 
                                                                String method, String succeed, bool force, 
                                                                BuildContext? context, int? limit, int? offset, 
                                                                bool isFilter, String? extend, Options? options) async {
    var err = ""; 
    if (url != "") {
      try {
        dio.options.headers["authorization"] = auth;
        dio.interceptors.clear(); 
        var cmdCol = getCmdCol();
        var orderBy = "";
        if (!url.contains("shallow")) {
          orderBy = getOrderDir(url);
        }
        
        var filter = getFilter(url, isFilter, globalFilter[viewID]);
        var cols = getColumns(url, offset != null);
        // if (currentView != null && offset != null && currentView!.max < offset) { globalOffset = offset = 0;  }
        var command = "";
        if (commands[viewID] != null && isEditMode[viewID] == true && editMode[viewID] == "math") { 
          command = "&command_row=${cmdToSQLRow(commands[viewID]!)}"; 
        }
        url = "$url$cols$command$cmdCol${extend ?? ""}$orderBy$filter";
        if (method == "get") {
          if ((!force || noReload || resize) && cache.containsKey(url) && cache[url] != null ) { 
            return cache[url]! as APIResponse<T>;
          }
        }
        
        // print("$method $url$cols$command$cmdCol${extend ?? ""}${limit != null ? "&limit=$limit" : ""}${offset != null ? "&offset=$offset" : ""}$orderBy");
        var response = await request("$url${limit != null ? "&limit=$limit" : ""}${offset != null ? "&offset=$offset" : ""}", method, body, options);        
        
        if (response.statusCode == 302) {
          final locationHeader = response.headers.value('location');
          if (locationHeader != null) {
            launchUrl(Uri.parse(locationHeader), webOnlyWindowName: '_blank');
          }
        }
        if (response.statusCode != null && response.statusCode! < 400 && response.statusCode != 302) {
          if (method == "delete") { 
            cache.remove(url); 
          }
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
              showAlertBanner(context, durationOfStayingOnScreen: Duration(seconds: 5), () {}, InfoAlertBannerChild(text: succeed), // <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,);
            }
            if (method == "get") {  
              return cache[url] as APIResponse<T>;  
            }
            return resp; 
          }
          err = resp.error ?? "internal error";
          print(err);
        } 
        if (response.statusCode == 401) { err = "not authorized"; }
      } catch(e, s) {  
        print(e);
        print(s);
        if (e.toString().contains("connection error")) {
          err = "server unreachable";
        } else {
          err = "${e.toString()} ${const String.fromEnvironment('HOST', defaultValue: 'http://localhost:8082')}"; }
        }
    } else { err = "no url"; }
    if (err.contains("token") && err.contains("expired")) {  AuthService().unAuthenticate();  }
    if (context != null && err != "no url") {
      // ignore: use_build_context_synchronously
      Future.delayed(Duration(milliseconds: 100), () => showAlertBanner( context, durationOfStayingOnScreen: Duration(minutes: 1), () {}, AlertAlertBannerChild(text: err),// <-- Put any widget here you want!
                       alertBannerLocation:  AlertBannerLocation.bottom,))
      ;
    } 
    throw Exception(err);
  }

  Future<APIResponse<RawData>> raw(String url, dynamic body, 
                                                                String method,) async {
    var err = ""; 
    if (url != "") {
      try {
        dio.options.headers["authorization"] = auth;
        dio.interceptors.clear(); 
        var command = "";
        if (commands[viewID] != null && isEditMode[viewID] == true && editMode[viewID] == "math") { command = "&command_row=${cmdToSQLRow(commands[viewID]!)}"; }
        var response = await request("$url$command&rawview=enable", method, body, null);
        if (response.statusCode == 302) {
          final locationHeader = response.headers.value('location');
          if (locationHeader != null) {
            launchUrl(Uri.parse(locationHeader), webOnlyWindowName: '_blank');
          }
        }
        if (response.statusCode != null && response.statusCode! < 400 && response.statusCode != 302) {
          if (method == "delete") { cache.remove(url); return APIResponse<RawData>(); }
          APIResponse<RawData> resp = APIResponse<RawData>().deserialize(response.data as Map<String, dynamic>); 
          if (resp.error == "") { return resp; }
          err = resp.error ?? "internal error";
        } 
        if (response.statusCode == 401) { err = "not authorized"; }
      } catch(e, s) {  
        print(e); print(s);
        err = "${e.toString()} ${const String.fromEnvironment('HOST', defaultValue: 'http://localhost:8082')}"; }
    } else { err = "no url"; }
    if (err.contains("token") && err.contains("expired")) {  AuthService().unAuthenticate();  }
    throw Exception(err);
  }

  Future<APIResponse<T>> sendFile<T extends SerializerDeserializer>(String url, String path, String name, Uint8List? b, BuildContext context) async {
    FormData formData = FormData.fromMap({
      "file": b != null ? MultipartFile.fromBytes(
        b,
        filename: name,
        contentType: MediaType("application", "octet-stream"),
      ) : await MultipartFile.fromFile( path, filename: name ),
    });
    // ignore: use_build_context_synchronously
    return main(url, formData, "post", "send succeed", true, context, null, null, false, 
            null, Options(contentType: 'multipart/form-data'));
  }

  Future getWithDownload<T extends SerializerDeserializer>(String url, String format, Map<String,dynamic> cache, String savePath, bool isWeb, BuildContext? context) async {
    String asLabel = "";
    for (var key in cache.keys) {
      if (!asLabel.contains(key)) { asLabel += "&${key}_aslabel=${cache[key]!}"; }
    }
    try { mainDownload(url, format, "get", true, 
      "${ format != "" ? "&export=$format" : ""}$asLabel", savePath, isWeb, context);
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