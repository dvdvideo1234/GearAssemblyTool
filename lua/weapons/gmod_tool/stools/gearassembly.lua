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
local GetConVarString   = GetConVarString
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

--- ZERO Objects
local VEC_ZERO = Vector(0,0,0)
local ANG_ZERO = Angle (0,0,0)

--- Toolgun Background texture ID reference
local txToolgunBackground

--- Render Base Colours
local stDrawDyes = {
  Red   = Color(255, 0 , 0 ,255),
  Green = Color( 0 ,255, 0 ,255),
  Blue  = Color( 0 , 0 ,255,255),
  Cyan  = Color( 0 ,255,255,255),
  Magen = Color(255, 0 ,255,255),
  Yello = Color(255,255, 0 ,255),
  White = Color(255,255,255,255),
  Black = Color( 0 , 0 , 0 ,255),
  Ghost = Color(255,255,255,150),
  Anchr = Color(180,255,150,255),
  Txtsk = Color(161,161,161,255)
}

local stSMode = {
  ["MAX"]  = 2,
  ["ACT"] = "Stack Mode",
  [1] = "Forward based",
  [2] = "Around pivot"
}

local stCType = {
  ["MAX"] = 13,
  ["ACT"] = "Constraint Type",
  [1]  = {Name = "Free Spawn"  , Make = nil},
  [2]  = {Name = "No PhysGun"  , Make = nil},
  [3]  = {Name = "Parent Piece", Make = nil},
  [4]  = {Name = "Weld Piece"  , Make = constraint.Weld},
  [5]  = {Name = "Axis Piece"  , Make = constraint.Axis},
  [6]  = {Name = "Ball-Sock HM", Make = constraint.Ballsocket},
  [7]  = {Name = "Ball-Sock TM", Make = constraint.Ballsocket},
  [8]  = {Name = "AdvBS Lock X", Make = constraint.AdvBallsocket},
  [9]  = {Name = "AdvBS Lock Y", Make = constraint.AdvBallsocket},
  [10] = {Name = "AdvBS Lock Z", Make = constraint.AdvBallsocket},
  [11] = {Name = "AdvBS Spin X", Make = constraint.AdvBallsocket},
  [12] = {Name = "AdvBS Spin Y", Make = constraint.AdvBallsocket},
  [13] = {Name = "AdvBS Spin Z", Make = constraint.AdvBallsocket}
}

--- Because Vec[1] is actually faster than Vec.X
--- Vector Component indexes ---
local cvX = 1
local cvY = 2
local cvZ = 3

--- Angle Component indexes ---
local caP = 1
local caY = 2
local caR = 3

--- Component Status indexes ---
-- Sign of the first component
local csX = 1
-- Sign of the second component
local csY = 2
-- Sign of the third component
local csZ = 3
-- Flag for disabling the point
local csD = 4

------------- LOCAL FUNCTIONS AND STUFF ----------------

