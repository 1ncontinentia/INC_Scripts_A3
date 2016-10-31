params ["_civ","_undercoverUnit"];

private ["_civPos","_civUnitorm","_civFace","_civSpeaker","_civHeadgear","_civRifle","_civBackpack","_civName","_civType"];

_civPos = getPosWorld _civ;

_civFace = face _civ;
_civSpeaker = speaker _civ;
_civHeadgear = selectRandom ["H_Shemag_olive","H_ShemagOpen_tan","H_ShemagOpen_khk"];
_civName = name _civ;
_civType = typeOf _civ;
deleteVehicle _civ;
_skill = (0.7 + (random 0.25));
_unitType = typeOf _undercoverUnit;
_civLoadout = [_unit,"script",false] call INCON_fnc_getLoadout;
_civLoadout = [_civLoadout, """", "'"] call CBA_fnc_replace;

_recruitedCiv = (group _undercoverUnit) createUnit [_unitType,[0,0,0],[],0,""];
_recruitedCiv setVariable ["noChanges",true,true];
_recruitedCiv setVariable ["isUndercover", true, true];

_recruitedCiv setPosWorld _civPos;
_recruitedCiv setUnitAbility _skill;

[_recruitedCiv,_civLoadout,_civHeadgear,_civFace,_civName,_civSpeaker,_undercoverUnit] spawn {
	params ["_recruitedCiv","_civLoadout","_civHeadgear","_civFace","_civName","_civSpeaker","_undercoverUnit"];

	sleep 0.1;

	[_recruitedCiv] call compile _civLoadout;

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
			private _civComment = selectRandom ["I'll just hang around here then I suppose","My back is killing me anyway.","It's been a pleasure.","I'm just not cut out for this.","I'll continue our good work.","Ah well, I've got better things to do","I don't need you to have a good time.","I'm my own woman.","What time is it? I need to get high.","I've got some paperwork to do anyway.","Well thank God for that."];
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

		"<t color='#334FFF'>Conceal weapon</t>", {

			params ["_unit"];
			private ["_weaponType","_ammoCount","_mag","_magazineCount","_weaponArray"];

			_weaponType = currentWeapon _unit;

			if ((_weaponType == "") || {_weaponType == "Throw"}) exitWith {
				private _civComment = selectRandom ["I'm unarmed, let's find a weapon.","I need to find a weapon.","I've got no weapon."];
				[[_unit, _civComment] remoteExec ["globalChat",0]];
			};

			_ammoCount = _unit ammo (currentWeapon _unit);
			_mag = currentMagazine _unit;
			_weaponArray = [_weaponType,_ammoCount,_mag];

			_unit setVariable ["INC_weaponStore",_weaponArray,true];
			_unit setVariable ["INC_weaponStoreActive",true,true];
			_unit removeWeaponGlobal _weaponType;
			_unit call ace_weaponselect_fnc_putWeaponAway;

		},[],6,false,true,"","((_this == _target) && !((currentWeapon _this == 'Throw') || (currentWeapon _this == '')))"

	]] remoteExec ["addAction", _undercoverUnit];

	[_recruitedCiv, [

		"<t color='#FF33BB'>Get concealed weapon out</t>", {

			params ["_unit"];
			private ["_weaponType","_ammoCount","_mag","_magazineCount","_weaponArray"];

			_weaponArray = _unit getVariable ["INC_weaponStore",[]];
			_weaponType = _weaponArray select 0;
			_ammoCount = _weaponArray select 1;
			_mag = _weaponArray select 2;
			_unit addMagazine _mag;
			_unit addWeapon _weaponType;
			_unit setAmmo [_weaponType,_ammoCount];
			_unit setVariable ["INC_weaponStoreActive",false,true];

			if ((_weaponType == "") || (_weaponType == "Throw")) then {

				private _civComment = selectRandom ["I'm unarmed, let's find a weapon.","I need to find a weapon.","I've got no weapon."];
				[[_unit, _civComment] remoteExec ["globalChat",0]];

			};

		},[],6,false,true,"","((_this == _target) && ((currentWeapon _this == 'Throw') || (currentWeapon _this == '')) && (_this getVariable ['weaponStoreActive',false]))"

	]] remoteExec ["addAction", _undercoverUnit];

	//[_recruitedCiv] call INCON_fnc_simpleArmedTracker;

	//[_recruitedCiv] call INCON_fnc_undercoverDetect;

	[_recruitedCiv] remoteExecCall ["INCON_fnc_simpleArmedTracker",_undercoverUnit];

	[_recruitedCiv] remoteExecCall ["INCON_fnc_undercoverDetect",_undercoverUnit];

	if !(_civUnarmed) then {

		if !(_civRifle) then {

			_recruitedCiv addMagazine "16Rnd_9x21_Mag";
			_recruitedCiv addMagazine "16Rnd_9x21_Mag";
			_recruitedCiv addMagazine "16Rnd_9x21_Mag";
			_recruitedCiv addMagazine "16Rnd_9x21_Mag";
			_recruitedCiv addWeapon "hgun_Rook40_F";

		} else {

			_recruitedCiv addMagazine "30Rnd_545x39_Mag_Green_F";
			_recruitedCiv addMagazine "30Rnd_545x39_Mag_Green_F";
			_recruitedCiv addMagazine "30Rnd_545x39_Mag_Green_F";
			_recruitedCiv addMagazine "30Rnd_545x39_Mag_Green_F";
			_recruitedCiv addWeapon "arifle_AKS_F";

		};

	};

};

_recruitedCiv setCombatMode "GREEN";

_recruitedCiv
