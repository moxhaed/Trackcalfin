import 'dart:async';
import 'dart:collection';

/// Who is waiting for an AI answer. The gate serves [user] requests first.
enum AiPriority {
  /// Someone tapped something and waits for the result: a fresh scan, Say it, Ask, a label
  /// photo, a swapped pick, Fill with AI.
  user,

  /// Nobody is waiting: macros for new items, scans queued earlier, tomorrow's pick.
  background,
}

/// A user request the gate holds back because Gemini rate limited its model. The app shows
/// [message] so a spinner that takes 20 s more says why.
class GateWait {
  const GateWait({required this.model, required this.wait, this.limit, this.unit = 'requests', this.freeTier = true});
  final String model;
  final Duration wait;

  /// What Google said the per-minute quota is, when it said.
  final int? limit;
  final String unit;
  final bool freeTier;

  String get message {
    final s = (wait.inMilliseconds / 1000).ceil();
    final who = freeTier ? "Gemini's free tier" : 'Your Gemini plan';
    return limit == null
        ? 'Gemini is busy right now; trying again in $s s…'
        : '$who allows $limit $unit a minute; trying again in $s s…';
  }
}

/// The one door every Gemini request goes through. The app has one (AiGateway owns it).
///
/// - At most [maxInFlight] requests at once, and at most [maxBackgroundInFlight] of them
///   background work, so a user request always finds a free slot.
/// - Requests start at least [minSpacing] apart, so a burst (app resume, a new key) spreads out.
/// - Waiting requests start in priority order: user before background, then first come first served.
/// - Per model, it remembers what Google said in a 429: a per-minute cooldown (RetryInfo),
///   the requests-per-minute quota (it then keeps every rolling minute under it), and a
///   spent daily quota (the client fails fast until it resets instead of sending).
class GeminiGate {
  GeminiGate({
    this.maxInFlight = 2,
    this.maxBackgroundInFlight = 1,
    this.minSpacing = const Duration(seconds: 1),
    DateTime Function()? clock,
    Future<void> Function(Duration)? delay,
  }) : _clock = clock ?? DateTime.now,
       _delay = delay ?? Future<void>.delayed;

  final int maxInFlight;
  final int maxBackgroundInFlight;
  final Duration minSpacing;
  final DateTime Function() _clock;
  final Future<void> Function(Duration) _delay;

  /// A rolling minute, plus a second for the trip to Google.
  static const window = Duration(seconds: 61);

  final _queue = <_Ticket>[];
  final _models = <String, _ModelState>{};
  final _waits = StreamController<GateWait>.broadcast();
  int _inFlight = 0;
  int _backgroundInFlight = 0;
  int _seq = 0;
  DateTime? _lastStart;
  DateTime? _wakeAt;

  DateTime get now => _clock();

  /// User requests held back by a rate limit, for a message on screen.
  Stream<GateWait> get waits => _waits.stream;

  int get inFlight => _inFlight;
  int get waiting => _queue.length;

  /// Runs [send] once the gate lets a request to [model] start.
  Future<T> run<T>(String model, AiPriority priority, Future<T> Function() send) async {
    final t = _Ticket(model, priority, _seq++);
    _queue.add(t);
    _pump();
    await t.go.future;
    try {
      return await send();
    } finally {
      _inFlight--;
      if (priority == AiPriority.background) _backgroundInFlight--;
      _pump();
    }
  }

  /// Google answered a per-minute 429 for [model]: hold its requests for [retryAfter].
  /// A request quota ([unit] 'requests') becomes the model's budget per rolling minute.
  void rateLimited(String model, Duration retryAfter, {int? limit, String unit = 'requests', bool freeTier = true}) {
    final s = _state(model);
    final until = now.add(retryAfter);
    if (s.coolUntil == null || until.isAfter(s.coolUntil!)) s.coolUntil = until;
    if (limit != null && limit > 0) {
      s
        ..limit = limit
        ..unit = unit
        ..freeTier = freeTier;
      if (unit == 'requests') s.perMinute = limit;
    }
    _pump();
  }

  /// Google answered a per-day 429 for [model]: until [until] the client fails fast with [message].
  void dailyLimitReached(String model, DateTime until, String message) {
    _state(model)
      ..exhaustedUntil = until
      ..dailyMessage = message;
  }

