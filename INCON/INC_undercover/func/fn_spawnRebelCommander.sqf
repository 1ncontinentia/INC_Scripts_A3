params [["_side",west]];


private _rebelCommander = format ["INC_rebelCommander%1",_side];

if (missionNamespace getVariable [_rebelCommander,false]) exitWith {};

missionNamespace setVariable [_rebelCommander,true,true];


private _rebelGroup = [[(random 40),(random 40),10], _side, 1] call BIS_fnc_spawnGroup;
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
