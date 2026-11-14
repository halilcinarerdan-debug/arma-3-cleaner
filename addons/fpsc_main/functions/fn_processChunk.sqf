// Applies every active rule to one square chunk of the map.
// Params: [chunkX, chunkY]
params ["_cx", "_cy"];
private _size = FPSC_r_chunk;
private _x0 = _cx * _size;
private _y0 = _cy * _size;
private _hide = [];

// 1) decor list (classname / model matching)
if (FPSC_r_hideOn) then {
    {
        private _mi = getModelInfo _x;
        private _path = toLower (_mi select 1);
        if !(_path isEqualTo "") then {
            private _v = FPSC_r_verdict getOrDefault [_path, -1];
            if (_v isEqualTo -1) then {
                _v = [_path, toLower (_mi select 0)] call FPSC_fnc_modelVerdict;
                FPSC_r_verdict set [_path, _v];
            };
            if (_v isEqualTo true) then { _hide pushBack _x };
        };
    } forEach ([FPSC_allTypes, _x0, _y0, _size] call FPSC_fnc_chunkObjects);
};

// 2) cluster thinning
if (FPSC_r_clusterOn) then {
    _hide append ([[FPSC_r_cTypes, _x0, _y0, _size] call FPSC_fnc_chunkObjects] call FPSC_fnc_clusterPick);
};

// 3) roadside removal
if (FPSC_r_roadOn) then {
    private _range = FPSC_r_roadRange;
    private _ctr = [_x0 + _size * 0.5, _y0 + _size * 0.5, 0];
    if (count (_ctr nearRoads (_size * 0.7072 + _range + 1)) > 0) then {
        {
            private _near = (getPosATL _x) nearRoads _range;
            if (count _near > 0) then {
                if (FPSC_r_roadTracks || {(_near findIf { ((getRoadInfo _x) select 0) in ["ROAD", "MAIN ROAD"] }) >= 0}) then {
                    _hide pushBack _x;
                };
            };
        } forEach ([FPSC_r_roadTypes, _x0, _y0, _size] call FPSC_fnc_chunkObjects);
    };
};

if (count _hide > 0) then {
    _hide = _hide arrayIntersect _hide; // unique
    if (FPSC_r_global) then {
        { _x hideObjectGlobal true } forEach _hide;
    } else {
        { _x hideObject true } forEach _hide;
    };
    FPSC_s_hidden append _hide;
};

// 4) destruction / simulation protection (server only)
if (count FPSC_r_protSmall > 0) then {
    private _small = [FPSC_r_protSmall, _x0, _y0, _size] call FPSC_fnc_chunkObjects;
    { _x allowDamage false } forEach _small;
    FPSC_s_prot append _small;
    if (FPSC_r_freeze) then {
        { _x enableSimulationGlobal false } forEach _small;
        FPSC_s_frozen append _small;
    };
};
if (count FPSC_r_protBld > 0) then {
    private _bld = [FPSC_r_protBld, _x0, _y0, _size] call FPSC_fnc_chunkObjects;
    { _x allowDamage false } forEach _bld;
    FPSC_s_prot append _bld;
};
