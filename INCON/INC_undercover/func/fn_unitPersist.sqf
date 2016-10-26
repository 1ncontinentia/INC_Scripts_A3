/*

Civilian Recruit Success

Author: Incontinentia

*/

params ["_unit",["_leader",objNull],["_mode","copy"],["_unitInfoArray",[]]];

private ["_result"];

_setSkill = {
	params ["_unit","_skillArray"];
	_skillArray params [_unitAccuracy,_unitAimshake,_unitAimingSpeed,_unitEndurance,_unitSpotDistance,_unitSpotTime,_unitCourage,_unitReloadSpeed,_unitCommanding,_unitGeneral];
	_unit setSkill ["aimingAccuracy",_unitAccuracy];
	_unit setSkill ["aimingShake",_unitAimshake];
	_unit setSkill ["aimingSpeed",_unitAimingSpeed];
	_unit setSkill ["endurance",_unitEndurance];
	_unit setSkill ["spotDistance",_unitSpotDistance];
	_unit setSkill ["spotTime",_unitSpotTime];
	_unit setSkill ["courage",_unitCourage];
	_unit setSkill ["reloadSpeed",_unitReloadSpeed];
	_unit setSkill ["commanding",_unitCommanding];
	_unit setSkill ["general",_unitGeneral];

};

switch (_mode) do {
	case "copy": {

		_unitVarName = _unit;
		_unitType = typeOf _unit;
		_unitPos = getPosWorld _unit;

		_unitName = name _unit;
		_unitFace = face _unit;
		_unitSpeaker = speaker _unit;

		_unitLoadout = [_unit,"script",false] call BIS_fnc_exportInventory;


		_unitDamage = damage _unit;
		_skillArray = [(_unit skill "aimingAccuracy"),(_unit skill "aimingShake"),(_unit skill "aimingSpeed"),(_unit skill "endurance"),(_unit skill "spotDistance"),(_unit skill "spotTime"),(_unit skill "courage"),(_unit skill "reloadSpeed"),(_unit skill "commanding"),(_unit skill "general")];
		_result = [_unitVarName,_unitType,_unitPos,_unitName,_unitFace,_unitSpeaker,_unitLoadout,_unitDamage,_skillArray];
	};

	case "set": {

		private _unit = _unitInfoArray select 0;
		private _spawnedUnitType = _unitInfoArray select 1;
		private _spawnedUnitPos = _unitInfoArray select 2;
		private _skillArray = _unitInfoArray select 8;

		_unit = (group _leader) createUnit [_spawnedUnitType,[0,0,0],[],0,""];
		_unit setVariable ["noChanges",true,true];
		_unit setPosWorld _spawnedUnitPos;

		[_unit,_skillArray] call _setSkill;



		_unitInfoArray spawn {
			params ["_unit","_unitType","_unitPos","_unitName","_unitFace","_unitSpeaker","_unitLoadout","_unitDamage","_skillArray"];

			_unit call compile {_unitLoadout};

			sleep 0.1;

			[_unit, _unitName] remoteExec ["setName", 0];
			[_unit, _unitFace] remoteExec ["setFace", 0];
			[_unit, _unitSpeaker] remoteExec ["setSpeaker", 0];

			sleep 0.1;

			_unit setDamage _unitDamage;

		};
	};
};

_result;
