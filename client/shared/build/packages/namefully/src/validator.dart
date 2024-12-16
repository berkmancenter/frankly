import 'constants.dart';
import 'types.dart';
import 'exception.dart';
import 'name.dart';
import 'utils.dart';

/// Set of [ValidationRule]s (or [RegExp]).
///
/// This is intended to match specific alphabets only as a person name does not
/// contain special characters. `\w` does not cover non-Latin characters. So,
/// it is extended using unicode chars to cover more cases (e.g., Icelandic).
/// It matches as follows:
/// - `[a-z]`: Latin alphabet from a (index 97) to z (index 122)
/// - `[A-Z]`: Latin alphabet from A (index 65) to Z (index 90)
/// - `[\u00C0-\u00D6]`: Latin/German from À (index 192) to Ö (index 214)
/// - `[\u00D8-\u00f6]`: German/Icelandic from Ø (index 216) to ö (index 246)
/// - `[\u00f8-\u00ff]`: German/Icelandic from ø (index 248) to ÿ (index 255)
/// - `[\u0400-\u04FF]`: Cyrillic alphabet from Ѐ (index 1024) to ӿ (index 1279)
/// - `[Ά-ωΑ-ώ]`: Greek alphabet from Ά (index 902) to ω (index 969)
abstract class ValidationRule {
  static final base = RegExp(
      r'[a-zA-Z\u00C0-\u00D6\u00D8-\u00f6\u00f8-\u00ff\u0400-\u04FFΆ-ωΑ-ώ]');

  /// Matches one name part (namon) that is of nature:
  /// - Latin (English, Spanish, French, etc.)
  /// - European (Greek, Cyrillic, Icelandic, German)
  /// - hyphenated
  /// - with apostrophe
  /// - with space
  ///
  /// For example, this rule matches the following use cases:
  /// - prefix: `Mr`
  /// - firstName: `Jean-Baptiste`,
  /// - middleName`Jane Doe`
  /// - lastName: `O'connor`,
  /// - suffix: `Ph.D`,
  static final namon = RegExp("^${base.pattern}+(([' -.]${base.pattern})?"
      '${base.pattern}*)*\$');

  /// Matches one name part (namon) that is of nature:
  /// - Latin (English, Spanish, French, etc.)
  /// - European (Greek, Cyrillic, Icelandic, German)
  /// - hyphenated
  /// - with apostrophe
  /// - with space
  static final firstName = namon;

  /// Matches 1+ names part (namon) that are of nature:
  /// - Latin (English, Spanish, French, etc.)
  /// - European (Greek, Cyrillic, Icelandic, German)
  /// - hyphenated
  /// - with apostrophe
  /// - with space
  static final middleName = RegExp("^${base.pattern}+(([' -]"
      '${base.pattern})?${base.pattern}*)*\$');

  /// Matches one name part (namon) that is of nature:
  /// - Latin (English, Spanish, French, etc.)
  /// - European (Greek, Cyrillic, Icelandic, German)
  /// - hyphenated
  /// - with apostrophe
  /// - with space
  static final lastName = namon;
}

/// A validator knows how to validate.
abstract class Validator<T> {
  /// Validates the content [value].
  void validate(T value);
}

mixin ListValidatorMixin<T> on Validator<List<T>> {
  @override
  void validate(List<T> values) {
    if (values.isEmpty ||
        values.length < kMinNumberOfNameParts ||
        values.length > kMaxNumberOfNameParts) {
      throw InputException(
        source: values,
        message: 'expecting a list of $kMinNumberOfNameParts-'
            '$kMaxNumberOfNameParts elements',
      );
    }
  }
}

/// Namon validator to help to parse single pieces of string.
class NamonValidator implements Validator<String> {
  static const _validator = NamonValidator._();

  const NamonValidator._();

  factory NamonValidator() => _validator;

  /// Validates the name content [value].
  @override
  void validate(String value) {
    if (!ValidationRule.namon.hasMatch(value)) {
      throw ValidationException(
        source: value,
        nameType: 'namon',
        message: 'invalid content',
      );
    }
  }
}

class FirstNameValidator implements Validator {
  static const _validator = FirstNameValidator._();

  const FirstNameValidator._();

  factory FirstNameValidator() => _validator;

  /// Validates the name content [value].
  @override
  void validate(dynamic /** String | FirstName */ value) {
    if (value is String) {
      if (!ValidationRule.firstName.hasMatch(value)) {
        throw ValidationException(
          source: value,
          nameType: 'firstName',
          message: 'invalid content',
        );
      }
    } else if (value is FirstName) {
      for (var name in value.asNames) {
        validate(name.value);
      }
    } else {
      throw InputException(
        source: value.runtimeType.toString(),
        message: 'expecting types String | FirstName',
      );
    }
  }
}

class MiddleNameValidator implements Validator {
  static const _validator = MiddleNameValidator._();

  const MiddleNameValidator._();

  factory MiddleNameValidator() => _validator;

  /// Validates the name content [value].
  @override
  void validate(dynamic /** String | List<String> | List<Name> */ value) {
    var namonValidator = Validators.namon;
    if (value is String) {
      if (!ValidationRule.middleName.hasMatch(value)) {
        throw ValidationException(
          source: value,
          nameType: 'middleName',
          message: 'invalid content',
        );
      }
    } else if (value is List<String>) {
      try {
        value.forEach(namonValidator.validate);
      } on ValidationException {
        throw ValidationException(
          source: value,
          nameType: 'middleName',
          message: 'invalid content',
        );
      }
    } else if (value is List<Name>) {
      try {
        for (Name n in value) {
          namonValidator.validate(n.value);
          if (n.type != Namon.middleName) {
            throw NameException('wrong type');
          }
        }
      } on NameException catch (exception) {
        throw ValidationException(
          source: value,
          nameType: 'middleName',
          message: exception.message,
        );
      }
    } else {
      throw InputException(
        source: value.runtimeType.toString(),
        message: 'expecting types String | List<String> | List<Name>',
      );
    }
  }
}

