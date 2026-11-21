import 'package:flutter/material.dart';

import '../features/command/parsed_command.dart';
import '../features/records/models.dart';
import '../l10n/app_localizations.dart';

/// Human-readable labels and icons for enums, in the current language.
extension BoloLabels on AppLocalizations {
  String intent(CommandIntent i) => switch (i) {
        CommandIntent.createReminder => intentReminder,
        CommandIntent.createTask => intentTask,
        CommandIntent.addExpense => intentExpense,
        CommandIntent.addReceivable => intentReceivable,
        CommandIntent.addPayable => intentPayable,
        CommandIntent.settleLedger => intentSettle,
        CommandIntent.querySummary => intentSummary,
        CommandIntent.callContact => intentCall,
        CommandIntent.playMedia => intentPlay,
        CommandIntent.openApp => intentOpen,
        CommandIntent.unknown => intentUnknown,
      };

  String category(ExpenseCategory c) => switch (c) {
        ExpenseCategory.food => catFood,
        ExpenseCategory.transport => catTransport,
        ExpenseCategory.bills => catBills,
        ExpenseCategory.shopping => catShopping,
        ExpenseCategory.health => catHealth,
        ExpenseCategory.education => catEducation,
        ExpenseCategory.mobileRecharge => catMobile,
        ExpenseCategory.family => catFamily,
        ExpenseCategory.other => catOther,
      };

  String problem(DraftProblem p) => switch (p) {
        DraftProblem.missingTitle => problemMissingTitle,
        DraftProblem.missingAmount => problemMissingAmount,
        DraftProblem.missingPerson => problemMissingPerson,
        DraftProblem.missingDate => problemMissingDate,
        DraftProblem.timeInPast => problemTimeInPast,
        DraftProblem.notSavable => intentUnknown,
      };

  String? ambiguity(Ambiguity a) => switch (a) {
        Ambiguity.none => null,
        Ambiguity.amPm => ambiguityAmPm,
        Ambiguity.relativeDay => ambiguityRelativeDay,
        Ambiguity.relativeWeek => ambiguityRelativeWeek,
        Ambiguity.missingDate => ambiguityMissingDate,
      };

  String repeat(ReminderRepeat r) => switch (r) {
        ReminderRepeat.none => repeatNone,
        ReminderRepeat.daily => repeatDaily,
        ReminderRepeat.weekly => repeatWeekly,
      };
}

IconData intentIcon(CommandIntent i) => switch (i) {
      CommandIntent.createReminder => Icons.alarm_rounded,
      CommandIntent.createTask => Icons.task_alt_rounded,
      CommandIntent.addExpense => Icons.shopping_bag_rounded,
      CommandIntent.addReceivable => Icons.call_received_rounded,
      CommandIntent.addPayable => Icons.call_made_rounded,
      CommandIntent.settleLedger => Icons.handshake_rounded,
      CommandIntent.querySummary => Icons.insights_rounded,
      CommandIntent.callContact => Icons.call_rounded,
      CommandIntent.playMedia => Icons.music_note_rounded,
      CommandIntent.openApp => Icons.apps_rounded,
      CommandIntent.unknown => Icons.help_outline_rounded,
    };

IconData categoryIcon(ExpenseCategory c) => switch (c) {
      ExpenseCategory.food => Icons.restaurant_rounded,
      ExpenseCategory.transport => Icons.directions_bus_rounded,
      ExpenseCategory.bills => Icons.receipt_long_rounded,
      ExpenseCategory.shopping => Icons.shopping_cart_rounded,
      ExpenseCategory.health => Icons.local_hospital_rounded,
      ExpenseCategory.education => Icons.school_rounded,
      ExpenseCategory.mobileRecharge => Icons.phone_android_rounded,
      ExpenseCategory.family => Icons.family_restroom_rounded,
      ExpenseCategory.other => Icons.category_rounded,
    };
