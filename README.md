# Flutter Console UI

A Flutter app with:
- Fixed-height top and bottom bars
- Middle split (left 75% tabs with nested steps, right 25% image viewer)
- "in Cloud" checkbox disables From/To dropdowns
- Console-styled output (white on black, monospaced)
- Dynamic image loader from local storage (works on desktop and web via file picker)

## Requirements
- Flutter SDK (stable channel)
- For desktop: enable platforms
  ```bash
  flutter config --enable-macos-desktop
  flutter config --enable-windows-desktop
  ```

## Run (Standalone Desktop)
### macOS
```bash
flutter run -d macos
```
or build app bundle:
```bash
./build_macos.sh
open build/macos/Build/Products/Release/flutter_console_ui.app
```

### Windows
```powershell
flutter run -d windows
```
or build:
```powershell
.uild_windows.ps1
start .\build\windows\x64\runner\Release\
```

## Run in Web Browser
```bash
flutter run -d chrome
```
or build static site:
```bash
flutter build web
```
Open `build/web/index.html` in a web server.

## Docker (serves web build with Nginx)
```bash
docker build -t flutter-console-ui:latest .
docker run -p 8080:80 flutter-console-ui:latest
# open http://localhost:8080
```

## GitHub Actions
Workflow builds the Docker image for web and uploads it as a tarball artifact.

## Image Loading
Use the **Load Image from Disk** button (right panel) to choose a PNG/JPG. On web this opens a file picker and renders the image in-browser. A default `assets/sample.png` is included.
