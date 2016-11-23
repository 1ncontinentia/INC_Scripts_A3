
#include "..\UCR_setup.sqf"

private ["_commander","_rebelGroup"];

//private _rebelCommander = format ["INC_rebelCommander"];

if (missionNamespace getVariable ["INC_rebelCommanderSpawned",false]) exitWith {};

private _rebelGroup = [[(random 40),(random 40),10], _undercoverUnitSide, 1] call BIS_fnc_spawnGroup;
_commander = leader _rebelGroup;
_commander setRank "COLONEL";
_commander disableAI "ALL";
_commander enableAI "TARGET";
_commander enableAI "FSM";
_commander allowDamage false;
_commander enableSimulation false;
_commander hideObjectGlobal true;
_commander hideObject true;
_commander setUnitAbility 1;

missionNamespace setVariable ["INC_rebelCommanderSpawned",true,true];

missionNamespace setVariable ["INC_rebelCommander",_commander,true];

_commander
