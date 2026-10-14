# Pinion — Build Specification

> Portfolio app 188, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Train reaction and digit precision with graded offline drills and a five-axis skill radar.

| Field | Value |
| --- | --- |
| Product name | Pinion |
| Bundle identifier | `com.pinion.reel` |
| Domain | https://pinion-reel.pro |
| Contact URL | https://pinion-reel.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `pin_` |
| User-Agent | `Pinion/1.0 (iOS; +https://pinion-reel.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Pinion -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A hands trainer rolls the live digit reel and pins when the odometer matches the lit prompt so the drill files a grade and the five-axis radar moves.

### 2.1 User flow

1. Tap Pin when the rolling digit matches the lit Prompt on the command row
2. Tap Roll to start the next generated drill on the active axis
3. Tap Seal after the pin window to file the Result and update the radar
4. Open the Library sheet to pick a Program or change axis emphasis
5. Open the Progress sheet to read the five-axis radar and past Results
6. Open Settings to tune roll speed bounds and reset the radar baseline

### 2.2 Essential behaviour

- Offline generated roll drills tagged to precision, speed, rhythm, control, and endurance
- Live odometer reel with command-row Prompt and session timeline
- S/A/B/C/D Results that nudge the five-axis radar after each Seal
- Adaptive roll speed from the last three grades on the active axis
- Weak-axis spotlight after five Results until that arm clears the next-weakest mean
- Local Program library and session history with no account or cloud sync

---

## 3. Uniqueness assignment for Pinion

| Axis | Assigned value |
| --- | --- |
| Architecture | **Reel ADT fold (Idle | Rolling | Pinned | Sealed); the lane is a fold over Drills; Roll writes a Prompt for one Axis, starts the odometer, and folds Idle to Rolling; Pin on Rolling when the live Digit equals Prompt writes a PinMark and folds Rolling to Pinned; Pin while Digit mismatches writes SkewMark and keeps Rolling until the window ends; Pin before the window opens writes EarlyMark and keeps Rolling; Seal writes a Result and folds Pinned to Idle; Seal on Idle or Rolling is refused; a second Roll while Rolling or Pinned is refused; after five Results Roll samples only the weakest Radar arm until it clears the next-weakest; empty lane writes Bare** |
| UI approach | **SwiftUI Layout protocol · timeline** |
| Naming convention | **Reel / chronograph lexicon (Reel, Prompt, Digit, Roll, Pin, PinMark, SkewMark, EarlyMark, Result, Radar, LockMark, Program, Seal)** |
| File organization | **By reel role (Reel, Prompt, Digit, Roll, PinMark, SkewMark, EarlyMark, Result, Radar, Program, LockMark, Seal)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **ibm · cabinet · duotone** |
| Typography | **DIN Condensed** |
| Navigation pattern | **Reel-locked chrome (the numeric reel and prompt row never leave; Library, Progress and Settings arrive as sheets; roll and pin fuse on Practice)** |
| AI art style | **Flat corporate vector data viz · photography-driven** |
| Functional twist | **Roll-then-pin with axis lock (Pin only while Rolling; SkewMark on mismatch; EarlyMark before window; Seal grades; after five Results Roll locks to weakest radar arm; LockMark refuses axis hop while locked)** |
| Persistence | **UserDefaults+Codable · one Reel root record holding Programs, Sessions, Results and RadarArms, encoded under a single key with debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — skill_drills

**Core** — A hands trainer rolls the live digit reel and pins when the odometer matches the lit prompt so the drill files a grade and the five-axis radar moves.

**Audience** — People training reaction and digit precision offline who want graded drills and a skill radar, not a spatial echo game and not a single high-score arcade board.

**User flow**

1. Tap Pin when the rolling digit matches the lit Prompt on the command row
2. Tap Roll to start the next generated drill on the active axis
3. Tap Seal after the pin window to file the Result and update the radar
4. Open the Library sheet to pick a Program or change axis emphasis
5. Open the Progress sheet to read the five-axis radar and past Results
6. Open Settings to tune roll speed bounds and reset the radar baseline

**Essential features**

- Offline generated roll drills tagged to precision, speed, rhythm, control, and endurance
- Live odometer reel with command-row Prompt and session timeline
- S/A/B/C/D Results that nudge the five-axis radar after each Seal
- Adaptive roll speed from the last three grades on the active axis
- Weak-axis spotlight after five Results until that arm clears the next-weakest mean
- Local Program library and session history with no account or cloud sync

**Twist** — Roll-then-pin with axis lock. Home is the numeric reel and command row. Roll writes a Prompt for one Axis, starts the odometer, and folds Idle to Rolling. Pin on Rolling when the live Digit equals Prompt writes a PinMark and folds Rolling to Pinned; Pin while Digit mismatches writes SkewMark and keeps Rolling until the window ends; Pin before the window opens writes EarlyMark and keeps Rolling. Seal writes a Result with grade S/A/B/C/D, updates that Axis on the radar, and folds Pinned to Idle. Seal on Idle or Rolling is refused. A second Roll while Rolling or Pinned is refused. After five Results, Roll samples only the weakest radar arm until its rolling mean exceeds the next-weakest; Roll on another Axis while locked writes LockMark and is refused. Two of the last three grades ≥ S step roll speed up; two D step down. Seed already Roll into Rolling with the odometer one tick from matching the lit Prompt so the opening tap is Pin. Home verb: pin-the-digit — not echo-the-cue and not chase-a-high-score. Local only.

**Why this is not a repeat** — Same family as Quintain (offline drills plus five-axis radar) but the home verb is pin-the-digit on a rolling odometer, not echo-the-cue on a flashed spatial Pattern; architecture is Reel ADT, UI is SwiftUI Layout timeline, design ibm cabinet duotone, and navigation is reel-locked rather than playfield-locked.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: One playfield + 5-axis radar.
- Invariant: Need ≥5 samples to recommend the weakest axis. Adaptive: 2 of last 3 ≥S → step up; 2 D → step down. Radar: precision/speed/rhythm/control/endurance.
- Never: Offline generated drills. No course reader.
- Desk `cue_punctuality`: fireAt=runStart+Σprior+offset; punctuality=1−min(1,|actual−planned|/1.5s).
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The live session is a Reel algebraic type with cases Idle, Rolling, Pinned, and Sealed, and the lane is a fold over Drills where an empty lane writes Bare. Roll is accepted only from Idle: it writes a Prompt, one digit from 0 through 9, for one Axis, starts the odometer, and folds Idle to Rolling, and a second Roll while Rolling or Pinned is refused. Pin on Rolling writes PinMark and folds to Pinned when the live Digit equals Prompt during the window, writes SkewMark and stays Rolling until the window ends on a mismatch, and writes EarlyMark and stays Rolling when the tap comes before the window, which opens on the second tick and stays open for three ticks. Seal is accepted only from Pinned, writes a Result, records the drill as Sealed, and folds the live Reel to Idle; Seal on Idle or Rolling is refused. If the window ends while still Rolling, the fold files the miss Result, C when no mark was written and D when EarlyMark or SkewMark was written, records Sealed, and returns the live Reel to Idle so the lane cannot stick. After five Results, Roll samples only the weakest Radar arm, breaking ties in the order precision, speed, rhythm, control, endurance, until that arm's rolling mean exceeds the next-weakest mean, and a Roll for another Axis while locked writes LockMark and is refused.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Practice uses one SwiftUI Layout as its timeline, and that Layout is the only custom surface. The live Digit is a large left-weighted readout, the command-row Prompt is a labeled plate above it, and PinMark, SkewMark, and EarlyMark sit on a horizontal time axis that fills the remaining width, including on iPad. The compact Radar sits in that same hero, lower and smaller, drawn with Shape, so the screen is one instrument rather than three equal cards. Roll, Pin, and Seal are native Buttons with one primary ButtonStyle for default, pressed, disabled, and loading, and a destructive style only for reset. Each hit target is the whole capsule, at least 44 points. Pin is enabled only while Rolling, Seal only while Pinned, and Roll only while Idle. Library, Progress, and Settings are stock List and Form sheets, one open at a time. Seal is the only spring, response 0.4 and damping 0.8. Other motion is ease-out. Reduce Motion fades the tick and does not spring. Grade letters accompany any arm tint so colour is not the only signal.

### 3.3 Naming contract

Convention: Reel / chronograph lexicon (Reel, Prompt, Digit, Roll, Pin, PinMark, SkewMark, EarlyMark, Result, Radar, LockMark, Program, Seal).

Examples to follow: `Reel`, `roll(axis:)`, `PinMark`, `RadarArm`

### 3.4 Dependency contract

No Swift Package Manager packages, no CocoaPods, and no vendored source. project.yml has no packages key. The only allowed system frameworks are UIKit, Core Graphics, AVFoundation, and URLSession. This product does not capture and does not search a catalog, so no capture session is created and cgi search is not called. Drills are generated on device.

### 3.5 Navigation contract

Reel-locked chrome: the numeric reel and the command-row Prompt stay mounted for the whole session, and there is no TabView. Roll and Pin are actions on Practice, not routes. Library, Progress, and Settings arrive as sheets over that reel, one at a time, leaving a lip of the prompt row visible so the shot is still a different screen. After onboarding, read ProcessInfo.processInfo.arguments once. The launch key today leaves Practice in place. The key log presents the Progress sheet. The key goals presents the Library sheet. The key settings presents the Settings sheet. today, log, and goals must show three different frames. Dismissing a sheet returns to the same reel, still in its current fold case.

### 3.6 Screen composition contract

Practice-root numeric reel (Practice holds Roll, Pin, Seal and the live digit timeline; Library, Progress and Settings arrive as sheets; no tab bar). Physical screens: Onboarding, Practice, Library, Progress, Settings. Onboarding is three full-page steps with Continue full width at the bottom. It writes default speed bounds and a completion flag. Skip writes the same defaults. Settings can run it again. Practice is the root and the mechanic: live Digit reel, command-row Prompt, session timeline, compact Radar, and the buttons Roll, Pin, and Seal. It is not a list of records. An empty lane is a full-page Bare state with generated art, the headline Run the first drill, the line Pin the digit that matches Prompt, and a full-width Roll button. Simulator seed pin.demo.v1 runs once, marks onboarding complete, files four Results so the radar has ink, and leaves the reel Rolling with the window already open and the odometer one tick from the lit Prompt, so Pin is the enabled primary verb. The five-result axis lock is a test fixture, not that first frame. Library is a sheet of local Programs, which are axis-emphasis presets, not a course. Its empty state is a full page. Progress is a sheet with the five-arm Radar and past Results, each row showing the grade letter and the axis name. Settings is a sheet for roll speed bounds, a confirmed reset of the radar baseline, re-run onboarding, confirmed reset of all data, and the contact link https://pinion-reel.pro/contact-us. Launch keys, read once after onboarding, are not tabs: today stays on Practice, log opens Progress, goals opens Library, settings opens Settings.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By reel role (Reel, Prompt, Digit, Roll, PinMark, SkewMark, EarlyMark, Result, Radar, Program, LockMark, Seal)**

```
Pinion/
  Reel/Reel.swift