if(CLIENT) then
  language.Add("Tool."   ..gearasmlib.GetToolNameL()..".name", "Gear Assembly")
  language.Add("Tool."   ..gearasmlib.GetToolNameL()..".desc", "Assembles gears to mesh together")
  language.Add("Tool."   ..gearasmlib.GetToolNameL()..".0"   , "Left click to spawn/stack, Right to change mode, Reload to remove a piece")
  language.Add("Cleanup."..gearasmlib.GetToolNameL()         , "Gear Assembly")
  language.Add("Cleaned."..gearasmlib.GetToolNameL().."s"    , "Cleaned up all Pieces")

  local function ResetOffsets(oPly,oCom,oArgs)
    -- Reset all of the offset options to zero
    oPly:ConCommand(gearasmlib.GetToolPrefixL().."nextx 0\n")
    oPly:ConCommand(gearasmlib.GetToolPrefixL().."nexty 0\n")
    oPly:ConCommand(gearasmlib.GetToolPrefixL().."nextz 0\n")
    oPly:ConCommand(gearasmlib.GetToolPrefixL().."rotpiv 0\n")
    oPly:ConCommand(gearasmlib.GetToolPrefixL().."nextpic 0\n")
    oPly:ConCommand(gearasmlib.GetToolPrefixL().."nextyaw 0\n")
    oPly:ConCommand(gearasmlib.GetToolPrefixL().."nextrol 0\n")
  end
  concommand.Add(gearasmlib.GetToolPrefixL().."resetoffs",ResetOffsets)
  
  local function OpenGearAssemblyFrame(oPly,oCom,oArgs)
    local Ind = 1
    local CntN = tonumber(oArgs[1]) or 0
    local scrW = surface.ScreenWidth()
    local scrH = surface.ScreenHeight()
    local FrequentlyUsed = gearasmlib.GetFrequentlyUsed(CntN)
    if(not FrequentlyUsed) then
      oPly:ChatPrint(gearasmlib.GetToolNameU()..": Failed to retrieve most frequent models")
      return
    end
    if(not IsValid(pnGearAssemblyFrame)) then
      pnGearAssemblyFrame = vgui.Create("DFrame")
      pnGearAssemblyFrame:SetTitle("Frequently used pieces by "..oPly:Nick())
      pnGearAssemblyFrame:SetVisible(false)
      pnGearAssemblyFrame:SetDraggable(true)
      pnGearAssemblyFrame:SetDeleteOnClose(true)
      pnGearAssemblyFrame:SetPos(scrW/4, scrH/4)
      pnGearAssemblyFrame:SetSize(750, 280)
      pnGearAssemblyFrame.OnClose = function()
        pnGearAssemblyFrame:SetVisible(false)
        pnGearAssemblyButtonL:Remove()
        pnGearAssemblyButtonR:Remove()
        pnGearAssemblyListView:Remove()
        pnGearAssemblyModelPanel:Remove()
        pnGearAssemblyProgressBar:Remove()
      end
    end
    if(not IsValid(pnGearAssemblyModelPanel)) then
      pnGearAssemblyModelPanel = vgui.Create("DModelPanel",pnGearAssemblyFrame)
      pnGearAssemblyModelPanel:SetParent(pnGearAssemblyFrame)
      pnGearAssemblyModelPanel:SetPos(500,25)
      pnGearAssemblyModelPanel:SetSize(250, 255)
      pnGearAssemblyModelPanel:SetVisible(false)
      pnGearAssemblyModelPanel.LayoutEntity = function(pnSelf, oEnt)
        if(pnSelf.bAnimated) then
          pnSelf:RunAnimation()
        end
        local uiRec = gearasmlib.CacheQueryPiece(oEnt:GetModel())
        if(not uiRec) then return end
        local Ang  = Angle(0, RealTime() * 5, 0)
              gearasmlib.RotateAngleDir(Ang,"RUF",uiRec.A[caP],uiRec.A[caY],uiRec.A[caR])
        local Pos = Vector(uiRec.M[cvX],uiRec.M[cvY],uiRec.M[cvZ])
        local Rot = Vector()
              Rot:Set(Pos)
              Rot:Rotate(Ang)
              Rot:Mul(-1)
              Rot:Add(Pos)
        oEnt:SetAngles(Ang) 
        oEnt:SetPos(Rot)
      end
    end
    if(not IsValid(pnGearAssemblyProgressBar)) then
      pnGearAssemblyProgressBar = vgui.Create("DProgress", pnGearAssemblyFrame)
      pnGearAssemblyProgressBar:SetParent(pnGearAssemblyFrame)
      pnGearAssemblyProgressBar:SetVisible(false)
      pnGearAssemblyProgressBar:SetPos(10, 30)
      pnGearAssemblyProgressBar:SetSize(490, 30)
      pnGearAssemblyProgressBar:SetFraction(0)
    end
    if(not IsValid(pnGearAssemblyButtonL)) then
      pnGearAssemblyButtonL = vgui.Create("DButton", pnGearAssemblyFrame)
      pnGearAssemblyButtonL:SetParent(pnGearAssemblyFrame)
      pnGearAssemblyButtonL:SetText("Export client's DB")
      pnGearAssemblyButtonL:SetPos(15,30)
      pnGearAssemblyButtonL:SetSize(230,30)
      pnGearAssemblyButtonL.DoClick = function()
        local exportdb = GetConVarNumber(gearasmlib.GetToolPrefixL().."exportdb") or 0
        if(exportdb ~= 0) then
          gearasmlib.Log("Button: "..pnGearAssemblyButtonL:GetText())
          gearasmlib.ExportSQL2Lua    ("PIECES")
          gearasmlib.ExportSQL2Inserts("PIECES")
          gearasmlib.SQLExportIntoDSV ("PIECES","\t")
        end
      end
    end
    if(not IsValid(pnGearAssemblyButtonR)) then
      pnGearAssemblyButtonR = vgui.Create("DButton", pnGearAssemblyFrame)
      pnGearAssemblyButtonR:SetParent(pnGearAssemblyFrame)
      pnGearAssemblyButtonR:SetText("Set client's LOG control")
      pnGearAssemblyButtonR:SetPos(255,30)
      pnGearAssemblyButtonR:SetSize(230,30)
      pnGearAssemblyButtonR.DoClick = function()
        gearasmlib.Log("Button: "..pnGearAssemblyButtonR:GetText())
        local logsmax  = GetConVarNumber(gearasmlib.GetToolPrefixL().."logsmax") or 0
        if(logsmax > 0) then
          local logsenb = GetConVarNumber(gearasmlib.GetToolPrefixL().."logsenb") or 0
          local logfile = GetConVarString(gearasmlib.GetToolPrefixL().."logfile") or ""
          gearasmlib.SetLogControl(logsenb,logsmax,logfile)
        end
      end
    end
    if(not IsValid(pnGearAssemblyListView)) then
      pnGearAssemblyListView = vgui.Create("DListView", pnGearAssemblyFrame)
      pnGearAssemblyListView:SetParent(pnGearAssemblyFrame)
      pnGearAssemblyListView:SetVisible(false)
      pnGearAssemblyListView:SetMultiSelect(false)
      pnGearAssemblyListView:SetPos(10,65)
      pnGearAssemblyListView:SetSize(480,205)
      pnGearAssemblyListView:AddColumn("Life"):SetFixedWidth(55)
      pnGearAssemblyListView:AddColumn("Mesh"):SetFixedWidth(35)
      pnGearAssemblyListView:AddColumn("Type"):SetFixedWidth(100)
      pnGearAssemblyListView:AddColumn("Model"):SetFixedWidth(290)
      pnGearAssemblyListView.OnRowSelected = function(pnSelf, nRow, pnVal)
        local uiMod = FrequentlyUsed[nRow].Table[3]
        pnGearAssemblyModelPanel:SetModel(uiMod)
        local uiRec = gearasmlib.CacheQueryPiece(uiMod)
        if(not uiRec) then return end
        -- OBBCenter ModelPanel Configuration --
        local uiEnt = pnGearAssemblyModelPanel.Entity
        local uiCen = Vector(uiRec.M[cvX],uiRec.M[cvY],uiRec.M[cvZ])
        local uiEye = uiEnt:LocalToWorld(uiCen)
        gearasmlib.SubVectorXYZ(uiCen,uiRec.O[cvX],uiRec.O[cvY],uiRec.O[cvZ])
        local uiLen = uiCen:Length()
        local uiCam = Vector(uiLen, 0, 0.5 * uiLen)
        pnGearAssemblyModelPanel:SetLookAt(uiEye)
        pnGearAssemblyModelPanel:SetCamPos(2 * uiCam + uiEye)
        oPly:ConCommand(gearasmlib.GetToolPrefixL().."model "..uiMod.."\n")
      end
    end
    pnGearAssemblyFrame:SetVisible(true)
    pnGearAssemblyFrame:Center()
    pnGearAssemblyFrame:MakePopup()
    pnGearAssemblyListView:Clear()
    pnGearAssemblyListView:SetVisible(false)
    pnGearAssemblyProgressBar:SetVisible(true)
    pnGearAssemblyProgressBar:SetFraction(0)
    RestoreCursorPosition()
    while(FrequentlyUsed[Ind]) do
      local Val = FrequentlyUsed[Ind]
      local Rec = gearasmlib.CacheQueryPiece(Val.Table[3])
      if(Rec) then
        pnGearAssemblyListView:AddLine(
          gearasmlib.RoundValue(Val.Value,0.001),
            Val.Table[1],Val.Table[2],Val.Table[3])
      end
      pnGearAssemblyProgressBar:SetFraction(Ind/CntN)
      Ind = Ind + 1
    end
    pnGearAssemblyListView:SetVisible(true)
    pnGearAssemblyProgressBar:SetVisible(false)
    pnGearAssemblyButtonL:SetVisible(true)
    pnGearAssemblyButtonL:SetVisible(true)
    pnGearAssemblyModelPanel:SetVisible(true)
    RememberCursorPosition()
  end
  concommand.Add(gearasmlib.GetToolPrefixL().."openframe", OpenGearAssemblyFrame)
  
  txToolgunBackground = surface.GetTextureID("vgui/white")
end

TOOL.Category   = "Construction"            -- Name of the category
TOOL.Name       = "#Tool."..gearasmlib.GetToolNameL()..".name" -- Name to display
TOOL.Command    = nil                       -- Command on click ( nil )
TOOL.ConfigName = nil                       -- Config file name ( nil )
TOOL.AddToMenu  = true                      -- Yo add it to the Q menu or not ( true )

TOOL.ClientConVar = {
  [ "mass"      ] = "250",
  [ "model"     ] = "models/props_phx/trains/tracks/track_1x.mdl",
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
  [ "orangtr"   ] = "0",
  [ "logsenb"   ] = "0",
  [ "logsmax"   ] = "10000",
  [ "logfile"   ] = "gearasmlib_log",
  [ "bgskids"   ] = "",
  [ "spwnflat"  ] = "0",
  [ "exportdb"  ] = "0",
  [ "forcelim"  ] = "0",
  [ "deltarot"  ] = "360",
  [ "maxstatts" ] = "3",
  [ "engravity" ] = "1",
  [ "nocollide" ] = "0",
}

