// Normalises a class/model token: lower case, backslashes, no leading backslash.
// A trailing slash/backslash is preserved (so "jbad\" stays a folder pattern).
// Params: [string]   Returns: string
params [["_s", "", [""]]];
_s = toLower _s;
private _trail = (count _s > 0) && {(_s select [count _s - 1]) in ["/", FPSC_bs]};
_s = (_s splitString "/") joinString FPSC_bs;
_s = (_s splitString FPSC_bs) joinString FPSC_bs;
if ((_s select [0, 1]) isEqualTo FPSC_bs) then { _s = _s select [1] };
if (_trail) then { _s = _s + FPSC_bs };
_s
