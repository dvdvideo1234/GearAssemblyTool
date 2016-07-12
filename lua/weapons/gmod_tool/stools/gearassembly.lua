---------------- Localizing Libraries ----------------
local type                  = type
local pairs                 = pairs
local Angle                 = Angle
local print                 = print
local Color                 = Color
local ipairs                = ipairs
local Vector                = Vector
local IsValid               = IsValid
local tonumber              = tonumber
local tostring              = tostring
local LocalPlayer           = LocalPlayer
local GetConVar             = GetConVar
local RunConsoleCommand     = RunConsoleCommand
local osDate                = os and os.date
local mathFloor             = math and math.floor
local vguiCreate            = vgui and vgui.Create
local fileExists            = file and file.Exists
local utilIsValidModel      = util and util.IsValidModel
local utilIsTraceLine       = util and util.TraceLine
local utilIsGetPlayerTrace  = util and util.GetPlayerTrace
local stringToFileName      = string and string.GetFileFromFilename
local cleanupRegister       = cleanup and cleanup.Register
local languageAdd           = language and language.Add
local concommandAdd         = concommand and concommand.Add
local duplicatorRegisterEntityModifier = duplicator and duplicator.RegisterEntityModifier

----------------- TOOL Global Parameters ----------------
--- Store a pointer to our module
local asmlib = gearasmlib
--- Because Vec[1] is actually faster than Vec.X
--- Vector Component indexes ---
local cvX, cvY, cvZ = asmlib.GetIndexes("V")
--- Angle Component indexes ---
local caP, caY, caR = asmlib.GetIndexes("A")

--- ZERO Objects
local VEC_ZERO = asmlib.GetOpVar("VEC_ZERO")
local ANG_ZERO = asmlib.GetOpVar("ANG_ZERO")

local goToolScr
local goMonitor
local gnRatio     = asmlib.GetOpVar("GOLDEN_RATIO")
local gnMaxOffRot = asmlib.GetOpVar("MAX_ROTATION")
local gnMaxErMode = asmlib.GetAsmVar("bnderrmod","STR")
local gsToolPrefL = asmlib.GetOpVar("TOOLNAME_PL")
local gsToolNameL = asmlib.GetOpVar("TOOLNAME_NL")
local gsToolPrefU = asmlib.GetOpVar("TOOLNAME_PU")
local gsToolNameU = asmlib.GetOpVar("TOOLNAME_NU")
local gsNameInitF = asmlib.GetOpVar("NAME_INIT")
      gsNameInitF = stringUpper(stringSub(gsNameInitF,1,1))..stringSub(gsNameInitF,2,-1)
local gsNamePerpF = asmlib.GetOpVar("NAME_PERP")
      gsNamePerpF = stringUpper(stringSub(gsNamePerpF,1,1))..stringSub(gsNamePerpF,2,-1)
local gsLimitName = asmlib.GetOpVar("CVAR_LIMITNAME")
local gsNoAnchor  = gsNoID..gsSymRev..gsNoMD

--- Render Base Colours
local conPalette = asmlib.MakeContainer("Colours")
      conPalette:Insert("r" ,Color(255, 0 , 0 ,255))
      conPalette:Insert("g" ,Color( 0 ,255, 0 ,255))
      conPalette:Insert("b" ,Color( 0 , 0 ,255,255))
      conPalette:Insert("c" ,Color( 0 ,255,255,255))
      conPalette:Insert("m" ,Color(255, 0 ,255,255))
      conPalette:Insert("y" ,Color(255,255, 0 ,255))
      conPalette:Insert("w" ,Color(255,255,255,255))
      conPalette:Insert("k" ,Color( 0 , 0 , 0 ,255))
      conPalette:Insert("gh",Color(255,255,255,150))
      conPalette:Insert("an",Color(180,255,150,255))
      conPalette:Insert("tx",Color(161,161,161,255))

local SMode = asmlib.GetOpVar("CONTAIN_STACK_MODE")
local CType = asmlib.GetOpVar("CONTAIN_CONSTRAINT_TYPE")

------------- LOCAL FUNCTIONS AND STUFF ----------------

if(CLIENT) then

  TOOL.Information = {
    { name = "info",  stage = 1   },
    { name = "left"         },
    { name = "right"        },
    { name = "right_use",   icon2 = "gui/e.png" },
    { name = "reload"       }
  }

  languageAdd("tool."..gsToolNameL..".name"      , gsNameInitF.." "..gsNamePerpF)
  languageAdd("tool."..gsToolNameL..".desc"      , "Assembles gears to mesh together")
  languageAdd("tool."..gsToolNameL..".0"         , "Left click to spawn/stack, Right to change mode, Reload to remove a piece")
  languageAdd("tool."..gsToolNameL..".left"      , "Spawn/snap a gear. Hold shift to stack")
  languageAdd("tool."..gsToolNameL..".right"     , "Switch stack mode. Hold shift for anchor selection")
  languageAdd("tool."..gsToolNameL..".right_use" , "Open frequently used pieces menu")
  languageAdd("tool."..gsToolNameL..".reload"    , "Remove a gear. Hold shift to select an anchor")
  languageAdd("tool."..gsToolNameL..".mass"      , "How heavy the piece spawned will be")
  languageAdd("tool."..gsToolNameL..".model"     , "Select the piece model to be used")
  languageAdd("tool."..gsToolNameL..".nextx"     , "Additional origin linear X offset")
  languageAdd("tool."..gsToolNameL..".nexty"     , "Additional origin linear Y offset")
  languageAdd("tool."..gsToolNameL..".nextz"     , "Additional origin linear Z offset")
  languageAdd("tool."..gsToolNameL..".count"     , "Maximum number of pieces to create while stacking")
  languageAdd("tool."..gsToolNameL..".contyp"    , "Select constraint type for the spawned piece")
  languageAdd("tool."..gsToolNameL..".stmode"    , "Select stack mode forward/pivot via right click")
  languageAdd("tool."..gsToolNameL..".freeze"    , "Makes the piece spawn in a frozen state")
  languageAdd("tool."..gsToolNameL..".adviser"   , "Controls rendering the tool position/angle adviser")
  languageAdd("tool."..gsToolNameL..".igntyp"    , "Makes the tool ignore the different piece types on snapping/stacking")
  languageAdd("tool."..gsToolNameL..".rotpivt"   , "Controls pivot angle offset when stacking/snapping")
  languageAdd("tool."..gsToolNameL..".rotpivh"   , "Rotate the piece local axis to precisely mesh the teeth")
  languageAdd("tool."..gsToolNameL..".nextpic"   , "Additional origin angular pitch offset")
  languageAdd("tool."..gsToolNameL..".nextyaw"   , "Additional origin angular yaw offset")
  languageAdd("tool."..gsToolNameL..".nextrol"   , "Additional origin angular roll offset")
  languageAdd("tool."..gsToolNameL..".trorang"   , "Use origin angle from trace")
  languageAdd("tool."..gsToolNameL..".bgskids"   , "Selection code of comma delimited Bodygroup/Skin IDs > ENTER to accept, TAB to auto-fill from trace")
  languageAdd("tool."..gsToolNameL..".spnflat"   , "Spawn the piece flat on the ground")
  languageAdd("tool."..gsToolNameL..".exportdb"  , "Controls the flag to export the database")
  languageAdd("tool."..gsToolNameL..".forcelim"  , "Controls how much force is needed to break the weld")
  languageAdd("tool."..gsToolNameL..".deltarot"  , "Controls the end-pivot angle when stacking")
  languageAdd("tool."..gsToolNameL..".gravity"   , "Controls the gravity on the piece spawned")
  languageAdd("tool."..gsToolNameL..".nocollide" , "Puts a no-collide between pieces and anchor/base")
  languageAdd("tool."..gsToolNameL..".ignphysgn" , "Ignores physics gun grab on the piece spawned/snapped/stacked")
  languageAdd("tool."..gsToolNameL..".ghosthold" ,"Controls rendering the tool ghosted holder piece")
  languageAdd("Cleanup_"..gsLimitName, gsNameInitF.." "..asmlib.GetOpVar("NAME_PERP").." pieces")
  languageAdd("Cleaned_"..gsLimitName, "Cleaned up all gear pieces")
  languageAdd("SBoxLimit_"..gsLimitName, "You've hit the Spawned gears limit!")
  concommandAdd(gsToolPrefL.."resetvars", asmlib.GetActionCode("RESET_VARIABLES"))
  concommandAdd(gsToolPrefL.."openframe", asmlib.GetActionCode("OPEN_FRAME"))
