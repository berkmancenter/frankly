import 'config.dart';
import 'constants.dart';
import 'derivative.dart';
import 'exception.dart';
import 'full_name.dart';
import 'name.dart';
import 'parser.dart';
import 'types.dart';
import 'utils.dart';

/// A helper for organizing person names in a particular order, way, or shape.
///
/// Though `namefully` is easy to use, it does not magically guess which part of
/// the name is what (prefix, suffix, first, last, or middle names). It relies
/// actually on how the name parts are indicated (i.e., their roles) so that
/// it can perform internally certain operations and saves us some extra
/// calculations/processing. In addition, [Namefully] can be created using
/// distinct raw data shapes. This is intended to give some flexibility to the
/// developer so that he or she is not bound to a particular data format.
/// By following closely the API reference to know how to harness its usability,
/// this utility aims to save time in formatting names.
///
/// `namefully` also works like a trapdoor. Once a raw data is provided and
/// validated, a developer can only *access* in a vast amount of, yet effective
/// ways the name info. *No editing* is possible. If the name is mistaken, a new
/// instance of [Namefully] must be created. Remember, this utility's primary
/// objective is to help to **handle** a person name.
///
/// Note that the name standards used for the current version of this library
/// are as follows:
///      `(prefix) firstName (middleName) lastName (suffix)`
/// The opening `(` and closing `)` symbols mean that these parts are optional.
/// In other words, the most basic and typical case is a name that looks like
/// this: `John Smith`, where `John` is the first name and `Smith`, the last
/// name.
///
/// See https://departments.weber.edu/qsupport&training/Data_Standards/Name.htm
/// for more info on name standards.
///
/// **IMPORTANT**: Keep in mind that the order of appearance matters and can be
/// altered through configured parameters, which we will be seeing later on. By
/// default, the order of appearance is as shown above and will be used as a
/// basis for future examples and use cases.
///
/// Once imported, all that is required to do is to create an instance of
/// [Namefully] and the rest will follow.
///
/// Some terminologies used across the library are:
/// - namon: 1 piece of name (e.g., first name)
/// - nama: 2+ pieces of name (e.g., first name + last name)
///
/// Happy name handling 😊!
class Namefully {
  /// A copy of high-quality name data.
  late final FullName _fullName;

  /// A copy of the default configuration (combined with a custom one if any).
  late final Config _config;

  /// Creates a name with distinguishable parts from a raw string content.
  ///
  /// An optional [Config]uration may be provided with specifics on how to treat
  /// a full name during its course. By default, all name parts are validated
  /// against some basic validation rules to avoid common runtime exceptions.
  Namefully(String names, {Config? config}) {
    _build(StringParser(names), config);
  }

  /// Creates a name from a list of distinguishable parts.
  Namefully.fromList(List<String> names, {Config? config}) {
    _build(ListStringParser(names), config);
  }

  /// Creates a name from a json-like distinguishable name parts.
  Namefully.fromJson(Map<String, String> names, {Config? config}) {
    _build(JsonNameParser(names), config);
  }

  /// Creates a name from a list of [Name]s.
  ///
  /// [Name] is provided by this utility, representing a namon with some extra
  /// capabilities, compared to a simple string name. This class helps to define
  /// the role of a name part (e.g, prefix) beforehand, which, as a consequence,
  /// gives more flexibility at the time of creating an instance of Namefully.
  Namefully.of(List<Name> names, {Config? config}) {
    _build(ListNameParser(names), config);
  }

  /// Creates a name from a [FullName].
  ///
  /// Provided by this utility, a [FullName] is a copy of the original data. See
  /// the [FullName] class definition for more info.
  Namefully.from(FullName fullName)
      : _config = fullName.config,
        _fullName = fullName;

  /// Creates a name from a customized [Parser].
  Namefully.fromParser(Parser parser, {Config? config}) {
    _build(parser, config);
  }

  /// Creates a name from specific name parts.
  Namefully.only({
    String? prefix,
    required String firstName,
    List<String>? middleName,
    required String lastName,
    String? suffix,
    Config? config,
  })  : _config = config ?? Config(),
        _fullName = FullName.raw(
          prefix: prefix,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          suffix: suffix,
          config: config,
        );

