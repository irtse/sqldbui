
import 'package:flutter/material.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/page/translate.dart';

class InfoAlertBannerChild extends StatelessWidget {
  final String text;
  const InfoAlertBannerChild({super.key, required this.text});

  @override
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: currentWidth * 0.8),
      decoration: const BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Material(
          color: Colors.transparent,
          child: Text((await getOnFlow(text)).toLowerCase(),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AlertAlertBannerChild extends StatelessWidget {
  final String text;
  const AlertAlertBannerChild({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: currentWidth * 0.8),
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Material(
          color: Colors.transparent,
          child: Text( (await getOnFlow(text)).toLowerCase(),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}