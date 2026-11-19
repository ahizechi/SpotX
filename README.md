# SpotX-Hardened

A hardened fork of [SpotX](https://github.com/SpotX-Official/SpotX). It debloats the Spotify desktop client and blocks its auto-updates, the same as SpotX, but removes the parts of SpotX that weren't needed for that.

## Usage

1. Download this repository (**Code → Download ZIP**) and extract it. Keep the `resources` folder next to the script.
2. Run `Install.bat` (not as administrator). It needs Windows 10/11 and the built-in Windows PowerShell 5.1.

To change options, edit the `set param=` line in `Install.bat`.

## Provenance

| What | Source |
|---|---|
| `SpotX-Hardened.ps1` | upstream `run.ps1` @ `d85794fdc446feb2c66b62379278767bcf87dda3` (SHA256 `2b18131a…fe2e5`), then edited; search for `HARDENED` |
| `resources/patches/patches.json` | upstream @ same commit, unmodified |
| `resources/lang/en.ps1` | upstream `scripts/installer-lang/en.ps1` @ same commit, unmodified |
| `resources/js-helper/sectionBlock.js` | upstream @ same commit, unmodified |
| `resources/css-helper/lyrics-color/*.css` | upstream @ same commit, unmodified |

## What changed vs. upstream SpotX

| Upstream behaviour | SpotX-Hardened |
|---|---|
| `.bat` downloads `run.ps1` from the `main` branch and pipes it to `iex` on every run | Runs the local reviewed script with `-File` |
| Downloads language file at runtime and runs it with `Invoke-Expression` | Loads `resources/lang/en.ps1` locally |
| Patches and JS helpers fetched from `main` at runtime | Vendored in `resources/`; any remaining fetch (legacy versions only) uses a pinned commit URL |
| Spotify installer downloaded with `curl -k --ssl-no-revoke` (TLS checks off), from a third-party mirror, and executed unchecked | TLS checks on; installer must have a valid **Spotify AB** Authenticode signature before it runs; extracted `Spotify.exe`/`.dll`s must be Spotify-signed and, for the default x64 build, match pinned SHA256 hashes |
| Adds Defender exclusions for Spotify **and `powershell.exe`** (silently if run as admin) | No exclusions by default. `-defender_exclusions_on` excludes the Spotify install folder only |
| Injects `checkVersion.js`, which captures your Spotify login token, queries Spotify's update API with it and reports to `spotify-ingest-admin.amd64fox1.workers.dev` | Never injected |
| Optional `goofyHistory.js` sends listening history to a third-party URL | Removed |
| Default version resolved through a remote manifest | Default pinned to `1.3.10.2586.g81a118a22460` |
| No hardware-acceleration option | `-hardware_acceleration_off` sets `ui.hardware_acceleration=false` in `%APPDATA%\Spotify\prefs`. That's the same setting as Spotify's own toggle; the key name comes from Spotify's native code, and the script checks the installed build still uses it before writing |
| `-DisableStartup` appends another `app.autostart-mode` line on every run | Updates the existing line in place |

## Memory use

`Install.bat` turns on both memory-related options:

- **`-hardware_acceleration_off`.** Spotify renders without the GPU, which usually lowers its memory use. Animations and scrolling use a bit more CPU instead. Sound quality is unaffected. If the UI stutters, remove the flag, or turn the setting back on in Spotify → Settings → Compatibility.
- **`-DisableStartup`.** Spotify doesn't launch with Windows, so it uses no memory until you open it.

The debloat itself also helps, since ads, home-page video takeovers and sponsored content are never loaded. Other popular memory "tweaks" were left out on purpose. Chromium switches on the shortcut aren't confirmed to reach Spotify's engine. JavaScript heap caps cause crashes. Forced working-set trimming only moves memory to the page file and causes stutter.

## Limitations

- The Spotify installer still comes from SpotX's mirror (`loadspot.amd64fox1.workers.dev`), because Spotify doesn't publish older builds. The signature check means a bad file is refused, not run. When the mirror is overloaded it returns HTTP 503, junk data or a truncated file; retry later, or download the installer yourself (the mirror supports resuming with HTTP range requests) and pass it with `-InstallerPath <file>`. A local installer goes through the same signature and hash checks.
- The signature and hash checks run when the script downloads Spotify itself (a fresh install, or replacing an outdated version). If a supported Spotify is already installed, the script patches it in place without re-checking it. Uninstall Spotify first if you want every check to run.
- Only English installer messages are bundled.
- With updates blocked, Spotify's built-in Chromium stops getting security fixes. Update deliberately: bump `$latest_full`, refresh `resources/patches/patches.json` from a newer upstream commit you've reviewed, update `PinnedCommits` and `KnownBinaryHashes`, then re-run.
- Patched `Spotify.exe`, `Spotify.dll` and `chrome_elf.dll` are unsigned by design. If Defender flags them, use `-defender_exclusions_on` (folder-only), never a process exclusion.

## License

MIT, same as upstream. See [LICENSE](LICENSE). Not affiliated with Spotify AB or the SpotX project. Modifying the Spotify client may break Spotify's terms of use; use at your own risk.