  /// Constructs a [Namefully] instance from a text.
  ///
  /// It throws a [NameException] if the text cannot be parsed. Use [tryParse]
  /// instead if a `null` return is preferred over a throwable exception.
  ///
  /// This operation is computed asynchronously, which gives more flexibility at
  /// the time of catching the exception (and stack trace if any). The acceptable
  /// text format is a string composed of two or more name pieces. For instance,
  /// `John Lennon`, or `John Winston Ono Lennon` are parsable names and follow
  /// the basic name standard rules (i.e., first-middle-last).
  ///
  /// Keep in mind that prefix and suffix are not considered during the parsing
  /// process.
  static Future<Namefully> parse(String text) {
    return Parser.buildAsync(text).then(Namefully.fromParser);
  }

  /// Constructs a [Namefully] instance from a text.
  ///
  /// It works like [parse] except that this function returns `null` where [parse]
  /// would throw a [NameException].
  static Namefully? tryParse(String text) {
    try {
      return Namefully.fromParser(Parser.build(text));
    } on NameException {
      return null;
    }
  }

  /// The current configuration.
  Config get config => _config;

  /// The number of characters of the [birthName], including spaces.
  int get length => birth.length;

  /// The prefix part.
  String? get prefix => _fullName.prefix?.toString();

  /// The first name.
  String get first => firstName();

  /// The first middle name if any.
  String? get middle => middleName().firstOrNull;

  /// Returns true if any [middleName]'s been set.
  bool get hasMiddle => _fullName.has(Namon.middleName);

  /// The last name.
  String get last => lastName();

  /// The suffix part.
  String? get suffix => _fullName.suffix?.toString();

  /// The birth name.
  String get birth => birthName();

  /// The shortest version of a person name.
  String get short => shorten();

  /// The longest version of a person name.
  String get long => birth;

  /// The entire name set.
  String get full => fullName();

  /// The first name combined with the last name's initial.
  String get public => format(r'f $l');

  /// A formal salutation.
  String get salutation => format('p l');

  /// Returns an [Iterable] of existing [Name]s.
  ///
  /// Regardless of the order of appearance, this method will always return the
  /// existing [Name]s according to the name standards upon which this library
  /// is based.
  ///
  /// This is useful for iterating over the name parts in a consistent manner and
  /// this automatically enables operations such as mapping, filtering, etc.
  Iterable<Name> get parts => _fullName.toIterable();

  /// Starts name derivation.
  NameDerivative get derivative => NameDerivative.of(this);

  /// Returns the full name as set.
  @override
  String toString() => full;

  /// Fetches the raw form of a [namon].
  Object? operator [](Namon namon) {
    if (namon == Namon.prefix) return _fullName.prefix;
    if (namon == Namon.firstName) return _fullName.firstName;
    if (namon == Namon.middleName) return _fullName.middleName;
    if (namon == Namon.lastName) return _fullName.lastName;
    if (namon == Namon.suffix) return _fullName.suffix;
    return null;
  }

  /// Whether this name is equal to an[other] one from a raw-string perspective.
  bool equal(Namefully other) => toString() == other.toString();

  /// Gets a Map or json-like representation of the full name.
  Map<String, String?> toMap() => Map<String, String?>.unmodifiable({
        Namon.prefix.name: prefix,
        Namon.firstName.name: first,
        Namon.middleName.name: middleName().join(' '),
        Namon.lastName.name: last,
        Namon.suffix.name: suffix,
      });

  /// Confirms that a name part has been set.
  bool has(Namon namon) => _fullName.has(namon);

  /// Gets the full name ordered as configured.
  ///
  /// The name order [orderedBy] forces to order by first or last name by
  /// overriding the preset configuration.
  ///
  /// [Namefully.format] may also be used to alter manually the order of appearance
  /// of full name.
  ///
  /// For example:
  /// ```dart
  /// var name = Namefully('Jon Stark Snow');
  /// print(name.fullName(NameOrder.lastName)); // "Snow Jon Stark"
  /// print(name.format('l f m')); // "Snow Jon Stark"
  /// ```
  String fullName([NameOrder? orderedBy]) {
    var sep = _config.ending ? ',' : '';
    orderedBy ??= _config.orderedBy;

    return <String>[
      if (prefix != null) prefix!,
      if (orderedBy == NameOrder.firstName) ...[
        first,
        ...middleName(),
        last + sep,
      ] else ...[
        last,
        first,
        middleName().join(' ') + sep
      ],
      if (suffix != null) suffix!,
    ].join(' ').trim();
  }

  /// Gets the birth name ordered as configured, no [prefix] or [suffix].
  ///
  /// The name order [orderedBy] forces to order by first or last name by
  /// overriding the preset configuration.
  String birthName([NameOrder? orderedBy]) {
    orderedBy ??= _config.orderedBy;
    return orderedBy == NameOrder.firstName
        ? <String>[first, ...middleName(), last].join(' ')
        : <String>[last, first, ...middleName()].join(' ');
  }

