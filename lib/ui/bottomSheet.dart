import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BottomSheetBuilder {
  static void showBottomSheet(
    BuildContext context,
    WidgetBuilder builder, {
    bool enableDrag = true,
    bool responsive = false,
    bool useWideLandscape = true,
    Color? backgroundColor,
    double? preferMinWidth,
    ShapeBorder shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  }) {
    showCustomModalBottomSheet(
      context: context,
      elevation: 0,
      enableDrag: enableDrag,
      backgroundColor: Colors.yellowAccent,
      shape: shape,
      builder: builder,
      containerWidget: (_, animation, child) => Container(
        height: 150,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: child,
      ),
    );
  }
}
