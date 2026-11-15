// Works through the pending decor-list jobs (one per chunk) in small batches, so a chunk with
// tens of thousands of objects (e.g. grass/wheat object fields) never causes a frame hitch.
// Params: [deadline (diag_tickTime)]
params ["_deadline"];
while {(count FPSC_s_jobs > 0) && {diag_tickTime < _deadline}} do {
    private _job = FPSC_s_jobs select 0;
    private _objs = _job select 0;
    private _i = _job select 1;
    private _end = (_i + 300) min (count _objs);
    private _hide = [];
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
    if (count _hide > 0) then {
        if (FPSC_r_global) then {
            { _x hideObjectGlobal true } forEach _hide;
        } else {
            { _x hideObject true } forEach _hide;
        };
        FPSC_s_hidden append _hide;
    };
    if (_end >= count _objs) then { FPSC_s_jobs deleteAt 0 } else { _job set [1, _end] };
};
