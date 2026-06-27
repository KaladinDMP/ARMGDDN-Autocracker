USERNAME = "AchievementTestAccount"
PASSWORD = "Nogamesonthisaccountdontbother."

import os
import sys
import json
import urllib.request
import urllib.error
import threading
import queue

# Add Tools/ to path so imports work both when run directly and when frozen
_base = os.path.dirname(sys.executable) if getattr(sys, 'frozen', False) else os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_base, 'Tools'))

HARDCODED_STEAM_IDS = [
    76561198017975643, 76561198028121353, 76561197979911851, 76561198355953202,
    76561198217186687, 76561197993544755, 76561198001237877, 76561198237402290,
    76561198152618007, 76561198213148949, 76561198037867621, 76561197969050296,
    76561198134044398, 76561198001678750, 76561198094227663, 76561197973009892,
    76561198019712127, 76561197976597747, 76561197963550511, 76561198044596404,
]

STEAM_IDS_URL = "https://raw.githubusercontent.com/KaladinDMP/steam-top-accounts-data/main/steam_ids_only.txt"
LOCAL_STEAM_IDS_FILE = "steam_ids_cache.txt"

def get_base_path():
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    else:
        return os.path.dirname(os.path.abspath(__file__))

BASE_PATH = get_base_path()
LOCAL_STEAM_IDS_FILE = os.path.join(BASE_PATH, LOCAL_STEAM_IDS_FILE)

def get_options_file_path():
    """Get path to options.txt in Resources/Tools folder"""
    base = get_base_path()
    return os.path.join(base, "Tools", "options.txt")

