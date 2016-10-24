params [["_targetChance",100],["_rebelChance",40],["_percentageTarget",40],["_percentageRebel",50],["_timeToRebel",(random 600)]];

if (missionNamespace getVariable ["civiliansTargeted",false]) exitWith {};

[_targetChance,_rebelChance,_percentageTarget,_percentageRebel,_timeToRebel] spawn {

	params [["_targetChance",100],["_rebelChance",40],["_percentageTarget",40],["_percentageRebel",30],["_timeToRebel",(random 600)]];

	_cooldownTimer = (30 + (random 300));
	sleep _cooldownTimer;

	if (isNil "rebelCommander") then {
		[] remoteExec ["INCON\INC_undercover\Scripts\spawnRebelCommander.sqf"];
	};

	if (_targetChance > (random 100)) then {

		missionNameSpace setVariable ["civiliansTargeted", true, true];
		//Enemies target civs
		{
			if (((side _x) == Civilian) && !(_x getVariable ["isUndercover", false])) then {
				if (_percentageTarget > (random 100)) then {
					[_x] joinSilent grpNull;
					[_x] joinSilent (group rebelCommander);
				};
			};
		} foreach allunits;
	};

	sleep _timeToRebel;


	//Armed civs will rebel
	if (_rebelChance > (random 100)) then {
		{
			if ((side _x) == Civilian) then {
				if !(_x getVariable ["isUndercover", false]) then {
					if !(_x getVariable ["civIsUnarmed", false]) then {
						if (_percentageRebel > (random 100)) then {
							[_x] joinSilent grpNull;
							[_x] joinSilent (group rebelCommander);
							if (_x getVariable ["civRifle",false]) exitWith {
								removeAllWeapons _x;
								_x addMagazine "30Rnd_762x39_Mag_Tracer_F";
								_x addWeapon "arifle_AKM_F";
								_x addMagazine "30Rnd_762x39_Mag_Tracer_F";
								_x addMagazine "30Rnd_762x39_Mag_Tracer_F";
								_x setUnitAbility (0.7 + (random 0.25));
							};
							removeAllWeapons _x;
							_x addMagazine "16Rnd_9x21_Mag";
							_x addWeapon "hgun_Rook40_F";
							_x addMagazine "16Rnd_9x21_Mag";
							_x addMagazine "16Rnd_9x21_Mag";
							_x addMagazine "16Rnd_9x21_Mag";
							_x setUnitAbility (0.7 + (random 0.25));
						};
					};
				};
			};
		} foreach allunits;
	};

	sleep _cooldownTimer;

	missionNamespace setVariable ["civiliansTargeted", false, true];
};
