# FlutterSampleLocalData

Aplikacja demonstracyjna pokazująca trzy sposoby lokalnej persystencji danych dla prostego modelu notatki (Note):
- przechowywanie w preferencjach (SharedPreferences) jako klucze i wartości,
- zapis i odczyt całej listy do pliku JSON w katalogu dokumentów aplikacji,
- baza SQLite z migracją schematu (dodanie kolumny na tagi oraz indeksu po dacie).

## Cel projektu
Chcę w jednym miejscu porównać różne podejścia do zapisu danych lokalnych w aplikacji mobilnej. Każda technika ma inną charakterystykę: preferencje są proste, plik JSON pozwala na szybki zapis całej kolekcji, a SQLite daje elastyczne zapytania i migracje.

## Model danych
Note posiada pola: id, title, content, createdAt oraz tags (lista tekstów). Czas zapisywany jest jako liczba milisekund od epoki. Tag-i w SQLite trzymane są w kolumnie JSON (tekstowo) dla uproszczenia.

## Ekrany
1. Ekran wyboru rodzaju magazynu danych (Preferences / JSON File / SQLite).
2. Ekran operacji: Seed 10, Add, Edit First, Delete First, Clear oraz lista aktualnych notatek. Przy dłuższych operacjach pojawia się blokująca nakładka z loaderem.

## Struktura (wycinek)
```
lib/
  data/
    models/note.dart
    repo/
      storage_repository.dart
      prefs_repository.dart
      file_repository.dart
      sqlite_repository.dart
    storage_kind.dart
  services/
    json_codec.dart
    file_paths.dart
    sqlite_migrations.dart
  ui/
    home_screen.dart
    run_screen.dart
    widgets/
      note_editor.dart
      progress_overlay.dart
```

## Sposoby zapisu
- Preferences: każdy obiekt jako osobny klucz + indeks identyfikatorów.
- JSON File: jedna kolekcja serializowana do `notes.json` (przy większych danych parsing w tle z `compute`).
- SQLite: tabela `notes` z kolumnami (id, title, content, created_at, tags_json) oraz indeks po dacie; migracja dodaje kolumnę i indeks jeśli brak.

## Jak uruchomić
```
flutter pub get
flutter run
```
Aby zbudować APK release:
```
flutter build apk --release
```