end

if(SERVER) then
  cleanupRegister(gsLimitName)
  duplicatorRegisterEntityModifier(gsToolPrefL.."ignphysgn",asmlib.GetActionCode("NO_PHYSGUN"))
end

TOOL.Category   = "Construction"            -- Name of the category
TOOL.Name       = "#tool."..gsToolNameL..".name" -- Name to display
TOOL.Command    = nil                       -- Command on click ( nil )
TOOL.ConfigName = nil                       -- Config file name ( nil )
TOOL.AddToMenu  = true                      -- Yo add it to the Q menu or not ( true )

TOOL.ClientConVar = {
  [ "mass"      ] = "250",
  [ "model"     ] = "models/props_phx/gears/spur9.mdl",
  [ "nextx"     ] = "0",
  [ "nexty"     ] = "0",
  [ "nextz"     ] = "0",
  [ "count"     ] = "1",
  [ "anchor"    ] = gsNoAnchor,
  [ "contyp"    ] = "1",
  [ "stmode"    ] = "1",
  [ "freeze"    ] = "0",
  [ "adviser"   ] = "1",
  [ "igntyp"    ] = "0",
  [ "rotpivt"   ] = "0",
  [ "rotpivh"   ] = "0",
  [ "gravity"   ] = "1",
  [ "nextpic"   ] = "0",
  [ "nextyaw"   ] = "0",
  [ "nextrol"   ] = "0",
  [ "trorang"   ] = "0",
  [ "bgskids"   ] = "",
  [ "spnflat"   ] = "0",
  [ "exportdb"  ] = "0",
  [ "forcelim"  ] = "0",
  [ "deltarot"  ] = "360",
  [ "maxstatts" ] = "3",
  [ "nocollide" ] = "0",
  [ "ignphysgn" ] = "0"
  [ "ghosthold" ] = "0",
}

function TOOL:GetModel()
  return self:GetClientInfo("model") or ""
end

function TOOL:GetCount()
  return math.Clamp(self:GetClientNumber("count"),1,asmlib.GetAsmVar("maxstcnt","INT"))
end

function TOOL:GetMass()
  return math.Clamp(self:GetClientNumber("mass"),1,asmlib.GetAsmVar("maxmass","FLT"))
end

function TOOL:GetDeveloperMode()
  return (asmlib.GetAsmVar("devmode","INT") or 0)
end

function TOOL:GetPosOffsets()
  local nMaxOffLin = asmlib.GetAsmVar("maxlinear","FLT")
  return (math.Clamp(self:GetClientNumber("nextx") or 0,-nMaxOffLin,nMaxOffLin)),
         (math.Clamp(self:GetClientNumber("nexty") or 0,-nMaxOffLin,nMaxOffLin)),
         (math.Clamp(self:GetClientNumber("nextz") or 0,-nMaxOffLin,nMaxOffLin))
end

function TOOL:GetAngOffsets()
  return (math.Clamp(self:GetClientNumber("nextpic") or 0,-gnMaxOffRot,gnMaxOffRot)),
         (math.Clamp(self:GetClientNumber("nextyaw") or 0,-gnMaxOffRot,gnMaxOffRot)),
         (math.Clamp(self:GetClientNumber("nextrol") or 0,-gnMaxOffRot,gnMaxOffRot))
end

function TOOL:GetFreeze()
  return (self:GetClientNumber("freeze") or 0)
end

function TOOL:GetIgnoreType()
  return (self:GetClientNumber("igntyp") or 0)
end

function TOOL:GetBodyGroupSkin()
  return (self:GetClientInfo("bgskids") or "")
end

function TOOL:GetGravity()
  return (self:GetClientNumber("gravity") or 0)
end

function TOOL:GetGhostHolder()
  return (self:GetClientNumber("ghosthold") or 0)
end

function TOOL:GetNoCollide()
  return (self:GetClientNumber("nocollide") or 0)
end

function TOOL:GetSpawnFlat()
  return (self:GetClientNumber("spnflat") or 0)
end

function TOOL:GetExportDB()
  return (self:GetClientNumber("exportdb") or 0)
end

function TOOL:GetLogLines()
  return (asmlib.GetAsmVar("logsmax","INT") or 0)
end

function TOOL:GetLogFile()
  return (asmlib.GetAsmVar("logfile","STR") or "")
end

function TOOL:GetAdviser()
  return (self:GetClientNumber("adviser") or 0)
end

function TOOL:GetTraceOriginAngle()
  return (self:GetClientNumber("trorang") or 0)
end

function TOOL:GetStackAttempts()
  return math.Clamp(self:GetClientNumber("maxstaatts"),1,5)
end

function TOOL:GetRotatePivot()
  return math.Clamp(self:GetClientNumber("rotpivt") or 0,-gnMaxOffRot,gnMaxOffRot),
         math.Clamp(self:GetClientNumber("rotpivh") or 0,-gnMaxOffRot,gnMaxOffRot)
end

function TOOL:GetDeltaRotation()
  return math.Clamp(self:GetClientNumber("deltarot") or 0,-gnMaxOffRot,gnMaxOffRot)
end

function TOOL:GetForceLimit()
  return math.Clamp(self:GetClientNumber("forcelim") or 0,0,asmlib.GetAsmVar("maxforce","FLT"))
end

function TOOL:GetStackMode()
  return (self:GetClientNumber("stmode") or 1)
end

function TOOL:GetContrType()
  return (self:GetClientNumber("contyp") or 1)
end

function TOOL:GetIgnorePhysgun()
  return (self:GetClientNumber("ignphysgn") or 0)
end

function TOOL:GetBoundErrorMode()
  return asmlib.GetAsmVar("bnderrmod","STR")
end

