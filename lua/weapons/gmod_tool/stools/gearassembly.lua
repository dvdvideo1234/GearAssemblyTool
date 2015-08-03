---------------- Localizing Libraries ----------------

local type              = type
local pairs             = pairs
local Angle             = Angle
local print             = print
local Color             = Color
local ipairs            = ipairs
local Vector            = Vector
local IsValid           = IsValid
local tonumber          = tonumber
local tostring          = tostring
local LocalPlayer       = LocalPlayer
local GetConVar         = GetConVar
local RunConsoleCommand = RunConsoleCommand
local os                = os
local sql               = sql
local math              = math
local ents              = ents
local util              = util
local undo              = undo
local file              = file
local string            = string
local cleanup           = cleanup
local concommand        = concommand
local duplicator        = duplicator
local constraint        = constraint

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
local gnMaxMass   = asmlib.GetOpVar("MAXCONVAR_MASS")
local gnMaxOffLin = asmlib.GetOpVar("MAXCONVAR_LINEAR")
local gnMaxOffRot = asmlib.GetOpVar("MAXCONVAR_ROTATION")
local gnMaxFreUse = asmlib.GetOpVar("MAXCONVAR_FREQUSED")
local gnMaxForLim = asmlib.GetOpVar("MAXCONVAR_FOCELIMIT")
local gnMaxStaCnt = asmlib.GetOpVar("MAXCONVAR_STACKCOUNT")
local gsToolPrefL = asmlib.GetToolPrefL()
local gsToolNameL = asmlib.GetToolNameL()
local gsToolPrefU = asmlib.GetToolPrefU()
local gsToolNameU = asmlib.GetToolNameU()


--- Render Base Colours
local DDyes = asmlib.MakeContainer("Colours")
      DDyes:Insert("r" ,Color(255, 0 , 0 ,255))
      DDyes:Insert("g" ,Color( 0 ,255, 0 ,255))
      DDyes:Insert("b" ,Color( 0 , 0 ,255,255))
      DDyes:Insert("c" ,Color( 0 ,255,255,255))
      DDyes:Insert("m" ,Color(255, 0 ,255,255))
      DDyes:Insert("y" ,Color(255,255, 0 ,255))
      DDyes:Insert("w" ,Color(255,255,255,255))
      DDyes:Insert("k" ,Color( 0 , 0 , 0 ,255))
      DDyes:Insert("gh",Color(255,255,255,150))
      DDyes:Insert("an",Color(180,255,150,255))
      DDyes:Insert("tx",Color(161,161,161,255))

local SMode = asmlib.GetOpVar("CONTAIN_STACK_MODE")
local CType = asmlib.GetOpVar("CONTAIN_CONSTRAINT_TYPE")

------------- LOCAL FUNCTIONS AND STUFF ----------------

if(CLIENT) then
  language.Add("tool."   ..gsToolNameL..".name", "Gear Assembly")
  language.Add("tool."   ..gsToolNameL..".desc", "Assembles gears to mesh together")
  language.Add("tool."   ..gsToolNameL..".0"   , "Left click to spawn/stack, Right to change mode, Reload to remove a piece")
  language.Add("cleanup."..gsToolNameL         , "Gear Assembly")
  language.Add("cleaned."..gsToolNameL.."s"    , "Cleaned up all Pieces")
  concommand.Add(gsToolPrefL.."resetoffs", asmlib.GetActionCode("RESET_OFFSETS"))
  concommand.Add(gsToolPrefL.."openframe", asmlib.GetActionCode("OPEN_FRAME"))
end

if(SERVER) then
  CreateConVar(gsToolPrefL.."bnderrmod","1",FCVAR_ARCHIVE      +
                                            FCVAR_ARCHIVE_XBOX +
                                            FCVAR_NOTIFY       +
                                            FCVAR_REPLICATED   +
                                            FCVAR_PROTECTED    +
                                            FCVAR_PRINTABLEONLY)
  cleanup.Register(gsToolNameU.."s")
  duplicator.RegisterEntityModifier(gsToolPrefL.."nophysgun",asmlib.GetActionCode("NO_PHYSGUN"))
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
  [ "anchor"    ] = "N/A",
  [ "contyp"    ] = "1",
  [ "stmode"    ] = "1",
  [ "freeze"    ] = "0",
  [ "advise"    ] = "1",
  [ "igntyp"    ] = "0",
  [ "rotpiv"    ] = "0",
  [ "nextpic"   ] = "0",
  [ "nextyaw"   ] = "0",
  [ "nextrol"   ] = "0",
  [ "enghost"   ] = "0",
  [ "addinfo"   ] = "0",
  [ "trorang"   ] = "0",
  [ "logsmax"   ] = "10000",
  [ "logfile"   ] = "gearasmlib_log",
  [ "bgskids"   ] = "",
  [ "spnflat"   ] = "0",
  [ "exportdb"  ] = "0",
  [ "forcelim"  ] = "0",
  [ "deltarot"  ] = "360",
  [ "maxstatts" ] = "3",
  [ "engravity" ] = "1",
  [ "nocollide" ] = "0",
  [ "nophysgun" ] = "0"
}

