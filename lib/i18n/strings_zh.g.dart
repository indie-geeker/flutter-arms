///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsZh with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZh({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zh,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsZh _root = this; // ignore: unused_field

	@override 
	TranslationsZh $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZh(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCommonZh common = _TranslationsCommonZh._(_root);
	@override late final _TranslationsAuthZh auth = _TranslationsAuthZh._(_root);
	@override late final _TranslationsOnboardingZh onboarding = _TranslationsOnboardingZh._(_root);
	@override late final _TranslationsHomeZh home = _TranslationsHomeZh._(_root);
	@override late final _TranslationsProfileZh profile = _TranslationsProfileZh._(_root);
	@override late final _TranslationsSplashZh splash = _TranslationsSplashZh._(_root);
}

// Path: common
class _TranslationsCommonZh implements TranslationsCommonEn {
	_TranslationsCommonZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get logout => '退出登录';
	@override String get retry => '重试';
}

// Path: auth
class _TranslationsAuthZh implements TranslationsAuthEn {
	_TranslationsAuthZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '登录';
	@override String get welcomeBack => '欢迎登录';
	@override String get username => '账号';
	@override String get password => '密码';
	@override String get submit => '登录';
}

// Path: onboarding
class _TranslationsOnboardingZh implements TranslationsOnboardingEn {
	_TranslationsOnboardingZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get slide1Title => '快速启动模板';
	@override String get slide1Body => '从一套可运行的 Flutter 模板开始，直接进入业务开发。';
	@override String get slide2Title => 'Clean Architecture + MVVM';
	@override String get slide2Body => '按清晰的分层组织代码，方便扩展和维护。';
	@override String get slide3Title => '更快交付';
	@override String get slide3Body => '完成引导后直接进入登录页，开始你的项目。';
	@override String get skip => '跳过';
	@override String get next => '下一步';
	@override String get start => '开始使用';
}

// Path: home
class _TranslationsHomeZh implements TranslationsHomeEn {
	_TranslationsHomeZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get feed => '首页';
	@override String get explore => '探索';
	@override String get profile => '我的';
}

// Path: profile
class _TranslationsProfileZh implements TranslationsProfileEn {
	_TranslationsProfileZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get appearance => '外观';
	@override String get themeMode => '主题模式';
	@override String get light => '浅色';
	@override String get dark => '深色';
	@override String get system => '跟随系统';
	@override String get themeColor => '主题色';
	@override String get custom => '自定义';
	@override String get general => '通用';
	@override String get language => '语言';
	@override String get guest => '游客';
}

// Path: splash
class _TranslationsSplashZh implements TranslationsSplashEn {
	_TranslationsSplashZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => 'Flutter Arms';
}

/// The flat map containing all translations for locale <zh>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZh {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.logout' => '退出登录',
			'common.retry' => '重试',
			'auth.title' => '登录',
			'auth.welcomeBack' => '欢迎登录',
			'auth.username' => '账号',
			'auth.password' => '密码',
			'auth.submit' => '登录',
			'onboarding.slide1Title' => '快速启动模板',
			'onboarding.slide1Body' => '从一套可运行的 Flutter 模板开始，直接进入业务开发。',
			'onboarding.slide2Title' => 'Clean Architecture + MVVM',
			'onboarding.slide2Body' => '按清晰的分层组织代码，方便扩展和维护。',
			'onboarding.slide3Title' => '更快交付',
			'onboarding.slide3Body' => '完成引导后直接进入登录页，开始你的项目。',
			'onboarding.skip' => '跳过',
			'onboarding.next' => '下一步',
			'onboarding.start' => '开始使用',
			'home.feed' => '首页',
			'home.explore' => '探索',
			'home.profile' => '我的',
			'profile.appearance' => '外观',
			'profile.themeMode' => '主题模式',
			'profile.light' => '浅色',
			'profile.dark' => '深色',
			'profile.system' => '跟随系统',
			'profile.themeColor' => '主题色',
			'profile.custom' => '自定义',
			'profile.general' => '通用',
			'profile.language' => '语言',
			'profile.guest' => '游客',
			'splash.title' => 'Flutter Arms',
			_ => null,
		};
	}
}
