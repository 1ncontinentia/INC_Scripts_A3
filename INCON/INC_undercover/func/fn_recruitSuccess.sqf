params ["_civ","_undercoverUnit"];

private ["_civPos","_prevGroup","_civUnitorm","_civFace","_civSpeaker","_civHeadgear","_civRifle","_civBackpack","_civName","_civType"];

_civPos = getPosWorld _civ;
_prevGroup = group _civ;
_civFace = face _civ;
_civSpeaker = speaker _civ;
_civHeadgear = selectRandom ["H_Shemag_olive","H_ShemagOpen_tan","H_ShemagOpen_khk"];
_civName = name _civ;
_civType = typeOf _civ;
deleteVehicle _civ;

_skill = (0.7 + (random 0.25));

_unitType = typeOf _undercoverUnit;
_civLoadout = getUnitLoadout _civ;

_recruitedCiv = (group _undercoverUnit) createUnit [_unitType,[0,0,0],[],0,""];
_recruitedCiv setVariable ["noChanges",true,true];
_recruitedCiv setVariable ["isUndercover", true, true];

_recruitedCiv setPosWorld _civPos;
_recruitedCiv setUnitAbility _skill;

if ((count units _prevGroup) == 0) then {
	deleteGroup _prevGroup;
};

[_recruitedCiv,_civLoadout,_civHeadgear,_civFace,_civName,_civSpeaker,_undercoverUnit] spawn {
	params ["_recruitedCiv","_civLoadout","_civHeadgear","_civFace","_civName","_civSpeaker","_undercoverUnit"];

	sleep 0.1;

	_recruitedCiv setUnitLoadout _civLoadout;

	sleep 0.1;

	[_recruitedCiv, _civFace] remoteExec ["setFace", 0];
	[_recruitedCiv, _civName] remoteExec ["setName", 0];
	[_recruitedCiv, _civSpeaker] remoteExec ["setSpeaker", 0];

	sleep 0.3;

	_recruitedCiv remoteExec ["removeAllActions",0];
	removeHeadgear _recruitedCiv;

	sleep 0.1;

	_recruitedCiv addHeadgear _civHeadgear;

	sleep 1;

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

				};
			};

			_weaponArray = [_wpn,_ammoCount,_mag];

			_unit setVariable ["INC_weaponStore",_weaponArray];
			_unit setVariable ["INC_weaponStoreActive",true];

			if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {
				_unit call ace_weaponselect_fnc_putWeaponAway;
			};

		},[],6,false,true,"","(_this == _target) && !{(currentWeapon _this == 'Throw') || (currentWeapon _this == '')} && {(_this canAddItemToUniform (currentWeapon _this)) || (_this canAddItemToBackpack (currentWeapon _this))}"

	]] remoteExec ["addAction", _undercoverUnit];

	[_recruitedCiv, [

		"<t color='#FF33BB'>Get concealed weapon out</t>", {

			params ["_unit"];
			private ["_wpn","_ammoCount","_mag","_magazineCount","_weaponArray"];

			_weaponArray = (_unit getVariable ["INC_weaponStore",[]]);

			if ((_weaponArray != []) && {((_weaponArray select 0) in weapons _unit)}) then {
				_wpn = _weaponArray select 0;
				_ammoCount = _weaponArray select 1;
				_mag = _weaponArray select 2;
			} else {
				_wpn = selectRandom (weapons _unit);
				_ammoCount = 500;
				_mag = selectRandom ([_wpn,"getCompatMags"] call INCON_fnc_civHandler);
			};

			_unit addMagazine _mag;
			_unit addWeapon _wpn;
			_unit setAmmo [_wpn,_ammoCount];
			_unit setVariable ["INC_weaponStoreActive",false];

		},[],6,false,true,"","((_this == _target) && {((currentWeapon _this == 'Throw') || (currentWeapon _this == ''))} && {(weapons _unit != [])})"

	]] remoteExec ["addAction", _undercoverUnit];

	[_recruitedCiv] remoteExecCall ["INCON_fnc_simpleArmedTracker",_undercoverUnit];

	[_recruitedCiv] remoteExecCall ["INCON_fnc_undercoverDetect",_undercoverUnit];

};

_recruitedCiv setCombatMode "GREEN";

_recruitedCiv