function TOOL:GetModel()
  return self:GetClientInfo("model") or ""
end

function TOOL:GetCount()
  return math.Clamp(self:GetClientNumber("count"),1,gnMaxStaCnt)
end

function TOOL:GetMass()
  return math.Clamp(self:GetClientNumber("mass"),1,gnMaxMass)
end

function TOOL:GetAdditionalInfo()
  return (self:GetClientNumber("addinfo") or 0)
end

function TOOL:GetPosOffsets()
  return (math.Clamp(self:GetClientNumber("nextx") or 0,-gnMaxOffLin,gnMaxOffLin)),
         (math.Clamp(self:GetClientNumber("nexty") or 0,-gnMaxOffLin,gnMaxOffLin)),
         (math.Clamp(self:GetClientNumber("nextz") or 0,-gnMaxOffLin,gnMaxOffLin))
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

function TOOL:GetEnableGravity()
  return (self:GetClientNumber("engravity") or 0)
end

function TOOL:GetEnableGhost()
  return (self:GetClientNumber("enghost") or 0)
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
  return (self:GetClientNumber("logsmax") or 0)
end

function TOOL:GetLogFile()
  return (self:GetClientInfo("logfile") or "")
end

function TOOL:GetAdvisor()
  return (self:GetClientNumber("advise") or 0)
end

function TOOL:GetTraceOriginAngle()
  return (self:GetClientNumber("trorang") or 0)
end

function TOOL:GetStackAttempts()
  return math.Clamp(self:GetClientNumber("maxstaatts"),1,5)
end

function TOOL:GetRotatePivot()
  return math.Clamp(self:GetClientNumber("rotpiv") or 0,-gnMaxOffRot,gnMaxOffRot)
end

function TOOL:GetDeltaRotation()
  return math.Clamp(self:GetClientNumber("deltarot") or 0,-gnMaxOffRot,gnMaxOffRot)
end

function TOOL:GetForceLimit()
  return math.Clamp(self:GetClientNumber("forcelim") or 0,0,gnMaxForLim)
end

function TOOL:GetStackMode()
  return (self:GetClientNumber("stmode") or 1)
end

function TOOL:GetContrType()
  return (self:GetClientNumber("contyp") or 1)
end

function TOOL:GetNoPhysgun()
  return (self:GetClientNumber("nophysgun") or 0)
end

function TOOL:GetBoundErrorMode()
  return math.floor(math.Clamp((GetConVar(gsToolPrefL.."bnderrmod"):GetFloat() or 0),0,gnMaxErMode))
end

