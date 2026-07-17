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
	late final TranslationsFeedbackEn feedback = TranslationsFeedbackEn._(_root);
	late final TranslationsSplashEn splash = TranslationsSplashEn._(_root);
	late final TranslationsErrorsEn errors = TranslationsErrorsEn._(_root);
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

	/// en: 'Home'
	String get home => 'Home';

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

	/// en: 'Support'
	String get support => 'Support';

	/// en: 'Help & Feedback'
	String get helpFeedback => 'Help & Feedback';

	/// en: 'Find answers or send feedback'
	String get helpFeedbackSubtitle => 'Find answers or send feedback';

	/// en: 'Developer'
	String get developer => 'Developer';

	/// en: 'Feature Showcase'
	String get showcase => 'Feature Showcase';

	/// en: 'Optional template capability demos'
	String get showcaseSubtitle => 'Optional template capability demos';
}

// Path: feedback
class TranslationsFeedbackEn {
	TranslationsFeedbackEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Help & Feedback'
	String get title => 'Help & Feedback';

	/// en: 'Search help'
	String get searchLabel => 'Search help';

	/// en: 'Search frequently asked questions'
	String get searchHint => 'Search frequently asked questions';

	/// en: 'Frequently asked questions'
	String get faqTitle => 'Frequently asked questions';

	/// en: 'No matching answers'
	String get noFaqs => 'No matching answers';

	/// en: 'Try another search or send us feedback.'
	String get noFaqsHint => 'Try another search or send us feedback.';

	/// en: 'Send feedback'
	String get submitCta => 'Send feedback';

	/// en: 'Report a problem or suggest an improvement'
	String get submitCtaSubtitle => 'Report a problem or suggest an improvement';

	/// en: 'Your feedback'
	String get historyTitle => 'Your feedback';

	/// en: 'No feedback yet'
	String get noTickets => 'No feedback yet';

	/// en: 'Submitted feedback will appear here.'
	String get noTicketsHint => 'Submitted feedback will appear here.';

	/// en: 'Could not load feedback'
	String get loadError => 'Could not load feedback';

	/// en: 'Feedback details'
	String get detailTitle => 'Feedback details';

	/// en: 'Could not load feedback details'
	String get detailLoadError => 'Could not load feedback details';

	/// en: 'This feedback is not available.'
	String get ticketUnavailable => 'This feedback is not available.';

	/// en: 'Category'
	String get categoryLabel => 'Category';

	/// en: 'Feedback'
	String get messageLabel => 'Feedback';

	/// en: 'Describe what happened and what you expected.'
	String get messageHelper => 'Describe what happened and what you expected.';

	/// en: 'Please enter your feedback.'
	String get messageRequired => 'Please enter your feedback.';

	/// en: 'Status'
	String get statusLabel => 'Status';

	/// en: 'Submitted'
	String get submittedAtLabel => 'Submitted';

	/// en: 'Reply'
	String get replyLabel => 'Reply';

	/// en: 'No reply yet'
	String get noReply => 'No reply yet';

	/// en: 'Send feedback'
	String get submitButton => 'Send feedback';

	/// en: 'Send feedback?'
	String get confirmTitle => 'Send feedback?';

	/// en: 'Your feedback will be sent to the support team.'
	String get confirmMessage => 'Your feedback will be sent to the support team.';

	/// en: 'Send'
	String get confirmAction => 'Send';

	/// en: 'Cancel'
	String get cancelAction => 'Cancel';

	/// en: 'Sending feedback...'
	String get submitting => 'Sending feedback...';

	/// en: 'Thanks — your feedback was sent.'
	String get successMessage => 'Thanks — your feedback was sent.';

	late final TranslationsFeedbackCategoriesEn categories = TranslationsFeedbackCategoriesEn._(_root);
	late final TranslationsFeedbackStatusesEn statuses = TranslationsFeedbackStatusesEn._(_root);
}

// Path: splash
class TranslationsSplashEn {
	TranslationsSplashEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Flutter Arms'
	String get title => 'Flutter Arms';
}

// Path: errors
class TranslationsErrorsEn {
	TranslationsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Network connection failed. Please check your network settings.'
	String get network => 'Network connection failed. Please check your network settings.';

	/// en: 'The request timed out. Please try again.'
	String get timeout => 'The request timed out. Please try again.';

