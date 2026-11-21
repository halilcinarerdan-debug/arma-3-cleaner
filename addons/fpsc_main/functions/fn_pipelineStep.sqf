// Per-frame worker. State 0 = idle, 1 = reverting previous changes, 2 = processing chunks.
// All work is limited to FPSC_r_budget seconds per frame so it never causes a hitch.
private _t0 = diag_tickTime;
private _lim = if (isNil "FPSC_r_budget") then { 0.004 } else { FPSC_r_budget };

// token bucket for network-heavy changes (server only), at most one second worth of tokens
if (isServer) then {
    FPSC_s_tokens = (FPSC_s_tokens + ((_t0 - FPSC_s_lastTick) * FPSC_r_rate)) min FPSC_r_rate;
    FPSC_s_lastTick = _t0;
};

switch (FPSC_s_state) do {
    case 1: {
        private _allow = if (isServer) then { floor FPSC_s_tokens } else { 1000000 };
        private _start = _allow;
        while {(diag_tickTime - _t0) < _lim && {_allow > 0 && {count FPSC_s_rvHide > 0}}} do {
            private _c = ((count FPSC_s_rvHide) min 100) min _allow;
            for "_i" from 1 to _c do {
                private _o = FPSC_s_rvHide deleteAt ((count FPSC_s_rvHide) - 1);
                if (isServer) then { _o hideObjectGlobal false };
                _o hideObject false;
            };
            _allow = _allow - _c;
        };
        while {(diag_tickTime - _t0) < _lim && {_allow > 0 && {count FPSC_s_rvProt > 0}}} do {
            private _c = ((count FPSC_s_rvProt) min 100) min _allow;
            for "_i" from 1 to _c do {
                (FPSC_s_rvProt deleteAt ((count FPSC_s_rvProt) - 1)) allowDamage true;
            };
            _allow = _allow - _c;
        };
        while {(diag_tickTime - _t0) < _lim && {_allow > 0 && {count FPSC_s_rvFrz > 0}}} do {
            private _c = ((count FPSC_s_rvFrz) min 100) min _allow;
            for "_i" from 1 to _c do {
                (FPSC_s_rvFrz deleteAt ((count FPSC_s_rvFrz) - 1)) enableSimulationGlobal true;
            };
            _allow = _allow - _c;
        };
        if (isServer) then { FPSC_s_tokens = FPSC_s_tokens - (_start - _allow) };
        if (count FPSC_s_rvHide == 0 && {count FPSC_s_rvProt == 0 && {count FPSC_s_rvFrz == 0}}) then {
            call FPSC_fnc_compileRules;
            call FPSC_fnc_purgeMission;
            FPSC_s_state = if (FPSC_r_active) then { 2 } else { 0 };
            if (FPSC_debug) then { diag_log format ["[FPSC] revert finished, state=%1", FPSC_s_state] };
        };
    };
    case 2: {
        if (diag_tickTime >= FPSC_s_nextEnq) then {
            FPSC_s_nextEnq = diag_tickTime + 3;
            call FPSC_fnc_enqueue;
        };
        [_t0 + _lim] call FPSC_fnc_jobStep;
        while {(count FPSC_s_jobs) == 0 && {(count FPSC_s_pjobs) == 0 && {FPSC_s_qi < count FPSC_s_queue && {(diag_tickTime - _t0) < _lim}}}} do {
            (FPSC_s_queue select FPSC_s_qi) call FPSC_fnc_processChunk;
            FPSC_s_qi = FPSC_s_qi + 1;
            FPSC_s_chunks = FPSC_s_chunks + 1;
        };
        if (FPSC_s_qi > 0 && {FPSC_s_qi >= count FPSC_s_queue}) then {
            FPSC_s_queue = [];
            FPSC_s_qi = 0;
        };
        if (FPSC_debug && {diag_tickTime >= FPSC_s_nextLog}) then {
            FPSC_s_nextLog = diag_tickTime + 30;
            if (FPSC_s_chunks > FPSC_s_lastLogChunks) then {
                FPSC_s_lastLogChunks = FPSC_s_chunks;
                call FPSC_fnc_status;
            };
        };
    };
    default {};
};
