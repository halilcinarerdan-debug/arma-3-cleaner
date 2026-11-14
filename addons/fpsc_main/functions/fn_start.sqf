// Runs once on every machine when CBA has initialised the settings.
if (FPSC_ready) exitWith {};

FPSC_s_state = 0;
FPSC_s_hidden = [];
FPSC_s_prot = [];
FPSC_s_frozen = [];
FPSC_s_rvHide = [];
FPSC_s_rvProt = [];
FPSC_s_rvFrz = [];
FPSC_s_queue = [];
FPSC_s_qi = 0;
FPSC_s_seen = createHashMap;
FPSC_s_allQueued = false;
FPSC_s_nextEnq = 0;
FPSC_s_nextLog = 0;
FPSC_s_chunks = 0;
FPSC_s_lastLogChunks = 0;
FPSC_r_verdict = createHashMap;
FPSC_r_chunk = 250;
FPSC_c_envApplied = false;
FPSC_c_nextGeo = 0;

FPSC_dirty = true;
FPSC_dirtyAt = diag_tickTime - 10;
FPSC_ready = true;

if (isServer || hasInterface) then {
    [{ call FPSC_fnc_tick }, 0] call CBA_fnc_addPerFrameHandler;
};
diag_log "[FPSC] FPS Cleaner started";
