---------------- Localizing Libraries ----------------
local type                             = type
local pairs                            = pairs
local Angle                            = Angle
local print                            = print
local Color                            = Color
local ipairs                           = ipairs
local Vector                           = Vector
local IsValid                          = IsValid
local tonumber                         = tonumber
local tostring                         = tostring
local LocalPlayer                      = LocalPlayer
local GetConVar                        = GetConVar
local RunConsoleCommand                = RunConsoleCommand
local osDate                           = os and os.date
local gameGetWorld                     = game and game.GetWorld
local hookAdd                          = hook and hook.Add
local mathFloor                        = math and math.floor
local mathClamp                        = math and math.Clamp
local vguiCreate                       = vgui and vgui.Create
local fileExists                       = file and file.Exists
local utilIsValidModel                 = util and util.IsValidModel
local tableGetKeys                     = table and table.GetKeys
local inputIsKeyDown                   = input and input.IsKeyDown
local stringUpper                      = string and string.upper
local cleanupRegister                  = cleanup and cleanup.Register
local concommandAdd                    = concommand and concommand.Add
local surfaceScreenWidth               = surface and surface.ScreenWidth
local surfaceScreenHeight              = surface and surface.ScreenHeight
local languageAdd                      = language and language.Add
local languageGetPhrase                = language and language.GetPhrase
local duplicatorRegisterEntityModifier = duplicator and duplicator.RegisterEntityModifier

----------------- TOOL Global Parameters ----------------
--- Store a pointer to our module
local asmlib = gearasmlib
--- Vector Component indexes ---
local cvX, cvY, cvZ = asmlib.GetIndexes("V")
--- Angle Component indexes ---
local caP, caY, caR = asmlib.GetIndexes("A")

--- ZERO Objects
local VEC_ZERO = asmlib.GetOpVar("VEC_ZERO")
local ANG_ZERO = asmlib.GetOpVar("ANG_ZERO")

local gsLibName   = asmlib.GetOpVar("NAME_LIBRARY")
local gsDataRoot  = asmlib.GetOpVar("DIRPATH_BAS")
local gsModeDataB = asmlib.GetOpVar("MODE_DATABASE")
local gsNoID      = asmlib.GetOpVar("MISS_NOID")
local gsNoMD      = asmlib.GetOpVar("MISS_NOMD")
local gsNoAV      = asmlib.GetOpVar("MISS_NOAV")
local conStackMod = asmlib.MakeContainer("STACK_MODE")
local conConstTyp = asmlib.MakeContainer("CONSTRAINT_TYPE")
local gsSymRev    = asmlib.GetOpVar("OPSYM_REVSIGN")
local gsSymDir    = asmlib.GetOpVar("OPSYM_DIRECTORY")
local gsLimitName = asmlib.GetOpVar("CVAR_LIMITNAME")
local gsUndoPrefN = asmlib.GetOpVar("NAME_INIT"):gsub("^%l", stringUpper)..": "
local gnMaxRot    = asmlib.GetOpVar("MAX_ROTATION")
local gnMaxErMode = asmlib.GetAsmVar("bnderrmod","STR")
local gsToolPrefL = asmlib.GetOpVar("TOOLNAME_PL")
local gsToolNameL = asmlib.GetOpVar("TOOLNAME_NL")
local gsToolPrefU = asmlib.GetOpVar("TOOLNAME_PU")
local gsToolNameU = asmlib.GetOpVar("TOOLNAME_NU")
local gsNoAnchor  = gsNoID..gsSymRev..gsNoMD
local conPalette  = asmlib.GetOpVar("CONTAINER_PALETTE")
local varLanguage = GetConVar("gmod_language")
local gtArgsLogs  = {"TOOL"}

if(not asmlib.ProcessDSV()) then -- Default tab delimiter
  asmlib.LogInstance("Processing data list failed <"..gsDataRoot..gsLibName.."_dsv.txt>",gtArgsLogs)
end

cleanupRegister(gsLimitName); asmlib.SetOpVar("REFER_TOOLOBJ", TOOL)

TOOL.ClientConVar = {
  [ "mass"      ] = 250,
  [ "model"     ] = "models/props_phx/gears/spur9.mdl",
  [ "nextx"     ] = 0,
  [ "nexty"     ] = 0,
  [ "nextz"     ] = 0,
  [ "count"     ] = 1,
  [ "anchor"    ] = gsNoAnchor,
  [ "contyp"    ] = 1,
  [ "stmode"    ] = 1,
  [ "freeze"    ] = 0,
  [ "adviser"   ] = 1,
  [ "igntyp"    ] = 0,
  [ "angsnap"   ] = 0,
  [ "rotpivt"   ] = 0,
  [ "rotpivh"   ] = 0,
  [ "gravity"   ] = 1,
  [ "nextpic"   ] = 0,
  [ "nextyaw"   ] = 0,
  [ "nextrol"   ] = 0,
  [ "trorang"   ] = 0,
  [ "bgskids"   ] = "",
  [ "spnflat"   ] = 0,
  [ "exportdb"  ] = 0,
  [ "deltarot"  ] = 360,
  [ "friction"  ] = 0,
  [ "forcelim"  ] = 0,
  [ "torquelim" ] = 0,
  [ "maxstatts" ] = 3,
  [ "nocollide" ] = 0,
  [ "ignphysgn" ] = 0,
  [ "ghosthold" ] = 0,
  [ "upspanchor"] = 0
}

if(CLIENT) then
  TOOL.Information = {
    { name = "info",  stage = 1   },
    { name = "left"         },
    { name = "right"        },
    { name = "right_use",   icon2 = "gui/e.png" },
    { name = "reload"       }
  }
  asmlib.InitLocalify(varLanguage:GetString())
  languageAdd("tool."..gsToolNameL..".category", "Construction")
  concommandAdd(gsToolPrefL.."resetvars", asmlib.GetActionCode("RESET_VARIABLES"))
  concommandAdd(gsToolPrefL.."openframe", asmlib.GetActionCode("OPEN_FRAME"))

  -- Listen for changes to the localify language and reload the tool's menu to update the localizations
  cvarsRemoveChangeCallback(varLanguage:GetName(), gsToolPrefL.."lang")
  cvarsAddChangeCallback(varLanguage:GetName(), function(sNam, vO, vN)
    asmlib.InitLocalify(vN) -- Initialize the new langauge from the didicated file
    local oTool  = asmlib.GetOpVar("REFER_TOOLOBJ") -- Take the tool reference
    local cPanel = controlpanelGet(oTool.Mode); if(not IsValid(cPanel)) then return end
    cPanel:ClearControls(); oTool.BuildCPanel(cPanel) -- Rebuild the tool panel
  end, gsToolPrefL.."lang")

  asmlib.SetOpVar("STORE_TOOLOBJ", TOOL)
  asmlib.SetOpVar("STORE_CONVARS", TOOL:BuildConVarList())
end

if(SERVER) then
  hookAdd("PlayerDisconnected", gsToolPrefL.."player_quit", asmlib.GetActionCode("PLAYER_QUIT"))
  duplicatorRegisterEntityModifier(gsToolPrefL.."dupe_phys_set",asmlib.GetActionCode("DUPE_PHYS_SETTINGS"))
end

TOOL.Category   = languageGetPhrase and languageGetPhrase("tool."..gsToolNameL..".category") -- Name of the category
TOOL.Name       = languageGetPhrase and languageGetPhrase("tool."..gsToolNameL..".name")     -- Name to display
TOOL.Command    = nil  -- Command on click ( nil )
TOOL.ConfigName = nil  -- Configuration file name ( nil )

function TOOL:GetModel()
  return tostring(self:GetClientInfo("model") or "")
end

function TOOL:GetCount()
  return math.Clamp(self:GetClientNumber("count"),1,asmlib.GetAsmVar("maxstcnt","INT"))
