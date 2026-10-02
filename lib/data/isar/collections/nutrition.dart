import 'package:isar_community/isar.dart';

part 'nutrition.g.dart';

/// Macro nutrients. Per 100 g/ml on [Ingredient.per100], absolute elsewhere.
@embedded
class Nutrition {
  Nutrition({this.kcal = 0, this.proteinG = 0, this.carbsG = 0, this.fatG = 0, this.fiberG = 0});

  double kcal;
  double proteinG;
  double carbsG;
  double fatG;
  double fiberG;

  Nutrition operator +(Nutrition o) => Nutrition(
    kcal: kcal + o.kcal,
    proteinG: proteinG + o.proteinG,
    carbsG: carbsG + o.carbsG,
    fatG: fatG + o.fatG,
    fiberG: fiberG + o.fiberG,
  );

  Nutrition scale(double f) =>
      Nutrition(kcal: kcal * f, proteinG: proteinG * f, carbsG: carbsG * f, fatG: fatG * f, fiberG: fiberG * f);

  Nutrition copy() => scale(1);

  @ignore
  bool get isZero => kcal == 0 && proteinG == 0 && carbsG == 0 && fatG == 0 && fiberG == 0;

  /// Rounded to one decimal, as shown and stored after a conversion.
  Nutrition rounded() {
    double r(double v) => (v * 10).round() / 10;
    return Nutrition(kcal: r(kcal), proteinG: r(proteinG), carbsG: r(carbsG), fatG: r(fatG), fiberG: r(fiberG));
  }

  bool sameAs(Nutrition o) =>
      kcal == o.kcal && proteinG == o.proteinG && carbsG == o.carbsG && fatG == o.fatG && fiberG == o.fiberG;

  static Nutrition sum(Iterable<Nutrition> items) => items.fold(Nutrition(), (a, b) => a + b);
}
