# Pinion

Pinion is an offline hands trainer. You roll a live digit, pin when it matches the lit prompt, and seal a grade. People training reaction and digit precision get a five-axis radar (precision, speed, rhythm, control, endurance) without an account or a cloud sync.

## Architecture

The live session is a reel algebraic type: Idle, Rolling, Pinned, Sealed. The lane is a fold over drills. An empty lane is Bare. Roll is accepted only from Idle: it writes one prompt digit for one axis, starts the odometer, and folds Idle to Rolling. A second roll while Rolling or Pinned is refused. Pin on Rolling writes a PinMark and folds to Pinned when the live digit equals the prompt inside the window, a SkewMark and stays Rolling on a mismatch, and an EarlyMark and stays Rolling when the tap comes before the window. The window opens on the second tick and stays open for three ticks. Seal is accepted only from Pinned: it writes a Result and returns the live reel to Idle. Seal on Idle or Rolling is refused. If the window ends while still Rolling, the fold files the miss (C with no mark, D when EarlyMark or SkewMark was written) and returns to Idle so the lane cannot stick. After five results, roll samples only the weakest radar arm, ties broken precision, speed, rhythm, control, endurance, until that arm's mean exceeds the next-weakest. A roll on another axis while locked writes a LockMark and is refused.

This fits the product because the home verb is a timed match on one moving digit. The cases are the only legal taps. Storage is a separate seam: one Codable reel root under a single key, saved on a debounce after each mark. Views talk to the store, not to the fold and not to UserDefaults.

## Twist

Roll, then pin, with an axis lock. Home is the numeric reel and the command-row prompt, not a list of records. Two of the last three grades at S step roll speed up. Two D grades step down. The lock screen lists refused hops. Practice shows the held arm on the prompt plate.

## Look

IBM cabinet, duotone, DIN Condensed. One hero timeline (SwiftUI Layout) holds the digit, the prompt, the mark rail, and a compact radar drawn with Shape. Library, Progress, and Settings are sheets. There is no tab bar.

Art direction is flat corporate vector over photography. Asset prompts:

- pin_AppIcon: A solid pinion gear filling the canvas edge to edge, hub as a closed metal window, photographed flat and redrawn as corporate vector. No text, no numerals, no rounded mask, no transparency, no shadow outside the canvas.
- pin_Splash: Vertical photograph of a metal odometer housing, flattened into corporate vector, hairline tick rules in the margins, quiet empty center band. Fills the canvas. No text.
- pin_Onboarding1: A photographed hand hovering over a solid metal digit reel, subject centered and fully opaque, documentary and frontal, redrawn as flat corporate vector. Hard cutout, transparent corners.
- pin_Onboarding2: A photographed finger pressing a solid pin key onto a digit reel at the moment of a match, mid gesture, opaque subject centered, flat corporate vector. Hard cutout, transparent corners.
- pin_Onboarding3: A solid five-arm radar plate with five filled spokes of unequal length, photographed metal, flat corporate vector, centered, no text. Hard cutout, transparent corners.
- pin_EmptyHome: A closed solid metal instrument case, fully opaque, latched, centered. Flat corporate vector over a documentary photo of the case. Hard cutout, transparent corners.
- pin_EmptyList: A single closed drawer front, solid and opaque, empty of contents, centered. Flat corporate vector. Hard cutout, transparent corners.
- pin_CardBackdrop: An abstract field of hairline chart rules and soft photographic grain, low contrast, filling the canvas edge to edge, no central object, no text.
- pin_ControlFace: The face of a solid round pin key, photographed metal, opaque center, not a hollow ring, centered. Flat corporate vector. Hard cutout, transparent corners.
- pin_TwistHero: A solid reel drum crossed by a lock bar, one spoke left clear, opaque metal, centered, no text. Flat corporate vector. Hard cutout, transparent corners.
- pin_SuccessMark: A solid filled metal seal stamp occupying the center, thick and opaque, not an outline and not a hollow ring. Flat corporate vector. Hard cutout, transparent corners.
- pin_HeaderDecor: A wide horizontal bar of odometer tick marks, solid photographic metal edge, flat corporate vector, no text. Hard cutout, transparent corners.

## How this differs

Same family as a drill-and-radar trainer, but the home verb is pin-the-digit on a rolling odometer, not echo-the-cue on a flashed spatial pattern. Navigation keeps the reel mounted. Library, Progress, and Settings arrive as sheets.

## Build

```bash
cd apps/Pinion
xcodegen generate
xcodebuild build-for-testing -scheme Pinion -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```

Launch keys, read once after onboarding: `-ReviewScreen today` stays on Practice, `log` opens Progress, `goals` opens Library, `settings` opens Settings, `lock` opens the axis lock, `roll` opens the arm list, `pin` opens the match plate, `seal` opens the grade bands. Simulator seed `pin.demo.v1` marks onboarding complete, files four results, and leaves the reel Rolling with Pin enabled.