  /// The daily-limit message while [model]'s daily quota is spent, else null.
  String? dailyLimit(String model) {
    final s = _models[model];
    final until = s?.exhaustedUntil;
    if (until == null || !until.isAfter(now)) return null;
    return s!.dailyMessage;
  }

  /// How long a request to [model] would wait for its cooldown or per-minute budget now.
  Duration cooldownLeft(String model) {
    final t = now;
    final at = _models[model]?.readyAt(t);
    return at == null || !at.isAfter(t) ? Duration.zero : at.difference(t);
  }

  /// [model] has quota left right now.
  bool available(String model) => dailyLimit(model) == null && cooldownLeft(model) == Duration.zero;

  /// Requests to [model] in the last rolling minute.
  int recentStarts(String model) {
    final s = _models[model];
    if (s == null) return 0;
    s.trim(now);
    return s.starts.length;
  }

  /// The per-minute request budget learned for [model] from a 429, if any.
  int? perMinuteBudget(String model) => _models[model]?.perMinute;

  _ModelState _state(String model) => _models.putIfAbsent(model, _ModelState.new);

  void _pump() {
    if (_queue.isEmpty) return;
    final t0 = now;
    _queue.sort((a, b) => a.priority != b.priority ? a.priority.index - b.priority.index : a.seq - b.seq);
    DateTime? next;
    for (final t in [..._queue]) {
      if (_inFlight >= maxInFlight) break; // a finishing request pumps again
      if (t.priority == AiPriority.background && _backgroundInFlight >= maxBackgroundInFlight) continue;
      final spaced = _lastStart?.add(minSpacing);
      if (spaced != null && spaced.isAfter(t0)) {
        next = _earlier(next, spaced);
        break;
      }
      final ready = _models[t.model]?.readyAt(t0);
      if (ready != null && ready.isAfter(t0)) {
        next = _earlier(next, ready);
        _announce(t, ready, t0);
        continue; // another model may go
      }
      _queue.remove(t);
      _inFlight++;
      if (t.priority == AiPriority.background) _backgroundInFlight++;
      _lastStart = t0;
      _state(t.model).starts.add(t0);
      t.go.complete();
    }
    if (next != null) _wakeUpAt(next);
  }

  /// Tells the app, once per wait, that a user request waits for a model's rate limit.
  void _announce(_Ticket t, DateTime ready, DateTime now) {
    final s = _models[t.model]!;
    final wait = ready.difference(now);
    if (t.priority != AiPriority.user || s.announced == ready || wait < const Duration(seconds: 1)) return;
    s.announced = ready;
    _waits.add(GateWait(model: t.model, wait: wait, limit: s.limit, unit: s.unit, freeTier: s.freeTier));
  }

  void _wakeUpAt(DateTime at) {
    final scheduled = _wakeAt;
    if (scheduled != null && !scheduled.isAfter(at) && scheduled.isAfter(now)) return;
    _wakeAt = at;
    final wait = at.difference(now);
    unawaited(
      _delay(wait.isNegative ? Duration.zero : wait).then((_) {
        if (_wakeAt == at) _wakeAt = null;
        _pump();
      }),
    );
  }

  static DateTime _earlier(DateTime? a, DateTime b) => a == null || b.isBefore(a) ? b : a;
}

class _Ticket {
  _Ticket(this.model, this.priority, this.seq);
  final String model;
  final AiPriority priority;
  final int seq;
  final go = Completer<void>();
}

class _ModelState {
  final starts = Queue<DateTime>();
  int? perMinute;
  DateTime? coolUntil;
  DateTime? exhaustedUntil;
  String dailyMessage = '';
  DateTime? announced;
  int? limit;
  String unit = 'requests';
  bool freeTier = true;

  void trim(DateTime now) {
    while (starts.isNotEmpty && !starts.first.add(GeminiGate.window).isAfter(now)) {
      starts.removeFirst();
    }
  }

  /// When the next request may start: after the cooldown, and once the rolling minute
  /// has room under the per-minute budget. Null when it may start now.
  DateTime? readyAt(DateTime now) {
    trim(now);
    DateTime? at;
    final cool = coolUntil;
    if (cool != null && cool.isAfter(now)) at = cool;
    final budget = perMinute;
    if (budget != null && starts.length >= budget) {
      final room = starts.elementAt(starts.length - budget).add(GeminiGate.window);
      if (at == null || room.isAfter(at)) at = room;
    }
    return at;
  }
}
