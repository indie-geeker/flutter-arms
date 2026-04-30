---
name: flutter-arms-feature
description: Scaffold and modify features in a flutter_arms project (Clean Architecture + MVVM + Riverpod 3 + AutoRoute + Retrofit + Freezed + hive_ce + slang). Use this skill whenever the user asks to add, modify, rename, or extend a feature — including new pages, new API endpoints, new ViewModels/Notifiers, new entities/DTOs, new routes, new i18n keys, or new Retrofit datasources. Also use it when the request is phrased as "添加登录页", "add a settings screen", "wire up /users API", "新增 feature", "写一个 profile 页", "make a search module", or anything that touches data/domain/presentation layers. Do NOT write generic Flutter code in this project — flutter_arms has its own Result<T>, Failure, .asApi() conventions that must be followed. Apply this skill proactively even when the user doesn't say "feature" explicitly, as long as the change involves any of: Riverpod providers, AutoRoute pages, Retrofit interfaces, Hive storage, Freezed states, slang i18n, or Clean Architecture layers.
---

# flutter-arms-feature

You are working inside a **flutter_arms** project — a Clean Architecture + MVVM Flutter template. Everything you write must match the conventions already baked into `lib/`. Before coding, identify which layer the change belongs in and plan the file tree.

## The stack (non-negotiable)

| Concern | Tool | Do NOT substitute |
|---|---|---|
| State + DI | **Riverpod 3** + `@riverpod` / `@Riverpod(keepAlive: true)` | No Bloc, no GetIt, no StateProvider, no ChangeNotifierProvider |
| Routing | **AutoRoute** + `@RoutePage()` | No GoRouter, no `Navigator.push` for top-level nav |
| Network | **Dio + Retrofit** + `@RestApi()` | No raw `http` package |
| Immutable data | **Freezed 3** — `abstract class X with _$X` | No manual `copyWith`, no Equatable |
| JSON | `json_serializable` with `@JsonSerializable` / `@freezed` `fromJson` | — |
| Local storage | **hive_ce** via `kvStorageProvider` | No `shared_preferences` |
| i18n | **slang** — `context.t.<path>` | No `AppLocalizations.of(context)` |
| Errors | `Result<T>` + `Failure` + `AppException` (custom trio) | No Dartz `Either`, no `try/catch` in UI |
| Logging | **talker** — `ref.read(appLoggerProvider)` | No `print` |
| Lint | `very_good_analysis` + 80-char lines | — |
| Tests | `flutter_test` + **mocktail** + `ProviderContainer` | No mockito |

## Layer contract (enforced by `test/core/architecture_test.dart`)

```
features/<f>/
├── data/              ← dio, retrofit, hive_ce, AppException ALLOWED here
│   ├── datasources/   ← @RestApi() (remote), Hive wrapper (local)
│   ├── models/        ← DTO @freezed + toEntity() extension
│   └── repositories/  ← impl: try { ... .asApi() } on AppException catch
├── domain/            ← pure Dart only; NO dio/hive/retrofit/AppException
│   ├── entities/      ← @immutable plain class OR freezed
│   ├── repositories/  ← abstract class, methods return Future<Result<T>>
│   └── usecases/      ← one class per use case with a `call()` method
└── presentation/      ← flutter, riverpod, auto_route; NO AppException
    ├── pages/         ← @RoutePage() StatelessWidget / ConsumerWidget
    ├── view_models/   ← @riverpod class XxxViewModel extends _$XxxViewModel
    ├── states/        ← @freezed XxxState
    └── widgets/       ← private _Xxx or public shared widgets
```

Violating these rules makes `tool/test.sh` fail. If you must cross-cut (e.g. a Profile page calling `AuthNotifier`), add `// arch-exempt: <reason>` on the line above the import. Don't add exemptions casually — the current whitelist is only auth-related.

## CRITICAL rules (generic Flutter advice gets these wrong)

1. **Repository always returns `Future<Result<T>>`**, never throws to the UI. Canonical shape:
   ```dart
   try {
     final dto = await _remote.xxx(body).asApi();
     return Result.success(dto.toEntity());
   } on AppException catch (e) {
     return Result.failure(Failure.fromException(e));
   }
   ```

2. **`.asApi()` is mandatory** on every Retrofit call inside a Repository. It converts `DioException` → `AppException` at the boundary. Skipping it means `on AppException catch` will miss and a raw `DioException` will leak.

3. **Domain / Presentation never import `app_exception.dart`** — they only know `Failure` + `FailureCode`. The architecture test will fail otherwise.

4. **UI renders errors via `context.failureMessage(failure)`** to get localized text. Do NOT hardcode error strings, do NOT call `failure.toString()` in the UI.

5. **ViewModel naming convention**:
   - `XxxViewModel` → **page-level** Notifier, disposed with the route. Default `@riverpod` (autoDispose).
   - `XxxNotifier` → **global** Notifier, outlives pages (auth, theme, locale). Always `@Riverpod(keepAlive: true)`.

6. **Private widget classes, not `Widget _buildXxx()` methods.** Extract a `class _Xxx extends StatelessWidget { ... }` at the bottom of the same file with a separator comment.

