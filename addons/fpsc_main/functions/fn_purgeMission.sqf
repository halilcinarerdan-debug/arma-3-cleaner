// Server only: deletes mission-placed / spawned static objects whose classname is on the decor
// list (optional setting) and keeps watching newly created ones.
if (!isNil "FPSC_s_ehEntity") then {
    removeMissionEventHandler ["EntityCreated", FPSC_s_ehEntity];
    FPSC_s_ehEntity = nil;
};
if (!isServer || {!FPSC_r_missionOn}) exitWith {};

private _n = 0;
{
    if ([_x] call FPSC_fnc_classMatch) then { deleteVehicle _x; _n = _n + 1 };
} forEach (allMissionObjects "");

FPSC_s_ehEntity = addMissionEventHandler ["EntityCreated", {
    params ["_entity"];
    if ([_entity] call FPSC_fnc_classMatch) then {
        [{ deleteVehicle _this }, _entity] call CBA_fnc_execNextFrame;
    };
}];
if (FPSC_debug) then { diag_log format ["[FPSC] mission objects deleted: %1", _n] };