end

function TOOL:GetMass()
  return math.Clamp(self:GetClientNumber("mass"),1,asmlib.GetAsmVar("maxmass","FLT"))
end

function TOOL:GetDeveloperMode()
  return asmlib.GetAsmVar("devmode","BUL")
end

function TOOL:GetPosOffsets()
  local nMaxLin = asmlib.GetAsmVar("maxlinear","FLT")
  return (math.Clamp(self:GetClientNumber("nextx") or 0,-nMaxLin,nMaxLin)),
         (math.Clamp(self:GetClientNumber("nexty") or 0,-nMaxLin,nMaxLin)),
         (math.Clamp(self:GetClientNumber("nextz") or 0,-nMaxLin,nMaxLin))
end

function TOOL:GetAngOffsets()
  return (math.Clamp(self:GetClientNumber("nextpic") or 0,-gnMaxRot,gnMaxRot)),
         (math.Clamp(self:GetClientNumber("nextyaw") or 0,-gnMaxRot,gnMaxRot)),
         (math.Clamp(self:GetClientNumber("nextrol") or 0,-gnMaxRot,gnMaxRot))
end

function TOOL:GetFreeze()
  return ((self:GetClientNumber("freeze") or 0) ~= 0)
end

function TOOL:GetIgnoreType()
  return ((self:GetClientNumber("igntyp") or 0) ~= 0)
end

function TOOL:GetBodyGroupSkin()
  return (self:GetClientInfo("bgskids") or "")
end

function TOOL:GetGravity()
  return ((self:GetClientNumber("gravity") or 0) ~= 0)
end

function TOOL:GetGhostHolder()
  return ((self:GetClientNumber("ghosthold") or 0) ~= 0)
end

function TOOL:GetUpSpawnAnchor()
  return ((self:GetClientNumber("upspanchor") or 0) ~= 0)
end

function TOOL:GetNoCollide()
  return (self:GetClientNumber("nocollide") or 0)
end

function TOOL:GetSpawnFlat()
  return ((self:GetClientNumber("spnflat") or 0) ~= 0)
end

function TOOL:GetExportDB()
  return ((self:GetClientNumber("exportdb") or 0) ~= 0)
end

function TOOL:GetLogLines()
  return (asmlib.GetAsmVar("logsmax","INT") or 0)
end

function TOOL:GetLogFile()
  return (asmlib.GetAsmVar("logfile","STR") or "")
end

function TOOL:GetAdviser()
  return ((self:GetClientNumber("adviser") or 0) ~= 0)
end

function TOOL:GetTraceOriginAngle()
  return ((self:GetClientNumber("trorang") or 0) ~= 0)
end

function TOOL:GetStackAttempts()
  return math.Clamp(self:GetClientNumber("maxstatts"),1,5)
end

function TOOL:GetRotatePivot()
  return math.Clamp(self:GetClientNumber("rotpivt") or 0,-gnMaxRot,gnMaxRot),
         math.Clamp(self:GetClientNumber("rotpivh") or 0,-gnMaxRot,gnMaxRot)
end

function TOOL:GetDeltaRotation()
  return math.Clamp(self:GetClientNumber("deltarot") or 0,-gnMaxRot,gnMaxRot)
end

function TOOL:GetFriction()
  return math.Clamp(self:GetClientNumber("friction") or 0,0,asmlib.GetAsmVar("maxfrict","FLT"))
end

function TOOL:GetForceLimit()
  return math.Clamp(self:GetClientNumber("forcelim") or 0,0,asmlib.GetAsmVar("maxforce","FLT"))
end

function TOOL:GetTorqueLimit()
  return math.Clamp(self:GetClientNumber("torquelim") or 0,0,asmlib.GetAsmVar("maxtorque","FLT"))
end

function TOOL:GetStackMode()
  return (self:GetClientNumber("stmode") or 1)
end

function TOOL:GetAngSnap()
  return mathClamp(self:GetClientNumber("angsnap"),0,gnMaxRot)
end

function TOOL:GetContrType()
  return (self:GetClientNumber("contyp") or 1)
end

function TOOL:GetIgnorePhysgun()
  return ((self:GetClientNumber("ignphysgn") or 0) ~= 0)
end

function TOOL:GetBoundErrorMode()
  return asmlib.GetAsmVar("bnderrmod","STR")
end

function TOOL:ClearAnchor(bMute)
  local plPly = self:GetOwner()
  local siAnc, svEnt = self:GetAnchor()
  if(CLIENT) then return end; self:ClearObjects()
  asmlib.ConCommandPly(plPly,"anchor",gsNoAnchor)
  if(svEnt) then
    if(not svEnt:IsWorld()) then
      if(svEnt and svEnt:IsValid()) then
        svEnt:SetColor(conPalette:Select("w"))
        svEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
      end
    end
    if(not bMute) then
      asmlib.PrintNotifyPly(plPly,"Anchor: Cleaned "..siAnc.." !","CLEANUP") end
  end; asmlib.LogInstance("Cleared "..asmlib.GetReport1(bMute),gtArgsLogs); return true
end

function TOOL:SetAnchor(stTrace)
  self:ClearAnchor(true)
  if(not stTrace) then asmlib.LogInstance("Trace invalid",gtArgsLogs); return false end
  if(not stTrace.Hit) then asmlib.LogInstance("Trace not hit",gtArgsLogs); return false end
  local plPly = self:GetOwner(); if(not (plPly and plPly:IsValid())) then
    asmlib.LogInstance("Player invalid",gtArgsLogs); return false end
  if(stTrace.HitWorld) then
    local sAnchor = "0"..gsSymRev.."worldspawn.mdl"
    self:SetObject(1,gameGetWorld(),stTrace.HitPos,phEnt,stTrace.PhysicsBone,stTrace.HitNormal)
    asmlib.ConCommandPly(plPly,"anchor",sAnchor)
    asmlib.PrintNotifyPly(plPly,"Anchor: Set "..sAnchor.." !","UNDO")
    asmlib.LogInstance("Set "..asmlib.GetReport1(sAnchor),gtArgsLogs); return true
  else
    local trEnt = stTrace.Entity
    if(not (trEnt and trEnt:IsValid())) then asmlib.LogInstance("Trace no entity",gtArgsLogs); return false end
    local phEnt = trEnt:GetPhysicsObject()
    if(not (phEnt and phEnt:IsValid())) then asmlib.LogInstance("Trace no physics",gtArgsLogs); return false end
    local sAnchor = trEnt:EntIndex()..gsSymRev..trEnt:GetModel():GetFileFromFilename()
    trEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
    trEnt:SetColor(conPalette:Select("an"))
    self:SetObject(1,trEnt,stTrace.HitPos,phEnt,stTrace.PhysicsBone,stTrace.HitNormal)
    asmlib.ConCommandPly(plPly,"anchor",sAnchor)
    asmlib.PrintNotifyPly(plPly,"Anchor: Set "..sAnchor.." !","UNDO")
    asmlib.LogInstance("Set "..asmlib.GetReport1(sAnchor),gtArgsLogs); return true
  end
end

function TOOL:GetAnchor()
  local svEnt = self:GetEnt(1)
  local siAnc = (self:GetClientInfo("anchor") or gsNoAnchor)
  if(svEnt) then
    if(not svEnt:IsWorld()) then
      if(not svEnt:IsValid()) then svEnt = nil end
    end
  end; return siAnc, svEnt
end

