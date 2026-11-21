// Should a terrain model be hidden according to a rule set (see FPSC_fnc_parseRules)?
// Params: [pathLower, fileLower, rules]   Returns: bool
params ["_path", "_file", "_rules"];
if ((_path select [0, 1]) isEqualTo FPSC_bs) then { _path = _path select [1] };
private _kExact = _rules select 3;
if ((_kExact getOrDefault [_path, false]) || {_kExact getOrDefault [_file, false]}) exitWith { false };
if (((_rules select 4) findIf { (_path find _x) >= 0 }) >= 0) exitWith { false };
private _exact = _rules select 0;
if ((_exact getOrDefault [_path, false]) || {_exact getOrDefault [_file, false]}) exitWith { true };
((_rules select 1) findIf { (_path find _x) >= 0 }) >= 0
