// Applies every active rule to one square chunk of the map. Nothing is hidden/protected here directly:
// the objects are queued as jobs and FPSC_fnc_jobStep works through them within the frame budget.
// Params: [chunkX, chunkY]
params ["_cx", "_cy"];
private _size = FPSC_r_chunk;
private _x0 = _cx * _size;
private _y0 = _cy * _size;
private _hide = [];
private _skipHide = FPSC_r_global && {FPSC_s_capped};

// 1) decor list (classname / model matching)
if (FPSC_r_hideOn && {!_skipHide}) then {
    FPSC_s_jobs pushBack [[FPSC_allTypes, _x0, _y0, _size] call FPSC_fnc_chunkObjects, 0, false];
};

// 2) cluster thinning
if (FPSC_r_clusterOn && {!_skipHide}) then {
    _hide append ([[FPSC_r_cTypes, _x0, _y0, _size] call FPSC_fnc_chunkObjects] call FPSC_fnc_clusterPick);
};

// 3) roadside removal
if (FPSC_r_roadOn && {!_skipHide}) then {
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
    FPSC_s_jobs pushBack [_hide arrayIntersect _hide, 0, true]; // unique, already decided
};

// 4) destruction / simulation protection (server only)
if (count FPSC_r_protSmall > 0) then {
    FPSC_s_pjobs pushBack [[FPSC_r_protSmall, _x0, _y0, _size] call FPSC_fnc_chunkObjects, 0, FPSC_r_freeze];
};
if (count FPSC_r_protBld > 0) then {
    FPSC_s_pjobs pushBack [[FPSC_r_protBld, _x0, _y0, _size] call FPSC_fnc_chunkObjects, 0, false];
};
