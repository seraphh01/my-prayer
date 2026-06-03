# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

This is **"Rugăciuni și Cântări - CMD"**, a Flutter/Dart cross-platform prayer app (web/Android/iOS) built with FlutterFlow. See `README.md` for the basics.

### Prerequisites

- **Flutter SDK 3.38.4** (stable channel) is required. The SDK is installed at `/home/ubuntu/flutter` and added to `PATH` via `~/.bashrc`.
- The web target is the primary development platform in cloud environments (no Android SDK or Xcode needed).

### Key commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Lint | `flutter analyze` |
| Run tests | `flutter test` |
| Dev server (web) | `flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080` |
| Build web | `flutter build web` |

### Gotchas

- **Widget test fails**: The single test in `test/widget_test.dart` is a FlutterFlow boilerplate smoke test that does not register the `GetIt` service locator (`PageManager`), so it throws `Bad state: GetIt: Object/factory with type PageManager is not registered`. This is a pre-existing issue; it is not caused by environment setup.
- **`flutter analyze` exits with code 1** due to ~127 pre-existing info/warning-level issues in the FlutterFlow-generated code (`lib/custom_code/` and `lib/flutter_flow/custom_functions.dart` are excluded from analysis via `analysis_options.yaml`). There are no error-level issues.
- **Backend services (Supabase)** are hosted externally. The Supabase anon key is embedded in the codebase. No local database setup is needed.
