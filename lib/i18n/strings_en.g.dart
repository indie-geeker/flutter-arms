///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsCommonEn common = TranslationsCommonEn._(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn._(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn._(_root);
	late final TranslationsProfileEn profile = TranslationsProfileEn._(_root);
	late final TranslationsSplashEn splash = TranslationsSplashEn._(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Logout'
	String get logout => 'Logout';

	/// en: 'Retry'
	String get retry => 'Retry';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get title => 'Login';

	/// en: 'Welcome back'
	String get welcomeBack => 'Welcome back';

	/// en: 'Username'
	String get username => 'Username';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Sign in'
	String get submit => 'Sign in';
}

// Path: onboarding
class TranslationsOnboardingEn {
	TranslationsOnboardingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start fast'
	String get slide1Title => 'Start fast';

	/// en: 'Start from a working Flutter template and focus on your product.'
	String get slide1Body => 'Start from a working Flutter template and focus on your product.';

	/// en: 'Clean Architecture + MVVM'
	String get slide2Title => 'Clean Architecture + MVVM';

	/// en: 'Keep code layered so it stays easy to extend and maintain.'
	String get slide2Body => 'Keep code layered so it stays easy to extend and maintain.';

	/// en: 'Ship sooner'
	String get slide3Title => 'Ship sooner';

	/// en: 'Finish onboarding and jump straight to login.'
	String get slide3Body => 'Finish onboarding and jump straight to login.';

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Get started'
	String get start => 'Get started';
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Feed'
	String get feed => 'Feed';

	/// en: 'Explore'
	String get explore => 'Explore';

	/// en: 'Profile'
	String get profile => 'Profile';
}

// Path: profile
class TranslationsProfileEn {
	TranslationsProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Theme mode'
	String get themeMode => 'Theme mode';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';

	/// en: 'System'
	String get system => 'System';

	/// en: 'Theme color'
	String get themeColor => 'Theme color';

	/// en: 'Custom'
	String get custom => 'Custom';

	/// en: 'General'
	String get general => 'General';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Guest'
	String get guest => 'Guest';
}

// Path: splash
class TranslationsSplashEn {
	TranslationsSplashEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Flutter Arms'
	String get title => 'Flutter Arms';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.logout' => 'Logout',
			'common.retry' => 'Retry',
			'auth.title' => 'Login',
			'auth.welcomeBack' => 'Welcome back',
			'auth.username' => 'Username',
			'auth.password' => 'Password',
			'auth.submit' => 'Sign in',
			'onboarding.slide1Title' => 'Start fast',
			'onboarding.slide1Body' => 'Start from a working Flutter template and focus on your product.',
			'onboarding.slide2Title' => 'Clean Architecture + MVVM',
			'onboarding.slide2Body' => 'Keep code layered so it stays easy to extend and maintain.',
			'onboarding.slide3Title' => 'Ship sooner',
			'onboarding.slide3Body' => 'Finish onboarding and jump straight to login.',
			'onboarding.skip' => 'Skip',
			'onboarding.next' => 'Next',
			'onboarding.start' => 'Get started',
			'home.feed' => 'Feed',
			'home.explore' => 'Explore',
			'home.profile' => 'Profile',
			'profile.appearance' => 'Appearance',
			'profile.themeMode' => 'Theme mode',
			'profile.light' => 'Light',
			'profile.dark' => 'Dark',
			'profile.system' => 'System',
			'profile.themeColor' => 'Theme color',
			'profile.custom' => 'Custom',
			'profile.general' => 'General',
			'profile.language' => 'Language',
			'profile.guest' => 'Guest',
			'splash.title' => 'Flutter Arms',
			_ => null,
		};
	}
}
