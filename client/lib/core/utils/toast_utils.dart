import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType {
  success,
  neutral,
  failed,
}

/// Displays Toast message based on the [ToastType].
void showRegularToast(
  BuildContext context,
  String message, {
  required ToastType toastType,
  int durationInSeconds = 3,
}) {
  final Color backgroundColor;
  final Color textColor;
  AppAsset? iconPath;

  switch (toastType) {
    case ToastType.success:
      backgroundColor = AppColor.lightGreen;
      textColor = AppColor.darkGreen;
      iconPath = AppAsset.kCheckCircleSvg;
      break;
    case ToastType.neutral:
      backgroundColor = AppColor.darkBlue;
      textColor = AppColor.white;
      break;
    case ToastType.failed:
      backgroundColor = AppColor.lightRed;
      textColor = AppColor.redLightMode;
      iconPath = AppAsset.kExclamationSvg;
      break;
  }

  FToast().init(context).showToast(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: backgroundColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null) ...[
                SvgPicture.asset(
                  iconPath.path,
                  color: textColor,
                  width: 20,
                  height: 20,
                ),
                SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  message,
                  style: AppTextStyle.subhead.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        ),
        toastDuration: Duration(seconds: durationInSeconds),
        positionedToastBuilder: (context, child) {
          return Positioned(
            top: 16.0,
            left: 24.0,
            right: 24.0,
            child: child,
          );
        },
      );
}
