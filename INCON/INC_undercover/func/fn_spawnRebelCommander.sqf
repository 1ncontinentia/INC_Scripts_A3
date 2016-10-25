params [["_side",west]];


if (missionNamespace getVariable ["INC_rebelCommanderSpawned",false]) exitWith {};

if (isNil "rebelCommander") then {

	private _rebelGroup = [[40,40,10], _side, 1] call BIS_fnc_spawnGroup;
	rebelCommander = leader _rebelGroup;
	rebelCommander setRank "COLONEL";
	rebelCommander disableAI "ALL";
	rebelCommander enableAI "TARGET";
	rebelCommander enableAI "FSM";
	rebelCommander allowDamage false;
	rebelCommander enableSimulation false;
	rebelCommander hideObjectGlobal true;
	rebelCommander hideObject true;
	rebelCommander setUnitAbility 1;
	INC_rebelCommanderSpawned = true;
	publicVariable "INC_rebelCommanderSpawned";

};