7. **Run `tool/gen.sh`** after touching any annotation (`@freezed`, `@riverpod`, `@RoutePage()`, `@RestApi()`, `@JsonSerializable`). It runs `build_runner build --delete-conflicting-outputs && dart run slang`.

8. **i18n keys go into BOTH `lib/i18n/en.i18n.json` and `lib/i18n/zh.i18n.json`** with symmetric structure. Then re-run slang. Access via `context.t.<path>`.

9. **Cross-feature import is forbidden.** If feature X needs something from feature Y, either (a) extract it into `core/` (preferred), or (b) add `// arch-exempt: <reason>` with a real reason. Do NOT silently import.

10. **Style**: 80-char line width, trailing commas, Chinese `///` doc comments on every public symbol, imports ordered dart → package → relative.

## Adding a new feature (step-by-step)

For a feature named `<name>` (singular, snake_case, e.g. `settings`, `post`, `search`):

1. **Scaffold from template.** Copy `.claude/skills/flutter-arms-feature/assets/feature_template/` to `lib/features/<name>/`. Every path and file-content occurrence of `%feature%` → `<name>`, every `%Feature%` → PascalCase. See `references/checklist.md` for the exact substitution table.

2. **Fill Data layer:**
   - `data/models/<name>_dto.dart` — Retrofit response DTO as `@freezed`; add `toEntity()` extension.
   - `data/datasources/<name>_remote_datasource.dart` — `@RestApi()` interface + `@Riverpod(keepAlive: true)` provider reading `dioProvider`.
   - `data/datasources/<name>_local_datasource.dart` — only if the feature caches data. Wraps `KvStorage`.
   - `data/repositories/<name>_repository_impl.dart` — `implements <Name>Repository` + provider for the repository + one provider per UseCase. See `auth_repository_impl.dart` for the canonical shape.

3. **Fill Domain layer:**
   - `domain/entities/<name>.dart` — `@immutable` plain Dart class with value equality, OR freezed if it has many fields.
   - `domain/repositories/<name>_repository.dart` — abstract class, methods return `Future<Result<T>>`.
   - `domain/usecases/<verb>_<name>_usecase.dart` — one class per UseCase with `const` constructor and `call(...)` method.

4. **Fill Presentation layer:**
   - `presentation/states/<name>_state.dart` — `@freezed` with at least `isLoading`, `error: Failure?`, and your data fields.
   - `presentation/view_models/<name>_view_model.dart` — `@riverpod class <Name>ViewModel extends _$<Name>ViewModel`. `build()` returns initial state. Actions read a UseCase provider, switch on `Result`, update `state`.
   - `presentation/pages/<name>_page.dart` — `@RoutePage()`. Use `ConsumerWidget` if it reads Riverpod state, otherwise `StatelessWidget`. Render errors via `AppDialog.showError(context, context.failureMessage(failure))` inside a `ref.listen`.
   - `presentation/widgets/` — private `_Xxx` widgets, or promote to `lib/shared/widgets/` if reused.

5. **Register the route** in `lib/app/app_router.dart`: add `AutoRoute(page: <Name>Route.page)` to `routes`. Add `guards: <AutoRouteGuard>[_authGuard]` if it needs auth.

6. **Add i18n keys** symmetrically to `lib/i18n/en.i18n.json` AND `lib/i18n/zh.i18n.json` under a `<name>:` namespace.

7. **Run codegen**: `tool/gen.sh`.

8. **Add tests** (see the `flutter-arms-testing` skill):
   - `test/features/<name>/data/repositories/<name>_repository_impl_test.dart`
   - `test/features/<name>/presentation/view_models/<name>_view_model_test.dart`
   - `test/features/<name>/presentation/pages/<name>_page_test.dart` (if the page has meaningful interactions)

9. **Verify**: `tool/test.sh` — analyze + test, including `test/core/architecture_test.dart`.

## When to consult which reference

- **`references/architecture.md`** — layer boundaries, how to read architecture test failures, when to promote code to `core/`, correct use of `// arch-exempt:`.
- **`references/state_management.md`** — Riverpod 3 patterns, ViewModel vs Notifier, `ref.listen` vs `ref.watch`, Freezed state shapes, what NOT to use (StateProvider, ChangeNotifier).
- **`references/networking.md`** — Retrofit interfaces, `.asApi()` boundary, interceptor chain, mock API, where to change timeouts.
- **`references/routing.md`** — AutoRoute declaration, guards, nested routes, how `AuthListenable` reevaluates guards on auth change.
- **`references/storage.md`** — `KvStorage` interface, common vs secure box, adding a new persistent key, feature-local datasources.
- **`references/i18n.md`** — slang workflow, dynamic params, the errors namespace, symmetric JSON requirement.
- **`references/ui_conventions.md`** — private widget classes, shared widgets in `lib/shared/`, theme access via `context.theme`/`context.colors`, error display patterns.
- **`references/checklist.md`** — the placeholder substitution table for the template, plus a common-mistakes list.

Load a reference ONLY when the task actually touches that area. Load multiple references if the task spans areas.

## Template location

`assets/feature_template/` contains the full directory tree with `%feature%` / `%Feature%` placeholders. Copy the tree, substitute both in paths and contents, then fill in real field names, DTO shapes, and endpoint paths. The substitution table is in `references/checklist.md`.
