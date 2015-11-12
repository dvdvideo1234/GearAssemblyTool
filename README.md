GearAssemblyTool-a
================

**Copyright 2015 ME !**

**IF YOU HAPPEN TO FIND REUPLOADS WITH DIFFERENT ORIGIN REPORT THEM TO ME IMMIDEATELY !!!**

![GearAssemblyTool](https://raw.githubusercontent.com/dvdvideo1234/GearAssemblyTool/master/screenshot.jpg)

 On the Steam WS: http://steamcommunity.com/sharedfiles/filedetails/?id=384782853

This is a Gmod tool for assembling Gears 

Genral FAQ:

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

Q: Dude, how can I make a mighty gear diff, like in the icon?
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
A: Easy, see the "Anc:" selection on the toolgun's screen. It indicates which prop is
   selected for "Anchor" ( A prop that the gears will be automatically constrained to )
   If it shows "N/A" ( Not Available ), then no anchor is selected.
   If it shows for example "[Entity_ID] Some_model_from_gmod.mdl", then an anchor
   is selected and all gears will be automatically constrained to it if enabled
   ( Constraint type different than "Free spawn" ). You can also clear it any time by pointing
   to the world and using IN_SPEED ( Def: Shift ) + click IN_ATTACK2 ( Def: Right mouse button ). 
   
Q: You said this thing is pretty mush like the TA, which settings are the same?
A: The handling of Bodygroup/Skin selection, Mass, Gear's physical properties,
   Ghosting and stuff, Error logging, Screens and Data selection.
```
**Destribution ownership is like the Track Assembly Tool, so DO NOT UPLOAD THIS TO ANY OTHER SITES !**

**I mean it !**
