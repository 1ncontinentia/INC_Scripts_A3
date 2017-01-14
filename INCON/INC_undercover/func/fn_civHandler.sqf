/*

Civilian Recruitment / Arming

Author: Incontinentia

*/


params [["_input",objNull],["_operation","addConcealedRifle"]];

private ["_return"];

#include "..\UCR_setup.sqf"

switch (_operation) do {

	case "spawnRebelCommander": {
		
		private ["_commander","_rebelGroup"];

		//private _rebelCommander = format ["INC_rebelCommander"];

		if (missionNamespace getVariable ["INC_rebelCommanderSpawned",false]) exitWith {};

		private _rebelGroup = [[(random 40),(random 40),10], _undercoverUnitSide, 1] call BIS_fnc_spawnGroup;
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

		missionNamespace setVariable ["INC_rebelCommanderSpawned",true,true];

		missionNamespace setVariable ["INC_rebelCommander",_commander,true];

		_return = _commander;

	};

	case "getCompatMags": {

		_input params ["_weapon"];

		private _configEntry = configFile >> "CfgWeapons" >> _weapon;
		private _result = [];
		{
			_result pushBack (
				if (_x == "this") then {
					getArray(_configEntry >> "magazines")
				}
			);
		} forEach getArray(_configEntry >> "muzzles");

		_return = _result select 0;
	};

	case "addBackpack": {

		_input params ["_unit"];

		_unit addBackpack (selectRandom _civPackArray);
		unitBackpack _unit setVariable ["owner",_unit,true];

		[(unitBackpack _unit), {
			_this addEventHandler ["ContainerOpened", {
				_backpack  = _this select 0;
				_civ = _backpack getVariable "owner";
				private _civComment = selectRandom ["Get the fuck out of my backpack","What are you doing?","Leave me alone!","Get out!","What are you playing at?"];
				[[_civ, _civComment] remoteExec ["globalChat",0]];
				[[_civ,"runAway"] remoteExecCall ["INCON_fnc_civHandler",_civ]];
				}
			];
		}] remoteExec ["call", 0,true];

		_return = unitBackpack _unit;
	};

	case "addWeapon": {

		_input params ["_unit"];

		private _wpn = selectRandom _civWpnArray;
		private _magsArray = ([_wpn,"getCompatMags"] call INCON_fnc_civHandler);

		_return = true;

		if (_unit canAddItemToUniform _wpn) then {
			_unit addItemToUniform _wpn;
			_unit addMagazine (selectRandom _magsArray);
			for "_i" from 1 to (ceil random 5) do {
				_unit addMagazine (selectRandom _magsArray);
			};

		} else {

			if (_unit canAddItemToBackpack _wpn) then {

				_unit addMagazine (selectRandom _magsArray);
				_unit addItemToBackpack _wpn;
				for "_i" from 1 to (ceil random 8) do {
					_unit addMagazine (selectRandom _magsArray);
				};

			} else {

				_return = false;
			};
		};
	};

	case "addItems": {

		for "_i" from 0 to (round (random 3)) do {
			private _itemToAdd = selectRandom _civItemArray;
			_unit addItem _itemToAdd;
		};

		_return = true;
	};

	case "runAway": {

		_input params ["_unit"];

		_unit doMove [
			(getPosASL _unit select 0) + (5 + (random 3) - (random 16)),
			(getPosASL _unit select 1) + (5 + (random 3)),
			getPosASL _unit select 2
		];
		_return = true;
	};

	case "addConcealActions": {

		_input params ["_recruitedCiv","_undercoverUnit",["_dismiss",true]];

		if ((_dismiss) || {(_recruitedCiv getVariable ["INC_notDismissable",false])}) then {

			[_recruitedCiv, [
				"<t color='#9933FF'>Dismiss</t>", {

					private _recruitedCiv = _this select 0;
					private _civComment = selectRandom ["I'll just hang around here then I suppose.","My back is killing me anyway.","It's been a pleasure.","I'm just not cut out for this.","I'll continue our good work.","See you later.","I don't need you to have a good time.","I'm my own woman.","What time is it? I need to get high.","I've got some paperwork to do anyway.","Well thank God for that."];
					[[_recruitedCiv, _civComment] remoteExec ["globalChat",0]];

					[_recruitedCiv] join grpNull;
					_recruitedCiv remoteExec ["removeAllActions",0];
					_recruitedCiv setVariable ["isUndercover", false, true];

					_wp1 = (group _recruitedCiv) addWaypoint [(getPosWorld _recruitedCiv), 3];
					(group _recruitedCiv) setBehaviour "SAFE";
					_wp1 setWaypointType "DISMISS";

				},[],5.9,false,true,"","((_this == _target) && (_this getVariable ['isUndercover',false]))"
			]] remoteExec ["addAction", _undercoverUnit];
		} else {
			_recruitedCiv setVariable ["INC_notDismissable",true];
		};

		[_recruitedCiv, [

			"<t color='#334FFF'>Hide current weapon</t>", {

				params ["_unit"];
				private ["_wpn","_ammoCount","_mag","_magazineCount","_weaponArray"];

				_wpn = currentWeapon _unit;
				_mag = currentMagazine _unit;
				_ammoCount = _unit ammo (currentWeapon _unit);

				if (_unit canAddItemToUniform _wpn) then {

					_unit addItemToUniform _wpn;
					_unit addMagazine _mag;
					_unit removeWeaponGlobal _wpn;

				} else {

					if (_unit canAddItemToBackpack _wpn) then {

						_unit addItemToBackpack _wpn;
						_mag = currentMagazine _unit;
						_unit removeWeaponGlobal _wpn;

					};
				};

				_weaponArray = [_wpn,_ammoCount,_mag];

				_unit setVariable ["INC_weaponStore",_weaponArray];
				_unit setVariable ["INC_weaponStoreActive",true];

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {
					_unit call ace_weaponselect_fnc_putWeaponAway;
				};

			},[],6,false,true,"","(_this == _target) && {!((currentWeapon _this == 'Throw') || (currentWeapon _this == ''))} && {(_this canAddItemToUniform (currentWeapon _this)) || (_this canAddItemToBackpack (currentWeapon _this))}"

		]] remoteExec ["addAction", _undercoverUnit];

		[_recruitedCiv, [

			"<t color='#FF33BB'>Get concealed weapon out</t>", {

				params ["_unit"];
				private ["_wpn","_ammoCount","_mag","_magazineCount","_weaponArray"];

				_weaponArray = (_unit getVariable ["INC_weaponStore",[]]);

				if (!(_weaponArray isEqualTo []) && {((_weaponArray select 0) in weapons _unit)}) then {
					_wpn = _weaponArray select 0;
					_ammoCount = _weaponArray select 1;
					_mag = _weaponArray select 2;
					_unit removeItem _wpn;
				} else {
					_wpn = selectRandom (weapons _unit);
					_ammoCount = 500;
					_mag = selectRandom ([_wpn,"getCompatMags"] call INCON_fnc_civHandler);
					_unit removeItem _wpn;
				};

				_unit addMagazine _mag;
				_unit addWeapon _wpn;
				_unit setAmmo [_wpn,_ammoCount];
				_unit setVariable ["INC_weaponStoreActive",false];

			},[],6,false,true,"","((_this == _target) && {((currentWeapon _this == 'Throw') || (currentWeapon _this == ''))} && {!((weapons _this) isEqualTo [])})"

		]] remoteExec ["addAction", _undercoverUnit];

		_return = true;
	};

	case "profileGroup": {

		if (!(isClass(configFile >> "CfgPatches" >> "ALiVE_main")) || {!isServer}) exitWith {_return = grpNull};

		_input params ["_undercoverUnit"];

		private ["_originalGroup","_newGroup","_nonPlayableArray","_playableArray"];

		_originalGroup = group _undercoverUnit;

		_newGroup = createGroup _undercoverUnitSide;

		_nonPlayableArray = [];

		_playableArray = [];

		{
			if ((_x != leader group _x) && {!(_x in playableUnits)} && {!(_x getVariable ["INC_notDismissable",false])} && {count _nonPlayableArray <= 4}) then {
				_nonPlayableArray pushback _x;
				_x setCaptive false;
			};
		} forEach units _originalGroup;

		_return = [_newGroup,_playableArray,_nonPlayableArray];

		_nonPlayableArray join _newGroup;

		[_newGroup] spawn {
			params ["_newGroup"];

			sleep 5;

			{_x setCaptive false} forEach (units _newGroup);

			sleep 2;

			["",[],false,[_newGroup]] call ALiVE_fnc_CreateProfilesFromUnits;
		};
	};

	case "recruitSuccess": {

		_input spawn {

			params ["_civ","_undercoverUnit"];

			private ["_unitType","_civPos","_prevGroup","_civFace","_civSpeaker","_civHeadgear","_civName"];

			_civLoadout = getUnitLoadout _civ;

			sleep 0.1;

			_unitType =  (selectRandom (["units",[(faction _undercoverUnit)]] call INCON_fnc_getFactionGear));

			sleep 0.2;

			_civPos = getPosWorld _civ;
			_prevGroup = group _civ;
			_civFace = face _civ;
			_civSpeaker = speaker _civ;
			_civHeadgear = selectRandom ["H_Shemag_olive","H_ShemagOpen_tan","H_ShemagOpen_khk"];
			_civName = name _civ;
			deleteVehicle _civ;

			_skill = (0.7 + (random 0.25));

			_recruitedCiv = (group _undercoverUnit) createUnit [_unitType,[0,0,0],[],0,""];
			_recruitedCiv setVariable ["noChanges",true,true];
			_recruitedCiv setVariable ["isUndercover", true, true];

			_recruitedCiv setPosWorld _civPos;
			_recruitedCiv setUnitAbility _skill;

			_recruitedCiv setUnitLoadout _civLoadout;

			if ((count units _prevGroup) == 0) then {
				deleteGroup _prevGroup;
			};

			[_recruitedCiv,_civLoadout,_civHeadgear,_civFace,_civName,_civSpeaker,_undercoverUnit] spawn {
				params ["_recruitedCiv","_civLoadout","_civHeadgear","_civFace","_civName","_civSpeaker","_undercoverUnit"];

				sleep 0.1;

				[_recruitedCiv, _civFace] remoteExec ["setFace", 0];
				[_recruitedCiv, _civName] remoteExec ["setName", 0];
				[_recruitedCiv, _civSpeaker] remoteExec ["setSpeaker", 0];

				_recruitedCiv setUnitLoadout _civLoadout;

				sleep 0.3;

				_recruitedCiv remoteExec ["removeAllActions",0];
				removeHeadgear _recruitedCiv;

				_recruitedCiv setUnitLoadout _civLoadout;

				sleep 0.1;

				_recruitedCiv addHeadgear _civHeadgear;

				_recruitedCiv setUnitLoadout _civLoadout;

				sleep 1;

				[[_recruitedCiv,_undercoverUnit],"addConcealActions"] call INCON_fnc_civHandler;
				[_recruitedCiv] remoteExecCall ["INCON_fnc_undercoverInit",_undercoverUnit];

				_recruitedCiv setCombatMode "GREEN";
			};
		};
		_return = true;
	};
};

_return
