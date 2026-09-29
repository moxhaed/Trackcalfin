import '../core/enums.dart';
import '../core/money.dart';
import '../data/isar/collections/user_profile.dart';
import 'dashboard.dart';

class VibeResult {
  VibeResult(this.score, this.label, this.insight, this.components);

  /// 0..100, or null while there's nothing to score yet.
  final int? score;
  final String label;
  final String insight;
  final Map<String, double> components;
}

/// Composite 0-100 "Vibe Check" with one actionable insight line.
class VibeScorer {
  const VibeScorer._();

  static const weights = {
    'food': 0.30,
    'nonfood': 0.15,
    'protein': 0.20,
    'kcal': 0.15,
    'logging': 0.20,
  };

  static double paceScore(double pace) => 100 - ((pace - 1) * 200).clamp(0, 100);

  static double kcalScore(double avg, double target) {
    final d = (avg - target).abs() / target;
    return 100 - ((d - 0.05) * 400).clamp(0, 100);
  }

  static String labelFor(int score) => score >= 85
      ? 'Locked in'
      : score >= 70
          ? 'On track'
          : score >= 50
              ? 'Drifting'
              : 'Reset mode';

  static VibeResult score(
    DashboardState s,
    UserProfile p,
    MoneyFormat money, {
    String? pickTitle,
    double? pickProtein,
  }) {
    final c = <String, double>{};
    if (s.monthlyBudget > 0 && s.monthPace != null && !s.collectingData) {
      c['food'] = paceScore(s.monthPace!);
    }
    if (s.nonFoodLimit > 0) {
      final pace = s.nonFoodSpent / (s.nonFoodLimit * (s.monthElapsedFraction < paceFloor ? paceFloor : s.monthElapsedFraction));
      c['nonfood'] = paceScore(pace);
    }
    if (p.dailyProteinTargetG > 0 && s.avgProtein != null) {
      c['protein'] = (s.avgProtein! / p.dailyProteinTargetG).clamp(0, 1) * 100;
    }
    if (p.dailyKcalTarget > 0 && s.avgKcal != null) {
      c['kcal'] = kcalScore(s.avgKcal!, p.dailyKcalTarget);
    }
    if (s.coverage != null) c['logging'] = s.coverage! * 100;

    if (c.isEmpty) {
      return VibeResult(null, 'Getting started',
          'Log a few meals and purchases and your vibe check appears here.', c);
    }

    final wSum = c.keys.fold<double>(0, (a, k) => a + weights[k]!);
    final score = (c.entries.fold<double>(0, (a, e) => a + e.value * weights[e.key]!) / wSum).round();
    final lowest = c.entries.reduce((a, b) => a.value <= b.value ? a : b);
    final weekStart = s.elapsedDays <= 1;

    String insight;
    if (lowest.value < 50) {
      insight = _template(lowest.key, s, p, money, pickTitle, pickProtein);
    } else if (weekStart) {
      insight = 'New week, clean slate: ${money.compact(s.weeklyBudget)} to plan with.';
    } else if (lowest.value >= 85) {
      final saved = s.savedVsOut != null && s.savedVsOut! > 0 ? ', ~${money.compact(s.savedVsOut!)} saved' : '';
      insight = "Everything's on track: ${s.completedDays} days logged$saved.";
    } else {
      insight = _template(lowest.key, s, p, money, pickTitle, pickProtein);
    }
    return VibeResult(score, labelFor(score), insight, c);
  }

  static String _template(
    String key,
    DashboardState s,
    UserProfile p,
    MoneyFormat money,
    String? pickTitle,
    double? pickProtein,
  ) {
    switch (key) {
      case 'food':
        final pct = ((s.monthPace! - 1) * 100).round();
        final meal = s.costPerMeal != null ? money.compact(s.costPerMeal!) : 'money';
        return pct > 0
            ? 'Food spend is $pct% ahead of pace. A pantry-only day saves ~$meal.'
            : 'Food spend is right on pace.';
      case 'nonfood':
        final worst = s.nonFood.where((x) => x.limitMinor > 0).fold<CategorySpend?>(
            null, (a, b) => a == null || (b.spentMinor / b.limitMinor) > (a.spentMinor / a.limitMinor) ? b : a);
        if (worst == null) return 'Other spending is running hot this month.';
        final pct = (worst.spentMinor / worst.limitMinor * 100).round();
        return '${worst.category.label} is at $pct% of its limit with ${s.daysLeftInMonth} days to go.';
      case 'protein':
        final pct = ((1 - s.avgProtein! / p.dailyProteinTargetG) * 100).round();
        if (pickTitle != null && pickProtein != null) {
          return 'Protein is $pct% under target. $pickTitle has ${pickProtein.round()} g.';
        }
        return 'Protein is $pct% under target. A prepped portion helps close the gap.';
      case 'kcal':
        final diff = ((s.avgKcal! - p.dailyKcalTarget) / p.dailyKcalTarget * 100).round();
        return diff > 0
            ? 'Averaging $diff% above your calorie target this week.'
            : 'Averaging ${-diff}% under your calorie target. Prepped portions help.';
      case 'logging':
      default:
        return "Log one meal today to keep this week's picture accurate.";
    }
  }
}
