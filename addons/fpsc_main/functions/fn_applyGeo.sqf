// Geometry budget: object + shadow render distance (client only). Cheap and idempotent,
// so it is re-asserted every few seconds (the player can change view distance in the menu).
if (!hasInterface) exitWith {};
if (FPSC_geo_enabled) then {
    if (isNil "FPSC_c_origGeo") then { FPSC_c_origGeo = getObjectViewDistance };
    private _target = [((FPSC_geo_obj min viewDistance) max 50), FPSC_geo_shadow];
    private _cur = getObjectViewDistance;
    if (((abs ((_cur select 0) - (_target select 0))) > 1) || {(abs ((_cur select 1) - (_target select 1))) > 1}) then {
        setObjectViewDistance _target;
    };
} else {
    if (!isNil "FPSC_c_origGeo") then {
        setObjectViewDistance FPSC_c_origGeo;
        FPSC_c_origGeo = nil;
    };
};