function TOOL:SetAnchor(stTrace)
  self:ClearAnchor()
  if(not stTrace) then return asmlib.StatusLog(false,"TOOL:SetAnchor(): Trace invalid") end
  if(not stTrace.Hit) then return asmlib.StatusLog(false,"TOOL:SetAnchor(): Trace not hit") end
  local trEnt = stTrace.Entity
  if(not (trEnt and trEnt:IsValid())) then return asmlib.StatusLog(false,"TOOL:SetAnchor(): Trace no entity") end
  local phEnt = trEnt:GetPhysicsObject()
  if(not (phEnt and phEnt:IsValid())) then return asmlib.StatusLog(false,"TOOL:SetAnchor(): Trace no physics") end
  local plPly = self:GetOwner()
  if(not (plPly and plPly:IsValid())) then return asmlib.StatusLog(false,"TOOL:SetAnchor(): Player invalid") end
  local sAnchor = trEnt:EntIndex()..gsSymRev..stringToFileName(trEnt:GetModel())
  trEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
  trEnt:SetColor(conPalette:Select("an"))
  self:SetObject(1,trEnt,stTrace.HitPos,phEnt,stTrace.PhysicsBone,stTrace.HitNormal)
  asmlib.ConCommandPly(plPly,"anchor",sAnchor)
  asmlib.PrintNotifyPly(plPly,"Anchor: Set "..sAnchor.." !","UNDO")
  return asmlib.StatusLog(true,"TOOL:SetAnchor("..sAnchor..")")
end

function TOOL:ClearAnchor()
  local svEnt = self:GetEnt(1)
  local plPly = self:GetOwner()
  if(svEnt and svEnt:IsValid()) then
    svEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
    svEnt:SetColor(conPalette:Select("w"))
  end
  self:ClearObjects()
  asmlib.PrintNotifyPly(plPly,"Anchor: Cleaned !","CLEANUP")
  asmlib.ConCommandPly(plPly,"anchor",gsNoAnchor)
  return asmlib.StatusLog(true,"TOOL:ClearAnchor(): Anchor cleared")
end

function TOOL:GetAnchor()
  local svEnt = self:GetEnt(1)
  if(not (svEnt and svEnt:IsValid())) then svEnt = nil end
  return (self:GetClientInfo("anchor") or gsNoAnchor), svEnt
end

