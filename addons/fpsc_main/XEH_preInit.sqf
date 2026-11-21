// FPS Cleaner - preInit (runs on every machine)
// Registers constants, CBA settings and keybinds. The real work starts in FPSC_fnc_start
// once CBA has initialised its settings.

FPSC_ready = false;
FPSC_dirty = false;
FPSC_dirtyAt = 0;
FPSC_bs = toString [92]; // single backslash, built at runtime on purpose (keeps packers happy)

// Every nearestTerrainObjects type except roads/rails (those are never "decor")
FPSC_allTypes = [
    "TREE", "SMALL TREE", "BUSH", "BUILDING", "HOUSE", "FOREST BORDER", "FOREST TRIANGLE",
    "FOREST SQUARE", "CHURCH", "CHAPEL", "CROSS", "BUNKER", "FORTRESS", "FOUNTAIN", "VIEW-TOWER",
    "LIGHTHOUSE", "QUAY", "FUELSTATION", "HOSPITAL", "FENCE", "WALL", "HIDE", "BUSSTOP", "FOREST",
    "TRANSMITTER", "STACK", "RUIN", "TOURISM", "WATERTOWER", "ROCK", "ROCKS", "POWER LINES",
    "POWERSOLAR", "POWERWAVE", "POWERWIND", "SHIPWRECK"
];
// Small, non-building terrain objects
FPSC_smallTypes = ["BUSH", "SMALL TREE", "TREE", "ROCK", "ROCKS", "FENCE", "WALL", "HIDE"];
// Buildings and other big structures (used by the destruction protection)
FPSC_bldTypes = [
    "BUILDING", "HOUSE", "CHURCH", "CHAPEL", "CROSS", "BUNKER", "FORTRESS", "FOUNTAIN", "VIEW-TOWER",
    "LIGHTHOUSE", "FUELSTATION", "HOSPITAL", "BUSSTOP", "TRANSMITTER", "STACK", "TOURISM",
    "WATERTOWER", "POWER LINES", "POWERSOLAR", "POWERWAVE", "POWERWIND"
];

private _cat = {
    [localize "STR_FPSC_cat", localize format ["STR_FPSC_sub_%1", _this]]
};

// [setting, type, stringtable key, category key, valueInfo, isGlobal]
private _add = {
    params ["_name", "_type", "_key", "_sub", "_value", "_global"];
    [
        _name, _type,
        [localize format ["STR_FPSC_%1", _key], localize format ["STR_FPSC_%1_tip", _key]],
        _sub call _cat, _value, _global,
        { call FPSC_fnc_onSettingChanged }
    ] call CBA_fnc_addSetting;
};

private _lbl = { _this apply { localize format ["STR_FPSC_%1", _x] } };

// ---- 1. General (server settings, shared with all clients) ----
["FPSC_enabled", "CHECKBOX", "enabled", "1", true, 1] call _add;
["FPSC_radius", "SLIDER", "radius", "1", [0, 10000, 2500, 0], 1] call _add;
["FPSC_budget", "SLIDER", "budget", "1", [1, 20, 4, 0], 1] call _add;
["FPSC_global_rate", "SLIDER", "global_rate", "1", [20, 2000, 200, 0], 1] call _add;
["FPSC_global_max", "SLIDER", "global_max", "1", [1000, 200000, 50000, 0], 1] call _add;
["FPSC_debug", "CHECKBOX", "debug", "1", false, 1] call _add;

// ---- 2. Decor objects ----
["FPSC_hide_enabled", "CHECKBOX", "hide_enabled", "2", true, 1] call _add;
["FPSC_hide_builtin", "CHECKBOX", "hide_builtin", "2", true, 1] call _add;
["FPSC_hide_list", "EDITBOX", "hide_list", "2", "", 1] call _add;
["FPSC_hide_file", "CHECKBOX", "hide_file", "2", false, 1] call _add;
["FPSC_hide_mission", "CHECKBOX", "hide_mission", "2", false, 1] call _add;
["FPSC_local_builtin", "CHECKBOX", "local_builtin", "2", true, 1] call _add;
["FPSC_local_list", "EDITBOX", "local_list", "2", "", 1] call _add;

// ---- 3. Clusters ----
private _presetLabels = ["preset_0", "preset_1", "preset_2", "preset_3", "preset_4"] call _lbl;
["FPSC_cluster_enabled", "CHECKBOX", "cluster_enabled", "3", false, 1] call _add;
["FPSC_cluster_percent", "SLIDER", "cluster_percent", "3", [0, 100, 50, 0], 1] call _add;
["FPSC_cluster_types", "LIST", "cluster_types", "3", [[0, 1, 2, 3, 4], _presetLabels, 1], 1] call _add;
["FPSC_cluster_cell", "SLIDER", "cluster_cell", "3", [10, 100, 30, 0], 1] call _add;
["FPSC_cluster_min", "SLIDER", "cluster_min", "3", [2, 60, 6, 0], 1] call _add;

// ---- 4. Roadside ----
["FPSC_road_enabled", "CHECKBOX", "road_enabled", "4", false, 1] call _add;
["FPSC_road_range", "SLIDER", "road_range", "4", [0, 60, 10, 0], 1] call _add;
["FPSC_road_types", "LIST", "road_types", "4", [[0, 1, 2, 3, 4], _presetLabels, 2], 1] call _add;
["FPSC_road_tracks", "CHECKBOX", "road_tracks", "4", false, 1] call _add;

// ---- 5. Destruction / simulation ----
["FPSC_prot_mode", "LIST", "prot_mode", "5",
    [[0, 1, 2, 3], ["prot_0", "prot_1", "prot_2", "prot_3"] call _lbl, 0], 1] call _add;
["FPSC_prot_freeze", "CHECKBOX", "prot_freeze", "5", false, 1] call _add;

// ---- 6. Terrain (per client) ----
["FPSC_terrain_grid", "LIST", "terrain_grid", "6",
    [[-1, 50, 25, 12.5, 6.25, 3.125], ["grid_keep", "grid_50", "grid_25", "grid_125", "grid_625", "grid_3125"] call _lbl, 0], 0] call _add;
["FPSC_env_life", "CHECKBOX", "env_life", "6", false, 0] call _add;
["FPSC_env_sound", "CHECKBOX", "env_sound", "6", false, 0] call _add;

// ---- 7. Geometry (per client) ----
["FPSC_geo_enabled", "CHECKBOX", "geo_enabled", "7", false, 0] call _add;
["FPSC_geo_obj", "SLIDER", "geo_obj", "7", [100, 12000, 1500, 0], 0] call _add;
["FPSC_geo_shadow", "SLIDER", "geo_shadow", "7", [0, 500, 80, 0], 0] call _add;

// ---- Keybinds (clients only) ----
if (hasInterface) then {
    [localize "STR_FPSC_cat", "FPSC_key_inspect", localize "STR_FPSC_key_inspect",
        { [] spawn FPSC_fnc_inspect; true }, {}, [23, [true, true, false]]] call CBA_fnc_addKeybind; // Ctrl+Shift+I
    [localize "STR_FPSC_cat", "FPSC_key_scan", localize "STR_FPSC_key_scan",
        { [300, "", 250] spawn FPSC_fnc_scan; true }, {}, [24, [true, true, false]]] call CBA_fnc_addKeybind; // Ctrl+Shift+O
};

["CBA_settingsInitialized", { call FPSC_fnc_start }] call CBA_fnc_addEventHandler;
