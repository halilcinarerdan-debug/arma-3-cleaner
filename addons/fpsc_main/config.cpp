class CfgPatches {
    class fpsc_main {
        name = "FPS Cleaner";
        author = "FPS Cleaner";
        url = "";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.06;
        requiredAddons[] = {"cba_main"};
    };
};

class CfgFunctions {
    class FPSC {
        tag = "FPSC";
        class core {
            file = "\z\fpsc\addons\fpsc_main\functions";
            class applyEnv {};
            class applyGeo {};
            class chunkObjects {};
            class classMatch {};
            class clusterPick {};
            class compileRules {};
            class enqueue {};
            class inspect {};
            class modelMap {};
            class modelVerdict {};
            class normPath {};
            class onSettingChanged {};
            class parseList {};
            class pipelineReset {};
            class pipelineStep {};
            class processChunk {};
            class purgeMission {};
            class scan {};
            class start {};
            class status {};
            class tick {};
            class typePreset {};
        };
    };
};

class Extended_PreInit_EventHandlers {
    class fpsc_main {
        init = "call compile preprocessFileLineNumbers '\z\fpsc\addons\fpsc_main\XEH_preInit.sqf'";
    };
};
