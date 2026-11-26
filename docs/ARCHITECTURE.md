# Architecture

Technical design for AVI. Decisions referenced as `Dxx` live in [DECISIONS.md](DECISIONS.md).

## Principles

1. **Greybox first.** Every system is built and tested with placeholder shapes. Code never waits for art.
2. **Data in Resources.** Damage, cooldowns, health, phases and passives live in `.tres` files editable in the inspector.
3. **Logic separate from presentation.** Controllers emit state; visual scenes decide how it looks. Swapping art never touches gameplay code.
4. **Composition over inheritance**, except for `BossBase`, which each boss extends.
5. **No dependencies** beyond Godot itself unless justified.

## Autoloads

| Autoload | Responsibility |
|---|---|
| `Events` | Global signal bus (`boss_defeated`, `player_died`, `unlock_granted`, ...) |
| `GameState` | Current save data: victories per boss, unlocks, equipped loadout |
| `SaveManager` | 3 slots, versioned JSON in `user://saves/` (D22) |
| `SceneRouter` | Scene changes with transitions (fade / glitch) |
| `AudioManager` | Music/SFX/Voice buses, one-shot helpers |
| `Settings` | Language, volumes, display, input remapping (persisted separately from saves) |
| `DebugTools` | F1 hitboxes, F2 invincibility, F3 skip phase, tuning overlay (debug builds only) |

## Input

Default bindings live in `autoload/input_defaults.gd` (`InputDefaults`) and are applied by `Settings` at startup, so remapping (stage 13) only overrides this single table.

| Action | Keyboard | Gamepad |
|---|---|---|
| `move_left` / `move_right` | A / D | Left stick, D-pad |
| `look_up` / `look_down` | W / S | Left stick, D-pad |
| `jump` | Space | A |
| `dodge` | Shift | B |
| `dash` | N | RT |
| `attack_short` | K | X |
| `attack_medium` | L | Y |
| `attack_long` | I | RB |
| `pause` | Esc | Start |

Debug keys (F1–F4) are hard-coded in `DebugTools` and only exist in debug builds.

## Data (custom Resources)

| Resource | Key fields |
|---|---|
| `PlayerTuning` | move speed, jump height, gravity, dash/dodge distance, duration, i-frames, cooldowns, hurt i-frames |
| `AttackData` | `id`, `slot` (SHORT/MEDIUM/LONG), damage, cooldown, hitbox/projectile scene, animation, voice clip, name/desc keys |
| `PassiveData` | `id`, `Array[StatModifier]`, optional effect script, attachment scene, name/desc keys |
| `StatModifier` | stat, operation (add/multiply), value |
| `BossData` | id, name key, arena scene, boss scene, `first_fight_phases`, `rematch_phases`, rewards, defeat message keys |
| `PhaseData` | health, `Array[AttackPattern]` scheduling, transition scene/animation, optional `ambient_minions: MinionWaveData` |
| `MinionData` | id, max health, contact damage, move speed, wander settings, lifetime, spawn telegraph time, visual scene |
| `MinionWaveData` | `MinionData`, count per spawn, interval, max alive, spawn area / spawn origin |
| `DifficultyProfile` | multipliers by victory count (pending balance) |

## Player (`actors/player/`)

```
AVI (CharacterBody2D) — PlayerController
├── StateMachine: Idle, Run, Crouch, Jump, Fall, Dash, Dodge, Attack, Hurt, Dead, Victory
├── InputBuffer      — buffered actions + coyote time (D06)
├── Aim              — 8-way aim from W/S + facing (D05)
├── HealthComponent
├── Hurtbox
├── Loadout          — up to 3 AttackData (typed slots) + up to 3 PassiveData
├── StatsComponent   — base PlayerTuning + passive modifiers
├── CooldownTracker
└── AVIVisual (scene) — presentation only: cutout rig, attachment anchors, binary shader, mask ✔/✖
```

**Input priority (draft):** Dodge > Dash > Jump > Attack. Dodge/dash may cancel attack recovery; attacks cannot cancel dodge/dash; dash cannot chain into dodge or vice versa without a short lockout. Attacks are allowed while running, crouching and airborne.

## Bosses (`actors/bosses/`)

```
BossBase (inherited scene)
├── BossController   — health, phase transitions by threshold, uses BossData
├── PatternScheduler — sequence / weighted random of AttackPatterns per phase
├── AttackPattern    — Telegraph → Active → Recovery (telegraph mandatory)
├── Hurtboxes (vulnerable areas) / Hitboxes (damage areas)
└── BossVisual (scene)
```

A fight loads `rematch_phases` or `first_fight_phases` depending on `GameState` victory count (D13).

## Minions (`actors/minions/`, D25)

Small red-code insects ("glitch bugs") that fly around the arena at random and deal a small amount of contact damage. They add pressure without being the main threat.

```
Minion (Node2D, scene) — MinionController, configured by MinionData
├── WanderMovement   — random steering inside the arena bounds
├── HealthComponent
├── Hurtbox          — enemy hurtbox layer, any player attack can kill it
├── Hitbox           — contact damage (small), enemy hitbox layer
└── MinionVisual     — presentation only: body + 2 wing parts, flap animation
```

