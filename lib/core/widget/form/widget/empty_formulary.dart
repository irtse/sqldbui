import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';

// ignore: must_be_immutable
class EmptyFormularyWidget extends StatefulWidget {  
  const EmptyFormularyWidget ({ 
    super.key, 
  });
  @override EmptyFormularyWidgetState createState() => EmptyFormularyWidgetState();
}
class EmptyFormularyWidgetState extends State<EmptyFormularyWidget> {
  @override Widget build(BuildContext context) {
    return Container( 
            decoration: BoxDecoration(
            color: Theme.of(context).splashColor,
            borderRadius: BorderRadius.circular(10)
          ),
          margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
          padding: const EdgeInsets.all(20), 
          width: currentWidth - menuSize - 80 > 0 ? currentWidth - menuSize - 80 : 0,
          child:  Wrap( 
            alignment: WrapAlignment.center,
            children: [
              Padding( 
                padding: const EdgeInsets.all(20), 
                child: Container( 
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  width: currentWidth / 3, height: 40 )),
              Padding( padding: const EdgeInsets.all(20), child: Container( 
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                width: currentWidth / 3, height: 40 )),
              Padding( padding: const EdgeInsets.all(20), child: Container( 
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                width: currentWidth / 3, height: 40)),
              Padding( padding: const EdgeInsets.all(20), child: Container( 
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                width: currentWidth / 3, height: 40 )),
              Padding( padding: const EdgeInsets.all(20), child: Container( 
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                width: currentWidth / 3, height: 40 )),
            ],
          ));
  }
}