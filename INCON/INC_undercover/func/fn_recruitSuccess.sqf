
_this spawn {

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

		[_recruitedCiv,"simpleArmedLoop"] remoteExecCall ["INCON_fnc_armedHandler",_undercoverUnit];

		[_recruitedCiv] remoteExecCall ["INCON_fnc_undercoverDetect",_undercoverUnit];

	};

	_recruitedCiv setCombatMode "GREEN";

	_recruitedCiv

};
true
