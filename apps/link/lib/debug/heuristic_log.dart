import 'package:flutter/foundation.dart';

/// In-memory buffer for heuristic-engine reasoning lines (debug builds only).
class HeuristicLog extends ChangeNotifier {
  HeuristicLog._();
  static final HeuristicLog instance = HeuristicLog._();

  static const _maxLines = 500;
  final List<String> _lines = [];

  List<String> get lines => List.unmodifiable(_lines);

  void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }

  void add(String message) {
    if (!kDebugMode) return;
    final now = DateTime.now();
    final ts =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    _lines.add('[$ts] $message');
    if (_lines.length > _maxLines) {
      _lines.removeRange(0, _lines.length - _maxLines);
    }
    notifyListeners();
    debugPrint('[Heuristics] $message');
  }
}
