/*

Civilian Recruit Success

Author: Incontinentia

*/

params [["_input",objNull],["_mode","copy"],["_leader",objNull],["_dataBase",objNull]];

private ["_result"];

switch (_mode) do {

	case "copy": {

		private ["_unit"];

		_unit = _input;

		_unitType = typeOf _unit;
		_unitPos = getPosWorld _unit;

		_unitName = name _unit;
		_unitFace = face _unit;
		_unitSpeaker = speaker _unit;

		_unitLoadout = [_unit,"script",false] call INCON_fnc_exportLoadout;

		_unitLoadout = [_unitLoadout, """", "'"] call CBA_fnc_replace;

		_unitDamage = damage _unit;

		_skillArray = [
			(_unit skill "aimingAccuracy"),
			(_unit skill "aimingShake"),
			(_unit skill "aimingSpeed"),
			(_unit skill "endurance"),
			(_unit skill "spotDistance"),
			(_unit skill "spotTime"),
			(_unit skill "courage"),
			(_unit skill "reloadSpeed"),
			(_unit skill "commanding"),
			(_unit skill "general")
		];
		_result = [_unitType,_unitPos,_unitName,_unitFace,_unitSpeaker,_unitLoadout,_unitDamage,_skillArray];
	};

	case "create": {

		_input params ["_unitType","_unitPos","_unitName","_unitFace","_unitSpeaker","_unitLoadout","_unitDamage","_skillArray"];

		_spawnedUnit = (group _leader) createUnit [_unitType,[0,0,0],[],0,""];
		_spawnedUnit setVariable ["noChanges",true,true];
		_spawnedUnit setPosWorld _unitPos;

		_skillArray params ["_unitAccuracy","_unitAimshake","_unitAimingSpeed","_unitEndurance","_unitSpotDistance","_unitSpotTime","_unitCourage","_unitReloadSpeed","_unitCommanding","_unitGeneral"];
		_spawnedUnit setSkill ["aimingAccuracy",_unitAccuracy];
		_spawnedUnit setSkill ["aimingShake",_unitAimshake];
		_spawnedUnit setSkill ["aimingSpeed",_unitAimingSpeed];
		_spawnedUnit setSkill ["endurance",_unitEndurance];
		_spawnedUnit setSkill ["spotDistance",_unitSpotDistance];
		_spawnedUnit setSkill ["spotTime",_unitSpotTime];
		_spawnedUnit setSkill ["courage",_unitCourage];
		_spawnedUnit setSkill ["reloadSpeed",_unitReloadSpeed];
		_spawnedUnit setSkill ["commanding",_unitCommanding];
		_spawnedUnit setSkill ["general",_unitGeneral];

		[_spawnedUnit, _unitName] remoteExec ["setName", 0];
		[_spawnedUnit, _unitFace] remoteExec ["setFace", 0];
		[_spawnedUnit, _unitSpeaker] remoteExec ["setSpeaker", 0];

		[_spawnedUnit] call compile _unitLoadout;

		[_spawnedUnit,_unitType,_unitPos,_unitName,_unitFace,_unitSpeaker,_unitLoadout,_unitDamage,_skillArray] spawn {
			params ["_unit","_unitType","_unitPos","_unitName","_unitFace","_unitSpeaker","_unitLoadout","_unitDamage","_skillArray"];

			sleep 0.1;

			[_unit] call compile _unitLoadout;

			sleep 0.1;

			[_unit, _unitName] remoteExec ["setName", 0];
			[_unit, _unitFace] remoteExec ["setFace", 0];
			[_unit, _unitSpeaker] remoteExec ["setSpeaker", 0];

			sleep 0.1;

			_unit setDamage _unitDamage;

		};

		_result = _spawnedUnit;
	};

	case "saveGroup": {

		private ["_unit"];

		_unit = _input;

		_result = [];

		for "_i" from 1 to ((count units group _unit) - 1) do {

			private ["_groupMember","_unitInfo"];

			_groupMember = (units group _unit) select _i;
			_unitInfo = [_groupMember] call INCON_fnc_unitPersist;
			_result pushBack _unitInfo;

		};
	};

	case "loadGroup": {

		for "_i" from 0 to ((count _input) - 1) do {

			private ["_groupMember","_unitInfo"];

			_result = [];

			_unitInfo = _input select _i;
			_groupMember = [_unitInfo,"create",_leader] call INCON_fnc_unitPersist;
			_result pushBack _groupMember;

		};
	};

	case "saveGroupINIDB": {

		private ["_unit"];

		_unit = _input;

		_result = [];

		for "_i" from 1 to ((count units group _unit) - 1) do {

			private ["_groupMember","_unitInfo"];

			if (_i >= 5) exitWith {};

			_groupMember = (units group _unit) select _i;
			_unitInfo = [_groupMember] call INCON_fnc_unitPersist;
			_encodedData = ["encodeBase64", (str _unitInfo)] call _database;
			_result pushBack _encodedData;

		};
	};

	case "loadGroupINIDB": {

		{
			[_x,"createINIDB",_leader,_database] call INCON_fnc_unitPersist;
		} forEach _input;

		_result = true;
	};

	case "createINIDB": {

		_input params ["_unitInfoEncoded"];
		_unitInfo = ["decodeBase64", _unitInfoEncoded] call _database;
		_groupMember = [(call compile _unitInfo),"create",_leader] call INCON_fnc_unitPersist;

		_result = true;
	};
};

_result;
