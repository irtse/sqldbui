
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:alert_banner/exports.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/model/abstract.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/widget/dialog/alert.dart';

var firstAPI = true;

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
      baseUrl: 'http://localhost:8080/v1', // you can keep this blank
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

  Future<Response> request<T extends SerializerDeserializer>(String url, String method, Map<String, dynamic>? body) async {
    switch (method.toLowerCase()) {
      case 'get' : return await dio.get(url);
      case 'post' : return await dio.post(url, data:body);
      case 'put' : return await dio.put(url, data:body!);
      case 'delete' : return await dio.delete(url);
      default : return await dio.get(url);
    }
  }

  Future<APIResponse<T>> main<T extends SerializerDeserializer>(String url, Map<String, dynamic>? body, 
                                                                String method, String succeed, bool force, 
                                                                BuildContext? context, int? limit, int? offset, bool isFilter) async {
    var err = ""; 
    // developer.log('LOG URL ${url}', name: 'my.app.category');
    if (url != "") {
      if (cache.containsKey(url) && !force && cache[url] != null && globalOrder.isEmpty) { 
        if (offset != null && cache[url]!.offset <= offset) { return cache[url]! as APIResponse<T>; 
        } else { return cache[url]! as APIResponse<T>; }
      }
      try {
        dio.options.headers["authorization"] = auth;
        var orderBy = "";
        var filter = "";
        var dir = "";
        if (url.contains("?")) {
          for (var order in globalOrder.keys) {
            if (orderBy.isEmpty) { orderBy += "&orderby=$order"; 
            } else { orderBy += ",$order";  }
            if (dir.isEmpty) { dir += "&dir=${globalOrder[order]}"; 
            } else { dir += ",${globalOrder[order]}";  }
          }
          if (isFilter) {
            for (var f in globalFilter.keys) {  
              if (globalFilter[f] != null && globalFilter[f]!.isNotEmpty) { 
                filter += "&$f=";
                for (var f in globalFilter[f]!) {
                  filter += "%${f.value}%${f.connector == "and" ? "+" : ( f.connector == "or" ? "|" : "")}"; 
                }
              }
            }
            if (globalNew) { filter += "&new=enable"; }
          }
        }
        var response = await request("$url${limit != null ? "&limit=$limit" : ""}${offset != null ? "&offset=$offset" : ""}${orderBy.isNotEmpty ? orderBy : ""}${ dir.isNotEmpty ? dir : ""}$filter", method, body);
        if (response.statusCode != null && response.statusCode! < 400) {
          APIResponse<T> resp = APIResponse<T>().deserialize(response.data as Map<String, dynamic>); 
          if (resp.error == "") { 
            if (method == "get") { 
              if (limit != null && cache.containsKey(url)) { 
                if (offset != null) { 
                  cache[url]!.data!.addAll(resp.data!);
                  cache[url]!.offset = offset; 
                }
              } else { cache[url]=resp; } }
            if (context != null && succeed != "") {
              // ignore: use_build_context_synchronously
              showAlertBanner(context, () {}, InfoAlertBannerChild(text: succeed), // <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,);
            }
            return resp; 
          }
          err = resp.error ?? "internal error";
        } 
        if (response.statusCode == 401) { err = "not authorized"; }
      } catch(e, s) {  
        err = e.toString(); }
    } else { err = "no url"; }
    if (context != null) {
      // ignore: use_build_context_synchronously
      showAlertBanner( context, () {}, AlertAlertBannerChild(text: err),// <-- Put any widget here you want!
                       alertBannerLocation:  AlertBannerLocation.bottom,);
    } 
    throw Exception(err);
  }

  Future<APIResponse<T>> getWithOffset<T extends SerializerDeserializer>(String url, bool force, BuildContext? context) async {
    return main(url, null, "get", "", force, context, globalLimit, globalOffset, true);
  }

  Future<APIResponse<T>> get<T extends SerializerDeserializer>(String url, bool force, BuildContext? context) async {
    return main(url, null, "get", "", force, context, null, null, false);
  }

  Future<APIResponse<T>> post<T extends SerializerDeserializer>(String url, Map<String, dynamic> values, BuildContext? context) async {
    return main(url, values, "post", "send succeed", true, context, null, null, false);
  }

  Future<APIResponse<T>> put<T extends SerializerDeserializer>(String url, Map<String, dynamic> values, BuildContext? context) async {
    return main(url, values, "put", "save succeed", true, context, null, null, false);
  }

  Future<APIResponse<T>> delete<T extends SerializerDeserializer>(String url, BuildContext? context) async {
    return main(url, null, "delete", "deletion succeed", true, context, null, null, false);
  }
}