/// Checks if the given [url] is valid or not. Should start with http or https.
bool isUrlValid(String url) {
  final urlPattern = RegExp(
    r'^(http(s)?:\/\/)?((w){3}.)?'
    r'([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}'
    r'(:[0-9]{1,5})?(\/.*)?$',
  );

  return urlPattern.hasMatch(url);
}

/// Checks if the given [url] ends with .pdf.
bool isUrlEndsWithPdf(String url) {
  final urlPattern = RegExp(r'\.pdf$');

  return urlPattern.hasMatch(url);
}
