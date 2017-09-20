GearAssemblyTool
================

**Copyright 2015 ME !**

**IF YOU HAPPEN TO FIND REUPLOADS WITH DIFFERENT ORIGIN REPORT THEM TO ME IMMIDEATELY !!!**

![GearAssemblyTool](https://raw.githubusercontent.com/dvdvideo1234/GearAssemblyTool/LuaDB/data/pictures/screenshot.jpg)

 On the Steam WS: http://steamcommunity.com/sharedfiles/filedetails/?id=384782853

This is a Gmod tool for assembling Gears

General FAQ:

```
Q: Why did you made this script and what is its purpose ?
A: I made it, because I am pissed of messing my gears over and over and ... you get the
   idea xD, some friends suggested that I should make this thing. It's made
   for assembling and precisely meshing gears the best way there is in Gmod

Q: How can I spawn gears then ?
A: Spawn gears by clicking anywhere.

Q: That's nice, but want to mesh ( or stack ) gears for example, how should I do that ?
A: Set the Stack count to one or more, point to one gear, then
   hold IN_SPEED ( Def: Shift ) and click IN_ATTACK1 ( Def: Left mouse button ).

Q: How can I adjust the stack mode of the tool and what is it for?
A: The stack mode is used ( as the name suggests ) to support two
   different gear stacking modes. When the state is "Around Pivot",
   you are stacking around and relative to the trace gear's pivot line ( yellow ).
   When the stack mode is set to "Forward based" the script will stack gears
   in a direction selected by the user, and precisely meshing those.

Q: How can I make a planetary gear ?
A: Set the stack mode to "Around pivot" ( Around the trace prop's yellow line ).
   Put some ending angle, if you don't want to stack all-around
   Set the stack count to 2 or more.
   Adjust pivot rotation if you don't want to start at 0 degrees.
   Use the meshing function, done ;).

Q: Dude, how can I make a mighty gear differential, like in the icon?
A: Repeat the same procedure as the planetary gear above, but with bevels.
   Last, adjust the piece's rotation to 180 degrees, set the stack count to one,
   point to one of the planetary bevels use the meshing function.

Q: How can I stack gears in one particular direction.
A: Orient the first gear's forward to point in the desired direction. Freeze it.
   Adjust stack mode to "Forward based", set stack count to two or more
   You can also use the used manual offsets like the TA. Now mesh those things !

Q: How can chose the constraint type when I want to automatically constrain a gear?
A: Below the gear selection tree, there is a drop-down menu. ( It shows "<Constraint Type>" at first )
   Click on it to select constraint type like Axis, BS, and so on ..

Q: How should I chose an anchor prop to constrain the gears to and how can I know what did I select?
A: Easy, see the "[ID]" selection on the toolgun screen next to the trace status. It indicates
   which prop is selected for "Anchor" ( A prop that the gears will be automatically constrained to )
   If it shows "N/A" ( Not Available ), then no anchor is selected.
   If it shows for example "[Entity_ID]", then an anchor is selected
   and all gears will be automatically constrained to it if enabled
   ( Constraint type different than "Free spawn" ). You can also clear it any time by pointing
   to the world and using IN_SPEED ( Def: Shift ) + click IN_ATTACK2 ( Def: Right mouse button ).

Q: You said this thing is pretty mush like the TA, which settings are the same?
A: The handling of Bodygroup/Skin selection, Mass, Gear's physical properties,
   Ghosting and stuff, Error logging, Screens, Translations and Data export/selection.

Q: I want to stack a gearbox relative to trace forward, but the gear tooth is directly placed
   on the angle forward vector. This makes the tool stack gears where the teeth are inside each
   other. What should I do?
A: Ah, this happens when the gear piece has even set of teeth. Adjust the trace pivot rotation
   until the tooth of the holder gear ( the piece that you are holding ) aligns with the gap of
   the trace gear. Take this number (For example 7.25) and divide it by two (3.625). Now use this
   same value (3.625) for both trace pivot rotation and piece ( holder pivot ) rotation.

Q: I have a hard time reading the lines and circles of the adviser. What do these visuals represent?
A: All the red lines are forward direction and the blues are the up direction vectors of all the
   angle orientations processed. The trace and the holder blue lines are the trace and holder pivot
   axises respectively. The green circles are the trace and domain mass-centers as position vectors.
   The green line is the origin right vector and the blue line the up vector. The yellow circle is the
   point where the gears mesh. The gear position is displayed on the screen in red. The mass-center is
   used for all internal position calculations and it is proper origin to relate the offset on. The
   world space distances between the mass-centers and positions are displayed with yellow line.
   The magenta lines represent the distance vectors between holder and trace to the mesh origin.
   If you are still confused about this, please take a look at the diagram below:
```
![GearAssemblyCoordinates](https://raw.githubusercontent.com/dvdvideo1234/GearAssemblyTool/LuaDB/data/pictures/coordinates.jpg)

**Distribution ownership is like the Track Assembly Tool, so DO NOT UPLOAD THIS TO ANY OTHER SITES !**

**I mean it !**
