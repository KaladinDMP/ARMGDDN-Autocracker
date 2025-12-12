import requests
import json
import os
import time
import sys
import difflib  # Built-in, no install needed


def get_executable_path():
    """Return the folder where the EXE / script is running from."""
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    else:
        return os.path.dirname(os.path.abspath(__file__))


def get_file_path(filename):
    """Get a path to a file in the same folder as the EXE / script."""
    return os.path.join(get_executable_path(), filename)


def preprocess_game_name(game_name):
    """Lightweight cleaner. Should match how names are stored in steam_app_dict.json."""
    if not isinstance(game_name, str):
        return ""
    # Keep only alphanumeric + space
    cleaned = ''.join(char for char in game_name if char.isalnum() or char.isspace())
    cleaned = cleaned.lower().strip()

    # Simple stopword removal, same style as the updater
    stop_words = {"the", "a", "an", "of", "and", "in", "for", "to"}
    tokens = cleaned.split()
    filtered_tokens = [t for t in tokens if t not in stop_words]

    return " ".join(filtered_tokens)


def write_steam_appid_file(app_id):
    filename = get_file_path("steam_appid.txt")
    with open(filename, 'w', encoding="utf-8") as file:
        file.write(str(app_id))
    print(f"steam_appid.txt file created with App ID: {app_id}")


def save_app_dict(app_dict):
    filename = get_file_path("steam_app_dict.json")
    with open(filename, 'w', encoding="utf-8") as file:
        json.dump(app_dict, file)


def load_app_dict():
    filename = get_file_path("steam_app_dict.json")
    app_dict = {}
    if os.path.exists(filename):
        try:
            with open(filename, 'r', encoding="utf-8") as file:
                app_dict_data = json.load(file)
                for app_id, app_data in app_dict_data.items():
                    app_dict[app_id] = {
                        'original_name': app_data['original_name'],
                        'processed_name': app_data['processed_name']
                    }
        except (json.JSONDecodeError, OSError) as e:
            print(f"Error loading {filename}: {e}")
    else:
        print(f"{filename} not found.")
    return app_dict


def save_non_game_apps(non_game_apps):
    filename = get_file_path("non_game_apps.json")
    with open(filename, 'w', encoding="utf-8") as file:
        json.dump(list(non_game_apps), file)


def load_non_game_apps():
    filename = get_file_path("non_game_apps.json")
    if os.path.exists(filename):
        try:
            with open(filename, 'r', encoding="utf-8") as file:
                non_game_apps = set(str(app_id) for app_id in json.load(file))
                return non_game_apps
        except json.JSONDecodeError:
            print("Error: Invalid JSON data in non_game_apps.json file.")
            return set()
        except OSError as e:
            print(f"Error reading non_game_apps.json: {e}")
            return set()
    else:
        return set()


def update_app_dict_from_github():
    """
    Download steam_app_dict.json from GitHub and save it next to the EXE/script.
    """
    GITHUB_RAW_URL = (
        "https://raw.githubusercontent.com/"
        "KaladinDMP/ARMGDDN-Autocracker-OG-GSE/"
        "main/Resources/AppID/steam_app_dict.json"
    )

    print("Downloading app dictionary from GitHub...")
    try:
        resp = requests.get(GITHUB_RAW_URL, timeout=30)
    except requests.RequestException as e:
        print(f"Error downloading from GitHub: {e}")
        return False

    if resp.status_code != 200:
        print(f"GitHub returned HTTP {resp.status_code}. Using existing local copy.")
        return False

    local_filename = get_file_path("steam_app_dict.json")
    try:
        with open(local_filename, "w", encoding="utf-8") as f:
            f.write(resp.text)
        print("steam_app_dict.json updated from GitHub.")
        return True
    except OSError as e:
        print(f"Error writing local steam_app_dict.json: {e}")
        return False


def is_game(app_id):
    url = f"https://store.steampowered.com/api/appdetails?appids={app_id}"
    try:
        response = requests.get(url, timeout=15)
    except requests.RequestException:
        return False

    if response.status_code == 200:
        try:
            data = json.loads(response.text)
        except json.JSONDecodeError:
            return False

        if str(app_id) in data and data[str(app_id)].get('success'):
            return data[str(app_id)]['data'].get('type') == 'game'
    return False


