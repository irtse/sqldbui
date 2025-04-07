import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class LinkBoxWidget extends StatefulWidget {
  String path;
  bool success = false;
  LinkBoxWidget ({ super.key, required this.path});
  @override LinkBoxWidgetState createState() => LinkBoxWidgetState();
}
class LinkBoxWidgetState extends State<LinkBoxWidget> {
  @override Widget build(BuildContext context) {
    return PopupMenuButton(
      color: Colors.white,
      tooltip: TranslateConstants.share.toLowerCase(),
      icon: Icon(size: 18, Icons.share, color: Theme.of(context).primaryColor),
      onSelected: (value) { },
      itemBuilder: (BuildContext bc) { 
        return [ PopupMenuItem(enabled: false, 
            child: Padding( padding: EdgeInsets.all(20), child: Column(children: [  
              Text(TranslateConstants.pathToCopy.toLowerCase(), 
              style: TextStyle(fontSize: 12.5, color: Colors.grey),),
              Row( children : [ 
                SizedBox( 
                  width: 166, 
                  height: 20, 
                  child: TextFormField(
                    enabled: false, 
                    initialValue: widget.path,
                    style: TextStyle( fontSize: 12),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 0, left: 10.0, right: 10.0, bottom: 0),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                      border: const OutlineInputBorder(),
                      filled: true, 
                      fillColor: Theme.of(context).splashColor)
                  )
                ),
                Padding( padding: const EdgeInsets.only(left: 10), child: IconButton(onPressed: () {
                  setState(() {
                    widget.success = true;
                    Future.delayed(const Duration(seconds: 5), () { widget.success = false; });
                  });
                  Clipboard.setData(ClipboardData(text: widget.path));
                }, icon: const Icon(Icons.copy, size: 20, color: Colors.grey))),
              ]),
              ...(widget.success ? [
                Text( TranslateConstants.successCopy, 
                  style: TextStyle(fontSize: 12.5, color: Colors.green),)
              ] : []),
            ]))) ]; 
        });
  }
}