
// ignore: must_be_immutable
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class MenuTileTextWidget extends StatefulWidget {
  String view;
  String category;
  void Function(String?, String?, bool, bool, bool) refreshView;

  MenuTileTextWidget ({ 
    super.key, 
    required this.view,
    required this.category,
    required this.refreshView, 
  });
  @override MenuTileTextWidgetState createState() => MenuTileTextWidgetState();
}
class MenuTileTextWidgetState extends State<MenuTileTextWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    var label = await getOnFlow(widget.view);
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        selected: widget.view == viewID?.substring(1),
        onTap: () async { setState(() { 
          widget.refreshView("#${widget.view}", widget.category, true, false, false);  
          globalMenuKey.currentState?.setState(() {});
        }); },
        tileColor: Theme.of(context).secondaryHeaderColor,
        iconColor: Theme.of(context).splashColor,
        title: Text(label.toLowerCase(), 
          overflow: TextOverflow.ellipsis, 
          style: const TextStyle(fontSize: 13.0,)),
        visualDensity: const VisualDensity(vertical: -4), // to compact
        textColor: Colors.white, selectedColor: Colors.white, hoverColor: Theme.of(context).primaryColorLight,
        leading: Icon( Icons.dashboard ),
      ));
  }
}