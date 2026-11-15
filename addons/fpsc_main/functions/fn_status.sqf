// Prints (RPT) and returns a one-line status. Debug console: call FPSC_fnc_status
private _s = format ["[FPSC] state=%1 queue=%2/%3 chunksDone=%4 seen=%5 hidden=%6 protected=%7 frozen=%8 modelCache=%9 chunkSize=%10 pendingJobs=%11",
    FPSC_s_state, FPSC_s_qi, count FPSC_s_queue, FPSC_s_chunks, count FPSC_s_seen,
    count FPSC_s_hidden, count FPSC_s_prot, count FPSC_s_frozen, count FPSC_r_verdict, FPSC_r_chunk, count FPSC_s_jobs];
diag_log _s;
_s
