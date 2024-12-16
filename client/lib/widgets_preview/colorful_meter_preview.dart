import 'package:flutter/material.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/common_widgets/colorful_meter_v2.dart';

class ColorfulMeterPreview extends StatefulWidget {
  @override
  State<ColorfulMeterPreview> createState() => _ColorfulMeterPreviewState();
}

class _ColorfulMeterPreviewState extends State<ColorfulMeterPreview> {
  double _sliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Colorful Meter')),
      body: Column(
        children: [
          Slider(
            min: -1,
            max: 1,
            value: _sliderValue,
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
          SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _Section(
                  text: 'Gauge',
                  child: ColorfulMeterV2(
                    size: 400,
                    value: _sliderValue,
                    title: 'titleeeeeeeeeeeee',
                    subtitle: 'subtitleeeeeeeeeeeee',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  final Widget child;

  const _Section({
    Key? key,
    required this.text,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: AppTextStyle.headline3.copyWith(color: AppColor.redDarkMode),
        ),
        SizedBox(height: 16),
        child,
        SizedBox(height: 32),
      ],
    );
  }
}
