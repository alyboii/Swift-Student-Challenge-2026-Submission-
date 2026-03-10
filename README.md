# Canteen Hero

**Apple Swift Student Challenge 2026**

---

## The Story

Every school day, millions of children stand in line at the canteen — and many of them struggle to count their change. Not because they are careless, but because nobody ever taught them how.

Canteen Hero was built around that moment. The app places the player behind a school canteen counter in Turkey, where they browse a familiar menu of local snacks, pick what they want to buy, and figure out how to pay with the right coins. The loop is simple, but the skill it builds is real.

The design draws from the Turkish school experience deliberately. The menu items — simit, ayran, tost, pogaca — are things children already know and want. That familiarity lowers the barrier to engagement and makes the financial concepts feel grounded rather than abstract.

---

## What It Teaches

- Coin recognition and denomination values
- Calculating exact change under different constraints
- Budgeting across a session toward a personal savings goal
- Making decisions without hints — building independence

---

## How It Works

Players choose a difficulty level before each session. Easy mode uses small amounts and allows hints. Medium hides the target and offers hints on request. Hard mode removes hints entirely and increases the payment amounts. A savings goal chosen at the start gives each session a purpose beyond the transaction itself.

After each purchase, the app tracks coins saved. Progress toward the goal accumulates across rounds. At the end of a session, a summary shows what was bought, what was saved, and which achievements were unlocked.

---

## Technical Overview

| | |
|---|---|
| Platform | iOS 26 / iPadOS 26 |
| Language | Swift 6 |
| Framework | SwiftUI |
| Format | Swift Playgrounds package (.swiftpm) |

The project is structured around a clear separation of views, view models, models, and services. An on-device AI hint service provides contextual guidance without requiring a network connection. Haptic and speech feedback are layered on top of the visual interface to reinforce correct actions.

---

## Project Structure

```
SSC26.swiftpm/
├── App/
├── Views/
├── Components/
├── Models/
├── ViewModel/
├── Services/
├── Theme/
└── Assets.xcassets/
```

---

## Running the Project

Open `SSC26.swiftpm` in Swift Playgrounds 4 or Xcode 16 and run on any iOS 26 simulator or device.

---

*Developed by Aly — Swift Student Challenge 2026*