function TOOL:GetStatus(stTrace,saMsg,hdEnt)
  local iMaxlog = asmlib.GetOpVar("LOG_MAXLOGS")
  if(not (iMaxlog > 0)) then return "Status N/A" end
  local ply, sDelim  = self:GetOwner(), "\n"
  local iCurLog = asmlib.GetOpVar("LOG_CURLOGS")
  local sFleLog = asmlib.GetOpVar("LOG_LOGFILE")
  local sSpace  = (" "):rep(6 + tostring(iMaxlog):len())
  local rotpivt, rotpivh = self:GetRotatePivot()
  local siAnc  , anEnt   = self:GetAnchor()
  local nextx  , nexty  , nextz   = self:GetPosOffsets()
  local nextpic, nextyaw, nextrol = self:GetAngOffsets()
  local hdModel, trModel, trRec   = self:GetModel()
  local hdRec   = asmlib.CacheQueryPiece(hdModel)
  local trEnt   = stTrace.Entity
  if(stTrace and trEnt and trEnt:IsValid()) then
    trModel = trEnt:GetModel()
    trRec   = asmlib.CacheQueryPiece(trModel)
  end
  local sDu = ""
        sDu = sDu..tostring(saMsg)..sDelim
        sDu = sDu..sSpace.."Dumping logs state:"..sDelim
        sDu = sDu..sSpace.."  LogsMax:        <"..tostring(iMaxlog)..">"..sDelim
        sDu = sDu..sSpace.."  LogsCur:        <"..tostring(iCurLog)..">"..sDelim
        sDu = sDu..sSpace.."  LogFile:        <"..tostring(sFleLog)..">"..sDelim
        sDu = sDu..sSpace.."  MaxProps:       <"..tostring(GetConVar("sbox_maxprops"):GetInt())..">"..sDelim
        sDu = sDu..sSpace.."  MaxPieces:      <"..tostring(GetConVar("sbox_max"..gsLimitName):GetInt())..">"..sDelim
        sDu = sDu..sSpace.."Dumping player keys:"..sDelim
        sDu = sDu..sSpace.."  Player:         <"..tostring(ply:SteamID())..">{"..ply:Nick().."}"..sDelim
        sDu = sDu..sSpace.."  IN.USE:         <"..tostring(ply:KeyDown(IN_USE))..">"..sDelim
        sDu = sDu..sSpace.."  IN.DUCK:        <"..tostring(ply:KeyDown(IN_DUCK))..">"..sDelim
        sDu = sDu..sSpace.."  IN.SPEED:       <"..tostring(ply:KeyDown(IN_SPEED))..">"..sDelim
        sDu = sDu..sSpace.."  IN.RELOAD:      <"..tostring(ply:KeyDown(IN_RELOAD))..">"..sDelim
        sDu = sDu..sSpace.."  IN.SCORE:       <"..tostring(ply:KeyDown(IN_SCORE))..">"..sDelim
        sDu = sDu..sSpace.."Dumping trace data state:"..sDelim
        sDu = sDu..sSpace.."  Trace:          <"..tostring(stTrace)..">"..sDelim
        sDu = sDu..sSpace.."  TR.Hit:         <"..tostring(stTrace and stTrace.Hit or gsNoAV)..">"..sDelim
        sDu = sDu..sSpace.."  TR.HitW:        <"..tostring(stTrace and stTrace.HitWorld or gsNoAV)..">"..sDelim
        sDu = sDu..sSpace.."  TR.ENT:         <"..tostring(stTrace and trEnt or gsNoAV)..">"..sDelim
        sDu = sDu..sSpace.."  TR.Model:       <"..tostring(trModel or gsNoAV)..">["..tostring(trRec and trRec.Kept or gsNoID).."]"..sDelim
        sDu = sDu..sSpace.."  TR.File:        <"..tostring(trModel and trModel:GetFileFromFilename() or gsNoAV)..">"..sDelim
        sDu = sDu..sSpace.."Dumping console variables state:"..sDelim
        sDu = sDu..sSpace.."  HD.Entity:      <"..tostring(hdEnt or gsNoAV)..">"..sDelim
        sDu = sDu..sSpace.."  HD.Model:       <"..tostring(hdModel or gsNoAV)..">["..tostring(hdRec and hdRec.Kept or gsNoID).."]"..sDelim
        sDu = sDu..sSpace.."  HD.File:        <"..tostring(hdModel and hdModel:GetFileFromFilename() or gsNoAV)..">"..sDelim
        sDu = sDu..sSpace.."  HD.Mass:        <"..tostring(self:GetMass())..">"..sDelim
        sDu = sDu..sSpace.."  HD.StackCNT:    <"..tostring(self:GetCount())..">"..sDelim
        sDu = sDu..sSpace.."  HD.Freeze:      <"..tostring(self:GetFreeze())..">"..sDelim
        sDu = sDu..sSpace.."  HD.Gravity:     <"..tostring(self:GetGravity())..">"..sDelim
        sDu = sDu..sSpace.."  HD.Adviser:     <"..tostring(self:GetAdviser())..">"..sDelim
        sDu = sDu..sSpace.."  HD.YawSnap:     <"..tostring(self:GetAngSnap())..">"..sDelim
        sDu = sDu..sSpace.."  HD.Friction:    <"..tostring(self:GetFriction())..">"..sDelim
        sDu = sDu..sSpace.."  HD.ExportDB:    <"..tostring(self:GetExportDB())..">"..sDelim
        sDu = sDu..sSpace.."  HD.NoCollide:   <"..tostring(self:GetNoCollide())..">"..sDelim
        sDu = sDu..sSpace.."  HD.SpawnFlat:   <"..tostring(self:GetSpawnFlat())..">"..sDelim
        sDu = sDu..sSpace.."  HD.StkMode:     <"..tostring(self:GetStackMode())..">"..sDelim
        sDu = sDu..sSpace.."  HD.ConstrType:  <"..tostring(self:GetContrType())..">"..sDelim
        sDu = sDu..sSpace.."  HD.IgnoreType:  <"..tostring(self:GetIgnoreType())..">"..sDelim
        sDu = sDu..sSpace.."  HD.ForceLimit:  <"..tostring(self:GetForceLimit())..">"..sDelim
        sDu = sDu..sSpace.."  HD.TorqueLimit: <"..tostring(self:GetTorqueLimit())..">"..sDelim
        sDu = sDu..sSpace.."  HD.GhostHold:   <"..tostring(self:GetGhostHolder())..">"..sDelim
        sDu = sDu..sSpace.."  HD.SkinBG:      <"..tostring(self:GetBodyGroupSkin())..">"..sDelim
        sDu = sDu..sSpace.."  HD.StackAtempt: <"..tostring(self:GetStackAttempts())..">"..sDelim
        sDu = sDu..sSpace.."  HD.IgnorePG:    <"..tostring(self:GetIgnorePhysgun())..">"..sDelim
        sDu = sDu..sSpace.."  HD.DeltaRot:    <"..tostring(self:GetDeltaRotation())..">"..sDelim
        sDu = sDu..sSpace.."  HD.SnapAnchor:  <"..tostring(self:GetUpSpawnAnchor())..">"..sDelim
        sDu = sDu..sSpace.."  HD.TrOrgAngle:  <"..tostring(self:GetTraceOriginAngle())..">"..sDelim
        sDu = sDu..sSpace.."  HD.ModDataBase: <"..gsModeDataB..","..tostring(asmlib.GetAsmVar("modedb" ,"STR"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.TimerMode:   <"..tostring(asmlib.GetAsmVar("timermode","STR"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.DevelopMode: <"..tostring(asmlib.GetAsmVar("devmode"  ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxMass:     <"..tostring(asmlib.GetAsmVar("maxmass"  ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxLinear:   <"..tostring(asmlib.GetAsmVar("maxlinear","INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxForce:    <"..tostring(asmlib.GetAsmVar("maxforce" ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxStackCnt: <"..tostring(asmlib.GetAsmVar("maxstcnt" ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.BoundErrMod: <"..tostring(asmlib.GetAsmVar("bnderrmod","STR"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxFrequent: <"..tostring(asmlib.GetAsmVar("maxfruse" ,"INT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.MaxTrMargin: <"..tostring(asmlib.GetAsmVar("maxtrmarg","FLT"))..">"..sDelim
        sDu = sDu..sSpace.."  HD.RotatePivot: {"..tostring(rotpivt)..", "..tostring(rotpivh).."}"..sDelim
        sDu = sDu..sSpace.."  HD.Anchor:      {"..tostring(anEnt or gsNoAV).."}<"..tostring(siAnc)..">"..sDelim
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
  local mass      = self:GetMass()
  local model     = self:GetModel()
  local count     = self:GetCount()
  local freeze    = self:GetFreeze()
  local gravity   = self:GetGravity()
  local angsnap   = self:GetAngSnap()
  local friction  = self:GetFriction()
  local nocollide = self:GetNoCollide()
  local spnflat   = self:GetSpawnFlat()
  local igntyp    = self:GetIgnoreType()
  local forcelim  = self:GetForceLimit()
  local torquelim = self:GetTorqueLimit()
  local bgskids   = self:GetBodyGroupSkin()
  local maxstatts = self:GetStackAttempts()
  local deltarot  = self:GetDeltaRotation()
  local ignphysgn = self:GetIgnorePhysgun()
  local bnderrmod = self:GetBoundErrorMode()
  local trorang   = self:GetTraceOriginAngle()
  local fnmodel   = model:GetFileFromFilename()
  local stmode    = asmlib.GetCorrectID(self:GetStackMode(),conStackMod)
  local contyp    = asmlib.GetCorrectID(self:GetContrType(),conConstTyp)
  local siAnc , anEnt    = self:GetAnchor()
  local rotpivt, rotpivh = self:GetRotatePivot()
  local nextx  , nexty  , nextz   = self:GetPosOffsets()
  local nextpic, nextyaw, nextrol = self:GetAngOffsets()

  -- Update the anchor entity automatically when enabled
  if(self:GetUpSpawnAnchor()) then
    if(anEnt ~= trEnt) then
      self:SetAnchor(stTrace)
      siAnc, anEnt = self:GetAnchor()
    end
  end

  -- General spawning when we do not apply neither mesh
  if(not ply:KeyDown(IN_SPEED) and not ply:KeyDown(IN_DUCK)) then

    -- Update the anchor entity automatically when enabled
    if(self:GetUpSpawnAnchor()) then -- Read the auto-update flag
      if(anEnt ~= trEnt) then -- When the anchor needs to be changed
        self:SetAnchor(stTrace) -- Update anchor with current trace
        siAnc, anEnt = self:GetAnchor() -- Export anchor to locals
      end -- This needs to be triggered only when the user is not meshing
    end -- When the flag is not enabled must not automatically update anchor

    if(anEnt) then -- Check if there is an anchor available
      if(not anEnt:IsWorld()) then -- Check all other cases that are not world
        if(not (anEnt and anEnt:IsValid()) and -- When the anchor is not valid use trace
               (trEnt and trEnt:IsValid())) then anEnt = trEnt end -- Switch-a-roo
      end -- When anchor is not the world and it is invalid use the trace
    else -- When the anchor is missing we just use the trace entity or spawn on the ground
      if(trEnt and trEnt:IsValid()) then anEnt = trEnt end -- Switch-a-roo
    end -- If there is something wrong with the anchor entity use the trace

    local vPos, vAxis = stTrace.HitPos, Vector()
    local aAng = asmlib.GetNormalAngle(ply, stTrace, angsnap)
    local stSpawn = asmlib.GetNormalSpawn(ply,vPos,aAng,model,rotpivh,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(World): Normal spawn failed")) end
    local ePiece = asmlib.MakePiece(ply,model,stTrace.HitPos,ANG_ZERO,mass,bgskids,conPalette:Select("w"),bnderrmod)
    if(not ePiece) then return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(World): Making piece failed")) end
    if(spnflat) then vAxis:Set(stTrace.HitNormal)
      asmlib.ApplySpawnFlat(ePiece,stSpawn,stTrace.HitNormal)
    else vAxis:Set(stSpawn.DAng:Up()) end
    ePiece:SetAngles(stSpawn.SAng); ePiece:SetPos(stSpawn.SPos)
    asmlib.UndoCratePly(gsUndoPrefN..fnmodel.." ( World spawn )")
    if(not asmlib.ApplyPhysicalSettings(ePiece,ignphysgn,freeze,gravity)) then
      return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(World): Failed to apply physical settings",ePiece)) end
    if(not asmlib.ApplyPhysicalAnchor(ePiece,anEnt,stTrace.HitPos,vAxis,contyp,nocollide,forcelim,torquelim,friction)) then
      return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(World): Failed to apply physical anchor",ePiece)) end
    asmlib.UndoAddEntityPly(ePiece)
    asmlib.UndoFinishPly(ply)
    return asmlib.StatusLog(true,"TOOL:LeftClick(World): Success")
  end

  if(not trRec) then asmlib.LogStatus(self:GetStatus(stTrace,"(Prop) Trace invalid")); return false end

  --No need stacking relative to non-persistent props or using them...
  local hdRec = asmlib.CacheQueryPiece(model)
  local trRec = asmlib.CacheQueryPiece(trModel)
  local trRec = asmlib.CacheQueryPiece(trEnt:GetModel())

  if(not trRec) then asmlib.LogStatus(self:GetStatus(stTrace,"(Prop) Trace model not a piece")); return false end

  -- Applies the physics or anchor on the piece selected
  if(ply:KeyDown(IN_DUCK)) then -- USE: Use the valid trace as a piece
    if(ply:KeyDown(IN_USE)) then -- The user must click on the gear surface to apply
      if(not asmlib.ApplyPhysicalAnchor(ePiece,anEnt,stTrace.HitPos,stTrace.HitNormal,contyp,nocollide,forcelim,torquelim,friction)) then
        return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(World): Failed to apply physical anchor",ePiece)) end
    else -- Model
      if(not asmlib.ApplyPhysicalSettings(trEnt,ignphysgn,freeze,gravity)) then
        return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Physical): Failed to apply physical settings",trEnt)) end
      trEnt:GetPhysicsObject():SetMass(mass)
      return asmlib.StatusLog(true,"TOOL:LeftClick(Physical): Success")
    end
  end

  if(not hdRec) then return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Prop): Holder model not a piece")) end
  -- Stacking when the mode is within borders and count is more than one
  if(ply:KeyDown(IN_SPEED) and count > 1 and stmode >= 1 and stmode <= conStackMod:GetSize()) then
    local stSpawn = asmlib.GetEntitySpawn(ply,trEnt,rotpivt,rotpivh,model,igntyp,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Stack): Failed to retrieve spawn data")) end
    local ePieceO, ePieceN = trEnt, nil
    local aIter  , aStart  = ePieceO:GetAngles(), ePieceO:GetAngles()
    local iNdex  , iTrys, dRot = count, maxstatts, (deltarot / count)
    asmlib.UndoCratePly(gsUndoPrefN..fnmodel.." ( Stack #"..tostring(count).." )")
    while(iNdex > 0) do
      local sIterat = "["..tostring(iNdex).."]"
      ePieceN = asmlib.MakePiece(ply,model,stSpawn.SPos,stSpawn.SAng,mass,bgskids,conPalette:Select("w"),bnderrmod)
      if(ePieceN) then
        if(not asmlib.ApplyPhysicalSettings(ePieceN,ignphysgn,freeze,gravity)) then
          return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Stack): Failed to apply physical settings",ePiece)) end
        if(not asmlib.ApplyPhysicalAnchor(ePieceN,anEnt,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim,torquelim,friction)) then
          return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Stack): Failed to apply physical anchor",ePiece)) end
        asmlib.UndoAddEntityPly(ePieceN)
        if(stmode == 1) then
          stSpawn = asmlib.GetEntitySpawn(ply,ePieceN,rotpivt,rotpivh,model,igntyp,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
        elseif(stmode == 2) then
          aIter:RotateAroundAxis(stSpawn.TAng:Up(),-dRot)
          trEnt:SetAngles(aIter)
          stSpawn = asmlib.GetEntitySpawn(ply,trEnt,rotpivt,rotpivh,model,igntyp,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
        end
        if(not stSpawn) then -- Look both ways in a one way street :D
          asmlib.PrintNotifyPly(ply,"Cannot obtain spawn data!","ERROR")
          asmlib.UndoFinishPly(ply,sIterat)
          return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Stack)"..sIterat..": Stacking has invalid user data"))
        end -- Spawn data is valid for the current iteration iNdex
        ePieceO, iNdex, iTrys = ePieceN, (iNdex - 1), maxstatts
      else iTrys = iTrys - 1 end
      if(iTrys <= 0) then
        asmlib.UndoFinishPly(ply,sIterat) --  Make it shoot but throw the error
        return asmlib.StatusLog(true,self:GetStatus(stTrace,"TOOL:LeftClick(Stack)"..sIterat..": All stack attempts failed"))
      end -- We still have enough memory to preform the stacking
    end
    trEnt:SetAngles(aStart)
    asmlib.UndoFinishPly(ply)
    return asmlib.StatusLog(true,"TOOL:LeftClick(Stack): Success")
  end
  -- Mesh holder gear to the trace one when stack count is one
  local stSpawn = asmlib.GetEntitySpawn(ply,trEnt,rotpivt,rotpivh,model,igntyp,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
  if(stSpawn) then
    local ePiece = asmlib.MakePiece(ply,model,stSpawn.SPos,stSpawn.SAng,mass,bgskids,conPalette:Select("w"),bnderrmod)
    if(ePiece) then
      if(not asmlib.ApplyPhysicalSettings(ePiece,ignphysgn,freeze,gravity)) then
        return asmlib.StatusLog(false,self:GetStatus(stTrace,"TOOL:LeftClick(Snap): Failed to apply physical settings",ePiece)) end
      if(not asmlib.ApplyPhysicalAnchor(ePiece,anEnt,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim,freeze,gravity,torquelim,friction)) then
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
  local trEnt = stTrace.Entity
  local ply   = self:GetOwner()
  if(ply:KeyDown(IN_USE)) then
    if(stTrace.HitWorld) then -- Open frequent pieces frame
      asmlib.ConCommandPly(ply,"openframe",asmlib.GetAsmVar("maxfruse" ,"INT"))
      return asmlib.StatusLog(true,"TOOL:RightClick(World): Success open frame")
    end
  elseif(ply:KeyDown(IN_SPEED)) then -- Controls anchor selection
    if(stTrace.HitWorld) then
      if(self:GetUpSpawnAnchor()) then
        local siAnc, anEnt = self:GetAnchor()
        if(anEnt and anEnt:IsWorld()) then
          self:ClearAnchor(false); asmlib.LogInstance("(SPEED): Anchor cleared",gtArgsLogs); return true
        else
          self:SetAnchor(stTrace); asmlib.LogInstance("(SPEED): Anchor set",gtArgsLogs); return true
        end
      else
        self:ClearAnchor(false); asmlib.LogInstance("(SPEED): Anchor cleared",gtArgsLogs); return true
      end
    elseif(trEnt and trEnt:IsValid()) then
      self:SetAnchor(stTrace); return asmlib.StatusLog(true,"TOOL:RightClick(SPEED): Anchor set")
    else return asmlib.StatusLog(true,self:GetStatus(stTrace,"TOOL:RightClick(SPEED): Invalid action",trEnt)) end
  elseif(ply:KeyDown(IN_DUCK)) then -- Controls model selection
    if(trEnt and trEnt:IsValid()) then
      local trModel = trEnt:GetModel()
      local fnModel = trModel:GetFileFromFilename()
      asmlib.ConCommandPly(ply,"model",trModel)
      asmlib.PrintNotifyPly(ply,"Model: "..fnModel.." selected !","GENERIC")
      asmlib.LogInstance("(DUCK): Success <"..fnModel..">",gtArgsLogs); return true
    end
  else -- If neither is pressed changes the stack mode
    local stmode = asmlib.GetCorrectID(self:GetStackMode(),conStackMod)
          stmode = asmlib.GetCorrectID(stmode + 1,conStackMod)
    asmlib.ConCommandPly(ply,"stmode",stmode)
    asmlib.PrintNotifyPly(ply,"Stack Mode: "..conStackMod:Select(stmode).." !","UNDO")
    asmlib.LogInstance("(MODE) Success",gtArgsLogs); return true
  end
end

function TOOL:Reload(stTrace)
  if(CLIENT) then return true end
  if(not stTrace) then return false end
  local ply = self:GetOwner()
  local trEnt = stTrace.Entity
  if(ply:KeyDown(IN_SPEED) and stTrace.HitWorld) then
    asmlib.SetLogControl(self:GetLogLines(),self:GetLogFile())
    if(self:GetExportDB()) then
      asmlib.LogInstance("(World) Exporting DB",gtArgsLogs)
      asmlib.ExportDSV("PIECES")
      asmlib.ConCommandPly(ply, "exportdb", 0)
    end; return asmlib.StatusLog(true,"TOOL:Reload(World): Success")
  end
  local trEnt = stTrace.Entity
  local trRec = asmlib.CacheQueryPiece(trEnt:GetModel())
  if(trRec) then trEnt:Remove()
    return asmlib.StatusLog(true,"TOOL:Reload(Prop) Removed a piece") end
  return asmlib.StatusLog(false,"TOOL:Reload(): Nothing removed")
end

function TOOL:Holster()
  self:ReleaseGhostEntity()
  local gho = self.GhostEntity
  if(gho and gho:IsValid()) then gho:Remove() end
end

function TOOL:UpdateGhost(ePiece, oPly)
  if(not asmlib.IsInit()) then return end
  if(not (ePiece and ePiece:IsValid())) then return end
  local stTrace = asmlib.CacheTracePly(oPly)
  if(not stTrace) then return end
  local trEnt = stTrace.Entity
  ePiece:SetNoDraw(true)
  ePiece:DrawShadow(false)
  ePiece:SetColor(conPalette:Select("gh"))
  local trorang = self:GetTraceOriginAngle()
  local rotpivt, rotpivh = self:GetRotatePivot()
  if(trEnt and trEnt:IsValid() and oPly:KeyDown(IN_SPEED)) then
    if(asmlib.IsOther(trEnt)) then return end
    local trRec = asmlib.CacheQueryPiece(trEnt:GetModel())
    if(trRec) then
      local model   = self:GetModel()
      local igntyp  = self:GetIgnoreType()
      local nextx  , nexty  , nextz   = self:GetPosOffsets()
      local nextpic, nextyaw, nextrol = self:GetAngOffsets()
      local stSpawn = asmlib.GetEntitySpawn(oPly,trEnt,rotpivt,rotpivh,model,igntyp,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
      if(not stSpawn) then return end
      ePiece:SetNoDraw(false)
      ePiece:SetAngles(stSpawn.SAng)
      ePiece:SetPos(stSpawn.SPos)
    end
  else
    local model = self:GetModel()
    local angsnap = self:GetAngSnap()
    local spnflat = self:GetSpawnFlat()
    local nextx, nexty, nextz = self:GetPosOffsets()
    local nextpic, nextyaw, nextrol = self:GetAngOffsets()
    local vPos = stTrace.HitPos
    local aAng = asmlib.GetNormalAngle(oPly, stTrace, angsnap)
    local stSpawn = asmlib.GetNormalSpawn(oPly,vPos,aAng,model,rotpivh,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return end
    if(spnflat) then asmlib.ApplySpawnFlat(ePiece,stSpawn,stTrace.HitNormal) end
    ePiece:SetNoDraw(false); ePiece:SetAngles(stSpawn.SAng); ePiece:SetPos(stSpawn.SPos); return
  end
end

function TOOL:Think()
  local model = self:GetModel()
  if(utilIsValidModel(model)) then -- Check model validation
    local ply = self:GetOwner()
    local gho = self.GhostEntity
    if(self:GetGhostHolder()) then
      if (not (gho and gho:IsValid() and gho:GetModel() == model)) then
        self:MakeGhostEntity(model,VEC_ZERO,ANG_ZERO)
      end; self:UpdateGhost(self.GhostEntity, ply) -- In client single player the ghost is skipped
    else self:ReleaseGhostEntity() end -- Delete the ghost entity when ghosting is disabled
    if(CLIENT and inputIsKeyDown(KEY_LALT) and inputIsKeyDown(KEY_E)) then
      local pnFrame = asmlib.GetOpVar("PANEL_FREQUENT_MODELS")
      if(pnFrame and IsValid(pnFrame)) then pnFrame.OnClose() end -- That was a /close call/ :D
    end -- Shortcut for closing the routine pieces
  end
end

--[[
 * This function draws value snapshot of the spawn structure in the screen
 * oScreen > Screen to draw the text on
 * sCol    > Text draw color
 * sMeth   > Text draw method
 * tArgs   > Text draw arguments
]]--
function TOOL:DrawTextSpawn(oScreen, sCol, sMeth, tArgs)
  local ply = LocalPlayer()
  local stS = asmlib.CacheSpawnPly(ply)
  local arK = asmlib.GetOpVar("STRUCT_SPAWN")
  local w,h = oScreen:GetSize()
  oScreen:SetTextEdge(w - 500,0)
  oScreen:DrawText("Spawn debug information",sCol,sMeth,tArgs)
  for ID = 1, #arK, 1 do local def = arK[ID]
    local key, typ, inf = def[1], def[2], tostring(def[3] or "")
    local cnv = ((not asmlib.IsBlank(inf)) and (" > "..inf) or "")
    if(not asmlib.IsHere(typ)) then oScreen:DrawText(tostring(key))
    else local typ, val = tostring(typ or ""), tostring(stS[key] or "")
      oScreen:DrawText("<"..key.."> "..typ..": "..val..cnv) end
  end
end

function TOOL:DrawUCS(oScreen, vOrg, aOrg, nRad, sCol, bRgh)
  local Op, UCS = vOrg:ToScreen(), 15
  local Xs = (vOrg + UCS * aOrg:Forward()):ToScreen()
  local Zs = (vOrg + UCS * aOrg:Up()):ToScreen()
  oScreen:DrawLine(Op,Xs,"r","SURF")
  if(bRgh) then -- Do not calculate the disabled Ys
    local Ys = (vOrg + UCS * aOrg:Right()):ToScreen()
    oScreen:DrawLine(Op,Ys,"g")
  end; oScreen:DrawCircle(Op,nRad,sCol,"SURF")
  oScreen:DrawLine(Op,Zs,"b")
  return Op
end

function TOOL:DrawHUD()
  if(SERVER) then return end
  local hudMonitor = asmlib.GetOpVar("MONITOR_GAME")
  if(not hudMonitor) then
    local scrW = surfaceScreenWidth()
    local scrH = surfaceScreenHeight()
    hudMonitor = asmlib.MakeScreen(0,0,scrW,scrH,conPalette)
    if(not hudMonitor) then
      return asmlib.StatusLog(nil,"DrawHUD: Invalid screen") end
    asmlib.SetOpVar("MONITOR_GAME", hudMonitor)
    asmlib.LogInstance("DrawHUD: Create screen",gtArgsLogs)
  end; hudMonitor:SetColor()
  local oPly = LocalPlayer()
  local stTrace = asmlib.CacheTracePly(oPly)
  if(not stTrace) then return end
  if(not self:GetAdviser()) then return end
  local trEnt, trHit = stTrace.Entity, stTrace.HitPos
  local spnflat, model = self:GetSpawnFlat(), self:GetModel()
  local trorang, angsnap = self:GetTraceOriginAngle(), self:GetAngSnap()
  local rotpivt, rotpivh = self:GetRotatePivot()
  local nextx  , nexty  , nextz   = self:GetPosOffsets()
  local nextpic, nextyaw, nextrol = self:GetAngOffsets()
  local plyrad  = asmlib.CacheRadiusPly(oPly, trHit, 1)
  if(trEnt and trEnt:IsValid() and oPly:KeyDown(IN_SPEED)) then
    if(asmlib.IsOther(trEnt)) then return end
    local igntyp  = self:GetIgnoreType()
    local stSpawn = asmlib.GetEntitySpawn(oPly,trEnt,rotpivt,rotpivh,model,igntyp,trorang,
                                            nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return end
    local Tp =  trEnt:GetPos():ToScreen()
    local Hp =  stSpawn.SPos:ToScreen()
    local Mt = self:DrawUCS(hudMonitor, stSpawn.TOrg, stSpawn.TAng, plyrad, "y")
    local Op = self:DrawUCS(hudMonitor, stSpawn.OPos, stSpawn.F:AngleEx(stSpawn.U), plyrad, "y", true)
    local Mh = self:DrawUCS(hudMonitor, stSpawn.HOrg, stSpawn.DAng, plyrad, "y")
    hudMonitor:DrawCircle(Tp,plyrad,"r")  -- Trace position
    hudMonitor:DrawCircle(Hp,plyrad)      -- Holder position
    hudMonitor:DrawLine(Mh,Hp,"y")        -- Trace position distance
    hudMonitor:DrawLine(Mt,Tp)            -- Holder position distance
    hudMonitor:DrawLine(Mt,Op,"g")        -- Trace mass-origin distance
    hudMonitor:DrawLine(Op,Mh,"m")        -- Holder mass-origin distance
    if(not self:GetDeveloperMode()) then return end
    self:DrawTextSpawn(hudMonitor, "k","SURF",{"Trebuchet18"})
  else
    local aAng = asmlib.GetNormalAngle(oPly, stTrace, angsnap)
    local stSpawn = asmlib.GetNormalSpawn(oPly,trHit,aAng,model,rotpivh,trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return false end
    local Op = self:DrawUCS(hudMonitor, stSpawn.OPos, stSpawn.F:AngleEx(stSpawn.U), plyrad, "y", true)
    if(not spnflat) then
      local Hp = stSpawn.SPos:ToScreen()
      local Mh = self:DrawUCS(hudMonitor, stSpawn.HOrg, stSpawn.DAng, plyrad, "g")
      hudMonitor:DrawLine(Mh,Hp,"y")       -- Holder position distance
      hudMonitor:DrawCircle(Hp,plyrad,"r") -- Holder spawn position
      hudMonitor:DrawLine(Op,Mh,"m")       -- Holder distance vector
    end
    if(not self:GetDeveloperMode()) then return end
    self:DrawTextSpawn(hudMonitor, "k","SURF",{"Trebuchet18"})
  end
end

function TOOL:DrawRatioVisual(oScreen,nTrR,nHdR,nDeep)
  local hDeep = mathFloor((nDeep or 0) / 2)
  if(hDeep <= 2) then return end
  local nW, nH = oScreen:GetSize()
  local dx, dy, dw, dh = oScreen:GetTextState(0,0,0,2)
  if(nTrR) then
    local nCen = mathFloor((nTrR / ( nTrR + nHdR )) * nW)
    oScreen:DrawRect({x=0,y=dh},{x=nDeep,y=nH},"y")               -- Trace Teeth
    oScreen:DrawRect({x=nDeep,y=dh},{x=nCen-hDeep,y=nH},"g")      -- Trace Gear
    oScreen:DrawRect({x=nCen-hDeep,y=dh},{x=nCen+hDeep,y=nH},"y") -- Mesh position
    oScreen:DrawRect({x=nCen+hDeep,y=dh},{x=nW-nDeep,y=nH},"m")   -- Holds Gear
    oScreen:DrawRect({x=nW-nDeep,y=dh},{x=nW,y=nH},"y")           -- Holds Teeth
  else
    oScreen:DrawRect({x=0,y=dh},{x=nDeep,y=nH},"y")               -- Holds Teeth
    oScreen:DrawRect({x=nDeep,y=dh},{x=nW-nDeep,y=nH},"g")        -- Holds
    oScreen:DrawRect({x=nW-nDeep,y=dh},{x=nW,y=nH},"y")           -- Holds Teeth
  end
end

function TOOL:DrawToolScreen(w, h)
  if(SERVER) then return end
  local scrTool = asmlib.GetOpVar("MONITOR_TOOL")
  if(not scrTool) then
    scrTool = asmlib.MakeScreen(0,0,w,h,conPalette)
    if(not scrTool) then
      return asmlib.StatusLog(nil,"DrawToolScreen: Invalid screen") end
    asmlib.SetOpVar("MONITOR_TOOL", scrTool)
    asmlib.LogInstance("DrawToolScreen: Create screen",gtArgsLogs)
  end
  scrTool:SetColor()
  scrTool:DrawRect({x=0,y=0},{x=w,y=h},"k","SURF",{"vgui/white"})
  scrTool:SetTextEdge(0,0)
  local siAnc, anEnt = self:GetAnchor()
  local tInfo = gsSymRev:Explode(siAnc)
  local stTrace = asmlib.CacheTracePly(LocalPlayer())
  if(not stTrace) then
    scrTool:DrawText("Trace status: Invalid","r","SURF",{"Trebuchet24"})
    scrTool:DrawTextAdd("  ["..(tInfo[1] or gsNoID).."]","an")
    return
  end
  scrTool:DrawText("Trace status: Valid","g","SURF",{"Trebuchet24"})
  scrTool:DrawTextAdd("  ["..(tInfo[1] or gsNoID).."]","an")
  local model = self:GetModel()
  local hdRec = asmlib.CacheQueryPiece(model)
  if(not hdRec) then
    scrTool:DrawText("Holds Model: Invalid","r")
    scrTool:DrawTextAdd("  ["..gsModeDataB.."]","db")
    return
  end
  scrTool:DrawText("Holds Model: Valid","g")
  scrTool:DrawTextAdd("  ["..gsModeDataB.."]","db")
  local NoAV  = "N/A"
  local trEnt = stTrace.Entity
  local trOrig, trModel, trRake, trRad
  local stmode = asmlib.GetCorrectID(self:GetStackMode(),conStackMod)
  if(trEnt and trEnt:IsValid()) then
    if(asmlib.IsOther(trEnt)) then return end
          trModel = trEnt:GetModel()
    local trRec   = asmlib.CacheQueryPiece(trModel)
          trModel = trModel:GetFileFromFilename()
    if(trRec) then
      trRake = asmlib.RoundValue(trRec.Rake,0.01)
      trRad  = asmlib.RoundValue(asmlib.AbsVector(trRec.Offs.P),0.01)
    end
  end
  local hdRad = asmlib.RoundValue(asmlib.AbsVector(hdRec.Offs.P),0.01)
  local nFrac = asmlib.RoundValue((trRad or 0) / hdRad,0.01)
  scrTool:DrawText("TM: "..(trModel or NoAV),"g")
  scrTool:DrawText("HM: "..(model:GetFileFromFilename() or NoAV),"m")
  scrTool:DrawText("Anc: "..self:GetAnchor("anchor"),"an")
  scrTool:DrawText("Rake: "..tostring(trRake or NoAV).." > "..tostring(asmlib.RoundValue(hdRec.Rake,0.01) or NoAV),"y")
  scrTool:DrawText("Frac: "..tostring(nFrac).." > "..tostring(trRad or gsNoID).."/"..tostring(hdRad))
  scrTool:DrawText("Mode: "..conStackMod:Select(stmode),"r")
  scrTool:DrawText("Date: "..tostring(asmlib.GetDate()),"w")
  self:DrawRatioVisual(scrTool,trRad,hdRad,10)
end

function TOOL.BuildCPanel(CPanel)
  local sLog = "*TOOL.BuildCPanel"; CPanel:ClearControls()
  CPanel:ClearControls(); CPanel:DockPadding(5, 0, 5, 10)
  local drmSkin, sLog = CPanel:GetSkin(), "*TOOL.BuildCPanel"
  local devmode = asmlib.GetAsmConvar("devmode", "BUL")
  local nMaxLin = asmlib.GetAsmConvar("maxlinear","FLT")
  local iMaxDec = asmlib.GetAsmConvar("maxmenupr","INT")
  local pItem = 0 -- pItem is the current panel created
          CPanel:SetName(asmlib.GetPhrase("tool."..gsToolNameL..".name"))
  pItem = CPanel:Help   (asmlib.GetPhrase("tool."..gsToolNameL..".desc"))

  local pComboPresets = vguiCreate("ControlPresets", CPanel)
        pComboPresets:SetPreset(gsToolNameL)
        pComboPresets:AddOption("Default", asmlib.GetOpVar("STORE_CONVARS"))
        for key, val in pairs(tableGetKeys(asmlib.GetOpVar("STORE_CONVARS"))) do
          pComboPresets:AddConVar(val) end
  CPanel:AddItem(pComboPresets)

  local cqPanel = asmlib.CacheQueryPanel(devmode); if(not cqPanel) then
    asmlib.LogInstance("Panel population empty",sLog); return end
  local defTable = asmlib.GetOpVar("DEFTABLE_PIECES")
  local catTypes = asmlib.GetOpVar("TABLE_CATEGORIES")
  local pTree    = vguiCreate("DTree")
        pTree:SetPos(2, CurY)
        pTree:SetSize(2, 300)
        pTree:SetIndentSize(0)
        pTree:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".model_con"))
  local iCnt, pFolders, pCateg, pNode = 1, {}, {}
  while(cqPanel[iCnt]) do
    local Rec = cqPanel[iCnt]
    local Mod = Rec[defTable[1][1]]
    local Typ = Rec[defTable[2][1]]
    local Nam = Rec[defTable[3][1]]
    if(fileExists(Mod, "GAME")) then
      if(not (asmlib.IsBlank(Typ) or pFolders[Typ])) then
        local pRoot = pTree:AddNode(Typ) -- No type folder made already
              pRoot.Icon:SetImage("icon16/database_connect.png")
              pRoot.InternalDoClick = function() end
              pRoot.DoClick         = function() return false end
              pRoot.DoRightClick    = function() SetClipboardText(pRoot:GetText()) end
              pRoot.Label.UpdateColours = function(pSelf)
                return pSelf:SetTextStyleColor(conPalette:Select("tx")) end
        pFolders[Typ] = pRoot
      end -- Reset the primary tree node pointer
      if(pFolders[Typ]) then pItem = pFolders[Typ] else pItem = pTree end
      -- Register the category if definition functional is given
      if(catTypes[Typ]) then -- There is a category definition
        if(not pCateg[Typ]) then pCateg[Typ] = {} end
        local bSuc, ptCat, psNam = pcall(catTypes[Typ].Cmp, Mod)
        -- If the call is successful in protected mode and a folder table is present
        if(bSuc) then
          local pCurr = pCateg[Typ]
          if(asmlib.IsBlank(ptCat)) then ptCat = nil end
          if(ptCat and type(ptCat) ~= "table") then ptCat = {ptCat} end
          if(ptCat and ptCat[1]) then
            local iCnt = 1; while(ptCat[iCnt]) do
              local sCat = tostring(ptCat[iCnt])
              if(asmlib.IsBlank(sCat)) then sCat = "Other" end
              if(pCurr[sCat]) then -- Jump next if already created
                pCurr, pItem = asmlib.GetDirectoryObj(pCurr, sCat)
              else -- Create the last needed node regarding pItem
                pCurr, pItem = asmlib.SetDirectoryObj(pItem, pCurr, sCat,"icon16/folder.png",conPalette:Select("tx"))
              end; iCnt = iCnt + 1;
            end
          end; if(psNam and not asmlib.IsBlank(psNam)) then Nam = tostring(psNam) end
        end -- Custom name to override via category
      end
      -- Register the node associated with the track piece
      pNode = pItem:AddNode(Nam)
      pNode.DoRightClick = function() SetClipboardText(Mod) end
      pNode:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".model"))
      pNode.Icon:SetImage("icon16/brick.png")
      pNode.DoClick = function() RunConsoleCommand(gsToolPrefL.."model", Mod) end
    else asmlib.LogInstance("Piece <"..Mod.."> from extension <"..Typ.."> not available .. SKIPPING !",gtArgsLogs) end
    iCnt = iCnt + 1
  end
  CPanel:AddItem(pTree)
  CurY = CurY + pTree:GetTall() + 2
  asmlib.LogInstance("Found #"..tostring(iCnt-1).." piece items.",gtArgsLogs)

  -- http://wiki.garrysmod.com/page/Category:DComboBox
  local ConID = asmlib.GetCorrectID(asmlib.GetAsmVar("contyp","STR"),conConstTyp)
  local pConsType = vguiCreate("DComboBox")
        pConsType:SetPos(2, CurY)
        pConsType:SetTall(18)
        pConsType:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".contyp"))
        pConsType:SetValue(conConstTyp:Select(ConID).Name or ("<"..conConstTyp:GetInfo()..">"))
        CurY = CurY + pConsType:GetTall() + 2
  local iCnt = 1
  local Val = conConstTyp:Select(iCnt)
  while(Val) do
    pConsType:AddChoice(Val.Name)
    pConsType.OnSelect = function(pnSelf,iID,anyVal)
      RunConsoleCommand(gsToolPrefL.."contyp",iID)
    end
    iCnt = iCnt + 1
    Val = conConstTyp:Select(iCnt)
  end
  pConsType:ChooseOptionID(ConID)
  CPanel:AddItem(pConsType)

-- http://wiki.garrysmod.com/page/Category:DTextEntry
  local pText = vguiCreate("DTextEntry")
        pText:SetPos(2, CurY)
        pText:SetTall(18)
        pText:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".bgskids"))
        pText:SetText(asmlib.DefaultString(asmlib.GetAsmVar("bgskids", "STR"),asmlib.GetPhrase("tool."..gsToolNameL..".bgskids_def")))
        pText.OnKeyCodeTyped = function(pnSelf, nKeyEnum)
          if(nKeyEnum == KEY_TAB) then
            local sTX = asmlib.GetPropBodyGroup()..gsSymDir..asmlib.GetPropSkin()
            pnSelf:SetText(sTX)
            pnSelf:SetValue(sTX)
          elseif(nKeyEnum == KEY_ENTER) then
            local sTX = pnSelf:GetValue() or ""
            RunConsoleCommand(gsToolPrefL.."bgskids",sTX)
          end
        end; CurY = CurY + pText:GetTall() + 2
  CPanel:AddItem(pText)

  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".mass_con"), gsToolPrefL.."mass", 1, asmlib.GetAsmVar("maxmass","FLT")  , 0)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".mass"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".count_con"), gsToolPrefL.."count", 1, asmlib.GetAsmVar("maxstcnt" , "INT"), 0)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".count"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase ("tool."..gsToolNameL..".angsnap_con"), gsToolPrefL.."angsnap", 0, gnMaxRot, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".angsnap"))
  pItem = CPanel:Button(asmlib.GetPhrase("tool."..gsToolNameL..".resetvars_con"), gsToolPrefL.."resetvars")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".resetvars"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".rotpivt_con"), gsToolPrefL.."rotpivt", -gnMaxRot, gnMaxRot, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".rotpivt"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".rotpivh_con"), gsToolPrefL.."rotpivh", -gnMaxRot, gnMaxRot, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".rotpivh"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".deltarot_con"), gsToolPrefL.."deltarot", -gnMaxRot, gnMaxRot, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".deltarot"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".nextyaw_con"), gsToolPrefL.."nextyaw", -gnMaxRot, gnMaxRot, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".nextyaw"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".nextpic_con"), gsToolPrefL.."nextpic", -gnMaxRot, gnMaxRot, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".nextpic"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".nextrol_con"), gsToolPrefL.."nextrol", -gnMaxRot, gnMaxRot, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".nextrol"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".nextx_con"), gsToolPrefL.."nextx", -nMaxLin, nMaxLin, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".nextx"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".nexty_con"), gsToolPrefL.."nexty", -nMaxLin, nMaxLin, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".nexty"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".nextz_con"), gsToolPrefL.."nextz", -nMaxLin, nMaxLin, iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".nextz"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".friction_con"), gsToolPrefL.."friction", 0, asmlib.GetAsmVar("maxfrict","FLT"), iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".friction"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".forcelim_con"), gsToolPrefL.."forcelim", 0, asmlib.GetAsmVar("maxforce","FLT"), iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".forcelim"))
  pItem = CPanel:NumSlider(asmlib.GetPhrase("tool."..gsToolNameL..".torquelim_con"), gsToolPrefL.."torquelim", 0, asmlib.GetAsmVar("maxtorque","FLT"), iMaxDec)
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".torquelim"))
  pItem = CPanel:CheckBox(asmlib.GetPhrase("tool."..gsToolNameL..".nocollide_con"), gsToolPrefL.."nocollide")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".nocollide"))
  pItem = CPanel:CheckBox(asmlib.GetPhrase("tool."..gsToolNameL..".freeze_con"), gsToolPrefL.."freeze")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".freeze"))
  pItem = CPanel:CheckBox(asmlib.GetPhrase("tool."..gsToolNameL..".ignphysgn_con"), gsToolPrefL.."ignphysgn")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".ignphysgn"))
  pItem = CPanel:CheckBox(languageGetPhrase("tool."..gsToolNameL..".upspanchor_con"), gsToolPrefL.."upspanchor")
           pItem:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".upspanchor"))
  pItem = CPanel:CheckBox(asmlib.GetPhrase("tool."..gsToolNameL..".gravity_con"), gsToolPrefL.."gravity")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".gravity"))
  pItem = CPanel:CheckBox(asmlib.GetPhrase("tool."..gsToolNameL..".trorang_con"), gsToolPrefL.."trorang")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".trorang"))
  pItem = CPanel:CheckBox(asmlib.GetPhrase("tool."..gsToolNameL..".igntyp_con"), gsToolPrefL.."igntyp")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".igntyp"))
  pItem = CPanel:CheckBox(asmlib.GetPhrase("tool."..gsToolNameL..".spnflat_con"), gsToolPrefL.."spnflat")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".spnflat"))
  pItem = CPanel:CheckBox(asmlib.GetPhrase("tool."..gsToolNameL..".adviser_con"), gsToolPrefL.."adviser")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".adviser"))
  pItem = CPanel:CheckBox(asmlib.GetPhrase("tool."..gsToolNameL..".ghosthold_con"), gsToolPrefL.."ghosthold")
           pItem:SetTooltip(asmlib.GetPhrase("tool."..gsToolNameL..".ghosthold"))
end