if(SERVER) then

  cleanup.Register(gearasmlib.GetToolNameU().."s")

  function LoadDupeGearAssemblyNoPhysgun(Ply,oEnt,tData)
    if(tData.NoPhysgun) then
      oEnt:SetMoveType(MOVETYPE_NONE)
      oEnt:SetUnFreezable(true)
      oEnt.PhysgunDisabled = true
      duplicator.StoreEntityModifier(oEnt,gearasmlib.GetToolPrefixL().."nophysgun",{NoPhysgun = true })
    end
  end

  duplicator.RegisterEntityModifier(gearasmlib.GetToolPrefixL().."nophysgun",LoadDupeGearAssemblyNoPhysgun)

  function eMakeGearAssemblyPiece(sModel,vPos,aAng,nMass,sBgSkIDs)
    -- You never know .. ^_^
    local stPiece = gearasmlib.CacheQueryPiece(sModel)
    if(not stPiece) then return nil end -- Not present in the DB
    local ePiece = ents.Create("prop_physics")
    if(ePiece and ePiece:IsValid()) then
      ePiece:SetCollisionGroup(COLLISION_GROUP_NONE)
      ePiece:SetSolid(SOLID_VPHYSICS)
      ePiece:SetMoveType(MOVETYPE_VPHYSICS)
      ePiece:SetNotSolid(false)
      ePiece:SetModel(sModel)
      ePiece:SetPos(vPos)
      ePiece:SetAngles(aAng)
      ePiece:Spawn()
      ePiece:Activate()
      ePiece:SetRenderMode(RENDERMODE_TRANSALPHA)
      ePiece:SetColor(stDrawDyes.White)
      ePiece:DrawShadow(true)
      ePiece:PhysWake()
      local phPiece = ePiece:GetPhysicsObject()
      if(phPiece and phPiece:IsValid()) then
        local IDs = gearasmlib.StringExplode(sBgSkIDs,"/")
        phPiece:SetMass(nMass)
        phPiece:EnableMotion(false)
        gearasmlib.AttachBodyGroups(ePiece,IDs[1] or "")
        ePiece:SetSkin(math.Clamp(tonumber(IDs[2]) or 0,0,ePiece:SkinCount()-1))
        return ePiece
      end
      ePiece:Remove()
      return nil
    end
    return nil
  end

  -- Returns Error Trigger ( False = No Error)
  function ConstraintGearAssemblyPiece(eBase,ePiece,vPos,vNorm,nID,nNoCollid,nForceLim,nFreeze,nGrav)
    local ConID    = tonumber(nID) or 1
    local Freeze   = nFreeze       or 0
    local Grav     = nGrav         or 0
    local NoCollid = nNoCollid     or 0
    local ForceLim = nForceLim     or 0
    local IsIn     = false
    if(not stCType[ConID]) then return true end
    gearasmlib.LogInstance("ConstraintGearAssemblyPiece: Creating "..stCType[ConID].Name..".")
    local ConstrInfo = stCType[ConID]
    -- Check for "Free Spawn" ( No constraints ) , coz nothing to be done after it.
    if(not IsIn and ConID == 1) then IsIn = true end
    if(not (ePiece and ePiece:IsValid())) then return true end
    if(not constraint.CanConstrain(ePiece,0)) then return true end
    if(gearasmlib.IsOther(ePiece)) then return true end
    if(not IsIn and ConID == 2) then
      -- Weld Ground is my custom child ...
      ePiece:SetUnFreezable(true)
      ePiece.PhysgunDisabled = true
      duplicator.StoreEntityModifier(ePiece,gearasmlib.GetToolPrefixL().."nophysgun",{NoPhysgun = true})
      IsIn = true
    end
    local pyPiece = ePiece:GetPhysicsObject()
    if(not (pyPiece and pyPiece:IsValid())) then return true end
    construct.SetPhysProp(nil,ePiece,0,pyPiece,{Material = "gmod_ice"})
    if(nFreeze and Freeze == 0) then
      pyPiece:EnableMotion(true)
    end
    if(not (Grav and nG ~= 0)) then
      construct.SetPhysProp(nil,ePiece,0,pyPiece,{GravityToggle = false})
    end
    if(not (eBase and eBase:IsValid())) then return true end
    if(not constraint.CanConstrain(eBase,0)) then return true end
    if(gearasmlib.IsOther(eBase)) then return true end
    if(not IsIn and ConID == 3) then
      -- http://wiki.garrysmod.com/page/Entity/SetParent
      ePiece:SetParent(eBase)
      IsIn = true
    elseif(not IsIn and ConID == 4) then
      -- http://wiki.garrysmod.com/page/constraint/Weld
      local C = ConstrInfo.Make(ePiece,eBase,0,0,ForceLim,(NoCollid ~= 0),false)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    end
    if(not IsIn and ConID == 5 and vNorm) then
      -- http://wiki.garrysmod.com/page/constraint/Axis
      local LPos1 = pyPiece:GetMassCenter()
      local LPos2 = ePiece:LocalToWorld(LPos1)
            LPos2:Add(vNorm)
            LPos2:Set(eBase:WorldToLocal(LPos2))
      local C = ConstrInfo.Make(ePiece,eBase,0,0,
                                LPos1,LPos2,
                                ForceLim,0,0,NoCollid)
       gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
       IsIn = true
    elseif(not IsIn and ConID == 6) then
      -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( HD )
      local C = ConstrInfo.Make(eBase,ePiece,0,0,pyPiece:GetMassCenter(),ForceLim,0,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    elseif(not IsIn and ConID == 7 and vPos) then
      -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( TR )
      local vLPos2 = eBase:WorldToLocal(vPos)
      local C = ConstrInfo.Make(ePiece,eBase,0,0,vLPos2,ForceLim,0,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    end
    -- http://wiki.garrysmod.com/page/constraint/AdvBallsocket
    local pyBase = eBase:GetPhysicsObject()
    if(not (pyBase and pyBase:IsValid())) then return true end
    local Min,Max = 0.01,180
    local LPos1 = pyBase:GetMassCenter()
    local LPos2 = pyPiece:GetMassCenter()
    if(not IsIn and ConID == 8) then -- Lock X
      local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Min,-Max,-Max,Min,Max,Max,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    elseif(not IsIn and ConID == 9) then -- Lock Y
      local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max,-Min,-Max,Max,Min,Max,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    elseif(not IsIn and ConID == 10) then -- Lock Z
      local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max,-Max,-Min,Max,Max,Min,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    elseif(not IsIn and ConID == 11) then -- Spin X
      local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max,-Min,-Min,Max, Min, Min,0,0,0,1,NoCollid)
      local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max, Min, Min,Max,-Min,-Min,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C1,C2},2)
      IsIn = true
    elseif(not IsIn and ConID == 12) then -- Spin Y
      local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Min,-Max,-Min, Min,Max, Min,0,0,0,1,NoCollid)
      local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0, Min,-Max, Min,-Min,Max,-Min,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C1,C2},2)
      IsIn = true
    elseif(not IsIn and ConID == 13) then -- Spin Z
      local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Min,-Min,-Max, Min, Min,Max,0,0,0,1,NoCollid)
      local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0, Min, Min,-Max,-Min,-Min,Max,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C1,C2},2)
      IsIn = true
    end
    return (not IsIn)
  end

end

