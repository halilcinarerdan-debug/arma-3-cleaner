// Terrain objects of the given types whose position lies inside one square chunk.
// inAreaArray is native, a scripted select would cost ~1 ms per 1000 objects.
// Params: [types, x0, y0, size]   Returns: array of objects
params ["_types", "_x0", "_y0", "_size"];
private _h = _size * 0.5;
private _ctr = [_x0 + _h, _y0 + _h, 0];
(nearestTerrainObjects [_ctr, _types, _size * 0.7072 + 1, false, true]) inAreaArray [_ctr, _h, _h, 0, true]
