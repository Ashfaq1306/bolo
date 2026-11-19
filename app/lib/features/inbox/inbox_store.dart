import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A capture that could not be understood yet (usually because the phone was
/// offline). Kept ONLY on this phone until the user taps "Process".
class InboxItem {
  const InboxItem({required this.text, required this.createdAt, required this.fromVoice});
  final String text;
  final DateTime createdAt;
  final bool fromVoice;

  Map<String, Object> toJson() =>
      {'text': text, 'createdAt': createdAt.toIso8601String(), 'fromVoice': fromVoice};

  static InboxItem? fromJson(Object? j) {
    if (j is! Map) return null;
    final text = j['text'], created = j['createdAt'];
    if (text is! String || created is! String) return null;
    final at = DateTime.tryParse(created);
    if (at == null) return null;
    return InboxItem(text: text, createdAt: at, fromVoice: j['fromVoice'] == true);
  }
}

class InboxStore {
  InboxStore(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'inbox.v1';
  static const maxItems = 20;

  List<InboxItem> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map(InboxItem.fromJson).whereType<InboxItem>().toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<InboxItem>> add(InboxItem item) async {
    final items = [item, ...load()].take(maxItems).toList();
    await _save(items);
    return items;
  }

  Future<List<InboxItem>> remove(InboxItem item) async {
    final items = load()
        .where((i) => !(i.text == item.text && i.createdAt == item.createdAt))
        .toList();
    await _save(items);
    return items;
  }

  Future<void> _save(List<InboxItem> items) =>
      _prefs.setString(_key, jsonEncode(items.map((i) => i.toJson()).toList()));
}
