# New feature checklist

## Placeholder substitutions

When copying from `assets/feature_template/`, substitute these in BOTH filenames and file contents. The template uses `%` delimiters because they don't collide with Dart's `{...}` named-parameter syntax.

| Placeholder | Replace with | Example (`settings`) |
|---|---|---|
| `%feature%` | snake_case singular feature name | `settings` |
| `%Feature%` | PascalCase | `Settings` |

## File-by-file mapping

| Template path | Produced path (example `settings`) |
|---|---|
| `data/datasources/%feature%_remote_datasource.dart` | `lib/features/settings/data/datasources/settings_remote_datasource.dart` |
| `data/datasources/%feature%_local_datasource.dart` | `lib/features/settings/data/datasources/settings_local_datasource.dart` |
| `data/models/%feature%_dto.dart` | `lib/features/settings/data/models/settings_dto.dart` |
| `data/repositories/%feature%_repository_impl.dart` | `lib/features/settings/data/repositories/settings_repository_impl.dart` |
| `domain/entities/%feature%.dart` | `lib/features/settings/domain/entities/settings.dart` |
| `domain/repositories/%feature%_repository.dart` | `lib/features/settings/domain/repositories/settings_repository.dart` |
| `domain/usecases/get_%feature%_usecase.dart` | `lib/features/settings/domain/usecases/get_settings_usecase.dart` |
| `presentation/pages/%feature%_page.dart` | `lib/features/settings/presentation/pages/settings_page.dart` |
| `presentation/view_models/%feature%_view_model.dart` | `lib/features/settings/presentation/view_models/settings_view_model.dart` |
| `presentation/states/%feature%_state.dart` | `lib/features/settings/presentation/states/settings_state.dart` |

Rename the files, open each, and substitute inside the content too. Then fill in real endpoint paths, DTO fields, entity fields, state fields, UseCase signatures.

## Ordered checklist

1. [ ] Decide the feature name: singular, snake_case, no verb prefix (e.g. `post`, not `add_post`).
2. [ ] Copy the template tree to `lib/features/<name>/`.
3. [ ] Do the `%feature%` / `%Feature%` substitutions in filenames and contents.
4. [ ] Trim templates you don't need — e.g. if the feature has no local caching, delete `%feature%_local_datasource.dart` and remove its provider wiring from the repository impl.
5. [ ] Fill in the Retrofit endpoints and path parameters on the remote datasource.
6. [ ] Fill in the DTO fields (match the API response shape exactly; use `@JsonKey` if the JSON key differs from the Dart field).
7. [ ] Fill in the `toEntity()` extension on the DTO.
8. [ ] Fill in the Entity fields (domain — no JSON annotations).
9. [ ] Fill in the Repository interface methods (all return `Future<Result<T>>`).
10. [ ] Fill in the Repository implementation using the `try { ... .asApi() } on AppException catch` pattern.
11. [ ] Declare each UseCase as a small class with a `call(...)` method.
12. [ ] Add a Riverpod provider (function form) for the repository and each UseCase, co-located in the impl file.
13. [ ] Fill in the State fields (include `isLoading` + `Failure? error` always; add domain data fields).
14. [ ] Fill in the ViewModel — `build()` returns initial state; each action reads the UseCase provider and switches on `Result`.
15. [ ] Fill in the Page — `@RoutePage()`; use `ConsumerWidget` if it reads state.
16. [ ] Create any needed `_XxxWidget` private classes at the bottom of the page file, or under `presentation/widgets/` if shared within the feature.
17. [ ] Register the route in `lib/app/app_router.dart`, with `guards: [_authGuard]` if protected.
18. [ ] Add i18n keys to BOTH `lib/i18n/en.i18n.json` AND `lib/i18n/zh.i18n.json` under a `<name>` namespace. Keep shape symmetric.
19. [ ] Run `tool/gen.sh` — this runs `build_runner build --delete-conflicting-outputs` + `dart run slang`.
20. [ ] Run `tool/format.sh` (enforces 80-char wrap).
21. [ ] Run `tool/test.sh` and fix any lint / architecture test failures.
22. [ ] Write tests — see the `flutter-arms-testing` skill for the exact patterns.

## Common mistakes

- ❌ Forgetting `.asApi()` on a Retrofit call → `DioException` leaks, `on AppException catch` misses it.
- ❌ Importing `app_exception.dart` in a ViewModel or Page → architecture test fails (Rule 2).
- ❌ Cross-feature import without `// arch-exempt: <reason>` → architecture test fails (Rule 4).
- ❌ Missing a matching i18n key in `zh.i18n.json` → `dart run slang` fails at codegen.
- ❌ Forgetting to re-run `tool/gen.sh` after adding `@freezed` / `@riverpod` / `@RoutePage()` / `@RestApi()` → build errors referencing missing `_$Xxx` classes.
- ❌ Page using `StatefulWidget` with manual `setState` to hold form values → state should live in the ViewModel, form fields should use `initialValue`.
- ❌ Repository throwing instead of returning `Result.failure(...)` → UI layer can't handle it without breaking the contract.
- ❌ Using `StateProvider<bool>(...)` instead of a `@riverpod class` — legacy API, not on our approved list.
- ❌ Entity importing DTO or DTO's freezed file → domain should be purely domain types.
- ❌ Manually writing `copyWith` — let Freezed generate it.
- ❌ Placing a repository provider OUTSIDE the impl file → breaks the "one feature module, one place to wire DI" convention.

## Naming conventions summary

| Kind | Pattern | Example |
|---|---|---|
| Feature folder | snake_case singular | `settings`, `post`, `search` |
| Entity class | PascalCase singular | `Post`, `Settings` |
| DTO class | `<Entity>Dto` | `PostDto`, `SettingsDto` |
| Repository interface | `<Feature>Repository` | `PostRepository` |
| Repository impl | `<Feature>RepositoryImpl` | `PostRepositoryImpl` |
| Remote DS | `<Feature>RemoteDataSource` | `PostRemoteDataSource` |
| Local DS | `<Feature>LocalDataSource` | `PostLocalDataSource` |
| UseCase | `<Verb><Feature>UseCase` | `GetPostUseCase`, `DeletePostUseCase` |
| Page-level ViewModel | `<Feature>ViewModel` | `PostViewModel` |
| Global Notifier | `<Feature>Notifier` | `AuthNotifier` |
| State class | `<Feature>State` | `PostState` |
| Page widget | `<Feature>Page` | `PostPage` |
| AutoRoute class (generated) | `<Feature>Route` | `PostRoute` |
| Functional provider | lowerCamelCase | `postRepository`, `getPostUseCase`, `postRemoteDataSource` |
| Private sub-widget | `_<Name>` | `_PostHeader`, `_PostListTile` |
