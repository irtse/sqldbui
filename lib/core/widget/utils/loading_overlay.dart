import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Shown on top of the previous frame while a reload is in flight, so the
// content underneath never has to be torn down to a blank widget first.
// Also used stand-alone (via `standalone: true`) for the rare case where
// there is no previous frame to show yet (very first load): same spinner,
// same size, just an opaque background instead of a translucent scrim, so
// it never reads as a different, less polished loader.
class LoadingOverlayWidget extends StatelessWidget {
  final bool standalone;
  // Inset from the top only, e.g. to clear a header/actionbar above the
  // content this overlay sits on. Must stay a Positioned.fill offset (not a
  // wrapping Container/margin) — Positioned.fill needs to be a direct Stack
  // child to size itself to the full width; wrapping it breaks that.
  final double topMargin;
  const LoadingOverlayWidget({super.key, this.standalone = false, this.topMargin = 0});
  @override Widget build(BuildContext context) {
    final content = Container(
      color: Colors.black.withValues(alpha: 0.70),
      alignment: Alignment.center,
      child: SpinKitCircle(color: Theme.of(context).primaryColor, size: 40),
    );
    if (standalone) {
      return content;
    }
    return Positioned.fill(top: topMargin, child: IgnorePointer(child: content));
  }
}

// Small centered spinner for confined spaces (a single icon button, a table
// cell, a value input) where the full-size LoadingOverlayWidget would be
// out of proportion. Give it an explicit width/height (via SizedBox) when the
// surrounding layout can't infer a size on its own (e.g. inside a horizontal
// scroll view or a Row with loose constraints).
class InlineLoaderWidget extends StatelessWidget {
  final double size;
  const InlineLoaderWidget({super.key, this.size = 18});
  @override Widget build(BuildContext context) {
    return Center(child: SpinKitCircle(color: Theme.of(context).primaryColor, size: size));
  }
}

// A fixed-height bar with a centered spinner, standing in for a toolbar/row
// while whatever it needs (usually a batch of translations) isn't ready yet,
// instead of letting the real content pop in piecemeal as each translation
// resolves.
class LoadingBarWidget extends StatelessWidget {
  final double height;
  const LoadingBarWidget({super.key, this.height = 40});
  @override Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Theme.of(context).primaryColorLight,
      alignment: Alignment.center,
      child: SpinKitCircle(color: Theme.of(context).primaryColor, size: height * 0.5),
    );
  }
}
