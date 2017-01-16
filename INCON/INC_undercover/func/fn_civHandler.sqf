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

		[_recruitedCiv, [

			"<t color='#334FFF'>Hide current weapon</t>", {

				params ["_unit"];
				private ["_visibleWeapons"];

				if !((currentWeapon _unit == primaryWeapon _unit) || {currentWeapon _unit == primaryWeapon _unit}) exitWith {};

				private ["_wpn","_ammoCount","_mag","_items","_weaponArray"];

				_wpn = currentWeapon _unit;
				//if (currentWeapon _unit == primaryWeapon _unit) then {_items = primaryWeaponItems _unit} else {_items = handgunItems _unit};

				sleep 0.5;

				if (_unit canAddItemToUniform _wpn) then {
					_unit action ["DropWeapon", uniformContainer _unit, currentWeapon _unit];

				} else {

					if (_unit canAddItemToBackpack _wpn) then {
						_unit action ["DropWeapon", unitBackpack _unit, currentWeapon _unit];
					};
				};

			},[],6,false,true,"","(_this == _target) && {!((currentWeapon _this == 'Throw') || (currentWeapon _this == ''))} && {(_this canAddItemToUniform (currentWeapon _this)) || (_this canAddItemToBackpack (currentWeapon _this))}"

		]] remoteExec ["addAction", _undercoverUnit];

		[_recruitedCiv, [

			"<t color='#FF33BB'>Get concealed weapon out</t>", {

				params ["_unit"];
				private ["_wpn","_weapons"];

				_weapons = [];

				{
					if (_x isKindOf ["Rifle", configFile >> "CfgWeapons"]) then {
						_weapons pushBack _x;
					};
				} forEach (weapons _unit);

				if (_weapons isEqualTo []) then {
					{
						if (_x isKindOf ["Pistol", configFile >> "CfgWeapons"]) then {
							_weapons pushBack _x;
						};
					} forEach (weapons _unit);
				};

				if (_weapons isEqualTo []) exitWith {};

				_wpn = selectRandom _weapons;

				_activeContainer = weaponsitemscargo unitBackpack _unit;

				if ((uniformItems _unit) find _wpn >= 0) then {_activeContainer = weaponsitemscargo uniformContainer _unit};

				_weapon = (_activeContainer select {(_x select 0) == _wpn}) select 0;

				_unit removeItem (_weapon select 0);
				_unit addWeapon (_weapon select 0);

				if (primaryWeapon _unit == (_weapon select 0)) exitWith {
					_unit addPrimaryWeaponItem (_weapon select 1);
					_unit addPrimaryWeaponItem (_weapon select 2);
					_unit addPrimaryWeaponItem (_weapon select 3);
					_unit addPrimaryWeaponItem (_weapon select 5);
					if ((_weapon select 4 select 0) != "") then {
						_unit addMagazine (_weapon select 4 select 0);
						_unit setAmmo [(primaryWeapon _unit), (_weapon select 4 select 1)];
					};
				};


				_unit addHandgunItem (_weapon select 1);
				_unit addHandgunItem (_weapon select 2);
				_unit addHandgunItem (_weapon select 3);
				_unit addHandgunItem (_weapon select 5);
				if ((_weapon select 4 select 0) != "") then {
					_unit addMagazine (_weapon select 4 select 0);
					_unit setAmmo [(primaryWeapon _unit), (_weapon select 4 select 1)];
				};

			},[],6,false,true,"","((_this == _target) && {((currentWeapon _this == 'Throw') || (currentWeapon _this == ''))} && {!((weapons _this) isEqualTo [])})"

		]] remoteExec ["addAction", _undercoverUnit];

		if (!isPlayer _recruitedCiv) then {
			[[_recruitedCiv,false],"SwitchUniformAction"] call INCON_fnc_civHandler;
		} else {

			_recruitedCiv addEventHandler ["InventoryClosed", {
				params ["_unit"];
				if ([[_unit,false],"switchUniforms"] call INCON_fnc_civHandler) then {
					[[_unit,true,5],"SwitchUniformAction"] call INCON_fnc_civHandler;
				};
			}]
		};

		if ((_dismiss) || {!(_recruitedCiv getVariable ["INC_notDismissable",false])}) then {

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

				},[],5.8,false,true,"","((_this == _target) && (_this getVariable ['isUndercover',false]))"
			]] remoteExec ["addAction", _undercoverUnit];
		} else {
			_recruitedCiv setVariable ["INC_notDismissable",true];
		};

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
				[[_recruitedCiv],"INCON\INC_undercover\initUCR.sqf"] remoteExec ["execVM",_undercoverUnit];
				//[_recruitedCiv] remoteExecCall ["INCON_fnc_undercoverInit",_undercoverUnit];

				_recruitedCiv setCombatMode "GREEN";
			};
		};
		_return = true;
	};

	case "SwitchUniformAction": {

		_input params ["_unit",["_temporary",true],["_duration",10]];

		if (_unit getVariable ["INC_switchUniformActionActive",false]) exitWith {_return = false};

		_unit setVariable ["INC_switchUniformActionActive",true];

		INC_switchUniformAction = _unit addAction [
			"<t color='#33FF42'>Change uniform</t>", {
				params ["_unit"];

				private ["_success"];

				_success = [[_unit,true],"switchUniforms"] call INCON_fnc_civHandler;

				if (_success) then {
					if (!isPlayer _unit) then {
						private _comment = selectRandom ["Ah, yes.","Got something","This'll do","Found some new clothes.","Does my bum look big in this?","Fits nicely.","It's almost as if we're all the same dimensions.","Fits like a glove.","Beautiful.","I look like an idiot."];
						_unit groupChat _comment;
					} else {hint "Uniform changed."};
				} else {
					if (!isPlayer _unit) then {
						private _comment = selectRandom ["Which one?","I'm not sure where you want me to look.","Can you point it out a bit better?"];
						_unit groupChat _comment;
					} else {hint "No safe uniforms found nearby."};
				};

			},[],5.9,false,true,"","((_this == _target) && (_this getVariable ['isUndercover',false]))"
		];

		if (_temporary) then {

			[_unit,_duration] spawn {

				params ["_unit",["_duration",10]];
				sleep _duration;
				_unit removeAction INC_switchUniformAction;

				_unit setVariable ["INC_switchUniformActionActive",false];

			};
		};

		_return = true;
	};

	case "switchUniforms": {

		_input params ["_unit",["_switchUniform",true],["_attempt",1],["_autoReAttempt",true]];

		private ["_activeContainer","_newUnif","_origUnif","_newUnifItems","_droppedUniform","_containerArray"];

		_containerArray = [];

		if (_attempt <= 1) then {_containerArray = (nearestObjects [_unit, ["GroundWeaponHolder"],5])};

		if ((count _containerArray == 0) && {_attempt <= 2}) then {_attempt = 2; _containerArray = (_unit nearEntities [["Car","Truck","Motorcycle","Tank"],5])};

		if ((count _containerArray == 0) && {_attempt <= 3}) then {_attempt = 3; _containerArray =  (nearestObjects [_unit, ["ReammoBox_F"],5])};

		if (count _containerArray == 0) exitWith {_return = false};

		_activeContainer = (_containerArray select 0);

		_origUnif = uniform _unit;
		_origUnifItems = uniformItems _unit;

		_newUnif = (((everyContainer _activeContainer) select {
		    (
				(
					(((_x select 0) find "U_") >= 0) ||
					{(((_x select 0) find "uniform") >= 0)} ||
					{(((_x select 0) find "Uniform") >= 0)}
				) &&
				{
					!(((_x select 0) find _origUnif) == 0) ||
					{_origUnif == ""}
				} &&
				{(_x select 0) in (INC_safeUniforms + INC_incognitoUniforms)}
			)
		}) select 0);

		if (isNil "_newUnif") exitWith {
			_return = false;
			if (_autoReAttempt && {_attempt <= 2}) then {
				_return = [[_unit,_switchUniform,(_attempt + 1)],"switchUniforms"] call INCON_fnc_civHandler;
			};
		};

		if (_switchUniform) then {
			[_unit,_activeContainer,_origUnifItems,_origUnif,_newUnif] spawn {
				params ["_unit","_activeContainer","_origUnifItems","_origUnif","_newUnif"];

				if (_activeContainer isKindOf "GroundWeaponHolder") then {_oldGwh = _activeContainer; _activeContainer = createVehicle ["GroundWeaponHolder", getPosATL _unit, [], 0, "CAN_COLLIDE"]};

				_activeContainer addItemCargoGlobal [(_origUnif), 1];

				_newUnifItems = (itemcargo (_newUnif select 1)) + (magazinecargo (_newUnif select 1)) + (weaponcargo (_newUnif select 1));

				[_unit,"AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon"] remoteExec ["playMove",0];

				sleep 0.2;

				{_activeContainer addItemCargoGlobal [_x, 1];} forEach (_newUnifItems);

				sleep 0.1;

				_unit forceAddUniform (_newUnif select 0);

				sleep 0.2;

				{(uniformContainer _unit) addItemCargoGlobal  [_x, 1]} forEach (_origUnifItems);

				sleep 0.1;

				_crateCargo = itemCargo _activeContainer;
				_newCrateCargo = (itemCargo _activeContainer);
				_newCrateCargo set [(_newCrateCargo find (_newUnif select 0)),-1];
				_newCrateCargo = _newCrateCargo - [-1];

				sleep 0.2;
				clearItemCargoGlobal _activeContainer;
				{_activeContainer addItemCargoGlobal [_x,1]} forEach (_newCrateCargo);

			};
		};

		_return = true;
	};
};

_return
