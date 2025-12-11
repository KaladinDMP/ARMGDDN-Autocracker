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
   - Blocks non-LAN connections (for the paranoid among us)

Choose wisely. Or don't. We're not your mom.

### 💾 User Options System

Tired of being called "gse orca" in every game? Now you can set your own identity!

The first time you generate steam settings, you'll be asked:
- **Username** - Be whoever you want! (In games. Not in real life. That's identity theft.)
- **Save Location** - Portable (saves with game) or AppData (the civilized choice)

Your preferences are saved to `Resources/Tools/options.txt` and remembered forever. Or until you delete it. Whichever comes first.

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

### 🧊 Cold Client Loader (GBE-Fork Style)

For those stubborn games that refuse to play nice:

- Copies `steamclient_loader_x32.exe` OR `steamclient_loader_x64.exe` based on the architecture of the .exe
- Includes `steamclient.dll`, `steamclient64.dll`
- GameOverlayRenderer DLLs for that authentic fake-Steam experience
- Auto-generates `ColdClientLoader.ini` with your settings

Just pick steamclient_loader_64/32.exe when launching. It will work. Probably.

### 🔍 Steam App ID Detection

Same bloodhound-level hunting as before:
1. Searches the game folder for `steam_appid.txt`
2. If not found, launches `ARMGDDN.App.ID.exe` to search our (OK, Steams) massive database
3. If STILL not found, makes you type it in like a caveman

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
4. Right-click any EXE or DLL → ARMGDDN Autocracker → GBE Fork → Pick your poison. Or if you only use Windows Defender you can now right click on any folder and choose AAC Folder Exclusion to auto-add it. It even checks and makes sure you havent already excluded it.
5. Follow the prompts
6. Profit???

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
        ├── AAC_Autocracker.ico              # Icon for context menu
        ├── AAC_Icon.png                     # PNG source for icon
        ├── ExclusionHelper.exe              # Does the excluding
        ├── ExclusionHelper.dll              # Helper for ExclusionHelper
        ├── ExclusionHelper.pdb              # Helper for ExclusionHelper
        ├── ExclusionHelper.deps.json        # Helper for ExclusionHelper
        ├── ExclusionHelper.runtimeconfig.json
        ├── generate_interfaces_file.exe     # For old games that need it
        ├── nircmd.exe                       # For talking and cool stuff
        └── options.txt                      # Your saved preferences
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
- **cs.rin.ru Thread for the ARMGDDN Autocracker - GBE-Fork**: [Coming Soon™]

## 🌟 Support

Got questions? Found a bug? Just want to complain? Find me:

- **ARMGDDN Games Telegram**: [ARMGDDN Games](https://t.me/ARMGDDNGames) — Miss Tulip says hi
- **Personal Telegram**: [DeliciousMeatPop](https://t.me/SickSoThr33)
- **Reddit**: [u/DeliciousMeatPop](https://www.reddit.com/user/DeliciousMeatPop/)
- **Discord**: [DeliciousMeatPop](https://discordapp.com/users/191105213808115712) — I never use discord though, so might as well just write down your comment and flush it as try to contact me there.

---

*Remember: If it works, you're welcome. If it doesn't, you probably did something wrong. But we'll help anyway because we're nice like that.*

**Happy cracking!** 🎮🔓