function TOOL:GetStatus(stTrace,anyMessage,hdEnt)
  local iMaxlog = asmlib.GetOpVar("LOG_MAXLOGS")
  if(not (iMaxlog > 0)) then return "Status N/A" end
  local ply, sDelim  = self:GetOwner(), "\n"
  local iCurLog = asmlib.GetOpVar("LOG_CURLOGS")
  local sFleLog = asmlib.GetOpVar("LOG_LOGFILE")
  local sSpace  = stringRep(" ",6 + stringLen(tostring(iMaxlog)))
  local plyKeys = asmlib.LoadKeyPly(ply,"DEBUG")
  local rotpivt, rotpivh = self:GetRotatePivot()
  local aninfo , anEnt   = self:GetAnchor()
  local nextx  , nexty  , nextz   = self:GetPosOffsets()
  local nextpic, nextyaw, nextrol = self:GetAngOffsets()
  local hdModel, trModel, trRec   = self:GetModel()
  local hdRec   = asmlib.CacheQueryPiece(hdModel)
  if(stTrace and stTrace.Entity and stTrace.Entity:IsValid()) then
    trModel = stTrace.Entity:GetModel()
    trRec   = asmlib.CacheQueryPiece(trModel)
  end
  local sDu = ""
        sDu = sDu..tostring(anyMessage)..sDelim
        sDu = sDu..sSpace.."Dumping logs state:"..sDelim
        sDu = sDu..sSpace.."  LogsMax:        <"..tostring(iMaxlog)..">"..sDelim
        sDu = sDu..sSpace.."  LogsCur:        <"..tostring(iCurLog)..">"..sDelim
        sDu = sDu..sSpace.."  LogFile:        <"..tostring(sFleLog)..">"..sDelim
        sDu = sDu..sSpace.."  MaxProps:       <"..tostring(GetConVar("sbox_maxprops","INT"))..">"..sDelim
        sDu = sDu..sSpace.."  MaxTrack:       <"..tostring(GetConVar("sbox_max"..gsLimitName,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."Dumping player keys:"..sDelim
        sDu = sDu..sSpace.."  Player:         "..stringGsub(tostring(ply),"Player%s","")..sDelim
        sDu = sDu..sSpace.."  IN.USE:         <"..tostring(plyKeys["USE"])..">"..sDelim
        sDu = sDu..sSpace.."  IN.DUCK:        <"..tostring(plyKeys["DUCK"])..">"..sDelim
        sDu = sDu..sSpace.."  IN.SPEED:       <"..tostring(plyKeys["SPEED"])..">"..sDelim
        sDu = sDu..sSpace.."  IN.RELOAD:      <"..tostring(plyKeys["RELOAD"])..">"..sDelim
        sDu = sDu..sSpace.."  IN.SCORE:       <"..tostring(plyKeys["SCORE"])..">"..sDelim
        sDu = sDu..sSpace.."Dumping trace data state:"..sDelim
        sDu = sDu..sSpace.."  Trace:          <"..tostring(stTrace)..">"..sDelim
        sDu = sDu..sSpace.."  TR.Hit:         <"..tostring(stTrace and stTrace.Hit or gsNoAV)..">"..sDelim
        sDu = sDu..sSpace.."  TR.HitW:        <"..tostring(stTrace and stTrace.HitWorld or gsNoAV)..">"..sDelim
        sDu = sDu..sSpace.."  TR.ENT:         <"..tostring(stTrace and stTrace.Entity or gsNoAV)..">"..sDelim
        sDu = sDu..sSpace.."  TR.Model:       <"..tostring(trModel or gsNoAV)..">["..tostring(trRec and trRec.Kept or gsNoID).."]"..sDelim
        sDu = sDu..sSpace.."  TR.File:        <"..stringToFileName(tostring(trModel or gsNoAV))..">"..sDelim
        sDu = sDu..sSpace.."Dumping console variables state:"..sDelim
        sDu = sDu..sSpace.."  HD.Entity:      {"..tostring(hdEnt or gsNoAV).."}"..sDelim
        sDu = sDu..sSpace.."  HD.Model:       <"..tostring(hdModel or gsNoAV)..">["..tostring(hdRec and hdRec.Kept or gsNoID).."]"..sDelim
        sDu = sDu..sSpace.."  HD.File:        <"..stringToFileName(tostring(hdModel or gsNoAV))..">"..sDelim
        sDu = sDu..sSpace.."  HD.Mass:        <"..tostring(self:GetMass())..">"..sDelim
        sDu = sDu..sSpace.."  HD.StackCNT:    <"..tostring(self:GetCount())..">"..sDelim
        sDu = sDu..sSpace.."  HD.Gravity:     <"..tostring(self:GetGravity())..">"..sDelim
        sDu = sDu..sSpace.."  HD.Adviser:     <"..tostring(self:GetAdviser())..">"..sDelim
        sDu = sDu..sSpace.."  HD.ExportDB:    <"..tostring(self:GetExportDB())..">"..sDelim
        sDu = sDu..sSpace.."  HD.NoCollide:   <"..tostring(self:GetNoCollide())..">"..sDelim
        sDu = sDu..sSpace.."  HD.SpawnFlat:   <"..tostring(self:GetSpawnFlat())..">"..sDelim
        sDu = sDu..sSpace.."  HD.IgnoreType:  <"..tostring(self:GetIgnoreType())..">"..sDelim
        sDu = sDu..sSpace.."  HD.ForceLimit:  <"..tostring(self:GetForceLimit())..">"..sDelim
        sDu = sDu..sSpace.."  HD.GhostHold:   <"..tostring(self:GetGhostHolder())..">"..sDelim
        sDu = sDu..sSpace.."  HD.SkinBG:      <"..tostring(self:GetBodyGroupSkin())..">"..sDelim
        sDu = sDu..sSpace.."  HD.StackAtempt: <"..tostring(self:GetStackAttempts())..">"..sDelim
        sDu = sDu..sSpace.."  HD.IgnorePG:    <"..tostring(self:GetIgnorePhysgun())..">"..sDelim
        sDu = sDu..sSpace.."  HD.ModDataBase: <"..gsModeDataB..","..tostring(asmlib.GetAsmVar("modedb" ,"STR"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.EnableStore: <"..tostring(gsQueryStr)..","..tostring(asmlib.GetAsmVar("enqstore","INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.TimerMode:   <"..tostring(asmlib.GetAsmVar("timermode","STR"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.EnableWire:  <"..tostring(asmlib.GetAsmVar("enwiremod","INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.DevelopMode: <"..tostring(asmlib.GetAsmVar("devmode"  ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxMass:     <"..tostring(asmlib.GetAsmVar("maxmass"  ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxLinear:   <"..tostring(asmlib.GetAsmVar("maxlinear","INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxForce:    <"..tostring(asmlib.GetAsmVar("maxforce" ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxStackCnt: <"..tostring(asmlib.GetAsmVar("maxstcnt" ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.BoundErrMod: <"..tostring(asmlib.GetAsmVar("bnderrmod","STR"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxFrequent: <"..tostring(asmlib.GetAsmVar("maxfruse" ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.RotatePivot: {"..tostring(rotpivt)..", "..tostring(rotpivh).."}"..sDelim
        sDu = sDu..sSpace.."  HD.Anchor:      {"..tostring(anEnt or gsNoAV).."}<"..tostring(aninfo)..">"..sDelim
        sDu = sDu..sSpace.."  HD.AngOffsets:  ["..tostring(nextx)..","..tostring(nexty)..","..tostring(nextz).."]"..sDelim
        sDu = sDu..sSpace.."  HD.PosOffsets:  ["..tostring(nextpic)..","..tostring(nextyaw)..","..tostring(nextrol).."]"..sDelim
  if(hdEnt and hdEnt:IsValid()) then hdEnt:Remove() end
  return sDu
end

function TOOL:LeftClick(stTrace)
  if(CLIENT) then
    return asmlib.StatusLog(true,"TOOL:LeftClick(): Working on client") end
  if(not stTrace) then
    return asmlib.StatusLog(false,"TOOL:LeftClick(): Trace missing") end
  if(not stTrace.Hit) then
    return asmlib.StatusLog(false,"TOOL:LeftClick(): Trace not hit") end
  local trEnt     = stTrace.Entity
  local ply       = self:GetOwner()
  local model     = self:GetModel()
  local freeze    = self:GetFreeze()
  local igntyp    = self:GetIgnoreType()
  local bgskids   = self:GetBodyGroupSkin()
  local gravity   = self:GetGravity()
  local nocollide = self:GetNoCollide()
  local spnflat   = self:GetSpawnFlat()
  local trorang   = self:GetTraceOriginAngle()
  local count     = self:GetCount()
  local mass      = self:GetMass()
  local staatts   = self:GetStackAttempts()
  local deltarot  = self:GetDeltaRotation()
  local forcelim  = self:GetForceLimit()
  local ignphysgn = self:GetIgnorePhysgun()
  local bnderrmod = self:GetBoundErrorMode()
  local fnmodel   = stringToFileName(model)
  local stmode    = asmlib.GetCorrectID(self:GetStackMode(),SMode)
  local contyp    = asmlib.GetCorrectID(self:GetContrType(),CType)
  local aninfo , eBase   = self:GetAnchor()
  local rotpivt, rotpivh = self:GetRotatePivot()
  local nextx  , nexty  , nextz   = self:GetPosOffsets()
  local nextpic, nextyaw, nextrol = self:GetAngOffsets()
  asmlib.PlyLoadKey(ply)
  if(not asmlib.PlyLoadKey(ply,"SPEED") and not asmlib.PlyLoadKey(ply,"DUCK")) then
    if(not (eBase and eBase:IsValid()) and (trEnt and trEnt:IsValid())) then eBase = trEnt end
    local stSpawn = asmlib.GetNormalSpawn(stTrace,model,rotpivh,nextx,nexty,nextz,
                                              nextpic,nextyaw,nextrol)
    if(not stSpawn) then return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(World): Normal spawn failed")) end
    local ePiece = asmlib.MakePiece(ply,model,stTrace.HitPos,ANG_ZERO,mass,bgskids,conPalette:Select("w"),bnderrmod)
    if(not ePiece) then return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(World): Making piece failed")) end
    stSpawn.SPos:Add(asmlib.GetCustomAngBBZ(ePiece,stSpawn.HRec,spnflat) * stTrace.HitNormal)
    ePiece:SetAngles(stSpawn.SAng); ePiece:SetPos   (stSpawn.SPos)
    asmlib.UndoCratePly(gsUndoPrefN..fnmodel.." ( World spawn )")
    if(not asmlib.ApplyPhysicalSettings(ePiece,freeze,gravity,ignphysgn)) then
      return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(World): Failed to apply physical settings",ePiece)) end
    if(not asmlib.ApplyPhysicalAnchor(ePiece,eBase,stTrace.HitPos,stTrace.HitNormal,contyp,nocollide,forcelim)) then
      return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(World): Failed to apply physical anchor",ePiece)) end
    asmlib.UndoAddEntityPly(ePiece)
    asmlib.UndoFinishPly(ply)
    return asmlib.StatusLog(true,"TOOL:LeftClick(World): Success hit world")
  end

  if(not (trEnt and trEnt:IsValid())) then
    return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Prop): Trace entity invalid")) end
  if(asmlib.IsOther(trEnt)) then
    return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Prop): Trace is other type of object")) end
  if(not asmlib.IsPhysTrace(stTrace)) then
    return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Prop): Trace is not physical object")) end

  local trModel = trEnt:GetModel()
  local bsModel = "N/A"
  if(eBase and eBase:IsValid()) then bsModel = eBase:GetModel() end

  --No need stacking relative to non-persistent props or using them...
  local hdRec   = asmlib.CacheQueryPiece(model)
  local trRec   = asmlib.CacheQueryPiece(trModel)

  if(not trRec) then return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Prop): Trace model not a piece")) end

  if(asmlib.PlyLoadKey(ply,"DUCK")) then -- USE: Use the valid trace as a piece
    if(asmlib.PlyLoadKey(ply,"USE")) then -- Physical
      if(not asmlib.ApplyPhysicalSettings(trEnt,freeze,gravity,ignphysgn)) then
        return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Physical): Failed to apply physical settings",trEnt)) end
      trEnt:GetPhysicsObject():SetMass(mass)
      return asmlib.StatusLog(true,"TOOL:LeftClick(Physical): Success")
    else -- Model
      asmlib.ConCommandPly(ply,"model",trModel)
      asmlib.PrintNotifyPly(ply,"Model: "..fnmodel.." selected !","GENERIC")
      return asmlib.StatusLog(true,"TOOL:LeftClick(Select): Success <"..trModel..">")
    end
  end

  if(not hdRec) then return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Prop): Holder model not a piece")) end

  if(asmlib.PlyLoadKey(ply,"SPEED") and count > 1 and stmode >= 1 and stmode <= SMode:GetSize()) then
    local stSpawn = asmlib.GetEntitySpawn(trEnt,rotpiv,model,igntyp,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Stack): Failed to retrieve spawn data")) end
    local ePieceO, ePieceN = trEnt, nil
    local aIter  , aStart  = ePieceO:GetAngles(), ePieceO:GetAngles()
    local iNdex  , nTrys, dRot = count, staatts, (deltarot / count)
    asmlib.UndoCratePly(gsUndoPrefN..fnmodel.." ( Stack #"..tostring(count).." )")
    while(iNdex > 0) do
      local sIterat = "["..tostring(iNdex).."]"
      ePieceN = asmlib.MakePiece(ply,model,stSpawn.SPos,stSpawn.SAng,mass,bgskids,conPalette:Select("w"),bnderrmod)
      if(ePieceN) then
        if(not asmlib.ApplyPhysicalSettings(ePieceN,forcelim,freeze,gravity,ignphysgn)) then
          return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Stack): Failed to apply physical settings",ePiece)) end
        if(not asmlib.ApplyPhysicalAnchor(ePieceN,eBase,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim)) then
          return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Stack): Failed to apply physical anchor",ePiece)) end
        asmlib.UndoAddEntityPly(ePieceN)
        if(stmode == 1) then
          stSpawn = asmlib.GetEntitySpawn(ePieceN,rotpiv,model,igntyp,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
        elseif(stmode == 2) then
          aIter:RotateAroundAxis(stSpawn.CAng:Up(),-dRot)
          trEnt:SetAngles(aIter)
          stSpawn = asmlib.GetEntitySpawn(trEnt,rotpiv,model,igntyp,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
        end
        if(not stSpawn) then -- Look both ways in a one way street :D
          asmlib.PrintNotifyPly(ply,"Cannot obtain spawn data!","ERROR")
          asmlib.UndoFinishPly(ply,sIterat)
          return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Stack)"..sIterat..": Stacking has invalid user data"))
        end -- Spawn data is valid for the current iteration iNdex
        ePieceO, iNdex, nTrys = ePieceN, (iNdex - 1), staatts
      else nTrys = nTrys - 1 end
      if(iTrys <= 0) then
        asmlib.UndoFinishPly(ply,sIterat) --  Make it shoot but throw the error
        return asmlib.StatusLog(true,self:GetStatus(stTrace,"TOOL:LeftClick(Stack)"..sIterat..": All stack attempts failed"))
      end -- We still have enough memory to preform the stacking
    end
    trEnt:SetAngles(aStart)
    asmlib.UndoFinishPly(ply)
    return asmlib.StatusLog(true,"TOOL:LeftClick(Stack): Success stacking")
  end

  local stSpawn = asmlib.GetEntitySpawn(trEnt,rotpiv,model,igntyp,
                    trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
  if(stSpawn) then
    local ePiece = asmlib.MakePiece(ply,model,stSpawn.SPos,stSpawn.SAng,mass,bgskids,conPalette:Select("w"),bnderrmod)
    if(ePiece) then
      if(not asmlib.ApplyPhysicalSettings(ePieceN,forcelim,freeze,gravity,ignphysgn)) then
        return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Snap): Failed to apply physical settings",ePiece)) end
      if(not ApplyPhysicalAnchor(ePiece,eBase,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim,freeze,gravity,ignphysgn)) then
        return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Snap): Failed to apply physical anchor",ePiece)) end
      asmlib.UndoCratePly(gsUndoPrefN..fnmodel.." ( Snap prop )")
      asmlib.UndoAddEntityPly(ePiece)
      asmlib.UndoFinishPly(ply)
      return asmlib.StatusLog(true,"TOOL:LeftClick(Snap): Success")
    end
  end
  return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Snap): Crating piece failed"))
end

function TOOL:RightClick(stTrace)
  if(CLIENT) then
    return asmlib.StatusLog(true,"TOOL:RightClick(): Working on client") end
  if(not stTrace) then
    return asmlib.StatusLog(false,"TOOL:RightClick(): Trace missing") end
  if(not stTrace.Hit) then
    return asmlib.StatusLog(false,"TOOL:RightClick(): Trace not hit") end
  local trEnt = Trace.Entity
  local ply   = self:GetOwner()
  asmlib.PlyLoadKey(ply)
  if(Trace.HitWorld and asmlib.PlyLoadKey(ply,"USE")) then
    asmlib.ConCommandPly(ply,"openframe",asmlib.GetAsmVar("maxfruse" ,"INT"))
    return asmlib.StatusLog(true,"TOOL:RightClick(World): Success open frame")
  elseif(asmlib.PlyLoadKey(ply,"SPEED")) then
    if(Trace.HitWorld) then
      self:ClearAnchor(); return asmlib.StatusLog(true,"TOOL:RightClick(Prop): Anchor cleared")
    elseif(trEnt and trEnt:IsValid()) then
      if(not asmlib.IsPhysTrace(stTrace)) then return false end
      if(asmlib.IsOther(trEnt)) then return false end
      self:SetAnchor(Trace); return asmlib.StatusLog(true,"TOOL:RightClick(Prop): Anchor set")
    else return asmlib.StatusLog(true,self:GetStaus(stTrace,"TOOL:RightClick(Prop): Invalid action",trEnt) end
  else
    local stmode = asmlib.GetCorrectID(self:GetStackMode(),SMode)
          stmode = asmlib.GetCorrectID(stmode + 1,SMode)
    asmlib.ConCommandPly(ply,"stmode",stmode)
    asmlib.PrintNotifyPly(ply,"Stack Mode: "..SMode:Select(stmode).." !","UNDO")
    return true
  end
end

function TOOL:Reload(Trace)
  if(CLIENT) then return true end
  if(not Trace) then return false end
  local ply       = self:GetOwner()
  asmlib.PlyLoadKey(ply)
  if(asmlib.PlyLoadKey(ply,"SPEED") and Trace.HitWorld) then
    asmlib.SetLogControl(self:GetLogLines(),self:GetLogFile())
    if(self:GetExportDB() ~= 0) then
      asmlib.StoreExternalDatabase("PIECES", ",","INS")
      asmlib.StoreExternalDatabase("PIECES","\t","DSV")
      return asmlib.StatusLog(true,"TOOL:Reload(Trace) > DB Exported")
    end
  end
  if(not asmlib.IsPhysTrace(Trace)) then
    return asmlib.StatusLog(false,self:GetStaus(stTrace,"TOOL:Reload(): Trace not physics") end
  local trEnt = Trace.Entity
  if(asmlib.IsOther(trEnt)) then
    return asmlib.StatusLog(false,self:GetStaus(stTrace,"TOOL:Reload(): Entity is other",trEnt) end
  local trRec = asmlib.CacheQueryPiece(trEnt:GetModel())
  if(trRec) then trEnt:Remove(); return asmlib.StatusLog(true,"TOOL:Reload(Prop): Removed a piece") end
  return asmlib.StatusLog(false,"TOOL:Reload(): Nothing removed")
end

function TOOL:Holster()
  self:ReleaseGhostEntity()
  if(self.GhostEntity and self.GhostEntity:IsValid()) then
    self.GhostEntity:Remove()
  end
end

local function DrawAdditionalInfo(oScreen,stSpawn)
  if(not oScreen) then return end
  if(not stSpawn) then return end
  local x, y = oScreen:GetCenter(10,10)
  oScreen:SetTextEdge(x,y)
  oScreen:DrawText("Org POS: "..tostring(stSpawn.OPos)"k","SURF",{"Trebuchet18"})
  oScreen:DrawText("Dom ANG: "..tostring(stSpawn.DAng))
  oScreen:DrawText("Mod POS: "..tostring(stSpawn.MPos))
  oScreen:DrawText("Mod ANG: "..tostring(stSpawn.MAng))
  oScreen:DrawText("Spn POS: "..tostring(stSpawn.SPos))
  oScreen:DrawText("Spn ANG: "..tostring(stSpawn.SAng))
end

function TOOL:DrawHUD()
  if(SERVER) then return end
  if(not goMonitor) then
    goMonitor = asmlib.MakeScreen(0,0,
                  surface.ScreenWidth(),
                  surface.ScreenHeight(),conPalette,false)
    if(not goMonitor) then
      asmlib.PrintInstance(gsToolNameU..": DrawHUD: Invalid screen")
      return
    end
  end
  goMonitor:SetColor()
  local ply   = LocalPlayer()
  local Trace = ply:GetEyeTrace()
  if(not Trace) then return end
  if(self:GetAdviser() == 0) then return end
  local trEnt  = Trace.Entity
  local model  = self:GetModel()
  local ratioc = (gnRatio - 1) * 100
  local ratiom = (gnRatio * 1000)
  local plyd   = (stTrace.HitPos - ply:GetPos()):Length()
  local plyrad = mathClamp((ratiom / plyd) * (stSpawn.RLen / actrad),1,ratioc)
  local nextx, nexty, nextz = self:GetPosOffsets()
  local nextpic, nextyaw, nextrol = self:GetAngOffsets()
  asmlib.PlyLoadKey(ply)
  if(trEnt and trEnt:IsValid() and asmlib.PlyLoadKey(ply,"SPEED")) then
    if(asmlib.IsOther(trEnt)) then return end
    local igntyp  = self:GetIgnoreType()
    local trorang = self:GetTraceOriginAngle()
    local rotpivt, rotpivh = self:GetRotatePivot()
    local stSpawn = asmlib.GetEntitySpawn(trEnt,rotpiv,model,igntyp,
                      trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return end
    local Op =  stSpawn.OPos:ToScreen()
    local Xs = (stSpawn.OPos + 15 * stSpawn.F):ToScreen()
    local Ys = (stSpawn.OPos + 15 * stSpawn.R):ToScreen()
    local Zs = (stSpawn.OPos + 15 * stSpawn.U):ToScreen()
    local Sp =  stSpawn.SPos:ToScreen()
    local Df = (stSpawn.SPos + 15 * stSpawn.DAng:Forward()):ToScreen()
    local Du = (stSpawn.SPos + 15 * stSpawn.DAng:Up()):ToScreen()
    local Cp =  stSpawn.CPos:ToScreen()
    local Cu = (stSpawn.CPos + 15 * stSpawn.CAng:Up()):ToScreen()
    -- Draw UCS
    goMonitor:DrawLine(Op,Xs,"r","SURF")-- Base X
    goMonitor:DrawLine(Sp,Df)           -- Next
    goMonitor:DrawLine(Op,Zs,"b")       -- Base Z
    goMonitor:DrawLine(Cp,Cu,"y")       -- Base Z
    goMonitor:DrawCircle(Op,plyrad)     -- Base O
    goMonitor:DrawLine(Op,Ys,"g")
    goMonitor:DrawLine(Cp,Op)
    goMonitor:DrawCircle(Cp,plyrad)
    goMonitor:DrawLine(Op,Sp,"m")
    goMonitor:DrawCircle(Sp,Sp,plyrad)
    goMonitor:DrawLine(Sp,Du,"c")
    if(self:GetDeveloperMode() ~= 0) then DrawAdditionalInfo(goMonitor,stSpawn) end
  else
    local stSpawn  = asmlib.GetNormalSpawn(Trace,model,
                       nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return false end
    local Os = stSpawn.SPos:ToScreen()
    local Xs = (stSpawn.SPos + 15 * stSpawn.F):ToScreen()
    local Ys = (stSpawn.SPos + 15 * stSpawn.R):ToScreen()
    local Zs = (stSpawn.SPos + 15 * stSpawn.U):ToScreen()
    goMonitor:DrawLine(Os,Xs,"r")
    goMonitor:DrawLine(Os,Ys,"g")
    goMonitor:DrawLine(Os,Zs,"b")
    goMonitor:DrawCircle(Os,plyrad,"y")
    if(self:GetDeveloperMode() ~= 0) then DrawAdditionalInfo(goMonitor,stSpawn) end
  end
end

local function DrawRatioVisual(oScreen,nTrR,nHdR,nDeep)
  if(not oScreen) then return end
  local hDeep = mathFloor((nDeep or 0) / 2)
  if(hDeep <= 2) then return end
  local nW, nH = oScreen:GetSize()
  local dx, dy, dw, dh = oScreen:GetTextState(0,0,0,2)
  if(nTrR) then
    local Cent = mathFloor((nTrR / ( nTrR + nHdR )) * nW)
    oScreen:DrawRect(0,dh,nDeep,nH-dy,"y")               -- Trace Teeth
    oScreen:DrawRect(nDeep,dh,Cent-hDeep,nH-dy,"g")      -- Trace Gear
    oScreen:DrawRect(Cent-hDeep,dh,Cent+hDeep,nH-dy,"y") -- Meshing
    oScreen:DrawRect(Cent+hDeep,dh,nW-nDeep,nH-dy,"m")   -- Holds Gear
    oScreen:DrawRect(nW-nDeep,dh,nW,nH-dy,"y")           -- Holds Teeth
  else
    oScreen:DrawRect(0,dh,nDeep,nH-dy,"y")               -- Holds Teeth
    oScreen:DrawRect(nDeep,dh,nW-nDeep,nH-dy,"g")        -- Holds
    oScreen:DrawRect(nW-nDeep,dh,nW,nH-dy,"y")           -- Holds Teeth
  end
end

function TOOL:DrawToolScreen(w, h)
  if(SERVER) then return end
  if(not goToolScr) then
    goToolScr = asmlib.MakeScreen(0,0,w,h,conPalette,false)
    if(not goToolScr) then
      asmlib.PrintInstance(gsToolNameU..": DrawToolScreen: Invalid screen")
      return
    end
  end
  goToolScr:SetColor()
  goToolScr:DrawBackGround("k")
  goToolScr:SetTextEdge(0,0)
  local Trace = LocalPlayer():GetEyeTrace()
  if(not Trace) then
    goToolScr:DrawText("Trace status: Invalid","r","SURF",{"Trebuchet24"})
    goToolScr:DrawTextAdd("  ["..(tInfo[1] or gsNoID).."]","an")
    return
  end
  goToolScr:DrawText("Trace status: Valid","g","SURF",{"Trebuchet24"})
  goToolScr:DrawTextAdd("  ["..(tInfo[1] or gsNoID).."]","an")
  local model = self:GetModel()
  local hdRec = asmlib.CacheQueryPiece(model)
  if(not hdRec) then
    goToolScr:DrawText("Holds Model: Invalid","r")
    goToolScr:DrawTextAdd("  ["..gsModeDataB.."]","db")
    return
  end
  goToolScr:DrawText("Holds Model: Valid","g")
  goToolScr:DrawTextAdd("  ["..gsModeDataB.."]","db")
  local NoAV  = "N/A"
  local trEnt = Trace.Entity
  local trOrig, trModel, trMesh, trRad
  local stmode = asmlib.GetCorrectID(self:GetStackMode(),SMode)
  if(trEnt and trEnt:IsValid()) then
    if(asmlib.IsOther(trEnt)) then return end
          trModel = trEnt:GetModel()
    local trRec   = asmlib.CacheQueryPiece(trModel)
          trModel = asmlib.GetModelFileName(trModel)
    if(trRec) then
      trMesh = asmlib.RoundValue(trRec.Mesh,0.01)
      trRad  = asmlib.RoundValue(asmlib.GetLengthVector(trRec.O),0.01)
    end
  end
  local hdRad = asmlib.RoundValue(asmlib.GetLengthVector(hdRec.O),0.01)
  local Ratio = asmlib.RoundValue((trRad or 0) / hdRad,0.01)
  goToolScr:DrawText("TM: "..(trModel or NoAV),"g")
  goToolScr:DrawText("HM: "..(asmlib.GetModelFileName(model) or NoAV),"m")
  goToolScr:DrawText("Anc: "..self:GetAnchor("anchor"),"an")
  goToolScr:DrawText("Mesh: "..tostring(trMesh or NoAV).." > "..tostring(asmlib.RoundValue(hdRec.Mesh,0.01) or NoAV),"y")
  goToolScr:DrawText("Ratio: "..tostring(Ratio).." > "..tostring(trRad or NoAV).."/"..tostring(hdRad))
  goToolScr:DrawText("StackMod: "..SMode:Select(stmode),"r")
  goToolScr:DrawText(tostring(osDate()),"w")
  DrawRatioVisual(goToolScr,trRad,hdRad,10)
end

local ConVarList = TOOL:BuildConVarList()
function TOOL.BuildCPanel(CPanel)
  local CurY, pItem = 0 -- pItem is the current panel created
          CPanel:SetName(languageGetPhrase("tool."..gsToolNameL..".name"))
  pItem = CPanel:Help   (languageGetPhrase("tool."..gsToolNameL..".desc"));  CurY = CurY + pItem:GetTall() + 2

  pItem = CPanel:AddControl( "ComboBox",{
              MenuButton = 1,
              Folder     = gsToolNameL,
              Options    = {["#Default"] = ConVarList},
              CVars      = tableGetKeys(ConVarList)}); CurY = CurY + pItem:GetTall() + 2

  local Panel  = asmlib.CacheQueryPanel()
  if(not Panel) then return asmlib.StatusPrint(nil,"TOOL:BuildCPanel(cPanel): Panel population empty") end
  local stTable = asmlib.GetOpVar("DEFTABLE_PIECES")
  local pTree   = vguiCreate("DTree")
        pTree:SetPos(2, CurY)
        pTree:SetSize(2, 200)
        pTree:SetIndentSize(0)
  local iCnt, pFolders, pNode = 1, {}
  while(Panel[iCnt]) do
    local Val = Panel[iCnt]
    local Mod = Val[stTable[1][1]]
    local Typ = Val[stTable[2][1]]
    local Nam = Val[stTable[3][1]]
    if(fileExists(Mod, "GAME")) then
      if(Typ ~= "" and not pFolders[Typ]) then
      -- No Folder, Make one xD
        pItem = pTree:AddNode(Typ)
        pItem:SetName(Typ)
        pItem.Icon:SetImage("icon16/database_connect.png")
        pItem.InternalDoClick = function() end
        pItem.DoClick = function() return false end
        pItem.Label.UpdateColours = function(pSelf)
          return pSelf:SetTextStyleColor(conPalette:Select("tx")) end
        pFolders[Typ] = pItem
      end
      if(pFolders[Typ]) then pItem = pFolders[Typ] else pItem = pTree end
      pNode = pItem:AddNode(Nam)
      pNode:SetName(Nam)
      pNode:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".model"))
      pNode.Icon:SetImage("icon16/brick.png")
      pNode.DoClick = function() RunConsoleCommand(gsToolPrefL.."model", Mod) end
    else asmlib.PrintInstance("Piece <"..Mod.."> from extension <"..Typ.."> not available .. SKIPPING !") end
    iCnt = iCnt + 1
  end
  CPanel:AddItem(pTree)
  CurY = CurY + pTree:GetTall() + 2
  asmlib.PrintInstance(gsToolNameU.." Found #"..tostring(iCnt-1).." piece items.")

  -- http://wiki.garrysmod.com/page/Category:DComboBox
  local ConID = asmlib.GetCorrectID(asmlib.GetAsmVar("contyp","STR"),CType)
  local pConsType = vguiCreate("DComboBox")
        pConsType:SetPos(2, CurY)
        pConsType:SetTall(18)
        pConsType:SetValue(CType:Select(ConID).Name or ("<"..CType:GetInfo()..">"))
        CurY = CurY + pConsType:GetTall() + 2
  local iCnt = 1
  local Val = CType:Select(iCnt)
  while(Val) do
    pConsType:AddChoice(Val.Name)
    pConsType.OnSelect = function(panel,index,value)
      RunConsoleCommand(gsToolPrefL.."contyp",index)
    end
    iCnt = iCnt + 1
    Val = CType:Select(iCnt)
  end
  pConsType:ChooseOptionID(ConID)
  CPanel:AddItem(pConsType)

  -- http://wiki.garrysmod.com/page/Category:DTextEntry
  local pText = vguiCreate("DTextEntry")
        pText:SetPos(2, 300)
        pText:SetTall(18)
        pText:SetText(asmlib.GetDefaultString(asmlib.GetAsmVar("bgskids","STR"),
                 "Comma delimited Body/Skin IDs > ENTER ( TAB to Auto-fill from Trace )"))
        pText.OnKeyCodeTyped = function(pnSelf, nKeyEnum)
          if(nKeyEnum == KEY_TAB) then
            local sTX = asmlib.GetPropBodyGrp()
                 .."/"..asmlib.GetPropSkin()
            pnSelf:SetText(sTX)
            pnSelf:SetValue(sTX)
          elseif(nKeyEnum == KEY_ENTER) then
            local sTX = pnSelf:GetValue() or ""
            RunConsoleCommand(gsToolPrefL.."bgskids",sTX)
          end
        end
        CurY = CurY + pText:GetTall() + 2
  CPanel:AddItem(pText)

  pItem = CPanel:NumSlider("Piece mass:", gsToolPrefL.."mass", 1, asmlib.GetAsmVar("maxmass","FLT")  , 0)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".mass"))
  pItem = CPanel:NumSlider("Pieces count:", gsToolPrefL.."count", 1, asmlib.GetAsmVar("maxstcnt" , "INT"), 0)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".count"))
  pItem = CPanel:Button("V Reset variables V", gsToolPrefL.."resetvars")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".resetvars"))
  pItem = CPanel:NumSlider("Pivot rotation:", gsToolPrefL.."rotpivt", -gnMaxOffRot, gnMaxOffRot, 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".rotpivt"))
  pItem = CPanel:NumSlider("Pivot rotation:", gsToolPrefL.."rotpivh", -gnMaxOffRot, gnMaxOffRot, 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".rotpivh"))
  pItem = CPanel:NumSlider("End angle pivot:", gsToolPrefL.."deltarot", -gnMaxOffRot, gnMaxOffRot, 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".deltarot"))
  pItem = CPanel:NumSlider("Origin yaw:"  , gsToolPrefL.."nextyaw", -gnMaxOffRot, gnMaxOffRot, 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".nextyaw"))
  pItem = CPanel:NumSlider("Origin pitch:", gsToolPrefL.."nextpic", -gnMaxOffRot, gnMaxOffRot, 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".nextpic"))
  pItem = CPanel:NumSlider("Origin roll:" , gsToolPrefL.."nextrol", -gnMaxOffRot, gnMaxOffRot, 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".nextrol"))
  local nMaxOffLin = asmlib.GetAsmVar("maxlinear","FLT")
  pItem = CPanel:NumSlider("Offset X:", gsToolPrefL.."nextx", -nMaxOffLin, nMaxOffLin, 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".nextx"))
  pItem = CPanel:NumSlider("Offset Y:", gsToolPrefL.."nexty", -nMaxOffLin, nMaxOffLin, 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".nexty"))
  pItem = CPanel:NumSlider("Offset Z:", gsToolPrefL.."nextz", -nMaxOffLin, nMaxOffLin, 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".nextz"))
  pItem = CPanel:NumSlider("Force Limit:", gsToolPrefL.."forcelim", 0, asmlib.GetAsmVar("maxforce","FLT"), 3)
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".forcelim"))
  pItem = CPanel:CheckBox("NoCollide new pieces to the anchor", gsToolPrefL.."nocollide")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".nocollide"))
  pItem = CPanel:CheckBox("Freeze pieces", gsToolPrefL.."freeze")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".freeze"))
  pItem = CPanel:CheckBox("Ignore physgun", gsToolPrefL.."ignphysgn")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".ignphysgn"))
  pItem = CPanel:CheckBox("Apply pieces gravity", gsToolPrefL.."gravity")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".gravity"))
  pItem = CPanel:CheckBox("Use origin angle from trace", gsToolPrefL.."trorang")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".trorang"))
  pItem = CPanel:CheckBox("Ignore gearbox type", gsToolPrefL.."igntyp")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".igntyp"))
  pItem = CPanel:CheckBox("Spawn horizontally", gsToolPrefL.."spnflat")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".spnflat"))
  pItem = CPanel:CheckBox("Enable adviser", gsToolPrefL.."adviser")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".adviser"))
  pItem = CPanel:CheckBox("Draw adviser", gsToolPrefL.."adviser")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".adviser"))
  pItem = CPanel:CheckBox("Draw holder ghost", gsToolPrefL.."ghosthold")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".ghosthold"))
