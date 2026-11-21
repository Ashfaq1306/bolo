import 'package:bolo_app/features/assistant/assistant_actions.dart';
import 'package:bolo_app/features/assistant/assistant_settings.dart';
import 'package:bolo_app/features/command/parsed_command.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('assistant name', () {
    test('normalises English names and rejects others', () {
      expect(normalizeAssistantName('  bolo '), 'Bolo');
      expect(normalizeAssistantName('hey   jarvis'), 'Hey Jarvis');
      expect(normalizeAssistantName('বলো'), isNull, reason: 'the offline wake word model is English');
      expect(normalizeAssistantName('b'), isNull);
      expect(normalizeAssistantName('r2d2'), isNull);
    });

    test('default name is shown as বলো in Bangla', () {
      expect(assistantDisplayName('Bolo', 'bn'), 'বলো');
      expect(assistantDisplayName('Bolo', 'en'), 'Bolo');
      expect(assistantDisplayName('Robi', 'bn'), 'Robi');
    });

    test('sensitivity maps to the tested thresholds', () {
      expect(wakeThreshold(1), 0.6);
      expect(wakeThreshold(0), greaterThan(wakeThreshold(1)));
      expect(wakeThreshold(2), lessThan(wakeThreshold(1)));
    });
  });

  test('family words search for common contact names', () {
    expect(searchTermsFor('Ammu'), containsAll(['Ammu', 'Amma', 'Mom', 'মা']));
    expect(searchTermsFor('baba'), containsAll(['baba', 'Abbu', 'Dad']));
    expect(searchTermsFor('Rahim'), ['Rahim']);
  });

  test('actions are never saved and never financial', () {
    for (final i in [CommandIntent.callContact, CommandIntent.playMedia, CommandIntent.openApp]) {
      expect(i.isAction, isTrue);
      expect(i.isSavable, isFalse);
      expect(i.isFinancial, isFalse);
    }
  });
}
