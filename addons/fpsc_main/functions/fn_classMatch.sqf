// Does a (mission-placed / spawned) static object match the decor list by classname?
// Params: [object]   Returns: bool
params ["_obj"];
if !((_obj isKindOf "Static") || {_obj isKindOf "Thing"}) exitWith { false };
private _c = toLower typeOf _obj;
if (_c isEqualTo "") exitWith { false };
if (FPSC_r_kClass getOrDefault [_c, false]) exitWith { false };
if (FPSC_r_classes getOrDefault [_c, false]) exitWith { true };
(FPSC_r_contains findIf { (_c find _x) >= 0 }) >= 0
