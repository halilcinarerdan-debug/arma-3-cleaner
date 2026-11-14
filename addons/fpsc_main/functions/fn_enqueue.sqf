// Adds the chunks around every relevant player to the work queue (nearest first).
private _players = if (isServer) then {
    allPlayers select { !(_x isKindOf "HeadlessClient_F") }
} else {
    [player]
};
_players = _players select { !isNull _x };

private _size = FPSC_r_chunk;
private _maxIdx = floor (worldSize / _size);
private _R = FPSC_r_radius;
private _new = [];

if (_R <= 0) then {
    if (!FPSC_s_allQueued) then {
        FPSC_s_allQueued = true;
        for "_i" from 0 to _maxIdx do {
            for "_j" from 0 to _maxIdx do { _new pushBack [0, _i, _j] };
        };
    };
} else {
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
                if !(FPSC_s_seen getOrDefault [_key, false]) then {
                    private _dx = ((_i + 0.5) * _size) - _px;
                    private _dy = ((_j + 0.5) * _size) - _py;
                    private _d = sqrt ((_dx * _dx) + (_dy * _dy));
                    if (_d < (_R + (_size * 0.71))) then {
                        FPSC_s_seen set [_key, true];
                        _new pushBack [_d, _i, _j];
                    };
                };
            };
        };
    } forEach _players;
};

_new sort true;
{ FPSC_s_queue pushBack [_x select 1, _x select 2] } forEach _new;
