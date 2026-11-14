// Cluster thinning. Splits the given objects into grid cells (FPSC_r_cCell metres, aligned with
// the chunk grid). Cells holding >= FPSC_r_cMin objects are "clusters"; in each cluster
// FPSC_r_cPct percent of the objects are selected for removal (100 = whole cluster).
// Selection is deterministic (position hash), so every restart gives the same result.
// Params: [objects]   Returns: array of objects to remove
params ["_pool"];
private _remove = [];
if (count _pool < FPSC_r_cMin) exitWith { _remove };
private _cell = FPSC_r_cCell;
private _cells = createHashMap;
{
    private _p = getPosATL _x;
    private _k = (floor ((_p select 0) / _cell)) * 10000 + (floor ((_p select 1) / _cell));
    private _l = _cells getOrDefault [_k, []];
    _l pushBack _x;
    _cells set [_k, _l];
} forEach _pool;

{
    private _l = _x;
    private _n = count _l;
    if (_n >= FPSC_r_cMin) then {
        private _rm = round (_n * FPSC_r_cPct / 100);
        if (_rm > 0) then {
            private _ranked = [];
            {
                private _p = getPosATL _x;
                private _h = (abs (sin ((_p select 0) * 12.9898 + (_p select 1) * 78.233))) * 43758.5453;
                _ranked pushBack [(_h - (floor _h)) + (_forEachIndex * 0.0000001), _forEachIndex];
            } forEach _l;
            _ranked sort true;
            for "_i" from (_n - _rm) to (_n - 1) do {
                _remove pushBack (_l select ((_ranked select _i) select 1));
            };
        };
    };
} forEach (values _cells);
_remove
