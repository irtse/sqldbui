import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TutorialPopUpWidget extends StatefulWidget {
  TutorialPopUpWidget ({ Key? key,}): super(key: key);
  @override
  TutorialPopUpState createState() => TutorialPopUpState();
}
class TutorialPopUpState extends State<TutorialPopUpWidget> {
  @override Widget build(BuildContext context) {
    List<int> list = [1, 2, 3, 4, 5];
    return Scaffold(
      appBar: AppBar(title: const Text('TUTORIAL - HOW TO START')),
      body: Container(
          child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          scrollDirection: Axis.vertical,
        ),
        items: list
            .map((item) => Container(
                  child: Center(child: Text(item.toString())),
                  color: Colors.green,
                ))
            .toList(),
      )),
    );
  }
}