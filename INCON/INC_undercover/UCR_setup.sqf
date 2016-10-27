/*

Setup options for INC_undercover undercover / civilian recruitment script by Incontinentia.

*/

_undercoverUnitSide = west;             //What side is the undercover unit on? (Can be east, west or independent)

//Enemy Settings
_regEnySide = east;                     //Side of regular enemies (Can be east, west or independent) - if there are none, use sideEmpty
_regBarbaric = false;                   //Will this side lash out on civilians if it takes casualties and doesn't know the attacker?
_asymEnySide = independent;             //Side of asymetric enemies (Can be east, west or independent) - if there are none, use sideEmpty
_asymBarbaric = true;                    //Will this side lash out on civilians if it takes casualties and doesn't know the attacker?

_safeFactionVests = ["CIV_F","CIV_F_TANOA"]; //Array of factions whose vests are safe for undercover units to wear (must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeFactionUniforms = ["CIV_F","CIV_F_TANOA"]; //Array of factions whose uniforms are safe for undercover units to wear (must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])

//Array of safe vests (on top of the specific factions above - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeVests = [];

//Array of safe uniforms (on top of the specific factions above - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeUniforms = ["U_BG_Guerilla2_2","U_BG_Guerilla2_1","U_BG_Guerilla2_3","U_I_C_Soldier_Bandit_4_F","U_I_C_Soldier_Bandit_1_F","U_I_C_Soldier_Bandit_2_F","U_I_C_Soldier_Bandit_5_F","U_I_C_Soldier_Bandit_3_F"];

_HMDallowed = false; //Are HMDs (night vision goggles etc.) safe to wear? Set to false if wearing HMDs will cause suspicion.

//ALiVE specific features (turn off if not using ALiVE)
_civRecruitEnabled = true;      //Set this to false to prevent undercover units from recruiting civilians (only works with ALiVE)
_armedCivPercentage = 70;       //Percentage of civilians armed with rifles or pistols on person or in backpacks (0 to disable)
_persistentGroup = true;        //Attempt to save and load AI in player group using ALiVE persistence (only works with ALiVE)

_debug = false; //Set to true for debug hints