function TOOL:LeftClick(Trace)
  if(CLIENT) then self:ClearObjects() return true end
  if(not Trace) then return false end
  if(not Trace.Hit) then return false end
  local trEnt     = Trace.Entity
  local eBase     = self:GetEnt(1)
  local ply       = self:GetOwner()
  local model     = self:GetModel()
  local freeze    = self:GetFreeze()
  local igntyp    = self:GetIgnoreType()
  local bgskids   = self:GetBodyGroupSkin()
  local engravity = self:GetEnableGravity()
  local nocollide = self:GetNoCollide()
  local spnflat   = self:GetSpawnFlat()
  local trorang   = self:GetTraceOriginAngle()
  local count     = self:GetCount()
  local mass      = self:GetMass()
  local staatts   = self:GetStackAttempts()
  local rotpiv    = self:GetRotatePivot()
  local deltarot  = self:GetDeltaRotation()
  local forcelim  = self:GetForceLimit()
  local nophysgun = self:GetNoPhysgun()
  local bnderrmod = self:GetBoundErrorMode()
  local stmode    = asmlib.GetCorrectID(self:GetStackMode(),SMode)
  local contyp    = asmlib.GetCorrectID(self:GetContrType(),CType)
  local nextx  , nexty  , nextz   = self:GetPosOffsets()
  local nextpic, nextyaw, nextrol = self:GetAngOffsets()
  asmlib.PlyLoadKey(ply)
  if(not asmlib.PlyLoadKey(ply,"SPEED") and
     not asmlib.PlyLoadKey(ply,"DUCK")) then
    -- Direct Snapping
    if(not (eBase and eBase:IsValid()) and (trEnt and trEnt:IsValid())) then eBase = trEnt end
    local ePiece = asmlib.MakePiece(model,Trace.HitPos,ANG_ZERO,mass,bgskids,DDyes:Select("w"))
    if(not ePiece) then return false end
    local stSpawn = asmlib.GetNormalSpawn(Trace,model,nextx,nexty,nextz,
                                              nextpic,nextyaw,nextrol)
    if(not stSpawn) then return false end
    stSpawn.SPos:Add(asmlib.GetCustomAngBBZ(ePiece,stSpawn.HRec,spnflat) * Trace.HitNormal)
    ePiece:SetAngles(stSpawn.SAng)
    if(ePiece:SetMapBoundPos(stSpawn.SPos,ply,bnderrmod,"Additional Error INFO"
      .."\n   Event  : Spawning when HitNormal"
      .."\n   Player : "..ply:Nick()
      .."\n   hdModel: "..asmlib.GetModelFileName(model))) then return false end
    undo.Create("Last Gear Assembly")
    if(not ePiece:Anchor(eBase,Trace.HitPos,Trace.HitNormal,contyp,nocollide,forcelim,freeze,engravity,nophysgun)) then
      asmlib.PrintNotify(ply,"Failed creating "..CType:Select(contyp).Name,"ERROR")
    end
    asmlib.EmitSoundPly(ply)
    undo.AddEntity(ePiece)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText("Undone Assembly ( Normal Spawn )")
    undo.Finish()
    return true
  end
  -- Hit Prop
  if(not trEnt) then return false end
  if(not trEnt:IsValid()) then return false end
  if(not asmlib.IsPhysTrace(Trace)) then return false end
  if(asmlib.IsOther(trEnt)) then return false end

  local trModel = trEnt:GetModel()
  local bsModel = "N/A"
  if(eBase and eBase:IsValid()) then bsModel = eBase:GetModel() end

  --No need stacking relative to non-persistent props or using them...
  local hdRec   = asmlib.CacheQueryPiece(model)
  local trRec   = asmlib.CacheQueryPiece(trModel)

  if(not trRec) then return false end

  if(asmlib.PlyLoadKey(ply,"DUCK")) then
    -- USE: Use the VALID Trace.Entity as a piece
    asmlib.PrintNotify(ply,"Model: "..asmlib.GetModelFileName(trModel).." selected !","GENERIC")
    ply:ConCommand(gsToolPrefL.."model "..trModel.."\n")
    return true
  end

  if(not hdRec) then return false end

  if(count > 1 and
     asmlib.PlyLoadKey(ply,"SPEED") and
     stmode >= 1 and
     stmode <= SMode:GetSize()
  ) then
    local stSpawn = asmlib.GetEntitySpawn(trEnt,rotpiv,model,igntyp,
                      trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return false end
    undo.Create("Last Gear Assembly")
    local ePieceN, ePieceO = nil, trEnt
    local iNdex  = count
    local nTrys  = staatts
    local dRot   = deltarot / count
    local aIter  = ePieceO:GetAngles()
    local aStart = ePieceO:GetAngles()
    while(iNdex > 0) do
      if(iNdex ~= count) then
        ePieceN = ePieceO:Duplicate()
      else
        ePieceN = asmlib.MakePiece(model,ePieceO:GetPos(),ANG_ZERO,mass,bgskids,DDyes:Select("w"))
      end
      if(ePieceN) then
        ePieceN:SetAngles(stSpawn.SAng)
        if(ePiece:SetMapBoundPos(stSpawn.SPos,ply,bnderrmod,"Additional Error INFO"
          .."\n   Event  : Stacking > Position out of map bounds"
          .."\n   StMode : "..SMode:Select(stmode)
          .."\n   Iterats: "..tostring(count-iNdex)
          .."\n   StackTr: "..tostring(nTrys).." ?= "..tostring(staatts)
          .."\n   Player : "..ply:Nick()
          .."\n   DeltaRt: "..dRot
          .."\n   Anchor : "..asmlib.GetModelFileName(bsModel)
          .."\n   trModel: "..asmlib.GetModelFileName(trModel)
          .."\n   hdModel: "..asmlib.GetModelFileName(model))) then
          undo.SetPlayer(ply)
          undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-iNdex).." )")
          undo.Finish()
          return false
        end
        if(not ePieceN:Anchor(eBase,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim,freeze,engravity,nophysgun)) then
          asmlib.PrintNotify(ply,"Failed creating "..CType:Select(contyp).Name,"ERROR")
        end
        undo.AddEntity(ePieceN)
        if(stmode == 1) then
          stSpawn = asmlib.GetEntitySpawn(ePieceN,rotpiv,model,igntyp,
                      trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
        elseif(stmode == 2) then
          aIter:RotateAroundAxis(stSpawn.CAng:Up(),-dRot)
          trEnt:SetAngles(aIter)
          stSpawn = asmlib.GetEntitySpawn(trEnt,rotpiv,model,igntyp,
                      trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
        end
        if(not stSpawn) then
          asmlib.PrintNotify(ply,"Failed to obtain spawn data!","ERROR")
          asmlib.EmitSoundPly(ply)
          undo.SetPlayer(ply)
          undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-iNdex).." )")
          undo.Finish()
          return asmlib.StatusLog(true,gsToolNameU.." Additional Error INFO"
          .."\n   Event  : Stacking > Failed to obtain spawn data"
          .."\n   StMode : "..SMode:Select(stmode)
          .."\n   Iterats: "..tostring(count-iNdex)
          .."\n   StackTr: "..tostring(nTrys).." ?= "..tostring(staatts)
          .."\n   Player : "..ply:Nick()
          .."\n   DeltaRt: "..dRot
          .."\n   Anchor : "..asmlib.GetModelFileName(bsModel)
          .."\n   trModel: "..asmlib.GetModelFileName(trModel)
          .."\n   hdModel: "..asmlib.GetModelFileName(model))
        end
        ePieceO = ePieceN
        iNdex = iNdex - 1
        nTrys = staatts
      else
        nTrys = nTrys - 1
      end
      if(nTrys <= 0) then
        asmlib.PrintNotify(ply,"Make attempts ran off!","ERROR")
        asmlib.EmitSoundPly(ply)
        undo.SetPlayer(ply)
        undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-iNdex).." )")
        undo.Finish()
        return asmlib.StatusLog(false,gsToolNameU.." Additional Error INFO"
        .."\n   Event  : Stacking > Failed to allocate memory for a piece"
        .."\n   StMode : "..SMode:Select(stmode)
        .."\n   Iterats: "..tostring(count-iNdex)
        .."\n   StackTr: "..tostring(nTrys).." ?= "..tostring(staatts)
        .."\n   Player : "..ply:Nick()
        .."\n   DeltaRt: "..dRot
        .."\n   Anchor : "..asmlib.GetModelFileName(bsModel)
        .."\n   trModel: "..asmlib.GetModelFileName(trModel)
        .."\n   hdModel: "..asmlib.GetModelFileName(model))
      end
    end
    trEnt:SetAngles(aStart)
    asmlib.EmitSoundPly(ply)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-iNdex).." )")
    undo.Finish()
    return true
  end

  local stSpawn = asmlib.GetEntitySpawn(trEnt,rotpiv,model,igntyp,
                    trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
  if(stSpawn) then
    local ePiece = asmlib.MakePiece(model,Trace.HitPos,ANG_ZERO,mass,bgskids,DDyes:Select("w"))
    if(ePiece) then
      ePiece:SetAngles(stSpawn.SAng)
      if(ePiece:SetMapBoundPos(stSpawn.SPos,ply,bnderrmod,"Additional Error INFO"
        .."\n   Event  : Spawn one piece relative to another"
        .."\n   Player : "..ply:Nick()
        .."\n   Anchor : "..asmlib.GetModelFileName(bsModel)
        .."\n   trModel: "..asmlib.GetModelFileName(trModel)
        .."\n   hdModel: "..asmlib.GetModelFileName(model))) then return false end      
      undo.Create("Last Gear Assembly")
      if(not ePiece:Anchor(eBase,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim,freeze,engravity,nophysgun)) then
        asmlib.PrintNotify(ply,"Failed creating "..CType:Select(contyp).Name,"ERROR")
      end
      asmlib.EmitSoundPly(ply)
      undo.AddEntity(ePiece)
      undo.SetPlayer(ply)
      undo.SetCustomUndoText("Undone Assembly ( Prop Relative )")
      undo.Finish()
      return true
    end
  end
  return false
end

function TOOL:RightClick(Trace)
  if(CLIENT) then return true end
  if(not Trace) then return false end
  local ply = self:GetOwner()
  asmlib.PlyLoadKey(ply)
  if(Trace.HitWorld and asmlib.PlyLoadKey(ply,"USE")) then
    ply:ConCommand(gsToolPrefL.."openframe "..gnMaxFreUse.."\n")
    return true
  end
  if(asmlib.PlyLoadKey(ply,"SPEED")) then
    local trEnt = Trace.Entity
    if(Trace.HitWorld) then
      local svEnt = self:GetEnt(1)
      if(svEnt and svEnt:IsValid()) then
        svEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
        svEnt:SetColor(DDyes:Select("w"))
      end
      asmlib.PrintNotify(ply,"Anchor: Cleaned !","CLEANUP")
      ply:ConCommand(gsToolPrefL.."anchor N/A\n")
      self:ClearObjects()
      return true
    elseif(trEnt and trEnt:IsValid() and not asmlib.IsOther(trEnt)) then
      local svEnt = self:GetEnt(1)
      if(svEnt and svEnt:IsValid()) then
        svEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
        svEnt:SetColor(DDyes:Select("w"))
      end
      self:ClearObjects()
      pyEnt = trEnt:GetPhysicsObject()
      if(not (pyEnt and pyEnt:IsValid())) then return false end
      self:SetObject(1,trEnt,Trace.HitPos,pyEnt,Trace.PhysicsBone,Trace.HitNormal)
      trEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
      trEnt:SetColor(DDyes:Select("an"))
      local trModel = asmlib.GetModelFileName(trEnt:GetModel())
      ply:ConCommand(gsToolPrefL.."anchor ["..trEnt:EntIndex().."] "..trModel.."\n")
      asmlib.PrintNotify(ply,"Anchor: Set "..trModel.." !","UNDO")
      return true
    else
      return false
    end
  else
    local stmode = asmlib.GetCorrectID(self:GetStackMode(),SMode)
          stmode = asmlib.GetCorrectID(stmode + 1,SMode)
    ply:ConCommand(gsToolPrefL.."stmode "..stmode.."\n")
    asmlib.PrintNotify(ply,"Stack Mode: "..SMode:Select(stmode).." !","UNDO")
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
      asmlib.SQLExportIntoLua    ("PIECES")
      asmlib.SQLExportIntoInserts("PIECES")
      asmlib.SQLExportIntoDSV    ("PIECES","\t")
      return asmlib.StatusLog(true,"TOOL:Reload(Trace) > DB Exported")
    end
  end
  if(not asmlib.IsPhysTrace(Trace)) then return false end
  local trEnt = Trace.Entity
  if(asmlib.IsOther(trEnt)) then return false end
  local trRec = asmlib.CacheQueryPiece(trEnt:GetModel())
  if(trRec) then
    trEnt:Remove()
    return true
  end
  return false
end

function TOOL:Holster()
  self:ReleaseGhostEntity()
  if(self.GhostEntity and self.GhostEntity:IsValid()) then
    self.GhostEntity:Remove()
  end
end

local function DrawAdditionalInfo(oScreen,stSpawn)
  if(not stSpawn) then return end
  if(not oScreen) then return end
  local x, y = oScreen:GetCenter(10,10)
  oScreen:SetTextEdge(x,y)
  oScreen:SetFont("Trebuchet18")
  oScreen:DrawText("Org POS: "..tostring(stSpawn.OPos)"k")
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
                  surface.ScreenHeight(),DDyes,false)
    if(not goMonitor) then
      asmlib.PrintInstance(gsToolNameU..": DrawHUD: Invalid screen")
      return
    end
  end
  goMonitor:SetFont("Trebuchet24")
  local adv   = self:GetAdvisor()
  local ply   = LocalPlayer()
  local Trace = ply:GetEyeTrace()
  if(adv ~= 0) then
    if(not Trace) then return end
    local trEnt   = Trace.Entity
    local model   = self:GetModel()
    local addinfo = self:GetAdditionalInfo()
    local nextx, nexty, nextz = self:GetPosOffsets()
    local nextpic, nextyaw, nextrol = self:GetAngOffsets()
    local RadScal = asmlib.GetViewRadius(ply,Trace.HitPos)
    asmlib.PlyLoadKey(ply)
    if(trEnt and trEnt:IsValid() and asmlib.PlyLoadKey(ply,"SPEED")) then
      if(asmlib.IsOther(trEnt)) then return end
      local igntyp  = self:GetIgnoreType()
      local trorang = self:GetTraceOriginAngle()
      local rotpiv  = self:GetRotatePivot()
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
      goMonitor:DrawLine(Op,Xs,"r")       -- Base X
      goMonitor:DrawLine(Sp,Df)           -- Next
      goMonitor:DrawLine(Op,Zs,"b")       -- Base Z
      goMonitor:DrawLine(Cp,Cu,"y")       -- Base Z
      goMonitor:DrawCircle(Op,RadScal)    -- Base O
      goMonitor:DrawLine(Op,Ys,"g")       --
      goMonitor:DrawLine(Cp,Op)           --
      goMonitor:DrawCircle(Cp,RadScal)    --
      goMonitor:DrawLine(Op,Sp,"m")       --
      goMonitor:DrawCircle(Sp,Sp,RadScal) --
      goMonitor:DrawLine(Sp,Du,"c")       --
      if(addinfo ~= 0) then
        DrawAdditionalInfo(goMonitor,stSpawn)
      end
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
      goMonitor:DrawCircle(Os,RadScal,"y")
      if(addinfo ~= 0) then
        DrawAdditionalInfo(stSpawn)
      end
    end
  end
