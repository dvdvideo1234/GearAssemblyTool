--[[
 * The purpose of this Lua file is to add your gear pack pieces to the
 * gear assembly tool, so they can appear in the tool selection menu.
 * Why the name starts with /z/ you may ask. When Gmod loads the game
 * it goes trough all the Lua addons alphabetically.
 * That means your file name ( The file you are reading right now )
 * must be greater alphabetically than /asmlib/, so the API of the
 * module can be loaded before you can use it like seen below.
]]--
-- Local reference to the module
local asmlib = gearasmlib

-- Change this to your addon name
local myAddon = "RyuZU" -- Your addon name goes here
-- https://en.wikipedia.org/wiki/Clockwork_Planet
-- Yes, I am fan of the anime "Clockwork planet" and you can stop wondering now xD

-- Change this if you want to use different in-game type
local myType  = myAddon -- The type your addon resides in TA with

--[[
 * For actually produce an error you can replace the /print/
 * statement with one of following API calls:
 * http://wiki.garrysmod.com/page/Global/error
 * http://wiki.garrysmod.com/page/Global/Error
 * http://wiki.garrysmod.com/page/Global/ErrorNoHalt
]]
local myError = print

-- This is used for addon relation prefix. Fingers away from it
local myPrefix = myAddon:gsub("[^%w]","_")

if(asmlib) then
  -- This is the path to your DSV
  local myDsv = asmlib.GetOpVar("DIRPATH_BAS")..
                asmlib.GetOpVar("DIRPATH_DSV")..myPrefix..
                asmlib.GetOpVar("TOOLNAME_PU")
  local myFlag = file.Exists(myDsv.."PIECES.txt","DATA")

  -- This is the script path. It tells TA who wants to add these models
  -- Do not touch this also, it is used for debugging
  local myScript = debug.getinfo(1)
        myScript = myScript and myScript.source or "N/A"

  -- Tell TA what custom script we just called don't touch it
  asmlib.LogInstance(">>> "..myScript)

  -- And what parameters I was called with ;)
  asmlib.LogInstance("Status("..tostring(myFlag).."): {"..myAddon..", "..myPrefix.."}")

  --[[
   * Register the addon to the auto-load prefix list when the
   * PIECES file is missing. The auto-load list is located in
   * (/garrysmod/data/gearassembly/gearasmlib_dsv.txt)
   * a.k.a the DATA folder of Garry's mod
   *
   * @bSuccess = RegisterDSV(sProg, sPref, sDelim)
   * sProg  > The program which registered the DSV
   * sPref  > The external data prefix to be added ( default instance prefix )
   * sDelim > The delimiter to be used for processing ( default tab )
  ]]--
  if(myFlag) then
    asmlib.LogInstance("RegisterDSV skip <"..myPrefix..">")
  else
    if(not asmlib.RegisterDSV(myScript, myPrefix)) then
      myError("Failed to register DSV: "..myScript)
    end -- Third argument is the delimiter. The default tab is used
  end
  --[[
   * This is used if you want to make internal categories for your addon
   * You must make a function as a string under the hash of your addon
   * The function must take only one argument and that is the model
   * For every sub-category of your track pieces, you must return a table
   * with that much elements or return a /nil/ value to add the piece to
   * the root of your branch. You can also return a second value if you
   * want to override the track piece name.
  ]]--
  local myCategory ={
    [myType] = {Txt = [[
      function(m)
        local r = m:gsub("models/props_phx/construct/",""):gsub("_","/")
        local s = r:find("/"); r = s and r:sub(1,s-1) or nil
        local n = nil
        if(r) then
          if(r ==  "metal" ) then n = "My metal plate" end
          if(r == "windows") then n = "My glass plate" end
        end
        r = r and r:gsub("^%l", string.upper) or nil
        p = r and {r} or nil
        return p, n
      end
    ]]}
  }

  --[[
   * This logic statement is needed for reporting the error in the console if the
   * process fails.
   *
   @ bSuccess = ExportCategory(nInd, tData, sPref)
   * nInd   > The index equal indent format to be stored with ( generally = 3 )
   * tData  > The category functional definition you want to use to divide your stuff with
   * sPref  > An export file custom prefix. For synchronizing
   * it must be related to your addon ( default is instance prefix )
  ]]--
  if(CLIENT) then
    if(not asmlib.ExportCategory(3, myCategory, myPrefix)) then
      myError("Failed to synchronize category: "..myScript)
    end
  end

  --[[
   * Create a table and populate it as shown below
   * In the square brackets goes your model,
   * and then for every active point, you must have one array of
   * strings, where the elements match the following data settings.
   * You can use the reverse sign event /@/ to reverse any component of the
   * parameterization and also the disable event /#/ to make TA auto-fill
   * the value provided {TYPE, NAME, AMESH, POINT, ORIGIN, ANGLE, CLASS}
   * TYPE   > This string is the name of the type your stuff will reside in the panel
   *          Disabling this, makes it use the value of the /DEFAULT_TYPE/ variable
   *          If it is empty uses the string /TYPE/, so make sure you fill this
   * NAME   > This is the name of your track piece. Put /#/ here to be auto-generated from
   *          the model ( from the last slash to the file extension )
   * AMESH  > This is the meshing additional angle it is mandatory and represents
   *          the base angle of the teeth when meshing gears. For example bevels have 45.
   * POINT  > This is the position vector that is used to get the gear leverage.
   *          It is mandatory and tells the tool how far from the mass-center is the meshing point
   * ORIGIN > This is the mass-center of the piece and it is mandatory.
   * ANGLE  > This is the angle relative to which the forward and up vectors are calculated.
   *          An empty string is treated as {0,0,0}. Disabling this also makes it use {0,0,0}
   * CLASS  > This string is filled up when your entity class is not /prop_physics/ but something else
   *          used by ents.Create of the gmod ents API library. Keep this empty if your stuff is a normal prop
  ]]--
  local myTable = {
    ["models/props_trainstation/trainstation_clock001.mdl"] = {
      {myType,"#",0,"33.158,0,0","0.00034787258482538,0.01172979734838,0.00039185225614347","90,0,0",""}
    }
  }

  --[[
   * This logic statement is needed for reporting the error in the console if the
   * process fails.
   *
   @ bSuccess = SynchronizeDSV(sTable, tData, bRepl, sPref, sDelim)
   * sTable > The table you want to sync
   * tData  > A data table like the one described above
   * bRepl  > If set to /true/, makes the API to replace the repeating models with
              these of your addon. This is nice when you are constantly updating your track packs
              If set to /false/ keeps the current model in the
              database and ignores yours if they are the same file.
   * sPref  > An export file custom prefix. For synchronizing it must be related to your addon
   * sDelim > The delimiter used by the server/client ( default is a tab symbol )
   *
   @ bSuccess = TranslateDSV(sTable, sPref, sDelim)
   * sTable > The table you want to translate to Lua script
   * sPref  > An export file custom prefix. For synchronizing it must be related to your addon
   * sDelim > The delimiter used by the server/client ( default is a tab symbol )
  ]]--
  if(not asmlib.SynchronizeDSV("PIECES", myTable, true, myPrefix)) then
    myError("Failed to synchronize track pieces: "..myScript)
  else -- You are saving me from all the work for manually generating these
    if(not asmlib.TranslateDSV("PIECES", myPrefix)) then
      myError("Failed to translate DSV into Lua: "..myScript) end
  end -- Now we have Lua inserts and DSV

  asmlib.LogInstance("<<< "..myScript)
else
  myError("Failed loading the required module: "..myScript)
end