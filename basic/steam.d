module basic.steam;

import basic : AliasSeq, Procedure;

struct ISteamUser__; alias ISteamUser = ISteamUser__*;
struct ISteamUtils__; alias ISteamUtils = ISteamUtils__*;
struct ISteamFriends__; alias ISteamFriends = ISteamFriends__*;
enum SteamAPIInitResult : int {
    OK = 0,
    FAILED_GENERIC = 1,
    NO_STEAM_CLIENT = 2,
    VERSION_MISMATCH = 3,
}

alias steam_api64 = AliasSeq!(
    Procedure!(SteamAPIInitResult, "SteamAPI_InitFlat", char[1024]*),
    Procedure!(void, "SteamAPI_RunCallbacks"),
    Procedure!(void, "SteamAPI_Shutdown"),
    Procedure!(ISteamUser, "SteamAPI_SteamUser_v023"),
    Procedure!(ISteamUtils, "SteamAPI_SteamUtils_v010"),
    Procedure!(ISteamFriends, "SteamAPI_SteamFriends_v017"),
);
