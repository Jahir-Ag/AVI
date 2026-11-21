# Decision Log

Approved design and technical decisions. Newest last. Any change to an entry must be discussed and logged as a new entry that supersedes it.

| # | Date | Area | Decision |
|---|---|---|---|
| D01 | 2026-11-21 | Engine | Godot 4.7, GDScript, **Forward+** renderer (needed for 2D HDR/glow and layered depth). |
| D02 | 2026-11-21 | Language | All code, identifiers, comments and commits in **English**. In-game text localized **ES/EN** via translation keys. |
| D03 | 2026-11-21 | Perspective | **Side-view 2D with gravity** (Cuphead-like). Art direction inspired by Cult of the Lamb; depth via parallax layers, foreground, 2D lighting and atmosphere (Silksong-like). |
| D04 | 2026-11-21 | Controls | **One button per action**; direction only aims/orients. Space: jump/double jump · Shift: dodge · N: dash · K: short · L: medium · I: long. Gamepad mapping centralized; **key remapping in MVP**. |
| D05 | 2026-11-21 | Aiming | Cuphead-style: **W aims up, S crouches / aims diagonally down**, attacks usable while moving and airborne. |
| D06 | 2026-11-21 | Input | Input buffer (~100 ms) + coyote time; explicit priority rules so no action swallows another. |
| D07 | 2026-11-21 | Dash vs dodge | **Dodge:** short, longer i-frames, usable in air, triggers perfect-dodge effects. **Dash:** long, few i-frames, repositioning. All values tunable. |
| D08 | 2026-11-21 | Perfect dodge | A dodge is "perfect" when an enemy hitbox overlaps AVI during dodge i-frames. Triggers SURGE passive. |
| D09 | 2026-11-21 | Attack slots | **Typed slots:** short / medium / long, one button each. Player equips **1–3 attacks** (empty slot = inactive button). Default: all 3. |
| D10 | 2026-11-21 | Passives | Player equips **1–3 passives** freely (no category restriction). Default: all 3. |
| D11 | 2026-11-21 | Content | Start: 3 attacks + 3 passives. Each main boss unlocks 1 attack + 1 passive → **6 + 6**. BUG unlocks double jump (separate movement ability, not a passive slot). |
| D12 | 2026-11-21 | Ability names | Same names in ES and EN (single voice-over take). See table below. |
| D13 | 2026-11-21 | Boss phases | **First fight: phases 1–2. Rematch: phases 1–3** (phase 3 = abstract true form). |
| D14 | 2026-11-21 | Fight length | Target **3–4 min** first fight, **4–5 min** rematch (tunable). |
| D15 | 2026-11-21 | Retry | **Instant retry** (Cuphead-style). Defeat screen shows progress reached. |
| D16 | 2026-11-21 | BUG unlock | Defeat **each of the 3 main bosses at least 2 times**. |
| D17 | 2026-11-21 | Art pipeline | **Cutout animation in Godot** (Skeleton2D/AnimationPlayer) from separated parts generated with Gemini. Passive visuals are **attachments** on anchor points. AVI's binary body is a **shader**. |
| D18 | 2026-11-21 | Intro | Built **in Godot** from still illustrations + camera moves + screen-dive shader (no AI video). |
| D19 | 2026-11-21 | Voice | Ability shouts recorded by the author. |
| D20 | 2026-11-21 | Resolution | Base **1920×1080**, stretch `canvas_items`, aspect `expand`. Target 60 FPS. |
| D21 | 2026-11-21 | Camera | Fixed single-screen arenas with screen shake (pending confirmation per arena). |
| D22 | 2026-11-21 | Saves | **3 save slots**, each individually deletable. Versioned JSON in `user://`. |
| D23 | 2026-11-21 | Git | `main` + feature branches per deliverable; Conventional Commits; tags per stage. |
| D24 | 2026-11-21 | License | Code **MIT**; assets all rights reserved; AI use disclosed in README. |

## Ability roster (D12)

### Attacks

| Slot | Starting | Unlock (boss) |
|---|---|---|
| Short (K) | **SCAN**: fast melee combo, no cooldown | **PURGE**: heavy spinning strike, cooldown (Trojan) |
| Medium (L) | **FIREWALL**: projectile that leaves a small fire barrier | **HONEYPOT**: decoy that lures minions and explodes (Phishing) |
| Long (I) | **PING**: fast long-range pulse | **DECRYPT**: piercing beam that breaks shields/chains (Ransomware) |

### Passives

| Effect | Name | Visual attachment | Source |
|---|---|---|---|
| Damage reduction | **ENCRYPTION** | Shield | Starting |
| Move speed | **OVERCLOCK** | Boots | Starting |
| Cooldown reduction | **CACHE** | Glowing chest core | Starting |
| Critical chance | **EXPLOIT** | Red-green blade/claw | Trojan |
| Pulse on perfect dodge | **SURGE** | Pulse aura | Phishing |
| Regeneration | **BACKUP** | Cape / tunic | Ransomware |
| Double jump | **DEBUG** | Insect wings | BUG |

## Open questions

- Platforms per arena (drop-through with S + jump)?
- Reward for beating the 3-phase rematch, beyond counting toward BUG?
- BUG phase count and arena.
- Exact difficulty scaling for rematches (balance pending).
