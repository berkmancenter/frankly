import 'package:flutter/material.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

class AppHorizontalSelectionData<T> {
  final String text;
  final T value;

  AppHorizontalSelectionData(this.text, this.value);
}

class AppHorizontalSelection<T> extends StatelessWidget {
  final List<AppHorizontalSelectionData> appHorizontalSelectionData;
  final T currentValue;
  final void Function(T) onSelected;

  const AppHorizontalSelection({
    Key? key,
    required this.appHorizontalSelectionData,
    required this.currentValue,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.darkBlue),
        ),
        child: Row(
          children: List.generate(appHorizontalSelectionData.length, (index) {
            final isLastItem = appHorizontalSelectionData.length == index + 1;
            final data = appHorizontalSelectionData[index];

            return Expanded(
              child: Material(
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  child: AnimatedContainer(
                    duration: kTabScrollDuration,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border:
                          isLastItem ? null : Border(right: BorderSide(color: AppColor.darkBlue)),
                      color: _getBackgroundColor(data.value),
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: kTabScrollDuration,
                      style: AppTextStyle.bodyMedium.copyWith(color: _getTextColor(data.value)),
                      child: JuntoText(
                        data.text,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  onTap: () => onSelected(data.value),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getBackgroundColor(T data) {
    return currentValue == data ? AppColor.darkBlue : Colors.transparent;
  }

  Color _getTextColor(T data) {
    return currentValue == data ? AppColor.brightGreen : AppColor.darkBlue;
  }
}
