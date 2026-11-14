// Builds (once) a lookup  model path (lower case, no leading backslash)  ->  [[class, configRoot], ...]
// from CfgVehicles and CfgNonAIVehicles, so terrain objects can be mapped back to classnames.
// Must run in the scheduled environment (it loops over tens of thousands of classes).
if (!isNil "FPSC_c_modelMap") exitWith { FPSC_c_modelMap };
if (!isNil "FPSC_c_mapBusy") exitWith {
    waitUntil { !isNil "FPSC_c_modelMap" };
    FPSC_c_modelMap
};
FPSC_c_mapBusy = true;

private _map = createHashMap;
{
    private _root = _x;
    {
        private _m = getText (_x >> "model");
        if !(_m isEqualTo "") then {
            _m = [_m] call FPSC_fnc_normPath;
            if !((_m select [(count _m) - 4]) isEqualTo ".p3d") then { _m = _m + ".p3d" };
            private _l = _map getOrDefault [_m, []];
            if (count _l < 5) then {
                _l pushBack [configName _x, _root];
                _map set [_m, _l];
            };
        };
    } forEach ("isClass _x" configClasses (configFile >> _root));
} forEach ["CfgVehicles", "CfgNonAIVehicles"];

FPSC_c_modelMap = _map;
_map
