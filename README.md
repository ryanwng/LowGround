# Imposter Killer

A fast, top-down **survival action roguelite** built in **Godot 4** — dodge endless
swarms, vacuum up XP gems, and pick upgrades every level as the horde escalates.
Survive 5 minutes to win. Inspired by *Vampire Survivors*.

![Imposter Killer gameplay](screenshots/gameplay.gif)

> _Recording the gif:_ capture ~8–10s of busy mid-run action — a level-up card
> pick followed by a screen full of spears/tornadoes shredding enemies — and save
> it as `screenshots/gameplay.gif`. It will appear above automatically.

---

## Play

- **WASD** — move
- **Space** — attack (ice spears auto-aim the nearest enemy)
- **Esc** — pause / settings

Kill enemies → collect the gems they drop → level up → choose an upgrade. Weapons,
health, speed, armor and a gem magnet all scale from the upgrade pool. Tougher
enemies (kobolds, cyclopes, amoebas, juggernauts) arrive as the timer climbs.

## Features

- **Leveling & data-driven upgrades** — a central upgrade database with
  prerequisites and per-upgrade caps; a random 3-choice level-up panel.
- **Wave-based spawner** with a timed spawn table and difficulty that ramps to a
  5-minute climax.
- **Two weapons** — piercing ice spears and roaming tornadoes (unlockable).
- **Game feel** — enemy hit-flash, camera shake, floating damage numbers, and
  level-up/pickup pops.
- **Full UI flow** — main menu, in-game pause + settings (Master/Music/SFX
  sliders), and a win/lose run-summary screen (time, level, kills, gems, best).
- **Persistence** — best time and volume settings saved to disk (JSON).

## Tech highlights

- **Engine:** Godot 4.7, GDScript
- Signal-driven HUD decoupled from the player
- Autoload singletons for the upgrade DB and save/settings data
- Dedicated audio buses (Master / Music / SFX) with a runtime mixer
- Collision-layer-based hit/hurt boxes shared across player, enemies, and pickups
- Web-export ready (see [`DEPLOY.md`](DEPLOY.md))

## Run it

1. Open the project in **Godot 4.7**.
2. Press **Play** (`F5`). Main scene is `res://GUI/main_menu.tscn`.

## Play in the browser

The project is set up for an HTML5 export to GitHub Pages — see
[`DEPLOY.md`](DEPLOY.md) for the (short) steps.

## Credits

- Extended from a *Vampire Survivors*-style Godot tutorial base.
- Art: "2D Pixel Dungeon Asset Pack" and the project's bundled sprite/audio packs.
- `web/coi-serviceworker.js` © Guido Zuidhof et al., MIT.
