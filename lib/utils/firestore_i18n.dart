String getLocalizedField(Map field, String localeCode) {
  if (field.containsKey(localeCode) &&
      (field[localeCode] as String).isNotEmpty) {
    return field[localeCode] as String;
  }
  if (field.containsKey('en') && (field['en'] as String).isNotEmpty) {
    return field['en'] as String;
  }
  // As a last resort, return first available value
  for (final value in field.values) {
    if (value is String && value.isNotEmpty) return value;
  }
  return '';
}