end

function TOOL:UpdateGhost(oEnt, oPly)
  if(not oEnt) then return end
  if(not oEnt:IsValid()) then return end
  local Trace = utilTraceLine(utilGetPlayerTrace(oPly))
  if(not Trace) then return end
  local trEnt = Trace.Entity
  oEnt:SetNoDraw(true)
  oEnt:DrawShadow(false)
  oEnt:SetColor(conPalette:Select("gh"))
  asmlib.PlyLoadKey(oPly)
  local rotpivt, rotpivh = self:GetRotatePivot()
  if(trEnt and trEnt:IsValid() and asmlib.PlyLoadKey(oPly,"SPEED")) then
    if(asmlib.IsOther(trEnt)) then return end
    local trRec = asmlib.CacheQueryPiece(trEnt:GetModel())
    if(trRec) then
      local model   = self:GetModel()
      local nextx, nexty, nextz = self:GetPosOffsets()
      local igntyp  = self:GetIgnoreType()
      local trorang = self:GetTraceOriginAngle()
      local nextpic, nextyaw, nextrol = self:GetAngOffsets()
      local stSpawn = asmlib.GetEntitySpawn(trEnt,rotpivt,rotpivh,model,igntyp,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
      if(not stSpawn) then return end
      oEnt:SetNoDraw(false)
      oEnt:SetAngles(stSpawn.SAng)
      asmlib.SetMCWorld(oEnt,stSpawn.HRec.O,stSpawn.SPos)
    end
  else
    local model = self:GetModel()
    local nextx, nexty, nextz = self:GetPosOffsets()
    local nextpic, nextyaw, nextrol = self:GetAngOffsets()
    local stSpawn = asmlib.GetNormalSpawn(Trace,model,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return end
    local spnflat = self:GetSpawnFlat()
    oEnt:SetNoDraw(false)
    oEnt:SetAngles(stSpawn.SAng)
    stSpawn.SPos:Add(asmlib.GetCustomAngBBZ(oEnt,stSpawn.HRec,spnflat) * Trace.HitNormal)
    asmlib.SetMCWorld(oEnt,stSpawn.HRec.O,stSpawn.SPos)
    return
  end
end

function TOOL:Think()
  local model = self:GetModel()
  if(self:GetGhostHolder() ~= 0 and utilIsValidModel(model)) then
    if (not self.GhostEntity or
        not self.GhostEntity:IsValid() or
            self.GhostEntity:GetModel() ~= model
    ) then
      self:MakeGhostEntity(model)
    end
    self:UpdateGhost(self.GhostEntity, self:GetOwner())
  else
    self:ReleaseGhostEntity()
    if(self.GhostEntity and self.GhostEntity:IsValid()) then
      self.GhostEntity:Remove()
    end
  end
end
