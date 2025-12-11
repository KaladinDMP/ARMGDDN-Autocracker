import vdf
import sys
import os
import json


STAT_TYPE_INT = '1'
STAT_TYPE_FLOAT = '2'
STAT_TYPE_AVGRATE = '3'
STAT_TYPE_BITS = '4'


def generate_stats_achievements(schema, config_directory):
    """
    Generate achievements.json and stats.json from Steam schema binary data.
    
    Args:
        schema: Binary schema data from Steam
        config_directory: Output directory for generated files
    
    Returns:
        Tuple of (achievements_list, stats_list)
    """
    schema = vdf.binary_loads(schema)
    achievements_out = []
    stats_out = []

    for appid in schema:
        sch = schema[appid]
        stat_info = sch['stats']
        for s in stat_info:
            stat = stat_info[s]
            if stat['type'] == STAT_TYPE_BITS:
                # This is an achievement
                achs = stat['bits']
                for ach_num in achs:
                    out = {}
                    ach = achs[ach_num]
                    out["hidden"] = '0'
                    for x in ach['display']:
                        value = ach['display'][x]
                        if x == 'name':
                            x = 'displayName'
                        if x == 'desc':
                            x = 'description'
                        if x == 'Hidden':
                            x = 'hidden'
                        out[x] = value
                    out['name'] = ach['name']
                    if 'progress' in ach:
                        out['progress'] = ach['progress']
                    achievements_out += [out]
            else:
                # This is a stat
                out = {}
                out['name'] = stat['name']
                
                # Determine stat type
                if stat['type'] == STAT_TYPE_INT:
                    out['type'] = 'int'
                elif stat['type'] == STAT_TYPE_FLOAT:
                    out['type'] = 'float'
                elif stat['type'] == STAT_TYPE_AVGRATE:
                    out['type'] = 'avgrate'
                
                # Get default value
                default_val = 0
                if 'Default' in stat:
                    default_val = stat['Default']
                elif 'default' in stat:
                    default_val = stat['default']
                
                # Convert to appropriate type for JSON
                if out['type'] == 'int':
                    try:
                        default_val = int(default_val)
                    except (ValueError, TypeError):
                        try:
                            default_val = int(float(default_val))
                        except (ValueError, TypeError):
                            print(f"Warning: Cannot convert '{default_val}' to int for stat '{out['name']}'. Using 0.")
                            default_val = 0
                else:
                    try:
                        default_val = float(default_val)
                    except (ValueError, TypeError):
                        print(f"Warning: Cannot convert '{default_val}' to float for stat '{out['name']}'. Using 0.0.")
                        default_val = 0.0
                
                # GBE format uses string for default
                out['default'] = str(default_val)
                # GBE format includes global field (default to "0")
                out['global'] = "0"
                
                stats_out += [out]

    # Create output directory if needed
    if not os.path.exists(config_directory):
        os.makedirs(config_directory)

    # Write achievements.json
    # Update icon paths to use 'images/' prefix for GBE fork
    for ach in achievements_out:
        if "icon" in ach and not ach["icon"].startswith("images/"):
            ach["icon"] = "images/" + ach["icon"]
        if "icon_gray" in ach and not ach["icon_gray"].startswith("images/"):
            ach["icon_gray"] = "images/" + ach["icon_gray"]
        if "icongray" in ach and not ach["icongray"].startswith("images/"):
            ach["icongray"] = "images/" + ach["icongray"]

    output_ach = json.dumps(achievements_out, indent=4)
    with open(os.path.join(config_directory, "achievements.json"), 'w', encoding='utf-8') as f:
        f.write(output_ach)

    # Write stats.json (GBE format - array of objects)
    if stats_out:
        output_stats = json.dumps(stats_out, indent=2)
        with open(os.path.join(config_directory, "stats.json"), 'w', encoding='utf-8') as f:
            f.write(output_stats)
        print(f"Created stats.json with {len(stats_out)} stats")

    return (achievements_out, stats_out)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("format: {} UserGameStatsSchema_480.bin".format(sys.argv[0]))
        exit(0)

    with open(sys.argv[1], 'rb') as f:
        schema = f.read()

    generate_stats_achievements(schema, os.path.join("{}".format("{}_output".format(sys.argv[1])), "steam_settings"))