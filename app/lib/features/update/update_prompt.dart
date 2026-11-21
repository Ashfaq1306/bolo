import 'package:flutter/material.dart';

import '../../core/bangla_digits.dart';
import '../../l10n/app_localizations.dart';
import 'app_updater.dart';

/// Shows the "Update available" dialog. A mandatory update can't be dismissed.
Future<void> showUpdateDialog(BuildContext context, AppUpdater updater, AppUpdate update) {
  final l = AppLocalizations.of(context);
  final lang = Localizations.localeOf(context).languageCode;
  final notes = update.notes(lang);
  return showDialog<void>(
    context: context,
    barrierDismissible: !update.mandatory,
    builder: (context) => PopScope(
      canPop: !update.mandatory,
      child: AlertDialog(
        icon: const Icon(Icons.system_update_rounded, size: 36),
        title: Text(l.updateTitle),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(update.mandatory
                ? l.updateMandatoryBody
                : l.updateBody(localDigits(update.latestName.isEmpty ? '${update.latestBuild}' : update.latestName, lang))),
            if (notes.isNotEmpty) ...[const SizedBox(height: 12), Text(notes)],
            const SizedBox(height: 12),
            Text(l.updateHowTo, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        actions: [
          if (!update.mandatory) TextButton(onPressed: () => Navigator.pop(context), child: Text(l.updateLater)),
          FilledButton.icon(
            icon: const Icon(Icons.download_rounded),
            label: Text(l.updateNow),
            onPressed: () async {
              final messenger = ScaffoldMessenger.maybeOf(context);
              final ok = await updater.openDownload(update);
              if (!ok) messenger?.showSnackBar(SnackBar(content: Text(l.updateOpenFailed)));
              if (context.mounted && !update.mandatory) Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
