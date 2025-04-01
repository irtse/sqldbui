
// ignore: must_be_immutable
import 'package:sqldbui2/core/sections/menu/menu_header.dart';
import 'package:sqldbui2/core/sections/menu/menu_tile_text.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/page.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/menu/menu_tile.dart';

// ignore: must_be_immutable
class MenuExpansionTileWidget extends StatefulWidget {
  String category;
  int count = 0;
  bool isExpanded = false;
  void Function(String?, String?, bool, bool, bool) refreshView;

  MenuExpansionTileWidget ({ 
    super.key, 
    required this.count,
    required this.category,
    required this.isExpanded,
    required this.refreshView,  
  });
  @override MenuExpansionTileWidgetState createState() => MenuExpansionTileWidgetState();
}
class MenuExpansionTileWidgetState extends State<MenuExpansionTileWidget> {
  @override Widget build(BuildContext context) {
    return ExpansionTile(
      shape: const ContinuousRectangleBorder(side: BorderSide(color: Colors.transparent)),
      initiallyExpanded: widget.isExpanded,
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      title: Row( children: [
        Padding(
          padding: const EdgeInsets.only(right: 10), 
          child: Icon(widget.category.toUpperCase().contains("DATA") ? Icons.grid_on : Icons.bookmark, color: Theme.of(context).splashColor)
        ), 
        Flexible( 
          child: Padding( 
            padding: EdgeInsets.only(right: "${widget.count}".isNotEmpty ? (("${widget.count}".length + 1) * 7) : 0), 
            child: Text(widget.category.toUpperCase(), overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).highlightColor, fontSize: 11))
          )
        ) 
      ]), 
      iconColor: isMenu ? Theme.of(context).highlightColor : Colors.transparent, 
      collapsedIconColor: isMenu ? Theme.of(context).highlightColor : Colors.transparent,
      children: [ 
        widget.category.toLowerCase() == "general" ? Container(
          width: noMenu ? 300 : menuSize, 
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black, width: .5), 
              left: BorderSide(color: Theme.of(context).primaryColor, width: 10),
              bottom: const BorderSide(color: Colors.black, width: .25)),
            color: Theme.of(context).secondaryHeaderColor
          ),
          child: MenuTileTextWidget( view: "dashboard", category: widget.category, refreshView: widget.refreshView)
        ) : Container(),
        Container(
          width: noMenu ? 300 : menuSize, 
          height: categories[widget.category]!.length * 40, 
          color: Theme.of(context).secondaryHeaderColor,
          child: ListView.builder(itemBuilder: (builder, index) {
            if (categories[widget.category] == null || categories[widget.category]!.length <= index) { 
              return null; 
            }
            var catIndex = categories[widget.category]![index];
            if (FavoriteConstants.isFavorite && !categories[widget.category]![index].isFavorize) {
              return null;
            }
            List<Widget> badge = catIndex.newIds.isNotEmpty ? [
              Positioned(
                right: 20, 
                top: 8, 
                child: Container(
                  decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(7)), color: Theme.of(context).primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.all(5), child: Text("${catIndex.newIds.length}", 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Theme.of(context).highlightColor )
                  ))
                )
            )] : [];
            return Stack( 
              alignment: Alignment.topRight, 
              children: [ 
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: index == 0 ? .5 : .25), 
                      bottom: const BorderSide(color: Colors.black, width: .25)),
                    color: "${catIndex.id}" == viewID?.substring(1) ? Theme.of(context).primaryColorLight : Colors.transparent 
                  ),
                  child:  Container(
                    decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 10)),
                    color: "${catIndex.id}" == viewID?.substring(1) ? Theme.of(context).primaryColorLight : Colors.transparent 
                  ), 
                  child: MenuTileWidget( view: catIndex, category: widget.category, refreshView: widget.refreshView))), 
                ...badge
              ]); }))],);
  }
}