end

local function DrawRatioVisual(oScreen,nTrR,nHdR,nDeep)
  if(not oScreen) then return end
  local D2 = math.floor((nDeep or 0) / 2)
  if(D2 <= 2) then return end
  local nW, nH = oScreen:GetSize()
  local dx, dy, dw, dh = oScreen:GetTextState(0,0,0,2)
  if(nTrR) then
    local Cent = math.floor((nTrR / ( nTrR + nHdR )) * nW)
    oScreen:DrawRect(0,dh,nDeep,nH-dy,"y")          -- Trace Teeth
    oScreen:DrawRect(nDeep,dh,Cent-D2,nH-dy,"g")    -- Trace Gear
    oScreen:DrawRect(Cent-D2,dh,Cent+D2,nH-dy,"y")  -- Meshing
    oScreen:DrawRect(Cent+D2,dh,nW-nDeep,nH-dy,"m") -- Holds Gear
    oScreen:DrawRect(nW-nDeep,dh,nW,nH-dy,"y")      -- Holds Teeth
  else
    oScreen:DrawRect(0,dh,nDeep,nH-dy,"y")          -- Holds Teeth
    oScreen:DrawRect(nDeep,dh,nW-nDeep,nH-dy,"g")   -- Holds
    oScreen:DrawRect(nW-nDeep,dh,nW,nH-dy,"y")      -- Holds Teeth
  end
