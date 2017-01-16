/*
Armed tracker - detects whethere a player is wearing a BLUFOR military uniform or a military vest, or is armed.

Spawns a loop that checks if the unit is armed or if the unit is wearing a suspicious uniform.


*/


params [["_unit",objNull],["_operation","armedLoop"]];

#include "..\UCR_setup.sqf"

if ((_unit getVariable ["INC_undercoverLoopsActive",false]) || {(!local _unit)}) exitWith {};

_unit setVariable ["INC_undercoverLoopsActive", true]; // Stops the script running twice on the same unit

_unit setVariable ["INC_proxAlert",false]; //Proximity
_unit setVariable ["INC_trespassAlert",false]; //Trespassing
_unit setVariable ["INC_suspiciousValue", 1]; //How suspicious is the unit
_unit setVariable ["INC_weirdoLevel",1]; //How weird is the unit acting

if (isPlayer _unit) then {
	[[_unit,_unit,false],"addConcealActions"] call INCON_fnc_civHandler;
};


//Proximity / Trespass Stuff - sets variables to be picked up by armed/suspicious loop
//=======================================================================//
[_unit,_regDetectRadius,_asymDetectRadius] spawn {
	params [["_unit",player],["_regDetectRadius",15],["_asymDetectRadius",25],["_radius3",60],["_radius4",200]];

	private ["_nearReg","_nearAsym","_nearHVT","_nearSuperHVT","_nearMines"];

	waitUntil {

		//Proximity check for players (doesn't run if the unit is compromised)
		if (isPlayer _unit) then {

			private _disguiseValue = ((_unit getVariable ["INC_compromisedValue",1]) * (_unit getVariable ["INC_weirdoLevel",1]));

			switch (_unit getVariable ["INC_goneIncognito",false]) do {

				case true: {
					//Needs testing
					_nearReg = count (
						(_unit nearEntities (_regDetectRadius * _disguiseValue)) select {
							(side _x == INC_regEnySide) &&
							{(_x knowsAbout _unit) > 2} &&
							{((_x getHideFrom _unit) distanceSqr _unit < 10)} &&
							{alive _x}
						}
					);

					sleep 0.5;

					//Needs testing
					_nearAsym = count (
						(_unit nearEntities (_asymDetectRadius * _disguiseValue)) select {
							(side _x == INC_asymEnySide) &&
							{(_x knowsAbout _unit) > 2} &&
							{((_x getHideFrom _unit) distanceSqr _unit < 10)} &&
							{alive _x}
						}
					);
				};

				case false: {

					_nearReg = count (
						(_unit nearEntities (_regDetectRadius * _disguiseValue)) select {
							(side _x == INC_regEnySide) &&
							{(_x knowsAbout _unit) > 3} &&
							{alive _x}
						}
					);

					sleep 0.5;

					_nearAsym = count (
						(_unit nearEntities (_asymDetectRadius * _disguiseValue)) select {
							(side _x == INC_asymEnySide) &&
							{(_x knowsAbout _unit) > 3} &&
							{alive _x}
						}
					);
				};
			};

			sleep 0.5;

			_nearMines = {_x isKindOf "timeBombCore"} count (nearestObjects [_unit,[],4]);

			sleep 0.5;

			if ((_nearAsym + _nearReg + _nearMines) != 0) then {
				_unit setVariable ["INC_proxAlert",true]
			} else {
				_unit setVariable ["INC_proxAlert",false]
			};
		};

        sleep 0.4;

		//Trespassing check for AI and players
		if !(_unit getVariable ["INC_trespassAlert",false]) then {

	        {
	            if (_unit inArea _x) exitWith {

	                private _activeMarker = _x;

	                _unit setVariable ["INC_trespassAlert",true];

	                waitUntil {

	                    sleep 1;

	                    !(_unit inArea _activeMarker);
	                };

	                _unit setVariable ["INC_trespassAlert",false];
	            };

	            false

	        } count INC_trespassMarkers;
		};

		sleep 0.1;

		(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)} || {!local _unit})
	};
};