def get_game_name_from_appid(app_id, app_dict):
    """Look up game name from appid in local dictionary."""
    app_id_str = str(app_id)
    if app_id_str in app_dict:
        return app_dict[app_id_str]['original_name']
    return None


def verify_appid_online(app_id):
    """Verify appid exists and get name from Steam API."""
    url = f"https://store.steampowered.com/api/appdetails?appids={app_id}"
    try:
        response = requests.get(url, timeout=15)
        if response.status_code == 200:
            data = json.loads(response.text)
            if str(app_id) in data and data[str(app_id)].get('success'):
                return data[str(app_id)]['data'].get('name', 'Unknown')
    except:
        pass
    return None


def search_games(game_name, app_dict, non_game_apps):
    """
    Search for games with fuzzy matching.
    Returns list of (app_id, original_name) tuples sorted by relevance.
    """
    processed_name = preprocess_game_name(game_name)
    matching_games = []

    if not processed_name:
        return matching_games

    search_tokens = processed_name.split()

    for app_id, app_data in app_dict.items():
        if app_id in non_game_apps:
            continue

        processed_game_name = app_data['processed_name'].lower()
        game_tokens = processed_game_name.split()

        # Method 1: Exact substring match (original behavior) - highest priority
        if processed_name in processed_game_name:
            matching_games.append((app_id, app_data['original_name'], 100))
            continue

        # Method 2: All search tokens found in game name (any order)
        all_tokens_found = all(token in processed_game_name for token in search_tokens)
        if all_tokens_found:
            matching_games.append((app_id, app_data['original_name'], 90))
            continue

        # Method 3: Fuzzy match on individual tokens (TIGHTER)
        if len(search_tokens) >= 1:
            fuzzy_matches = 0
            for search_token in search_tokens:
                # Skip very short tokens for fuzzy matching (too many false positives)
                if len(search_token) < 3:
                    continue
                    
                # Check for close matches in game tokens (handles typos)
                # Increased cutoff from 0.75 to 0.85
                close = difflib.get_close_matches(search_token, game_tokens, n=1, cutoff=0.85)
                if close:
                    fuzzy_matches += 1
                # Substring match only if search token is 4+ chars and matches START of game token
                elif len(search_token) >= 4:
                    for gt in game_tokens:
                        if gt.startswith(search_token) or search_token.startswith(gt):
                            fuzzy_matches += 0.75
                            break

            # Require at least 70% of tokens to match (was 50%)
            if len(search_tokens) > 0:
                match_ratio = fuzzy_matches / len(search_tokens)
                if match_ratio >= 0.7:
                    matching_games.append((app_id, app_data['original_name'], int(match_ratio * 80)))

    # Sort by score (highest first) and return top 15 (was 25)
    matching_games.sort(key=lambda x: x[2], reverse=True)

    # Return without scores
    return [(app_id, name) for app_id, name, score in matching_games[:15]]

def remove_non_games(matching_games, non_game_apps):
    updated_matching_games = []
    for app_id, game_name in matching_games:
        if not is_game(app_id):
            non_game_apps.add(app_id)
        else:
            updated_matching_games.append((app_id, game_name))
    return updated_matching_games, non_game_apps


def save_last_update_timestamp(timestamp):
    filename = get_file_path("last_update_timestamp.txt")
    with open(filename, 'w', encoding="utf-8") as file:
        file.write(str(timestamp))


def load_last_update_timestamp():
    filename = get_file_path("last_update_timestamp.txt")
    if os.path.exists(filename):
        try:
            with open(filename, 'r', encoding="utf-8") as file:
                return float(file.read())
        except (ValueError, OSError):
            return 0
    return 0


# ---------------- main flow ----------------

print("Loading app dictionary...")
app_dict = load_app_dict()
print("App dictionary loaded.")

print("Loading non-game app IDs...")
non_game_apps = load_non_game_apps()
print("Non-game app IDs loaded.")

print("Checking for updates...")
last_update_timestamp = load_last_update_timestamp()
current_timestamp = time.time()

if current_timestamp - last_update_timestamp >= 24 * 60 * 60:
    print("Downloading latest app dictionary from GitHub...")
    if update_app_dict_from_github():
        app_dict = load_app_dict()
        save_last_update_timestamp(current_timestamp)
        print("App dictionary updated successfully from GitHub.")
    else:
        print("Failed to update app dictionary from GitHub. Using existing local copy.")
