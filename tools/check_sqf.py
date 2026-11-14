#!/usr/bin/env python3
"""Light sanity checks for the addon (no Arma needed):
 - bracket balance per SQF/CPP file (strings and comments ignored)
 - every FPSC_fnc_* that is called exists in config.cpp CfgFunctions and as a file
 - every FPSC_* CBA setting variable that is read is registered in XEH_preInit.sqf
 - no line in an .sqf ends with a backslash (packers treat it as a line continuation)
It is NOT a full SQF parser; it only catches typos that would break the mod at load time."""
import re, sys, pathlib

root = pathlib.Path(__file__).resolve().parent.parent / "addons" / "fpsc_main"
errors = []

def strip(src):
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if src.startswith("//", i):
            while i < n and src[i] != "\n": i += 1
        elif src.startswith("/*", i):
            j = src.find("*/", i + 2); i = n if j < 0 else j + 2
        elif c in "\"'":
            q = c; i += 1
            while i < n:
                if src[i] == q:
                    if i + 1 < n and src[i + 1] == q: i += 2; continue
                    break
                i += 1
            i += 1; out.append('""')
        else:
            out.append(c); i += 1
    return "".join(out)

def balance(path, src):
    st, pairs = [], {")": "(", "]": "[", "}": "{"}
    line = 1
    for c in strip(src):
        if c == "\n": line += 1
        if c in "([{": st.append((c, line))
        elif c in ")]}":
            if not st or st[-1][0] != pairs[c]: errors.append(f"{path.name}: unbalanced '{c}' near line {line}"); return
            st.pop()
    if st: errors.append(f"{path.name}: unclosed '{st[-1][0]}' from line {st[-1][1]}")

files = sorted(root.rglob("*.sqf")) + [root / "config.cpp"]
for f in files:
    t = f.read_text(encoding="utf-8")
    balance(f, t)
    if f.suffix == ".sqf":
        for n, l in enumerate(t.splitlines(), 1):
            if l.rstrip().endswith("\\"): errors.append(f"{f.name}:{n}: line ends with backslash")

cfg = (root / "config.cpp").read_text()
declared = set(re.findall(r"class (\w+) \{\};", cfg))
on_disk = {p.stem[3:] for p in (root / "functions").glob("fn_*.sqf")}
if declared != on_disk: errors.append(f"CfgFunctions vs files differ: {sorted(declared ^ on_disk)}")
allsrc = "\n".join(strip(f.read_text(encoding="utf-8")) for f in files if f.suffix == ".sqf")
for fn in sorted(set(re.findall(r"FPSC_fnc_(\w+)", allsrc))):
    if fn not in declared: errors.append(f"FPSC_fnc_{fn} is used but not defined")

pre = (root / "XEH_preInit.sqf").read_text()
registered = set(re.findall(r'\["(FPSC_\w+)", "(?:CHECKBOX|LIST|SLIDER|EDITBOX)"', pre))
used = set(re.findall(r"\bFPSC_[a-z]+_?[a-zA-Z_]*\b", allsrc))
settings_like = {u for u in used if re.match(r"FPSC_(enabled|hide_|cluster_|road_|prot_|terrain_|env_|geo_|radius|budget|debug)", u)}
settings_like -= {u for u in settings_like if u.startswith(("FPSC_r_", "FPSC_s_", "FPSC_c_"))}
for u in sorted(settings_like - registered): errors.append(f"setting variable {u} is read but never registered")
for u in sorted(registered - used): errors.append(f"setting {u} is registered but never read")

print(f"checked {len(files)} files, {len(declared)} functions, {len(registered)} settings")
for e in errors: print("ERROR:", e)
sys.exit(1 if errors else 0)