  /// Gets the first name part of the [FullName].
  ///
  /// The [withMore] param determines whether to include other pieces of the
  /// first name.
  String firstName({bool withMore = true}) {
    return _fullName.firstName.toString(withMore: withMore);
  }

  /// Gets the last name part of the [FullName].
  ///
  /// The last name [format] overrides the how-to formatting of a surname
  /// output, considering its sub-parts.
  String lastName({Surname? format}) {
    return _fullName.lastName.toString(format: format);
  }

  /// Gets the middle [Name] part of the [FullName].
  List<String> middleName() {
    return _fullName.middleName.map((n) => n.value).toList();
  }

  /// Gets the initials of the [FullName].
  ///
  /// The name order [orderedBy] forces to order by first or last name by
  /// overriding the preset configuration.
  ///
  /// [withMid] determines whether to include the initials of middle [Name].
  ///
  /// For example, given the names:
  /// - `John Smith` => `['J', 'S']`
  /// - `John Ben Smith` => `['J', 'S']`.
  /// when [withMid] is set to true:
  /// - `John Ben Smith` => `['J', 'B', 'S']`.
  ///
  /// **Note**:
  /// Ordered by last name obeys the following format:
  ///  `lastName firstName [middleName]`
  /// which means that if no middle name was set, setting [withMid] to true
  /// will output nothing.
  List<String> initials({
    NameOrder? orderedBy,
    bool withMid = false,
    NameType only = NameType.birthName,
  }) {
    orderedBy ??= _config.orderedBy;
    var firstInits = _fullName.firstName.initials(),
        midInits = _fullName.middleName.map((n) => n.initials()).toList(),
        lastInits = _fullName.lastName.initials(),
        initials = <String>[];

    if (only != NameType.birthName) {
      if (only == NameType.firstName) {
        initials.addAll(firstInits);
      } else if (only == NameType.middleName) {
        midInits.forEach(initials.addAll);
      } else {
        initials.addAll(lastInits);
      }
    } else if (orderedBy == NameOrder.firstName) {
      initials.addAll(firstInits);
      if (withMid) midInits.forEach(initials.addAll);
      initials.addAll(lastInits);
    } else {
      initials.addAll(lastInits);
      initials.addAll(firstInits);
      if (withMid) midInits.forEach(initials.addAll);
    }

    return List<String>.unmodifiable(initials);
  }

  /// Shortens a complex full name to a simple typical name, a combination of
  /// first and last name.
  ///
  /// The name order [orderedBy] forces to order by first or last name by
  /// overriding the preset configuration.
  ///
  /// For a given name such as `Mr Keanu Charles Reeves`, shortening this name
  /// is equivalent to making it `Keanu Reeves`.
  ///
  /// As a shortened name, the namon of the first name is favored over the other
  /// names forming part of the entire first names, if any. Meanwhile, for
  /// the last name, the configured `surname` is prioritized.
  ///
  /// For a given `FirstName FatherName MotherName`, shortening this name when
  /// the surname is set as `mother` is equivalent to making it:
  /// `FirstName MotherName`.
  String shorten({NameOrder? orderedBy}) {
    orderedBy ??= _config.orderedBy;
    return orderedBy == NameOrder.firstName
        ? [_fullName.firstName.value, _fullName.lastName.toString()].join(' ')
        : [_fullName.lastName.toString(), _fullName.firstName.value].join(' ');
  }