Prompt/Prompt.swift
Digit/Digit.swift
Roll/Roll.swift
PinMark/PinMark.swift
SkewMark/SkewMark.swift
EarlyMark/EarlyMark.swift
Result/Result.swift
Radar/Radar.swift
Program/Program.swift
LockMark/LockMark.swift
Seal/Seal.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Practice
A first-class screen for **Practice**. Must render empty, populated and error states.

### 5.3 Library
A first-class screen for **Library**. Must render empty, populated and error states.

### 5.4 Progress
A first-class screen for **Progress**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Drill** — named per this app's convention.
- **Result** — named per this app's convention.
- **Program** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **ibm · cabinet · duotone**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#EFEDE7` | Screen background |
| `surface` | `#F5F6F3` | Cards, rows, sheets |
| `ink` | `#2A2614` | Primary text and icons |
| `accent` | `#668B0E` | Primary action, key figure, progress fill |
| `muted` | `#686246` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Pinion/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **DIN Condensed**

DIN Condensed only, face DINCondensed-Bold, through one accessor of six steps: display, title, headline, body, caption, and micro. Build each step with Font.custom using the name DINCondensed-Bold and a size relative to a text style so Dynamic Type scales it. Do not call fixedSize and do not add a second family. The live Digit uses display, the Prompt uses title, grades use headline, and body stays near 17 points before scaling. Headlines stay within two lines. Grades, speed detents, radar means, and day keys go through NumberFormatter. Use ScaledMetric for the digit box. At the largest accessibility size, keep Prompt and Digit on one line by tightening tracking on this same face.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **24pt** for cards, sheets and primary surfaces; **10pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI Layout protocol · timeline**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI Layout protocol · timeline** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **ibm** — steal rhythm and restraint, not their colours or logos.

