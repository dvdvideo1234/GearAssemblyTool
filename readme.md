# GearAssemblyTool

---

# Copyright 2015 [ME](http://steamcommunity.com/profiles/76561197988124141) !

## IF YOU HAPPEN TO FIND REUPLOADS WITH DIFFERENT ORIGIN REPORT THEM TO ME IMMIDEATELY !!!

![GearAssemblyTool](https://raw.githubusercontent.com/dvdvideo1234/GearAssemblyTool/master/data/pictures/screenshot.jpg)

## Description
This script can give you the ability to connect prop-segmented gear pieces fast.
It is optimized and brings the gear building time consuming to a minimum.
It uses pre-defined radius-vectors to snap the segments the best way there is in Garry's Mod

## General FAQ:

#### How can I install this?
You can subscribe to it [here](http://steamcommunity.com/sharedfiles/filedetails/?id=384782853)
or download the latest stable release from [here](https://github.com/dvdvideo1234/GearAssemblyTool/releases)
after that extract it in `..\GarrysMod\garrysmod\addons` and you are practically done.

#### What kind of features does this script has?
  * Gear precise alignment relative to the mass-center
  * Extendable database via [text file](https://raw.githubusercontent.com/dvdvideo1234/GearAssemblyTool/master/gearassembly/dsv/sv_GEARASSEMBLY_PIECES.txt)
    or a [lua script](https://raw.githubusercontent.com/dvdvideo1234/GearAssemblyTool/master/data/autosave/z_autorun_add_pieces.lua))
  * Extendable database via text file
        [load list](https://raw.githubusercontent.com/dvdvideo1234/GearAssemblyTool/master/gearassembly/gearasmlib_dsv.txt)
    and [list prefixes](https://raw.githubusercontent.com/dvdvideo1234/GearAssemblyTool/master/gearassembly/dsv/clock_GEARASSEMBLY_PIECES.txt)
        [categories](https://raw.githubusercontent.com/dvdvideo1234/TrackAssemblyTool/master/data/trackassembly/dsv/cl_TRACKASSEMBLY_CATEGORY.txt)
  * Switching database storage between Lua table and SQL
  * Spawning pieces on the map
  * Snapping/spawning at the center if checked
  * Snapping the first piece yaw to user defined angle
  * Automatic gear-anchor constraint creation when building
  * Custom point position angle and orientation adviser
  * Advanced duplicator can be used on the gearbox created
  * Custom entity properties ( weld, freeze, no-collide )
  * User can disable phys-gun grabbing on a piece
  * Ability to list up the most used pieces on the server ( E + MRIGHT ). Close shortcut (ALT + E)
  * Ability to search among the most server popular pieces by [Lua patterns](https://www.lua.org/pil/20.2.html)
  * Ability to export server and client database as a file
  * Tool-tips for every button are available and can be translated easily
  * Ability to spawn scripted gear items of other class
  * Ability to modify the bodygroups and skins of a gear piece ( with duping )
  * Gear surface behavior automatically set to super-ice ( Optimal performance )

#### What addons does this script work with alongside these included in Garry's mod ?
  * Gmod 10 (spur, racks) (INCLUDED)
  * PHX spur (spotted, small, medium, big, flat) (INCLUDED)
  * PHX bevel (regular, vertical) (INCLUDED)
  * PHX rack (spotted, flat) (INCLUDED)
  * [Black spur](https://steamcommunity.com/sharedfiles/filedetails/?id=564582559) (small, medium)
  * [SProps](https://steamcommunity.com/sharedfiles/filedetails/?id=173482196) (small spur, large spur, rack, bevel)
  * [Propeller pack](https://steamcommunity.com/sharedfiles/filedetails/?id=686701650)

#### Why did you made this script and what is its purpose ?
I made it, because I am pissed of messing my gears over and over and ... you get the
idea xD, some friends suggested that I should make this thing. It's made
for assembling and precisely meshing gears the best way there is in Gmod.

#### How can I spawn gears then ?
Spawn gears by clicking anywhere[.](http://clockwork-planet.wikia.com/wiki/Clockwork_Planet_(Earth))

#### That's nice, but want to mesh ( or stack ) gears for example, how should I do that ?
Set the Stack count to one or more, point to one gear, then
hold `IN_SPEED` ( Def: SHIFT ) and click `IN_ATTACK1` ( Def: Left mouse button ).

#### How can I adjust the stacking mode if I want different stacking option for my gearbox?
Press the `IN_ATTACK2` ( Def: Right mouse button ) without any additional keys.
GA will switch between all stacking options available.

#### How can I adjust the stack mode of the tool and what is it for?
The stack mode is used ( as the name suggests ) to support two
different gear stacking modes. When the state is `Around trace pivot`,
you are stacking around and relative to the trace gear's [pivot](http://www.dictionary.com/browse/pivot) line ( blue ).
When the stack mode is set to `Forward direction` the script will stack gears
in a [direction](https://en.wikipedia.org/wiki/Direction_vector) selected by the user, and precisely meshing those.

#### How can I make a planetary gear ?
Set the stack mode to `Around trace pivot` ( Around the trace prop's blue line ).
Put some ending angle, if you don't want to stack all-around
Set the stack count to 2 or more.
Adjust pivot rotation if you don't want to start at 0 degrees.
Use the meshing function, done ;).

#### Dude, how can I make a mighty gear differential, like in the icon?
Repeat the same procedure as the planetary gear above, but with bevels.
Last, set the stack count to one, point to one of the planetary bevels
and use the meshing function.

#### How can I stack gears in one particular direction.
Orient the first gear's forward to point in the desired direction. Freeze it.
Adjust stack mode to `Forward direction`, set stack count to two or more
You can also use the manual offsets like in TA. Now mesh those things !<br><br>
_*Beware, that some gears have different forward origin related to the mesh angle.
The bevels for example have mesh angle of 45 degrees and if you stack 3 of them,
this will result in a created differential with 2 planet gears and two suns gears*_

#### How can I chose the constraint type when I want to automatically constrain a gear?
Below the gear selection tree, there is a drop-down menu. ( It shows `<Constraint Type>` at first )
Click on it to select constraint type like Axis, BS, and so on ..<br><br>
_*The axises and ball-sockets are created in the gear's mass-center for increased precision
and I can admit no one likes off-centered gears*_

#### How should I chose an anchor prop to constrain the gears to and how can I know what did I select?
Easy, see the `[ID]` selection on the toolgun screen next to the trace status. It indicates
which prop is selected for `Anchor` ( A prop that the gears will be automatically constrained to )
If it shows `N/A` ( Not Available ), then no anchor is selected[.](https://myanimelist.net/character/103893/AnchoR)
If it shows for example `[Entity_ID]`, then an anchor is selected
and all gears will be automatically constrained to it if enabled
( Constraint type different than `Free spawn` ). You can also clear it any time by pointing
to the world and using `IN_SPEED` ( Def: SHIFT ) + click `IN_ATTACK2` ( Def: Right mouse button ).

#### How can I stack a gearbox trace forward, when the teeth overlap ?
Ah, this happens when the gear piece has even set of teeth. Adjust the trace pivot rotation
until the tooth of the holder gear ( the piece that you are holding ) aligns with the gap of
the trace gear. Take this number (For example 7.25) and divide it by two (3.625). Now use this
same value (3.625) for both trace pivot rotation and piece ( holder pivot ) rotation.

#### Do you know how to switch fast the prop to be used as a gear?
Yep, just point to another gear you want to use and press
`IN_DUCK` ( Def: CTRL ) + click `IN_ATTACK2` ( Def: Right mouse button )
If the gear is valid database model it will be selected normally and if not,
GA will say that this model is invalid.

#### You said this thing is pretty mush like the TA, which settings are the same?
The handling of Bodygroup/Skin selection, Mass, Gear's physical properties,
Ghosting and stuff, Error logging, Screens, Translations and Data export/selection.

#### I have a hard time reading the lines and circles of the adviser. What do these visuals represent?
All the red lines are forward direction and the blues are the up direction vectors of all the
angle orientations processed. The trace and the holder blue lines are the trace and holder pivot
axises respectively. The yellow circles are the trace and domain mass-centers as position vectors.
The green line is the origin right vector and the blue line the up vector. The yellow circle is the
point where the gears mesh. The gear position is displayed on the screen in red. The mass-center is
used for all internal position calculations and it is proper origin to relate the offset on. The
world space distances between the mass-centers and positions are displayed with yellow lines.
The magenta line represents the distance vector between holder and origin the green trace and origin.
If you are still confused about this, please take a look at the diagram below:

#### May I put your script in a third-party website?
*Distribution ownership is like the Track Assembly Tool, so DO NOT UPLOAD THIS TO ANY OTHER SITES !*
**I mean it !**

![ref_ga_coords](https://raw.githubusercontent.com/dvdvideo1234/GearAssemblyTool/master/data/pictures/coordinates.jpg)
