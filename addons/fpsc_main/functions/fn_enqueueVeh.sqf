// Roadside clearing "only near vehicles": queues the chunks around every crewed land vehicle
// (AI or player) into the priority queue FPSC_s_vq (kind 1 = roadside pass only).
// This is what keeps AI-driven vehicles from getting stuck on trees / fences / walls next to the road.
private _size = FPSC_r_chunk;
private _maxIdx = floor (worldSize / _size);
private _R = FPSC_road_vehRadius;
private _veh = vehicles select { (_x isKindOf "LandVehicle") && {alive _x && {((crew _x) findIf { alive _x }) >= 0}} };
private _new = [];
{
    private _p = getPosATL _x;
    private _px = _p select 0;
    private _py = _p select 1;
    private _cxMin = (floor ((_px - _R) / _size)) max 0;
    private _cxMax = (floor ((_px + _R) / _size)) min _maxIdx;
    private _cyMin = (floor ((_py - _R) / _size)) max 0;
    private _cyMax = (floor ((_py + _R) / _size)) min _maxIdx;
    for "_i" from _cxMin to _cxMax do {
        for "_j" from _cyMin to _cyMax do {
            private _key = _i * 1000 + _j;
            if !(FPSC_s_seenRoad getOrDefault [_key, false]) then {
                private _dx = ((_i + 0.5) * _size) - _px;
                private _dy = ((_j + 0.5) * _size) - _py;
                private _d = sqrt ((_dx * _dx) + (_dy * _dy));
                if (_d < (_R + (_size * 0.71))) then {
                    FPSC_s_seenRoad set [_key, true];
                    _new pushBack [_d, _i, _j];
                };
            };
        };
    };
} forEach _veh;
_new sort true;
{ FPSC_s_vq pushBack [_x select 1, _x select 2, 1] } forEach _new;
