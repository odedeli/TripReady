/// ISO 3166-1 country list with multi-language support.
///
/// Adding a new language:
///   1. Add a nullable field to [Country] (e.g. `final String? nameFr`)
///   2. Populate it in [kCountries]
///   3. Add a case in [Country.localizedName]
///
/// Currently supported: English (en), Hebrew (he)
class Country {
  final String name;       // English — canonical / fallback
  final String? nameHe;   // Hebrew
  final String code;       // ISO 3166-1 alpha-2
  final String flag;       // emoji flag

  const Country({
    required this.name,
    required this.code,
    required this.flag,
    this.nameHe,
  });

  /// Returns the country name in [languageCode], falling back to English.
  String localizedName(String languageCode) {
    switch (languageCode) {
      case 'he': return nameHe ?? name;
      // Add future languages here:
      // case 'fr': return nameFr ?? name;
      // case 'ar': return nameAr ?? name;
      default:   return name;
    }
  }

  /// Display string for the picker row in a given locale.
  String localizedDisplay(String languageCode) =>
      localizedName(languageCode);

  /// English display — used as fallback
  String get display => name;

  @override
  String toString() => name;
}

const List<Country> kCountries = [
  Country(name: 'Afghanistan',              code: 'AF', flag: '🇦🇫', nameHe: 'אפגניסטן'),
  Country(name: 'Albania',                  code: 'AL', flag: '🇦🇱', nameHe: 'אלבניה'),
  Country(name: 'Algeria',                  code: 'DZ', flag: '🇩🇿', nameHe: 'אלג\'יריה'),
  Country(name: 'Andorra',                  code: 'AD', flag: '🇦🇩', nameHe: 'אנדורה'),
  Country(name: 'Angola',                   code: 'AO', flag: '🇦🇴', nameHe: 'אנגולה'),
  Country(name: 'Argentina',                code: 'AR', flag: '🇦🇷', nameHe: 'ארגנטינה'),
  Country(name: 'Armenia',                  code: 'AM', flag: '🇦🇲', nameHe: 'ארמניה'),
  Country(name: 'Australia',                code: 'AU', flag: '🇦🇺', nameHe: 'אוסטרליה'),
  Country(name: 'Austria',                  code: 'AT', flag: '🇦🇹', nameHe: 'אוסטריה'),
  Country(name: 'Azerbaijan',               code: 'AZ', flag: '🇦🇿', nameHe: 'אזרבייג\'ן'),
  Country(name: 'Bahamas',                  code: 'BS', flag: '🇧🇸', nameHe: 'איי בהאמה'),
  Country(name: 'Bahrain',                  code: 'BH', flag: '🇧🇭', nameHe: 'בחריין'),
  Country(name: 'Bangladesh',               code: 'BD', flag: '🇧🇩', nameHe: 'בנגלדש'),
  Country(name: 'Belarus',                  code: 'BY', flag: '🇧🇾', nameHe: 'בלארוס'),
  Country(name: 'Belgium',                  code: 'BE', flag: '🇧🇪', nameHe: 'בלגיה'),
  Country(name: 'Belize',                   code: 'BZ', flag: '🇧🇿', nameHe: 'בליז'),
  Country(name: 'Benin',                    code: 'BJ', flag: '🇧🇯', nameHe: 'בנין'),
  Country(name: 'Bhutan',                   code: 'BT', flag: '🇧🇹', nameHe: 'בהוטן'),
  Country(name: 'Bolivia',                  code: 'BO', flag: '🇧🇴', nameHe: 'בוליביה'),
  Country(name: 'Bosnia and Herzegovina',   code: 'BA', flag: '🇧🇦', nameHe: 'בוסניה והרצגובינה'),
  Country(name: 'Botswana',                 code: 'BW', flag: '🇧🇼', nameHe: 'בוצוואנה'),
  Country(name: 'Brazil',                   code: 'BR', flag: '🇧🇷', nameHe: 'ברזיל'),
  Country(name: 'Brunei',                   code: 'BN', flag: '🇧🇳', nameHe: 'ברוניי'),
  Country(name: 'Bulgaria',                 code: 'BG', flag: '🇧🇬', nameHe: 'בולגריה'),
  Country(name: 'Burkina Faso',             code: 'BF', flag: '🇧🇫', nameHe: 'בורקינה פאסו'),
  Country(name: 'Burundi',                  code: 'BI', flag: '🇧🇮', nameHe: 'בורונדי'),
  Country(name: 'Cambodia',                 code: 'KH', flag: '🇰🇭', nameHe: 'קמבודיה'),
  Country(name: 'Cameroon',                 code: 'CM', flag: '🇨🇲', nameHe: 'קמרון'),
  Country(name: 'Canada',                   code: 'CA', flag: '🇨🇦', nameHe: 'קנדה'),
  Country(name: 'Cape Verde',               code: 'CV', flag: '🇨🇻', nameHe: 'כף ורדה'),
  Country(name: 'Central African Republic', code: 'CF', flag: '🇨🇫', nameHe: 'הרפובליקה המרכז-אפריקאית'),
  Country(name: 'Chad',                     code: 'TD', flag: '🇹🇩', nameHe: 'צ\'אד'),
  Country(name: 'Chile',                    code: 'CL', flag: '🇨🇱', nameHe: 'צ\'ילה'),
  Country(name: 'China',                    code: 'CN', flag: '🇨🇳', nameHe: 'סין'),
  Country(name: 'Colombia',                 code: 'CO', flag: '🇨🇴', nameHe: 'קולומביה'),
  Country(name: 'Comoros',                  code: 'KM', flag: '🇰🇲', nameHe: 'קומורו'),
  Country(name: 'Congo',                    code: 'CG', flag: '🇨🇬', nameHe: 'קונגו'),
  Country(name: 'Costa Rica',               code: 'CR', flag: '🇨🇷', nameHe: 'קוסטה ריקה'),
  Country(name: 'Croatia',                  code: 'HR', flag: '🇭🇷', nameHe: 'קרואטיה'),
  Country(name: 'Cuba',                     code: 'CU', flag: '🇨🇺', nameHe: 'קובה'),
  Country(name: 'Cyprus',                   code: 'CY', flag: '🇨🇾', nameHe: 'קפריסין'),
  Country(name: 'Czech Republic',           code: 'CZ', flag: '🇨🇿', nameHe: 'צ\'כיה'),
  Country(name: 'Denmark',                  code: 'DK', flag: '🇩🇰', nameHe: 'דנמרק'),
  Country(name: 'Djibouti',                 code: 'DJ', flag: '🇩🇯', nameHe: 'ג\'יבוטי'),
  Country(name: 'Dominican Republic',       code: 'DO', flag: '🇩🇴', nameHe: 'הרפובליקה הדומיניקנית'),
  Country(name: 'DR Congo',                 code: 'CD', flag: '🇨🇩', nameHe: 'קונגו הדמוקרטית'),
  Country(name: 'Ecuador',                  code: 'EC', flag: '🇪🇨', nameHe: 'אקוודור'),
  Country(name: 'Egypt',                    code: 'EG', flag: '🇪🇬', nameHe: 'מצרים'),
  Country(name: 'El Salvador',              code: 'SV', flag: '🇸🇻', nameHe: 'אל סלבדור'),
  Country(name: 'Equatorial Guinea',        code: 'GQ', flag: '🇬🇶', nameHe: 'גינאה המשוונית'),
  Country(name: 'Eritrea',                  code: 'ER', flag: '🇪🇷', nameHe: 'אריתריאה'),
  Country(name: 'Estonia',                  code: 'EE', flag: '🇪🇪', nameHe: 'אסטוניה'),
  Country(name: 'Eswatini',                 code: 'SZ', flag: '🇸🇿', nameHe: 'אסווטיני'),
  Country(name: 'Ethiopia',                 code: 'ET', flag: '🇪🇹', nameHe: 'אתיופיה'),
  Country(name: 'Fiji',                     code: 'FJ', flag: '🇫🇯', nameHe: 'פיג\'י'),
  Country(name: 'Finland',                  code: 'FI', flag: '🇫🇮', nameHe: 'פינלנד'),
  Country(name: 'France',                   code: 'FR', flag: '🇫🇷', nameHe: 'צרפת'),
  Country(name: 'Gabon',                    code: 'GA', flag: '🇬🇦', nameHe: 'גבון'),
  Country(name: 'Gambia',                   code: 'GM', flag: '🇬🇲', nameHe: 'גמביה'),
  Country(name: 'Georgia',                  code: 'GE', flag: '🇬🇪', nameHe: 'גאורגיה'),
  Country(name: 'Germany',                  code: 'DE', flag: '🇩🇪', nameHe: 'גרמניה'),
  Country(name: 'Ghana',                    code: 'GH', flag: '🇬🇭', nameHe: 'גאנה'),
  Country(name: 'Greece',                   code: 'GR', flag: '🇬🇷', nameHe: 'יוון'),
  Country(name: 'Guatemala',                code: 'GT', flag: '🇬🇹', nameHe: 'גואטמלה'),
  Country(name: 'Guinea',                   code: 'GN', flag: '🇬🇳', nameHe: 'גינאה'),
  Country(name: 'Guinea-Bissau',            code: 'GW', flag: '🇬🇼', nameHe: 'גינאה-ביסאו'),
  Country(name: 'Guyana',                   code: 'GY', flag: '🇬🇾', nameHe: 'גויאנה'),
  Country(name: 'Haiti',                    code: 'HT', flag: '🇭🇹', nameHe: 'האיטי'),
  Country(name: 'Honduras',                 code: 'HN', flag: '🇭🇳', nameHe: 'הונדורס'),
  Country(name: 'Hungary',                  code: 'HU', flag: '🇭🇺', nameHe: 'הונגריה'),
  Country(name: 'Iceland',                  code: 'IS', flag: '🇮🇸', nameHe: 'איסלנד'),
  Country(name: 'India',                    code: 'IN', flag: '🇮🇳', nameHe: 'הודו'),
  Country(name: 'Indonesia',                code: 'ID', flag: '🇮🇩', nameHe: 'אינדונזיה'),
  Country(name: 'Iran',                     code: 'IR', flag: '🇮🇷', nameHe: 'איראן'),
  Country(name: 'Iraq',                     code: 'IQ', flag: '🇮🇶', nameHe: 'עיראק'),
  Country(name: 'Ireland',                  code: 'IE', flag: '🇮🇪', nameHe: 'אירלנד'),
  Country(name: 'Israel',                   code: 'IL', flag: '🇮🇱', nameHe: 'ישראל'),
  Country(name: 'Italy',                    code: 'IT', flag: '🇮🇹', nameHe: 'איטליה'),
  Country(name: 'Ivory Coast',              code: 'CI', flag: '🇨🇮', nameHe: 'חוף השנהב'),
  Country(name: 'Jamaica',                  code: 'JM', flag: '🇯🇲', nameHe: 'ג\'מייקה'),
  Country(name: 'Japan',                    code: 'JP', flag: '🇯🇵', nameHe: 'יפן'),
  Country(name: 'Jordan',                   code: 'JO', flag: '🇯🇴', nameHe: 'ירדן'),
  Country(name: 'Kazakhstan',               code: 'KZ', flag: '🇰🇿', nameHe: 'קזחסטן'),
  Country(name: 'Kenya',                    code: 'KE', flag: '🇰🇪', nameHe: 'קניה'),
  Country(name: 'Kuwait',                   code: 'KW', flag: '🇰🇼', nameHe: 'כווית'),
  Country(name: 'Kyrgyzstan',               code: 'KG', flag: '🇰🇬', nameHe: 'קירגיזסטן'),
  Country(name: 'Laos',                     code: 'LA', flag: '🇱🇦', nameHe: 'לאוס'),
  Country(name: 'Latvia',                   code: 'LV', flag: '🇱🇻', nameHe: 'לטביה'),
  Country(name: 'Lebanon',                  code: 'LB', flag: '🇱🇧', nameHe: 'לבנון'),
  Country(name: 'Lesotho',                  code: 'LS', flag: '🇱🇸', nameHe: 'לסוטו'),
  Country(name: 'Liberia',                  code: 'LR', flag: '🇱🇷', nameHe: 'ליבריה'),
  Country(name: 'Libya',                    code: 'LY', flag: '🇱🇾', nameHe: 'לוב'),
  Country(name: 'Liechtenstein',            code: 'LI', flag: '🇱🇮', nameHe: 'ליכטנשטיין'),
  Country(name: 'Lithuania',                code: 'LT', flag: '🇱🇹', nameHe: 'ליטא'),
  Country(name: 'Luxembourg',               code: 'LU', flag: '🇱🇺', nameHe: 'לוקסמבורג'),
  Country(name: 'Madagascar',               code: 'MG', flag: '🇲🇬', nameHe: 'מדגסקר'),
  Country(name: 'Malawi',                   code: 'MW', flag: '🇲🇼', nameHe: 'מלאווי'),
  Country(name: 'Malaysia',                 code: 'MY', flag: '🇲🇾', nameHe: 'מלזיה'),
  Country(name: 'Maldives',                 code: 'MV', flag: '🇲🇻', nameHe: 'האיים המלדיביים'),
  Country(name: 'Mali',                     code: 'ML', flag: '🇲🇱', nameHe: 'מאלי'),
  Country(name: 'Malta',                    code: 'MT', flag: '🇲🇹', nameHe: 'מלטה'),
  Country(name: 'Mauritania',               code: 'MR', flag: '🇲🇷', nameHe: 'מאוריטניה'),
  Country(name: 'Mauritius',                code: 'MU', flag: '🇲🇺', nameHe: 'מאוריציוס'),
  Country(name: 'Mexico',                   code: 'MX', flag: '🇲🇽', nameHe: 'מקסיקו'),
  Country(name: 'Moldova',                  code: 'MD', flag: '🇲🇩', nameHe: 'מולדובה'),
  Country(name: 'Monaco',                   code: 'MC', flag: '🇲🇨', nameHe: 'מונקו'),
  Country(name: 'Mongolia',                 code: 'MN', flag: '🇲🇳', nameHe: 'מונגוליה'),
  Country(name: 'Montenegro',               code: 'ME', flag: '🇲🇪', nameHe: 'מונטנגרו'),
  Country(name: 'Morocco',                  code: 'MA', flag: '🇲🇦', nameHe: 'מרוקו'),
  Country(name: 'Mozambique',               code: 'MZ', flag: '🇲🇿', nameHe: 'מוזמביק'),
  Country(name: 'Myanmar',                  code: 'MM', flag: '🇲🇲', nameHe: 'מיאנמר'),
  Country(name: 'Namibia',                  code: 'NA', flag: '🇳🇦', nameHe: 'נמיביה'),
  Country(name: 'Nepal',                    code: 'NP', flag: '🇳🇵', nameHe: 'נפאל'),
  Country(name: 'Netherlands',              code: 'NL', flag: '🇳🇱', nameHe: 'הולנד'),
  Country(name: 'New Zealand',              code: 'NZ', flag: '🇳🇿', nameHe: 'ניו זילנד'),
  Country(name: 'Nicaragua',                code: 'NI', flag: '🇳🇮', nameHe: 'ניקרגואה'),
  Country(name: 'Niger',                    code: 'NE', flag: '🇳🇪', nameHe: 'ניז\'ר'),
  Country(name: 'Nigeria',                  code: 'NG', flag: '🇳🇬', nameHe: 'ניגריה'),
  Country(name: 'North Korea',              code: 'KP', flag: '🇰🇵', nameHe: 'קוריאה הצפונית'),
  Country(name: 'North Macedonia',          code: 'MK', flag: '🇲🇰', nameHe: 'מקדוניה הצפונית'),
  Country(name: 'Norway',                   code: 'NO', flag: '🇳🇴', nameHe: 'נורווגיה'),
  Country(name: 'Oman',                     code: 'OM', flag: '🇴🇲', nameHe: 'עומאן'),
  Country(name: 'Pakistan',                 code: 'PK', flag: '🇵🇰', nameHe: 'פקיסטן'),
  Country(name: 'Palestine',                code: 'PS', flag: '🇵🇸', nameHe: 'פלסטין'),
  Country(name: 'Panama',                   code: 'PA', flag: '🇵🇦', nameHe: 'פנמה'),
  Country(name: 'Papua New Guinea',         code: 'PG', flag: '🇵🇬', nameHe: 'פפואה גינאה החדשה'),
  Country(name: 'Paraguay',                 code: 'PY', flag: '🇵🇾', nameHe: 'פרגוואי'),
  Country(name: 'Peru',                     code: 'PE', flag: '🇵🇪', nameHe: 'פרו'),
  Country(name: 'Philippines',              code: 'PH', flag: '🇵🇭', nameHe: 'הפיליפינים'),
  Country(name: 'Poland',                   code: 'PL', flag: '🇵🇱', nameHe: 'פולין'),
  Country(name: 'Portugal',                 code: 'PT', flag: '🇵🇹', nameHe: 'פורטוגל'),
  Country(name: 'Qatar',                    code: 'QA', flag: '🇶🇦', nameHe: 'קטר'),
  Country(name: 'Romania',                  code: 'RO', flag: '🇷🇴', nameHe: 'רומניה'),
  Country(name: 'Russia',                   code: 'RU', flag: '🇷🇺', nameHe: 'רוסיה'),
  Country(name: 'Rwanda',                   code: 'RW', flag: '🇷🇼', nameHe: 'רואנדה'),
  Country(name: 'Saudi Arabia',             code: 'SA', flag: '🇸🇦', nameHe: 'ערב הסעודית'),
  Country(name: 'Senegal',                  code: 'SN', flag: '🇸🇳', nameHe: 'סנגל'),
  Country(name: 'Serbia',                   code: 'RS', flag: '🇷🇸', nameHe: 'סרביה'),
  Country(name: 'Sierra Leone',             code: 'SL', flag: '🇸🇱', nameHe: 'סיירה לאונה'),
  Country(name: 'Singapore',                code: 'SG', flag: '🇸🇬', nameHe: 'סינגפור'),
  Country(name: 'Slovakia',                 code: 'SK', flag: '🇸🇰', nameHe: 'סלובקיה'),
  Country(name: 'Slovenia',                 code: 'SI', flag: '🇸🇮', nameHe: 'סלובניה'),
  Country(name: 'Somalia',                  code: 'SO', flag: '🇸🇴', nameHe: 'סומליה'),
  Country(name: 'South Africa',             code: 'ZA', flag: '🇿🇦', nameHe: 'דרום אפריקה'),
  Country(name: 'South Korea',              code: 'KR', flag: '🇰🇷', nameHe: 'קוריאה הדרומית'),
  Country(name: 'South Sudan',              code: 'SS', flag: '🇸🇸', nameHe: 'דרום סודן'),
  Country(name: 'Spain',                    code: 'ES', flag: '🇪🇸', nameHe: 'ספרד'),
  Country(name: 'Sri Lanka',                code: 'LK', flag: '🇱🇰', nameHe: 'סרי לנקה'),
  Country(name: 'Sudan',                    code: 'SD', flag: '🇸🇩', nameHe: 'סודן'),
  Country(name: 'Suriname',                 code: 'SR', flag: '🇸🇷', nameHe: 'סורינאם'),
  Country(name: 'Sweden',                   code: 'SE', flag: '🇸🇪', nameHe: 'שוודיה'),
  Country(name: 'Switzerland',              code: 'CH', flag: '🇨🇭', nameHe: 'שווייץ'),
  Country(name: 'Syria',                    code: 'SY', flag: '🇸🇾', nameHe: 'סוריה'),
  Country(name: 'Taiwan',                   code: 'TW', flag: '🇹🇼', nameHe: 'טייוואן'),
  Country(name: 'Tajikistan',               code: 'TJ', flag: '🇹🇯', nameHe: 'טג\'יקיסטן'),
  Country(name: 'Tanzania',                 code: 'TZ', flag: '🇹🇿', nameHe: 'טנזניה'),
  Country(name: 'Thailand',                 code: 'TH', flag: '🇹🇭', nameHe: 'תאילנד'),
  Country(name: 'Timor-Leste',              code: 'TL', flag: '🇹🇱', nameHe: 'טימור-לסטה'),
  Country(name: 'Togo',                     code: 'TG', flag: '🇹🇬', nameHe: 'טוגו'),
  Country(name: 'Trinidad and Tobago',      code: 'TT', flag: '🇹🇹', nameHe: 'טרינידד וטובגו'),
  Country(name: 'Tunisia',                  code: 'TN', flag: '🇹🇳', nameHe: 'תוניסיה'),
  Country(name: 'Turkey',                   code: 'TR', flag: '🇹🇷', nameHe: 'טורקיה'),
  Country(name: 'Turkmenistan',             code: 'TM', flag: '🇹🇲', nameHe: 'טורקמניסטן'),
  Country(name: 'Uganda',                   code: 'UG', flag: '🇺🇬', nameHe: 'אוגנדה'),
  Country(name: 'Ukraine',                  code: 'UA', flag: '🇺🇦', nameHe: 'אוקראינה'),
  Country(name: 'United Arab Emirates',     code: 'AE', flag: '🇦🇪', nameHe: 'איחוד האמירויות'),
  Country(name: 'United Kingdom',           code: 'GB', flag: '🇬🇧', nameHe: 'בריטניה'),
  Country(name: 'United States',            code: 'US', flag: '🇺🇸', nameHe: 'ארצות הברית'),
  Country(name: 'Uruguay',                  code: 'UY', flag: '🇺🇾', nameHe: 'אורוגוואי'),
  Country(name: 'Uzbekistan',               code: 'UZ', flag: '🇺🇿', nameHe: 'אוזבקיסטן'),
  Country(name: 'Venezuela',                code: 'VE', flag: '🇻🇪', nameHe: 'ונצואלה'),
  Country(name: 'Vietnam',                  code: 'VN', flag: '🇻🇳', nameHe: 'וייטנאם'),
  Country(name: 'Yemen',                    code: 'YE', flag: '🇾🇪', nameHe: 'תימן'),
  Country(name: 'Zambia',                   code: 'ZM', flag: '🇿🇲', nameHe: 'זמביה'),
  Country(name: 'Zimbabwe',                 code: 'ZW', flag: '🇿🇼', nameHe: 'זימבבואה'),
];

/// Find a Country by ISO alpha-2 code. Returns null if not found.
Country? countryByCode(String? code) {
  if (code == null || code.isEmpty) return null;
  try {
    return kCountries.firstWhere(
      (c) => c.code.toLowerCase() == code.toLowerCase(),
    );
  } catch (_) {
    return null;
  }
}
