/*

Setup options for INC_undercover undercover / civilian recruitment script by Incontinentia.

*/

//-------------------------Player settings-------------------------

_undercoverUnitSide = west;             //What side is/are the undercover unit(s) on? (Can be east, west or independent - only one side supported at present)

//-------------------------Enemy Settings-------------------------
/*
Note: the difference between regular and asymmetric enemies relates only to their detection behaviour. Either will work similarly but with the following differences:
Regular enemies will share your identity between all units of that side after a short while once you become compromised, making it more important to have quick, clean kills.
Asymmetric enemies on the other hand will be able to detect your true identity from further away due to their local knowledge, but won't necessarily share your identity with other cells.
In essence, you can get closer to regular enemies without blowing your cover but once blown, it will stay blown for longer.
*/

_regEnySide = east;                     //Units of this side will be classed as regular enemies (Side: can be east, west, independent, or sideEmpty) - if you don't need this, type 'sideEmpty' (without quotation marks) into this field or comment the line out (i.e. put // before _regEnySide, as in //_regEnySide = east;).
_regBarbaric = false;                   //(Bool - true or false) Will this side lash out on civilians if it takes casualties and doesn't know the attacker?
_asymEnySide = independent;             //Units of this side will be classed as asymetric enemies (Side: can be east, west, independent, or sideEmpty) - if you don't need this, type 'sideEmpty' (without quotation marks) into this field or comment the line out (i.e. put // before _asymEnySide, as in //_asymEnySide = sideEmpty;).
_asymBarbaric = true;                   //(Bool - true or false) Will this side lash out on civilians if it takes casualties and doesn't know the attacker?


//-------------------------Disguise settings-------------------------
/*
Disguises allow the player and his subordinates to pose as non-hostiles as long as they don't act suspiciously.
Safe items are items that you can wear and not blow your cover.
Be aware though that the script is geared more towards undercover work dressed as civilians and will currently penalise anyone carrying a weapon.
If you are seen carrying military equipment (weapons, grenades, explosives, NVGs, binoculars / laser designators), it will blow your disguise.
Having night vision goggles strapped to your head will blow your disguise too, even if you aren't actually using them!! (This can be turned off below).
*/
_safeFactionVests = ["CIV_F","CIV_F_TANOA"]; //Array of factions whose vests are safe for undercover units to wear (must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeFactionUniforms = ["CIV_F","CIV_F_TANOA"]; //Array of factions whose clothes are safe for undercover units to wear (must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])

//(array of classnames) Safe vests (on top of the specific factions above - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeVests = [];

//(Array of classnames) Safe uniforms (on top of the specific factions above - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeUniforms = ["U_BG_Guerilla2_2","U_BG_Guerilla2_1","U_BG_Guerilla2_3","U_I_C_Soldier_Bandit_4_F","U_I_C_Soldier_Bandit_1_F","U_I_C_Soldier_Bandit_2_F","U_I_C_Soldier_Bandit_5_F","U_I_C_Soldier_Bandit_3_F"];

//(Array of classnames) Safe backpacks (will automatically include civilian backpack classes - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_safeBackpacks = ["B_FieldPack_blk","B_FieldPack_cbr","B_FieldPack_khk","B_FieldPack_oucamo","B_Carryall_cbr","B_Carryall_khk","B_Carryall_oucamo","B_TacticalPack_blk","B_TacticalPack_rgr","B_TacticalPack_oli","B_Kitbag_cbr","B_Kitbag_rgr","B_Kitbag_sgg","B_Respawn_Sleeping_bag_blue_F","B_Respawn_Sleeping_bag_brown_F","B_Respawn_TentDome_F","B_Respawn_TentA_F","B_Parachute","ACE_NonSteerableParachute","ACE_TacticalLadder_Pack"];

_HMDallowed = false; //(Bool - true or false) Are HMDs (night vision goggles etc.) safe to wear? Set to false if wearing HMDs will cause suspicion (must be stored in backpack).




//-------------------------Civilian recruitment settings-------------------------
/*
By enabling civilian recruitment, undercover can recruit any ambient civilians they see into their group (if their reputation allows / the civvy wants to join).
Civilians will operate under similar restrictions to the player; if they are armed, conducting hostile actions, or seen wearing prohibited gear, their cover will be blown.
If your civilian teammate has a concealed weapon in their uniform or backpack, you can order them to get it out by using the action orders menu (command menu -> 6).
If they are armed and have space to hide a weapon in their uniform or backpack, you can order them to conceal their weapon using the same action menu.
You can also dismiss your new teammates and they will leave your group and carry on doing whatever it is they fancy doing (usually sitting cross-legged in the middle of a field).
*/

_civRecruitEnabled = true;          //(Bool - true or false) Set this to false to prevent undercover units from recruiting civilians
_armedCivPercentage = 70;           //(Number - 0 to 100) Max percentage of civilians armed with weapons from the array below, either on their person or in their backpacks (will only work if _civRecruitEnabled is set to true, otherwise this is ignored)

//Weapon classnames for armed civilians (array of classnames)
_civWpnArray = ["arifle_AKS_F","arifle_AKM_F","hgun_Pistol_01_F","hgun_Rook40_F","hgun_ACPC2_F","hgun_Rook40_F"];

//Items that civilians may carry
_civItemArray = ["ACE_Cellphone","ACE_Banana","ACE_Flashlight_KSF1","ACE_SpraypaintBlack","itemRadio","ACE_RangeCard","ACE_key_civ","ACE_key_lockpick","ACE_fieldDressing","IEDUrbanSmall_F","IEDUrbanSmall_F"];


//Civilian backpack classes (array of classnames)
_civPackArray = ["B_FieldPack_blk","B_FieldPack_cbr","B_FieldPack_khk","B_FieldPack_oucamo","B_Carryall_cbr"];

//Persistent player group settings (EXPERIMENTAL)
_persistentGroup = true;        //Persist AI in player group between ALiVE persistent sessions (requires INCON_groupPersist and INIDBI2 loaded on server)


//-------------------------Misc settings-------------------------

_debug = false; //Set to true for debug hints
