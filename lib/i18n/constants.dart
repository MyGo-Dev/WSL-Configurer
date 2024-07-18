const i18nFolder = "assets/i18n";
const i18nLanguages = "$i18nFolder/languages.yaml";

String i18nLanguage(String locale) => "$i18nFolder/$locale";
String i18nLanguageFields(String locale) => "${i18nLanguage(locale)}/fields.yaml";
