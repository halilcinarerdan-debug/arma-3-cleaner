// Maps a preset index to a list of nearestTerrainObjects types.
// 0 bushes | 1 bushes+small trees | 2 all vegetation | 3 vegetation+rocks | 4 everything small
// Params: [index]   Returns: array of strings
params [["_i", 0, [0]]];
switch (_i) do {
    case 0: { ["BUSH"] };
    case 1: { ["BUSH", "SMALL TREE"] };
    case 2: { ["BUSH", "SMALL TREE", "TREE"] };
    case 3: { ["BUSH", "SMALL TREE", "TREE", "ROCK", "ROCKS"] };
    default { +FPSC_smallTypes };
}
