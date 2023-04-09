String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String capitalizeWords(String s) {
  return s.split(' ').map((word) => capitalize(word)).join(' ');
}

String kebabCase(String s) {
  return s
      .split(' ')
      .map((word) => word.toLowerCase())
      .join('-')
      .replaceAll(RegExp(r'[^a-z0-9-]'), '');
}

String snakeCase(String s) {
  return s
      .split(' ')
      .map((word) => word.toLowerCase())
      .join('_')
      .replaceAll(RegExp(r'[^a-z0-9_]'), '');
}

String camelCase(String s) {
  return s
      .split(' ')
      .map((word) => capitalize(word))
      .join()
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
}

String pascalCase(String s) {
  return s
      .split(' ')
      .map((word) => capitalize(word))
      .join()
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
}

String removeDashes(String s) => s.replaceAll('-', ' ').trim();

String removeUnderscores(String s) => s.replaceAll('_', ' ').trim();

String titleCase(String s) {
  return s.split(' ').map((word) => capitalize(word)).join(' ');
}

String trim(String s) => s.trim();