	/// en: 'The server returned an unexpected response.'
	String get badResponse => 'The server returned an unexpected response.';

	/// en: 'Your session has expired. Please sign in again.'
	String get auth => 'Your session has expired. Please sign in again.';

	/// en: 'Please review the input and try again.'
	String get validation => 'Please review the input and try again.';

	/// en: 'The request was cancelled.'
	String get cancelled => 'The request was cancelled.';

	/// en: 'Something went wrong. Please try again.'
	String get unknown => 'Something went wrong. Please try again.';
}

// Path: feedback.categories
class TranslationsFeedbackCategoriesEn {
	TranslationsFeedbackCategoriesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bug report'
	String get bug => 'Bug report';

	/// en: 'Suggestion'
	String get suggestion => 'Suggestion';

	/// en: 'Other'
	String get other => 'Other';
}

// Path: feedback.statuses
class TranslationsFeedbackStatusesEn {
	TranslationsFeedbackStatusesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Submitted'
	String get submitted => 'Submitted';

	/// en: 'In review'
	String get reviewing => 'In review';

	/// en: 'Resolved'
	String get resolved => 'Resolved';

	/// en: 'Closed'
	String get closed => 'Closed';
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
			'home.home' => 'Home',
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
			'profile.support' => 'Support',
			'profile.helpFeedback' => 'Help & Feedback',
			'profile.helpFeedbackSubtitle' => 'Find answers or send feedback',
			'profile.developer' => 'Developer',
			'profile.showcase' => 'Feature Showcase',
			'profile.showcaseSubtitle' => 'Optional template capability demos',
			'feedback.title' => 'Help & Feedback',
			'feedback.searchLabel' => 'Search help',
			'feedback.searchHint' => 'Search frequently asked questions',
			'feedback.faqTitle' => 'Frequently asked questions',
			'feedback.noFaqs' => 'No matching answers',
			'feedback.noFaqsHint' => 'Try another search or send us feedback.',
			'feedback.submitCta' => 'Send feedback',
			'feedback.submitCtaSubtitle' => 'Report a problem or suggest an improvement',
			'feedback.historyTitle' => 'Your feedback',
			'feedback.noTickets' => 'No feedback yet',
			'feedback.noTicketsHint' => 'Submitted feedback will appear here.',
			'feedback.loadError' => 'Could not load feedback',
			'feedback.detailTitle' => 'Feedback details',
			'feedback.detailLoadError' => 'Could not load feedback details',
			'feedback.ticketUnavailable' => 'This feedback is not available.',
			'feedback.categoryLabel' => 'Category',
			'feedback.messageLabel' => 'Feedback',
			'feedback.messageHelper' => 'Describe what happened and what you expected.',
			'feedback.messageRequired' => 'Please enter your feedback.',
			'feedback.statusLabel' => 'Status',
			'feedback.submittedAtLabel' => 'Submitted',
			'feedback.replyLabel' => 'Reply',
			'feedback.noReply' => 'No reply yet',
			'feedback.submitButton' => 'Send feedback',
			'feedback.confirmTitle' => 'Send feedback?',
			'feedback.confirmMessage' => 'Your feedback will be sent to the support team.',
			'feedback.confirmAction' => 'Send',
			'feedback.cancelAction' => 'Cancel',
			'feedback.submitting' => 'Sending feedback...',
			'feedback.successMessage' => 'Thanks — your feedback was sent.',
			'feedback.categories.bug' => 'Bug report',
			'feedback.categories.suggestion' => 'Suggestion',
			'feedback.categories.other' => 'Other',
			'feedback.statuses.submitted' => 'Submitted',
			'feedback.statuses.reviewing' => 'In review',
			'feedback.statuses.resolved' => 'Resolved',
			'feedback.statuses.closed' => 'Closed',
			'splash.title' => 'Flutter Arms',
			'errors.network' => 'Network connection failed. Please check your network settings.',
			'errors.timeout' => 'The request timed out. Please try again.',
			'errors.badResponse' => 'The server returned an unexpected response.',
			'errors.auth' => 'Your session has expired. Please sign in again.',
			'errors.validation' => 'Please review the input and try again.',
			'errors.cancelled' => 'The request was cancelled.',
			'errors.unknown' => 'Something went wrong. Please try again.',
			_ => null,
		};
	}
}
