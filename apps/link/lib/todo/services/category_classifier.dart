import '../models/enums.dart';

/// Keyword-based auto-categorization for personal tasks.
///
/// Runs entirely on-device, offline, deterministically.
/// The [CategoryClassifier] interface allows a TFLite model to be
/// substituted in a future phase without changing any call sites.
abstract class CategoryClassifier {
  TaskCategory classify(String title, {String? notes});
}

class KeywordCategoryClassifier implements CategoryClassifier {
  /// Keywords shorter than this must match as whole words only.
  /// Bare tokens like `test` / `run` / `call` / `id` / `pay` / `bin`
  /// previously over-matched (e.g. "Test1" → Health).
  static const _shortKeywordMaxLen = 3;

  static const _rules = <TaskCategory, List<String>>{
    TaskCategory.household: [
      // English
      'clean',
      'cleaning',
      'wash',
      'laundry',
      'dishes',
      'vacuum',
      'mop',
      'groceries',
      'grocery',
      'supermarket',
      'shop',
      'shopping',
      'cook',
      'cooking',
      'dinner',
      'lunch',
      'breakfast',
      'meal',
      'repair',
      'fix',
      'garden',
      'lawn',
      'mow',
      'rubbish',
      'trash',
      'recycle',
      'ikea',
      'furniture',
      'paint',
      'plumber',
      'electrician',
      // Dutch
      'boodschappen',
      'supermarkt',
      'inkopen',
      'schoonmaken',
      'schoonmaak',
      'stofzuigen',
      'afwassen',
      'wassen',
      'wasgoed',
      'koken',
      'avondeten',
      'middageten',
      'ontbijt',
      'maaltijd',
      'repareren',
      'reparatie',
      'tuin',
      'grasmaaien',
      'maaien',
      'afval',
      'vuilnis',
      'recyclen',
      'meubels',
      'schilderen',
      'loodgieter',
      'elektricien',
      'opruimen',
      'dweilen',
      'strijken',
      'ophangen',
    ],
    TaskCategory.health: [
      // English — no bare "test"/"run"/"blood" (too short / ambiguous)
      'doctor',
      'dentist',
      'hospital',
      'appointment',
      'prescription',
      'medicine',
      'medication',
      'pharmacy',
      'physio',
      'therapy',
      'exercise',
      'gym',
      'running',
      'yoga',
      'checkup',
      'check-up',
      'vaccine',
      'blood test',
      'bloodwork',
      'optician',
      'glasses',
      // Dutch
      'dokter',
      'tandarts',
      'ziekenhuis',
      'afspraak',
      'recept',
      'medicijn',
      'medicijnen',
      'apotheek',
      'fysiotherapeut',
      'fysiotherapie',
      'therapie',
      'sporten',
      'hardlopen',
      'controle',
      'vaccinatie',
      'bloedtest',
      'opticien',
      'bril',
      'huisarts',
      'specialist',
    ],
    TaskCategory.admin: [
      // English — no bare "call"/"id"/"form" as substring traps
      'email',
      'phone',
      'letter',
      'form',
      'forms',
      'document',
      'sign',
      'contract',
      'insurance',
      'renew',
      'register',
      'application',
      'passport',
      'visa',
      'driving',
      'licence',
      'license',
      'council',
      'government',
      'tax',
      'taxes',
      'return',
      'accountant',
      'phone call',
      // Dutch
      'bellen',
      'mailen',
      'brief',
      'formulier',
      'document',
      'ondertekenen',
      'contract',
      'verzekering',
      'verlengen',
      'vernieuwen',
      'aanvragen',
      'inschrijven',
      'aanmelden',
      'afmelden',
      'paspoort',
      'rijbewijs',
      'belasting',
      'aangifte',
      'gemeente',
      'overheid',
      'terugbellen',
      'invullen',
      'inleveren',
      'regelen',
    ],
    TaskCategory.school: [
      // English
      'school',
      'homework',
      'teacher',
      'parent evening',
      'meeting',
      'permission',
      'trip',
      'uniform',
      'book',
      'books',
      'tutor',
      'pickup',
      'drop off',
      'nursery',
      'daycare',
      'sport kit',
      // Dutch
      'huiswerk',
      'leraar',
      'juf',
      'meester',
      'ouderavond',
      'vergadering',
      'toestemming',
      'excursie',
      'schoolreis',
      'uniform',
      'boek',
      'bijles',
      'ophalen',
      'brengen',
      'kinderopvang',
      'dagopvang',
      'naschools',
      'gymspullen',
      'rapport',
    ],
    TaskCategory.finance: [
      // English — avoid bare "pay"/"bill" substring issues via word match
      'bank',
      'payment',
      'pay',
      'invoice',
      'bill',
      'bills',
      'transfer',
      'mortgage',
      'rent',
      'insurance',
      'savings',
      'invest',
      'pension',
      'finance',
      'budget',
      'expense',
      'receipt',
      'refund',
      'subscription',
      // Dutch
      'betalen',
      'betaling',
      'factuur',
      'rekening',
      'overmaken',
      'overboeking',
      'hypotheek',
      'huur',
      'sparen',
      'investeren',
      'pensioen',
      'begroting',
      'kosten',
      'terugbetaling',
      'abonnement',
      'boete',
    ],
  };

  /// Whole-word / phrase match. Multi-word keywords match as substrings
  /// with word boundaries on the ends; short tokens never match inside
  /// longer words (e.g. `test` will not match `Test1` or `contest`).
  static bool matchesKeyword(String corpus, String keyword) {
    final k = keyword.toLowerCase().trim();
    if (k.isEmpty) return false;
    final c = corpus.toLowerCase();

    if (k.contains(' ')) {
      // Phrase: require non-letter boundaries around the whole phrase.
      final escaped = RegExp.escape(k);
      return RegExp(
        '(^|[^a-z0-9])$escaped(\$|[^a-z0-9])',
        caseSensitive: false,
      ).hasMatch(c);
    }

    // Single token: always whole-word (letters/digits).
    final escaped = RegExp.escape(k);
    if (!RegExp(
      '(^|[^a-z0-9])$escaped(\$|[^a-z0-9])',
      caseSensitive: false,
    ).hasMatch(c)) {
      return false;
    }
    // Extra guard: reject ultra-short tokens unless they are standalone
    // (already enforced by the regex above). Length note for docs/tests.
    if (k.length <= _shortKeywordMaxLen) {
      return true; // whole-word already required
    }
    return true;
  }

  @override
  TaskCategory classify(String title, {String? notes}) {
    final corpus = '${title.toLowerCase()} ${notes?.toLowerCase() ?? ''}';

    for (final entry in _rules.entries) {
      for (final keyword in entry.value) {
        if (matchesKeyword(corpus, keyword)) return entry.key;
      }
    }
    return TaskCategory.other;
  }
}

/// Singleton for easy access throughout the app.
final categoryClassifier = KeywordCategoryClassifier();
