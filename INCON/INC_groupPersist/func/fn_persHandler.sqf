/*

Group Persistence Handler

Author: Incontinentia

*/

params [["_input",objNull],["_mode","copy"],["_leader",objNull],["_dataBase",objNull]];

private ["_result"];

switch (_mode) do {

	case "copy": {

		private ["_unit"];

		_unit = _input;

		_unitType = typeOf _unit;

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
		_result = [_unitType,_unitName,_unitFace,_unitSpeaker,_unitLoadout,_unitDamage,_skillArray];
	};

	case "create": {

		_input params ["_unitType","_unitName","_unitFace","_unitSpeaker","_unitLoadout","_unitDamage","_skillArray"];

		private ["_pos","_newPos"];

		_pos = getPosWorld _leader;
		_newPos = ([_pos, 6] call CBA_fnc_randPos);

		_spawnedUnit = (group _leader) createUnit [_unitType,[0,0,0],[],0,""];
		_spawnedUnit setVariable ["noChanges",true,true];
		_spawnedUnit setPosWorld _newPos;

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

		[_spawnedUnit,_unitType,_unitName,_unitFace,_unitSpeaker,_unitLoadout,_unitDamage,_skillArray] spawn {
			params ["_unit","_unitType","_unitName","_unitFace","_unitSpeaker","_unitLoadout","_unitDamage","_skillArray"];

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
			_unitInfo = [_groupMember] call INCON_fnc_persHandler;
			_result pushBack _unitInfo;

		};
	};

	case "loadGroup": {

		for "_i" from 0 to ((count _input) - 1) do {

			private ["_groupMember","_unitInfo"];

			_result = [];

			_unitInfo = _input select _i;
			_groupMember = [_unitInfo,"create",_leader] call INCON_fnc_persHandler;
			_result pushBack _groupMember;

		};
	};

	case "saveGroupINIDB": {
		//Creates an array starting with a date float (select 0) and followed by encoded unit information

		private ["_unit","_float"];

		_unit = _input;

		_float = dateToNumber date;

		_result = [_float];

		for "_i" from 1 to ((count units group _unit) - 1) do {

			private ["_groupMember","_unitInfo"];

			if (count _result >= 6) exitWith {};

			_groupMember = (units group _unit) select _i;
			_unitInfo = [_groupMember] call INCON_fnc_persHandler;
			_encodedData = ["encodeBase64", (str _unitInfo)] call _database;
			_result pushBack _encodedData;

		};
	};

	case "loadGroupINIDB": {
		//From the group array, remove the date float and create the group
		//Returns the dateToNumber of the group

		_result = _input select 0;

		if (typeName _result == "SCALAR") then {_input deleteAt 0};

		{
			[_x,"createINIDB",_leader,_database] call INCON_fnc_persHandler;
		} forEach _input;
	};

	case "createINIDB": {
		//Decode unit's data and create that unit

		_input params ["_unitInfoEncoded"];
		_unitInfo = ["decodeBase64", _unitInfoEncoded] call _database;
		_groupMember = [(call compile _unitInfo),"create",_leader] call INCON_fnc_persHandler;

		_result = true;
	};

	case "saveAliveData": {
		if !(isDedicated) exitWith {};
		_input params ["_key","_value"];
		[_key, _value] call ALiVE_fnc_setData;
		_result = true;
	};

	case "loadAliveData": {
		if !(isDedicated) exitWith {};
		_input params ["_key"];
		_result = [_key] call ALiVE_fnc_getData;
	};
};

_result;
