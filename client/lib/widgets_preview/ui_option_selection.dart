import 'package:flutter/material.dart';
import 'package:junto/styles/app_styles.dart';

/// Only used with testing widget's UI.
///
/// For example we have enum
/// ```
///           enum PrePostCardWidgetType {
///             overview,
///             edit,
///           }
/// ```
///
/// Then simply use
/// ```
///                 UiOptionSelection<PrePostCardWidgetType>(
///                 name: 'Type',
///                 availableOptions: PrePostCardWidgetType.values,
///                 currentOption: _prePostCardPrePostCardWidgetType,
///                 onOptionSelected: (option) => setState(
///                   () => _prePostCardPrePostCardWidgetType = option,
///                ),
///               ),
/// ```
///
/// Provides easy functionality of testing multiple values at once and removes boilerplate code.
/// Check [WidgetsPreview] for more samples.
class UiOptionSelection<T> extends StatelessWidget {
  final String name;
  final List<T> availableOptions;
  final T currentOption;
  final void Function(T) onOptionSelected;

  const UiOptionSelection({
    Key? key,
    required this.name,
    required this.availableOptions,
    required this.currentOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(name, style: AppTextStyle.body),
          SizedBox(width: 16),
          Expanded(
            child: Wrap(
              children: List.generate(availableOptions.length, (index) {
                final T listAvailableOption = availableOptions[index];

                return ChoiceChip(
                  label: Text('$listAvailableOption'),
                  selected: listAvailableOption == currentOption,
                  onSelected: (_) => onOptionSelected(listAvailableOption),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
