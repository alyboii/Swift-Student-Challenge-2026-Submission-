# Canteen Hero — Swift Student Challenge 2026

> Learn money. One coin at a time.

A financial literacy game for children ages 6–10, inspired by a real Turkish schoolcanteen.

## About

Canteen Hero teaches children how to handle money through a 3-minute interactive canteen simulation. Players get 50 Canteen Coins, buy items from a Turkish-inspired menu (Simit, Ayran, Tost, Poğaça), and calculate the correct change using drag-and-drop coins.

## Tech Stack

- **SwiftUI** — iOS 26, @Observable, GlassEffect (Liquid Glass)
- **SpriteKit** — Coin physics introduction scene  
- **Swift Charts** — Spending visualization
- **Foundation Models** — On-device AI hints (Apple Intelligence)
- **CoreHaptics + AVSpeechSynthesizer** — Multi-sensory feedback
- **Dynamic Type + VoiceOver** — Full accessibility

## Privacy by Design

All data stays on-device. No network requests, no analytics, no tracking. AI-generated hints are processed entirely on-device through Apple's Foundation Models framework. When Apple Intelligence isn't available, the app falls back to a built-in hint engine — so no child is left behind, and no data ever leaves the device.

---

## 📝 SSC 2026 Essay — Beyond My Submission

I'm a student developer from Turkey who grew up watching my father run a school canteen. Every day, I saw kids struggle with something adults take for granted — handling money and calculating change. Some walked away without their change, not because they didn't care, but because money felt too abstract.

Canteen Hero was born from that observation: what if learning about money felt like playing a game?

### What It Does

The complete experience fits in about 3 minutes. Players start with 50 Canteen Coins, pick from a Turkish-inspired menu — Simit (Sesame Ring), Ayran (Yogurt Drink), Tost (Grilled Sandwich), Poğaça (Pastry) — then drag-and-drop coins to calculate the correct change. Three difficulty levels adapt the challenge, from visible targets with hints to a timed countdown with no guidance.

### Apple Technologies

I built Canteen Hero entirely in SwiftUI, embracing Apple's latest design language. **Liquid Glass** effects bring depth and translucency to headers, cards, and buttons. **SpriteKit** powers an interactive coin physics scene where children learn denominations by dropping and touching coins. **PhaseAnimator** and **KeyframeAnimator** create playful celebrations. **Swift Charts** visualizes spending patterns. **CoreHaptics** and **AudioToolbox** add multi-sensory feedback — each coin denomination has a unique haptic signature. **AVSpeechSynthesizer** narrates the entire experience so the app works even for early readers. And **Foundation Models** generates personalized, age-appropriate hints based on the exact coins a child has placed — without ever revealing the answer.

### Everyone Can Code

Canteen Hero embodies Apple's *Everyone Can Code* mission. Financial literacy shouldn't depend on a child's background, ability, or language. That's why every screen supports **Dynamic Type** for text scaling, complete **VoiceOver** labels and hints, **Reduce Motion** alternatives for every animation, and **color blindness–safe** coin shapes. I even added Apple's **Pride colors** to achievement badges and progress rings — because inclusivity isn't an afterthought, it's a design principle.

### Privacy by Design

True to Apple's values, all data stays on-device. The AI hint system uses Foundation Models for local inference — no network requests, no cloud processing, no tracking. When Apple Intelligence isn't available, the app gracefully falls back to its built-in hint engine. No child is excluded, and no data ever leaves the device.

### What I Learned

I tested early builds with children ages 6–10. Their feedback directly shaped the design: removing jargon, enlarging tap targets, adding voice narration, and adjusting difficulty so both a first-grader and a fourth-grader find their own challenge. Building for children taught me that simplicity is harder than complexity — every interaction needed to be intuitive for a 6-year-old while remaining educational.

Financial literacy starts young — studies show children form money habits by age 7. Canteen Hero makes that critical learning window engaging and accessible, regardless of background or ability.
