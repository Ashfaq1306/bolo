import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dhaka_time.dart';
import '../../core/labels.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/depth_card.dart';
import '../../l10n/app_localizations.dart';
import '../command/confirmation_sheet.dart';
import '../command/parsed_command.dart';
import '../receipt/scan_flow.dart';
import '../records/models.dart';

/// Expenses for the month plus the receivable/payable ledger.
class MoneyScreen extends ConsumerWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final expenses = ref.watch(monthExpensesProvider).value ?? const <Expense>[];
    final ledger = ref.watch(openLedgerProvider).value ?? const <LedgerEntry>[];
    final summary = ref.watch(dailySummaryProvider);

    final byCategory = <ExpenseCategory, int>{};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amountPoisha;
    }
    final sortedCats = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final monthTotal = summary.spentMonthPoisha;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l.navMoney),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: l.scanReceipt,
            icon: const Icon(Icons.document_scanner_rounded),
            onPressed: () => scanReceiptFlow(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addMoney',
        onPressed: () => showConfirmationSheet(context, ref, const ParsedCommand(intent: CommandIntent.addExpense)),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addManually),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 96), children: [
        DepthCard(
          accent: BoloColors.violet,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.expensesTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(Money.format(monthTotal, languageCode: lang),
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (sortedCats.isEmpty) Text(l.noExpenses),
            // Category bars: a simple, accessible "chart" (text + bar).
            for (final entry in sortedCats)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Icon(categoryIcon(entry.key), size: 18),
                  const SizedBox(width: 8),
                  SizedBox(width: 96, child: Text(l.category(entry.key), overflow: TextOverflow.ellipsis)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: monthTotal == 0 ? 0 : entry.value / monthTotal,
                        minHeight: 10,
                        color: BoloColors.teal,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(Money.format(entry.value, languageCode: lang)),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        for (final e in expenses.take(30))
          ListTile(
            leading: CircleAvatar(child: Icon(categoryIcon(e.category), size: 20)),
            title: Text(e.note.isEmpty ? l.category(e.category) : e.note),
            subtitle: Text(DhakaTime.formatDate(e.spentAt, lang)),
            trailing: Text(Money.format(e.amountPoisha, languageCode: lang),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text(l.ledgerTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
          TextButton.icon(
            onPressed: () => showConfirmationSheet(context, ref, const ParsedCommand(intent: CommandIntent.addReceivable)),
            icon: const Icon(Icons.add_rounded),
            label: Text(l.addManually),
          ),
        ]),
        if (ledger.isEmpty) Padding(padding: const EdgeInsets.all(12), child: Text(l.noLedger)),
        for (final e in ledger)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DepthCard(
              accent: e.direction == LedgerDirection.receivable ? BoloColors.receive : BoloColors.pay,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Icon(
                  e.direction == LedgerDirection.receivable ? Icons.call_received_rounded : Icons.call_made_rounded,
                  color: e.direction == LedgerDirection.receivable ? BoloColors.receive : BoloColors.pay,
                ),
                title: Text('${e.person} · ${Money.format(e.amountPoisha, languageCode: lang)}'),
                subtitle: Text([
                  e.direction == LedgerDirection.receivable ? l.intentReceivable : l.intentPayable,
                  if (e.dueAt != null) DhakaTime.formatDate(e.dueAt!, lang),
                  if (e.note.isNotEmpty) e.note,
                ].join(' · ')),
                trailing: IconButton(
                  tooltip: l.settle,
                  icon: const Icon(Icons.handshake_rounded),
                  onPressed: () => _settle(context, ref, e, lang),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  /// Settling money is financial too: always an explicit confirmation.
  Future<void> _settle(BuildContext context, WidgetRef ref, LedgerEntry e, String lang) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.settle),
        content: Text(l.settleConfirm(e.person, Money.format(e.amountPoisha, languageCode: lang))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.confirm)),
        ],
      ),
    );
    if (ok == true) await ref.read(recordsRepositoryProvider)?.settleLedgerEntry(e.id);
  }
}