def load_user_options():
    """Load user options from Resources/Tools/options.txt"""
    defaults = {
        'account_name': 'ARMGDDN',
        'portable': '0',
        'local_save_path': 'saves',
        'saves_folder_name': 'GSE Saves',
        'ask': '1'  # 1=prompt every time, 0=use saved settings silently
    }
    
    options_file = get_options_file_path()
    
    if not os.path.exists(options_file):
        return defaults
    
    try:
        with open(options_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if '=' in line and not line.startswith('#'):
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip()
                    # Handle old 'username' key for backwards compatibility
                    if key == 'username':
                        key = 'account_name'
                    if key in defaults:
                        defaults[key] = value
    except Exception as e:
        print(f"Warning: Could not load options.txt: {e}")
    
    return defaults


def save_user_options(options):
    """Save user options to Resources/Tools/options.txt"""
    options_file = get_options_file_path()
    
    # Make sure Tools directory exists
    tools_dir = os.path.dirname(options_file)
    if not os.path.exists(tools_dir):
        os.makedirs(tools_dir)
    
    try:
        with open(options_file, 'w', encoding='utf-8') as f:
            f.write("# ARMGDDN Autocracker User Options\n")
            f.write("# These settings are used when generating steam_settings\n")
            f.write("\n")
            f.write(f"account_name={options['account_name']}\n")
            f.write(f"portable={options['portable']}\n")
            f.write(f"local_save_path={options['local_save_path']}\n")
            f.write(f"saves_folder_name={options['saves_folder_name']}\n")
            f.write("\n")
            f.write("# ask=1 prompts you every time, ask=0 uses these settings silently\n")
            f.write(f"ask={options.get('ask', '1')}\n")
        print(f"Options saved to: {options_file}")
    except Exception as e:
        print(f"Warning: Could not save options.txt: {e}")


def prompt_user_options():
    """
    Ask user if they want to change settings.
    Returns updated options dict.
    """
    options = load_user_options()
    
    # If ask=0, just use saved settings silently
    if options.get('ask', '1') == '0':
        print()
        print(f"Using saved settings (username: {options['account_name']})")
        if options['portable'] == '1':
            print(f"Save location: PORTABLE (./{options['local_save_path']}/)")        
        else:
            print(f"Save location: AppData ({options['saves_folder_name']})")
        print("(To change settings, edit ask=0 to ask=1 in Resources/Tools/options.txt)")
        print()
        return options
    
    print()
    print("============================================")
    print("  User Settings Configuration")
    print("============================================")
    print()
    print(f"Current username: {options['account_name']}")
    if options['portable'] == '1':
        print(f"Save location: PORTABLE (game folder: {options['local_save_path']})")
    else:
        print(f"Save location: AppData ({options['saves_folder_name']})")
    print()
    
    change = input("Change username or save location? (Y/N): ").strip().upper()
    
    if change != 'Y':
        print("Keeping current settings.")
        print()
        print("--------------------------------------------")
        print("Don't want to be asked every time?")
        print("Add ask=0 to Resources/Tools/options.txt")
        print("--------------------------------------------")
        print()
        return options
    
    print()
    print("--------------------------------------------")
    print("  Username")
    print("--------------------------------------------")
    print(f"Currently set to: {options['account_name']}")
    new_username = input("Type new username or hit Enter to keep current: ").strip()
    if new_username:
        options['account_name'] = new_username
        print(f"Username changed to: {options['account_name']}")
    else:
        print(f"Keeping username: {options['account_name']}")
    
    print()
    print("--------------------------------------------")
    print("  Save Location")
    print("--------------------------------------------")
    print()
    print("Options:")
    print("  1. PORTABLE - saves in game folder (relative to DLL)")
    print("     WARNING: Saves stored with game files, not in AppData")
    print()
    print("  0. APPDATA - Saves in AppData folder (default, recommended)")
    print("     Saves persist even if game is deleted/moved")
    print()
    
    if options['portable'] == '1':
        print(f"Currently: PORTABLE (path: {options['local_save_path']})")
    else:
        print(f"Currently: APPDATA (folder: {options['saves_folder_name']})")
    print()
    
    save_choice = input("Choose save location (1=Portable, 0=AppData, Enter=keep current): ").strip()
    
    if save_choice == '1':
        options['portable'] = '1'
        print()
        print(f"Current portable path: {options['local_save_path']}")
        print("This path is relative to the game's steam_api DLL location.")
        new_path = input("Enter save folder name (or Enter for current): ").strip()
        if new_path:
            options['local_save_path'] = new_path
        print(f"Portable saves will be stored in: ./{options['local_save_path']}/")
        
    elif save_choice == '0':
        options['portable'] = '0'
        print()
        print(f"Current AppData folder name: {options['saves_folder_name']}")
        new_folder = input("Enter folder name (or Enter for 'GSE Saves'): ").strip()
        if new_folder:
            options['saves_folder_name'] = new_folder
        else:
            options['saves_folder_name'] = 'GSE Saves'
        print(f"Saves will be stored in: %AppData%/{options['saves_folder_name']}/")
    else:
        print("Keeping current save location setting.")
    
    # Ask about disabling future prompts
    print()
    print("--------------------------------------------")
    disable_ask = input("Stop asking every time? (Y/N): ").strip().upper()
    if disable_ask == 'Y':
        options['ask'] = '0'
        print("Got it! Will use these settings silently next time.")
        print("(Change ask=0 to ask=1 in options.txt to re-enable prompts)")
    else:
        options['ask'] = '1'
    
    # Save the options for next time
    save_user_options(options)
    
    print()
    print("Settings updated!")
    print()
    
    return options


def download_and_merge_steam_ids():
    """Download and merge Steam IDs from GitHub with hardcoded list."""
    print(f"Starting with {len(HARDCODED_STEAM_IDS)} hardcoded Steam IDs...")
    final_steam_ids = HARDCODED_STEAM_IDS.copy()
    
    try:
        print("Attempting to download Steam IDs from GitHub...")
        with urllib.request.urlopen(STEAM_IDS_URL, timeout=10) as response:
            content = response.read().decode('utf-8')
            
            with open(LOCAL_STEAM_IDS_FILE, 'w') as f:
                f.write(content)
            
            github_steam_ids = []
            for line in content.strip().split('\n'):
                line = line.strip()
                if line:
                    try:
                        github_steam_ids.append(int(line))
                    except ValueError:
                        pass
            
            for steam_id in github_steam_ids:
                if steam_id not in HARDCODED_STEAM_IDS:
                    final_steam_ids.append(steam_id)
                    
    except Exception as e:
        print(f"Error downloading Steam IDs: {e}")
        try:
            with open(LOCAL_STEAM_IDS_FILE, 'r') as f:
                content = f.read()
                for line in content.strip().split('\n'):
                    line = line.strip()
                    if line:
                        try:
                            steam_id = int(line)
                            if steam_id not in final_steam_ids:
                                final_steam_ids.append(steam_id)
                        except ValueError:
                            pass
        except:
            pass
    
    return final_steam_ids

TOP_OWNER_IDS = download_and_merge_steam_ids()

from stats_schema_achievement_gen import achievements_gen
from controller_config_generator import parse_controller_vdf
from steam.client import SteamClient
from steam.client.cdn import CDNClient
from steam.enums import common
from steam.enums.common import EResult
from steam.enums.emsg import EMsg
from steam.core.msg import MsgProto

if len(sys.argv) < 2:
    print("\nUsage: ARMGDDN.Steam.Settings.exe APPID\n\nExample: ARMGDDN.Steam.Settings.exe 480\n")
    sys.exit(1)

appids = []
for id in sys.argv[1:]:
    appids += [int(id)]

client = SteamClient()

print("Connecting to Steam (anonymous)...")
result = client.anonymous_login()
if result != EResult.OK:
    print(f"Steam connection failed: {result}")
    print("Check your internet connection and try again.")
    sys.exit(1)
print("Connected.")


def get_stats_schema(client, game_id, owner_id):
    message = MsgProto(EMsg.ClientGetUserStats)
    message.body.game_id = game_id
    message.body.schema_local_version = -1
    message.body.crc_stats = 0
    message.body.steam_id_for_user = owner_id
    client.send(message)
    return client.wait_msg(EMsg.ClientGetUserStatsResponse, timeout=1)


def download_achievement_images(game_id, image_names, output_folder):
    """Download achievement images to images/ folder (GBE format)."""
    q = queue.Queue()

    def downloader_thread():
        while True:
            name = q.get()
            if name is None:
                q.task_done()
                return
            succeeded = False
            for u in ["https://cdn.akamai.steamstatic.com/steamcommunity/public/images/apps/",
                      "https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/apps/"]:
                url = "{}{}/{}".format(u, game_id, name)
                try:
                    with urllib.request.urlopen(url) as response:
                        image_data = response.read()
                        with open(os.path.join(output_folder, name), "wb") as f:
                            f.write(image_data)
                        succeeded = True
                        break
                except urllib.error.HTTPError as e:
                    print(f"HTTPError downloading {url}: {e.code}")
                except urllib.error.URLError as e:
                    print(f"URLError downloading {url}: {e.reason}")
            if not succeeded:
                print(f"Error: could not download {name}")
            q.task_done()

    num_threads = 20
    for i in range(num_threads):
        threading.Thread(target=downloader_thread, daemon=True).start()

    for name in image_names:
        q.put(name)
    q.join()

    for i in range(num_threads):
        q.put(None)
    q.join()


def generate_achievement_stats(client, game_id, output_directory):
    """Generate achievements.json and stats.json (GBE format)."""
    images_dir = os.path.join(output_directory, "images")
    images_to_download = []
    
    if not TOP_OWNER_IDS:
        print("Warning: No Steam IDs available. Skipping achievement stats generation.")
        return False
    
    stats_generated = False
    steam_id_list = TOP_OWNER_IDS
    
    print(f"Fetching achievement schema (trying up to {len(steam_id_list)} Steam IDs)...")
    for i, x in enumerate(steam_id_list):
        out = get_stats_schema(client, game_id, x)
        if out is not None:
            if len(out.body.schema) > 0:
                try:
                    achievements, stats = achievements_gen.generate_stats_achievements(
                        out.body.schema, output_directory
                    )
                    
                    if stats and len(stats) > 0:
                        stats_generated = True
                        print(f"Generated stats.json with {len(stats)} stats")
                    
                    for ach in achievements:
                        if "icon" in ach:
                            icon_name = ach["icon"].replace("images/", "")
                            images_to_download.append(icon_name)
                        if "icon_gray" in ach:
                            icon_name = ach["icon_gray"].replace("images/", "")
                            images_to_download.append(icon_name)
                        if "icongray" in ach:
                            icon_name = ach["icongray"].replace("images/", "")
                            images_to_download.append(icon_name)
                    print(f"Got achievement schema from ID #{i+1} ({len(achievements)} achievements)")
                    break
                except ValueError as e:
                    print(f"Error generating stats for Steam ID {x}: {e}")
                    continue

    if not images_to_download:
        print("No achievements found for this game.")

    if len(images_to_download) > 0:
        if not os.path.exists(images_dir):
            os.makedirs(images_dir)
        download_achievement_images(game_id, images_to_download, images_dir)
        print(f"Downloaded {len(images_to_download)} achievement images to images/ folder")
    
    return stats_generated


def get_inventory_info(client, game_id):
    return client.send_um_and_wait('Inventory.GetItemDefMeta#1', {'appid': game_id})


def generate_inventory(client, game_id):
    inventory = get_inventory_info(client, game_id)
    if inventory.header.eresult != EResult.OK:
        return None
    url = f"https://api.steampowered.com/IGameInventory/GetItemDefArchive/v0001?appid={game_id}&digest={inventory.body.digest}"
    try:
        with urllib.request.urlopen(url) as response:
            return response.read()
    except urllib.error.HTTPError as e:
        print(f"HTTPError getting inventory: {e.code}")
    except urllib.error.URLError as e:
        print(f"URLError getting inventory: {e.reason}")
    return None


def get_dlc(raw_infos):
    """Extract DLC information from game info."""
    try:
        try:
            dlc_list = set(map(lambda a: int(a), raw_infos["extended"]["listofdlc"].split(",")))
        except:
            dlc_list = set()
        depot_app_list = set()
        if "depots" in raw_infos:
            depots = raw_infos["depots"]
            for dep in depots:
                depot_info = depots[dep]
                if "dlcappid" in depot_info:
                    dlc_list.add(int(depot_info["dlcappid"]))
                if "depotfromapp" in depot_info:
                    depot_app_list.add(int(depot_info["depotfromapp"]))
        return (dlc_list, depot_app_list)
    except:
        print("Could not get DLC infos, are there any DLCs?")
        return (set(), set())


def generate_configs_app_ini(output_directory, dlc_list=None):
    """
    Generate configs.app.ini (GBE format) with DLC entries.
    Always creates the file with default config sections.
    
    dlc_list: list of tuples (appid, name) - e.g. [(1234, "DLC Name"), (5678, "Another DLC")]
              Can be None or empty for no DLCs.
    """
    
    if dlc_list is None:
        dlc_list = []
    
    ini_path = os.path.join(output_directory, "configs.app.ini")
    
    lines = []
    
    lines.append("")
    lines.append("[app::general]")
    lines.append("# by default the emu will report a `non-beta` branch when the game calls `Steam_Apps::GetCurrentBetaName()`")
    lines.append("# 1=make the game/app think we're playing on a beta branch")
    lines.append("# default=0")
    lines.append("is_beta_branch=0")
    lines.append("# the name of the current branch, this must also exist in branches.json")
    lines.append("# otherwise will be ignored by the emu and the default 'public' branch will be used")
    lines.append("# default=public")
    lines.append("branch_name=public")
    
    lines.append("")
    lines.append("[app::dlcs]")
    lines.append("# 1=report all DLCs as unlocked")
    lines.append("# 0=report only the DLCs mentioned")
    lines.append("# some games check for \"hidden\" DLCs, hence this should be set to 1 in that case")
    lines.append("# but other games detect emus by querying for a fake/bad DLC, hence this should be set to 0 in that case")
    lines.append("# default=1")
    lines.append("unlock_all=1")
    lines.append("# format: ID=name")
    
    for dlc_id, dlc_name in dlc_list:
        if dlc_name is not None:
            lines.append(f"{dlc_id}={dlc_name}")
        else:
            lines.append(f"{dlc_id}=Unknown DLC")
    
    lines.append("")
    lines.append("[app::paths]")
    lines.append("# some rare games might need to be provided one or more paths to appids")
    lines.append("# for example the path to where a DLC is installed")
    lines.append("# this sets the paths returned by the Steam_Apps::GetAppInstallDir function")
    lines.append("#556760=../DLCRoot0")
    lines.append("#1234=./folder_where_steam_api_is")
    lines.append("#3456=../folder_one_level_above_where_steam_api_is")
    lines.append("#5678=../../folder_two_levels_above_where_steam_api_is")
    lines.append("# however some other games might expect this function to return empty paths to properly load DLCs")
    lines.append("# you can deliberately set the path to be empty to specify this behavior like lines below")
    lines.append("#1337=")
    
    lines.append("")
    lines.append("[app::cloud_save::general]")
    lines.append("# should the emu create the default directory for cloud saves on startup:")
    lines.append("#   [Steam Install]/userdata/{Steam3AccountID}/{AppID}/")
    lines.append("# default=1")
    lines.append("create_default_dir=0")
    lines.append("# should the emu create the directories specified in the cloud saves section of the current OS on startup")
    lines.append("# default=1")
    lines.append("create_specific_dirs=1")
    lines.append("# directories which should be created on startup, this is used for cloud saves")
    lines.append("# some games refuse to work unless these directories exist")
    lines.append("# there are reserved identifiers which are replaced at runtime")
    lines.append("# you can find a list of them here:")
    lines.append("#   https://partner.steamgames.com/doc/features/cloud#setup")
    lines.append("#")
    lines.append("# the identifiers must be wrapped with double colons \":::\" like this:")
    lines.append("#   original value: {SteamCloudDocuments}")
    lines.append("#   ini value:      {::SteamCloudDocuments::}")
    lines.append("# notice the braces \"{\" and \"}\", they are not changed")
    lines.append("# the double colons are added between them as shown above")
    lines.append("#")
    lines.append("# === known identifiers:")
    lines.append("# ---")
    lines.append("# --- general:")
    lines.append("# ---")
    lines.append("# Steam3AccountID=current account ID in Steam3 format")
    lines.append("# 64BitSteamID=current account ID in Steam64 format")
    lines.append("# gameinstall=[Steam Install]\\SteamApps\\common\\[Game Folder]\\")
    lines.append("# EmuSteamInstall=this is an emu specific variable, the value preference is as follows:")
    lines.append("#  - from environment variable: SteamPath")
    lines.append("#  - or from environment variable: InstallPath")
    lines.append("#  - or if using coldclientloader: directory of steamclient")
    lines.append("#  - or if NOT using coldclientloader: directory of steam_api")
    lines.append("#  - or directory of exe")
    lines.append("# ---")
    lines.append("# --- Windows only:")
    lines.append("# ---")
    lines.append("# WinMyDocuments=%USERPROFILE%\\My Documents\\")
    lines.append("# WinAppDataLocal=%USERPROFILE%\\AppData\\Local\\")
    lines.append("# WinAppDataLocalLow=%USERPROFILE%\\AppData\\LocalLow\\")
    lines.append("# WinAppDataRoaming=%USERPROFILE%\\AppData\\Roaming\\")
    lines.append("# WinSavedGames=%USERPROFILE%\\Saved Games\\")
    lines.append("# ---")
    lines.append("# --- Linux only:")
    lines.append("# ---")
    lines.append("# LinuxHome=~/")
    lines.append("# SteamCloudDocuments=")
    lines.append("#   - Linux:   ~/.SteamCloud/[username]/[Game Folder]/")
    lines.append("#   - Windows: X")
    lines.append("#   - MAcOS:   X")
    lines.append("# LinuxXdgDataHome=")
    lines.append("#   - if 'XDG_DATA_HOME' is defined: $XDG_DATA_HOME/")
    lines.append("#   - otherwise:                     $HOME/.local/share")
    
    lines.append("")
    lines.append("[app::cloud_save::win]")
    lines.append("#dir1={::WinAppDataRoaming::}/publisher_name/some_game")
    lines.append("#dir2={::WinMyDocuments::}/publisher_name/some_game/{::Steam3AccountID::}")
    
    lines.append("")
    lines.append("[app::cloud_save::linux]")
    lines.append("#dir1={::LinuxXdgDataHome::}/publisher_name/some_game")
    lines.append("#dir2={::LinuxHome::}/publisher_name/some_game/{::64BitSteamID::}")
    
    with open(ini_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    if len(dlc_list) > 0:
        print(f"Created configs.app.ini with {len(dlc_list)} DLC entries")
    else:
        print("Created configs.app.ini (no DLCs)")


def generate_configs_user_ini(output_directory, options):
    """
    Generate configs.user.ini (GBE format) using provided options.
    Matches the exact template format.
    """
    ini_path = os.path.join(output_directory, "configs.user.ini")
    
    lines = []
    
    lines.append("[user::general]")
    lines.append("# user account name")
    lines.append("# default=gse orca")
    lines.append(f"account_name={options['account_name']}")
    lines.append("# your account ID in Steam64 format")
    lines.append("# if the specified ID is invalid, the emu will ignore it and generate a proper one")
    lines.append("# default=randomly generated by the emu only once and saved in the global settings")
    lines.append("account_steamid=76561197960287930")
    lines.append("# Example Base64 Ticket.")
    lines.append("#ticket=SGVyZSBsYXlzIHlvdXIgQmFzZTY0IFRpY2tldCB5b3UgYmVhdXRpZnVsIGhhY2tlcg==")
    lines.append("# Alt SteamId for encrypted savegames.")
    lines.append("#alt_steamid=0")
    lines.append("# How many calls before swapping out the SteamId to Alt")
    lines.append("# IT WILL REPLACE AFTER THOSE CALLS BE AWARE!")
    lines.append("#alt_steamid_count=5")
    lines.append("# the language reported to the app/game")
    lines.append("# this must exist in 'supported_languages.txt', otherwise it will be ignored by the emu")
    lines.append("# look for the column 'API language code' here: https://partner.steamgames.com/doc/store/localization/languages")
    lines.append("# default=english")
    lines.append("language=english")
    lines.append("# report a country IP if the game queries it")
    lines.append("# ISO 3166-1-alpha-2 format, use this link to get the 'Alpha-2' country code: https://www.iban.com/country-codes")
    lines.append("# default=US")
    lines.append("ip_country=US")
    
    lines.append("")
    lines.append("[user::saves]")
    lines.append("# when this is set, it will force the emu to use the specified location instead of the default global location")
    lines.append("# path could be absolute, or relative to the location of the .dll/.so")
    lines.append("# leading and trailing whitespaces are trimmed")
    lines.append("# when this option is used, the global settings folder is completely ignored, allowing a full portable behavior")
    lines.append("# default=")
    
    if options['portable'] == '1':
        lines.append(f"local_save_path={options['local_save_path']}")
    else:
        lines.append("local_save_path=")
    
    lines.append("# name of the base folder used to store save data, leading and trailing whitespaces are trimmed")
    lines.append("# only useful if 'local_save_path' isn't used")
    lines.append("# default=GSE Saves")
    lines.append(f"saves_folder_name={options['saves_folder_name']}")
    
    with open(ini_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print("Created configs.user.ini")
    if options['portable'] == '1':
        print(f"  Save location: PORTABLE (./{options['local_save_path']}/)")    
    else:
        print(f"  Save location: AppData ({options['saves_folder_name']})")

def generate_configs_overlay_ini(output_directory):
    """
    Generate configs.overlay.ini.disabled (GBE format).
    Disabled by default - user can rename to configs.overlay.ini to enable.
    """
    ini_path = os.path.join(output_directory, "configs.overlay.ini.disabled")
    
    content = """# ----------------------------
# XXXXXXXXXXXXXXXXXXXXXXXXXXXX
# XXX USE AT YOUR OWN RISK XXX
# XXXXXXXXXXXXXXXXXXXXXXXXXXXX
# ----------------------------
# 
# This feature might cause crashes or other problems
# RENAME THIS FILE TO configs.overlay.ini TO ENABLE
# 
# ############################################################################## #
# you do not have to specify everything, pick and choose the options you need only
# ############################################################################## #

[overlay::general]
# 1=enable the experimental overlay, might cause crashes
# default=0
enable_experimental_overlay=1
# amount of time to wait before attempting to detect and hook the renderer (DirectX, OpenGL, etc...)
# default=0
hook_delay_sec=0
# timeout for the renderer detector
# default=15
renderer_detector_timeout_sec=15
# 1=disable the achievements notifications
# default=0
disable_achievement_notification=0
# 1=disable friends invitations and messages notifications
# default=0
disable_friend_notification=0
# 1=disable showing notifications for achievements progress
# default=0
disable_achievement_progress=0
# 1=disable any warning in the overlay
# default=0
disable_warning_any=0
# 1=disable the bad app ID warning in the overlay
# default=0
disable_warning_bad_appid=0
# 1=disable the local_save warning in the overlay
# default=0
disable_warning_local_save=0
# by default the overlay will attempt to upload the achievements icons to the GPU
# so that they are displayed, in rare cases this might keep failing and cause FPS drop
# 0=prevent the overlay from attempting to upload the icons periodically,
#   in that case achievements icons win't be displayed
# default=1
upload_achievements_icons_to_gpu=1
# amount of frames to accumulate, to eventually calculate the average frametime (in milliseconds)
# lower values would result in instantaneous frametime/fps, but the FPS would be erratic
# higher values would result in a more stable frametime/fps, but will be inaccurate due to averaging over long time
# minimum allowed value = 1
# default=10
fps_averaging_window=10
# 1=always show user info in the overlay
# default=0
overlay_always_show_user_info=0
# 1=always show fps in the overlay
# default=0
overlay_always_show_fps=0
# 1=always show frametime in the overlay
# default=0
overlay_always_show_frametime=0
# 1=always show playtime in the overlay
# default=0
overlay_always_show_playtime=0

[overlay::appearance]
# load custom TrueType font from a path, it could be absolute, or relative
# relative paths will be looked up inside the local folder "steam_settings/fonts" first,
# if that wasn't found, it will be looked up inside the global folder "GSE Settings/settings/fonts"
# default=
Font_Override=Roboto-Medium.ttf
# global font size
# for built-in font, multiple of 16 is recommended. e.g. 16 32...
# default=16.0
Font_Size=20.0

# achievement icon size
Icon_Size=64.0

# spacing between characters
Font_Glyph_Extra_Spacing_x=1.0
Font_Glyph_Extra_Spacing_y=0.0

# background for all types of notifications
Notification_R=0.12
Notification_G=0.14
Notification_B=0.21
Notification_A=1.0

# notifications corners roundness
Notification_Rounding=10.0
# horizontal (x) and vertical (y) margins for the notifications
Notification_Margin_x=5.0
Notification_Margin_y=5.0

# duration/timing for various notification types (in seconds)
# duration of notification animation in seconds. Set to 0 to disable
Notification_Animation=0.35
# duration of achievement progress indication
Notification_Duration_Progress=6.0
# duration of achievement unlocked
Notification_Duration_Achievement=7.0
# duration of friend invitation
Notification_Duration_Invitation=8.0
# duration of chat message
Notification_Duration_Chat=4.0

# format for the achievement unlock date/time, limited to 79 characters
# if the output formatted string exceeded this limit, the builtin format will be used
# look for the format here: https://en.cppreference.com/w/cpp/chrono/c/strftime
# default=%Y/%m/%d - %H:%M:%S
Achievement_Unlock_Datetime_Format=%Y/%m/%d - %H:%M:%S

# main background when you press shift+tab
Background_R=0.12
Background_G=0.11
Background_B=0.11
Background_A=0.55

Element_R=0.30
Element_G=0.32
Element_B=0.40
Element_A=1.0

ElementHovered_R=0.278
ElementHovered_G=0.393
ElementHovered_B=0.602
ElementHovered_A=1.0

ElementActive_R=-1.0
ElementActive_G=-1.0
ElementActive_B=-1.0
ElementActive_A=-1.0

# ############################# #
# available options:
# top_left
# top_center
# top_right
# bot_left
# bot_center
# bot_right

# position of achievements
PosAchievement=bot_right
# position of invitations
PosInvitation=top_right
# position of chat messages
PosChatMsg=top_center
# ############################# #

# ############################# #
# FPS background color
Stats_Background_R=0.0
Stats_Background_G=0.0
Stats_Background_B=0.0
Stats_Background_A=0.6

# FPS text color
Stats_Text_R=0.8
Stats_Text_G=0.7
Stats_Text_B=0.0
Stats_Text_A=1.0

# FPS position in percentage [0.0, 1.0]
# X=0.0 : left
# X=1.0 : right
Stats_Pos_x=0.0

# Y=0.0 : up
# Y=1.0 : down
Stats_Pos_y=0.0
# ############################# #
"""
    
    with open(ini_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Created configs.overlay.ini.disabled")

# Main execution
user_options = prompt_user_options()

for appid in appids:
    out_dir = "steam_settings"

    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    print(f"Outputting config to {out_dir}")

    raw = client.get_product_info(apps=[appid])
    game_info = raw["apps"][appid]

    if "common" in game_info:
        game_info_common = game_info["common"]
        try:
            generate_achievement_stats(client, appid, out_dir)
        except Exception as e:
            print(f"Unhandled exception during achievement stats generation for appid {appid}: {e}")

    with open(os.path.join(out_dir, "steam_appid.txt"), 'w') as f:
        f.write(str(appid))
    print(f"Created steam_appid.txt with appid {appid}")

    dlc_config_list = []
    dlc_list, depot_app_list = get_dlc(game_info)
    
    if len(dlc_list) > 0:
        print(f"Fetching info for {len(dlc_list)} DLCs...")
        dlc_raw = client.get_product_info(apps=dlc_list)["apps"]
        for dlc in dlc_raw:
            try:
                dlc_config_list.append((dlc, dlc_raw[dlc]["common"]["name"]))
            except:
                dlc_config_list.append((dlc, None))

    generate_configs_app_ini(out_dir, dlc_config_list)
    generate_configs_user_ini(out_dir, user_options)
    generate_configs_overlay_ini(out_dir)

    print(f"\nSteam settings generation complete for appid {appid}")
    print("Files created in steam_settings/ folder:")
    print("  - steam_appid.txt")
    print("  - achievements.json (if available)")
    print("  - stats.json (if available)")
    print("  - images/ folder (achievement icons)")
    print("  - configs.app.ini (DLC configuration)")
    print("  - configs.user.ini (user settings)")
    print("  - configs.overlay.ini.disabled (rename to enable overlay)")
