import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/quick_log_service.dart';
import '../../data/ai/dto/quick_log_dto.dart';
import '../../domain/quick_log.dart';
import '../../platform/speech.dart';
import '../common/text_prompt.dart';
import '../common/widgets.dart';

Future<void> showSayIt(BuildContext context) => showModalBottomSheet(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => const SayItSheet(),
);

/// "Say it": tell the app what you did, in your own words. Gemini reads it (Prompt G), the
/// app works out every number from your data, and you see it all before one tap logs it.
class SayItSheet extends ConsumerStatefulWidget {
  const SayItSheet({super.key});

  @override
  ConsumerState<SayItSheet> createState() => _SayItSheetState();
}

class _SayItSheetState extends ConsumerState<SayItSheet> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _timer = LogTimer();
  bool _listening = false;
  bool _thinking = false;
  bool _saving = false;
  String? _error;
  QuickLogDraft? _draft;

  /// Every step with nothing left out, so an unticked line stays on the card.
  List<QuickStep> _all = [];

  /// The steps with what is left out and the prices typed: the numbers that get saved.
  List<QuickStep> _now = [];
  final _skip = <int>{};
  final _paid = <int, int>{};

  static const _examples = [
    'Bought a Coke Zero for 1.29 and drank it',
    'Ate two portions of the chili',
    'Döner for 7.50 at lunch',
    'Where is chicken cheaper?',
  ];

  @override
  void initState() {
    super.initState();
    // Talk first: the fastest way to log. Without speech (desktop, no permission) type.
    WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
  }

  @override
  void dispose() {
    unawaited(Speech.instance.stop());
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    final ok = await Speech.instance.start((words, isFinal) {
      if (!mounted) return;
      setState(() => _text.text = words);
      // Done talking: read it right away. Nothing is saved before Log it.
      if (isFinal && words.trim().isNotEmpty) unawaited(_read());
    });
    if (!mounted) return;
    setState(() => _listening = ok);
    if (!ok) _focus.requestFocus();
  }

  Future<void> _stopListening() async {
    await Speech.instance.stop();
    if (mounted) setState(() => _listening = false);
  }

  Future<void> _read() async {
    if (_thinking) return;
    await _stopListening();
    final said = _text.text.trim();
    if (said.isEmpty) {
      setState(() => _error = 'Say or type what you did first.');
      return;
    }
    setState(() {
      _thinking = true;
      _error = null;
    });
    final draft = await ref.read(quickLogServiceProvider).interpret(said);
    if (!mounted) return;
    setState(() {
      _thinking = false;
      _skip.clear();
      _paid.clear();
      if (draft.error != null) {
        _error = draft.error;
        _draft = null;
      } else {
        _draft = draft;
        _all = draft.steps;
        _now = draft.steps;
      }
    });
  }

  Future<void> _replan() async {
    final log = _draft?.log;
    if (log == null) return;
    final steps = await ref.read(quickLogServiceProvider).preview(log, skip: _skip, paid: _paid);
    if (mounted) setState(() => _now = steps);
  }

  void _edit() {
    setState(() => _draft = null);
    _focus.requestFocus();
  }

  Future<void> _price(QuickStep step) async {
    final money = ref.read(moneyProvider);
    // The dialog owns its text controller (see showTextPrompt).
    final text = await showTextPrompt(
      context,
      title: 'What did you pay?',
      keyboard: const TextInputType.numberWithOptions(decimal: true),
      prefix: '${money.symbol} ',
      helper: step.title,
    );
    final typed = text == null ? null : money.parse(text);
    if (!mounted || typed == null || typed <= 0) return;
    _paid[step.action] = typed;
    await _replan();
  }

  Future<void> _log() async {
    final log = _draft?.log;
    if (log == null || _saving) return;
    setState(() => _saving = true);
    final service = ref.read(quickLogServiceProvider);
    final metrics = ref.read(metricsServiceProvider);
    final nutrition = ref.read(nutritionServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final QuickLogReceipt r;
    try {
      r = await service.apply(log, skip: _skip, paid: _paid);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not log it: $e';
        });
      }
      return;
    }
    celebrate();
    unawaited(metrics.record('say_it', _timer.elapsed));
    unawaited(nutrition.fillMissing());
    // Swiped away while saving: popping now would close the screen under the sheet.
    if (mounted) nav.pop();
    // Price checks were answers on the card, not things logged.
    final logged = r.steps.where((s) => !s.info).toList();
    final n = logged.length;
    showUndoOn(
      messenger,
      n == 1 ? logged.single.title : 'Logged $n things',
      detail: n == 1 ? logged.single.detail : logged.map((s) => s.title).take(3).join(' · '),
      onUndo: () => service.undo(r),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: draft == null ? _input(context) : _review(context, draft),
          ),
        ),
      ),
    );
  }

  Widget _input(BuildContext context) {
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Say it', style: context.text.titleLarge),
        const SizedBox(height: 2),
        Text(
          'What did you buy, eat, cook or pay for? Or ask where something is cheaper. '
          'Nothing is saved until you check it.',
          style: muted,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _text,
          focusNode: _focus,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          enabled: !_thinking,
          decoration: InputDecoration(
            hintText: _listening ? 'Listening…' : 'Bought a Coke Zero for 1.29 and drank it',
            errorText: _error,
            errorMaxLines: 3,
          ),
          onTap: _listening ? _stopListening : null,
          onSubmitted: (_) => _read(),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        if (_text.text.isEmpty && !_thinking) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in _examples)
                ActionChip(
                  label: Text(e, style: context.text.labelMedium),
                  onPressed: () => setState(() => _text.text = e),
                ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            _MicButton(listening: _listening, onPressed: _thinking ? null : (_listening ? _stopListening : _listen)),
            const Spacer(),
            if (_thinking) ...[
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 10),
              Text('Working it out…', style: context.text.bodyMedium),
            ] else
              FilledButton.icon(onPressed: _read, icon: const Icon(Icons.arrow_forward), label: const Text('Next')),
          ],
        ),
      ],
    );
  }

  Widget _review(BuildContext context, QuickLogDraft draft) {
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    final current = {for (final s in _now) s.action: s};
    final included = _all.where((s) => !s.info && !_skip.contains(s.action)).length;
    // Only answers (where something is cheaper): nothing to log, the card just closes.
    final onlyAnswers = _all.isNotEmpty && _all.every((s) => s.info);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _all.isEmpty ? 'One question' : (onlyAnswers ? 'Here is what I found' : 'Here is what I got'),
          style: context.text.titleLarge,
        ),
        const SizedBox(height: 2),
        Text('“${draft.said}”', style: muted, maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        if (draft.question != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline, color: context.colors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(draft.question!, style: context.text.bodyMedium)),
              ],
            ),
          ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final s in _all)
                _StepTile(
                  step: current[s.action] ?? s,
                  included: !_skip.contains(s.action),
                  onToggle: (on) {
                    setState(() => on ? _skip.remove(s.action) : _skip.add(s.action));
                    unawaited(_replan());
                  },
                  onPrice: () => _price(s),
                ),
            ],
          ),
        ),
        if (_error != null) Text(_error!, style: context.text.bodySmall?.copyWith(color: context.scheme.error)),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton.icon(
              onPressed: _saving ? null : _edit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(draft.question != null ? 'Answer' : 'Change'),
            ),
            const Spacer(),
            if (onlyAnswers)
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Done'),
              )
            else
              FilledButton.icon(
                onPressed: _saving || included == 0 ? null : _log,
                icon: const Icon(Icons.check),
                label: Text(included <= 1 ? 'Log it' : 'Log $included things'),
              ),
          ],
        ),
      ],
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.listening, required this.onPressed});
  final bool listening;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Tooltip(
      message: listening ? 'Stop listening' : 'Talk',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: listening ? scheme.primary : scheme.primaryContainer,
          boxShadow: [
            if (listening) BoxShadow(color: scheme.primary.withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 2),
          ],
        ),
        child: IconButton(
          iconSize: 26,
          onPressed: onPressed,
          icon: Icon(
            listening ? Icons.graphic_eq : Icons.mic_none,
            color: listening ? scheme.onPrimary : scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

/// One thing that will be logged: what, the numbers the app worked out, anything to check.
class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.included, required this.onToggle, required this.onPrice});
  final QuickStep step;
  final bool included;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPrice;

  static IconData _icon(QuickActionType t) => switch (t) {
    QuickActionType.buy => Icons.shopping_basket_outlined,
    QuickActionType.expense => Icons.payments_outlined,
    QuickActionType.eat => Icons.restaurant_outlined,
    QuickActionType.cook => Icons.soup_kitchen_outlined,
    QuickActionType.throwAway => Icons.delete_outline,
    QuickActionType.count => Icons.inventory_2_outlined,
    QuickActionType.priceCheck => Icons.storefront_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    return Opacity(
      opacity: included ? 1 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // An answer has nothing to leave out.
            if (step.info)
              const SizedBox(width: 12)
            else
              Checkbox(value: included, onChanged: (v) => onToggle(v ?? true)),
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 10),
              child: Icon(_icon(step.kind), size: 20, color: context.scheme.primary),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: context.text.titleSmall),
                    if (step.detail != null) Text(step.detail!, style: muted),
                    if (step.warning != null && included)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          step.warning!,
                          style: context.text.bodySmall?.copyWith(color: context.colors.warning),
                        ),
                      ),
                    if (step.kind == QuickActionType.buy && included)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: onPrice,
                          child: Text(step.estimatedPrice ? 'Enter the price paid' : 'Change price'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
