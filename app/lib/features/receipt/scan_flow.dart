import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../command/confirmation_sheet.dart';
import '../command/parsed_command.dart';
import '../records/models.dart';
import '../voice/face_mood.dart';
import '../voice/orb_face.dart';
import 'receipt_scanner.dart';

/// Camera → on-device text recognition → expense confirmation card.
Future<void> scanReceiptFlow(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  ref.read(faceMoodProvider.notifier).flash(FaceExpression.thinking, duration: const Duration(seconds: 8));
  final result = await ref.read(receiptScannerProvider).scan();
  ref.read(faceMoodProvider.notifier).flash(FaceExpression.idle, duration: Duration.zero);

  switch (result.failure) {
    case ScanFailure.cancelled:
      return;
    case ScanFailure.noText:
      ref.read(faceMoodProvider.notifier).flash(FaceExpression.confused);
      messenger.showSnackBar(SnackBar(content: Text(l.scanNoText)));
      return;
    case ScanFailure.error:
      ref.read(faceMoodProvider.notifier).flash(FaceExpression.confused);
      messenger.showSnackBar(SnackBar(content: Text(l.scanFailed)));
      return;
    case null:
      break;
  }

  final guess = result.guess!;
  if (!context.mounted) return;
  messenger.showSnackBar(SnackBar(content: Text(l.scanHint), duration: const Duration(seconds: 4)));
  await showConfirmationSheet(
    context,
    ref,
    ParsedCommand(
      intent: CommandIntent.addExpense,
      confidence: 0.6, // a scan is a guess: the card shows "please check"
      amountPoisha: guess.amountPoisha,
      category: guess.category,
      title: guess.merchant ?? '',
      source: RecordSource.scan,
    ),
  );
}
