/*

Setup options for INC_undercover undercover / civilian recruitment script by Incontinentia.

*/

_undercoverUnitSide = west;             //What side is the undercover unit on? (Can be east, west or independent)

//Enemy Settings

/*
Also not the difference between regular and asymmetric enemies; either will work similarly but regular enemies will share your identity between all units of that side after a short while once you become compromised, making it more important to have quick, clean kills.
Asymmetric enemies on the other hand will be able to detect your true identity from further away due to their local knowledge, but won't necessarily share your identity with other cells.
In essence, you can get closer to regular enemies without blowing your cover but once blown, it will stay blown for longer.
*/

_regEnySide = east;                     //Side of regular enemies (Can be east, west or independent) - if there are none, use sideEmpty
_regBarbaric = false;                   //Will this side lash out on civilians if it takes casualties and doesn't know the attacker?
_asymEnySide = independent;             //Side of asymetric enemies (Can be east, west or independent) - if there are none, use sideEmpty
_asymBarbaric = true;                   //Will this side lash out on civilians if it takes casualties and doesn't know the attacker?

_safeFactionVests = ["CIV_F","CIV_F_TANOA"]; //Array of factions whose vests are safe for undercover units to wear (must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeFactionUniforms = ["CIV_F","CIV_F_TANOA"]; //Array of factions whose uniforms are safe for undercover units to wear (must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])

//Array of safe vests (on top of the specific factions above - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeVests = [];

//Array of safe uniforms (on top of the specific factions above - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeUniforms = ["U_BG_Guerilla2_2","U_BG_Guerilla2_1","U_BG_Guerilla2_3","U_I_C_Soldier_Bandit_4_F","U_I_C_Soldier_Bandit_1_F","U_I_C_Soldier_Bandit_2_F","U_I_C_Soldier_Bandit_5_F","U_I_C_Soldier_Bandit_3_F"];

_HMDallowed = false; //Are HMDs (night vision goggles etc.) safe to wear? Set to false if wearing HMDs will cause suspicion (must be stored in backpack).

_civRecruitEnabled = true;          //Set this to false to prevent undercover units from recruiting civilians
_armedCivPercentage = 70;           //Max percentage of civilians armed with rifles or pistols on person or in backpacks (if _civRecruitEnabled is set to true, otherwise this is ignored)

//Weapon classnames for armed civilians
_civWpnArray = ["arifle_AKS_F","hgun_Rook40_F"];

//Civilian backpack classes
_civPackArray = ["B_FieldPack_blk","B_FieldPack_cbr","B_FieldPack_khk","B_FieldPack_oucamo","B_Carryall_cbr"];

//Persistent player group settings (EXPERIMENTAL)
_persistentGroup = true;        //Persist AI in player group between ALiVE persistent sessions (requires INCON_groupPersist and INIDBI2 loaded on server)

_debug = false; //Set to true for debug hints
