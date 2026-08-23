# Deploying "Impostor Killer" to the web (GitHub Pages)

This project is **prepared** for a Godot 4 HTML5 export to GitHub Pages, but the
export itself has not been run yet (it requires the Godot editor + web export
templates). Follow these steps when you're ready to publish.

---

## 1. Install the Web export templates (one time)

In Godot: **Editor → Manage Export Templates… → Download and Install**. This
downloads the templates matching your exact Godot version (4.7).

## 2. Export the game

A **Web** export preset is already committed in `export_presets.cfg` and writes to
the `docs/` folder (GitHub Pages can serve straight from `/docs`).

1. **Project → Export…** — you should see the "Web" preset.
2. Confirm **Export Path** is `docs/index.html`.
3. **Recommended:** in the preset options, make sure **Thread Support is OFF**
   (the preset ships with `variant/thread_support=false`). With threads off the
   build does **not** need special COOP/COEP headers, so it runs on GitHub Pages
   with zero extra setup. (See "If you keep threads on" below if you need them.)
4. Click **Export Project** (uncheck "Export With Debug").

## 3. Make the build Pages-friendly

- Add an empty file named **`.nojekyll`** inside `docs/` (stops GitHub's Jekyll
  from hiding files). You can create it from a terminal:
  ```bash
  touch docs/.nojekyll
  ```
- The export already names the entry file `index.html`, which Pages serves by default.

## 4. Push and enable Pages

```bash
git add docs .nojekyll export_presets.cfg
git commit -m "Add web build"
git push
```

Then on GitHub: **Settings → Pages → Build and deployment → Source: Deploy from a
branch**, and choose **branch `main` / folder `/docs`**. Your game will be live at
`https://<your-username>.github.io/<repo-name>/` within a minute or two.

---

## If you keep Thread Support ON

Godot web builds with threads use `SharedArrayBuffer`, which browsers only allow
in a "cross-origin isolated" page (needs `Cross-Origin-Opener-Policy` and
`Cross-Origin-Embedder-Policy` headers). GitHub Pages can't send custom headers,
so use the included service-worker shim:

1. Copy `web/coi-serviceworker.js` into `docs/` (next to `index.html`).
2. Add this line inside the `<head>` of the exported `docs/index.html`:
   ```html
   <script src="coi-serviceworker.js"></script>
   ```
   (To make this automatic on every export, set the preset's
   **HTML → Head Include** to that same `<script>` tag.)

The simplest path is still **threads off** — then you can skip this entirely.

---

## Alternative: itch.io (even easier)

For a portfolio, itch.io is often quicker: export to a folder, zip it, and upload
as an HTML5 project (tick "This file will be played in the browser"). itch.io can
serve cross-origin-isolated pages via a project setting, so threaded builds work
there too.

---

## Attribution (put this in your README)

- Base project extended from a Vampire-Survivors-style Godot tutorial.
- Art: "2D Pixel Dungeon Asset Pack" and the project's bundled sprite/audio packs.
- `web/coi-serviceworker.js` © Guido Zuidhof et al., MIT
  (https://github.com/gzuidhof/coi-serviceworker).
