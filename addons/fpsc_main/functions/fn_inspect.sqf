// Shows the classname / model / mod of the object under the crosshair and copies a
// ready-to-paste decor list entry to the clipboard. Keybind: Ctrl+Shift+I.
// Debug console:  [] spawn FPSC_fnc_inspect;
if (!canSuspend) exitWith { [] spawn FPSC_fnc_inspect };

private _o = cursorObject;
if (isNull _o) then { _o = cursorTarget };
if (isNull _o) exitWith { systemChat "[FPS Cleaner] no object under the crosshair" };

private _mi = getModelInfo _o;
private _path = toLower (_mi select 1);
private _clean = if ((_path select [0, 1]) isEqualTo FPSC_bs) then { _path select [1] } else { _path };
private _map = call FPSC_fnc_modelMap;
private _known = _map getOrDefault [_clean, []];
private _classes = _known apply { _x select 0 };
private _typeOf = typeOf _o;
if (!(_typeOf isEqualTo "") && {!((toLower _typeOf) in (_classes apply { toLower _x }))}) then { _classes = [_typeOf] + _classes };

private _mod = "";
if (count _known > 0) then {
    private _cfg = configFile >> ((_known select 0) select 1) >> ((_known select 0) select 0);
    _mod = configSourceMod _cfg;
    if (_mod isEqualTo "") then { _mod = (configSourceAddonList _cfg) param [0, ""] };
};
private _entry = if (count _classes > 0) then { _classes select 0 } else { toLower (_mi select 0) };

private _txt = format ["[FPSC][INSPECT] object=%1 | typeOf='%2' | classnames=%3 | model=%4 | path=%5 | mod=%6 | decor-list entry: %7",
    _o, _typeOf, _classes joinString "|", _mi select 0, _clean, _mod, _entry];
diag_log _txt;
copyToClipboard _entry;
systemChat format ["[FPS Cleaner] %1 (%2) | mod: %3 | '%4' copied to clipboard", _entry, _mi select 0, _mod, _entry];
hintSilent parseText format ["<t size='1.1'>FPS Cleaner</t><br/>class: %1<br/>model: %2<br/>mod: %3<br/><t color='#99ff99'>%4</t> copied", _classes joinString ", ", _mi select 0, _mod, _entry];
_txt