end

function TOOL:DrawToolScreen(w, h)
  if(SERVER) then return end
  if(not goToolScr) then
    goToolScr = asmlib.MakeScreen(0,0,w,h,DDyes,false)
    if(not goToolScr) then
      asmlib.PrintInstance(gsToolNameU..": DrawToolScreen: Invalid screen")
      return
    end
  end
  goToolScr:DrawBackGround("k")
  goToolScr:SetFont("Trebuchet24")
  goToolScr:SetTextEdge(0,0)
  local Trace = LocalPlayer():GetEyeTrace()
  if(not Trace) then
    goToolScr:DrawText("Trace status: Invalid","r")
    return
  end
  goToolScr:DrawText("Trace status: Valid","g")
  local model = self:GetModel()
  local hdRec = asmlib.CacheQueryPiece(model)
  if(not hdRec) then
    goToolScr:DrawText("Holds Model: Invalid","r")
    return
  end
  goToolScr:DrawText("Holds Model: Valid","g")
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
  goToolScr:DrawText("Anc: "..self:GetClientInfo("anchor"),"an")
  goToolScr:DrawText("Mesh: "..tostring(trMesh or NoAV).." > "..tostring(asmlib.RoundValue(hdRec.Mesh,0.01) or NoAV),"y")
  goToolScr:DrawText("Ratio: "..tostring(Ratio).." > "..tostring(trRad or NoAV).."/"..tostring(hdRad))
  goToolScr:DrawText("StackMod: "..SMode:Select(stmode),"r")
  goToolScr:DrawText(tostring(os.date()),"w")
  DrawRatioVisual(goToolScr,trRad,hdRad,10)
