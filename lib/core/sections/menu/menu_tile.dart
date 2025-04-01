
// ignore: must_be_immutable
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';

// ignore: must_be_immutable
class MenuTileWidget extends StatefulWidget {
  model.View view;
  String category;
  void Function(String?, String?, bool, bool, bool) refreshView;

  MenuTileWidget ({ 
    super.key, 
    required this.view,
    required this.category,
    required this.refreshView, 
  });
  @override MenuTileWidgetState createState() => MenuTileWidgetState();
}
class MenuTileWidgetState extends State<MenuTileWidget> {
  @override Widget build(BuildContext context) {
    print("THERE");
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        selected: "${widget.view.id}" == viewID?.substring(1),
        onTap: () async { setState(() { 
          widget.refreshView("#${widget.view.id}", widget.category, true, false, false);  
          globalMenuKey.currentState?.setState(() {});
        }); },
        tileColor: Theme.of(context).secondaryHeaderColor,
        iconColor: Theme.of(context).splashColor,
        title: Text((widget.view.label ?? widget.view.name), 
          overflow: TextOverflow.ellipsis, 
          style: const TextStyle(fontSize: 13.0)),
        visualDensity: const VisualDensity(vertical: -4), // to compact
        textColor: Colors.white, 
        selectedColor: Colors.white, 
        hoverColor: Theme.of(context).primaryColorLight,
        trailing: Padding( 
          padding: EdgeInsets.only(right: widget.view.newIds.isNotEmpty ? (("${widget.view.newIds.length}".length + 1) * 10) : 0), 
          child: InkWell( 
            onTap: () {
              widget.view.isFavorize = !widget.view.isFavorize;
              var urlPath = widget.view.favorizePath;
              for (var k in widget.view.favorizeBody.keys.where((element) => !widget.view.isFavorize)) { 
                urlPath += "&$k=${widget.view.favorizeBody[k]}"; 
              }
              setState(() {});
              APIService().call<model.View>(urlPath, widget.view.isFavorize ? "post" : "delete", widget.view.favorizeBody, true, null);
            }, 
            child: Icon( widget.view.isFavorize ? Icons.favorite : Icons.favorite_border, size: 14)
          )
        ),
        leading: Icon( widget.view.isList ?Icons.list : Icons.edit_document ),
      ));
  }
}