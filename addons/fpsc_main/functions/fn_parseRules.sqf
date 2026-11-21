// Turns a decor list text into a rule set.
// Entry syntax (separators: comma, semicolon, space, tab, newline):
//   classname / model file / model path   exact match            jbad_barrel_01   bush_b.p3d
//   entry containing *                    "contains" match       jbad_*   *bottle*   (/ and \ are the same)
//   !entry                                exception, never hidden
// Params: [text]
// Returns: [exact (hashmap), contains (array), classes (hashmap), keepExact (hashmap), keepContains (array), keepClasses (hashmap)]
params [["_text", "", [""]]];
private _exactH = createHashMap;
private _contains = [];
private _classes = createHashMap;
private _kExact = createHashMap;
private _kContains = [];
private _kClass = createHashMap;

{
    private _tok = _x;
    private _keep = false;
    if ((_tok select [0, 1]) isEqualTo "!") then { _keep = true; _tok = _tok select [1] };
    private _wild = (_tok find "*") >= 0;
    if (_wild) then { _tok = (_tok splitString "*") joinString "" };
    _tok = [_tok] call FPSC_fnc_normPath;

    if !(_tok isEqualTo "") then {
        if (_wild) then {
            if (_keep) then { _kContains pushBack _tok } else { _contains pushBack _tok };
        } else {
            private _exact = if (_keep) then { _kExact } else { _exactH };
            private _cls = if (_keep) then { _kClass } else { _classes };
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
                        if !(_m isEqualTo "") then {
                            if !((_m select [(count _m) - 4]) isEqualTo ".p3d") then { _m = _m + ".p3d" };
                            _exact set [_m, true];
                        };
                    };
                } forEach ["CfgVehicles", "CfgNonAIVehicles"];
            };
        };
    };
} forEach ([_text] call FPSC_fnc_parseList);

[_exactH, _contains, _classes, _kExact, _kContains, _kClass]
