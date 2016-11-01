/*

Civilian Recruitment / Arming

Author: Incontinentia

*/


params [["_unit",objNull],["_armedCivPercentage",70]];

if (_unit getVariable ["isPrisonGuard",false]) exitWith {};

[_unit, [
	"<t color='#33FFEC'>Recruit</t>", {
		params ["_civ","_undercoverUnit"];

		if !((currentWeapon _undercoverUnit == "") || (currentWeapon _undercoverUnit == "Throw")) exitWith {
		    private _civComment = selectRandom ["Put your weapon away.","Get that thing out of my face","I don't like being threatened.","Put your gun away."];
		    [[_civ, _civComment] remoteExec ["globalChat",0]];
		};

		[_civ, _undercoverUnit] remoteExecCall ["INCON_fnc_recruitAttempt",_civ];

		_civ setVariable ["INC_alreadyTried",true,true];

	},[],6,true,true,"","((alive _target) && {(_this getVariable ['isUndercover',false])} && {!(_target getVariable ['INC_alreadyTried',false])})",4
]] remoteExec ["addAction", 0];


if (_armedCivPercentage > (random 100)) exitWith {

	if (70 > (random 100)) then {
		[_unit,"addBackpack"] call INCON_fnc_civHandler;
	};

	[_unit,"addWeapon"] call INCON_fnc_civHandler;
};
