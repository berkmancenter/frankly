import 'types.dart';

const String _kDefaultName = 'default';
const String _kCopyAlias = '_copy';

/// The [Config]uration to use across the other components.
///
/// The multiton pattern is used to keep one configuration across the [Namefully]
/// setup. This is useful for avoiding confusion when building other components
/// such as [FirstName], [LastName], or [Name] of distinct types (or [Namon]) that
/// may be of particular shapes.
///
/// For example, a person's [FullName] may appear by:
/// - [NameOrder.firstName]: `Jon Snow` or
/// - [NameOrder.lastName]: `Snow Jon`.
///
/// [Config] makes it easy to set up a specific configuration for [Namefully]
/// and reuse it through other instances or components along the way. If a new
/// [Config] is needed, a named configuration may be created. It is actually
/// advised to use named [Config(name)] instead as it may help mitigate issues
/// and avoid confusion and ambiguity in the future. Plus, a named configuration
/// explains its purpose.
///
/// ```dart
/// var defaultConfig = Config();
/// var otherConfig = Config(name: 'other', title: Title.us);
/// var mergedConfig = Config.merge(otherConfig);
/// var copyConfig = mergedConfig.copyWith(ending: true);
/// ```
///
/// Additionally, a configuration may be [merge]d with or copied from an existing
/// configuration, prioritizing the new one's values.
abstract class Config {
  /// The order of appearance of a full name.
  NameOrder get orderedBy;

  /// The token used to indicate how to split string values.
  Separator get separator;

  /// The abbreviation type to indicate whether or not to add period to a prefix
  /// using the American or British way.
  Title get title;

  /// The option indicating if an ending suffix is used in a formal way.
  bool get ending;

  /// A bypass of the validation rules with this option. This option is ideal
  /// to avoid checking their validity.
  bool get bypass;

  /// An option indicating how to format a surname.
  ///
  /// The supported formats are:
  /// - `father` name only
  /// - `mother` name only
  /// - `hyphenated`, joining both father and mother names with a hyphen
  /// - `all`, joining both father and mother names with a space.
  ///
  /// Note that this option can be set when creating a [LastName]. As this can
  /// become ambiguous at the time of handling it, the value set in this is
  /// prioritized and viewed as the source of truth for future considerations.
  Surname get surname;

  /// The name of the cached configuration.
  String get name;

  /// Returns a unified version of default values of the configuration and the
  /// optional values to consider.
  factory Config({
    String name,
    NameOrder? orderedBy,
    Separator? separator,
    Title? title,
    bool? ending,
    bool? bypass,
    Surname? surname,
  }) = _Config;

  /// Returns a combined version of the existing values of the default configuration
  /// and the provided values of an[other] configuration.
  factory Config.merge(Config? other) = _Config.merge;

  /// Returns a last name-based configuration.
  factory Config.byLastName({Surname? surname, Separator? separator}) {
    return _Config(
      name: 'byLastName',
      orderedBy: NameOrder.lastName,
      surname: surname,
      separator: separator,
    );
  }

  /// Returns a copy of this configuration merged with the provided values.
  ///
  /// The word `_copy` is added to the existing config's name to create the new
  /// config's name if the name already exists for previous configurations. This
  /// is useful to maintain the uniqueness of each configuration. For example,
  /// if the new copy is made from the default configuration, this new copy will
  /// be named `default_copy`.
  Config copyWith({
    String? name,
    NameOrder? orderedBy,
    Separator? separator,
    Title? title,
    bool? ending,
    bool? bypass,
    Surname? surname,
  });

  /// Makes an exact copy of the current configuration.
  Config clone();

  /// Resets the configuration by setting it back to its default values.
  void reset();

  /// Alters the [nameOrder] between the first and last name, and rearrange the
  /// order of appearance of a name set.
  void updateOrder(NameOrder nameOrder);
}

/// Concrete configuration with internal settings and operations.
///
/// This is to avoid manipulating the internal values of [Config] locally, and
/// abstract out its class members. The actual config only exposes the available
/// props in a read-only mode, which should allow more control on the concrete
/// implementation.
class _Config implements Config {
  @override
  NameOrder orderedBy;

  @override
  Separator separator;

  @override
  Title title;

  @override
  bool ending;

  @override
  bool bypass;

  @override
  Surname surname;

  /// The immutable name of the configuration.
  @override
  final String name;

  // Cache for multiple instances.
  static final Map<String, _Config> _cache = {};

  _Config._default(
    this.name, {
    NameOrder? orderedBy,
    Separator? separator,
    Title? title,
    bool? ending,
    bool? bypass,
    Surname? surname,
  })  : orderedBy = orderedBy ?? NameOrder.firstName,
        separator = separator ?? Separator.space,
        title = title ?? Title.uk,
        ending = ending ?? false,
        bypass = bypass ?? true,
        surname = surname ?? Surname.father;

  factory _Config({
    String name = _kDefaultName,
    NameOrder? orderedBy,
    Separator? separator,
    Title? title,
    bool? ending,
    bool? bypass,
    Surname? surname,
  }) {
    if (_cache.containsKey(name)) {
      var restored = _cache[name]!;
      return _cache[name]!
        ..orderedBy = orderedBy ?? restored.orderedBy
        ..separator = separator ?? restored.separator
        ..title = title ?? restored.title
        ..ending = ending ?? restored.ending
        ..bypass = bypass ?? restored.bypass
        ..surname = surname ?? restored.surname;
    } else {
      return _cache[name] = _Config._default(
        name,
        orderedBy: orderedBy,
        separator: separator,
        title: title,
        ending: ending,
        bypass: bypass,
        surname: surname,
      );
    }
  }

  factory _Config.merge(Config? other) {
    return _Config(
      name: other?.name ?? _kDefaultName,
      orderedBy: other?.orderedBy,
      separator: other?.separator,
      title: other?.title,
      ending: other?.ending,
      bypass: other?.bypass,
      surname: other?.surname,
    );
  }

  @override
  _Config copyWith({
    String? name,
    NameOrder? orderedBy,
    Separator? separator,
    Title? title,
    bool? ending,
    bool? bypass,
    Surname? surname,
  }) {
    return _Config(
      name: genNewName(name ?? this.name),
      orderedBy: orderedBy ?? this.orderedBy,
      separator: separator ?? this.separator,
      title: title ?? this.title,
      ending: ending ?? this.ending,
      bypass: bypass ?? this.bypass,
      surname: surname ?? this.surname,
    );
  }

  @override
  Config clone() => copyWith();

  @override
  void reset() {
    orderedBy = NameOrder.firstName;
    separator = Separator.space;
    title = Title.uk;
    ending = false;
    bypass = true;
    surname = Surname.father;
    _cache[name] = _Config._default(name);
  }

  @override
  void updateOrder(NameOrder nameOrder) => _cache[name]!.orderedBy = nameOrder;

  /// Generates a unique new name.
  String genNewName(String name) {
    return name == this.name || _cache.containsKey(name)
        ? genNewName(name + _kCopyAlias)
        : name;
  }
}
