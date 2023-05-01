import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class AppVerticalText extends StatelessWidget {
  final String text;
  final Orientation orientation;

  const AppVerticalText(this.text, this.orientation, {super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: orientation == Orientation.landscape
      ? Axis.horizontal
      : Axis.vertical,
      alignment: WrapAlignment.center,
      spacing: 4.h,
      children: text
          .split("")
          .map((string) => TextAnimator(
                string,
                style: const TextStyle().bold.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                atRestEffect: WidgetRestingEffects.dangle(),
                // incomingEffect:
                //     WidgetTransitionEffects.incomingOffsetThenScaleAndStep(
                //   duration: const Duration(
                //     milliseconds: 2000,
                //   ),
                // ),
              ),)
          .toList(),
      /* .map((string) => Text(
                string,
                // style: const TextStyle().bold.copyWith(
                //       color: Colors.white,
                //       fontSize: 20.sp,
                //     ),
              ))
          .toList(),*/
    );
  }
}
