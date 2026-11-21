// Reads the CBA settings and compiles them into the FPSC_r_* globals used by the pipeline.
// Hybrid model:
//   server  : "server list" -> hideObjectGlobal (rate limited + capped), destruction protection, mission objects
//   clients : "local list" + cluster thinning + roadside removal -> hideObject (no network traffic)
// Runs on every machine each time the settings change.

private _on = FPSC_enabled;
FPSC_r_doProt = _on && isServer;
FPSC_r_budget = ((FPSC_budget max 1) / 1000);
FPSC_r_radius = FPSC_radius;
// network protection (server): max object changes per second and max globally hidden objects
FPSC_r_rate = if (isServer) then { FPSC_global_rate max 10 } else { 1000000000 };
FPSC_r_gmax = FPSC_global_max;

// ---- decor lists ----
private _readList = {
    private _a = call compile preprocessFileLineNumbers _this;
    if (isNil "_a" || {!(_a isEqualType [])}) then { _a = [] };
    _a joinString ","
};
private _srvText = FPSC_hide_list;
if (FPSC_hide_file) then { _srvText = _srvText + "," + (preprocessFile "userconfig\fpsc\hide_list.txt") };
if (FPSC_hide_builtin) then { _srvText = _srvText + "," + ("\z\fpsc\addons\fpsc_main\lists\server_default.sqf" call _readList) };
private _locText = FPSC_local_list;
if (FPSC_local_builtin) then { _locText = _locText + "," + ("\z\fpsc\addons\fpsc_main\lists\local_default.sqf" call _readList) };

FPSC_r_srv = [_srvText] call FPSC_fnc_parseRules;
FPSC_r_loc = [_locText] call FPSC_fnc_parseRules;
FPSC_r_vS = createHashMap; // model path -> bool caches
FPSC_r_vL = createHashMap;

private _srvKnown = ((count (FPSC_r_srv select 0)) > 0) || {(count (FPSC_r_srv select 1)) > 0};
private _locKnown = ((count (FPSC_r_loc select 0)) > 0) || {(count (FPSC_r_loc select 1)) > 0};
FPSC_r_srvOn = _on && isServer && FPSC_hide_enabled && _srvKnown;
FPSC_r_locOn = _on && hasInterface && FPSC_hide_enabled && _locKnown;
FPSC_r_missionOn = _on && isServer && FPSC_hide_mission && FPSC_hide_enabled && _srvKnown;

// ---- cluster thinning + roadside removal: local, every client for itself ----
FPSC_r_cCell = FPSC_cluster_cell max 5;
FPSC_r_cMin = FPSC_cluster_min max 2;
FPSC_r_cPct = FPSC_cluster_percent;
FPSC_r_cTypes = [FPSC_cluster_types] call FPSC_fnc_typePreset;
FPSC_r_clusterOn = _on && hasInterface && FPSC_cluster_enabled && (FPSC_r_cPct > 0);

FPSC_r_roadRange = FPSC_road_range;
FPSC_r_roadTypes = [FPSC_road_types] call FPSC_fnc_typePreset;
FPSC_r_roadTracks = FPSC_road_tracks;
FPSC_r_roadOn = _on && hasInterface && FPSC_road_enabled && (FPSC_r_roadRange > 0);

// ---- destruction protection (server): 1 vegetation | 2 all small objects | 3 small objects + buildings ----
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

FPSC_r_active = FPSC_r_srvOn || FPSC_r_locOn || FPSC_r_clusterOn || FPSC_r_roadOn
    || (count FPSC_r_protSmall > 0) || (count FPSC_r_protBld > 0);

if (FPSC_debug) then {
    diag_log format ["[FPSC] rules compiled: active=%1 serverList=%2 (exact=%3 contains=%4) localList=%5 (exact=%6 contains=%7) cluster=%8 road=%9 protect=%10/%11 chunk=%12 radius=%13",
        FPSC_r_active, FPSC_r_srvOn, count (FPSC_r_srv select 0), count (FPSC_r_srv select 1),
        FPSC_r_locOn, count (FPSC_r_loc select 0), count (FPSC_r_loc select 1),
        FPSC_r_clusterOn, FPSC_r_roadOn, count FPSC_r_protSmall, count FPSC_r_protBld, FPSC_r_chunk, FPSC_r_radius];
};
