import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DembraneProjectLinkSection extends StatelessWidget {
  const DembraneProjectLinkSection({
    super.key,
    required this.projectId,
    required this.onProjectChanged,
  });

  final String? projectId;
  final ValueChanged<String?> onProjectChanged;

  Future<void> _showDembraneProjectDialog(BuildContext context) async {
    final controller = TextEditingController(text: projectId ?? '');
    final linkedProjectId = projectId?.trim();
    final hasLinkedProject = linkedProjectId?.isNotEmpty ?? false;

    final result = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.l10n.linkToDembraneProject),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dialogContext.l10n.dembraneProjectUrlHint,
                  style: dialogContext.theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: controller,
                  labelText: dialogContext.l10n.dembraneProjectIdLabel,
                  autofocus: true,
                  maxLength: null,
                ),
                SizedBox(height: 12),
                Text(
                  dialogContext.l10n.dembraneProjectRecordingHint,
                  style: dialogContext.theme.textTheme.bodySmall?.copyWith(
                    color: dialogContext.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogContext.l10n.cancel),
            ),
            if (hasLinkedProject)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, ''),
                style: TextButton.styleFrom(
                  foregroundColor: dialogContext.theme.colorScheme.error,
                ),
                child: Text(dialogContext.l10n.unlink),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: Text(dialogContext.l10n.save),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result != null) {
      onProjectChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkedProjectId = projectId?.trim();
    final hasLinkedProject = linkedProjectId?.isNotEmpty ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.dembraneName,
            style: context.theme.textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            context.l10n.dembraneProjectSectionDescription,
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 16),
          ActionButton(
            expand: true,
            type: ActionButtonType.outline,
            text: hasLinkedProject
                ? context.l10n.updateDembraneProjectLink
                : context.l10n.linkToDembraneProject,
            onPressed: () => _showDembraneProjectDialog(context),
          ),
          if (hasLinkedProject) ...[
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.dembraneLinkedProjectId,
                          style: context.theme.textTheme.bodySmall?.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 4),
                        SelectableText(
                          linkedProjectId!,
                          style: context.theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  _CopyProjectIdButton(text: linkedProjectId),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CopyProjectIdButton extends StatelessWidget {
  const _CopyProjectIdButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        showRegularToast(
          context,
          context.l10n.copiedToClipboard,
          toastType: ToastType.success,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(Icons.copy, size: 20),
      ),
    );
  }
}
