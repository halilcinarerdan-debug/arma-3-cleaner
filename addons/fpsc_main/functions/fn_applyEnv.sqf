// Ambient life / sound, terrain grid and geometry (runs once per settings change).
private _off = FPSC_env_life || FPSC_env_sound;
if (_off || {FPSC_c_envApplied}) then {
    enableEnvironment [!FPSC_env_life, !FPSC_env_sound];
    FPSC_c_envApplied = _off;
};
if (!hasInterface) exitWith {};
if (FPSC_terrain_grid > 0) then { setTerrainGrid FPSC_terrain_grid };
call FPSC_fnc_applyGeo;
