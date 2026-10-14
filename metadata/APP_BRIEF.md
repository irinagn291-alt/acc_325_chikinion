<!-- gf-brief source=73705b266d556a9b5ef1b582ebe8b862c86de8adf8e3ff114830f8d990da45a3 written=2026-10-14T18:40:02+03:00 -->
# Chikinion

## What it is

Chikinion is an offline hands trainer. A live digit rolls on a reel; you pin when it matches the number on the Match plate, then seal a grade. It is for people practising reaction and digit precision who want graded drills on five arms — Precision, Speed, Rhythm, Control, and Endurance — without an account.

## Launch and onboarding

On a cold launch the home title **"Pin the number"** appears first (the line may look faded). A spinner may follow if loading takes a moment.

If onboarding has not been finished, three full pages follow. Each page has a picture, a title, a line, **"Continue"** or **"Start"**, and **"Skip"**.

1. **"Pin the live digit."** / **"Match the prompt on the reel."** — **"Continue"** goes to page 2. **"Skip"** ends onboarding and opens home.
2. **"Roll, then pin."** / **"The window opens on the second tick."** — **"Continue"** goes to page 3. **"Skip"** ends onboarding and opens home.
3. **"Seal files the grade."** / **"The radar moves after five results."** — **"Start"** ends onboarding and opens home. **"Skip"** does the same.

Finish or skip writes the opening roll-speed values (**"Floor 2"**, **"Ceiling 6"**, **"Detent 3"**) and does not show these pages again until **"Run onboarding again"** or **"Reset all data"**.

On a device, home then opens empty (see Screens). On Simulator the first run can skip these pages and open already mid-pass (see Starter content and resume).

## Screens

There is no tab bar. Home stays up. **"Library"**, **"Progress"**, **"Settings"**, and **"Lock"** open as sheets over it. **"Roll"**, **"Pin"**, and **"Seal"** on home are the pass controls, not those sheets. Separate sheets titled **"Roll"**, **"Pin"**, and **"Seal"** also exist; they are not in the chip row. Every sheet has a close mark; VoiceOver reads it as **"Close"**.

### Pin the number (home)

Title: **"Pin the number"**. A decorative tick bar sits under the title. The chip row is **"Library"**, **"Progress"**, **"Settings"**, **"Lock"**.

**Empty (no drill yet)**  
Headline **"Run the first drill"**. Line **"Pin the digit that matches Prompt"**. **"Roll"** starts the first pass and fills the reel. **"Library"**, **"Progress"**, **"Settings"**, and **"Lock"** still open.

**If the reel cannot be read while empty**  
Headline **"The reel could not be read."** The line is the warning (see Behaviours). **"Retry"** tries again.

**After the first Roll**  
A Match plate: caption **"Match"**, then the target number (or the word **"Roll"** while idle) and an arm name (**"Precision"**, **"Speed"**, **"Rhythm"**, **"Control"**, or **"Endurance"**). If an arm is held, a control **"Locked to Precision"** (or that arm, no period) opens **"Axis lock"**.

A large live number (0–9). VoiceOver: **"Live number"** plus that digit. While idle after a seal, the live number reads **0**.

Marks can appear on the time rail: **"Early"**, **"Skew"** plus the live digit at that tap, **"Pin"**.

A five-arm radar shows, for each arm, the latest grade letter or **"-"**, the arm name, and a one-decimal mean. Empty arms read **"-"** and **0.0**.

A short next-step line:

- While rolling: **"Pin when the number reads"** plus the Match number, then a period.
- After a pin: **"File the grade."**
- While idle: **"Start the next pass."**

Refusal and save lines can appear above that (see Behaviours). If a save failed, the warning plus **"Retry"**.

Bottom verbs, one primary and two quieter. Only one is enabled at a time:

- Idle: **"Roll"** starts a pass. **"Pin"** and **"Seal"** stay visible and do nothing.
- Rolling: **"Pin"** tries to pin. **"Roll"** and **"Seal"** stay visible and do nothing.
- Pinned: **"Seal"** files the grade. **"Roll"** and **"Pin"** stay visible and do nothing.

A successful Seal flashes a stamp picture (no words) and returns to idle. A matching Pin, a fresh Roll, and a filed Seal also give a short tap on the device.

**"Roll"** writes a random Match digit from 0–9, starts the live number on a different digit, and advances one face per tick (0 after 9). The first tick is before the window. The window opens on the second tick and stays open for three ticks. **"Pin"** during that window on the matching digit writes **"Pin"** and enables **"Seal"**. **"Seal"** files **S**, **A**, or **B** by which third of the window held the pin (first / middle / last), updates that arm on the radar, and returns to idle.

### Library

Title: **"Library"**.

**Empty**  
**"No plates yet."** / **"Add an axis emphasis for the next roll."** / **"Add a plate"** — if the name is blank it fills **"Precision plate"** (or **"Speed plate"**, and so on, for the Axis already chosen) and adds that plate.