function TOOL:LeftClick(Trace)
  if(CLIENT) then self:ClearObjects() return true end
  if(not Trace) then return false end
  if(not Trace.Hit) then return false end
  local trEnt     = Trace.Entity
  local eBase     = self:GetEnt(1)
  local ply       = self:GetOwner()
  local model     = self:GetClientInfo("model")
  local nextx     = self:GetClientNumber("nextx") or 0
  local nexty     = self:GetClientNumber("nexty") or 0
  local nextz     = self:GetClientNumber("nextz") or 0
  local freeze    = self:GetClientNumber("freeze") or 0
  local igntyp    = self:GetClientNumber("igntyp") or 0
  local bgskids   = self:GetClientInfo("bgskids") or ""
  local engravity = self:GetClientNumber("engravity") or 0
  local nocollide = self:GetClientNumber("nocollide") or 0
  local spwnflat  = self:GetClientNumber("spwnflat") or 0
  local orangtr   = self:GetClientNumber("orangtr")  or 0
  local count     = math.Clamp(self:GetClientNumber("count"),1,200)
  local mass      = math.Clamp(self:GetClientNumber("mass"),1,50000)
  local staatts   = math.Clamp(self:GetClientNumber("maxstaatts"),1,5)
  local rotpiv    = math.Clamp(self:GetClientNumber("rotpiv") or 0,-360,360)
  local nextpic   = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
  local nextyaw   = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
  local nextrol   = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
  local deltarot  = math.Clamp(self:GetClientNumber("deltarot") or 0,-360,360)
  local forcelim  = math.Clamp(self:GetClientNumber("forcelim") or 0,0,1000000)
  local stmode    = gearasmlib.GetCorrectID(self:GetClientInfo("stmode"),stSMode)
  local contyp    = gearasmlib.GetCorrectID(self:GetClientInfo("contyp"),stCType)
  gearasmlib.PlyLoadKey(ply)
  if(not gearasmlib.PlyLoadKey(ply,"SPEED") and
     not gearasmlib.PlyLoadKey(ply,"DUCK")) then
    -- Direct Snapping
    if(not (eBase and eBase:IsValid()) and (trEnt and trEnt:IsValid())) then eBase = trEnt end
    local ePiece = eMakeGearAssemblyPiece(model,Trace.HitPos,ANG_ZERO,mass,bgskids)
    if(not ePiece) then return false end
    local stSpawn = gearasmlib.GetNORSpawn(Trace,model,nextx,nexty,nextz,
                                           nextpic,nextyaw,nextrol)
    if(not stSpawn) then return false end
    stSpawn.SPos:Add(gearasmlib.GetCustomAngBBZ(ePiece,stSpawn.HRec,spwnflat) * Trace.HitNormal)
    ePiece:SetAngles(stSpawn.SAng)
    if(util.IsInWorld(stSpawn.SPos)) then
      gearasmlib.SetMCWorld(ePiece,stSpawn.HRec.M,stSpawn.SPos)
    else
      ePiece:Remove()
      gearasmlib.PrintNotify(ply,"Position out of map bounds!","ERROR")
      gearasmlib.LogInstance(gearasmlib.GetToolNameU().." Additional Error INFO"
      .."\n   Event  : Spawning when HitNormal"
      .."\n   Player : "..ply:Nick()
      .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
      .."\n")
      return false
    end
    undo.Create("Last Gear Assembly")
    if(ConstraintGearAssemblyPiece(eBase,ePiece,Trace.HitPos,Trace.HitNormal,contyp,nocollide,forcelim,freeze,engravity)) then
      gearasmlib.PrintNotify(ply,"Ignore constraint "..stCType[contyp].Name..".","UNDO")
    end
    gearasmlib.EmitSoundPly(ply)
    undo.AddEntity(ePiece)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText("Undone Assembly ( Normal Spawn )")
    undo.Finish()
    return true
  end
  -- Hit Prop
  if(not trEnt) then return false end
  if(not trEnt:IsValid()) then return false end
  if(not gearasmlib.IsPhysTrace(Trace)) then return false end
  if(gearasmlib.IsOther(trEnt)) then return false end

  local trModel = trEnt:GetModel()
  local bsModel = "N/A"
  if(eBase and eBase:IsValid()) then bsModel = eBase:GetModel() end

  --No need stacking relative to non-persistent props or using them...
  local hdRec   = gearasmlib.CacheQueryPiece(model)
  local trRec   = gearasmlib.CacheQueryPiece(trModel)

  if(not trRec) then return false end

  if(gearasmlib.PlyLoadKey(ply,"DUCK")) then
    -- USE: Use the VALID Trace.Entity as a piece
    gearasmlib.PrintNotify(ply,"Model: "..gearasmlib.GetModelFileName(trModel).." selected !","GENERIC")
    ply:ConCommand(gearasmlib.GetToolPrefixL().."model "..trModel.."\n")
    return true
  end

  if(not hdRec) then return false end

  if(count > 1 and
     gearasmlib.PlyLoadKey(ply,"SPEED") and
     stmode >= 1 and
     stmode <= stSMode["MAX"]
  ) then
    local stSpawn = gearasmlib.GetENTSpawn(trEnt,rotpiv,model,igntyp,orangtr,
                                           nextx,nexty,nextz,
                                           nextpic,nextyaw,nextrol)
    if(not stSpawn) then return false end
    undo.Create("Last Gear Assembly")
    local ePieceN, ePieceO = nil, trEnt
    local i      = count
    local nTrys  = staatts
    local dRot   = deltarot / count
    local aIter  = ePieceO:GetAngles()
    local aStart = ePieceO:GetAngles()
    while(i > 0) do
      ePieceN = eMakeGearAssemblyPiece(model,ePieceO:GetPos(),ANG_ZERO,mass,bgskids)
      if(ePieceN) then
        ePieceN:SetAngles(stSpawn.SAng)
        if(util.IsInWorld(stSpawn.SPos)) then
          gearasmlib.SetMCWorld(ePieceN,stSpawn.HRec.M,stSpawn.SPos)
        else
          ePieceN:Remove()
          gearasmlib.PrintNotify(ply,"Position out of map bounds!","ERROR")
          gearasmlib.LogInstance(gearasmlib.GetToolNameU().." Additional Error INFO"
          .."\n   Event  : Stacking > Position out of map bounds"
          .."\n   StMode : "..stSMode[stmode]
          .."\n   Iterats: "..tostring(count-i)
          .."\n   StackTr: "..tostring(nTrys).." ?= "..tostring(staatts)
          .."\n   Player : "..ply:Nick()
          .."\n   DeltaRt: "..dRot
          .."\n   Anchor : "..gearasmlib.GetModelFileName(bsModel)
          .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
          .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
          .."\n")
          gearasmlib.EmitSoundPly(ply)
          undo.SetPlayer(ply)
          undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-i).." )")
          undo.Finish()
          return true
        end
        ConstraintGearAssemblyPiece(eBase,ePieceN,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim,freeze,engravity)
        undo.AddEntity(ePieceN)
        if(stmode == 1) then
          stSpawn = gearasmlib.GetENTSpawn(ePieceN,rotpiv,model,igntyp,
                                           orangtr,nextx,nexty,nextz,
                                           nextpic,nextyaw,nextrol)
          ePieceO = ePieceN
        elseif(stmode == 2) then
          aIter:RotateAroundAxis(stSpawn.CAng:Up(),-dRot)
          trEnt:SetAngles(aIter)
          stSpawn = gearasmlib.GetENTSpawn(trEnt,rotpiv,model,igntyp,
                                           orangtr,nextx,nexty,nextz,
                                           nextpic,nextyaw,nextrol)
        end
        if(not stSpawn) then
          gearasmlib.PrintNotify(ply,"Failed to obtain spawn data!","ERROR")
          gearasmlib.LogInstance(gearasmlib.GetToolNameU().." Additional Error INFO"
          .."\n   Event  : Stacking > Failed to obtain spawn data"
          .."\n   StMode : "..stSMode[stmode]
          .."\n   Iterats: "..tostring(count-i)
          .."\n   StackTr: "..tostring(nTrys).." ?= "..tostring(staatts)
          .."\n   Player : "..ply:Nick()
          .."\n   DeltaRt: "..dRot
          .."\n   Anchor : "..gearasmlib.GetModelFileName(bsModel)
          .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
          .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
          .."\n")
          gearasmlib.EmitSoundPly(ply)
          undo.SetPlayer(ply)
          undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-i).." )")
          undo.Finish()
          return true
        end
        i = i - 1
        nTrys = staatts
      else
        nTrys = nTrys - 1
      end
      if(nTrys <= 0) then
        gearasmlib.PrintNotify(ply,"Make attempts ran off!","ERROR")
        gearasmlib.LogInstance(gearasmlib.GetToolNameU().." Additional Error INFO"
        .."\n   Event  : Stacking > Failed to allocate memory for a piece"
        .."\n   StMode : "..stSMode[stmode]
        .."\n   Iterats: "..tostring(count-i)
        .."\n   StackTr: "..tostring(nTrys).." ?= "..tostring(staatts)
        .."\n   Player : "..ply:Nick()
        .."\n   DeltaRt: "..dRot
        .."\n   Anchor : "..gearasmlib.GetModelFileName(bsModel)
        .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
        .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
        .."\n")
        gearasmlib.EmitSoundPly(ply)
        undo.SetPlayer(ply)
        undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-i).." )")
        undo.Finish()
        return true
      end
    end
    trEnt:SetAngles(aStart)
    gearasmlib.EmitSoundPly(ply)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-i).." )")
    undo.Finish()
    return true
  end

  local stSpawn = gearasmlib.GetENTSpawn(trEnt,rotpiv,model,igntyp,
                                         orangtr,nextx,nexty,nextz,
                                         nextpic,nextyaw,nextrol)
  if(stSpawn) then
    local ePiece = eMakeGearAssemblyPiece(model,Trace.HitPos,ANG_ZERO,mass,bgskids)
    if(ePiece) then
      ePiece:SetAngles(stSpawn.SAng)
      if(util.IsInWorld(stSpawn.SPos)) then
        gearasmlib.SetMCWorld(ePiece,stSpawn.HRec.M,stSpawn.SPos)
      else
        ePiece:Remove()
        gearasmlib.PrintNotify(ply,"Position out of map bounds !","ERROR")
        gearasmlib.LogInstance(gearasmlib.GetToolNameU().." Additional Error INFO"
        .."\n   Event  : Spawn one piece relative to another"
        .."\n   Player : "..ply:Nick()
        .."\n   Anchor : "..gearasmlib.GetModelFileName(bsModel)
        .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
        .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
        .."\n")
        return true
      end
      undo.Create("Last Gear Assembly")
      if(ConstraintGearAssemblyPiece(eBase,ePiece,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim,freeze,engravity)) then
        gearasmlib.PrintNotify(ply,"Ignore constraint "..stCType[contyp].Name..".","UNDO")
      end
      gearasmlib.EmitSoundPly(ply)
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
  -- Change the tool mode
  if(CLIENT) then return true end
  if(not Trace) then return nil end
  local ply = self:GetOwner()
  gearasmlib.PlyLoadKey(ply)
  if(Trace.HitWorld and gearasmlib.PlyLoadKey(ply,"USE")) then
    ply:ConCommand(gearasmlib.GetToolPrefixL().."openframe 20\n")
    return true
  end
  if(gearasmlib.PlyLoadKey(ply,"SPEED")) then
    local trEnt = Trace.Entity
    if(Trace.HitWorld) then
      local svEnt = self:GetEnt(1)
      if(svEnt and svEnt:IsValid()) then
        svEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
        svEnt:SetColor(stDrawDyes.White)
      end
      gearasmlib.PrintNotify(ply,"Anchor: Cleaned !","CLEANUP")
      ply:ConCommand(gearasmlib.GetToolPrefixL().."anchor N/A\n")
      self:ClearObjects()
      return true
    elseif(trEnt and trEnt:IsValid()) then
      local svEnt = self:GetEnt(1)
      if(svEnt and svEnt:IsValid()) then
        svEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
        svEnt:SetColor(stDrawDyes.White)
      end
      self:ClearObjects()
      pyEnt = trEnt:GetPhysicsObject()
      if(not (pyEnt and pyEnt:IsValid())) then return false end
      self:SetObject(1,trEnt,Trace.HitPos,pyEnt,Trace.PhysicsBone,Trace.HitNormal)
      trEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
      trEnt:SetColor(stDrawDyes.Anchr)
      local trModel = gearasmlib.GetModelFileName(trEnt:GetModel())
      ply:ConCommand(gearasmlib.GetToolPrefixL().."anchor ["..trEnt:EntIndex().."] "..trModel.."\n")
      gearasmlib.PrintNotify(ply,"Anchor: Set "..trModel.." !","UNDO")
      return true
    end
    return false
  else
    local stmode = gearasmlib.GetCorrectID(self:GetClientInfo("stmode"),stSMode)
          stmode = gearasmlib.GetCorrectID(stmode + 1,stSMode)
    ply:ConCommand(gearasmlib.GetToolPrefixL().."stmode "..stmode.."\n")
    gearasmlib.PrintNotify(ply,"Stack Mode: "..stSMode[stmode].." !","UNDO")
    return true
  end
  return false
