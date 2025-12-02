
// ignore: must_be_immutable
import 'package:sqldbui2/core/sections/homeview.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/form/convertors/consent.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/page/translate.dart';

List<GlobalKey<MenuTileWidgetState>> tiles = [];
// ignore: must_be_immutable
class MenuTileWidget extends StatefulWidget {
  bool isSelected = false;
  String? text;
  model.View? view;
  String category;
  void Function(String?, String?, bool, bool, bool) refreshView;

  MenuTileWidget ({ 
    super.key, 
    this.text,
    this.view,
    required this.category,
    required this.refreshView, 
  });
  @override MenuTileWidgetState createState() => MenuTileWidgetState();
}
class MenuTileWidgetState extends State<MenuTileWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: getOnFlow(widget.text ?? widget.view?.label ?? widget.view?.name ?? ""), builder: (a,s) {
        if (s.data != null) {
          fastTranslaste[widget.text ?? widget.view?.label ?? widget.view?.name ?? ""] = s.data ?? "";
          try {
            return Material(
              type: MaterialType.transparency,
              child: Tooltip( message: s.data!.toLowerCase(), child: ListTile(
                selected: widget.isSelected,
                onTap: () async { 
                  setState(() { 
                    confirmCache = {};
                    cacheForm = {};
                    consentCache = {};
                    oneToManiesForm = {};
                    oneToManiesStateForm= {};
                    //navigate = true;
                    for (var t in tiles) {
                      t.currentState?.setState(() {
                        t.currentState?.widget.isSelected = false; 
                      });
                    }
                    widget.isSelected = true;
                    for (var e in navigatorCtrls.items) {
                      e.selected = "#${widget.text ?? widget.view?.id}" == e.value;
                    }
                    widget.refreshView("#${widget.text ?? widget.view?.id}", widget.category, true, false, false); 
                  }); 
                },
                tileColor: Theme.of(context).secondaryHeaderColor,
                iconColor: Theme.of(context).splashColor,
                title: Text(
                  s.data!.toLowerCase(), 
                  overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontSize: 13.0)),
                visualDensity: const VisualDensity(vertical: -4), // to compact
                textColor: Colors.white, 
                selectedColor: Colors.white, 
                hoverColor: Theme.of(context).primaryColorLight,
                trailing: widget.view == null ? null : Padding( 
                  padding: EdgeInsets.only(right: (widget.view?.news ?? 0) > 0 ? (("${widget.view?.news ?? ""}".length + 1) * 10) : 0), 
                  child: InkWell( 
                    onTap: () {
                      confirmCache = {};
                      navigate = true;
                      widget.view!.isFavorize = !widget.view!.isFavorize;
                      var urlPath = widget.view!.favorizePath;
                      for (var k in widget.view!.favorizeBody.keys.where((element) => !widget.view!.isFavorize)) { 
                        urlPath += "&$k=${widget.view!.favorizeBody[k]}"; 
                      }
                      setState(() {});
                     globalHomeViewKey.currentState?.setState(() {});
                      APIService().call<model.View>(urlPath, widget.view!.isFavorize ? "post" : "delete", widget.view!.favorizeBody, true, null).then((value) => (e) {
                      },);
                    }, 
                    child: Icon( widget.view!.isFavorize ? Icons.favorite : Icons.favorite_border, size: 14)
                  )
                ),
                leading: Icon( widget.text != null ? Icons.dashboard : widget.view!.isList ? Icons.list : Icons.edit_document ),
              )));
          } catch(e) {
            return Container();
          }
      } else {
        return Container();
      }
    });
  }
}