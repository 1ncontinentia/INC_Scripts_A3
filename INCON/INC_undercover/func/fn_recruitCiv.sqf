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

		_civ remoteExec ["removeAllActions",0];

	},[],6,true,true,"","((alive _target) && (_this getVariable ['isUndercover',false]))",4
]] remoteExec ["addAction", 0];

if (_armedCivPercentage > (random 100)) exitWith {

	if (70 > (random 100)) then {

		private _backpackToAdd = selectRandom ["B_FieldPack_blk","B_FieldPack_cbr","B_FieldPack_khk","B_FieldPack_oucamo","B_Carryall_cbr"];
		_unit addMagazine "16Rnd_9x21_Mag";

		if (20 > (random 100)) then {

			_unit addBackpack _backpackToAdd;
			_unit additemtobackpack "hgun_Rook40_F";
			unitBackpack _unit setVariable ["owner",_unit,true];
			[(unitBackpack _unit), {
				_this addEventHandler ["ContainerOpened", {
					_backpack  = _this select 0;
					_civ = _backpack getVariable "owner";
					private _civComment = selectRandom ["Get the fuck out of my backpack!","What are you doing?","Leave me alone!","Get out!","What are you playing at?","Thief!","Get your own stuff.","Go away.","What the?","Crazy man"];
					[[_civ, _civComment] remoteExec ["globalChat",0]];
					[[_civ] remoteExecCall ["INCON_fnc_runAway",_civ]];
					}
				];
			}] remoteExec ["call", 0,true];
			_unit setVariable ["INC_civIsUnarmed",false,true];

		} else {

			_unit addItemToUniform "hgun_Rook40_F";
			_unit setVariable ["INC_civIsUnarmed",false,true];

		};

		_unit addMagazine "16Rnd_9x21_Mag";
		_unit addMagazine "16Rnd_9x21_Mag";
		_unit addMagazine "16Rnd_9x21_Mag";
		_unit call ace_weaponselect_fnc_putWeaponAway;
		_unit action ["SwitchWeapon", _unit, _unit, 99];
		_unit action ["HandGunOffStand", _unit];
		_unit removeWeapon (currentWeapon _unit); null = [_unit] spawn {_unit = (_this select 0); sleep 5; _unit action ['SwitchWeapon', _unit, _unit, 100];};

	} else {

		private _backpackToAdd = selectRandom ["B_FieldPack_blk","B_FieldPack_cbr","B_FieldPack_khk","B_FieldPack_oucamo","ace_gunbag","ace_gunbag_Tan","B_Carryall_cbr"];
		_unit addMagazine "30Rnd_545x39_Mag_Green_F";

		if (60 > (random 100)) then {

			_unit addBackpack _backpackToAdd;
			_unit additemtobackpack "arifle_AKS_F";
			unitBackpack _unit setVariable ["owner",_unit,true];
			[(unitBackpack _unit), {
				_this addEventHandler ["ContainerOpened", {
					_backpack  = _this select 0;
					_civ = _backpack getVariable "owner";
					private _civComment = selectRandom ["Get the fuck out of my backpack","What are you doing?","Leave me alone!","Get out!","What are you playing at?"];
					[[_civ, _civComment] remoteExec ["globalChat",0]];
					[[_civ] remoteExecCall ["INCON_fnc_runAway",_civ]];
					}
				];
			}] remoteExec ["call", 0,true];
		};

		_unit addMagazine "30Rnd_545x39_Mag_Green_F";
		_unit addMagazine "30Rnd_545x39_Mag_Green_F";
		_unit addMagazine "30Rnd_545x39_Mag_Green_F";
		_unit setVariable ["INC_civRifle",true,true];
		_unit setVariable ["INC_civIsUnarmed",false,true];

	};

};

_unit setVariable ["INC_civIsUnarmed",true,true];
