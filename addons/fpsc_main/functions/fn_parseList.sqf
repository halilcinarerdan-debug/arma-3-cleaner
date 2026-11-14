// Splits free text into tokens. Separators: comma, semicolon, space, tab, CR, LF.
// Params: [string]   Returns: array of strings
params [["_text", "", [""]]];
private _sep = ",; " + toString [9, 10, 13];
(_text splitString _sep) select { !(_x isEqualTo "") }
