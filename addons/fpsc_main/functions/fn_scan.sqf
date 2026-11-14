// ============================================================================
//  CLASSNAME / MODEL DISCOVERY  (debug tool)
//  Lists the terrain objects around you (or the whole map) grouped by model, with the
//  classnames that use the model, the mod/addon they come from and how many there are.
//  Output goes to: RPT (lines starting with [FPSC][SCAN]), the clipboard and the chat.
//
//  Debug console (Local Exec):
//     [300, "jbad,cup"] spawn FPSC_fnc_scan;   // 300 m around you, only JBAD / CUP stuff
//     [0, "jbad"] spawn FPSC_fnc_scan;         // whole map (slow)
//     [500, "", 400] spawn FPSC_fnc_scan;      // 500 m, everything, 400 rows
//  Params: [radius (0 = whole map), filter (comma separated, matches path/classname/mod), max rows]
//  Afterwards:  copyToClipboard FPSC_lastScanList   // comma separated, ready for the decor list
// ============================================================================
if (!canSuspend) exitWith {
    private _args = if (isNil "_this") then { [] } else { _this };
    _args spawn FPSC_fnc_scan;
};
params [["_radius", 300, [0]], ["_filter", "", [""]], ["_maxRows", 250, [0]]];

private _whole = _radius <= 0;
private _center = if (!isNil "player" && {!isNull player}) then { getPosATL player } else { [worldSize / 2, worldSize / 2, 0] };
if (_whole) then { _center = [worldSize / 2, worldSize / 2, 0]; _radius = worldSize };

private _step = 500;
private _maxIdx = floor (worldSize / _step);
private _cx0 = (floor (((_center select 0) - _radius) / _step)) max 0;
private _cx1 = (floor (((_center select 0) + _radius) / _step)) min _maxIdx;
private _cy0 = (floor (((_center select 1) - _radius) / _step)) max 0;
private _cy1 = (floor (((_center select 1) + _radius) / _step)) min _maxIdx;
private _total = (_cx1 - _cx0 + 1) * (_cy1 - _cy0 + 1);

private _groups = createHashMap;
private _objects = 0;
private _done = 0;
diag_log format ["[FPSC][SCAN] started: radius=%1 filter='%2' chunks=%3", if (_whole) then {"whole map"} else {_radius}, _filter, _total];

for "_i" from _cx0 to _cx1 do {
    for "_j" from _cy0 to _cy1 do {
        private _objs = [FPSC_allTypes, _i * _step, _j * _step, _step] call FPSC_fnc_chunkObjects;
        {
            if (_whole || {(_x distance2D _center) <= _radius}) then {
                private _mi = getModelInfo _x;
                private _path = toLower (_mi select 1);
                if !(_path isEqualTo "") then {
                    private _g = _groups getOrDefault [_path, []];
                    if (count _g == 0) then {
                        _g = [0, toLower (_mi select 0), _path, typeOf _x];
                        _groups set [_path, _g];
                    };
                    _g set [0, (_g select 0) + 1];
                    _objects = _objects + 1;
                };
            };
        } forEach _objs;
        _done = _done + 1;
        if (hasInterface && {(_done mod 20) == 0}) then {
            hintSilent format ["FPS Cleaner scan: %1 / %2 chunks, %3 objects", _done, _total, _objects];
        };
    };
};

// ---- turn groups into rows ----
private _map = call FPSC_fnc_modelMap;
private _filters = ([toLower _filter] call FPSC_fnc_parseList);
private _rows = [];
{
    private _g = _x;
    private _path = _g select 2;
    private _clean = if ((_path select [0, 1]) isEqualTo FPSC_bs) then { _path select [1] } else { _path };
    private _known = _map getOrDefault [_clean, []];
    private _classes = _known apply { _x select 0 };
    private _typeOf = _g select 3;
    if (!(_typeOf isEqualTo "") && {!((toLower _typeOf) in (_classes apply { toLower _x }))}) then { _classes = [_typeOf] + _classes };

    private _mod = "";
    if (count _known > 0) then {
        private _cfg = configFile >> ((_known select 0) select 1) >> ((_known select 0) select 0);
        _mod = configSourceMod _cfg;
        if (_mod isEqualTo "") then { _mod = (configSourceAddonList _cfg) param [0, ""] };
    };
    private _prefix = (_clean splitString FPSC_bs) param [0, ""];
    if (_mod isEqualTo "") then { _mod = _prefix };

    private _haystack = toLower (_clean + " " + (_classes joinString " ") + " " + _mod);
    if ((count _filters == 0) || {(_filters findIf { (_haystack find _x) >= 0 }) >= 0}) then {
        private _hit = if (isNil "FPSC_r_exact") then { false } else { [_clean, toLower (_g select 1)] call FPSC_fnc_modelVerdict };
        _rows pushBack [_g select 0, _g select 1, _classes joinString "|", _mod, _clean, _prefix, _hit];
    };
} forEach (values _groups);

// sort by object count, descending
private _order = [];
{ _order pushBack [_x select 0, _forEachIndex] } forEach _rows;
_order sort false;

// summary per top-level folder (= PBO prefix, e.g. a3 / cup / jbad)
private _byPrefix = createHashMap;
{
    private _p = _x select 5;
    private _e = _byPrefix getOrDefault [_p, [0, 0]];
    _e set [0, (_e select 0) + 1];
    _e set [1, (_e select 1) + (_x select 0)];
    _byPrefix set [_p, _e];
} forEach _rows;
private _prefixLines = [];
{ _prefixLines pushBack [(_byPrefix get _x) select 1, format ["  %1: %2 models, %3 objects", _x, (_byPrefix get _x) select 0, (_byPrefix get _x) select 1]] } forEach (keys _byPrefix);
_prefixLines sort false;

private _lines = [];
_lines pushBack format ["[FPSC][SCAN] ===== %1 objects, %2 unique models (filter '%3') =====", _objects, count _rows, _filter];
_lines pushBack "[FPSC][SCAN] -- by folder / pbo prefix --";
{ _lines pushBack ("[FPSC][SCAN] " + (_x select 1)) } forEach _prefixLines;
_lines pushBack "[FPSC][SCAN] -- rows: count | model file | classnames | mod/addon | path | [HIDE = already matched by decor list] --";
private _list = [];
{
    private _r = _rows select (_x select 1);
    if (_forEachIndex < _maxRows) then {
        _lines pushBack format ["[FPSC][SCAN] %1 | %2 | %3 | %4 | %5%6", _r select 0, _r select 1, _r select 2, _r select 3, _r select 4, if (_r select 6) then {" | HIDE"} else {""}];
    };
    private _cn = (_r select 2) splitString "|";
    private _entry = if (count _cn > 0) then { _cn select 0 } else { _r select 1 };
    _list pushBack _entry;
} forEach _order;
_lines pushBack "[FPSC][SCAN] ===== end =====";

FPSC_lastScanList = _list joinString ",";
FPSC_lastScanReport = _lines joinString endl;
{ diag_log _x } forEach _lines;
diag_log ("[FPSC][SCAN] LIST: " + FPSC_lastScanList);
if (hasInterface) then {
    copyToClipboard FPSC_lastScanReport;
    hintSilent "";
    systemChat format ["[FPS Cleaner] scan finished: %1 objects, %2 models. Report copied to clipboard + RPT. Decor list: copyToClipboard FPSC_lastScanList", _objects, count _rows];
};
FPSC_lastScanReport
