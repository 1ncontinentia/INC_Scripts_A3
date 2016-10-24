INCONTINENTIA'S UNDERCOVER / CIVILIAN RECRUITMENT (alpha)

Requires: ALiVE (for civilian recruitment)

This script package is part of a mission I am currently working on.
I decided to release it standalone for now.

Please bear in mind this is an early WIP project and I am a complete beginner at scripting.

There will likely be bugs and inefficiencies!

Also, as it is in alpha state, it should only be used if you are happy to accept that
things might change drastically as I figure out new ways to do cool shit. Backwards compatibility will hopefully be maintained but no promises!
It should work fine in SP, MP and Dedi but it is designed specifically for SP ALiVE missions hosted on dedicated servers (niche, I know!).

The detection stuff will work without ALiVE.
The recruitment of civilians will not work properly without ALiVE's civilian placement modules (you can disable this in the setup options).

Currently only BLUFOR undercover units are supported (this is planned to change).
Any other scenarios may work but probably not quite as intended. This is probably the next thing I'll work on.

Future plans include blacklists / whitelists of items. And maybe even disguises.

All attempts have been made to make it work in co-op but this is untested as I have no friends who share my Arma obsession
(or at least none that have come out of the closet).

All feedback is welcome, please report any suggestions / inclusions back to the forums thread.


|||*********************> Features <*********************|||

UNDERCOVER / RECRUITMENT

* Made for ALiVE
* Allows a player and his group to dress as civilians and go incognito, recruit actual civilians, and cause mayhem. 

* Undercover units remain incognito unless they
    (a) get too close to military units (of enemy side),
    (b) wear a suspicious uniform or vest,
    (c) openly carry any weapon (including binoculars),
    (d) trespass into a forbidden area
    (e) become compromised

* Enemies ignore the AI group members of undercover units unless they
    (a) wear a suspicious uniform or vest,
    (b) openly carry any weapon (including binoculars),
    (c) are compromised

* Stealth kills work -
    * If nobody sees you firing a shot, your cover will remain intact
    * BUT, enemies do remember suspicious units - if you kill someone and other enemies of that side already know who you are, there is a chance your cover will be blown regardless
    * However, your cover will return if you kill everyone who knows about you before they can spread the word

* Different behaviour for regular and asymmetric forces
    * Define a side as asymmetric and they will not share your identity between cells (maximum 1 regular side and 1 asymmetric side supported at present)
    * Define a side as regular and your cover will stay blown for much longer once compromised

(Optional)
* Recruit civilians to join your group
* Civilians may carry weapons and pistols on their person or in backpacks (only one type of each currently supported - AKs and Rooks)
* (Optional) If you kill an enemy and remain undetected, their side may lash out against civilians, prompting an armed rebellion
* The more enemies you kill, the better your side's reputation will become (persists with ALiVE)
* The better your side's reputation, the more likely civilians are to join you
* Armed civilians can conceal their weapons using the group actions radio menu (6 - 1) to remain incognito
* Simple incognito script for recruited civilians - if they are openly armed or enemies have seen them acting suspiciously, they will be seen as hostile to enemies

* Works on dedicated server
* SP compatible, untested in COOP but should work fine



|||*********************> USAGE <*********************|||

==========>>>>>Change your settings in the UCR_setup.sqf file.

==========>>>>>For each undercover unit, put this in their unit init:

this setVariable ["isSneaky",true,true];


==>>For each out of bounds area, place a trigger covering the area with these settings:

>>Trigger settings: present, any, repeatable.

>>Trigger condition:

{(_x getVariable "isSneaky")}  count thislist > 0

>>Trigger activation:

[(thisList select 0),thisTrigger] call INCON_fnc_undercoverTrespass;


==========>>>>> In init.sqf:

{[[_x], "INCON\INC_undercover\undercoverHandler.sqf"] remoteExec ["execVM",_x];} forEach (allUnits select {_x getVariable ["isSneaky",false]});


==========>>>>>In description.ext:

class Extended_InitPost_EventHandlers {
     class CAManBase {
		init = "_this call (compile preprocessFileLineNumbers 'INCON\INC_undercover\unitInitsUndercover.sqf')";
	};
};

class CfgFunctions
{
	#include "INCON\INC_undercover\cfgFunctions.hpp"
};

class CfgRemoteExec
{
   class Functions
   {
       mode = 2;
       jip = 1;
       #include "INCON\INC_undercover\functionsWhitelist.hpp"
   };
};



|||*********************> Future Plans <*********************|||

Sector hostility rewards for killing enemies on all sides, not just BLUFOR
Recruit civilians to non-BLUFOR sides (if there is demand for it)
Add ability to change civilians' weapons
Trespassing areas
Disguises


|||*********************> Thanks <*********************|||

Massive thanks to Spyderblack723 for all the help over this past year or so and whose awesome Spyder Addons mod inspired me to make stuff.
Also, thank you to davidoss, Grumpy Old Man, Tajin and sarogahtyp for coming up with the basis for the detection functions, as well as the guys on Arma 3 discord.
Lots of other people deserve thanks too I'm sure!