end

function TOOL:Reload(Trace)
  if(CLIENT) then return true end
  if(not Trace) then return false end
  local ply       = self:GetOwner()
  gearasmlib.PlyLoadKey(ply)
  if(Trace.HitWorld and gearasmlib.PlyLoadKey(ply,"SPEED")) then
    local logsenb   = self:GetClientNumber("logsenb") or 0
    local exportdb  = self:GetClientNumber("exportdb") or 0
    if(logsenb ~= 0) then
      local logsmax = self:GetClientNumber("logsmax") or 0
      local logfile = self:GetClientInfo  ("logfile") or ""
      if(logsmax > 0) then
        gearasmlib.SetLogControl(logsenb,logsmax,logfile)
      end
    end
    if(exportdb ~= 0) then
      gearasmlib.PrintInstance("TOOL:Reload(Trace) > Exporting DB")
      gearasmlib.ExportSQL2Lua("PIECES")
      gearasmlib.ExportSQL2Inserts("PIECES")
      gearasmlib.SQLExportIntoDSV("PIECES","\t")
    end
  end
  if(not gearasmlib.IsPhysTrace(Trace)) then return false end
  local trEnt = Trace.Entity
  if(gearasmlib.IsOther(trEnt)) then return false end
  local trRec = gearasmlib.CacheQueryPiece(trEnt:GetModel())
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

local function DrawTextRowColor(xyPos,sTxT,stColor)
  -- Always Set the font before usage:
  -- e.g. surface.SetFont("Trebuchet18")
  if(not xyPos) then return end
  if(not (xyPos.x and xyPos.y)) then return end
  surface.SetTextPos(xyPos.x,xyPos.y)
  if(stColor) then
    surface.SetTextColor(stColor)
  end
  surface.DrawText(sTxT)
  xyPos.w, xyPos.h = surface.GetTextSize(sTxT)
  xyPos.y = xyPos.y + xyPos.h
end

local function DrawLineColor(xyPosS,xyPosE,nW,nH,stColor)
  if(not (xyPosS and xyPosE)) then return end
  if(not (xyPosS.x and xyPosS.y and xyPosE.x and xyPosE.y)) then return end
  if(stColor) then
    surface.SetDrawColor(stColor)
  end
  if(xyPosS.x < 0 or xyPosS.x > nW) then return end
  if(xyPosS.y < 0 or xyPosS.y > nH) then return end
  if(xyPosE.x < 0 or xyPosE.x > nW) then return end
  if(xyPosE.y < 0 or xyPosE.y > nH) then return end
  surface.DrawLine(xyPosS.x,xyPosS.y,xyPosE.x,xyPosE.y)
end

