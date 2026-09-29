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
    'produce', 'meat_fish', 'dairy_eggs', 'grains_pasta', 'legumes_nuts', 'canned_jarred', 'bakery',
    'frozen', 'spices_condiments', 'oils_fats', 'beverages', 'snacks_sweets', 'other',
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
                    'suggest_staple': {'type': 'boolean'},
                  },
                  'required': ['name', 'ingredient_category', 'unit', 'per_100', 'shelf_life_days', 'suggest_staple'],
                },
              },
              'required': [
                'raw_text', 'name', 'line_type', 'spend_category', 'total_minor', 'ingredient_key',
                'is_new_ingredient', 'qty', 'unit', 'qty_source', 'confidence', 'new_ingredient',
              ],
            },
          },
          'warnings': {
            'type': 'array',
            'items': {'type': 'string'},
          },
        },
        'required': [
          'schema_version', 'image_type', 'stock_mode', 'merchant', 'purchased_at', 'purchased_time',
          'currency', 'receipt_total_minor', 'items', 'warnings',
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
                'role': _enum(allowMissing ? ['stock', 'staple', 'missing'] : ['stock', 'staple']),
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
          'title', 'hook', 'why', 'cuisine', 'portions', 'prep_minutes', 'cook_minutes', 'active_minutes',
          'fridge_life_days', 'ingredients', 'optional_additions', 'steps', 'tags', 'estimate_per_portion',
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
          'schema_version', 'status', 'request_type', 'interpreted_request', 'summary', 'max_portions_now',
          'recipe', 'omitted', 'shopping_list',
        ],
      };
}
