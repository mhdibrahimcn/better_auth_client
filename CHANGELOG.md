# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2024-01-20

### Changed

- Renamed package to `better_auth_flutter_client` for better discoverability
- Renamed library file to match package name

### Fixed

- Updated all imports to use new package name
- Fixed example app dependencies

## [1.0.0] - 2024-01-20

### Added

- Initial release of better_auth_client package
- Email/password authentication with `SignInModule`
- Email registration with `SignUpModule`
- Session management with `SessionModule`
- OAuth authentication with `OAuthModule` (Google, GitHub, etc.)
- Account management with `AccountModule`
- Secure token storage using flutter_secure_storage
- Reactive session state management using ValueNotifier
- Comprehensive error handling with `AuthError`
- Input validation utilities with `Validators`
- Custom storage interface for testability

### Features

- Type-safe authentication API
- Automatic Bearer token attachment to requests
- Session restoration on app startup
- Session revocation capabilities
- OAuth flow with flutter_web_auth_2

### Dependencies

- dio: ^5.4.0
- flutter_secure_storage: ^9.0.0
- flutter_web_auth_2: ^5.0.0

### Dev Dependencies

- flutter_test: sdk flutter
- flutter_lints: ^3.0.0
- mocktail: ^1.0.0
