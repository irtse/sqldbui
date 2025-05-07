import 'dart:async';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqldbui2/model/view.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/sections/menu/redirect_button.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' if (kIsWeb) '' as html;

// ignore: must_be_immutable
GlobalKey<HomeViewWidgetState> globalHomeViewKey = GlobalKey<HomeViewWidgetState>();
class HomeViewWidget extends StatefulWidget{
  HomeViewWidget(): super(key: globalHomeViewKey);
  @override HomeViewWidgetState createState() => HomeViewWidgetState();
}
class HomeViewWidgetState extends State<HomeViewWidget> {
  final Completer<WebViewController> _controller =  Completer<WebViewController>();
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    List<Widget> comps = [];
    List<RedirectButtonWidget> views = [];
    Widget? web;
    if (kIsWeb) {
      web= FutureBuilder(future: APIService().get<model.View>(
        "${APIConstants.genericEndpost}/dbdashboard?rows=all&is_selected=true", false, context), 
        builder: (s,a){
          if (a.data?.data != null && a.data!.data!.isNotEmpty 
          && a.data!.data![0].items.isNotEmpty && (a.data?.data?[0].items[0].values["url"] ?? "") != "") {
            var v = a.data!.data![0].items[0];
            return html.HtmlWidget(
              '''
                <iframe title="YouTube video player" src="${ v.values["url"]! }"</iframe>
              ''',
            );
          }
          return SizedBox(
            width: currentWidth - menuSize,
            height: currentHeigth - 120,
            child: Wrap( alignment: WrapAlignment.center, children: [
              Container(
                height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 60,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 40,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 40,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 60,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: currentWidth - menuSize - 80,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
            ]),
          );
        }); 
    } else {
      web = FutureBuilder(future: APIService().get<model.View>(
        "${APIConstants.genericEndpost}/dbdashboard?rows=all&is_selected=true", false, context), 
        builder: (s,a){
          if (a.data?.data != null && a.data!.data!.isNotEmpty 
          && a.data!.data![0].items.isNotEmpty && (a.data?.data?[0].items[0].values["url"] ?? "") != "") {
            var v = a.data!.data![0].items[0];
            return WebView(
              initialUrl: v.values["url"]!,
              initialCookies: const [
                WebViewCookie(name: 'mycookie', value: 'foo', domain: 'flutter.dev')
              ],
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              javascriptMode: JavascriptMode.unrestricted,
            );
          }
          return SizedBox(
            width: currentWidth - menuSize,
            height: currentHeigth - 120,
            child: Wrap( alignment: WrapAlignment.center, children: [
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 60,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 40,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 40,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: ((currentWidth - menuSize) / 4) - 60,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
              Container(
               height: ((currentHeigth - 120) / 2) - 40,
                width: currentWidth - menuSize - 80,
                margin: EdgeInsets.all(20), 
                decoration: BoxDecoration(color: Colors.grey.shade200,  borderRadius: BorderRadius.all(Radius.circular(5)))),
            ]),
          );
        });
    }
    for (var cat in categories.keys) {
      for (var view in categories[cat]!.where( (e) => e.isFavorize)) {
        views.add(
          RedirectButtonWidget(id: "${view.id}", name: view.label ?? view.name, category: cat)
        );
      }
      comps.add(Padding( padding: const EdgeInsets.symmetric(horizontal: 50), child: Column(children: [
        Row(children: [  Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.bookmark, color: Theme.of(context).splashColor, size: 25)),
          Padding( padding: const EdgeInsets.only(right: 20),
          child: Text(await getOnFlow("${cat[0].toUpperCase()}${cat.substring(1).toLowerCase()}"),
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 20))),
            Expanded( child: Divider(color: Theme.of(context).splashColor,))],),
        Padding(padding: const EdgeInsets.all(10), child: Wrap(alignment: WrapAlignment.center, children: views,))
      ],)));
    }
    return FutureBuilder<APIResponse<Shallowed>>(future:APIService().get<Shallowed>(
      "${APIConstants.genericEndpost}/dbview?rows=all&shallow=enable&shortcut_on_main=true", false, context), 
    builder: (a,s) {
      if (s.data?.data != null) {
        for (var d in s.data!.data!) {
          var l =  d.label ?? d.name ?? "";
          if (views.where( (e) => e.name == l).isEmpty) {
            views.add(RedirectButtonWidget(id: "${d.id}", name: l, category: ""));
          } 
        } 
      }
      return Column( children: [
        Container( 
          height: 40, 
          padding: const EdgeInsets.symmetric(horizontal: 30),
          width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
          decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            boxShadow: [  BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible( child: Text(TranslateConstants.dashboard.toUpperCase(), 
              overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).highlightColor) ) ),
              Padding(padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.dashboard, color: Colors.grey.shade200, size: 18)
            ),
          ])),
        Column( children: [
          Container(
              width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0, 
              decoration: BoxDecoration( 
                boxShadow: [  BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ],
                color: Theme.of(context).primaryColor),
              child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: views))
          ),
          Container(
            width: currentWidth - menuSize,
            color: Colors.grey.shade300,
            height: currentHeigth - 80 - (views.isEmpty ? 0 : 40),
            child: web
          ),
        ])
      
      ]);
    }); 
  }  
}