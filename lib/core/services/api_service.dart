
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/model/abstract.dart';
import 'package:sqldbui2/model/response.dart';
import 'dart:developer' as developer;
import 'package:alert_banner/exports.dart';
import 'package:flutter/material.dart';

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
      baseUrl: 'http://localhost:8080/v1',
     // you can keep this blank
      headers: { 
        'Content-Type': 'application/json; charset=UTF-8' 
      },
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
  Future<APIResponse<T>> get<T extends SerializerDeserializer>(String url, bool force, BuildContext? context) async {
    var err = ""; 
    // developer.log('LOG URL ${url}', name: 'my.app.category');
    if (url != "") {
      if (cache.containsKey(url) && !force) { return cache[url]! as APIResponse<T>; }
      try {
        dio.options.headers["authorization"] = auth;
        var response = await dio.get(url);
        if (response.statusCode != null && response.statusCode! < 400) {
          APIResponse<T> resp = APIResponse<T>().deserialize(response.data);
          if (resp.error == "") { 
            cache[url]=resp;
            return resp; 
          }
          err = resp.error ?? "internal error";
        } 
        if (response.statusCode == 401) { err = "not authorized"; }
      } catch(e) { err = e.toString(); }
    } else { err = "no url"; }
    if (context != null) {
      showAlertBanner( // <-- The function!
                context,
                () {},
                AlertAlertBannerChild(text: err),// <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,
              );
    } 
    throw Exception(err);
  }

  Future<APIResponse<T>> post<T extends SerializerDeserializer>(String url, Map<String, dynamic> values, BuildContext? context) async {
    var err = ""; 
    if (url != "") {
      try {
        dio.options.headers["authorization"] = auth;
        var response = await dio.post(url, data: values);
        if (response.statusCode != null &&  response.statusCode! < 400) {
          APIResponse<T> resp = APIResponse<T>().deserialize(response.data);
          if (resp.error == "") { 
            if (context != null) {
              showAlertBanner( // <-- The function!
                context,
                () {},
                InfoAlertBannerChild(text: "send succeed"), // <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,
              );
            }
            return resp; 
          }
          err = resp.error ?? "internal error";
        } 
        if (response.statusCode == 401) { err = "not authorized"; }
      } catch(e) { err = e.toString(); }
    } else { err = "no url"; }
    if (context != null) {
      showAlertBanner( // <-- The function!
                context,
                () {},
                AlertAlertBannerChild(text: err),// <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,
              );
    } 
    throw Exception(err);
  }

  Future<APIResponse<T>> put<T extends SerializerDeserializer>(String url, Map<String, dynamic> values, BuildContext? context) async {
    var err = ""; 
    if (url != "") {
      try {
        dio.options.headers["authorization"] = auth;
        var response = await dio.put(url, data: values);
        if (response.statusCode != null && response.statusCode! < 400) {
          APIResponse<T> resp = APIResponse<T>().deserialize(response.data);
          if (resp.error == "") { 
            if (context != null) {
              showAlertBanner( // <-- The function!
                context,
                () {},
                InfoAlertBannerChild(text: "save succeed"), // <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,
              );
            } 
            return resp; 
          }
          err = resp.error ?? "internal error";
        } 
        if (response.statusCode == 401) { err = "not authorized"; }
      } catch(e) { err = e.toString(); }
    } else { err = "no url"; }
    if (context != null) {
      showAlertBanner( // <-- The function!
                context,
                () {},
                AlertAlertBannerChild(text: err),// <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,
              );
    } 
    throw Exception(err);
  }

  Future<APIResponse<T>> delete<T extends SerializerDeserializer>(String url, BuildContext? context) async {
    var err = ""; 
    if (url != "") {
      try {
        dio.options.headers["authorization"] = auth;
        var response = await dio.delete(url);
        if (response.statusCode != null && response.statusCode! < 400) {
          APIResponse<T> resp = APIResponse<T>().deserialize(response.data);
          if (resp.error == "") { 
            if (context != null) {
              showAlertBanner( // <-- The function!
                context,
                () {},
                InfoAlertBannerChild(text: "deletion succeed"), // <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,
              );
              } 
            cache.remove(url);
            return resp; 
          }
          err = resp.error ?? "internal error";
        } 
        if (response.statusCode == 401) { err = "not authorized"; }
      } catch(e) { err = e.toString(); }
    } else { err = "no url"; }
    if (context != null) {
      showAlertBanner( // <-- The function!
                context,
                () {},
                AlertAlertBannerChild(text: err), // <-- Put any widget here you want!
                alertBannerLocation:  AlertBannerLocation.bottom,
              );
    } 
    throw Exception(err);
  }
}


class InfoAlertBannerChild extends StatelessWidget {
  final String text;
  const InfoAlertBannerChild({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      decoration: const BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Material(
          color: Colors.transparent,
          child: Text(text,
            style: TextStyle(color: Colors.white, fontSize: 18),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AlertAlertBannerChild extends StatelessWidget {
  final String text;
  const AlertAlertBannerChild({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Material(
          color: Colors.transparent,
          child: Text( text,
            style: TextStyle(color: Colors.white, fontSize: 18),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}