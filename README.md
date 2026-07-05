# JanAushadhi Sarthak

Lightweight Flutter app to help users find generic medicines from JanAushadhi stores by extracting medicine names from prescription images and searching a live API.

Status
------
- Image-only uploads (JPG/PNG/JPEG). PDF parsing removed.
- Real-time medicine and store search with sanitized error handling.
- Contact page opens automatically on server-side (5xx) errors.

CI / Releases
-------------
- A GitHub Actions workflow (`.github/workflows/build_and_release.yml`) automatically bumps `pubspec.yaml` version on push or manual trigger, builds split-per-ABI and universal APKs, and publishes them to a GitHub Release.

Quick Start
-----------
Prereqs: Flutter SDK, Android SDK (API 21+), Android Studio or VS Code.

Build locally:

```bash
flutter pub get
flutter run --debug
```

Generate release APKs locally:

```bash
flutter build apk --split-per-abi --release    # split APKs
flutter build apk --release                     # universal APK
```

Notes
-----
- The app no longer supports PDF uploads — only images.
- Error messages shown to users are sanitized; server (5xx) errors route users to the Contact tab.
- The repository includes a GitHub Actions workflow that creates releases with APK assets.

Contributing
------------
- Fork, add a branch, make changes, and open a PR.

License
-------
See repository license (if any).