  /// Flattens a long name using the name types as variants.
  ///
  /// While [limit] sets a threshold as a limited number of characters
  /// supported to flatten a [FullName], [Flat] indicates which variant
  /// to use when doing so. By default, a full name gets flattened by
  /// [Flat.middleName].
  ///
  /// The flattening operation is only executed iff there is a valid entry and
  /// it surpasses the limit set. In the examples below, let us assume that the
  /// name goes beyond the limit value.
  ///
  /// Flattening a long name refers to reducing the name to the following forms.
  /// For example, `John Winston Ono Lennon` flattened by:
  /// * [Flat.firstName]: => 'J. Winston Ono Lennon'
  /// * [Flat.middleName]: => 'John W. O. Lennon'
  /// * [Flat.lastName]: => 'John Winston Ono L.'
  /// * [Flat.firstMid]: => 'J. W. O. Lennon'
  /// * [Flat.midLast]: => 'John W. O. L.'
  /// * [Flat.all]: => 'J. W. O. L.'
  ///
  /// With the help of the [recursive] flag, the above operation can happen
  /// recursively in the same order if the name is still too long. For example,
  /// flattening `John Winston Ono Lennon` using the following params:
  /// `flatten(limit: 18, by: Flat.firstName, recursive: true)`
  /// will result in `John W. O. Lennon` and not `J. Winston Ono Lennon`.
  ///
  /// A shorter version of this method is [zip()].
  String flatten({
    int limit = 20,
    Flat by = Flat.middleName,
    bool withPeriod = true,
    bool recursive = false,
    bool withMore = false,
    Surname? surname,
  }) {
    if (length <= limit) return full;

    var sep = withPeriod ? '.' : '',
        fn = _fullName.firstName.toString(),
        mn = middleName().join(' '),
        ln = _fullName.lastName.toString(),
        hasMid = hasMiddle,
        f = _fullName.firstName.initials(withMore: withMore).join('$sep ') +
            sep,
        l = _fullName.lastName.initials(format: surname).join('$sep ') + sep,
        m = hasMiddle
            ? _fullName.middleName
                    .map((n) => n.initials().first)
                    .join('$sep ') +
                sep
            : '',
        name = <String>[];

    if (_config.orderedBy == NameOrder.firstName) {
      switch (by) {
        case Flat.firstName:
          name = hasMid ? [f, mn, ln] : [f, ln];
          break;
        case Flat.lastName:
          name = hasMid ? [fn, mn, l] : [fn, l];
          break;
        case Flat.middleName:
          name = hasMid ? [fn, m, ln] : [fn, ln];
          break;
        case Flat.firstMid:
          name = hasMid ? [f, m, ln] : [f, ln];
          break;
        case Flat.midLast:
          name = hasMid ? [fn, m, l] : [fn, l];
          break;
        case Flat.all:
          name = hasMid ? [f, m, l] : [f, l];
          break;
      }
    } else {
      switch (by) {
        case Flat.firstName:
          name = hasMid ? [ln, f, mn] : [ln, f];
          break;
        case Flat.lastName:
          name = hasMid ? [l, fn, mn] : [l, fn];
          break;
        case Flat.middleName:
          name = hasMid ? [ln, fn, m] : [ln, fn];
          break;
        case Flat.firstMid:
          name = hasMid ? [ln, f, m] : [ln, f];
          break;
        case Flat.midLast:
          name = hasMid ? [l, fn, m] : [l, fn];
          break;
        case Flat.all:
          name = hasMid ? [l, f, m] : [l, f];
          break;
      }
    }

    var flat = name.join(' ');

    if (recursive && flat.length > limit) {
      var next = by == Flat.firstName
          ? Flat.middleName
          : by == Flat.middleName
              ? Flat.lastName
              : by == Flat.lastName
                  ? Flat.firstMid
                  : by == Flat.firstMid
                      ? Flat.midLast
                      : by == Flat.midLast
                          ? Flat.all
                          : by == Flat.all
                              ? Flat.all
                              : by;
      if (next == by) return flat;
      return flatten(
        limit: limit,
        by: next,
        withPeriod: withPeriod,
        recursive: recursive,
        withMore: withMore,
        surname: surname,
      );
    }
    return flat;
  }

  /// Zips or compacts a name using different forms of variants.
  ///
  /// See [flatten()] for more details.
  String zip({Flat by = Flat.midLast, bool withPeriod = true}) {
    return flatten(limit: 0, by: by, withPeriod: withPeriod);
  }

