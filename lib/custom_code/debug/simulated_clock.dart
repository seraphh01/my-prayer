import 'package:flutter/foundation.dart';

/// Manual debug override. Set to `null` to use the real clock again.
bool simulatedClockEnabled = false;
DateTime? debugSimulatedNow = new DateTime(2026, 6, 15, 23, 45);

/// Optional run-time override: `flutter run --dart-define=SIMULATED_TIME=02:55`
const simulatedTimeFromEnvironment =
    String.fromEnvironment('SIMULATED_TIME', defaultValue: '');

bool get isSimulatedClockActive {
  if (!kDebugMode && simulatedClockEnabled) {
    return false;
  }
  return debugSimulatedNow != null || simulatedTimeFromEnvironment.isNotEmpty;
}

/// Clock used for “Pentru astăzi” hour windows and related dev testing.
DateTime effectiveNow() {
  if (!simulatedClockEnabled) {
    return DateTime.now();
  }

  final manual = debugSimulatedNow;
  if (manual != null) {
    return manual;
  }

  if (simulatedTimeFromEnvironment.isNotEmpty) {
    return _todayAtParsedTime(simulatedTimeFromEnvironment);
  }

  return DateTime.now();
}

DateTime todayAt(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}


void clearDebugSimulatedTime() {
  debugSimulatedNow = null;
}

String? simulatedClockLabel() {
  if (!isSimulatedClockActive) {
    return null;
  }

  final time = effectiveNow();
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute (simulat)';
}

DateTime _todayAtParsedTime(String value) {
  final parts = value.split(':');
  if (parts.isEmpty) {
    return DateTime.now();
  }
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  return todayAt(hour, minute);
}
