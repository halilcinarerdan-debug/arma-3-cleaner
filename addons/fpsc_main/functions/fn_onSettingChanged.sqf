// CBA setting callback (also fires during init, which we ignore until FPSC_ready).
if (!FPSC_ready) exitWith {};
FPSC_dirty = true;
FPSC_dirtyAt = diag_tickTime;
