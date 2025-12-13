# ARMGDDN Autocracker - GBE Fork Edition 🎮🔧🔥

![ARMGDDN Autocracker Logo](https://github.com/KaladinDMP/ARMGDDN-Autocracker/assets/92135051/ebcf7a21-8e5d-44e2-9165-cb280d8d275c)

**The next evolution of ARMGDDN Autocracker, now powered by [GBE Fork](https://github.com/Detanup01/gbe_fork)!**

Welcome to the GBE Fork Edition! We took everything you loved (and tolerated) about the original ARMGDDN Autocracker and gave it a shiny new engine. Same chaos, better emulation. If the OG Goldberg version was a trusty Honda Civic, this is the turbocharged Type R. Still gets you there, just... fancier.

## 🆕 What's Different From OG Goldberg Steam Emu?

Glad you asked! (Even if you didn't, I'm telling you anyway.)

| Feature | OG Goldberg | GBE Fork |
|---------|-------------|----------|
| Stats format | `stats.txt` | `stats.json` |
| Achievement icons | `achievement_images/` | `images/` |
| DLC config | `DLC.txt` | `configs.app.ini` |
| User settings | Scattered text files | `configs.user.ini` |
| Overlay support | Yes! (ExOL builds, optional) | Yes! (ExOL builds, optional) |
| Cold Client Loader | `steamclient_loader.exe` | `steamclient_loader_x32.exe` / `steamclient_loader_x64.exe` |
| Active development | Archived | Actively maintained |

**TL;DR:** GBE Fork is the spiritual successor to Goldberg's emulator, with more features, better compatibility, and someone actually fixing bugs. Revolutionary concept, I know.

## 🎯 Feature Highlights

### Core Functionality
- **🔄 One-Click DLL Replacement** - Right-click any `steam_api.dll` or `steam_api64.dll`, select Autocracker, and it's replaced with the GBE Fork emulator. Done.
- **🧊 Cold Client Loader Setup** - For games that need DLL injection instead of replacement. Auto-detects 32/64-bit architecture and configures everything.
- **🔓 Steam Stub Removal** - Integrated Steamless removes Steam's DRM protection from executables with one click.
- **🎮 Steam Settings Generator** - Automatically fetches achievements, stats, DLC info, and images from Steam's servers and creates properly formatted config files.

### Smart Features
- **🔍 Fuzzy Game Search** - Don't know the exact game name? Type "cyberpnuk" and it'll find "Cyberpunk 2077". Or just enter the AppID directly if you know it.
- **🏗️ Auto Architecture Detection** - Cold Client Loader reads the EXE header and picks the correct 32-bit or 64-bit loader automatically.
- **💾 Persistent User Settings** - Set your username and save location once, use it forever. Set `ask=0` to skip prompts entirely.
- **📁 Smart AppID Detection** - Searches game folders for existing `steam_appid.txt` before asking you to find it.

### Installation & Integration  
- **🖱️ Nested Context Menus** - Clean, 7-Zip style nested menus. All options under one parent menu, not scattered everywhere.
- **🤝 Dual Version Support** - Works alongside OG GSE v2.0.0. Install both, get both in one unified menu. Use whichever works better for each game.
- **🛡️ Windows Defender Integration** - Right-click any folder → "AAC Folder Exclude" to add it to Defender exclusions. No more false positives.
- **📦 Silent .NET Install** - Required runtime installs automatically and silently during context menu setup.

### GBE Fork Specific
- **🎨 Overlay Support (ExOL)** - Optional builds with working SHIFT+TAB overlay and achievement popups. Prompts you to enable after DLL replacement.
- **📝 Full Config Templates** - Generates `configs.app.ini`, `configs.user.ini`, and `configs.overlay.ini.disabled` with all GBE Fork options and documentation included.
- **🖼️ Achievement Images** - Downloads achievement icons to the correct `images/` folder (not `achievement_images/` like OG).
- **📊 Proper JSON Formats** - Stats as `stats.json`, achievements as `achievements.json` - the way GBE Fork expects them.

### VR Support
- **🥽 VD Batmaker** - Creates batch files to launch cracked games through Virtual Desktop Streamer for VR headset users.

## 🤝 Works With OG GSE v2.0.0!

This GBE Fork edition is designed to play nice with the **newly updated [ARMGDDN Autocracker - OG GSE v2.0.0](https://github.com/KaladinDMP/ARMGDDN-Autocracker-OG-GSE)**! 

### How It Works

The context menu installer is smart (well, smart-ish). It looks for both versions in the parent folder:

```
ARMGDDN.Autocracker/                    # Parent folder (can be named anything)
├── ARMGDDN.Autocracker.GBE-Fork/       # This one (GBE Fork)
│   ├── ARMGDDN.Main.exe
│   └── ...
│
├── ARMGDDN.Autocracker.OG-GSE/         # The OG (v2.0.0+)
    ├── ARMGDDN.Main.exe
    └── ...
```

When you run `AIOContextMenuSetupforAAC.exe`, it:

1. **Checks for GBE Fork** → Found? Adds "GBE Fork" submenu
2. **Checks for OG GSE** → Found? Adds "OG GSE" submenu
3. **Both found?** → Installs BOTH under one parent menu!
4. **Only one found?** → Just installs that one (no judgment)

### Why Would You Want Both?

- **GBE Fork** - Newer, actively maintained, more features, better for modern games
- **OG GSE** - Tried and true, sometimes works better on older/quirky games

Some games are picky. Having both options means you can try GBE Fork first, and if it acts up, switch to OG GSE without redownloading anything. It's like having both a Phillips and flathead screwdriver. Sure, one usually works, but sometimes you need the other.

### Installation Scenarios

| What You Have | What Gets Installed |
|---------------|---------------------|
| GBE-Fork only | Just GBE Fork submenu |
| OG-GSE only | Just OG GSE submenu |
| Both folders | Both submenus under one parent |
| Neither (you goofed) | Error message and disappointment |

## ✨ Features

### 🖱️ Nested Context Menu (7-Zip Style!)

Gone are the days of cluttering your context menu with 47 different options. Now it's all neatly tucked away:

```
Right-click any EXE/DLL →
  ARMGDDN Autocracker →
    ├── GBE Fork →
    │     ├── Autocracker
    │     ├── Cold Client
    │     ├── Steam Stub Remover
    │     ├── VD Batmaker (VR)
    │     └── Steam Interfaces (DLL only)
    │
    └── OG GSE →  (if you have both installed)
          └── ... same options

Right-click any Folder →
  AAC Folder Exclude
```

It's like a filing cabinet, but for cracking games. Marie Kondo would be proud. Or horrified. Probably both.

### 🎛️ DLL Flavor Selection

When cracking a DLL, you now get to choose your poison:

1. **Regular** - Standard GBE emulation. Reliable. Boring. Works.
2. **Experimental with Overlay (ExOL)** - The spicy option!
   - In-game overlay (SHIFT+TAB, just like the real thing!)
   - Achievement notifications that pop up and make you feel special
   - FPS counter, playtime tracking
   - Blocks non-LAN connections (for the paranoid among us)

Choose wisely. Or don't. We're not your mom.

**If you choose ExOL**, after generating steam settings you'll be asked:
1. "Enable the overlay?" → Yes/No
2. If Yes: Warning about potential crashes → OK/Cancel
3. If OK: `configs.overlay.ini.disabled` gets renamed to `configs.overlay.ini` and the overlay is active!

**Overlay not working? Game crashing?** Just rename or delete `configs.overlay.ini` in the `steam_settings` folder. The overlay will be disabled and you can still play with all other GBE features.

### 💾 User Options System

Tired of being called "gse orca" in every game? Now you can set your own identity!

The first time you generate steam settings, you'll be asked:
- **Username** - Be whoever you want! (In games. Not in real life. That's identity theft.)
- **Save Location** - Portable (saves with game) or AppData (the civilized choice)

Your preferences are saved to `Resources/Tools/options.txt` and remembered forever. Or until you delete it. Whichever comes first.

**Don't want to be asked every time?** When prompted, say "Y" to "Stop asking every time?" and it'll save `ask=0` to your options. From then on, it just uses your saved settings silently. Change your mind? Edit `options.txt` and set `ask=1` to re-enable prompts.

```ini
# Example options.txt
account_name=YourCoolName
portable=0
local_save_path=saves
saves_folder_name=GSE Saves

# ask=1 prompts every time, ask=0 uses settings silently
ask=0
```

### 📁 GBE-Fork Format Steam Settings

The `ARMGDDN.Steam.Settings.exe` now generates proper GBE-Fork format configs:

```
steam_settings/
├── steam_appid.txt
├── achievements.json
├── stats.json
├── images/
│   ├── achievement_icon1.jpg
│   └── achievement_icon2.jpg
├── configs.app.ini      (DLC, app settings)
└── configs.user.ini     (username, save location)
```

All the comments. All the options. All the documentation you'll never read but will be grateful exists when something breaks.

### 🎨 Overlay Configuration

The overlay config is generated as `configs.overlay.ini.disabled` by default. This is intentional - the overlay can cause crashes in some games, so we don't enable it automatically.

**To enable the overlay:**
- Rename `configs.overlay.ini.disabled` → `configs.overlay.ini`
- Or just say "Yes" when prompted after using ExOL DLLs

**What's in the overlay config?**
```ini
[overlay::general]
enable_experimental_overlay=1       # Master switch
disable_achievement_notification=0  # Show achievement popups
disable_friend_notification=0       # Show friend notifications
overlay_always_show_fps=0           # FPS counter (set to 1 to enable)
overlay_always_show_playtime=0      # Playtime display

[overlay::appearance]
Font_Size=20.0                      # UI font size
Icon_Size=64.0                      # Achievement icon size
PosAchievement=bot_right            # Where achievements appear
Notification_Duration_Achievement=7.0  # How long popups stay
# ... and many more customization options
```

**Overlay controls:**
- **SHIFT+TAB** - Open/close the overlay
- Achievement popups appear automatically when you unlock them
- FPS/playtime can be set to always show

### 🧊 Cold Client Loader (GBE-Fork Style)

For those stubborn games that refuse to play nice:

- **Auto-detects 32-bit vs 64-bit** - Reads the EXE header and picks the right loader automatically
- Copies `steamclient_loader_x32.exe` OR `steamclient_loader_x64.exe` (not both - less clutter!)
- Includes `steamclient.dll`, `steamclient64.dll`
- GameOverlayRenderer DLLs for that authentic fake-Steam experience
- Auto-generates `ColdClientLoader.ini` with your settings

```
Detected architecture: 64
Game is 64 bit. Using steamclient_loader_x64.exe
```

Just run the loader when you want to play. It handles everything else.

### 🔍 Steam App ID Detection (Now With Fuzzy Search!)

Same bloodhound-level hunting as before, but now with a brain upgrade:

1. Searches the game folder for `steam_appid.txt`
2. If not found, launches `ARMGDDN.App.ID.exe` with **two input modes**:

**Text Input = Fuzzy Search**
```
Enter: elden rign
Finds:  ELDEN RING (AppID: 1245620)
```
Typos? No problem. Missing words? We'll figure it out. It's like Google, but for Steam games.

**Number Input = Direct AppID**
```
Enter: 1245620
Result: Found in database: ELDEN RING
        Use AppID 1245620? (Y/N)
```
Already know the AppID? Just type it. We'll verify it exists (locally first, then online) and let you confirm. No searching, no waiting, no nonsense.

The fuzzy search uses three-tier matching:
- **Exact match** - Your search is in the game name
- **Token match** - All your words appear somewhere in the name
- **Fuzzy match** - Close enough (handles typos like "cyberpnuk" → "Cyberpunk 2077")

We believe in you. Mostly.

### 🥽 VD Batmaker (VR)

For the Virtual Desktop users out there living in the future with headsets strapped to their faces. Creates a batch file to launch your game through Virtual Desktop Streamer. VR gaming, cracked style.

### 🔓 Steam Stub Remover

Steamless integration, same as always. If a game has a Steam stub protecting it, we'll yank it out like a bad tooth. Uses Steamless by atom0s, because why reinvent the wheel when someone already made a really good wheel?

## 📖 Usage

### Option 1: Context Menu (The Fancy Way)

1. Extract the whole `ARMGDDN.Autocracker.GBE-Fork` folder somewhere permanent
2. Run `AIOContextMenuSetupforAAC.exe`
3. Accept the warnings about the script talking (yes, it talks, deal with it)
4. **Wait for .NET Desktop Runtime to install** (silent, automatic, required for Exclusion Helper)
5. Right-click any EXE or DLL → ARMGDDN Autocracker → GBE Fork → Pick your poison. Or if you only use Windows Defender you can now right click on any folder and choose AAC Folder Exclusion to auto-add it. It even checks and makes sure you havent already excluded it.
6. Follow the prompts
7. Profit???

**Note:** The installer automatically installs .NET Desktop Runtime 10.x if needed. If you already have it, it skips in about 1-2 seconds. No user interaction required - it's completely silent.

### Option 2: Drag and Drop (The Lazy Way)

1. Grab your EXE or `steam_api.dll` / `steam_api64.dll`
2. Yeet it onto `ARMGDDN.Main.exe`
3. Answer the questions
4. Done

### Option 3: Direct Execution (The Control Freak Way)

```
ARMGDDN.Main.exe "C:\Path\To\Game.exe"
ARMGDDN.Main.exe "C:\Path\To\steam_api64.dll"
```

## 🛠️ Requirements

- **Windows OS** - Linux users, you're on your own (but also, why do you need this?)
- **.NET Framework 4.5+** - For Steamless
- **.NET Desktop Runtime 10.x** - For Exclusion Helper (auto-installed by context menu setup)
- **Basic knowledge of Steam game structure** - Know your EXEs from your DLLs
- **Reading comprehension** - The prompts have words. Read them. Answer them. Use the force, Luke.

## 📁 Folder Structure

```
ARMGDDN.Autocracker.GBE-Fork/
├── ARMGDDN.Main.exe                    # Main entry point
├── AIOContextMenuSetupforAAC.exe       # Installs context menus
├── AIOContextMenuUninstallerforAAC.exe # Removes context menus
├── README.md                           # You are here
│
└── Resources/
    ├── ARMGDDN.Autocracker.exe         # DLL cracker
    ├── ARMGDDN.Cold.Client.exe         # Cold Client setup
    ├── ARMGDDN.Steam.Settings.exe      # Config generator
    ├── ARMGDDN.Stub.Remover.exe        # Steam stub remover
    ├── ARMGDDN.VD.Batmaker.exe         # VR batch maker
    │
    ├── Api/
    │   ├── steam_api.dll               # 32-bit regular
    │   ├── steam_api64.dll             # 64-bit regular
    │   ├── steam_apiExOL.dll           # 32-bit with overlay
    │   └── steam_api64ExOL.dll         # 64-bit with overlay
    │
    ├── AppID/
    │   └── ARMGDDN.App.ID.exe          # App ID finder
    │
    ├── Client/
    │   ├── ColdClientLoader.ini        # Where your options live
    │   ├── GameOverlayRenderer.dll     # Helps with the Overlay
    │   ├── GameOverlayRenderer64.dll   # Helps with the Overlay
    │   ├── steamclient.dll             # Required for cold client loader
    │   ├── steamclient64.dll           # Required for cold client loader
    │   ├── steamclient_loader_x32.exe  # 32 bit cold client loader
    │   └── steamclient_loader_x64.exe  # 64 bit cold client loader
    │
    ├── SteamlessCLI/
    │   ├── Steamless.CLI.exe           # Steam stub remover
    │   ├── Steamless.CLI.exe.config    # Steamless settings
    │   │
    │   └── Plugins/                    # DLLs that help Steamless run
    │       ├── ExamplePlugin.dll
    │       ├── SharpDisasm.dll
    │       ├── Steamless.API.dll
    │       ├── Steamless.Unpacker.Variant10.x86.dll
    │       ├── Steamless.Unpacker.Variant20.x86.dll
    │       ├── Steamless.Unpacker.Variant21.x86.dll
    │       ├── Steamless.Unpacker.Variant30.x64.dll
    │       ├── Steamless.Unpacker.Variant30.x86.dll
    │       ├── Steamless.Unpacker.Variant31.x64.dll
    │       └── Steamless.Unpacker.Variant31.x86.dll
    │
    └── Tools/
        ├── AAC_Autocracker.ico                        # Icon for context menu
        ├── AAC_Icon.png                               # PNG source for icon
        ├── ExclusionHelper.exe                        # Does the excluding
        ├── ExclusionHelper.dll                        # Helper for ExclusionHelper
        ├── ExclusionHelper.pdb                        # Helper for ExclusionHelper
        ├── ExclusionHelper.deps.json                  # Helper for ExclusionHelper
        ├── ExclusionHelper.runtimeconfig.json         # Helper for ExclusionHelper
        ├── generate_interfaces_file.exe               # For old games that need it
        ├── nircmd.exe                                 # For talking and cool stuff
        └── windowsdesktop-runtime-10.0.1-win-x64.exe  # .NET runtime (auto-installed)
```

## ⚠️ Disclaimer

This tool is for educational purposes and for games you legally own. We're not responsible for:
- Your Steam account getting banned (don't be stupid.)
- Games not working (sometimes it just be like that.)
- Your PC gaining sentience (unrelated but still not our fault.)
- Any Terms of Service violations (read them yourself, coward.)
- Voting for Trump (we didn't and won't.)

Use responsibly. Or don't. But if you don't, we don't know you.

## 🙏 Acknowledgements

Standing on the shoulders of giants (and some regular-sized people too):

- **[Detanup01](https://github.com/Detanup01/gbe_fork)** - For keeping the dream alive with GBE Fork along with some contributors
- **[Mr. Goldberg](https://gitlab.com/Mr_Goldberg/goldberg_emulator)** - The OG. The legend. The reason we're all here.
- **[Rat431](https://github.com/Rat431/ColdAPI_Steam)** - Cold Client Loaders humble beginnings, making impossible games possible
- **[atom0s](https://github.com/atom0s/Steamless)** - Steamless, because Steam stubs are annoying
- **[Sak32009](https://github.com/Sak32009/steam_py_fork)** - Steam module fixes that made everything faster
- **[SteamLadder](https://steamladder.com/)** - API access for finding achievement/DLC data
- **George Jefferson** - For telling me when I'm wrong (frequently)
- **You** - For reading this far. Gold star. ⭐

## 🔗 Links

- **OG GSE Gitlab**: [mr_goldberg.gitlab.io/goldberg_emulator/](https://mr_goldberg.gitlab.io/goldberg_emulator/)
- **GBE Fork Github**: [github.com/Detanup01/gbe_fork](https://github.com/Detanup01/gbe_fork)
- **ARMGDDN Autocracker - OG-GSE**: [github.com/KaladinDMP/ARMGDDN-Autocracker-OG-GSE](https://github.com/KaladinDMP/ARMGDDN-Autocracker-OG-GSE)
- **ARMGDDN Autocracker - GBE-Fork**: [github.com/KaladinDMP/ARMGDDN-Autocracker-GBE-Fork](https://github.com/KaladinDMP/ARMGDDN-Autocracker-GBE-Fork)
- **cs.rin.ru Thread for the ARMGDDN Autocracker - OG-GSE**: [cs.rin.ru/forum/viewtopic.php?f=20&t=141375](https://cs.rin.ru/forum/viewtopic.php?f=20&t=141375)
- **cs.rin.ru Thread for the ARMGDDN Autocracker - GBE-Fork**: [cs.rin.ru/forum/viewtopic.php?f=20&t=153779(https://cs.rin.ru/forum/viewtopic.php?f=20&t=153779)

## 🌟 Support

Got questions? Found a bug? Just want to complain? Find me:

- **ARMGDDN Games Telegram**: [ARMGDDN Games](https://t.me/ARMGDDNGames) — Miss Tulip says hi
- **Personal Telegram**: [DeliciousMeatPop](https://t.me/SickSoThr33)
- **Reddit**: [u/DeliciousMeatPop](https://www.reddit.com/user/DeliciousMeatPop/)
- **Discord**: [DeliciousMeatPop](https://discordapp.com/users/191105213808115712) — I never use discord though, so might as well just write down your comment and flush it as try to contact me there.

---

*Remember: If it works, you're welcome. If it doesn't, you probably did something wrong. But we'll help anyway because we're nice like that.*

**Happy cracking!** 🎮🔓