enum TranslationDirection {
  textToMorse,
  morseToText;

  TranslationDirection get flipped =>
      this == TranslationDirection.textToMorse ? TranslationDirection.morseToText : TranslationDirection.textToMorse;

  bool get isTextToMorse => this == TranslationDirection.textToMorse;
}
