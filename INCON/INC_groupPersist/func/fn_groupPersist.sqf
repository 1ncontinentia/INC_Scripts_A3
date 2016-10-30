/*
Group Persistence Main

Author: Incontinentia

*/


params [["_operation","loadGroup"],["_unit",objNull]];

#include "..\INC_groupPers_setup.sqf"

switch (_database) do {

    case "alive" : {

		//Locality: client, as anything that needs to be remotely executed is done from here
		if (isDedicated) exitWith {};

		switch (_operation) do {
			case "loadGroup" : {

				[_unit] spawn {
					params ["_unit"];
					private ["_groupData","_dataKey"];

					waitUntil {
						sleep 3;

						(_unit getvariable ["alive_sys_player_playerloaded",false])
					};

					_dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

					_groupData = [_dataKey,"loadAliveData"] remoteExecCall ["INCON_fnc_persHandler",2];

					sleep 0.2;

					if (count _groupData != 0) then {

						{if (_x != leader group _x) then {deleteVehicle _x}} forEach units group _unit;

						[_groupData,"loadGroup",_unit] call INCON_fnc_persHandler;

					};
				};
			};

            case "saveGroup" : {
        		switch (_saveType) do {

        			case "loop": {
						[_unit] spawn {
							params ["_unit"];
							private ["_groupData","_dataKey"];

							sleep 60;

							_dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

							waitUntil {

								sleep 59;

								_groupData = [_unit,"saveGroup"] call INCON_fnc_persHandler;

								sleep 1;

								[[_dataKey,_groupData],"saveAliveData"] remoteExecCall ["INCON_fnc_persHandler",2];

								!(isPlayer _unit)

							};
						};
					};

        			case "onExit": {
						[_unit] spawn {
							params ["_unit"];
							private ["_groupData","_dataKey"];

							sleep 60;

			                _dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

							waitUntil {

								sleep 3;

								!(isPlayer _unit)

							};

							_groupData = [_unit,"saveGroup"] call INCON_fnc_persHandler;

							sleep 1;

							[[_dataKey,_groupData],"saveAliveData"] remoteExecCall ["INCON_fnc_persHandler",2];
						};
        			};
        		};
        	};
        };
    };

    case "iniDBI2" : {

		//Locality, either but ideally server as otherwise "onExit" doesn't work.

		inidbi = ["new", "INC_groupPersDB"] call OO_INIDBI;

		switch (_operation) do {

			case "loadGroup" : {
                [_unit] spawn {
                    params ["_unit"];
                    private ["_groupData","_dataKey","_float"];

                    waitUntil {
                        sleep 3;

                        (_unit getvariable ["alive_sys_player_playerloaded",false])
                    };

                    _dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

                    _read = ["read", [(str missionName), _dataKey,[]]] call inidbi;

					_float = (_read select 0);

					_floatCompare = dateToNumber date;

                    if (!(_read isEqualTo []) && {typeName _float == "SCALAR"} && {_float > (_floatCompare - 0.000012)} && {_float < (_floatCompare + 0.000012)}) then {

                        {if (_x != leader group _x) then {deleteVehicle _x}} forEach units group _unit;

                        sleep 0.1;

                        [_read,"loadGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;

                    };
                };
			};

        	case "saveGroup" : {

        		switch (_saveType) do {

        			case "loop": {
        				[_unit] spawn {
        					params ["_unit"];
        					private ["_groupData","_dataKey"];

        					sleep 60;

        					waitUntil {

        						sleep 59;

        	                    _encodedData = [_unit,"saveGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;

								sleep 1;

            	                _dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

        	                    ["write", [(str missionName), _dataKey, _encodedData]] call inidbi;

        						!(isPlayer _unit)

        					};
        				};
        			};

        			case "onExit": {
        				[_unit] spawn {
        					params ["_unit"];
        					private ["_groupData","_dataKey"];

        					sleep 60;

        	                _dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

							waitUntil {

								sleep 5;

								!(isPlayer _unit)

							};

    	                    _encodedData = [_unit,"saveGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;
    	                    ["write", [(str missionName), _dataKey, _encodedData]] call inidbi;

        				};
                    };
        		};
            };
        };
	};
};