**If the library cannot be read**  
**"Library could not be read."** plus the warning. **"Retry"**.

**With plates**  
Field **"Plate name"**. Menu **"Axis"** with **"Precision"**, **"Speed"**, **"Rhythm"**, **"Control"**, **"Endurance"**. **"Add a plate"** adds the named plate; it does nothing while the name is only spaces. Each row shows the plate name, the arm, and **"Active"** on the arm chosen for the next Roll. Tapping a row chooses that arm, marks **"Active"**, and closes the sheet. There is no delete or rename.

### Progress

Title: **"Progress"**.

**Empty**  
**"No grades filed."** / **"Seal a pin to move an arm."** / **"Close"** dismisses the sheet.

**If progress cannot be read**  
**"Progress could not be read."** plus the warning. **"Retry"**.

**With grades**  
Five rows: latest letter or **"-"**, arm name, one-decimal mean. Then a list, newest first: the grade as a one-decimal score (**100.0**, **80.0**, **60.0**, **40.0**, **20.0**), the arm, and a line like **"S · Oct 14, 2026"** (English month, day, year). Rows are not tappable.

### Settings

Title: **"Settings"**.

**If settings cannot be read and there are no grades and no plates**  
**"Settings could not be read."** plus the warning. **"Retry"**.

**Otherwise**  
When there are no grades and speed is still at the opening values: **"Bounds are still at the opening detent."**  
A save warning, if any, plus **"Retry"**.

Section **"Roll speed"**: steppers **"Floor"** plus 1–12, **"Ceiling"** plus 1–12, **"Detent"** plus 1–12. After onboarding these start at **2**, **6**, and **3**. Floor and Ceiling swap if they cross. Detent stays between them. Two **S** grades in the last three on an arm step Detent up; two **D** grades step it down, still inside Floor and Ceiling.

**"Reset the baseline"** asks **"Clear the radar baseline?"** / **"Grades leave the five arms. Drills stay."** — **"Clear baseline"** or **"Cancel"**. Confirming clears grades, unlocks the arm, shows **"Baseline cleared."**, and leaves home filled (the first drill is still there).

**"Run onboarding again"** closes Settings and shows the three pages. Finish or skip puts speed back to **"Floor 2"**, **"Ceiling 6"**, **"Detent 3"** and keeps plates and grades.

**"Reset all data"** asks **"Reset all data?"** / **"Programs, grades, and history are removed."** — **"Reset all data"** or **"Cancel"**. Confirming wipes the reel and returns to onboarding.

**"Contact"** opens the support page.

### Axis lock

Title: **"Axis lock"**. Opened from **"Lock"** or from **"Locked to …"** on home.

**Empty**  
**"No arm is locked."** / **"After five grades, the next start stays on the weakest arm until it clears the next."** / **"Close"**.

**If lock cannot be read and the list is empty**  
**"Lock could not be read."** plus the warning. **"Retry"**.

**With a lock or refused hops**  
Title line **"Locked to Precision."** (or that arm, with a period) or **"Lock is open."** Caption **"A hop to another arm is refused."** Each refused start is **"Speed refused"** (the requested arm) and **"Held Precision, day"** plus a compact day number.

After five grades, the next **"Roll"** stays on the weakest arm (lowest mean; ties go Precision, then Speed, Rhythm, Control, Endurance) until that arm’s mean is above the next. Starting on another arm is refused, the notice **"Locked to Precision."** (or that arm, with a period) appears, and the hop is listed here. The lock stays open once cleared, until the baseline or all data is reset.

### Roll

Title: **"Roll"**. Caption **"Arm"**, the chosen arm name, **"Speed detent"** plus the Detent number. Chips **"Precision"**, **"Speed"**, **"Rhythm"**, **"Control"**, **"Endurance"** choose the arm for the next start (they do not close the sheet). Status **"Idle"** or **"Live"**, the live digit (or **0** when idle), and **"Match"** plus the target when a pass is live. Section **"Pass"** with **"Early"**, **"Open"**, **"Hold"**, **"Late"**, **"Close"** for the five ticks. **"Start"** begins a pass when idle; it does nothing while a pass is already running.

### Pin

Title: **"Pin"**. **"Pin is accepted only while the number is moving."** The Match number (or **0** when idle). **"The window opens on the second tick and stays open for three."** There is no Pin control here; pin from home.

### Seal

Title: **"Seal"**. **"File a grade only after the number is pinned."** Grade bands:

- **"S"** **"First third"** **100**
- **"A"** **"Middle third"** **80**
- **"B"** **"Last third"** **60**
- **"C"** **"Missed window"** **40**
- **"D"** **"Early or skew"** **20**

There is no Seal control here; seal from home.

## Features

