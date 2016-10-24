/*
Undercover Unit Handler Script

Author: Incontinentia

*/


params [["_undercoverUnit",objNull]];

waitUntil {!(isNull player)};

#include "UCR_setup.sqf"

//Can only be run once per unit locally on the client who is the undercover unit.
if ((_undercoverUnit getVariable ["INC_undercoverHandlerRunning",false]) || (isDedicated) || (_undercoverUnit != player)) exitWith {};

_undercoverUnit setVariable ["INC_undercoverHandlerRunning", true, true];

_undercoverUnit addMPEventHandler ["MPRespawn",{
	_this spawn {
		_undercoverUnit = _this select 0;
		_undercoverUnit setVariable ["INC_undercoverHandlerRunning", false, true];
		_underCoverUnit setVariable ["INC_armedLoopRunning", false, true];
		_underCoverUnit setVariable ["INC_trespassLoopRunning", false, true];
		_underCoverUnit setVariable ["INC_compromisedLoopRunning", false, true];
		_underCoverUnit setVariable ["INC_undercoverCompromised", false, true];
		_underCoverUnit setVariable ["INC_armed", false, true];
		_underCoverUnit setVariable ["INC_suspicious", false, true];
		_underCoverUnit setVariable ["INC_cooldown", false, true];
		sleep 1;
		[[_undercoverUnit], "INCON\INC_undercover\undercoverHandler.sqf"] remoteExec ["execVM",_undercoverUnit];
	};
}];

_undercoverUnit setVariable ["isUndercover", true, true]; //Allow scripts to pick up sneaky units alongside undercover civilians (who do not have the isSneaky variable)


if (_debug) then {
	_undercoverUnit spawn {
		_undercoverUnit = _this select 0;
		waitUntil {
			sleep 5;

			_undercoverUnit globalChat (format ["%1 cover intact: %2",_undercoverUnit,(captive _undercoverUnit)]);

			_undercoverUnit globalChat (format ["%1 compromised: %2",_undercoverUnit,(_undercoverUnit getVariable ["INC_undercoverCompromised",false])]);

			_undercoverUnit globalChat (format ["%1 trespassing: %2",_undercoverUnit,(_undercoverUnit getVariable ["INC_trespassing",false])]);

			_undercoverUnit globalChat (format ["%1 armed: %2",_undercoverUnit,(_undercoverUnit getVariable ["INC_armed",false])]);

			_undercoverUnit globalChat (format ["Enemy know about %1: %2",_undercoverUnit,(_undercoverUnit getVariable ["INC_AnyKnowsSO",false])]); 

			!(_undercoverUnit getVariable ["isUndercover",false])
		};

		_undercoverUnit globalChat (format ["%1 undercover status: %2",_undercoverUnit,(_undercoverUnit getVariable ["isUndercover",false])]);
	};
};

missionNamespace setVariable ["INC_civilianRecruitEnabled",_civRecruitEnabled,true];

_undercoverUnit setCaptive false;
_side = side _undercoverUnit;
//Spawn the rebel commader
[_side] remoteExecCall ["INCON_fnc_spawnRebelCommander",2];

sleep 2;

//Get undercover detection working on the unit
[_undercoverUnit,_regEnySide,_asymEnySide] call INCON_fnc_undercoverDetect;

sleep 2;

//Get the armed handler running on the unit
[_undercoverUnit] call INCON_fnc_undercoverArmedTracker;

sleep 2;

//Get the trespass handler running on the unit
[_undercoverUnit,_regEnySide,_asymEnySide] call INCON_fnc_undercoverTrespassHandler;

sleep 2;

//Get the fired event handler running on the unit
[_undercoverUnit,_regEnySide,_asymEnySide] call INCON_fnc_undercoverFiredEH;

sleep 2;

