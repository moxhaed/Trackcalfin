/// Countries and languages by name, for the first-run guess from the phone's region and for
/// the pickers. The app stores ISO codes; these are only what people read.
class Region {
  const Region._();

  /// ISO 3166 code → name and currency (ISO 4217).
  static const countries = <String, (String, String)>{
    'AE': ('United Arab Emirates', 'AED'),
    'AR': ('Argentina', 'ARS'),
    'AT': ('Austria', 'EUR'),
    'AU': ('Australia', 'AUD'),
    'BE': ('Belgium', 'EUR'),
    'BG': ('Bulgaria', 'EUR'),
    'BR': ('Brazil', 'BRL'),
    'CA': ('Canada', 'CAD'),
    'CH': ('Switzerland', 'CHF'),
    'CL': ('Chile', 'CLP'),
    'CN': ('China', 'CNY'),
    'CO': ('Colombia', 'COP'),
    'CY': ('Cyprus', 'EUR'),
    'CZ': ('Czechia', 'CZK'),
    'DE': ('Germany', 'EUR'),
    'DK': ('Denmark', 'DKK'),
    'EE': ('Estonia', 'EUR'),
    'EG': ('Egypt', 'EGP'),
    'ES': ('Spain', 'EUR'),
    'FI': ('Finland', 'EUR'),
    'FR': ('France', 'EUR'),
    'GB': ('United Kingdom', 'GBP'),
    'GR': ('Greece', 'EUR'),
    'HK': ('Hong Kong', 'HKD'),
    'HR': ('Croatia', 'EUR'),
    'HU': ('Hungary', 'HUF'),
    'ID': ('Indonesia', 'IDR'),
    'IE': ('Ireland', 'EUR'),
    'IL': ('Israel', 'ILS'),
    'IN': ('India', 'INR'),
    'IS': ('Iceland', 'ISK'),
    'IT': ('Italy', 'EUR'),
    'JP': ('Japan', 'JPY'),
    'KE': ('Kenya', 'KES'),
    'KR': ('South Korea', 'KRW'),
    'LT': ('Lithuania', 'EUR'),
    'LU': ('Luxembourg', 'EUR'),
    'LV': ('Latvia', 'EUR'),
    'MA': ('Morocco', 'MAD'),
    'MT': ('Malta', 'EUR'),
    'MX': ('Mexico', 'MXN'),
    'MY': ('Malaysia', 'MYR'),
    'NG': ('Nigeria', 'NGN'),
    'NL': ('Netherlands', 'EUR'),
    'NO': ('Norway', 'NOK'),
    'NZ': ('New Zealand', 'NZD'),
    'PE': ('Peru', 'PEN'),
    'PH': ('Philippines', 'PHP'),
    'PL': ('Poland', 'PLN'),
    'PT': ('Portugal', 'EUR'),
    'QA': ('Qatar', 'QAR'),
    'RO': ('Romania', 'RON'),
    'RS': ('Serbia', 'RSD'),
    'SA': ('Saudi Arabia', 'SAR'),
    'SE': ('Sweden', 'SEK'),
    'SG': ('Singapore', 'SGD'),
    'SI': ('Slovenia', 'EUR'),
    'SK': ('Slovakia', 'EUR'),
    'TH': ('Thailand', 'THB'),
    'TN': ('Tunisia', 'TND'),
    'TR': ('Türkiye', 'TRY'),
    'TW': ('Taiwan', 'TWD'),
    'UA': ('Ukraine', 'UAH'),
    'US': ('United States', 'USD'),
    'VN': ('Vietnam', 'VND'),
    'ZA': ('South Africa', 'ZAR'),
  };

  /// ISO 639-1 code → the language's own name, for recipes and product names.
  static const languages = <String, String>{
    'ar': 'العربية',
    'cs': 'Čeština',
    'da': 'Dansk',
    'de': 'Deutsch',
    'el': 'Ελληνικά',
    'en': 'English',
    'es': 'Español',
    'fi': 'Suomi',
    'fr': 'Français',
    'hu': 'Magyar',
    'it': 'Italiano',
    'ja': '日本語',
    'ko': '한국어',
    'nb': 'Norsk',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'pt': 'Português',
    'ro': 'Română',
    'sv': 'Svenska',
    'tr': 'Türkçe',
    'uk': 'Українська',
    'zh': '中文',
  };

  /// The currency [country] uses, when known.
  static String? currencyOf(String? country) => country == null ? null : countries[country.toUpperCase()]?.$2;

  /// "Germany", or the code itself for a country not in the list.
  static String countryName(String country) => countries[country.toUpperCase()]?.$1 ?? country.toUpperCase();

  /// "English", or the code itself for a language not in the list.
  static String languageName(String language) => languages[language.toLowerCase()] ?? language;
}
