class undercoverRecruit
{
	file = "INCON\INC_undercover\func";
	class armedHandler {description = "Sets captive depending on whether the unit is armed, wearing suspicious clothing or enemy units know about them.";};
	class civHandler {description = "Contains functions for arming recruitable civilians."};
	class countAlerted {description = "Counts units of the defined side who have been alerted to a unit.";};
	class getFactionGear {description = "Gets a faction's gear.";};
	class recruitAttempt {description = "Attempt to recruit - requires ALiVE.";};
	class recruitCiv {description = "Allows civilians to be recruited. Also gives them either a rifle or pistol.";};
	class recruitSuccess {description = "Unit join's initiator's group and adds dismiss, conceal weapon and show weapon actions.";};
	class spawnRebelCommander {description = "Spawns a commander for civilian units to join in an uprising.";};
	class undercoverCompromised {description = "Sets the unit as compromised while it is know to enemy units and is doing something naughty.";};
	class undercoverCooldown {description = "Initiates a cooldown after the unit has done something naughty";};
	class undercoverDetect {description = "Updates variables on a unit which become true if the defined side knows about them.";};
	class undercoverGetAlerted {description = "Returns the number of given side who know about the unit";};
	class undercoverKilledHandler {description = "Handles enemy deaths - enemies may become suspicious if they know about a nearby undercover unit. Also includes options for reprisals against civilians if the side is predefined as brutal in the setup.";};
	class undercoverTrespassHandler {description = "Handles unit trespassing in different situations, returning the 'trespassing' variable on the unit for the undercover handler.";};
};
