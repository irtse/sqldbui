import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/page/translate.dart';

class RedirectButtonWidget extends StatefulWidget {
  String id;
  String name;
  String category;

  bool isHovered = false;
  RedirectButtonWidget ({ 
    super.key, 
    required this.id,
    required this.name,
    required this.category
  });
  @override RedirectButtonWidgetState createState() => RedirectButtonWidgetState();
}
class RedirectButtonWidgetState extends State<RedirectButtonWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }

  Future<Widget> futureBuild(BuildContext context) async {
    var c = Theme.of(context).primaryColor;
    c.withOpacity(widget.isHovered ? 0.8 : 1);
    return MouseRegion(
      onHover: (h) => setState(() {
        widget.isHovered = true;
      }),
      onExit: (h) => setState(() {
        widget.isHovered = false;
      }),
      child: InkWell( onTap: () { globalMenuKey.currentState?.refreshView("#${widget.id}", widget.category, false, false, false); },
          child: Container(
            decoration: BoxDecoration(
              color: c,
              border: Border( right: BorderSide(color: Theme.of(context).splashColor)
            ), 
          ),
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text((await getOnFlow(widget.name)).toUpperCase(), style: TextStyle( fontSize: 12, color: Colors.white ) )
        )
    ));
  }
}