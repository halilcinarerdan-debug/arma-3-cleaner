// Terrain objects of the given types whose position lies inside one square chunk.
// Params: [types, x0, y0, size]   Returns: array of objects
params ["_types", "_x0", "_y0", "_size"];
private _x1 = _x0 + _size;
private _y1 = _y0 + _size;
private _ctr = [_x0 + _size * 0.5, _y0 + _size * 0.5, 0];
(nearestTerrainObjects [_ctr, _types, _size * 0.7072 + 1, false, true]) select {
    private _p = getPosATL _x;
    ((_p select 0) >= _x0) && {((_p select 0) < _x1) && {((_p select 1) >= _y0) && {(_p select 1) < _y1}}}
}
