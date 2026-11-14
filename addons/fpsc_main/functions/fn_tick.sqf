// Per-frame handler (all machines).
if (!FPSC_ready) exitWith {};
if (FPSC_dirty && {(diag_tickTime - FPSC_dirtyAt) > 1.5}) then {
    FPSC_dirty = false;
    call FPSC_fnc_applyEnv;
    call FPSC_fnc_pipelineReset;
};
if (hasInterface && {diag_tickTime >= FPSC_c_nextGeo}) then {
    FPSC_c_nextGeo = diag_tickTime + 5;
    call FPSC_fnc_applyGeo;
};
call FPSC_fnc_pipelineStep;
