// FPS Cleaner built-in LOCAL (every client hides these itself: grass, wheat, crops, stumps, hag objects, debris decals ...) decor list.
// RULE: only pure decor is listed. Things bots can take cover behind (rocks, walls, hay bales, crates, barrels, pipes, wrecks,
// barriers, timber) and important objects are NOT in here, see the optional lines in userconfig/fpsc/hide_list.txt.
// Syntax: see FPSC_fnc_parseRules (* = contains, ! = exception). Edit + repack the PBO to change it, or use the CBA "extra entries" boxes.
// Avoid a slash directly before a star (block comment for the preprocessor).
[
    "*plants_f/clutter/",
    "*plants_f/_leafs/",
    "*c_grass",
    "*c_bigfallenbranches",
    "*gbr_clutter/",
    "*plants_f/plant/",
    "*jbad_veg/plants/plant/",
    "*jbad_veg/plants/clutter/",
    "*vegetation_f_enoch/crop/",
    "*vegetation_f_enoch/clutter/",
    "*vegetation_f_exp/crop/",
    "*_stump",
    "*plants_e/plant/",
    "*hag_objects/",
    "*spe_water/riverdetails/",
    "*crater_01_decal",
    "*crater_02_decal",
    "*crater_02_debris",
    "*disturbedsoil_",
    "*spe_apple",
    "*spe_pears",
    "*spe_litter",
    "*spe_milk_",
    "*spe_cider_",
    "*spe_cow_dead"
]