- Offline Roll / Pin / Seal drills on a live 0–9 reel
- Match plate with a target digit and an arm name
- Five arms: **"Precision"**, **"Speed"**, **"Rhythm"**, **"Control"**, **"Endurance"**
- Pin window: opens on the second tick, stays open for three
- Timeline marks **"Early"**, **"Skew"** plus a digit, **"Pin"**
- Grades **S** / **A** / **B** by third of the open window; **C** **"Missed window"**; **D** **"Early or skew"**
- Five-arm radar that updates when a grade is filed
- **"Progress"** list of filed grades and arm means
- **"Library"** plates that set axis emphasis for the next Roll
- **"Roll speed"** **"Floor"**, **"Ceiling"**, **"Detent"** (opening **2**, **6**, **3**)
- Speed steps up after two **S** in the last three on that arm, down after two **D**
- Axis lock after five grades, weakest arm held until it clears the next
- **"Lock"** list of refused hops
- **"Reset the baseline"**, **"Run onboarding again"**, **"Reset all data"**
- **"Contact"**

## Behaviours that can look like bugs

- **"Pin"** and **"Seal"** stay on screen but look muted and do nothing until the pass is rolling or pinned. The lines **"Pin waits for a roll."** and **"Seal waits for a pin."** can appear if a pin or seal is refused. Wait for **"Roll"**, then pin during the window, then **"Seal"**.
- **"Roll"** looks muted during a pass. **"Reel is busy."** can appear if a start is refused then. Seal or let the window end.
- **"Pin"** before the window writes **"Early"** and keeps rolling. Pin again after the second tick, when the live number equals Match.
- **"Pin"** on the wrong digit writes **"Skew"** plus that digit and keeps rolling. Pin again when the faces match, still inside the three open ticks.
- If the window ends while still rolling, a grade is filed with no Seal: **C** if there was no mark, **D** if there was **"Early"** or **"Skew"**. Home returns to **"Start the next pass."**
- Empty home **"Roll"** is the only way to leave **"Run the first drill"**. The chip row works before that.
- **"Add a plate"** on a filled Library does nothing while **"Plate name"** is blank. Type a name, or use empty-state **"Add a plate"**, which fills **"Precision plate"** (or the chosen arm) by itself.
- After five grades, **"Roll"** on another arm is refused. The notice **"Locked to Precision."** (or that arm) appears. Use **"Locked to …"** or **"Lock"** to read it. Keep rolling the held arm, or **"Reset the baseline"** / **"Reset all data"**.
- A Library row can show **"Active"** on an arm that is not the held one; the next **"Roll"** is still refused until the lock clears.
- Match shows the word **"Roll"** and the live number **0** while idle. That is the waiting state. Tap **"Roll"** to get a new target.
- Onboarding says **"The radar moves after five results."** The radar already shows means after the first filed grade. The fifth grade starts the lock, not the first ink.
- **"Run onboarding again"** does not wipe plates or grades; it does put speed back to **"Floor 2"**, **"Ceiling 6"**, **"Detent 3"** when those pages are finished or skipped.
- **"Reset the baseline"** empties **"Progress"** and **"Axis lock"** but does not return home to **"Run the first drill"**.
- **"Reset all data"** returns to the three onboarding pages.
- **"Clear baseline"** / **"Reset all data"** do nothing until the confirm control is tapped; **"Cancel"** leaves data as it is.
- Home lock control reads **"Locked to Precision"** with no period; the lock sheet and the refusal notice add the period.
- Lock rows show **"day"** as a compact number, not the **"Oct 14, 2026"** style used on **"Progress"**.
- Save failures can show **"The reel could not be saved."**, **"Saved drills could not be read. Started empty."**, **"Reset could not remove the saved reel."**, or **"Reset could not remove the reel backup."** **"Retry"** reloads.
- While a verb is working it shows a spinner and ignores a second tap.
- The close mark has no printed word; VoiceOver says **"Close"**.

## Starter content and resume

On a device: none. The first home is **"Run the first drill"** until **"Roll"**.

On Simulator the first run can already be mid-pass: onboarding finished; plates **"Precision plate"** and **"Speed plate"**; four grades filed (**S** Precision, **A** Speed, **B** Rhythm, **C** Control); a live pass already rolling on **"Endurance"** with the window open and the live number one step from Match, so **"Pin"** is the enabled verb.

A pass that is rolling or pinned is kept if you leave and come back, so **"Pin"** or **"Seal"** can still be used. Mid-onboarding is not kept: a kill during the three pages starts again at **"Pin the live digit."** Plates and grades stay until a reset.

## Permissions

None.

## Absent

Login or accounts, in-app purchase, ads, analytics, user-generated content (plates are local names only), account deletion flow, and an App Tracking Transparency prompt are all absent.

## Data and support

Data stays on this device. **"Contact"** in **"Settings"** opens the support page.

## Scanning and health

None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information.

## Platform

English only. Progress dates use English month names. Whole numbers and one-decimal means follow the device decimal style, without grouping. Light appearance only. Portrait only, iPhone and iPad. Minimum iOS 17.0.

## Category

Education.
