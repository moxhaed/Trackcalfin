/// `responseJsonSchema` mirrors of each prompt's OUTPUT section.
///
/// Kept to a conservative JSON Schema subset. If the API rejects them,
/// GeminiClient drops the schema and relies on the prompt + Dart validation.
class AiSchemas {
  const AiSchemas._();

  static Map<String, dynamic> _nullable(String type) => {
    'type': [type, 'null'],
  };
  static Map<String, dynamic> _enum(List<String> values) => {'type': 'string', 'enum': values};

  static const _units = ['g', 'ml', 'pc'];
  static const _spend = ['groceries', 'household', 'clothes', 'eating_out', 'entertainment', 'other'];
  static const _ingCats = [
    'produce',
    'meat_fish',
    'dairy_eggs',
    'grains_pasta',
    'legumes_nuts',
    'canned_jarred',
    'bakery',
    'frozen',
    'spices_condiments',
    'oils_fats',
    'beverages',
    'snacks_sweets',
    'other',
  ];

  static Map<String, dynamic> get receipt => {
    'type': 'object',
    'properties': {
      'schema_version': {'type': 'integer'},
      'image_type': _enum(['receipt', 'pantry', 'unreadable']),
      'stock_mode': _enum(['add', 'set', 'none']),
      'merchant': _nullable('string'),
      'purchased_at': _nullable('string'),
      'purchased_time': _nullable('string'),
      'currency': {'type': 'string'},
      'receipt_total_minor': _nullable('integer'),
      'items': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'raw_text': {'type': 'string'},
            'name': {'type': 'string'},
            'line_type': _enum(['product', 'adjustment', 'deposit', 'fee']),
            'spend_category': _enum(_spend),
            'total_minor': {'type': 'integer'},
            'ingredient_key': _nullable('string'),
            'is_new_ingredient': {'type': 'boolean'},
            'qty': _nullable('number'),
            'unit': {
              'type': ['string', 'null'],
              'enum': [..._units, null],
            },
            'qty_source': _enum(['printed', 'inferred', 'estimated', 'unknown']),
            'confidence': _enum(['high', 'medium', 'low']),
            'product': _nullable('string'),
            'shelf_price': {
              'type': ['object', 'null'],
              'properties': {
                'package_qty': {'type': 'number'},
                'price_minor': {'type': 'integer'},
              },
              'required': ['package_qty', 'price_minor'],
            },
            'new_ingredient': {
              'type': ['object', 'null'],
              'properties': {
                'name': {'type': 'string'},
                'ingredient_category': _enum(_ingCats),
                'unit': _enum(_units),
                'grams_per_piece': _nullable('number'),
                'density_g_per_ml': _nullable('number'),
                'per_100': {
                  'type': 'object',
                  'properties': {
                    'kcal': {'type': 'number'},
                    'protein_g': {'type': 'number'},
                    'carbs_g': {'type': 'number'},
                    'fat_g': {'type': 'number'},
                    'fiber_g': {'type': 'number'},
                  },
                  'required': ['kcal', 'protein_g', 'carbs_g', 'fat_g', 'fiber_g'],
                },
                'shelf_life_days': {'type': 'integer'},
              },
              'required': ['name', 'ingredient_category', 'unit', 'per_100', 'shelf_life_days'],
            },
          },
          'required': [
            'raw_text',
            'name',
            'line_type',
            'spend_category',
            'total_minor',
            'ingredient_key',
            'is_new_ingredient',
            'qty',
            'unit',
            'qty_source',
            'confidence',
            'product',
            'shelf_price',
            'new_ingredient',
          ],
        },
      },
      'warnings': {
        'type': 'array',
        'items': {'type': 'string'},
      },
    },
    'required': [
      'schema_version',
      'image_type',
      'stock_mode',
      'merchant',
      'purchased_at',
      'purchased_time',
      'currency',
      'receipt_total_minor',
      'items',
      'warnings',
    ],
  };

  static Map<String, dynamic> get _newIngredient => {
    'type': ['object', 'null'],
    'properties': {
      'name': {'type': 'string'},
      'ingredient_category': _enum(_ingCats),
      'unit': _enum(_units),
      'grams_per_piece': _nullable('number'),
      'density_g_per_ml': _nullable('number'),
      'per_100': {
        'type': 'object',
        'properties': {
          'kcal': {'type': 'number'},
          'protein_g': {'type': 'number'},
          'carbs_g': {'type': 'number'},
          'fat_g': {'type': 'number'},
          'fiber_g': {'type': 'number'},
        },
        'required': ['kcal', 'protein_g', 'carbs_g', 'fat_g', 'fiber_g'],
      },
      'shelf_life_days': {'type': 'integer'},
    },
    'required': ['name', 'ingredient_category', 'unit', 'per_100', 'shelf_life_days'],
  };

  /// Prompt G: what the user said they did, as actions.
  static Map<String, dynamic> get quickLog => {
    'type': 'object',
    'properties': {
      'schema_version': {'type': 'integer'},
      'actions': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'type': _enum(['buy', 'expense', 'eat', 'cook', 'throw_away', 'count', 'price_check']),
            'when': _nullable('string'),
            'source': {
              'type': ['string', 'null'],
              'enum': ['fridge', 'pantry', 'out', null],
            },
            'key': _nullable('string'),
            'name': _nullable('string'),
            'qty': _nullable('number'),
            'unit': {
              'type': ['string', 'null'],
              'enum': [..._units, null],
            },
            'batch_id': _nullable('integer'),
            'recipe_id': _nullable('integer'),
            'portions': _nullable('number'),
            'ate_portions': _nullable('integer'),
            'paid_minor': _nullable('integer'),
            'est_price_minor': _nullable('integer'),
            'category': {
              'type': ['string', 'null'],
              'enum': [..._spend.where((c) => c != 'groceries'), null],
            },
            'merchant': _nullable('string'),
            'nutrition': {
              'type': ['object', 'null'],
              'properties': {
                'kcal': {'type': 'number'},
                'protein_g': {'type': 'number'},
                'carbs_g': {'type': 'number'},
                'fat_g': {'type': 'number'},
              },
              'required': ['kcal', 'protein_g', 'carbs_g', 'fat_g'],
            },
            'new_ingredient': _newIngredient,
          },
          'required': [
            'type',
            'when',
            'source',
            'key',
            'name',
            'qty',
            'unit',
            'batch_id',
            'recipe_id',
            'portions',
            'ate_portions',
            'paid_minor',
            'est_price_minor',
            'category',
            'merchant',
            'nutrition',
            'new_ingredient',
          ],
        },
      },
      'total_paid_minor': _nullable('integer'),
      'question': _nullable('string'),
    },
    'required': ['schema_version', 'actions', 'total_paid_minor', 'question'],
  };

  static Map<String, dynamic> get nutritionEstimate => {
    'type': 'object',
    'properties': {
      'schema_version': {'type': 'integer'},
      'items': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'key': {'type': 'string'},
            'per_100g': {
              'type': 'object',
              'properties': {
                'kcal': {'type': 'number'},
                'protein_g': {'type': 'number'},
                'carbs_g': {'type': 'number'},
                'fat_g': {'type': 'number'},
                'fiber_g': {'type': 'number'},
              },
              'required': ['kcal', 'protein_g', 'carbs_g', 'fat_g', 'fiber_g'],
            },
            'density_g_per_ml': _nullable('number'),
            'grams_per_piece': _nullable('number'),
          },
          'required': ['key', 'per_100g', 'density_g_per_ml', 'grams_per_piece'],
        },
      },
    },
    'required': ['schema_version', 'items'],
  };

  static Map<String, dynamic> get nutritionLabel => {
    'type': 'object',
    'properties': {
      'schema_version': {'type': 'integer'},
      'image_type': _enum(['label', 'unreadable']),
      'product_name': _nullable('string'),
      'basis': {
        'type': ['string', 'null'],
        'enum': ['per_100g', 'per_100ml', 'per_serving', null],
      },
      'serving_size_g': _nullable('number'),
      'serving_size_ml': _nullable('number'),
      'energy_kcal': _nullable('number'),
      'energy_kj': _nullable('number'),
      'protein_g': _nullable('number'),
      'carbs_g': _nullable('number'),
      'fat_g': _nullable('number'),
      'fiber_g': _nullable('number'),
      'carbs_include_fiber': {'type': 'boolean'},
      'warnings': {
        'type': 'array',
        'items': {'type': 'string'},
      },
    },
    'required': [
      'schema_version',
      'image_type',
      'product_name',
      'basis',
      'serving_size_g',
      'serving_size_ml',
      'energy_kcal',
      'energy_kj',
      'protein_g',
      'carbs_g',
      'fat_g',
      'fiber_g',
      'carbs_include_fiber',
      'warnings',
    ],
  };

  static Map<String, dynamic> _recipe({required bool allowMissing}) => {
    'type': 'object',
    'properties': {
      'title': {'type': 'string'},
      'hook': {'type': 'string'},
      'why': {'type': 'string'},
      'cuisine': {'type': 'string'},
      'portions': {'type': 'integer'},
      'prep_minutes': {'type': 'integer'},
      'cook_minutes': {'type': 'integer'},
      'active_minutes': {'type': 'integer'},
      'fridge_life_days': {'type': 'integer'},
      'ingredients': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'key': _nullable('string'),
            'name': {'type': 'string'},
            'qty_per_portion': {'type': 'number'},
            'unit': _enum(_units),
            'role': _enum(allowMissing ? ['stock', 'missing'] : ['stock']),
            'prep_note': _nullable('string'),
            'substitutes_for': _nullable('string'),
            'missing_est': {
              'type': ['object', 'null'],
              'properties': {
                'cost_minor_per_portion': {'type': 'integer'},
                'kcal_per_portion': {'type': 'number'},
                'protein_g_per_portion': {'type': 'number'},
                'carbs_g_per_portion': {'type': 'number'},
                'fat_g_per_portion': {'type': 'number'},
              },
            },
          },
          'required': ['key', 'name', 'qty_per_portion', 'unit', 'role', 'prep_note', 'substitutes_for', 'missing_est'],
        },
      },
      'optional_additions': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'why': {'type': 'string'},
            'est_cost_minor': {'type': 'integer'},
          },
          'required': ['name', 'why', 'est_cost_minor'],
        },
      },
      'steps': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'tags': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'estimate_per_portion': {
        'type': 'object',
        'properties': {
          'kcal': {'type': 'number'},
          'protein_g': {'type': 'number'},
          'carbs_g': {'type': 'number'},
          'fat_g': {'type': 'number'},
          'fiber_g': {'type': 'number'},
          'cost_minor': {'type': 'integer'},
        },
        'required': ['kcal', 'protein_g', 'carbs_g', 'fat_g', 'fiber_g', 'cost_minor'],
      },
      'tradeoffs': _nullable('string'),
    },
    'required': [
      'title',
      'hook',
      'why',
      'cuisine',
      'portions',
      'prep_minutes',
      'cook_minutes',
      'active_minutes',
      'fridge_life_days',
      'ingredients',
      'optional_additions',
      'steps',
      'tags',
      'estimate_per_portion',
      'tradeoffs',
    ],
  };

  static Map<String, dynamic> get daily => {
    'type': 'object',
    'properties': {
      'schema_version': {'type': 'integer'},
      'status': _enum(['ok', 'insufficient_stock']),
      'recipe': {
        ..._recipe(allowMissing: false),
        'type': ['object', 'null'],
      },
      'shopping_suggestions': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'why': {'type': 'string'},
            'est_cost_minor': {'type': 'integer'},
          },
          'required': ['name', 'why', 'est_cost_minor'],
        },
      },
    },
    'required': ['schema_version', 'status', 'recipe', 'shopping_suggestions'],
  };

  static Map<String, dynamic> get spontaneous => {
    'type': 'object',
    'properties': {
      'schema_version': {'type': 'integer'},
      'status': _enum(['ready', 'ready_with_swaps', 'missing_items', 'not_a_recipe']),
      'request_type': _enum(['dish', 'ingredient_led', 'not_a_recipe']),
      'interpreted_request': {'type': 'string'},
      'summary': {'type': 'string'},
      'max_portions_now': {'type': 'integer'},
      'recipe': {
        ..._recipe(allowMissing: true),
        'type': ['object', 'null'],
      },
      'omitted': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'shopping_list': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'package_desc': {'type': 'string'},
            'est_package_cost_minor': {'type': 'integer'},
            'reason': _enum(['missing', 'short']),
          },
          'required': ['name', 'package_desc', 'est_package_cost_minor', 'reason'],
        },
      },
    },
    'required': [
      'schema_version',
      'status',
      'request_type',
      'interpreted_request',
      'summary',
      'max_portions_now',
      'recipe',
      'omitted',
      'shopping_list',
    ],
  };

  /// Prompt H, first pass: the recipes in a PDF cookbook and their pages.
  static Map<String, dynamic> get cookbookIndex => {
    'type': 'object',
    'properties': {
      'schema_version': {'type': 'integer'},
      'is_cookbook': {'type': 'boolean'},
      'book_title': _nullable('string'),
      'page_count': _nullable('integer'),
      'recipes': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'title': {'type': 'string'},
            'page': _nullable('integer'),
          },
          'required': ['title', 'page'],
        },
      },
      'next_page': _nullable('integer'),
    },
    'required': ['schema_version', 'is_cookbook', 'book_title', 'page_count', 'recipes', 'next_page'],
  };

  /// Prompt H, later passes: a few recipes read in full, amounts for the whole recipe.
  static Map<String, dynamic> get cookbookRecipes => {
    'type': 'object',
    'properties': {
      'schema_version': {'type': 'integer'},
      'recipes': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'id': {'type': 'integer'},
            'found': {'type': 'boolean'},
            'title': {'type': 'string'},
            'page': _nullable('integer'),
            'servings': _nullable('integer'),
            'prep_minutes': _nullable('integer'),
            'cook_minutes': _nullable('integer'),
            'ingredients': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'as_written': {'type': 'string'},
                  'name': {'type': 'string'},
                  'key': {'type': 'string'},
                  'qty': {'type': 'number'},
                  'unit': _enum(_units),
                  'optional': {'type': 'boolean'},
                },
                'required': ['as_written', 'name', 'key', 'qty', 'unit', 'optional'],
              },
            },
            'steps': {
              'type': 'array',
              'items': {'type': 'string'},
            },
            'tags': {
              'type': 'array',
              'items': {'type': 'string'},
            },
          },
          'required': [
            'id',
            'found',
            'title',
            'page',
            'servings',
            'prep_minutes',
            'cook_minutes',
            'ingredients',
            'steps',
            'tags',
          ],
        },
      },
    },
    'required': ['schema_version', 'recipes'],
  };
}
