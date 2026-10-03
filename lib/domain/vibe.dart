import '../core/enums.dart';
import '../core/money.dart';
import '../data/isar/collections/user_profile.dart';
import 'dashboard.dart';

/// How things are going, as the dashboard's status circle shows it: a color, an icon and a word.
enum VibeLevel { none, good, watch, off }

class VibeResult {
  VibeResult(this.score, this.label, this.insight, this.components);

  /// 0..100, or null while there's nothing to judge yet. Never shown: only its [level] is.
  final int? score;

  /// "On track", "Slipping", "Off track", or "Getting started".
  final String label;

  /// One line on what matters most right now.
  final String insight;
  final Map<String, double> components;

  VibeLevel get level => VibeScorer.levelFor(score);
}

/// Budget pace, other spending, protein, calories and logging, weighed into one status
/// (on track, slipping, off track) with one actionable line. Pure Dart.
class VibeScorer {
  const VibeScorer._();

  static const weights = {'food': 0.30, 'nonfood': 0.15, 'protein': 0.20, 'kcal': 0.15, 'logging': 0.20};

  static double paceScore(double pace) => 100 - ((pace - 1) * 200).clamp(0, 100);

  static double kcalScore(double avg, double target) {
    final d = (avg - target).abs() / target;
    return 100 - ((d - 0.05) * 400).clamp(0, 100);
  }

  static VibeLevel levelFor(num? score) => score == null
      ? VibeLevel.none
      : score >= 70
      ? VibeLevel.good
      : score >= 50
      ? VibeLevel.watch
      : VibeLevel.off;

  static String labelFor(int score) => switch (levelFor(score)) {
    VibeLevel.good => 'On track',
    VibeLevel.watch => 'Slipping',
    VibeLevel.off => 'Off track',
    VibeLevel.none => 'Getting started',
  };

  static VibeResult score(
    DashboardState s,
    UserProfile p,
    MoneyFormat money, {
    String? pickTitle,
    double? pickProtein,
  }) {
    final c = <String, double>{};
    // The food budget is judged the way the user reads it: by what was eaten or what was spent.
    if (s.monthlyBudget > 0 && s.food.monthPace != null && !s.food.collecting) {
      c['food'] = paceScore(s.food.monthPace!);
    }
    if (s.nonFoodLimit > 0) {
      // Only categories with a limit: spending where no goal is set isn't over anything.
      final spent = s.nonFood.where((c) => c.limitMinor > 0).fold(0, (a, c) => a + c.spentMinor);
      final pace = spent / (s.nonFoodLimit * (s.monthElapsedFraction < paceFloor ? paceFloor : s.monthElapsedFraction));
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
      return VibeResult(
        null,
        'Getting started',
        'Log a few meals and purchases, and how things are going shows here.',
        c,
      );
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
      final saved = s.savedVsOut != null && s.savedVsOut! > 0
          ? ', ~${money.compact(s.savedVsOut!)} saved vs eating out'
          : '';
      insight = '${s.completedDays} ${s.completedDays == 1 ? 'day' : 'days'} logged this week$saved.';
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
        final pct = ((s.food.monthPace! - 1) * 100).round();
        final meal = s.costPerMeal != null ? money.compact(s.costPerMeal!) : 'money';
        if (s.basis == FoodBasis.eaten) {
          // Eating from the pantry still counts as eaten: what helps is cheaper meals.
          return pct > 0
              ? "You're eating $pct% ahead of the food budget's pace, ~$meal a meal. Cheaper picks bring it down."
              : 'What you eat is right on pace with the food budget.';
        }
        return pct > 0
            ? 'Food spend is $pct% ahead of pace. A pantry-only day saves ~$meal.'
            : 'Food spend is right on pace.';
      case 'nonfood':
        final worst = s.nonFood
            .where((x) => x.limitMinor > 0)
            .fold<CategorySpend?>(
              null,
              (a, b) => a == null || (b.spentMinor / b.limitMinor) > (a.spentMinor / a.limitMinor) ? b : a,
            );
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