  /// Formats the full name as desired.
  ///
  /// Which [pattern] to use to format it?
  /// string format
  /// -------------
  /// * 'short': typical first + last name
  /// * 'long': birth name (without prefix and suffix)
  /// * 'public': first name combined with the last name's initial.
  /// * 'official': official document format
  ///
  /// char format
  /// -----------
  /// * 'b': birth name
  /// * 'B': capitalized birth name
  /// * 'f': first name
  /// * 'F': capitalized first name
  /// * 'l': last name (official)
  /// * 'L': capitalized last name
  /// * 'm': middle names
  /// * 'M': capitalized middle names
  /// * 'o': official document format
  /// * 'O': official document format in capital letters
  /// * 'p': prefix
  /// * 'P': capitalized prefix
  /// * 's': suffix
  /// * 'S': capitalized suffix
  ///
  /// punctuations
  /// ------------
  /// * '.': period
  /// * ',': comma
  /// * ' ': space
  /// * '-': hyphen
  /// * '_': underscore
  /// * '$': an escape character to select only the initial of the next char.
  ///
  /// Given the name `Joe Jim Smith`, call [format] with the [pattern] string.
  /// - format('l f') => 'Smith Joe'
  /// - format('L, f') => 'SMITH, Joe'
  /// - format('short') => 'Joe Smith'
  /// - format() => 'SMITH, Joe Jim'
  /// - format(r'f $l.') => 'Joe S.'.
  ///
  /// Do note that the escape character is only valid for the birth name parts:
  /// first, middle, and last names.
  String format(String pattern) {
    if (pattern == 'short') return short;
    if (pattern == 'long') return long;
    if (pattern == 'public') return public;
    if (pattern == 'official') pattern = 'o';

    var group = ''; // set of chars.
    final formatted = <String>[];
    for (var c in pattern.chars) {
      if (!kAllowedTokens.contains(c)) {
        throw NotAllowedException(
          source: full,
          operation: 'format',
          message: 'unsupported character <$c> from $pattern.',
        );
      }
      group += c;
      if (c == r'$') continue;
      formatted.add(_map(group) ?? '');
      group = '';
    }
    return formatted.join().trim();
  }

  /// Transforms a [birthName] into UPPERCASE.
  String upper() => birth.toUpperCase();

  /// Transforms a [birthName] into lowercase.
  String lower() => birth.toLowerCase();

  /// Transforms a [birthName] into camelCase.
  String camel() => decapitalize(pascal());

  /// Transforms a [birthName] into PascalCase.
  String pascal() => split().map(capitalize).join();

  /// Transforms a [birthName] into snake_case.
  String snake() => split().map((n) => n.toLowerCase()).join('_');

  /// Transforms a [birthName] into hyphen-case (or kebab-case).
  String hyphen() => split().map((n) => n.toLowerCase()).join('-');

  /// Transforms a [birthName] into dot.case.
  String dot() => split().map((n) => n.toLowerCase()).join('.');

  /// Transforms a [birthName] into ToGgLe CaSe.
  String toggle() => toggleCase(birth);

  /// Splits a [birthName] using a [separator].
  List<String> split([RegExp? separator]) {
    separator ??= RegExp("[' -.]");
    return birth.replaceAll(separator, ' ').split(' ');
  }

  /// Joins the name parts of a [birthName] using a [separator].
  String join([String separator = '']) => split().join(separator);

  /// Flips definitely the name order from the preset/current config.
  void flip() {
    if (_config.orderedBy == NameOrder.firstName) {
      _config.updateOrder(NameOrder.lastName);
      print('The name order is now changed to: ${NameOrder.lastName.name}');
    } else {
      _config.updateOrder(NameOrder.firstName);
      print('The name order is now changed to: ${NameOrder.firstName.name}');
    }
  }

  /// Builds the core elements for name data.
  void _build<T>(Parser<T> parser, [Config? options]) {
    _config = Config.merge(options);
    _fullName = parser.parse(options: _config);
  }

  /// Maps each [char]acter to a specific name piece.
  String? _map(String char) {
    switch (char) {
      case '.':
      case ',':
      case ' ':
      case '-':
      case '_':
        return char;
      case 'b':
        return birth;
      case 'B':
        return birth.toUpperCase();
      case 'f':
        return first;
      case 'F':
        return first.toUpperCase();
      case 'l':
        return last;
      case 'L':
        return last.toUpperCase();
      case 'm':
      case 'M':
        return char == 'm'
            ? middleName().join(' ')
            : middleName().join(' ').toUpperCase();
      case 'o':
      case 'O':
        final sxSep = _config.ending ? ',' : '';
        final nama = <String>[
          if (prefix != null) prefix!,
          '$last,'.toUpperCase(),
          if (hasMiddle) ...[first, middleName().join(' ') + sxSep] else
            first + sxSep,
          if (suffix != null) suffix!
        ].join(' ').trim();

        return char == 'o' ? nama : nama.toUpperCase();
      case 'p':
        return prefix;
      case 'P':
        return prefix?.toUpperCase();
      case 's':
        return suffix;
      case 'S':
        return suffix?.toUpperCase();
      case r'$f':
      case r'$F':
        return _fullName.firstName.initials().first;
      case r'$l':
      case r'$L':
        return _fullName.lastName.initials().first;
      case r'$m':
      case r'$M':
        return hasMiddle ? middle![0] : null;
      default:
        return null;
    }
  }
}
