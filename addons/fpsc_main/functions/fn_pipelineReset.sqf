// Starts a fresh pass: everything we changed so far is queued for reverting, then the rules
// are recompiled and the map is processed again (see FPSC_fnc_pipelineStep).
FPSC_s_rvHide append FPSC_s_hidden;
FPSC_s_rvProt append FPSC_s_prot;
FPSC_s_rvFrz append FPSC_s_frozen;
FPSC_s_hidden = [];
FPSC_s_prot = [];
FPSC_s_frozen = [];
FPSC_s_queue = [];
FPSC_s_qi = 0;
FPSC_s_seen = createHashMap;
FPSC_s_allQueued = false;
FPSC_s_nextEnq = 0;
FPSC_s_state = 1;