//Run a low-impact version on group members (no proximity check)
if (_undercoverUnit isEqualTo (leader group _undercoverUnit)) then {
	{
		if !(_x getVariable ["isSneaky",false]) then {
			[_x] remoteExecCall ["INCON_fnc_simpleArmedTracker",_undercoverUnit];
			[_x,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverDetect",_undercoverUnit];
			_x setVariable ["noChanges",true,true];
			_x setVariable ["isUndercover", true, true];

			[_x,_undercoverUnit] spawn {

				params ["_unit","_undercoverUnit"];

				[_unit, [

					"<t color='#334FFF'>Conceal weapon</t>", {

						params ["_unit"];
						private ["_weaponType","_ammoCount","_mag","_magazineCount","_weaponArray"];

						_weaponType = currentWeapon _unit;

						if ((_weaponType == "") || (_weaponType == "Throw")) exitWith {
							private _civComment = selectRandom ["I'm unarmed, let's find a weapon.","I need to find a weapon.","I've got no weapon."];
							[[_unit, _civComment] remoteExec ["globalChat",0]];
						};

						_ammoCount = _unit ammo (currentWeapon _unit);
						_mag = currentMagazine _unit;
						_weaponArray = [_weaponType,_ammoCount,_mag];

						_unit setVariable ["weaponStore",_weaponArray,true];
						_unit setVariable ["weaponStoreActive",true,true];
						_unit removeWeaponGlobal _weaponType;
						_unit call ace_weaponselect_fnc_putWeaponAway;

					},[],6,false,true,"","((_this == _target) && !((currentWeapon _this == 'Throw') || (currentWeapon _this == '')))"

				]] remoteExec ["addAction", _undercoverUnit];

				[_unit, [

					"<t color='#FF33BB'>Get concealed weapon out</t>", {

						params ["_unit"];
						private ["_weaponType","_ammoCount","_mag","_magazineCount","_weaponArray"];

						_weaponArray = _unit getVariable ["weaponStore",[]];
						_weaponType = _weaponArray select 0;
						_ammoCount = _weaponArray select 1;
						_mag = _weaponArray select 2;
						_unit addMagazine _mag;
						_unit addWeapon _weaponType;
						_unit setAmmo [_weaponType,_ammoCount];
						_unit setVariable ["weaponStoreActive",false,true];

						if ((_weaponType == "") || (_weaponType == "Throw")) then {

							private _civComment = selectRandom ["I'm unarmed, let's find a weapon.","I need to find a weapon.","I've got no weapon."];
							[[_unit, _civComment] remoteExec ["globalChat",0]];

						};

					},[],6,false,true,"","((_this == _target) && ((currentWeapon _this == 'Throw') || (currentWeapon _this == '')) && (_this getVariable ['weaponStoreActive',false]))"

				]] remoteExec ["addAction", _undercoverUnit];
			};

		};
	} forEach units group _undercoverUnit;
};

sleep 2;

//Main loop
waitUntil {

	sleep 5;

	//Pause while the unit is compromised
	waitUntil {
		sleep 3;
		!(_undercoverUnit getVariable ["INC_undercoverCompromised",false]);
	};

	//wait until the unit is armed or trespassing
	waitUntil {
		sleep 3;
		((_undercoverUnit getVariable ["INC_armed",false]) || (_undercoverUnit getVariable ["INC_trespassing",false]));
	};

	//Once the player is doing naughty stuff, make them vulnerable to being compromised
	_undercoverUnit setVariable ["INC_suspicious", true, true]; //Hold the cooldown script until the unit is no longer doing naughty things
	[_undercoverUnit, false] remoteExec ["setCaptive", _undercoverUnit]; //Makes enemies hostile to the unit

	[_undercoverUnit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCooldown",_undercoverUnit]; //Gets the cooldown script going

	//If a unit is spotted while both armed and trespassing, he will become compromised
	if (_undercoverUnit getVariable ["INC_armed",false]) then {

		//While he's armed and not compromised, run these checks
		while { sleep 2; ((_undercoverUnit getVariable ["INC_armed",false]) && !(_undercoverUnit getVariable ["INC_undercoverCompromised",false]))} do {

			//Do nothing until he's also trespassing
			if (_undercoverUnit getVariable ["INC_trespassing",false]) then {

				//Wait until people know about him
				if (_undercoverUnit getVariable ["INC_AnyKnowsSO",false]) then {

					private _regAlerted = [_regEnySide,_undercoverUnit,50] call INCON_fnc_countAlerted;
					private _asymAlerted = [_asymEnySide,_undercoverUnit,50] call INCON_fnc_countAlerted;

					//Once people know exactly where he is, who he is, and that he is both armed and trespassing, make him compromised
					if ((_regAlerted != 0) || (_asymAlerted != 0)) exitWith {

						[_undercoverUnit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCompromised",_undercoverUnit];
					};
				};
			};
		};

	} else {

		//While he's trespassing and not compromised, run these checks
		while {sleep 2; ((_undercoverUnit getVariable ["INC_trespassing",false]) && !(_undercoverUnit getVariable ["INC_undercoverCompromised",false]))} do {

			//Do nothing until he is armed
			if (_undercoverUnit getVariable ["INC_armed",false]) then {

				//Do nothing until people know where he is
				if (_undercoverUnit getVariable ["INC_AnyKnowsSO",false]) then {

					private _regAlerted = [_regEnySide,_undercoverUnit,50] call INCON_fnc_countAlerted;
					private _asymAlerted = [_asymEnySide,_undercoverUnit,50] call INCON_fnc_countAlerted;

					//Once people know exactly where he is, who he is, and that he is both armed and trespassing, make him compromised
					if ((_regAlerted != 0) || (_asymAlerted != 0)) exitWith {

						[_undercoverUnit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCompromised",_undercoverUnit];
					};
				};
			};
		};
	};

	//Wait until he is no longer armed or trespassing...
	waitUntil {
		sleep 4;
		!((_undercoverUnit getVariable ["INC_trespassing",false]) && (_undercoverUnit getVariable ["INC_armed",false]));
	};

	//Then stop the holding variable and allow cooldown to commence
	_undercoverUnit setVariable ["INC_suspicious", false, true];

	sleep 5;

	//Wait until cooldown loop has finished
	waitUntil {
		sleep 4;
		!(_undercoverUnit getVariable ["INC_cooldown",false]);
	};

	false

};
