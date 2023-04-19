/*
import 'package:flip_book/flip_book.dart';
import 'package:flutter/material.dart';

class FlipBookControllers extends ChangeNotifier {
  final flipBookControllerEN = FlipBookController(totalPages: 32);
  final flipBookControllerHE = FlipBookController(totalPages: 10);
  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  FlipBookControllers() {
    Set.from({flipBookControllerEN, flipBookControllerHE}).forEach((
        changeNotifier) => changeNotifier.addListener(() {
          if (!_disposed) notifyListeners();
    }));
  }
}*/
