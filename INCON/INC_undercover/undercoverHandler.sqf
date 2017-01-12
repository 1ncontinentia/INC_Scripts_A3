/*
Undercover Unit Handler Script

Author: Incontinentia

*/


params [["_unit",objNull]];

waitUntil {!(isNull player)};

#include "UCR_setup.sqf"

{_x setVariable ["INC_notDismissable",true];} forEach (units group _unit);

//Can only be run once per unit.
if ((_unit getVariable ["INC_undercoverHandlerRunning",false]) || {(!local _unit)}) exitWith {};

_unit setVariable ["INC_undercoverHandlerRunning", true, true];

if ((_debug) || {_hints}) then {hint "Undercover initialising..."};

//Group persistence
if ((_persistentGroup) && {!(isNil "INCON_fnc_groupPersist")}) then {
	["loadGroup",_unit] call INCON_fnc_groupPersist;
	["saveGroup",_unit] call INCON_fnc_groupPersist;
};

//Add respawn eventhandler so all scripts work properly on respawn
_unit addMPEventHandler ["MPRespawn",{
	_this spawn {
        params ["_unit"];
		_unit setVariable ["INC_undercoverHandlerRunning", false];
		_unit setVariable ["INC_armedLoopRunning", false];
		_unit setVariable ["INC_trespassLoopRunning", false];
		_unit setVariable ["INC_compromisedLoopRunning", false];
		_unit setVariable ["INC_undercoverCompromised", false];
		_unit setVariable ["INC_armed", false];
		_unit setVariable ["INC_suspicious", false];
		_unit setVariable ["INC_cooldown", false];
		sleep 1;
		[[_unit], "INCON\INC_undercover\undercoverHandler.sqf"] remoteExec ["execVM",_unit];
	};
}];

_unit setVariable ["isUndercover", true, true]; //Allow scripts to pick up sneaky units alongside undercover civilians (who do not have the isSneaky variable)

missionNamespace setVariable ["INC_civilianRecruitEnabled",_civRecruitEnabled,true];

//Spawn the rebel commader
[(side _unit)] remoteExecCall ["INCON_fnc_spawnRebelCommander",2];

_unit setCaptive true;

sleep 2;

//Get undercover detection working on the unit
[_unit,_regEnySide,_asymEnySide] call INCON_fnc_undercoverDetect;

sleep 2;

//Get the armed handler running on the unit
[_unit] call INCON_fnc_armedHandler;

sleep 2;

//Get the trespass handler running on the unit
[_unit] call INCON_fnc_trespassHandler;

sleep 2;

//Debug hints
if (_debug) then {
	[_unit] spawn {
		params ["_unit"];

		sleep 5;

		waitUntil {

			sleep 1;

			_unit globalChat (format ["%1 cover intact: %2",_unit,(captive _unit)]);

			_unit globalChat (format ["%1 compromised: %2",_unit,(_unit getVariable ["INC_undercoverCompromised",false])]);

			_unit globalChat (format ["%1 trespassing: %2",_unit,(_unit getVariable ["INC_trespassing",false])]);

			_unit globalChat (format ["%1 armed / wearing suspicious item: %2",_unit,(_unit getVariable ["INC_armed",false])]);

			_unit globalChat (format ["Enemy know about %1: %2",_unit,(_unit getVariable ["INC_AnyKnowsSO",false])]);

			_unit globalChat (format ["Compromised radius multiplier: %1",((_unit getVariable ["INC_compromisedValue",1]) * (_unit getVariable ["INC_suspiciousValue",1]))]);

			!(_unit getVariable ["isUndercover",false])
		};

		_unit globalChat (format ["%1 undercover status: %2",_unit,(_unit getVariable ["isUndercover",false])]);
	};
};

sleep 1;

//Run a low-impact version of the undercover script on group members (no proximity check)
if (_unit isEqualTo (leader group _unit)) then {
	[_unit,_regEnySide,_asymEnySide] spawn {
		params ["_unit","_regEnySide","_asymEnySide"];
		{
			if !(_x getVariable ["isSneaky",false]) then {
				sleep 0.2;
				[_x,"simpleArmedLoop"] remoteExecCall ["INCON_fnc_armedHandler",_unit];
				sleep 0.2;
				[_x,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverDetect",_unit];
				sleep 0.2;
				_x setVariable ["noChanges",true,true];
				_x setVariable ["isUndercover", true, true];
				sleep 0.2;
				[[_x,_unit],"addConcealActions"] call INCON_fnc_civHandler;
			};
		} forEach units group _unit;
	};
};

//Main loop
waitUntil {

	sleep 1;

	//Pause while the unit is compromised
	waitUntil {
		sleep 1;
		!(_unit getVariable ["INC_undercoverCompromised",false]);
	};

	//wait until the unit is armed or trespassing
	waitUntil {
		sleep 1;
		((_unit getVariable ["INC_armed",false]) || {_unit getVariable ["INC_trespassing",false]});
	};

	if ((_debug) || {_hints}) then {
		if (_unit getVariable ["INC_trespassing",false]) then {hint "You are in a sensitive area."};

		[_unit] spawn {
			params ["_unit"];

			waitUntil {
				sleep 1;
				!((_unit getVariable ["INC_armed",false]) || {_unit getVariable ["INC_trespassing",false]})
			};

			hint "In disguise.";
		};
	};

	//Once the player is doing naughty stuff, make them vulnerable to being compromised
	_unit setVariable ["INC_suspicious", true]; //Hold the cooldown script until the unit is no longer doing naughty things
	[_unit, false] remoteExec ["setCaptive", _unit]; //Makes enemies hostile to the unit

	[_unit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCooldown",_unit]; //Gets the cooldown script going


	while {
		sleep 1;
		(((_unit getVariable ["INC_armed",false]) || {(_unit getVariable ["INC_trespassing",false])}) && {!(_unit getVariable ["INC_undercoverCompromised",false])}) //While not compromised and either armed or trespassing
	} do {
		if (
			(_unit getVariable ["INC_armed",false]) &&
			{(_unit getVariable ["INC_trespassing",false])} &&
			{(_unit getVariable ["INC_AnyKnowsSO",false])}
		) then {
			private _regAlerted = [_regEnySide,_unit,50] call INCON_fnc_countAlerted;
			private _asymAlerted = [_asymEnySide,_unit,50] call INCON_fnc_countAlerted;

			//Once people know exactly where he is, who he is, and that he is both armed and trespassing, make him compromised
			if ((_regAlerted != 0) || {(_asymAlerted != 0)}) exitWith {

				[_unit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCompromised",_unit];
			};
		};
	};

	//Then stop the holding variable and allow cooldown to commence
	_unit setVariable ["INC_suspicious", false];

	sleep 2;

	//Wait until cooldown loop has finished
	waitUntil {
		sleep 2;
		!(_unit getVariable ["INC_cooldown",false]);
	};

	(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)})

};

_unit setVariable ["INC_undercoverHandlerRunning", false, true];
