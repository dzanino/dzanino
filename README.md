# Meditation Šikuta

Asistované dýchacie cvičenie, modifikovaná Šikutova metóda — iOS + watchOS aplikácia.

## Funkcie

- **Vizuálna animácia** — pulzujúci kruh sa rozťahuje a sťahuje podľa fázy dýchania
- **Hlasové pokyny** — TTS v slovenčine (`AVSpeechSynthesizer`, hlas `sk-SK`)
- **Zvukové tóny** — binaural-friendly frekvencie pre každú fázu (432 Hz, 528 Hz, 396 Hz, 285 Hz)
- **watchOS** — haptic feedback, kompaktné UI, výber vzoru priamo na hodinkách
- **Nastaviteľné vzory** — predvolené + vlastné časovanie (nádych / zadržanie / výdych / pauza)

## Predvolené vzory

| Vzor | Nádych | Zadržanie | Výdych | Pauza | Cykly |
|------|--------|-----------|--------|-------|-------|
| **Šikutova metóda** | 4 s | 7 s | 8 s | — | 8 |
| Box dýchanie | 4 s | 4 s | 4 s | 4 s | 8 |
| Relaxačné | 4 s | — | 6 s | 2 s | 10 |
| Energizačné | 6 s | 2 s | 2 s | — | 12 |

## Štruktúra projektu

```
MeditationSikuta/
├── project.yml                          # XcodeGen konfigurácia
├── Shared/
│   ├── Models/
│   │   ├── BreathingPhase.swift         # Enum fáz, farby, frekvencie, haptics
│   │   └── BreathingPattern.swift       # Model vzoru dýchania
│   ├── ViewModels/
│   │   └── BreathingViewModel.swift     # Logika, timer, stavový automat
│   └── Managers/
│       └── AudioManager.swift           # AVAudioEngine tóny + TTS
├── MeditationSikuta/                    # iOS app
│   ├── App/MeditationSikutaApp.swift
│   └── Views/
│       ├── ContentView.swift
│       ├── BreathingAnimationView.swift
│       └── SettingsView.swift
└── MeditationSikutaWatch/               # watchOS app
    ├── App/WatchApp.swift
    └── Views/
        ├── WatchContentView.swift
        └── WatchBreathingView.swift
```

## Inštalácia a build

### Požiadavky
- Xcode 16+
- iOS 17+ / watchOS 10+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (odporúčané)

### Postup

```bash
# 1. Nainštalovať XcodeGen (ak ešte nie je)
brew install xcodegen

# 2. Vygenerovať Xcode projekt
xcodegen generate

# 3. Otvoriť v Xcode
open MeditationSikuta.xcodeproj
```

Alternatívne: vytvorte nový Xcode projekt ručne (iOS + watchOS) a pridajte súbory zo `Shared/`, `MeditationSikuta/` a `MeditationSikutaWatch/` do príslušných targetov.

## Technológie

- **SwiftUI** — UI pre iOS aj watchOS
- **AVFoundation** — generovanie sínusových tónov, TTS
- **WatchKit** — haptic feedback (`WKInterfaceDevice.play`)
- **Combine** — reaktívny timer v BreathingViewModel
