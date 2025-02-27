import 'package:fast_rx/fast_rx.dart';
import 'package:flutter/material.dart';

/// A [StatefulWidget] that updates with it's observer
class FastBuilder extends StatefulWidget {
  /// A Widget builder containing reactive objects
  final ValueGetter<Widget> builder;

  /// Rebuild if the [condition] is true
  ///
  /// Defaults to always rebuild
  final ValueGetter<bool>? condition;

  /// A list of [Rx] objects to listen to that's not within the [builder]
  ///
  /// RxObserverIsNotListenable will be thrown if observed widgets are only in
  /// the parent scope and not the builder. Take care to avoid duplicating
  ///  variables in the observable list and builder
  final List<Rx>? observables;

  /// A [FastBuilder] updates when reactive properties within change
  const FastBuilder(this.builder,
      {super.key, this.condition, this.observables});

  @override
  State<StatefulWidget> createState() {
    return _FastBuilderState();
  }
}

class _FastBuilderState extends State<FastBuilder> {
  final _observer = RxObserver();

  @override
  void initState() {
    super.initState();
    _observer.listen(() {
      if (!mounted || !(widget.condition?.call() ?? true)) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return _observer.setup(widget.builder, observables: widget.observables);
  }

  @override
  void dispose() {
    _observer.dispose();
    super.dispose();
  }
}
