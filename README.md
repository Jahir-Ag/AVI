# AVI

> A 2D boss-rush action game set inside a computer, where a tiny antivirus knight fights malware brought to life.

**Status:** in development (MVP) · **Engine:** Godot 4.7 (GDScript, Forward+) · **Platform:** PC (keyboard & gamepad) · **Languages:** English / Español

## Concept

A security analyst receives a threat alert and launches a scan. The camera dives into the screen and you take control of **AVI** (*Anti-VIrus*): a small digital knight with a body made of green binary code and a mask bearing the cyan "scan complete" checkmark.

Each boss is a real-world threat reimagined as a creature:

| Boss | Threat | Theme |
|---|---|---|
| **TROJAN** | Trojan horse | A wooden horse hiding corrupted code |
| **PHISHING** | Phishing | An anglerfish that lures you with bait |
| **RANSOMWARE** | Ransomware | A jailer that locks files away |
| **BUG** *(secret)* | Software bug | An erratic insect |

## Gameplay pillars

- **Pattern-based boss fights** with readable telegraphs, multiple phases and instant retry.
- **Rematches reveal the true form:** first fights have 2 phases; rematches add a 3rd, abstract phase.
- **Build your loadout:** equip 1–3 attacks and 1–3 passives. Self-imposed challenges are part of the design.
- **Cybersecurity-flavoured abilities:** `FIREWALL`, `PING`, `HONEYPOT`, `DECRYPT`, `ENCRYPTION`, `OVERCLOCK`...

## Project structure

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the technical design and [`docs/DECISIONS.md`](docs/DECISIONS.md) for the decision log.

## Running

1. Install [Godot 4.7](https://godotengine.org/download).
2. Open `project.godot` from this folder.
3. Press **F5**.

## AI disclosure

Code and architecture are developed with AI assistance (Claude Code). Visual assets are generated with AI assistance (Google Gemini) and then edited, separated and animated in-engine by the author. All voice acting is by the author.

## License

- **Code:** [MIT](LICENSE)
- **Art, audio and voice:** all rights reserved, see [ASSETS_LICENSE.md](ASSETS_LICENSE.md)
