// Does a (mission-placed / spawned) static object match the server decor list by classname?
// Params: [object]   Returns: bool
params ["_obj"];
if !((_obj isKindOf "Static") || {_obj isKindOf "Thing"}) exitWith { false };
private _c = toLower typeOf _obj;
if (_c isEqualTo "") exitWith { false };
if ((FPSC_r_srv select 5) getOrDefault [_c, false]) exitWith { false };
if ((FPSC_r_srv select 2) getOrDefault [_c, false]) exitWith { true };
((FPSC_r_srv select 1) findIf { (_c find _x) >= 0 }) >= 0