local function DrawAdditionalInfo(stSpawn)
  if(not stSpawn) then return end
  local txPos = {x = 0, y = 0, w = 0, h = 0}
  txPos.x = surface.ScreenWidth() / 2 + 10
  txPos.y = surface.ScreenHeight()/ 2 + 10
  surface.SetFont("Trebuchet18")
  DrawTextRowColor(txPos,"Org POS: "..tostring(stSpawn.OPos),stDrawDyes.Black)
  DrawTextRowColor(txPos,"Dom ANG: "..tostring(stSpawn.DAng))
  DrawTextRowColor(txPos,"Mod POS: "..tostring(stSpawn.MPos))
  DrawTextRowColor(txPos,"Mod ANG: "..tostring(stSpawn.MAng))
  DrawTextRowColor(txPos,"Spn POS: "..tostring(stSpawn.SPos))
  DrawTextRowColor(txPos,"Spn ANG: "..tostring(stSpawn.SAng))
end

function TOOL:DrawHUD()
  if(SERVER) then return end
  local adv   = self:GetClientNumber("advise") or 0
  local ply   = LocalPlayer()
  local Trace = ply:GetEyeTrace()
  if(adv ~= 0) then
    if(not Trace) then return end
    local trEnt   = Trace.Entity
    local scrH    = surface.ScreenHeight()
    local scrW    = surface.ScreenWidth()
    local model   = self:GetClientInfo("model")
    local nextx   = self:GetClientNumber("nextx") or 0
    local nexty   = self:GetClientNumber("nexty") or 0
    local nextz   = self:GetClientNumber("nextz") or 0
    local addinfo = self:GetClientNumber("addinfo") or 0
    local nextpic = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
    local nextyaw = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
    local nextrol = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
    local RadScal = gearasmlib.GetViewRadius(ply,Trace.HitPos)
    gearasmlib.PlyLoadKey(ply)
    if(trEnt and trEnt:IsValid() and gearasmlib.PlyLoadKey(ply,"SPEED")) then
      if(gearasmlib.IsOther(trEnt)) then return end
      local igntyp  = self:GetClientNumber("igntyp") or 0
      local orangtr = self:GetClientNumber("orangtr") or 0
      local rotpiv  = math.Clamp(self:GetClientNumber("rotpiv") or 0,-360,360)
      local stSpawn = gearasmlib.GetENTSpawn(trEnt,rotpiv,model,igntyp,
                                             orangtr,nextx,nexty,nextz,
                                             nextpic,nextyaw,nextrol)
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
      DrawLineColor(Op,Xs,scrW,scrH,stDrawDyes.Red)
      DrawLineColor(Op,Ys,scrW,scrH,stDrawDyes.Green)
      DrawLineColor(Op,Zs,scrW,scrH,stDrawDyes.Blue)
      DrawLineColor(Cp,Cu,scrW,scrH,stDrawDyes.Yello)
      DrawLineColor(Cp,Op,scrW,scrH,stDrawDyes.Green)
      surface.DrawCircle(Op.x,Op.y,RadScal,stDrawDyes.Yello)
      surface.DrawCircle(Cp.x,Cp.y,RadScal,stDrawDyes.Green)
      -- Draw Spawn
      DrawLineColor(Op,Sp,scrW,scrH,stDrawDyes.Magen)
      DrawLineColor(Sp,Du,scrW,scrH,stDrawDyes.Cyan)
      DrawLineColor(Sp,Df,scrW,scrH,stDrawDyes.Red)
      surface.DrawCircle(Sp.x,Sp.y,RadScal,stDrawDyes.Magen)
      if(addinfo ~= 0) then
        DrawAdditionalInfo(stSpawn)
      end
    else
      local stSpawn  = gearasmlib.GetNORSpawn(Trace,model,nextx,nexty,nextz,
                                              nextpic,nextyaw,nextrol)
      if(not stSpawn) then return false end
      local addinfo = self:GetClientNumber("addinfo") or 0
      local Os = stSpawn.SPos:ToScreen()
      local Xs = (stSpawn.SPos + 15 * stSpawn.F):ToScreen()
      local Ys = (stSpawn.SPos + 15 * stSpawn.R):ToScreen()
      local Zs = (stSpawn.SPos + 15 * stSpawn.U):ToScreen()
      DrawLineColor(Os,Xs,scrW,scrH,stDrawDyes.Red)
      DrawLineColor(Os,Ys,scrW,scrH,stDrawDyes.Green)
      DrawLineColor(Os,Zs,scrW,scrH,stDrawDyes.Blue)
      surface.DrawCircle(Os.x,Os.y,RadScal,stDrawDyes.Yello)
      if(addinfo ~= 0) then
        DrawAdditionalInfo(stSpawn)
      end
    end
  end
end

local function DrawRatioVisual(nW,nH,nY,nTrR,nHdR,nDeep)
  if(nY >= nH) then return end
  local D2 = math.floor((nDeep or 0) / 2)
  if(D2 <= 2) then return end
  local MColor = stDrawDyes.Yello
  local TColor = stDrawDyes.Green
  local HColor = stDrawDyes.Magen
  if(nTrR) then
    -- Trace Teeth
    surface.SetDrawColor(MColor)
    surface.DrawTexturedRect(0,nY,nDeep,nH)
    -- Trace Gear
    local Cent = math.floor((nTrR / ( nTrR + nHdR )) * nW)
    surface.SetDrawColor(TColor)
    surface.DrawTexturedRect(nDeep,nY,Cent-D2,nH)
    -- Meshing
    surface.SetDrawColor(MColor)
    surface.DrawTexturedRect(Cent-D2,nY,Cent+D2,nH)
    -- Holds Gear
    surface.SetDrawColor(HColor)
    surface.DrawTexturedRect(Cent+D2,nY,nW-nDeep,nH)
    -- Holds Teeth
    surface.SetDrawColor(MColor)
    surface.DrawTexturedRect(nW-nDeep,nY,nW,nH)
  else
    -- Holds Teeth
    surface.SetDrawColor(MColor)
    surface.DrawTexturedRect(0,nY,nDeep,nH)
    -- Holds
    surface.SetDrawColor(TColor)
    surface.DrawTexturedRect(nDeep,nY,nW-nDeep,nH)
    -- Holds Teeth
    surface.SetDrawColor(MColor)
    surface.DrawTexturedRect(nW-nDeep,nY,nW,nH)
  end
end

function TOOL:DrawToolScreen(w, h)
  if(SERVER) then return end
  surface.SetTexture(txToolgunBackground)
  surface.SetDrawColor(stDrawDyes.Black)
  surface.DrawTexturedRect(0,0,w,h)
  surface.SetFont("Trebuchet24")
  local Trace = LocalPlayer():GetEyeTrace()
  local txPos = {x = 0, y = 0, w = 0, h = 0}
  if(not Trace) then
    DrawTextRowColor(txPos,"Trace status: Invalid",stDrawDyes.White)
    return
  end
  DrawTextRowColor(txPos,"Trace status: Valid",stDrawDyes.White)
  local model = self:GetClientInfo("model") or ""
  local hdRec = gearasmlib.CacheQueryPiece(model)
  if(not hdRec) then
    DrawTextRowColor(txPos,"Holds Model: Invalid")
    return
  end
  DrawTextRowColor(txPos,"Holds Model: Valid")
  local NoAV  = "N/A"
  local stmode  = gearasmlib.GetCorrectID(self:GetClientInfo("stmode"),stSMode)
  local trEnt = Trace.Entity
  local trOrig, trModel, trMesh, trRad
  if(trEnt and trEnt:IsValid()) then
    if(gearasmlib.IsOther(trEnt)) then return end
          trModel = trEnt:GetModel()
    local trRec   = gearasmlib.CacheQueryPiece(trModel)
          trModel = gearasmlib.GetModelFileName(trModel)
    if(trRec) then
      trMesh = gearasmlib.RoundValue(trRec.Mesh,0.01)
      trRad  = gearasmlib.RoundValue(gearasmlib.GetLengthVector(trRec.O),0.01)
    end
  end
  local hdRad = gearasmlib.RoundValue(gearasmlib.GetLengthVector(hdRec.O),0.01)
  local Ratio = gearasmlib.RoundValue((trRad or 0) / hdRad,0.01)
  DrawTextRowColor(txPos,"TM: "..(trModel or NoAV),stDrawDyes.Green)
  DrawTextRowColor(txPos,"HM: "..(gearasmlib.GetModelFileName(model) or NoAV),stDrawDyes.Magen)
  DrawTextRowColor(txPos,"Anc: "..self:GetClientInfo("anchor"),stDrawDyes.Anchr)
  DrawTextRowColor(txPos,"Mesh: "..tostring(trMesh or NoAV).." > "..tostring(gearasmlib.RoundValue(hdRec.Mesh,0.01) or NoAV),stDrawDyes.Yello)
  DrawTextRowColor(txPos,"Ratio: "..tostring(Ratio).." > "..tostring(trRad or NoAV).."/"..tostring(hdRad))
  DrawTextRowColor(txPos,"StackMod: "..stSMode[stmode],stDrawDyes.Red)
  DrawTextRowColor(txPos,tostring(os.date()),stDrawDyes.White)
  DrawRatioVisual(w,h,txPos.y+2,trRad,hdRad,7)
