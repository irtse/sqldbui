import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/core/widget/form/widget/empty_formulary.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class FormularyCommentsWidget extends StatefulWidget {
  model.View view;
  model.Item refItem;
  double width;
  double height;

  String newComment = "";

  FormularyCommentsWidget ({ 
    super.key, 
    required this.width,
    required this.height,
    required this.refItem,    
    required this.view,
  });
  @override FormularyCommentsWidgetState createState() => FormularyCommentsWidgetState();
}




class FormularyCommentsWidgetState extends State<FormularyCommentsWidget> {
  /*WebSocketChannel? channel;


  @override
  void initState() {
    super.initState();
    if (channel == null &&  widget.refItem.commentsPath != null) {
      
      var url =  Uri.parse(baseURL);
      var uri = Uri(
        scheme: baseURL.contains("https") ? "wss" : "ws",
        host: url.host, 
        port: baseURL.contains("https") ? 443 : 80,
        path:"${url.path}/websocket/dbcomment?rows=all",
      );
      print(uri.toString());
      channel = WebSocketChannel.connect(uri);
    }
    channel?.stream.listen(
      (data) {
        try {
          jsonDecode(data);
          setState(() {});
        } catch (e) {
          print("Error decoding data: $e");
        }
      },
      onDone: () {
        print("Disconnected");
      },
      onError: (error) {
        print("WebSocket error: $error");
      },
    );
  }*/

  @override Widget build(BuildContext context) {
      return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }

  Future<Widget> futureBuild(BuildContext context) async {
      List<Widget> widgets = [];
      var path = "";
      if ((widget.refItem.commentsPath ?? "") != "") {
        widgets.add(FutureBuilder(future: APIService().get<model.View>(widget.refItem.commentsPath!, true, context), 
          builder: (a,snap) {
          List<Widget> w = [];
          for (var s in (snap.data?.data ?? [])) {
            path = s.actionPath;
            for (var item in s.items) {
              w.add(FormularyCommentWidget(comp: this, item: item, width: widget.width, commentPath: widget.refItem.commentsPath!));
            }
          }
          return Column( children: w.reversed.toList() );
        }));
      }
        
      
      if (widgets.isEmpty) {
        return EmptyFormularyWidget();
      }
      var ctrl = TextEditingController();
      var k = GlobalKey<FormFieldState>();
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child:  Column(children: [
          Container(
            width: widget.width,
            height: widget.height  - 265,
            decoration: BoxDecoration(
              border: Border( bottom: BorderSide(color: Theme.of(context).splashColor)) ),
            child: SingleChildScrollView( child: Column(children:  widgets) ),
          ),
          Padding( 
          padding: EdgeInsets.only(top: 20),
          child: Row( 
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
              width: widget.width - 94,
              margin: EdgeInsets.only(left: 20),
              child: TextFormField(
                key: k,
                readOnly: widget.view.readOnly,
                maxLines: 5,
                controller: ctrl,
                style: TextStyle( fontSize: 14, color: Theme.of(context).secondaryHeaderColor),
                enabled: true,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.grey, width: 1.0)),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIconColor: Theme.of(context).primaryColor,
                  hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                  fillColor:Colors.white,
                  contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 20),
                  suffixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor),
                  hintText: (await getOnFlow(TranslateConstants.commentary)).toLowerCase(),
                  labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                  errorStyle: const TextStyle(fontSize: 0,),
                ),
                onChanged: (String? value) {
                  widget.view.commentBody["content"] = value ?? widget.newComment;
                },
                validator: (String? value) {
                    var t = (value == null || value.isEmpty) ? "" : null;
                    return t;
                  },
                )
              ),
              
                InkWell(
                  onTap: () {
                    if (widget.view.readOnly) {
                      return;
                    }
                    if (!(k.currentState?.validate() ?? true) || (widget.view.commentBody["content"] ?? "") == "") {
                      return;
                    }
                    APIService().post(path, widget.view.commentBody, context).then( (e) {
                      widget.view.commentBody["content"] = null;
                      setState(() { });
                    });
                  },
                  child: Container(
                    height: 135,
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(color: widget.view.readOnly ? Colors.grey : Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Center(child: Icon(Icons.add, color: Colors.white))
                  )
                )
            ]))
        ]));
    }
}

// ignore: must_be_immutable
class FormularyCommentWidget extends StatefulWidget {
  model.Item item;
  double width;
  String commentPath;
  FormularyCommentsWidgetState comp;

  FormularyCommentWidget ({ 
    super.key, 
    required this.commentPath,
    required this.width,
    required this.item, 
    required this.comp,
  });
  @override FormularyCommentWidgetState createState() => FormularyCommentWidgetState();
}
class FormularyCommentWidgetState extends State<FormularyCommentWidget> {
    @override Widget build(BuildContext context) {
      return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
      String? user;
      String content = widget.item.values["content"];
      for (var shal in widget.item.valuesShallow.keys.where( (e) => e.contains("user"))) {
        user = widget.item.valuesShallow[shal]?.label ?? widget.item.valuesShallow[shal]?.name ?? "${widget.item.valuesShallow[shal]?.id}";
      }
      bool isMyself = user == AuthService.user?.name;
      return Row( 
      mainAxisAlignment: isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [Container(
        width: widget.width - 200,
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ],
        ),
        child: Column( children: [
          Stack( children: [
            Container(
              width: widget.width - 200,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50), 
              decoration: BoxDecoration(
                color: isMyself ? Theme.of(context).primaryColor : Colors.white,
                border: Border(bottom: BorderSide(color: Theme.of(context).splashColor)),
                boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 0)) ],
              ),
              child: Text(user?.toUpperCase() ?? "UNKNOWN", style: TextStyle(color:  isMyself ? Colors.white : Theme.of(context).primaryColor))),
            isMyself ? Positioned( right: 30, top: 7, child: InkWell(
              onTap: () => APIService().delete(widget.commentPath.replaceAll("rows=all", "rows=${widget.item.values["id"]}"), context).then(
                (e) => widget.comp.setState(() { })
              ),
              child: Icon(Icons.close, color: isMyself ?  Theme.of(context).splashColor : Colors.grey)
            )) : Container()
          ]),
          Container(
            width: widget.width - 200,
            padding: EdgeInsets.all(20), 
            child: Text(content)
          ),
        ])
      ) ]);
    }
}