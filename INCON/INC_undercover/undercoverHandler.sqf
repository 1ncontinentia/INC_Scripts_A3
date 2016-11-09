/*
Undercover Unit Handler Script

Author: Incontinentia

*/


params [["_undercoverUnit",objNull]];

waitUntil {!(isNull player)};

#include "UCR_setup.sqf"

{_x setVariable ["INC_notDismissable",true];} forEach (units group _undercoverUnit);

//Can only be run once per unit.
if (_undercoverUnit getVariable ["INC_undercoverHandlerRunning",false]) exitWith {};

_undercoverUnit setVariable ["INC_undercoverHandlerRunning", true, true];

//Group persistence
if ((_persistentGroup) && {!(isNil "INCON_fnc_groupPersist")}) then {
	["loadGroup",_undercoverUnit] call INCON_fnc_groupPersist;
	["saveGroup",_undercoverUnit] call INCON_fnc_groupPersist;
};

//Add respawn eventhandler so all scripts work properly on respawn
_undercoverUnit addMPEventHandler ["MPRespawn",{
	_this spawn {
        params ["_undercoverUnit"];
		_undercoverUnit setVariable ["INC_undercoverHandlerRunning", false];
		_underCoverUnit setVariable ["INC_armedLoopRunning", false];
		_underCoverUnit setVariable ["INC_trespassLoopRunning", false];
		_underCoverUnit setVariable ["INC_compromisedLoopRunning", false];
		_underCoverUnit setVariable ["INC_undercoverCompromised", false];
		_underCoverUnit setVariable ["INC_armed", false];
		_underCoverUnit setVariable ["INC_suspicious", false];
		_underCoverUnit setVariable ["INC_cooldown", false];
		sleep 1;
		[[_undercoverUnit], "INCON\INC_undercover\undercoverHandler.sqf"] remoteExec ["execVM",_undercoverUnit];
	};
}];

_undercoverUnit setVariable ["isUndercover", true, true]; //Allow scripts to pick up sneaky units alongside undercover civilians (who do not have the isSneaky variable)

missionNamespace setVariable ["INC_civilianRecruitEnabled",_civRecruitEnabled,true];

_undercoverUnit setCaptive true;
private _side = side _undercoverUnit;

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

//Debug hints
if (_debug) then {
	[_undercoverUnit] spawn {
		params ["_undercoverUnit"];
		waitUntil {

			waitUntil {
				sleep 1;
				(_undercoverUnit getVariable ["INC_trespassLoopRunning",false])
			};

			sleep 0.5;

			_undercoverUnit globalChat (format ["%1 cover intact: %2",_undercoverUnit,(captive _undercoverUnit)]);

			_undercoverUnit globalChat (format ["%1 compromised: %2",_undercoverUnit,(_undercoverUnit getVariable ["INC_undercoverCompromised",false])]);

			_undercoverUnit globalChat (format ["%1 trespassing: %2",_undercoverUnit,(_undercoverUnit getVariable ["INC_trespassing",false])]);

			_undercoverUnit globalChat (format ["%1 armed / wearing suspicious item: %2",_undercoverUnit,(_undercoverUnit getVariable ["INC_armed",false])]);

			_undercoverUnit globalChat (format ["Enemy know about %1: %2",_undercoverUnit,(_undercoverUnit getVariable ["INC_AnyKnowsSO",false])]);

			_undercoverUnit globalChat (format ["Compromised radius multiplier: %1",(_undercoverUnit getVariable ["INC_compromisedValue",1])]);

			!(_undercoverUnit getVariable ["isUndercover",false])
		};

		_undercoverUnit globalChat (format ["%1 undercover status: %2",_undercoverUnit,(_undercoverUnit getVariable ["isUndercover",false])]);
	};
};

sleep 2;

//Run a low-impact version of the undercover script on group members (no proximity check)
if (_undercoverUnit isEqualTo (leader group _undercoverUnit)) then {
	[_undercoverUnit,_regEnySide,_asymEnySide] spawn {
		params ["_undercoverUnit","_regEnySide","_asymEnySide"];
		{
			if !(_x getVariable ["isSneaky",false]) then {
				sleep 0.2;
				[_x] remoteExecCall ["INCON_fnc_simpleArmedTracker",_undercoverUnit];
				sleep 0.2;
				[_x,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverDetect",_undercoverUnit];
				sleep 0.2;
				_x setVariable ["noChanges",true,true];
				_x setVariable ["isUndercover", true, true];
				sleep 0.2;
				[[_x,_undercoverUnit],"addConcealActions"] call INCON_fnc_civHandler;
			};
		} forEach units group _undercoverUnit;
	};
};

//Main loop
waitUntil {

	sleep 1;

	//Pause while the unit is compromised
	waitUntil {
		sleep 3;
		!(_undercoverUnit getVariable ["INC_undercoverCompromised",false]);
	};

	//wait until the unit is armed or trespassing
	waitUntil {
		sleep 3;
		((_undercoverUnit getVariable ["INC_armed",false]) || {_undercoverUnit getVariable ["INC_trespassing",false]});
	};

	//Once the player is doing naughty stuff, make them vulnerable to being compromised
	_undercoverUnit setVariable ["INC_suspicious", true]; //Hold the cooldown script until the unit is no longer doing naughty things
	[_undercoverUnit, false] remoteExec ["setCaptive", _undercoverUnit]; //Makes enemies hostile to the unit

	[_undercoverUnit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCooldown",_undercoverUnit]; //Gets the cooldown script going


	while {
		sleep 2;
		(((_undercoverUnit getVariable ["INC_armed",false]) || {(_undercoverUnit getVariable ["INC_trespassing",false])}) && {!(_undercoverUnit getVariable ["INC_undercoverCompromised",false])})
	} do {
		if (
			(_undercoverUnit getVariable ["INC_armed",false]) &&
			{(_undercoverUnit getVariable ["INC_trespassing",false])} &&
			{(_undercoverUnit getVariable ["INC_AnyKnowsSO",false])}
		) then {
			private _regAlerted = [_regEnySide,_undercoverUnit,50] call INCON_fnc_countAlerted;
			private _asymAlerted = [_asymEnySide,_undercoverUnit,50] call INCON_fnc_countAlerted;

			//Once people know exactly where he is, who he is, and that he is both armed and trespassing, make him compromised
			if ((_regAlerted != 0) || {(_asymAlerted != 0)}) exitWith {

				[_undercoverUnit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCompromised",_undercoverUnit];
			};
		};
	};

	//Then stop the holding variable and allow cooldown to commence
	_undercoverUnit setVariable ["INC_suspicious", false];

	sleep 2;

	//Wait until cooldown loop has finished
	waitUntil {
		sleep 2;
		!(_undercoverUnit getVariable ["INC_cooldown",false]);
	};

	(!(_undercoverUnit getVariable ["isUndercover",false]) || {!(alive _undercoverUnit)})

};

_undercoverUnit setVariable ["INC_undercoverHandlerRunning", false, true];
