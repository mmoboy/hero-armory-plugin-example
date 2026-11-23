# Hero Armory Plugin Example (Realm Bounty Board)

Standalone template repository for building, signing, and publishing Hero Armory
WebAssembly (`wasip1/wasm`) plugins with zero local setup costs and free GitHub
Actions build provenance verification.

## Publish Your Own Plugin (Recommended: Source-Verified via GitHub Actions)

1. Click **Use this template** on GitHub (`github.com/mmoboy/hero-armory-plugin-example`)
   to create your own **public** GitHub repository.
2. Update `go.mod` module path to your repository URL and customize `manifest.json`:
   - `id`: unique 3..40 lowercase `[a-z0-9_-]` plugin slug
   - `version`: semver matching your release tag without the `v` prefix (for example `"1.0.6"` for tag `v1.0.6`)
   - `sdk_version`: `1`
   - `icon`: `"icon.png"` (replace the root `icon.png` with your own square PNG icon, max **256x256** px and <= 128 KiB, displayed in the Plugins Library and Host Server configuration)
3. Implement your game content in `server/main.go`, `client/main.go`, and `assets/`
   (this example includes Bounty Guild starter origins via `sdk.CharacterCreatePlugin`
   in `vanilla_extended` mode alongside rotating challenges, custom 3D bosses/ore
   veins, KV/Pref storage, and Sandbox role audits).
4. Add showcase PNG/JPG images under `screenshots/` (excluded from `.gtpack`, displayed on the Hero Armory website and desktop client for Source-Verified GitHub releases directly from the attested commit).
5. Keep `.github/workflows/release.yml` calling:
   `mmoboy/hero-armory-sdk/.github/workflows/build-plugin.yml@v1`
6. Tag and push a release:
   ```bash
   git add -A && git commit -m "Release v1.0.6"
   git tag v1.0.6
   git push origin main v1.0.6
   ```
7. Once the GitHub Actions workflow finishes (free for public repositories),
   sign into `https://kmmo.enlumis.com/plugins`, submit your GitHub repo URL +
   `v1.0.6`, and publish it with a **Source-Verified** badge linking directly to
   the immutable build commit and commit-pinned screenshots.

## Local Development Build

```bash
./build.sh
```
