// Works through the pending jobs in small batches so that a chunk with tens of thousands of
// objects never causes a frame hitch.
//   FPSC_s_jobs  : [objects, index, preDecided]  hide jobs (preDecided = true: hide all, false: check the decor list)
//   FPSC_s_pjobs : [objects, index, freeze]      destruction protection jobs (server only)
// Server mode: every hideObjectGlobal / allowDamage / enableSimulationGlobal is a network message, so all
// of them are paid for with tokens (FPSC_s_tokens, refilled with FPSC_r_rate per second) and the number of
// globally hidden objects is capped (FPSC_r_gmax). That keeps server FPS and sync healthy.
// Params: [deadline (diag_tickTime)]
params ["_deadline"];

// ---- hide jobs ----
while {(count FPSC_s_jobs > 0) && {diag_tickTime < _deadline}} do {
    private _job = FPSC_s_jobs select 0;
    private _objs = _job select 0;
    private _i = _job select 1;
    private _n = 300;
    if (FPSC_r_global) then {
        if ((count FPSC_s_hidden) >= FPSC_r_gmax) then {
            if (!FPSC_s_capped) then {
                FPSC_s_capped = true;
                diag_log format ["[FPSC] server mode: hard cap of %1 hidden objects reached, no more objects are hidden. Use the local removal method for bigger lists.", FPSC_r_gmax];
            };
            FPSC_s_jobs = [];
            _n = 0;
        } else {
            _n = (floor FPSC_s_tokens) min 300;
        };
    };
    if (_n < 1) then {
        _deadline = -1; // out of tokens (or capped): continue next frame
    } else {
        private _end = (_i + _n) min (count _objs);
        private _hide = [];
        if (_job select 2) then {
            _hide = _objs select [_i, _end - _i];
        } else {
            for "_k" from _i to (_end - 1) do {
                private _o = _objs select _k;
                private _mi = getModelInfo _o;
                private _path = toLower (_mi select 1);
                if !(_path isEqualTo "") then {
                    private _v = FPSC_r_verdict getOrDefault [_path, -1];
                    if (_v isEqualTo -1) then {
                        _v = [_path, toLower (_mi select 0)] call FPSC_fnc_modelVerdict;
                        FPSC_r_verdict set [_path, _v];
                    };
                    if (_v isEqualTo true) then { _hide pushBack _o };
                };
            };
        };
        if (count _hide > 0) then {
            if (FPSC_r_global) then {
                { _x hideObjectGlobal true } forEach _hide;
            } else {
                { _x hideObject true } forEach _hide;
            };
            FPSC_s_hidden append _hide;
        };
        if (FPSC_r_global) then { FPSC_s_tokens = FPSC_s_tokens - (_end - _i) };
        if (_end >= count _objs) then { FPSC_s_jobs deleteAt 0 } else { _job set [1, _end] };
    };
};

// ---- protection jobs (allowDamage false, optionally enableSimulationGlobal false) ----
while {(count FPSC_s_pjobs > 0) && {diag_tickTime < _deadline}} do {
    private _job = FPSC_s_pjobs select 0;
    private _objs = _job select 0;
    private _i = _job select 1;
    private _freeze = _job select 2;
    private _cost = if (_freeze) then { 2 } else { 1 };
    private _n = ((floor (FPSC_s_tokens / _cost)) min 200);
    if (_n < 1) then {
        _deadline = -1;
    } else {
        private _end = (_i + _n) min (count _objs);
        private _slice = _objs select [_i, _end - _i];
        { _x allowDamage false } forEach _slice;
        FPSC_s_prot append _slice;
        if (_freeze) then {
            { _x enableSimulationGlobal false } forEach _slice;
            FPSC_s_frozen append _slice;
        };
        FPSC_s_tokens = FPSC_s_tokens - ((_end - _i) * _cost);
        if (_end >= count _objs) then { FPSC_s_pjobs deleteAt 0 } else { _job set [1, _end] };
    };
};
