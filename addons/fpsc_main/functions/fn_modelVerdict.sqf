// Should a terrain model be hidden according to the decor list?
// Params: [pathLower, fileLower]   Returns: bool
params ["_path", "_file"];
if ((_path select [0, 1]) isEqualTo FPSC_bs) then { _path = _path select [1] };
if ((FPSC_r_kExact getOrDefault [_path, false]) || {FPSC_r_kExact getOrDefault [_file, false]}) exitWith { false };
if ((FPSC_r_kContains findIf { (_path find _x) >= 0 }) >= 0) exitWith { false };
if ((FPSC_r_exact getOrDefault [_path, false]) || {FPSC_r_exact getOrDefault [_file, false]}) exitWith { true };
(FPSC_r_contains findIf { (_path find _x) >= 0 }) >= 0