end

function TOOL.BuildCPanel(CPanel)
  Header = CPanel:AddControl("Header", { Text        = "#tool."..gsToolNameL..".name",
                                         Description = "#tool."..gsToolNameL..".desc" })
  local CurY = Header:GetTall() + 2

  local Combo         = {}
  Combo["Label"]      = "#Presets"
  Combo["MenuButton"] = "1"
  Combo["Folder"]     = gsToolNameL
  Combo["CVars"]      = {}
  Combo["CVars"][ 1]  = gsToolPrefL.."mass"
  Combo["CVars"][ 2]  = gsToolPrefL.."stmode"
  Combo["CVars"][ 3]  = gsToolPrefL.."model"
  Combo["CVars"][ 4]  = gsToolPrefL.."count"
  Combo["CVars"][ 4]  = gsToolPrefL.."contyp"
  Combo["CVars"][ 5]  = gsToolPrefL.."freeze"
  Combo["CVars"][ 6]  = gsToolPrefL.."advise"
  Combo["CVars"][ 7]  = gsToolPrefL.."igntyp"
  Combo["CVars"][ 8]  = gsToolPrefL.."nextpic"
  Combo["CVars"][ 9]  = gsToolPrefL.."nextyaw"
  Combo["CVars"][10]  = gsToolPrefL.."nextrol"
  Combo["CVars"][11]  = gsToolPrefL.."nextx"
  Combo["CVars"][12]  = gsToolPrefL.."nexty"
  Combo["CVars"][13]  = gsToolPrefL.."nextz"
  Combo["CVars"][14]  = gsToolPrefL.."enghost"
  Combo["CVars"][15]  = gsToolPrefL.."engravity"
  Combo["CVars"][14]  = gsToolPrefL.."nocollide"
  Combo["CVars"][15]  = gsToolPrefL.."forcelim"
  Combo["CVars"][16]  = gsToolPrefL.."nophysgun"

  CPanel:AddControl("ComboBox",Combo)
  CurY = CurY + 25
  local Sorted  = asmlib.CacheQueryPanel()
  local stTable = asmlib.GetTableDefinition("PIECES")
  local pTree   = vgui.Create("DTree")
        pTree:SetPos(2, CurY)
        pTree:SetSize(2, 250)
        pTree:SetIndentSize(0)
  local pFolders = {}
  local pNode
  local pItem
  local Cnt = 1
  while(Sorted[Cnt]) do
    local Val = Sorted[Cnt]
    local Mod = Val[stTable[1][1]]
    local Typ = Val[stTable[2][1]]
    local Nam = Val[stTable[3][1]]
    if(file.Exists(Mod, "GAME")) then
      if(Typ ~= "" and not pFolders[Typ]) then
      -- No Folder, Make one xD
        pItem = pTree:AddNode(Typ)
        pItem:SetName(Typ)
        pItem.Icon:SetImage("icon16/disconnect.png")
        function pItem:InternalDoClick() end
          pItem.DoClick = function()
          return false
        end
        local FolderLabel = pItem.Label
        function FolderLabel:UpdateColours(skin)
          return self:SetTextStyleColor(DDyes:Select("tx"))
        end
        pFolders[Typ] = pItem
      end
      if(pFolders[Typ]) then
        pItem = pFolders[Typ]
      else
        pItem = pTree
      end
      pNode = pItem:AddNode(Nam)
      pNode:SetName(Nam)
      pNode.Icon:SetImage("icon16/control_play_blue.png")
      pNode.DoClick = function()
        RunConsoleCommand(gsToolPrefL.."model"  , Mod)
      end
    else
      asmlib.PrintInstance(gsToolNameU.." Model "
             .. Mod
             .. " is not available in"
             .. " your system .. SKIPPING !")
    end
    Cnt = Cnt + 1
  end
  CPanel:AddItem(pTree)
  CurY = CurY + pTree:GetTall() + 2
  asmlib.PrintInstance(gsToolNameU.." Found #"..tostring(Cnt-1).." piece items.")

  -- http://wiki.garrysmod.com/page/Category:DComboBox
  local ConID = asmlib.GetCorrectID(GetConVar(gsToolPrefL.."contyp"):GetString(),CType)
  local pConsType = vgui.Create("DComboBox")
        pConsType:SetPos(2, CurY)
        pConsType:SetTall(18)
        pConsType:SetValue(CType:Select(ConID).Name or ("<"..CType:GetInfo()..">"))
        CurY = CurY + pConsType:GetTall() + 2
  local Cnt = 1
  local Val = CType:Select(Cnt)
  while(Val) do
    pConsType:AddChoice(Val.Name)
    pConsType.OnSelect = function(panel,index,value)
      RunConsoleCommand(gsToolPrefL.."contyp",index)
    end
    Cnt = Cnt + 1
    Val = CType:Select(Cnt)
  end
  pConsType:ChooseOptionID(ConID)
  CPanel:AddItem(pConsType)

  -- http://wiki.garrysmod.com/page/Category:DTextEntry
  local pText = vgui.Create("DTextEntry")
        pText:SetPos(2, 300)
        pText:SetTall(18)
        pText:SetText(asmlib.GetDefaultString(GetConVar(gsToolPrefL.."bgskids"):GetString(),
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

  CPanel:AddControl("Slider", {
            Label   = "Piece mass: ",
            Type    = "Integer",
            Min     = 1,
            Max     = gnMaxMass,
            Command = gsToolPrefL.."mass"})

  CPanel:AddControl("Slider", {
            Label   = "Pieces count: ",
            Type    = "Integer",
            Min     = 1,
            Max     = gnMaxStaCnt,
            Command = gsToolPrefL.."count"})

  CPanel:AddControl("Button", {
            Label   = "V Reset Offset Values V",
            Command = gsToolPrefL.."resetoffs",
            Text    = "Reset All Offsets" })

  CPanel:AddControl("Slider", {
            Label   = "Pivot rotation: ",
            Type    = "Float",
            Min     = -gnMaxOffRot,
            Max     =  gnMaxOffRot,
            Command = gsToolPrefL.."rotpiv"})

  CPanel:AddControl("Slider", {
            Label   = "End angle pivot: ",
            Type    = "Float",
            Min     = -gnMaxOffRot,
            Max     =  gnMaxOffRot,
            Command = gsToolPrefL.."deltarot"})

  CPanel:AddControl("Slider", {
            Label   = "Piece rotation: ",
            Type    = "Float",
            Min     = -gnMaxOffRot,
            Max     =  gnMaxOffRot,
            Command = gsToolPrefL.."nextyaw"})

  CPanel:AddControl("Slider", {
            Label   = "UCS pitch: ",
            Type    = "Float",
            Min     = -gnMaxOffRot,
            Max     =  gnMaxOffRot,
            Command = gsToolPrefL.."nextpic"})

  CPanel:AddControl("Slider", {
            Label   = "UCS roll: ",
            Type    = "Float",
            Min     = -gnMaxOffRot,
            Max     =  gnMaxOffRot,
            Command = gsToolPrefL.."nextrol"})

  CPanel:AddControl("Slider", {
            Label   = "Offset X: ",
            Type    = "Float",
            Min     = -gnMaxOffLin,
            Max     =  gnMaxOffLin,
            Command = gsToolPrefL.."nextx"})

  CPanel:AddControl("Slider", {
            Label   = "Offset Y: ",
            Type    = "Float",
            Min     = -gnMaxOffLin,
            Max     =  gnMaxOffLin,
            Command = gsToolPrefL.."nexty"})

  CPanel:AddControl("Slider", {
            Label   = "Offset Z: ",
            Type    = "Float",
            Min     = -gnMaxOffLin,
            Max     =  gnMaxOffLin,
            Command = gsToolPrefL.."nextz"})

  CPanel:AddControl("Slider", {
            Label   = "Force Limit: ",
            Type    = "Float",
            Min     = 0,
            Max     = gnMaxForLim,
            Command = gsToolPrefL.."forcelim"})

  CPanel:AddControl("Checkbox", {
            Label   = "NoCollide new pieces to the anchor",
            Command = gsToolPrefL.."nocollide"})

  CPanel:AddControl("Checkbox", {
            Label   = "Freeze pieces",
            Command = gsToolPrefL.."freeze"})

  CPanel:AddControl("Checkbox", {
            Label   = "Turn off physgun",
            Command = gsToolPrefL.."nophysgun"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable pieces gravity",
            Command = gsToolPrefL.."engravity"})

  CPanel:AddControl("Checkbox", {
            Label   = "Use origin angle from trace",
            Command = gsToolPrefL.."trorang"})

  CPanel:AddControl("Checkbox", {
            Label   = "Ignore gear type",
            Command = gsToolPrefL.."igntyp"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable flat gear spawn",
            Command = gsToolPrefL.."spnflat"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable advisor",
            Command = gsToolPrefL.."advise"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable ghosting",
            Command = gsToolPrefL.."enghost"})
end

function TOOL:MakeGhostEntity(sModel)
  -- Check for invalid model
  if(not util.IsValidModel(sModel)) then return end
  util.PrecacheModel(sModel)
  -- We do ghosting serverside in single player
  -- It's done clientside in multiplayer
  if(SERVER and not game.SinglePlayer()) then return end
  if(CLIENT and     game.SinglePlayer()) then return end
  -- Release the old ghost entity
  self:ReleaseGhostEntity()
  if(CLIENT) then
    self.GhostEntity = ents.CreateClientProp(sModel)
  else
    if(util.IsValidRagdoll(sModel)) then
      self.GhostEntity = ents.Create("prop_dynamic")
    else
      self.GhostEntity = ents.Create("prop_physics")
    end
  end
  -- If there are too many entities we might not spawn..
  if(not self.GhostEntity:IsValid()) then
    self.GhostEntity = nil
    return
  end
  self.GhostEntity:SetModel(sModel)
  self.GhostEntity:SetPos(VEC_ZERO)
  self.GhostEntity:SetAngles(ANG_ZERO)
  self.GhostEntity:Spawn()
  self.GhostEntity:SetSolid(SOLID_VPHYSICS);
  self.GhostEntity:SetMoveType(MOVETYPE_NONE)
  self.GhostEntity:SetNotSolid(true);
  self.GhostEntity:SetRenderMode(RENDERMODE_TRANSALPHA)
  self.GhostEntity:SetColor(DDyes:Select("gh"))
end

function TOOL:UpdateGhost(oEnt, oPly)
  if(not oEnt) then return end
  if(not oEnt:IsValid()) then return end
  local Trace = util.TraceLine(util.GetPlayerTrace(oPly))
  if(not Trace) then return end
  local trEnt = Trace.Entity
  oEnt:SetNoDraw(true)
  asmlib.PlyLoadKey(oPly)
  if(trEnt and trEnt:IsValid() and asmlib.PlyLoadKey(oPly,"SPEED")) then
    if(asmlib.IsOther(trEnt)) then return end
    local trRec = asmlib.CacheQueryPiece(trEnt:GetModel())
    if(trRec) then
      local model   = self:GetModel()
      local nextx, nexty, nextz = self:GetPosOffsets()
      local igntyp  = self:GetIgnoreType()
      local trorang = self:GetTraceOriginAngle()
      local rotpiv  = self:GetRotatePivot()
      local nextpic, nextyaw, nextrol = self:GetAngOffsets()
      local stSpawn = asmlib.GetEntitySpawn(trEnt,rotpiv,model,igntyp,
                        trorang,nextx,nexty,nextz,nextpic,nextyaw,nextrol)
      if(not stSpawn) then return end
      oEnt:SetNoDraw(false)
      oEnt:SetAngles(stSpawn.SAng)
      asmlib.SetMCWorld(oEnt,stSpawn.HRec.M,stSpawn.SPos)
    end
  else
    local model = self:GetModel()
    local nextx, nexty, nextz = self:GetPosOffsets()
    local nextpic, nextyaw, nextrol = self:GetAngOffsets()
    local stSpawn = asmlib.GetNormalSpawn(Trace,model,
                      nextx,nexty,nextz,nextpic,nextyaw,nextrol)
    if(not stSpawn) then return end
    local spnflat = self:GetSpawnFlat()
    oEnt:SetNoDraw(false)
    oEnt:SetAngles(stSpawn.SAng)
    stSpawn.SPos:Add(asmlib.GetCustomAngBBZ(oEnt,stSpawn.HRec,spnflat) * Trace.HitNormal)
    asmlib.SetMCWorld(oEnt,stSpawn.HRec.M,stSpawn.SPos)
    return
  end
end

function TOOL:Think()
  local model = self:GetModel()
  if(self:GetEnableGhost() ~= 0 and util.IsValidModel(model)) then
    if (not self.GhostEntity or
        not self.GhostEntity:IsValid() or
            self.GhostEntity:GetModel() ~= model
    ) then
      -- If none ...
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