//Armed / Incognito Stuff
//=======================================================================//
[_unit,_HMDallowed,_noOffRoad,_debug,_hints] spawn {

	params ["_unit","_HMDallowed","_noOffRoad","_debug","_hints"];

	private _responseTime = 0.25;

	if !(isPlayer _unit) then {_responseTime = (_responseTime * 3)}; //Repsonsiveness of script reduced for performance on AI

	sleep _responseTime;

	//Main loop
	waitUntil {

		//While not in a vehicle
		waitUntil {

			if !(isNull objectParent _unit) exitWith {true};

			private _suspiciousValue = 1; //Suspicious behaviour value: higher = more suspicious

			//Incognito check
			if ((uniform _unit in INC_incognitoUniforms) && {(vest _unit in INC_incognitoVests)}) then {

				if ((isPlayer _unit) && {_debug}) then {
					hint "You are disguised as the enemy."
				};

				_unit setVariable ["INC_goneIncognito",true];
			} else {
				_unit setVariable ["INC_goneIncognito",false];
			};

			//Penalise people for being oddballs
			if (isPlayer _unit) then {

				private _weirdoLevel = 1; //Multiplier of radius for units near the player

		        switch ((stance _unit == "CROUCH") || {stance _unit == "PRONE"}) do {

					case true: {
						_weirdoLevel = _weirdoLevel + (random 2);

				        if (speed _unit > 2) then {
							_weirdoLevel = _weirdoLevel + (random 1);

					        if (speed _unit > 5) then {
								_weirdoLevel = _weirdoLevel + (random 1);
							};
						};
					};

					case false: {

					    if (speed _unit > 8) then {
							_weirdoLevel = _weirdoLevel + (random 1);

						    if (speed _unit > 17) then {
								_weirdoLevel = _weirdoLevel + (random 3);
							};
						};
					};
				};

				if (uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"])) then {_weirdoLevel = _weirdoLevel + (random 3)};

				_unit setVariable ["INC_weirdoLevel",_weirdoLevel];  //This variable acts as a detection radius multiplier
			};

			sleep _responseTime;

			if !(_unit getVariable ["INC_goneIncognito",false]) then {

				//Check if unit is wearing anything suspicious
				if (!(uniform _unit in INC_safeUniforms) || {!(vest _unit in INC_safeVests)} || {!(backpack _unit in INC_safeBackpacks)} || {(hmd _unit != "") && !(_HMDallowed)}  || {(uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"]))}) then {

					/*if ((isPlayer _unit) && {_debug}) then {
						hint "You are wearing a suspicious item."
					};*/

					_suspiciousValue = _suspiciousValue + 1;
				};

				sleep _responseTime;

				//Check if unit is armed
				if !(((currentWeapon _unit == "") || {currentWeapon _unit == "Throw"}) && {primaryweapon _unit == ""} && {secondaryWeapon _unit == ""}) then {

					/*if ((isPlayer _unit) && {_debug}) then {
						hint "You are visibly armed."
					};*/

					_suspiciousValue = _suspiciousValue + 1;
				};

				sleep _responseTime;

				//Trespass check
				if (_unit getVariable ["INC_trespassAlert",false]) then {

					_suspiciousValue = _suspiciousValue + 1;
				};
			};

			//Trespass check
			if (_unit getVariable ["INC_proxAlert",false]) then {

				_suspiciousValue = _suspiciousValue + 2;
			};

			_unit setVariable ["INC_suspiciousValue", _suspiciousValue];

			!(isNull objectParent _unit)
		};

		sleep _responseTime;

		//While in a vehicle
		waitUntil {

			if (isNull objectParent _unit) exitWith {true};

			private _suspiciousValue = 1;

			//Incognito check to go here
			if (((typeOf vehicle _unit) in INC_incognitoVehArray) && {!((vehicle _unit) getVariable ["INC_naughtyVehicle",false])} && {uniform _unit in INC_incognitoUniforms}) then {

				if ((isPlayer _unit) && {_debug}) then {
					hint "You are disguised as the enemy."
				};

				_unit setVariable ["INC_goneIncognito",true];
				_unit setVariable ["INC_canConcealWeapon",false];
				_unit setVariable ["INC_canGoLoud",true];
			} else {
				_unit setVariable ["INC_goneIncognito",false];
				_unit setVariable ["INC_canConcealWeapon",([[_unit],"ableToConceal"] call INCON_fnc_civHandler)];
				_unit setVariable ["INC_canGoLoud",([[_unit],"ableToGoLoud"] call INCON_fnc_civHandler)];
			};

			//Penalise people for being oddballs by increasing the spotting radius - wearing wrong uniform / hmd
			if (isPlayer _unit) then {

				private _weirdoLevel = 1; //Multiplier of radius for units near the player

				if !(_unit getVariable ["INC_goneIncognito",false]) then {

			        switch (!(uniform _unit in INC_safeUniforms) || {!(vest _unit in INC_safeVests)}) do {

						case true: {

							_weirdoLevel = _weirdoLevel + (random 2);

							if ((hmd _unit != "") && {!(_HMDallowed)}) then {

								_weirdoLevel = _weirdoLevel + (random 1);
							};
						};

						case false: {

							if ((hmd _unit != "") && {!(_HMDallowed)}) then {

								_weirdoLevel = _weirdoLevel + (random 1.5);
							};
						};
					};
				} else {
					//Incognito uniform check for non-tank vehicles
					if (!((vehicle _unit) isKindOf "Tank") && {!(vest _unit in INC_incognitoVests)}) then {

						_weirdoLevel = _weirdoLevel + 2 + (random 1);
					};
				};

				if (uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"])) then {_weirdoLevel = _weirdoLevel + (random 3)};

				_unit setVariable ["INC_weirdoLevel",_weirdoLevel]; //This variable acts as a detection radius multiplier
			};

			sleep _responseTime;

			if !(_unit getVariable ["INC_goneIncognito",false]) then {

				//Suspicious vehicle check
				if !(((typeof vehicle _unit) in INC_safeVehicleArray) && {!((vehicle _unit) getVariable ["INC_naughtyVehicle",false])}) then {

					if ((isPlayer _unit) && {(_debug) || {_hints}}) then {
						hint "You are in a suspicious vehicle.";
					};

					_suspiciousValue = _suspiciousValue + 2;
				};

				sleep _responseTime;

				//Offroad check
				if ((_noOffRoad) && {((vehicle _unit) isKindOf "Land")} && {((count (_unit nearRoads 30)) == 0)}) then {

					if ((isPlayer _unit) && {(_debug) || {_hints}}) then {
						hint "You are in a suspicious vehicle.";
					};

					_suspiciousValue = _suspiciousValue + 1;
				};

				sleep _responseTime;

				//Trespass check
				if (_unit getVariable ["INC_trespassAlert",false]) then {

					_suspiciousValue = _suspiciousValue + 1;
				};
			};

			//Trespass check
			if (_unit getVariable ["INC_proxAlert",false]) then {

				_suspiciousValue = _suspiciousValue + 2;
			};

			_unit setVariable ["INC_suspiciousValue", _suspiciousValue];

			(isNull objectParent _unit)
		};

		(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)} || {!local _unit})
	};

	_unit setVariable ["INC_undercoverLoopsActive", false]; // Stops the script running twice on the same unit
};


//Detection Stuff
//=======================================================================//
[_unit] spawn {

	params ["_unit"];

	waitUntil {

		sleep 4;

		private _alertedRegKnows = ([_unit, INC_regEnySide] call INCON_fnc_undercoverGetAlerted);

		private _alertedAsymKnows = ([_unit, INC_asymEnySide] call INCON_fnc_undercoverGetAlerted);

		private _anyAlerted = false;

		if (_alertedRegKnows || {_alertedAsymKnows}) then {_anyAlerted = true};

		//Publicise variables on undercover unit for undercover handler, killed handler & cooldown.
		_unit setVariable ["INC_RegKnowsSO", _alertedRegKnows, true];
		_unit setVariable ["INC_AsymKnowsSO", _alertedAsymKnows, true];
		_unit setVariable ["INC_AnyKnowsSO", _anyAlerted, true];

		(!(_unit getVariable ["isUndercover",false]) || !(alive _unit))
	};
};

//Fired EventHandler
_unit addEventHandler["Fired", {
	params["_unit"];

	//If he's compromised, do nothing
	if !(_unit getVariable ["INC_undercoverCompromised",false]) then {

		//If anybody is aware of the unit, then...
		if (_unit getVariable ["INC_AnyKnowsSO",false]) then {

			//Do nothing unless they know where the dude is
			_regAlerted = [INC_regEnySide,_unit,50] call INCON_fnc_countAlerted;
			_asymAlerted = [INC_asymEnySide,_unit,50] call INCON_fnc_countAlerted;

			//Once people know where he is, who he is, and that he has fired a weapon, make him compromised
			if ((_regAlerted != 0) || {_asymAlerted != 0}) exitWith {

				[_unit] call INCON_fnc_undercoverCompromised;
			};
		};
	};
}];


//Add in suspicious level stuff for compromised variable and all that shizzlematiz, consolidate trespass loops into this function, consolidate detect, remove old shit