else:
    print("App dictionary is up to date.")

# Edge case: no app dictionary at all
if not app_dict:
    print()
    print("No app dictionary is available, so I can't search Steam apps.")
    print("Make sure you have an internet connection the first time you run this tool,")
    print("or manually place a valid steam_app_dict.json next to the EXE/script.")
    print("Exiting.")
    sys.exit(1)

# Normal interactive flow
while True:
    print()
    print("============================================")
    print("  Enter game name for fuzzy search")
    print("  OR enter AppID directly (numbers only)")
    print("============================================")
    user_input = input("Game name or AppID (or 'x' to exit): ").strip()
    
    if user_input.lower() == 'x':
        print("Exiting the script.")
        break

    # Check if input is a number (direct appid)
    if user_input.isdigit():
        app_id = user_input
        print(f"Detected AppID: {app_id}")
        
        # Try to find name in local dictionary first
        game_name = get_game_name_from_appid(app_id, app_dict)
        
        if game_name:
            print(f"Found in database: {game_name}")
            confirm = input(f"Use AppID {app_id} ({game_name})? (Y/N): ").strip().upper()
            if confirm == 'Y' or confirm == '':
                write_steam_appid_file(app_id)
                save_non_game_apps(non_game_apps)
                print("Exiting the script.")
                sys.exit(0)
            else:
                print("Cancelled. Try again.")
                continue
        else:
            # Not in local dict, verify online
            print("Not in local database, checking Steam...")
            online_name = verify_appid_online(app_id)
            if online_name:
                print(f"Found on Steam: {online_name}")
                confirm = input(f"Use AppID {app_id} ({online_name})? (Y/N): ").strip().upper()
                if confirm == 'Y' or confirm == '':
                    write_steam_appid_file(app_id)
                    save_non_game_apps(non_game_apps)
                    print("Exiting the script.")
                    sys.exit(0)
                else:
                    print("Cancelled. Try again.")
                    continue
            else:
                # Can't verify, ask user if they want to use it anyway
                print(f"Could not verify AppID {app_id} online.")
                confirm = input(f"Use AppID {app_id} anyway? (Y/N): ").strip().upper()
                if confirm == 'Y':
                    write_steam_appid_file(app_id)
                    save_non_game_apps(non_game_apps)
                    print("Exiting the script.")
                    sys.exit(0)
                else:
                    print("Cancelled. Try again.")
                    continue

    # Not a number, do fuzzy search
    game_name = user_input
    print("Searching for matching games (fuzzy search enabled)...")
    matching_games = search_games(game_name, app_dict, non_game_apps)

    if matching_games:
        print("Checking if the matching games are actual games...")
        updated_matching_games, non_game_apps = remove_non_games(matching_games, non_game_apps)

        if updated_matching_games:
            print()
            print("Matching games found:")
            print("-" * 50)
            for index, (app_id, gn) in enumerate(updated_matching_games, start=1):
                print(f"{index}. {gn} (AppID: {app_id})")

            print("-" * 50)
            print(f"{len(updated_matching_games) + 1}. None of these - search again")
            print(f"{len(updated_matching_games) + 2}. None of these - quit")

            while True:
                selection = input("Enter the number of the correct game: ")

                try:
                    selection = int(selection)
                    if 1 <= selection <= len(updated_matching_games):
                        selected_app_id, selected_game_name = updated_matching_games[selection - 1]
                        print(f"Selected: {selected_game_name} (AppID: {selected_app_id})")
                        write_steam_appid_file(selected_app_id)
                        save_non_game_apps(non_game_apps)
                        print("Exiting the script.")
                        sys.exit(0)
                    elif selection == len(updated_matching_games) + 1:
                        print("Searching again...")
                        break
                    elif selection == len(updated_matching_games) + 2:
                        print("Exiting - enter the AppID manually.")
                        sys.exit(0)
                    else:
                        print("Invalid selection. Please try again.")
                except ValueError:
                    print("Invalid input. Please enter a valid number.")
        else:
            print("No matching games found after verification.")
            print("Tip: Try a different spelling, or enter the AppID directly if you know it.")
    else:
        print("No matching games found.")
        print("Tip: Try fewer words, different spelling, or enter the AppID directly.")

print("Saving non-game app IDs...")
save_non_game_apps(non_game_apps)
print("Exiting the script.")
sys.exit(0)