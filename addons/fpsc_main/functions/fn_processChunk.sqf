// Applies every active rule to one square chunk of the map. Nothing is hidden/protected here directly:
// the objects are queued as jobs and FPSC_fnc_jobStep works through them within the frame budget.
// Params: [chunkX, chunkY]
params ["_cx", "_cy"];
private _size = FPSC_r_chunk;
private _x0 = _cx * _size;
private _y0 = _cy * _size;
private _hide = [];

// 1) decor lists (classname / model matching): server list (global) and/or local list
private _srv = FPSC_r_srvOn && {!FPSC_s_capped};
if (_srv || FPSC_r_locOn) then {
    private _all = [FPSC_allTypes, _x0, _y0, _size] call FPSC_fnc_chunkObjects;
    if (_srv) then { FPSC_s_jobs pushBack [_all, 0, 0] };
    if (FPSC_r_locOn) then { FPSC_s_jobs pushBack [_all, 0, 1] };
};

// 2) cluster thinning (local)
if (FPSC_r_clusterOn) then {
    _hide append ([[FPSC_r_cTypes, _x0, _y0, _size] call FPSC_fnc_chunkObjects] call FPSC_fnc_clusterPick);
};

// 3) roadside removal (local)
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
    FPSC_s_jobs pushBack [_hide arrayIntersect _hide, 0, 2]; // unique, already decided, hidden locally
};

// 4) destruction / simulation protection (server only)
if (count FPSC_r_protSmall > 0) then {
    FPSC_s_pjobs pushBack [[FPSC_r_protSmall, _x0, _y0, _size] call FPSC_fnc_chunkObjects, 0, FPSC_r_freeze];
};
if (count FPSC_r_protBld > 0) then {
    FPSC_s_pjobs pushBack [[FPSC_r_protBld, _x0, _y0, _size] call FPSC_fnc_chunkObjects, 0, false];
};
