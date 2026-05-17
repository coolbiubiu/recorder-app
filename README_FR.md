# Flutter Enregistreur Audio Cross-Plateforme

Une application d'enregistrement audio légère et sans publicité, supportant Android, iOS, Windows et macOS.

## Fonctionnalités

### 🎙️ Trois Modes d'Enregistrement
- **Microphone uniquement**: Enregistre la voix et les sons ambiants (convient pour interviews, notes)
- **Sons système uniquement**: Enregistre l'audio interne du système (convient pour cours en ligne, jeux, films)
- **Enregistrement mixte**: Enregistre simultanément le microphone et les sons système (convient pour commentaires, doublage)

### ⏯️ Fonctionnalités de Base
- Démarrer/Pause/Reprendre/Arrêter l'enregistrement
- Affichage du temps d'enregistrement en temps réel
- Visualisation de la forme d'onde audio en temps réel
- Support de l'enregistrement en arrière-plan
- Sans limite de durée (limité uniquement par l'espace de stockage)

### ⚙️ Configuration Audio
- Format audio: MP3, WAV, AAC, M4A
- Taux d'échantillonnage: 8000Hz / 16000Hz / 44100Hz / 48000Hz
- Débit: 128kbps / 256kbps / 320kbps
- Canaux: Mono / Stéréo

### 📁 Gestion des Fichiers
- Liste des fichiers d'enregistrement
- Recherche et tri des fichiers (par temps/taille/durée)
- Lecture en ligne
- Renommage et suppression
- Partage de fichiers

### 🎨 Caractéristiques de l'Interface
- Design minimaliste et léger
- Mode sombre/clair
- Adaptation à différentes tailles d'écran

## Plateformes Supportées

| Plateforme | Version Minimum | État |
|------------|-----------------|------|
| Android | Android 8.0+ | ✅ |
| iOS | iOS 14.0+ | ✅ |
| Windows | Windows 10+ | En développement |
| macOS | macOS 11.0+ | En développement |

## Stack Technique

- **Framework**: Flutter 3.x
- **Gestion d'état**: Provider
- **Stockage local**: Hive
- **Enregistrement audio**: record
- **Lecture audio**: audioplayers
- **Gestion des permissions**: permission_handler

## Pour Commencer

### Prérequis
- Flutter SDK 3.0+
- Android SDK (pour compilation Android)
- Xcode (pour compilation iOS)

### Installation des Dépendances

```bash
flutter pub get
```

### Exécution de l'App

```bash
# Exécuter la version debug
flutter run

# Compiler l'APK Android
flutter build apk --debug

# Compiler la version release Android
flutter build apk --release

# Compiler pour iOS
flutter build ios --release
```

## Permissions

### Android
- `RECORD_AUDIO` - Permission d'enregistrement
- `WRITE_EXTERNAL_STORAGE` - Permission de stockage
- `READ_MEDIA_AUDIO` - Permission de lecture audio
- `FOREGROUND_SERVICE` - Permission de service en arrière-plan

### iOS
- `NSMicrophoneUsageDescription` - Permission microphone
- `UIBackgroundModes: audio` - Audio en arrière-plan

## Licence

Ce projet est réservé à des fins d'apprentissage et d'échange.

---

**Versions linguistiques**:
- [English](./README.md)
- [한국어](./README_KO.md)
- [日本語](./README_JA.md)
- [Français](./README_FR.md)
- [Tiếng Việt](./README_VI.md)
- [中文](./README_ZH.md)