Mood: **Enterprise technology. Carbon design system, structured blue palette.**.

Home rhythm (`cabinet`, comfortable): Drawers and labels. Open one. Do not show every drawer open.

High-end agency: huge type, air, one accent, hairline depth. Layout `cabinet`, density comfortable. Kit 24/10, material, filled capsule. Palette recipe `duotone`. One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Editorial measure, generous leading, one rule. Reference type feel: agency.

Motion (`spring`): One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring.

Voice (`dry`): Short verbs. No warmth padding. 'Saved.' not 'Your changes were saved successfully.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Reel root record holding Programs, Sessions, Results and RadarArms, encoded under a single key with debounced save after each mark**

One Codable Reel root lives in UserDefaults under the single key pin.reel.v1. The root holds schemaVersion, Programs, Sessions, Results, and five RadarArms, plus the marks written during a live drill. PinMark, SkewMark, EarlyMark, LockMark, and Result each mutate that root and schedule one debounced save. Flush when scenePhase becomes inactive or background, and flush immediately on reset. Each Result stores its day as an Int in YYYYMMDD form, taken from Calendar.current.startOfDay. The UI talks only to the Reel store seam, never to UserDefaults. resetAllData() deletes that key and is available from Settings. Simulator seed pin.demo.v1 is a separate versioned flag, runs once under targetEnvironment(simulator), and is not written on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Pinion/1.0 (iOS; +https://pinion-reel.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.education`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.education
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Roll-then-pin with axis lock (Pin only while Rolling; SkewMark on mismatch; EarlyMark before window; Seal grades; after five Results Roll locks to weakest radar arm; LockMark refuses axis hop while locked)

Home is pin-the-digit, and the Simulator seed is already Rolling with the odometer one tick from the lit Prompt so the opening tap is Pin. Roll writes a Prompt for one Axis and folds Idle to Rolling; Pin is accepted only while Rolling, a second Roll while Rolling or Pinned is refused, and Seal is refused on Idle or Rolling. A Digit that matches Prompt writes PinMark and folds to Pinned, a mismatch writes SkewMark and stays Rolling until the window ends, and a Pin before the window opens writes EarlyMark and stays Rolling. Seal from Pinned files S, A, or B by which third of the open window held the PinMark, and a window that ends still Rolling files C when no mark was written or D when EarlyMark or SkewMark was written. That Result updates the matching Radar arm, one of precision, speed, rhythm, control, and endurance, to the mean of its grade points, where S is 100, A is 80, B is 60, C is 40, and D is 20, and the live Reel then returns to Idle. No arm is called weakest until five Results exist; after that, Roll samples only the weakest arm until its rolling mean exceeds the next-weakest mean, a Roll on another Axis writes LockMark and is refused, and two of the last three grades at S or above step the roll-speed detent up while two D grades step it down inside the Settings bounds.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Flat corporate vector data viz · photography-driven**


Base prompt, reused and extended for every asset:

```
Flat corporate vector data visualization with a photographed instrument pressed into the chart. Hard edges, hairline rules, labeled plates, one solid subject centered. Documentary photography, frontal and flattened, not a render and not clay. Two-tone print, no extra hues, no words, no glass, no hollow frame.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `pin_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `pin_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `pin_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `pin_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `pin_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `pin_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `pin_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `pin_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `pin_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `pin_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `pin_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Roll-then-pin with axis lock (Pin only while Rolling; SkewMark on mismatch; EarlyMark before window; Seal grades; after five Results Roll locks to weakest radar arm; LockMark refuses axis hop while locked)' feature screen. |
| 11 | `pin_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `pin_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`pin_AppIcon`** — 1024x1024

```
A solid pinion gear filling the canvas edge to edge, hub as a closed metal window, photographed flat and redrawn as corporate vector. No text, no numerals, no rounded mask, no transparency, no shadow outside the canvas.
```

**`pin_Splash`** — 1290x2796

```
Vertical photograph of a metal odometer housing, flattened into corporate vector, hairline tick rules in the margins, quiet empty center band. Fills the canvas. No text.
```

**`pin_Onboarding1`** — 1024x1536

```
A photographed hand hovering over a solid metal digit reel, subject centered and fully opaque, documentary and frontal, redrawn as flat corporate vector.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`pin_Onboarding2`** — 1024x1536

```
A photographed finger pressing a solid pin key onto a digit reel at the moment of a match, mid gesture, opaque subject centered, flat corporate vector.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`pin_Onboarding3`** — 1024x1536

```
A solid five-arm radar plate with five filled spokes of unequal length, photographed metal, flat corporate vector, centered, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`pin_EmptyHome`** — 1024x1024

```
A closed solid metal instrument case, fully opaque, latched, centered. Not glass, not a hollow frame, not a wire outline. Flat corporate vector over a documentary photo of the case.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`pin_EmptyList`** — 1024x1024

```
A single closed drawer front, solid and opaque, empty of contents, centered. Not glass. Flat corporate vector.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`pin_CardBackdrop`** — 1200x800

```
An abstract field of hairline chart rules and soft photographic grain, low contrast, filling the canvas edge to edge, no central object, no text.
```

**`pin_ControlFace`** — 512x512

```
The face of a solid round pin key, photographed metal, opaque center, not a hollow ring, centered. Flat corporate vector.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`pin_TwistHero`** — 1024x1024

```
A solid reel drum crossed by a lock bar, one spoke left clear, opaque metal, centered, no text. Flat corporate vector.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`pin_SuccessMark`** — 512x512

```
A solid filled metal seal stamp occupying the center, thick and opaque, not an outline and not a hollow ring. Flat corporate vector.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`pin_HeaderDecor`** — 1200x600

```
A wide horizontal bar of odometer tick marks, solid photographic metal edge, flat corporate vector, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`pin.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `PinionTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Pinion/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Pinion -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Reel ADT fold (Idle | Rolling | Pinned | Sealed); the lane is a fold over Drills; Roll writes a Prompt for one Axis, starts the odometer, and folds Idle to Rolling; Pin on Rolling when the live Digit equals Prompt writes a PinMark and folds Rolling to Pinned; Pin while Digit mismatches writes SkewMark and keeps Rolling until the window ends; Pin before the window opens writes EarlyMark and keeps Rolling; Seal writes a Result and folds Pinned to Idle; Seal on Idle or Rolling is refused; a second Roll while Rolling or Pinned is refused; after five Results Roll samples only the weakest Radar arm until it clears the next-weakest; empty lane writes Bare** with no leakage across layers.
- [ ] UI approach matches **SwiftUI Layout protocol · timeline**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Reel-locked chrome (the numeric reel and prompt row never leave; Library, Progress and Settings arrive as sheets; roll and pin fuse on Practice)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **DIN Condensed** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Pinion
xcodegen generate
xcodebuild build-for-testing -scheme Pinion -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.pinion.reel/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Pinion -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.pinion.reel/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Pinion -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.pinion.reel/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