**Movement (WanderMovement).** No physics body: the minion moves itself.
- Every `turn_interval` (random in a range, ~0.6–1.4 s) it picks a new random heading.
- It steers toward that heading at `turn_rate`, so turns look smooth instead of teleporting. A small jitter gives the "buggy" feel.
- When it gets close to the arena bounds (`ArenaBounds` rect, margin ~80 px), the new heading is biased back toward the center. It never leaves the screen.
- It does **not** chase AVI (`player_bias = 0` by default; tunable for rematches).
- If a node in the `lures` group is within `lure_radius` (HONEYPOT), the minion steers toward it instead of wandering.
- Max speed stays below AVI's run speed, so they can always be escaped.

**Lifecycle.**
1. **Telegraph:** a red glitch marker appears at the spawn point for `spawn_telegraph_time` (~0.5 s). No damage during it.
2. **Active:** wanders and deals contact damage. AVI's normal hurt i-frames apply, so a swarm cannot chain-hit.
3. **Death:** by player damage, by `lifetime` running out (it fades), or by despawn. It bursts into red binary digits and emits `Events.minion_killed`.
4. Killing minions does not damage the boss.

**Spawning (`MinionSpawner`, one per arena).**
- Bosses spawn minions through a `SpawnMinionsPattern` (an `AttackPattern` like any other, with telegraph → active → recovery), for example TROJAN spitting bugs from its mouth (`spawn_origin` marker).
- A phase may also define `ambient_minions` for periodic spawns from the arena edges.
- `max_alive` caps how many exist at once; spawns over the cap are skipped.
- Spawn points closer than ~300 px to AVI are rejected.
- On phase transition, boss defeat or player death, every minion is despawned.

**Debug:** `DebugTools` adds a key to spawn one minion at the cursor.

## Breakables (pending design)

DECRYPT "breaks shields and chains" (D12). A `Breakable` component (health + hurtbox that only listens to attacks tagged `breaks_shields`) is planned for RANSOMWARE. Designed at stage 10.

## Combat

- `Hitbox` / `Hurtbox` (Area2D) exchange a `DamageInfo` (amount, source, knockback, is_critical).
- Collision layers:

| Layer | Use |
|---|---|
| 1 | World |
| 2 | Player body |
| 3 | Player hurtbox |
| 4 | Player hitbox |
| 5 | Enemy hurtbox (bosses, minions) |
| 6 | Enemy hitbox / projectiles (bosses, minions) |

## Rendering and depth (D03, D20)

- 1920×1080 base, `canvas_items` stretch, `expand` aspect.
- Arena layers: far background → mid background → playfield → **foreground** (`Parallax2D`).
- 2D lights + HDR glow for binary code, checkmark and abilities; atmospheric fog/blur on far layers.

## Localization

All player-facing strings are keys (`UI_PLAY`, `DEFEAT_TROJAN_01`) in `localization/strings.csv` (columns `en`, `es`). Ability names stay identical across languages (D12).

The player picks the language in-game (`Settings.set_locale`). On first launch it follows the OS language, falling back to English. The choice is saved in `user://settings.cfg`.

## Folder structure

```
res://
├── autoload/
├── data/          attacks/ passives/ bosses/ tuning/
├── actors/        player/ bosses/{base,trojan,phishing,ransomware,bug}/ minions/
├── combat/
├── ui/            hud/ menus/ screens/
├── scenes/        intro/ hub/ arenas/
├── localization/
├── assets/        art/<character>/ audio/ fonts/ shaders/
├── debug/
└── docs/          (repo root, outside res:// usage)
```

## Art integration contract (Gemini)

- PNG with transparency, consistent scale per character, documented pivot.
- Characters delivered as **separated parts** in a neutral pose (cutout, D17).
- Characters and parts on a flat `#FF00FF` background (removed in post); VFX on flat black (additive blend).
- Prompt sheets per character live outside the repo (`../art_brief/`).
- Arenas delivered as **separate depth layers** with transparency.
- Naming: `snake_case`, `<owner>_<part|anim>_<variant>.png` (e.g. `avi_arm_l.png`, `trojan_p2_head.png`).
- A per-character spec and prompt sheet is written before requesting assets.

## MVP stages

| # | Stage | Done when |
|---|---|---|
| 0 | Project base: folders, input map, display settings, autoload stubs, debug toggle | Runs at 60 FPS, gamepad detected |
| 1 | AVI movement greybox: run, jump, crouch/aim, dodge, dash, buffer, tuning | Feel tunable from inspector |
| 2 | Combat core: hitbox/hurtbox, health, i-frames, knockback, dummy, SCAN | Hit and get hit, F1 shows boxes |
| 3 | Attack system: AttackData, SCAN/FIREWALL/PING, cooldowns, HUD | All 3 attacks + readable HUD |
| 4 | Boss framework + minions + spawner + TROJAN greybox (phases 1–3), boss health bar | Full Trojan fight without art, minions spawn and die correctly |
| 5 | Game flow: hub, loadout menu, boss intro, victory/defeat, 3 save slots, unlocks | Equip → fight → unlock → save → rematch |
| 6 | Passives: StatModifier, 6 passives, attachment anchors | Passives verifiably change stats |
| 7 | Art pipeline spike (AVI): specs, prompts, cutout rig, binary shader *(parallel with 2–4)* | Final-art AVI in game |
| 8 | TROJAN art + arena → vertical slice | One polished fight |
| 9 | PHISHING | Second boss complete |
| 10 | RANSOMWARE | Third boss complete |
| 11 | Rematch difficulty + BUG + DEBUG double jump | BUG unlocks at 2×3 wins |
| 12 | Intro + screen-dive transition | Full flow from launch |
| 13 | Audio, options/remapping, localization pass, export, performance | Stable Windows build at 60 FPS |
