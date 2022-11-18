import 'package:fast_rx/src/rx_observer.dart';
import 'package:fast_rx/fast_rx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RxObserver should not throw', () {
    final observer = RxObserver();
    final rx = ''.rx;
    builder() => Text(rx.value);

    observer.setup(builder);
  });

  test('RxObserver should throw', () {
    final observer = RxObserver();
    builder() => const Text('');

    expect(
      () => observer.setup(builder),
      throwsA(isA<NoRxValuesInFastBuilder>()),
    );
  });
}
