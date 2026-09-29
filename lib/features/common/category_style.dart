import 'package:flutter/material.dart';

import '../../core/enums.dart';

IconData categoryIcon(SpendCategory c) => switch (c) {
  SpendCategory.groceries => Icons.shopping_basket_outlined,
  SpendCategory.household => Icons.cleaning_services_outlined,
  SpendCategory.clothes => Icons.checkroom_outlined,
  SpendCategory.eatingOut => Icons.restaurant_outlined,
  SpendCategory.entertainment => Icons.local_activity_outlined,
  SpendCategory.other => Icons.more_horiz,
};

IconData ingredientIcon(IngredientCategory c) => switch (c) {
  IngredientCategory.produce => Icons.eco_outlined,
  IngredientCategory.meatFish => Icons.set_meal_outlined,
  IngredientCategory.dairyEggs => Icons.egg_outlined,
  IngredientCategory.grainsPasta => Icons.rice_bowl_outlined,
  IngredientCategory.legumesNuts => Icons.grain,
  IngredientCategory.cannedJarred => Icons.inventory_2_outlined,
  IngredientCategory.bakery => Icons.bakery_dining_outlined,
  IngredientCategory.frozen => Icons.ac_unit,
  IngredientCategory.spicesCondiments => Icons.local_fire_department_outlined,
  IngredientCategory.oilsFats => Icons.water_drop_outlined,
  IngredientCategory.beverages => Icons.local_drink_outlined,
  IngredientCategory.snacksSweets => Icons.cookie_outlined,
  IngredientCategory.other => Icons.category_outlined,
};
