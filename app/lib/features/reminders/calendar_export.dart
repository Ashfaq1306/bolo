import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/foundation.dart';

/// Opens the phone's calendar app with the event pre-filled; the user taps
/// Save there. Bolo needs no calendar permission and never reads the calendar.
Future<bool> addToPhoneCalendar({required String title, required DateTime start, String? description}) async {
  try {
    return await Add2Calendar.addEvent2Cal(Event(
      title: title,
      description: description,
      startDate: start,
      endDate: start.add(const Duration(minutes: 30)),
      timeZone: 'Asia/Dhaka',
    ));
  } catch (e) {
    debugPrint('Add to calendar failed: $e');
    return false;
  }
}