class LastNameValidator implements Validator {
  static const _validator = LastNameValidator._();

  const LastNameValidator._();

  factory LastNameValidator() => _validator;

  /// Validates the name content [value].
  @override
  void validate(dynamic /** String | LastName */ value) {
    if (value is String) {
      if (!ValidationRule.lastName.hasMatch(value)) {
        throw ValidationException(
          source: value,
          nameType: 'lastName',
          message: 'invalid content',
        );
      }
    } else if (value is LastName) {
      for (var name in value.asNames) {
        validate(name.value);
      }
    } else {
      throw InputException(
        source: value.runtimeType.toString(),
        message: 'expecting types String | LastName',
      );
    }
  }
}

class NameValidator implements Validator<Name> {
  static const _validator = NameValidator._();

  const NameValidator._();

  factory NameValidator() => _validator;

  /// Validates the [name] content.
  @override
  void validate(Name name) {
    if (!ValidationRule.namon.hasMatch(name.value)) {
      throw ValidationException(
        source: name,
        nameType: name.type.toString(),
        message: 'invalid content',
      );
    }
  }
}

class NamaValidator implements Validator<Map<Namon, String>> {
  static const _validator = NamaValidator._();

  const NamaValidator._();

  factory NamaValidator() => _validator;

  @override
  void validate(Map<Namon, String> nama) {
    validateKeys(nama);
    Validators.firstName.validate(nama[Namon.firstName]);
    Validators.lastName.validate(nama[Namon.lastName]);

    if (nama.containsKey(Namon.prefix)) {
      Validators.namon.validate(nama[Namon.prefix]!);
    }
    if (nama.containsKey(Namon.suffix)) {
      Validators.namon.validate(nama[Namon.suffix]!);
    }
  }

  void validateKeys(Map<Namon, String> nama) {
    if (nama.isEmpty) {
      throw InputException(
        source: 'null',
        message: 'Map<k,v> must not be empty',
      );
    } else if (nama.length < kMinNumberOfNameParts ||
        nama.length > kMaxNumberOfNameParts) {
      throw InputException(
        source: nama.values.join(' '),
        message: 'expecting $kMinNumberOfNameParts-'
            '$kMaxNumberOfNameParts fields',
      );
    }

    if (!nama.containsKey(Namon.firstName)) {
      throw InputException(
        source: nama.values.join(' '),
        message: '"firstName" is a required key',
      );
    }

    if (!nama.containsKey(Namon.lastName)) {
      throw InputException(
        source: nama.values.join(' '),
        message: '"lastName" is a required key',
      );
    }
  }
}

class ListStringValidator extends Validator<List<String>>
    with ListValidatorMixin<String> {
  final NameIndex index;
  ListStringValidator([this.index = const NameIndex.base()]);

  @override
  void validate(List<String> values) {
    super.validate(values);

    switch (values.length) {
      case 2:
        Validators.firstName.validate(values[index.firstName]);
        Validators.lastName.validate(values[index.lastName]);
        break;
      case 3:
        Validators.firstName.validate(values[index.firstName]);
        Validators.middleName.validate(values[index.middleName]);
        Validators.lastName.validate(values[index.lastName]);
        break;
      case 4:
        Validators.namon.validate(values[index.prefix]);
        Validators.firstName.validate(values[index.firstName]);
        Validators.middleName.validate(values[index.middleName]);
        Validators.lastName.validate(values[index.lastName]);
        break;
      case 5:
        Validators.namon.validate(values[index.prefix]);
        Validators.firstName.validate(values[index.firstName]);
        Validators.middleName.validate(values[index.middleName]);
        Validators.lastName.validate(values[index.lastName]);
        Validators.namon.validate(values[index.suffix]);
        break;
    }
  }

  void validateIndex(List<String> values) => super.validate(values);
}

class ListNameValidator extends Validator<List<Name>> {
  static final _validator = ListNameValidator._();

  factory ListNameValidator() => _validator;

  ListNameValidator._();

  @override
  void validate(List<Name> value) {
    if (value.isEmpty || value.length < kMinNumberOfNameParts) {
      throw InputException(
        source: value,
        message: 'expecting at least $kMinNumberOfNameParts elements',
      );
    }

    var names = _findBasicNames(value);
    if (names.length < kMinNumberOfNameParts) {
      throw InputException(
        source: value,
        message: 'both first and last names are required',
      );
    }
  }

  /// Finds if the iterable contains at least a first and last name.
  Map<String, String> _findBasicNames(List<Name> names) {
    return names.fold<Map<String, String>>({}, (accumulator, name) {
      if (name.isFirstName || name.isLastName) {
        accumulator.putIfAbsent(name.type.name, () => name.toString());
      }
      return accumulator;
    });
  }
}

/// A list of validators for a specific namon.
abstract class Validators {
  static final namon = NamonValidator();
  static final nama = NamaValidator();
  static final prefix = NameValidator();
  static final firstName = FirstNameValidator();
  static final middleName = MiddleNameValidator();
  static final lastName = LastNameValidator();
  static final suffix = NameValidator();
}
