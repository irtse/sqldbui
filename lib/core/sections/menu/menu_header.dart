
// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/page.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/page/translate.dart';

class MenuConstants {
  static bool isFavorite = false;
  static String? value;
}

// ignore: must_be_immutable
class MenuHeaderWidget extends StatefulWidget {
  TextEditingController controller = TextEditingController();

  MenuHeaderWidget ({ 
    super.key, 
    required this.controller,
  });
  @override MenuHeaderWidgetState createState() => MenuHeaderWidgetState();
}
class MenuHeaderWidgetState extends State<MenuHeaderWidget> {
  Widget getSlotMenu(int max, int index, IconData icon, String tooltip, bool Function() condition, void Function() change) {
    return Tooltip( message: tooltip, child: InkWell( 
      onTap: () { globalMenuKey.currentState?.setState(() { change(); });}, 
      child: Container(
        decoration: BoxDecoration(
          color: !condition() ? Theme.of(context).primaryColor : Theme.of(context).secondaryHeaderColor,
          border: Border( 
            bottom: BorderSide(color: Colors.black, width: 0.4),
            right: index > 0 ? BorderSide(color: Colors.black, width: 0.4) : BorderSide.none)),
      alignment: Alignment.center, height: 40, width: (noMenu ? 300 : menuSize) > 0 ? (noMenu ? 300 : menuSize) / max : 0, 
      child: Icon(icon, color: Theme.of(context).highlightColor))
    ));
  }

  @override Widget build(BuildContext context) {
    return Column( children: menuSize <= 0 && !noMenu ? [] : <Widget>[
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          border: const Border(bottom: BorderSide(color: Colors.black, width: 0.5))
        ),
        child: Padding( 
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), 
          child : SizedBox(
            height: 30, width: ((noMenu ? 300 : menuSize) - 20) > 0 ? ((noMenu ? 300 : menuSize) - 20) : 0, 
            child: TextFormField(
              cursorHeight: 15,
              controller: widget.controller,
              style: TextStyle(height: 1, color: Theme.of(context).highlightColor, fontSize: 11),
              onChanged: (value) {
                MenuConstants.value = value;
                globalMenuKey.currentState?.setState(() { });
              },
              decoration: InputDecoration(
                filled: true,
                labelStyle: TextStyle(color: Theme.of(context).highlightColor),
                hintStyle: TextStyle(color: Theme.of(context).splashColor),
                contentPadding: const EdgeInsets.all(2),
                fillColor: Theme.of(context).primaryColorLight,
                iconColor: Theme.of(context).highlightColor,
                prefixIcon: Icon(Icons.filter_alt, size: 20, color: Theme.of(context).splashColor,),
                hintText: TranslateConstants.filterMenu.toLowerCase(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), 
                                           borderSide: BorderSide(color: Theme.of(context).primaryColor)) )
        ),
      ))), 
      Row(children: [
        getSlotMenu(2, 0, Icons.all_inbox, TranslateConstants.all.toLowerCase(), () => MenuConstants.isFavorite, () { MenuConstants.isFavorite = false; }),
        getSlotMenu(2, 1, Icons.favorite_border, TranslateConstants.favorites.toLowerCase(), () => !MenuConstants.isFavorite, () { MenuConstants.isFavorite = true; }),
      ])
    ]);
  }
}