// Reads the CBA settings and compiles them into the FPSC_r_* globals used by the pipeline.
// Runs on the server and (in local mode) on clients, every time the settings change.

private _on = FPSC_enabled;
private _modeLocal = (FPSC_hide_mode == 1);

FPSC_r_doHide = _on && {(isServer && {!_modeLocal}) || {hasInterface && {_modeLocal}}};
FPSC_r_global = isServer && {!_modeLocal};
FPSC_r_doProt = _on && isServer;
FPSC_r_budget = ((FPSC_budget max 1) / 1000);
FPSC_r_radius = FPSC_radius;

// ---- decor list ----
FPSC_r_exact = createHashMap;     // model paths / file names (lower case)
FPSC_r_contains = [];             // substring patterns (from entries with *)
FPSC_r_classes = createHashMap;   // plain tokens, used for classname matching of mission objects
FPSC_r_kExact = createHashMap;    // "!" exclusions
FPSC_r_kContains = [];
FPSC_r_kClass = createHashMap;
FPSC_r_verdict = createHashMap;   // model path -> bool cache

private _text = FPSC_hide_list;
if (FPSC_hide_file) then {
    _text = _text + "," + (preprocessFile "userconfig\fpsc\hide_list.txt");
};

{
    private _tok = _x;
    private _keep = false;
    if ((_tok select [0, 1]) isEqualTo "!") then { _keep = true; _tok = _tok select [1] };
    private _wild = (_tok find "*") >= 0;
    if (_wild) then { _tok = (_tok splitString "*") joinString "" };
    _tok = [_tok] call FPSC_fnc_normPath;

    if (!(_tok isEqualTo "")) then {
        if (_wild) then {
            if (_keep) then { FPSC_r_kContains pushBack _tok } else { FPSC_r_contains pushBack _tok };
        } else {
            private _exact = if (_keep) then { FPSC_r_kExact } else { FPSC_r_exact };
            private _cls = if (_keep) then { FPSC_r_kClass } else { FPSC_r_classes };
            private _hasExt = (count _tok > 4) && {(_tok select [count _tok - 4]) isEqualTo ".p3d"};
            if (_hasExt) then {
                _exact set [_tok, true];
            } else {
                _exact set [_tok, true];
                _exact set [_tok + ".p3d", true];
                _cls set [_tok, true];
                // classname -> its model, so terrain objects using that model are caught too
                {
                    private _cfg = configFile >> _x >> _tok;
                    if (isClass _cfg) then {
                        private _m = [getText (_cfg >> "model")] call FPSC_fnc_normPath;
                        if (!(_m isEqualTo "")) then {
                            if !((_m select [count _m - 4]) isEqualTo ".p3d") then { _m = _m + ".p3d" };
                            _exact set [_m, true];
                        };
                    };
                } forEach ["CfgVehicles", "CfgNonAIVehicles"];
            };
        };
    };
} forEach ([_text] call FPSC_fnc_parseList);

// ---- rules ----
private _hideKnown = (count FPSC_r_exact > 0) || {count FPSC_r_contains > 0};
FPSC_r_hideOn = FPSC_r_doHide && FPSC_hide_enabled && _hideKnown;
FPSC_r_missionOn = _on && isServer && FPSC_hide_mission && FPSC_hide_enabled && _hideKnown;

FPSC_r_cCell = FPSC_cluster_cell max 5;
FPSC_r_cMin = FPSC_cluster_min max 2;
FPSC_r_cPct = FPSC_cluster_percent;
FPSC_r_cTypes = [FPSC_cluster_types] call FPSC_fnc_typePreset;
FPSC_r_clusterOn = FPSC_r_doHide && FPSC_cluster_enabled && (FPSC_r_cPct > 0);

FPSC_r_roadRange = FPSC_road_range;
FPSC_r_roadTypes = [FPSC_road_types] call FPSC_fnc_typePreset;
FPSC_r_roadTracks = FPSC_road_tracks;
FPSC_r_roadOn = FPSC_r_doHide && FPSC_road_enabled && (FPSC_r_roadRange > 0);

// Destruction protection: 1 vegetation | 2 all small objects | 3 small objects + buildings
FPSC_r_protSmall = [];
FPSC_r_protBld = [];
if (FPSC_r_doProt) then {
    switch (FPSC_prot_mode) do {
        case 1: { FPSC_r_protSmall = ["BUSH", "SMALL TREE", "TREE"] };
        case 2: { FPSC_r_protSmall = +FPSC_smallTypes };
        case 3: { FPSC_r_protSmall = +FPSC_smallTypes; FPSC_r_protBld = +FPSC_bldTypes };
        default {};
    };
};
FPSC_r_freeze = FPSC_prot_freeze;

// chunk edge = multiple of the cluster cell, so cells never straddle chunks
FPSC_r_chunk = FPSC_r_cCell * (ceil (250 / FPSC_r_cCell));

FPSC_r_active = FPSC_r_hideOn || FPSC_r_clusterOn || FPSC_r_roadOn
    || (count FPSC_r_protSmall > 0) || (count FPSC_r_protBld > 0);

if (FPSC_debug) then {
    diag_log format ["[FPSC] rules compiled: active=%1 hide=%2 (exact=%3 contains=%4) cluster=%5 road=%6 protect=%7/%8 global=%9 chunk=%10 radius=%11",
        FPSC_r_active, FPSC_r_hideOn, count FPSC_r_exact, count FPSC_r_contains, FPSC_r_clusterOn,
        FPSC_r_roadOn, count FPSC_r_protSmall, count FPSC_r_protBld, FPSC_r_global, FPSC_r_chunk, FPSC_r_radius];
};