end

function TOOL.BuildCPanel(CPanel)
  Header = CPanel:AddControl("Header", { Text        = "#Tool.gearassembly.Name",
                                         Description = "#Tool.gearassembly.desc" })
  local CurY = Header:GetTall() + 2

  local Combo         = {}
  Combo["Label"]      = "#Presets"
  Combo["MenuButton"] = "1"
  Combo["Folder"]     = "gearassembly"
  Combo["CVars"]      = {}
  Combo["CVars"][ 1]  = gearasmlib.GetToolPrefixL().."mass"
  Combo["CVars"][ 2]  = gearasmlib.GetToolPrefixL().."stmode"
  Combo["CVars"][ 3]  = gearasmlib.GetToolPrefixL().."model"
  Combo["CVars"][ 4]  = gearasmlib.GetToolPrefixL().."count"
  Combo["CVars"][ 4]  = gearasmlib.GetToolPrefixL().."contyp"
  Combo["CVars"][ 5]  = gearasmlib.GetToolPrefixL().."freeze"
  Combo["CVars"][ 6]  = gearasmlib.GetToolPrefixL().."advise"
  Combo["CVars"][ 7]  = gearasmlib.GetToolPrefixL().."igntyp"
  Combo["CVars"][ 8]  = gearasmlib.GetToolPrefixL().."nextpic"
  Combo["CVars"][ 9]  = gearasmlib.GetToolPrefixL().."nextyaw"
  Combo["CVars"][10]  = gearasmlib.GetToolPrefixL().."nextrol"
  Combo["CVars"][11]  = gearasmlib.GetToolPrefixL().."nextx"
  Combo["CVars"][12]  = gearasmlib.GetToolPrefixL().."nexty"
  Combo["CVars"][13]  = gearasmlib.GetToolPrefixL().."nextz"
  Combo["CVars"][14]  = gearasmlib.GetToolPrefixL().."enghost"
  Combo["CVars"][15]  = gearasmlib.GetToolPrefixL().."engravity"
  Combo["CVars"][14]  = gearasmlib.GetToolPrefixL().."nocollide"
  Combo["CVars"][15]  = gearasmlib.GetToolPrefixL().."forcelim"

  CPanel:AddControl("ComboBox",Combo)
  CurY = CurY + 25
  local Sorted  = gearasmlib.PanelQueryPieces()
  local stTable = gearasmlib.GetTableDefinition("PIECES")
  local pTree   = vgui.Create("DTree")
        pTree:SetPos(2, CurY)
        pTree:SetSize(2, 250)
        pTree:SetIndentSize(0)
  local pFolders = {}
  local pNode
  local pItem
  local Cnt = 1
  while(Sorted[Cnt]) do
    local v     = Sorted[Cnt]
    local Model = v[stTable[1][1]]
    local Type  = v[stTable[2][1]]
    local Name  = v[stTable[3][1]]
    if(file.Exists(Model, "GAME")) then
      if(Type ~= "" and not pFolders[Type]) then
      -- No Folder, Make one xD
        pItem = pTree:AddNode(Type)
        pItem:SetName(Type)
        pItem.Icon:SetImage("icon16/disconnect.png")
        function pItem:InternalDoClick() end
          pItem.DoClick = function()
          return false
        end
        local FolderLabel = pItem.Label
        function FolderLabel:UpdateColours(skin)
          return self:SetTextStyleColor(stDrawDyes.Txtsk)
        end
        pFolders[Type] = pItem
      end
      if(pFolders[Type]) then
        pItem = pFolders[Type]
      else
        pItem = pTree
      end
      pNode = pItem:AddNode(Name)
      pNode:SetName(Name)
      pNode.Icon:SetImage("icon16/control_play_blue.png")
      pNode.DoClick = function()
        RunConsoleCommand(gearasmlib.GetToolPrefixL().."model"  , Model)
      end
    else
      gearasmlib.PrintInstance(gearasmlib.GetToolNameU().." Model "
             .. Model
             .. " is not available in"
             .. " your system .. SKIPPING !")
    end
    Cnt = Cnt + 1
  end
  CPanel:AddItem(pTree)
  CurY = CurY + pTree:GetTall() + 2
  gearasmlib.PrintInstance(gearasmlib.GetToolNameU().." Found #"..tostring(Cnt-1).." piece items.")

  -- http://wiki.garrysmod.com/page/Category:DComboBox
  local ConID = gearasmlib.GetCorrectID(GetConVarString(gearasmlib.GetToolPrefixL().."contyp"),stCType)
  local pConsType = vgui.Create("DComboBox")
        pConsType:SetPos(2, CurY)
        pConsType:SetTall(18)
        pConsType:SetValue(stCType[ConID].Name or ("<"..stCType["ACT"]..">"))
        CurY = CurY + pConsType:GetTall() + 2
  local Cnt = 1
  local Val = stCType[Cnt]
  while(Val) do
    pConsType:AddChoice(Val.Name)
    pConsType.OnSelect = function(panel,index,value)
      RunConsoleCommand(gearasmlib.GetToolPrefixL().."contyp",index)
    end
    Cnt = Cnt + 1
    Val = stCType[Cnt]
  end
  pConsType:ChooseOptionID(ConID)
  CPanel:AddItem(pConsType)

  -- http://wiki.garrysmod.com/page/Category:DTextEntry
  local pText = vgui.Create("DTextEntry")
        pText:SetPos(2,300)
        pText:SetTall(18)
        pText:SetText(gearasmlib.GetDefaultString(GetConVarString(gearasmlib.GetToolPrefixL().."bgskids"),
                                           "Comma delimited Body/Skin IDs > ENTER"))
        pText.OnEnter = function(self)
          local sTX = self:GetValue() or ""
          RunConsoleCommand(gearasmlib.GetToolPrefixL().."bgskids",sTX)
        end
        CurY = CurY + pText:GetTall() + 2

  -- http://wiki.garrysmod.com/page/Category:DButton
  local pButton = vgui.Create("DButton")
        pButton:SetParent(CPanel)
        pButton:SetText("V Click to AUTOFILL Bgrp/Skin IDs from Trace V")
        pButton:SetPos(2,CurY)
        pButton:SetTall(18)
        pButton.DoClick = function()
          local sBG = gearasmlib.GetBodygroupTrace()
               .."/"..gearasmlib.GetSkinTrace()
          pText:SetValue(sBG)
          RunConsoleCommand(gearasmlib.GetToolPrefixL().."bgskids",sBG)
        end
        CurY = CurY + pButton:GetTall() + 2
  CPanel:AddItem(pButton)
  CPanel:AddItem(pText)

  CPanel:AddControl("Slider", {
            Label   = "Piece mass: ",
            Type    = "Integer",
            Min     = 1,
            Max     = 50000,
            Command = gearasmlib.GetToolPrefixL().."mass"})

  CPanel:AddControl("Slider", {
            Label   = "Pieces count: ",
            Type    = "Integer",
            Min     = 1,
            Max     = 200,
            Command = gearasmlib.GetToolPrefixL().."count"})

  CPanel:AddControl("Button", {
            Label   = "V Reset Offset Values V",
            Command = gearasmlib.GetToolPrefixL().."resetoffs",
            Text    = "Reset All Offsets" })

  CPanel:AddControl("Slider", {
            Label   = "Pivot rotation: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = gearasmlib.GetToolPrefixL().."rotpiv"})

  CPanel:AddControl("Slider", {
            Label   = "End angle pivot: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = gearasmlib.GetToolPrefixL().."deltarot"})

  CPanel:AddControl("Slider", {
            Label   = "Piece rotation: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = gearasmlib.GetToolPrefixL().."nextyaw"})

  CPanel:AddControl("Slider", {
            Label   = "UCS pitch: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = gearasmlib.GetToolPrefixL().."nextpic"})

  CPanel:AddControl("Slider", {
            Label   = "UCS roll: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = gearasmlib.GetToolPrefixL().."nextrol"})

  CPanel:AddControl("Slider", {
            Label   = "Offset X: ",
            Type    = "Float",
            Min     = -100,
            Max     =  100,
            Command = gearasmlib.GetToolPrefixL().."nextx"})

  CPanel:AddControl("Slider", {
            Label = "Offset Y: ",
            Type  = "Float",
            Min   = -100,
            Max   =  100,
            Command = gearasmlib.GetToolPrefixL().."nexty"})

  CPanel:AddControl("Slider", {
            Label   = "Offset Z: ",
            Type    = "Float",
            Min     = -100,
            Max     =  100,
            Command = gearasmlib.GetToolPrefixL().."nextz"})

  CPanel:AddControl("Slider", {
            Label   = "Force Limit: ",
            Type    = "Float",
            Min     = 0,
            Max     = 1000000,
            Command = gearasmlib.GetToolPrefixL().."forcelim"})

  CPanel:AddControl("Checkbox", {
            Label   = "NoCollide new pieces to the anchor",
            Command = gearasmlib.GetToolPrefixL().."nocollide"})

  CPanel:AddControl("Checkbox", {
            Label   = "Freeze pieces",
            Command = gearasmlib.GetToolPrefixL().."freeze"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable pieces gravity",
            Command = gearasmlib.GetToolPrefixL().."engravity"})

  CPanel:AddControl("Checkbox", {
            Label   = "Use origin angle from trace",
            Command = gearasmlib.GetToolPrefixL().."orangtr"})

  CPanel:AddControl("Checkbox", {
            Label   = "Ignore gear type",
            Command = gearasmlib.GetToolPrefixL().."igntyp"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable flat gear spawn",
            Command = gearasmlib.GetToolPrefixL().."spwnflat"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable advisor",
            Command = gearasmlib.GetToolPrefixL().."advise"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable ghosting",
            Command = gearasmlib.GetToolPrefixL().."enghost"})
end

function TOOL:MakeGhostEntity(sModel,vPos,aAngle)
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
  self.GhostEntity:SetPos(vPos)
  self.GhostEntity:SetAngles(aAngle)
  self.GhostEntity:Spawn()
  self.GhostEntity:SetSolid(SOLID_VPHYSICS);
  self.GhostEntity:SetMoveType(MOVETYPE_NONE)
  self.GhostEntity:SetNotSolid(true);
  self.GhostEntity:SetRenderMode(RENDERMODE_TRANSALPHA)
  self.GhostEntity:SetColor(stDrawDyes.Ghost)
end

function TOOL:UpdateGhost(oEnt, oPly)
  if(not oEnt) then return end
  if(not oEnt:IsValid()) then return end
  local Trace = util.TraceLine(util.GetPlayerTrace(oPly))
  if(not Trace) then return end
  local trEnt = Trace.Entity
  oEnt:SetNoDraw(true)
  gearasmlib.PlyLoadKey(oPly)
  if(trEnt and trEnt:IsValid() and gearasmlib.PlyLoadKey(oPly,"SPEED")) then
    if(gearasmlib.IsOther(trEnt)) then return end
    local trRec = gearasmlib.CacheQueryPiece(trEnt:GetModel())
    if(trRec) then
      local nextx   = self:GetClientNumber("nextx") or 0
      local nexty   = self:GetClientNumber("nexty") or 0
      local nextz   = self:GetClientNumber("nextz") or 0
      local model   = self:GetClientInfo("model") or ""
      local igntyp  = self:GetClientNumber("igntyp") or 0
      local orangtr = self:GetClientNumber("orangtr") or 0
      local rotpiv  = math.Clamp(self:GetClientNumber("rotpiv") or 0,-360,360)
      local nextpic = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
      local nextyaw = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
      local nextrol = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
      local stSpawn = gearasmlib.GetENTSpawn(trEnt,rotpiv,model,igntyp,
                                             orangtr,nextx,nexty,nextz,
                                             nextpic,nextyaw,nextrol)
      if(not stSpawn) then return end
      oEnt:SetNoDraw(false)
      oEnt:SetAngles(stSpawn.SAng)
      gearasmlib.SetMCWorld(oEnt,stSpawn.HRec.M,stSpawn.SPos)
    end
  else
    local model   = self:GetClientInfo("model") or ""
    local nextx   = self:GetClientNumber("nextx") or 0
    local nexty   = self:GetClientNumber("nexty") or 0
    local nextz   = self:GetClientNumber("nextz") or 0
    local nextpic = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
    local nextyaw = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
    local nextrol = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
    local stSpawn = gearasmlib.GetNORSpawn(Trace,model,nextx,nexty,nextz,
                                           nextpic,nextyaw,nextrol)
    if(not stSpawn) then return end
    local spwnflat  = self:GetClientNumber("spwnflat") or 0
    oEnt:SetNoDraw(false)
    oEnt:SetAngles(stSpawn.SAng)
    stSpawn.SPos:Add(gearasmlib.GetCustomAngBBZ(oEnt,stSpawn.HRec,spwnflat) * Trace.HitNormal)
    gearasmlib.SetMCWorld(oEnt,stSpawn.HRec.M,stSpawn.SPos)
    return
  end
end

function TOOL:Think()
  local model = self:GetClientInfo("model")
  if((tonumber(self:GetClientInfo("enghost")) or 0) ~= 0 and
      util.IsValidModel(model)
  ) then
    if (not self.GhostEntity or
        not self.GhostEntity:IsValid() or
            self.GhostEntity:GetModel() ~= model
    ) then
      -- If none ...
      self:MakeGhostEntity(model, VEC_ZERO, ANG_ZERO)
    end
    self:UpdateGhost(self.GhostEntity, self:GetOwner())
  else
    self:ReleaseGhostEntity()
    if(self.GhostEntity and self.GhostEntity:IsValid()) then
      self.GhostEntity:Remove()
    end
  end
end
