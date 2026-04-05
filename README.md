# Poliscope

Poliscope is a Flutter application that helps users explore which political current is closest to their views through a visual, opinion-based questionnaire.

Instead of assigning a rigid label, the app compares answers across several political axes and returns the closest matching profiles with a more nuanced reading of the result.

## Features

- Express mode with a shorter question flow for a quick result
- Full mode with the complete questionnaire for a more detailed reading
- Mobile-first UI with animated cards, large touch targets, and clear progress feedback
- Result screen with a main match, top alternative matches, and axis-by-axis positioning
- Cross-platform support with working flows for mobile, desktop, and web

## Experience

The app is built around three main moments:

- A bold landing screen with two entry points: `Express` and `Full`
- A card-based questionnaire flow with immediate answer capture and optional early preview
- A results screen showing the closest profile, strongest matches, and political axis breakdowns

## How It Works

Poliscope uses a bundled questionnaire dataset with:

- 200 questions
- 4 answer options per question
- 5 political axes
- 8 reference political profiles

User answers are translated into axis scores, then compared against the reference profiles to compute the closest matches.

The result is intentionally presented as an indication of proximity, not as a definitive identity.

## Tech Stack

- Flutter
- Dart
- Local bundled questionnaire data
- Native local persistence on supported platforms
- In-memory web fallback for browser builds

## Project Structure

```text
lib/
  main.dart
  src/
    app.dart
    data/
      questionnaire_repository.dart
    models/
      questionnaire_models.dart
    screens/
      home_screen.dart
      questionnaire_screen.dart
      result_screen.dart
    widgets/
      answer_option_card.dart
      axis_score_card.dart
      poliscope_backdrop.dart
assets/
  data/
  fonts/
test/
```

## Getting Started

### Prerequisites

- Flutter SDK installed
- A working Flutter environment (`flutter doctor`)

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

To target Chrome:

```bash
flutter run -d chrome
```

## Quality Checks

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build the web version:

```bash
flutter build web
```

## Design Direction

The interface is designed to feel energetic, readable, and tactile:

- bright editorial color palette
- strong contrast and oversized headings
- glass-like panels and animated background layers
- fast-scanning result cards

## Roadmap Ideas

- Shareable result cards
- Saved sessions and history
- More visual comparisons between profiles
- Deeper explanations for each political axis

## Disclaimer

Poliscope is an exploratory civic tool. It is meant to help users reflect on political proximity and positioning, not to replace deeper reading, debate, or independent research.
