--- Because Vec[1] is actually faster than Vec.X

--- Vector Component indexes ---
local cvX -- Vector X component
local cvY -- Vector Y component
local cvZ -- Vector Z component

--- Angle Component indexes ---
local caP -- Angle Pitch component
local caY -- Angle Yaw   component
local caR -- Angle Roll  component

--- Component Status indexes ---
local csX -- Sign of the first component
local csY -- Sign of the second component
local csZ -- Sign of the third component
local csD -- Flag for disabling the point

---------------- Localizing instances ------------------
local SERVER = SERVER
local CLIENT = CLIENT

---------------- Localizing Player keys ----------------
local IN_ALT1      = IN_ALT1
local IN_ALT2      = IN_ALT2
local IN_ATTACK    = IN_ATTACK
local IN_ATTACK2   = IN_ATTACK2
local IN_BACK      = IN_BACK
local IN_DUCK      = IN_DUCK
local IN_FORWARD   = IN_FORWARD
local IN_JUMP      = IN_JUMP
local IN_LEFT      = IN_LEFT
local IN_MOVELEFT  = IN_MOVELEFT
local IN_MOVERIGHT = IN_MOVERIGHT
local IN_RELOAD    = IN_RELOAD
local IN_RIGHT     = IN_RIGHT
local IN_SCORE     = IN_SCORE
local IN_SPEED     = IN_SPEED
local IN_USE       = IN_USE
local IN_WALK      = IN_WALK
local IN_ZOOM      = IN_ZOOM

---------------- Localizing ENT Properties ----------------
local COLLISION_GROUP_NONE  = COLLISION_GROUP_NONE
local SOLID_VPHYSICS        = SOLID_VPHYSICS
local MOVETYPE_VPHYSICS     = MOVETYPE_VPHYSICS
local RENDERMODE_TRANSALPHA = RENDERMODE_TRANSALPHA

---------------- Localizing Libraries ----------------
local Angle          = Angle
local collectgarbage = collectgarbage
local constraint     = constraint
local construct      = construct
local Color          = Color
local duplicator     = duplicator
local ents           = ents
local file           = file
local getmetatable   = getmetatable
local include        = include
local IsValid        = IsValid
local LocalPlayer    = LocalPlayer
local math           = math
local next           = next
local os             = os
local pairs          = pairs
local print          = print
local require        = require
local sql            = sql
local string         = string
local surface        = surface
local table          = table
local timer          = timer
local tonumber       = tonumber
local tostring       = tostring
local type           = type
local undo           = undo
local util           = util
local Vector         = Vector

---------------- CASHES SPACE --------------------

local LibCache  = {} -- Used to cache stuff in a Pool
local LibTables = {} -- Here is where the table references are stored
local LibAction = {} -- Used to attach external function to the lib
local LibOpVars = {} -- Used to Store operational Variable Values
local LibGetSQL = {} -- Space for storing built SQLs

module( "gearasmlib" )

---------------------------- AssemblyLib COMMON ----------------------------

function GetIndexes(sType)
  if(sType == "V") then
    return cvX, cvY, cvZ
  elseif(sType == "A") then
    return caP, caY, caR
  elseif(sType == "S") then
    return csX, csY, csZ, csD
  end
  return nil
end

function SetIndexes(sType,I1,I2,I3,I4)
  if(sType == "V") then
    cvX = I1
    cvY = I2
    cvZ = I3
  elseif(sType == "A") then
    caP = I1
    caY = I2
    caR = I3
  elseif(sType == "S") then
    csX = I1
    csY = I2
    csZ = I3
    csD = I4
  end
  return nil
end

function GetInstPref()
  if    (CLIENT) then return "cl_"
  elseif(SERVER) then return "sv_" end
  return "na_"
end

function PrintInstance(anyStuff)
  if(SERVER) then
    print("SERVER > "..tostring(anyStuff))
  elseif(CLIENT) then
    print("CLIENT > "..tostring(anyStuff))
  else
    print("NOINST > "..tostring(anyStuff))
  end
end

function Delay(nAdd)
  if(nAdd > 0) then
    local i = os.clock() + nAdd
    while(os.clock() < i) do end
  end
end

function GetOpVar(sName)
  return LibOpVars[sName]
end

function SetOpVar(sName, anyValue)
  LibOpVars[sName] = anyValue
end

function IsExistent(anyValue)
  if(anyValue ~= nil) then return true end
  return false
end

function IsString(anyValue)
  if(getmetatable(anyValue) == GetOpVar("TYPEMT_STRING")) then return true end
  return false
end

function InitAssembly(sName)
  SetOpVar("TYPEMT_STRING",getmetatable("TYPEMT_STRING"))
  if(not IsString(sName)) then
    PrintInstance("gearasmlib.lua: Error initializing. Expecting string argument")
    return false
  end
  if(string.len(sName) < 1 and
     tonumber(string.sub(sName,1,1))) then return end
  sName = sName.."assembly"
  SetOpVar("TOOLNAME_NL",string.lower(sName))
  SetOpVar("TOOLNAME_NU",string.upper(sName))
  SetOpVar("TOOLNAME_PL",LibOpVars["TOOLNAME_NL"].."_")
  SetOpVar("TOOLNAME_PU",LibOpVars["TOOLNAME_NU"].."_")
  SetOpVar("ARRAY_DECODEPOA",{0,0,0,1,1,1,false})
  SetOpVar("ANG_ZERO",Angle())
  SetOpVar("VEC_ZERO",Vector())
  SetOpVar("OPSYM_DISABLE","#")
  SetOpVar("OPSYM_REVSIGN","@")
  SetOpVar("OPSYM_DIVIDER","_")
  SetOpVar("SPAWN_ENTITY",{
    F    = Vector(),
    R    = Vector(),
    U    = Vector(),
    OPos = Vector(),
    SPos = Vector(),
    SAng = Angle (),
    MPos = Vector(),
    MAng = Angle (),
    CPos = Vector(),
    CAng = Angle (),
    DAng = Angle (),
    HRec = 0,
    TRec = 0
  })
  SetOpVar("SPAWN_NORMAL",{
    F    = Vector(),
    R    = Vector(),
    U    = Vector(),
    SPos = Vector(),
    SAng = Angle (),
    CAng = Angle (),
    DAng = Angle (),
    HRec = 0
  })
  return true
end

function GetToolNameL()
  return GetOpVar("TOOLNAME_NL")
end

function GetToolNameU()
  return GetOpVar("TOOLNAME_NU")
end

function GetToolPrefL()
  return GetOpVar("TOOLNAME_PL")
end

function GetToolPrefU()
  return GetOpVar("TOOLNAME_PU")
end

--- Angle

function ToAngle(aBase)
  return Angle((aBase[caP] or 0),
               (aBase[caY] or 0),
               (aBase[caR] or 0))
end

function ExpAngle(aBase)
  return (aBase[caP] or 0),
         (aBase[caY] or 0),
         (aBase[caR] or 0)
end

function AddAngle(aBase, adbAdd)
  aBase[caP] = aBase[caP] + adbAdd[caP]
  aBase[caY] = aBase[caY] + adbAdd[caY]
  aBase[caR] = aBase[caR] + adbAdd[caR]
end

function AddAnglePYR(aBase, nP, nY, nR)
  aBase[caP] = aBase[caP] + (nP or 0)
  aBase[caY] = aBase[caY] + (nY or 0)
  aBase[caR] = aBase[caR] + (nR or 0)
end

function SubAngle(aBase, adbSub)
  aBase[caP] = aBase[caP] - adbSub[caP]
  aBase[caY] = aBase[caY] - adbSub[caY]
  aBase[caR] = aBase[caR] - adbSub[caR]
end

function SubAnglePYR(aBase, nP, nY, nR)
  aBase[caP] = aBase[caP] - (nP or 0)
  aBase[caY] = aBase[caY] - (nY or 0)
  aBase[caR] = aBase[caR] - (nR or 0)
end

function NegAngle(aBase)
  aBase[caP] = -aBase[caP]
  aBase[caY] = -aBase[caY]
  aBase[caR] = -aBase[caR]
end

function SetAngle(aBase, adbSet)
  aBase[caP] = adbSet[caP]
  aBase[caY] = adbSet[caY]
  aBase[caR] = adbSet[caR]
end

function SetAnglePYR(aBase, nP, nY, nR)
  aBase[caP] = (nP or 0)
  aBase[caY] = (nY or 0)
  aBase[caR] = (nR or 0)
end

function RotateAngleDir(aBase, sOrder, nC1, nC2, nC3)
  if(not (aBase and sOrder)) then return end
  if(not IsString(sOrder)) then return end
  local Ind = 1
  local Val = {nC1, nC2, nC3}
  local C   = string.sub(sOrder,Ind,Ind)
  while(C ~= "" and Ind <= 3) do
    if    (C == "F") then
      aBase:RotateAroundAxis(aBase:Forward(),tonumber(Val[Ind]) or 0)
    elseif(C == "R") then
      aBase:RotateAroundAxis(aBase:Right(),tonumber(Val[Ind]) or 0)
    elseif(C == "U") then
      aBase:RotateAroundAxis(aBase:Up(),tonumber(Val[Ind]) or 0)
    end
    Ind = Ind + 1
    C = string.sub(sOrder,Ind,Ind)
  end
end

--- Vector

function ToVector(vBase)
  return Vector((vBase[cvX] or 0),
                (vBase[cvY] or 0),
                (vBase[cvZ] or 0))
end

function ExpVector(vBase)
  return (vBase[cvX] or 0),
         (vBase[cvY] or 0),
         (vBase[cvZ] or 0)
end

function GetLengthVector(vdbBase)
  local X = (vdbBase[cvX] or 0)
        X = X * X
  local Y = (vdbBase[cvY] or 0)
        Y = Y * Y
  local Z = (vdbBase[cvZ] or 0)
        Z = Z * Z
  return math.sqrt(X+Y+Z)
end

function RoundVector(vBase,nRound)
  local X = vBase[cvX] or 0
        X = RoundValue(X,nRound or 0.1)
  local Y = vBase[cvY] or 0
        Y = RoundValue(Y,nRound or 0.1)
  local Z = vBase[cvZ] or 0
        Z = RoundValue(Z,nRound or 0.1)
  vBase[cvX] = X
  vBase[cvY] = Y
  vBase[cvZ] = Z
end

function AddVector(vBase, vdbAdd)
  vBase[cvX] = vBase[cvX] + vdbAdd[cvX]
  vBase[cvY] = vBase[cvY] + vdbAdd[cvY]
  vBase[cvZ] = vBase[cvZ] + vdbAdd[cvZ]
end

function AddVectorXYZ(vBase, nX, nY, nZ)
  vBase[cvX] = vBase[cvX] + (nX or 0)
  vBase[cvY] = vBase[cvY] + (nY or 0)
  vBase[cvZ] = vBase[cvZ] + (nZ or 0)
end

function SubVector(vBase, vdbSub)
  vBase[cvX] = vBase[cvX] - vdbSub[cvX]
  vBase[cvY] = vBase[cvY] - vdbSub[cvY]
  vBase[cvZ] = vBase[cvZ] - vdbSub[cvZ]
end

function SubVectorXYZ(vBase, nX, nY, nZ)
  vBase[cvX] = vBase[cvX] - (nX or 0)
  vBase[cvY] = vBase[cvY] - (nY or 0)
  vBase[cvZ] = vBase[cvZ] - (nZ or 0)
end

function NegVector(vBase)
  vBase[cvX] = -vBase[cvX]
  vBase[cvY] = -vBase[cvY]
  vBase[cvZ] = -vBase[cvZ]
end

function SetVector(vVec, vdbSet)
  vVec[cvX] = vdbSet[cvX]
  vVec[cvY] = vdbSet[cvY]
  vVec[cvZ] = vdbSet[cvZ]
end

function SetVectorXYZ(vVec, nX, nY, nZ)
  vVec[cvX] = (nX or 0)
  vVec[cvY] = (nY or 0)
  vVec[cvZ] = (nZ or 0)
end

function DecomposeByAngle(V,A)
  if(not ( V and A ) ) then
    return Vector()
  end
  return Vector(V:DotProduct(A:Forward()),
                V:DotProduct(A:Right()),
                V:DotProduct(A:Up()))
end

function GetDefaultString(sBase, sDefault)
  if(IsString(sBase)) then
    if(string.len(sBase) > 0) then return sBase end
  end
  if(IsString(sDefault)) then return sDefault end
  return ""
end

function SetTableDefinition(sTable, tDefinition)
  if(not (sTable and tDefinition)) then return false end
  if(not IsString(sTable)) then return false end
  if(not tDefinition.Size) then return false end
  if(not tDefinition[1]) then return false end
  local TableKey = GetToolPrefU()..sTable
  for k,v in pairs(LibTables) do
    if(k == TableKey) then return false end
  end
  SetOpVar("QTABLE_"..sTable,TableKey)
  LogInstance("LibTables[\""..TableKey.."\"] = "
    ..tostring(tDefinition).." ["..tDefinition.Size.."]")
  LibTables[TableKey] = tDefinition
  return true
end

function GetTableDefinition(sTable)
  return LibTables[GetToolPrefU()..sTable]
end

---------- Library OOP -----------------

function MakeContainer(sInfo,sDefKey)
  local Info = tostring(sInfo or "Store Container")
  local Curs = 0
  local Data = {}
  local Sel  = ""
  local Ins  = ""
  local Del  = ""
  local Met  = ""
  local Key  = sDefKey or "(!_+*#-$@DEFKEY@$-#*+_!)"
  local self = {}
        self.Create = MakeContainer
  function self:GetInfo()
    return Info
  end
  function self:GetSize()
    return Curs
  end
  function self:Insert(nsKey,anyValue)
    Ins = nsKey or Key
    Met = "I"
    if(not IsExistent(Data[Ins])) then
      Curs = Curs + 1
    end
    Data[Ins] = anyValue
    collectgarbage()
  end
  function self:Select(nsKey)
    Sel = nsKey or Key
    return Data[Sel]
  end
  function self:Delete(nsKey)
    Del = nsKey or Key
    Met = "D"
    if(IsExistent(Data[Del])) then
      Data[Del] = nil
      Curs = Curs - 1
      collectgarbage()
    end
  end
  function self:GetHistory()
    return tostring(Met).."@"..
           tostring(Sel).."/"..
           tostring(Ins).."/"..
           tostring(Del)
  end
  return self
end

function MakeScreen(sW,sH,eW,eH,conPalette,sEst)
  if(SERVER) then return nil end
  local sW = sW or 0
  local sH = sH or 0
  local eW = eW or 0
  local eH = eH or 0
  if(eW <= 0 or eH <= 0) then return nil end
  if(type(conPalette) ~= "table") then return nil end
  local Est = sEst or ""
  local White = Color(255,255,255,255)
  local ColorKey
  local Text = {}
        Text.Font = "Trebuchet18"
        Text.DrawX = 0
        Text.DrawY = 0
        Text.ScrW  = 0
        Text.ScrH  = 0
        Text.LastW = 0
        Text.LastH = 0
  local Palette
  if(conPalette and conPalette.Create == MakeContainer) then
    Palette = conPalette
  end
  local Texture = {}
        Texture.Path = "vgui/white"
        Texture.ID   = surface.GetTextureID(Texture.Path)
  local self = {}
        self.Create = MakeScreen
  function self:GetSize()
    return (eW-sW), (eH-sH)
  end
  function self:GetCenter(nX,nY)
    local w, h = self:GetSize()
    w = (w / 2) + (nX or 0)
    h = (h / 2) + (nY or 0)
    return w, h
  end
  function self:SetColor(sColor)
    if(not sColor) then return end
    if(Palette) then
      local Colour = Palette:Select(sColor)
      if(Colour) then
        surface.SetDrawColor(Colour.r, Colour.g, Colour.b, Colour.a)
        surface.SetTextColor(Colour.r, Colour.g, Colour.b, Colour.a)
        ColorKey = sColor
      end
    else
      surface.SetDrawColor(White.r,White.g,White.b,White.a)
      surface.SetTextColor(White.r,White.g,White.b,White.a)
    end
  end
  function self:SetTexture(sTexture)
    if(not IsString(sTexture)) then return end
    if(sTexture == "") then return end
    Texture.Path = sTexture
    Texture.ID   = surface.GetTextureID(Texture.Path)
  end
  function self:GetTexture()
    return Texture.ID, Texture.Path
  end
  function self:DrawBackGround(sColor)
    self:SetColor(sColor)
    surface.SetTexture(Texture.ID)
    surface.DrawTexturedRect(sW,sH,eW-sW,eH-sH)
  end
  function self:DrawRect(nX,nY,nW,nH,sColor)
    self:SetColor(sColor)
    surface.SetTexture(Texture.ID)
    surface.DrawTexturedRect(nX,nY,nW,nH)
  end
  function self:SetTextEdge(x,y)
    Text.DrawX = tonumber(x) or 0
    Text.DrawY = tonumber(y) or 0
    Text.ScrW  = 0
    Text.ScrH  = 0
    Text.LastW = 0
    Text.LastH = 0
  end
  function self:SetFont(sFont)
    if(not IsString(sFont)) then return end
    Text.Font = sFont or "Trebuchet18"
    surface.SetFont(Text.Font)
  end
  function self:GetTextState(nX,nY,nW,nH)
    return (Text.DrawX + (nX or 0)), (Text.DrawY + (nY or 0)),
           (Text.ScrW + (nW or 0)), (Text.ScrH + (nH or 0)),
            Text.LastW, Text.LastH
  end
  function self:DrawText(sText,sColor)
    surface.SetTextPos(Text.DrawX,Text.DrawY)
    self:SetColor(sColor)
    surface.DrawText(sText)
    Text.LastW, Text.LastH = surface.GetTextSize(sText)
    Text.DrawY = Text.DrawY + Text.LastH
    if(Text.LastW > Text.ScrW) then
      Text.ScrW = Text.LastW
    end
    Text.ScrH = Text.DrawY
  end
  function self:DrawCircle(xyPos,nRad,sColor)
    if(Palette) then
      if(sColor) then
        local Colour = Palette:Select(sColor)
        if(Colour) then
          surface.DrawCircle( xyPos.x, xyPos.y, nRad, Colour)
          ColorKey = sColor
          return
        end
      else
        if(IsExistent(ColorKey)) then
          local Colour = Palette:Select(ColorKey)
          surface.DrawCircle( xyPos.x, xyPos.y, nRad, Colour)
          return
        end
      end
      return
    else
      surface.DrawCircle( xyPos.x, xyPos.y, nRad, White)
    end
  end
  function self:Enclose(xyPnt)
    if(xyPnt.x < sW) then return -1 end
    if(xyPnt.x > eW) then return -1 end
    if(xyPnt.y < sH) then return -1 end
    if(xyPnt.y > eH) then return -1 end
    return 1
  end
  function self:AdaptLine(xyS,xyE,nI,nK,sMeth)
    local I = 0
    if(not (xyS and xyE)) then return I end
    if(not (xyS.x and xyS.y and xyE.x and xyE.y)) then return I end
    local nK = nK or 0.75
    local nI = nI or 50
          nI = math.floor(nI)
    if(sW >= eW) then return I end
    if(sH >= eH) then return I end
    if(nI < 1) then return I end
    if(not (nK > I and nK < 1)) then return I end
    local SigS = self:Enclose(xyS)
    local SigE = self:Enclose(xyE)
    if(SigS == 1 and SigE == 1) then
      return (I+1)
    elseif(SigS == -1 and SigE == -1) then
      return I
    elseif(SigS == -1 and SigE == 1) then
      xyS.x, xyE.x = xyE.x, xyS.x
      xyS.y, xyE.y = xyE.y, xyS.y
    end --- From here below are the methods
    if(sMeth == "B") then
      local DisX = xyE.x - xyS.x
      local DirX = DisX
            DisX = DisX * DisX
      local DisY = xyE.y - xyS.y
      local DirY = DisY
            DisY = DisY * DisY
      local Dis = math.sqrt(DisX + DisY)
      if(Dis == 0) then
        return I
      end
            DirX = DirX / Dis
            DirY = DirY / Dis
      local Pos = {x = xyS.x, y = xyS.y}
      local Mid = Dis / 2
      local Pre = 100 -- Obviously big enough
      while(I < nI) do
        Sig = self:Enclose(Pos)
        if(Sig == 1) then
          xyE.x = Pos.x
          xyE.y = Pos.y
        end
        Pos.x = Pos.x + DirX * Sig * Mid
        Pos.y = Pos.y + DirY * Sig * Mid
        if(Sig == -1) then
          --[[
            Estimate the distance and break
            earlier with 0.5 because of the
            math.floor call afterwards.
          ]]
          Pre = math.abs(math.abs(Pos.x) + math.abs(Pos.y) -
                         math.abs(xyE.x) - math.abs(xyE.y))
          if(Pre < 0.5) then break end
        end
        Mid = nK * Mid
        I = I + 1
      end
    elseif(sMeth == "I") then
      local V = {x = xyE.x-xyS.x, y = xyE.y-xyS.y}
      local N = math.sqrt(V.x*V.x + V.y*V.y)
      local Z = (N * (1-nK))
      if(Z == 0) then return I end
      local D = {x = V.x/Z , y = V.y/Z}
            V.x = xyS.x
            V.y = xyS.y
      local Sig = self:Enclose(V)
      while(Sig == 1) do
        xyE.x, xyE.y = V.x, V.y
        V.x = V.x + D.x
        V.y = V.y + D.y
        Sig = self:Enclose(V)
        I = I + 1
      end
    end
    xyS.x, xyS.y = math.floor(xyS.x), math.floor(xyS.y)
    xyE.x, xyE.y = math.floor(xyE.x), math.floor(xyE.y)
    return I
  end
  function self:DrawLine(xyS,xyE,sColor)
    if(not (xyS and xyE)) then return end
    if(not (xyS.x and xyS.y and xyE.x and xyE.y)) then return end
    self:SetColor(sColor)
    if(Est ~= "") then
      local Iter = self:AdaptLine(xyS,xyE,200,0.75,Est)
      if(Iter > 0) then
        surface.DrawLine(xyS.x,xyS.y,xyE.x,xyE.y)
      end
    else
      local nS = self:Enclose(xyS)
      local nE = self:Enclose(xyE)
      if(nS == -1 or nE == -1) then return end
      surface.DrawLine(xyS.x,xyS.y,xyE.x,xyE.y)
    end
  end
  return self
end

function SetAction(sKey,fAct,tDat)
  if(not (sKey and IsString(sKey))) then return false end
  if(not (fAct and type(fAct) == "function")) then return false end
  if(not LibAction[sKey]) then
    LibAction[sKey] = {}
  end
  LibAction[sKey].Act = fAct
  LibAction[sKey].Dat = tDat
  return true
end

function GetActionCode(sKey)
  if(not (sKey and IsString(sKey))) then return nil end
  if(not (LibAction and LibAction[sKey])) then return nil end
  return LibAction[sKey].Act
end

function GetActionData(sKey)
  if(not (sKey and IsString(sKey))) then return nil end
  if(not (LibAction and LibAction[sKey])) then return nil end
  return LibAction[sKey].Dat
end

function CallAction(sKey,A1,A2,A3,A4)
  if(not (sKey and IsString(sKey))) then return false end
  if(not (LibAction and LibAction[sKey])) then return false end
  return LibAction[sKey].Act(A1,A2,A3,A4,LibAction[sKey].Dat)
end

function IsOther(oEnt)
  if(not oEnt)           then return true end
  if(not oEnt:IsValid()) then return true end
  if(oEnt:IsPlayer())    then return true end
  if(oEnt:IsVehicle())   then return true end
  if(oEnt:IsNPC())       then return true end
  if(oEnt:IsRagdoll())   then return true end
  if(oEnt:IsWeapon())    then return true end
  if(oEnt:IsWidget())    then return true end
  return false
end

local function PushSortValues(tTable,snCnt,nsValue,tData)
  local Cnt = math.floor(tonumber(snCnt) or 0)
  if(not (tTable and (type(tTable) == "table") and (Cnt > 0))) then return 0 end
  local Ind  = 1
  if(not tTable[Ind]) then
    tTable[Ind] = {Value = nsValue, Table = tData }
    return Ind
  else
    while(tTable[Ind] and (tTable[Ind].Value > nsValue)) do
      Ind = Ind + 1
    end
    if(Ind > Cnt) then return Ind end
    while(Ind < Cnt) do
      tTable[Cnt] = tTable[Cnt - 1]
      Cnt = Cnt - 1
    end
    tTable[Ind] = {Value = nsValue, Table = tData}
    return Ind
  end
end

function GetFrequentModels(snCount)
  local Cnt = tonumber(snCount) or 0
  if(Cnt < 1) then return nil end
  local TableKey = GetOpVar("QTABLE_PIECES")
  local defTable = LibTables[TableKey]
  local Cache    = LibCache[TableKey]
  local FreqNam  = "FREQUENT_MODELS"
  local FreqUse  = GetOpVar(FreqNam)
  local TimerID  = ""
  local Tim      = 0
  local Ind      = 1
  if(not IsExistent(FreqUse)) then
    SetOpVar(FreqNam,{})
    FreqUse = GetOpVar(FreqNam)
  end
  table.Empty(FreqUse)
  for Model, Record in pairs(Cache) do
    TimerID  = TableKey.."_"..Model
    if(timer.Exists(TimerID)) then
      Tim = timer.TimeLeft(TimerID)
      Ind = PushSortValues(FreqUse,Cnt,Tim,{Record.Mesh,Record.Type,Model})
      if(Ind < 1) then return nil end
    end
  end
  if(FreqUse and FreqUse[1]) then return FreqUse end
  return nil
end

function RoundValue(exact, frac)
    local q,f = math.modf(exact/frac)
    return frac * (q + (f > 0.5 and 1 or 0))
end

function GetViewRadius(plPly,vPos)
  if(not (vPos and plPly)) then return 0 end
  return math.Clamp(500 / (vPos - plPly:GetPos()):Length(),1,100)
end

function GetCorrectID(anyValue,oContainer)
  local Value = tonumber(anyValue)
  if(not Value) then return 1 end
  if(not oContainer) then return 1 end
  local Max = oContainer:GetSize()
  if(Value > Max) then Value = 1 end
  if(Value < 1) then Value = Max end
  return Value
end

function SnapValue(nVal, nSnap)
  if(not nVal) then return 0 end
  if(not nSnap) then return nVal end
  if(nSnap == 0) then return nVal end
  local Rez
  local Snp = math.abs(nSnap)
  local Val = math.abs(nVal)
  local Rst = Val % Snp
  if((Snp-Rst) < Rst) then
    Rez = Val+Snp-Rst
  else
    Rez = Val-Rst
  end
  if(nVal < 0) then
    return -Rez;
  end
  return Rez;
end

function IsPhysTrace(Trace)
  if(not Trace) then return false end
  local eEnt = Trace.Entity
  if(     eEnt   and
      not Trace.HitWorld and
          eEnt:IsValid() and
          eEnt:GetPhysicsObject():IsValid()) then
    return true
  end
  return false
end

function ModelToName(sModel)
  if(not IsString(sModel)) then return "" end
  local Len = string.len(sModel)
  if(string.sub(sModel,Len-2,Len) ~= "mdl") then return "" end
  Len = Len - 4
  if(Len <= 0) then return "" end
  local Cnt = Len
  local Fch = ""
  while(Cnt > 0) do
    Fch = string.sub(sModel,Cnt,Cnt)
    if(Fch == '/') then
      break
    end
    Cnt = Cnt - 1
  end
  local Div = GetOpVar("OPSYM_DIVIDER")
  local Sub = Div..string.sub(sModel,Cnt+1,Len)
  local Rez = ""
  local Bch = ""
  Len = string.len(Sub)
  Cnt = 1
  while(Cnt <= Len) do
    Bch = string.sub(Sub,Cnt,Cnt)
    Cha = string.sub(Sub,Cnt+1,Cnt+1)
    if(Bch == Div) then
       Bch = " "
       Cha = string.upper(Cha)
       Rez = Rez..Bch..Cha
       Cnt = Cnt + 1
    else
      Rez = Rez..Bch
    end
    Cnt = Cnt + 1
  end
  return string.sub(Rez,2,Len)
end

function DecodeOffset(arData,sStr)
  if(not sStr) then return false end
  local DatInd = 1
  local ComCnt = 0
  local Len = string.len(sStr)
  local SymOff = GetOpVar("OPSYM_DISABLE")
  local SymRev = GetOpVar("OPSYM_REVSIGN")
  local Ch = ""
  local S = 1
  local E = 1
  local Cnt = 1
  arData[1] = 0
  arData[2] = 0
  arData[3] = 0
  arData[4] = 1
  arData[5] = 1
  arData[6] = 1
  arData[7] = false
  if(string.sub(sStr,Cnt,Cnt) == SymOff) then
    arData[7] = true
    Cnt = Cnt + 1
    S   = S   + 1
  end
  while(Cnt <= Len) do
    Ch = string.sub(sStr,Cnt,Cnt)
    if(Ch == SymRev) then
      arData[3+DatInd] = -arData[3+DatInd]
      S   = S + 1
    elseif(Ch == ",") then
      ComCnt = ComCnt + 1
      E = Cnt - 1
      if(ComCnt > 2) then break end
      arData[DatInd] = tonumber(string.sub(sStr,S,E)) or 0
      DatInd = DatInd + 1
      S = Cnt + 1
      E = S
    else
      E = E + 1
    end
    Cnt = Cnt + 1
  end
  arData[DatInd] = tonumber(string.sub(sStr,S,E)) or 0
end

function FormatNumberMax(nNum,nMax)
  return string.format("%"..string.len(tostring(math.floor(nMax))).."d",nNum)
end

function Indent(nCnt,sStr,bFixed)
  if(not (nCnt and sStr)) then return "" end
  local Out = ""
  local Cnt = nCnt
  local Len = string.len(sStr)
  if(bFixed) then return " "..sStr end
  if(Cnt == 0) then return sStr end
  if(Cnt  > 0) then
    while(Cnt > 0) do
      Out = Out.."  "
      Cnt = Cnt - 1
    end
    return Out..sStr
  else
    return string.sub(sStr,1-2*Cnt,Len)
  end
end

local function Qsort(Data,Lo,Hi)
  if(Lo < Hi) then
  local Mid = math.random(Hi-(Lo-1))+Lo-1
  Data[Lo], Data[Mid] = Data[Mid], Data[Lo]
  local Vmid = Data[Lo].Val
        Mid  = Lo
  local Cnt  = Lo + 1
  while(Cnt <= Hi)do
    if(Data[Cnt].Val < Vmid) then
      Mid = Mid + 1
      Data[Mid], Data[Cnt] = Data[Cnt], Data[Mid]
    end
    Cnt = Cnt + 1
  end
  Data[Lo], Data[Mid] = Data[Mid], Data[Lo]
  Qsort(Data,Lo,Mid-1)
  Qsort(Data,Mid+1,Hi)
 end
end

function Sort(tTable,tIndexes)
  local CopyTable = {}
  local Cnt = 1
  local Cct = 1

  for k,v in pairs(tTable) do
    CopyTable[Cct] = {
      Val = "",
      Key = Cct
    }
    Cnt = 1
    while(tIndexes[Cnt]) do
      i = tIndexes[Cnt]
      if(not v[i]) then
        LogInstance("Sort: Failed to process Table["..Cct.."]["..i.."]")
        return nil
      end
      CopyTable[Cct].Val = CopyTable[Cct].Val..tostring(v[i])
      Cnt = Cnt + 1
    end
    Cct = Cct + 1
  end
  Cct = Cct - 1
  Qsort(CopyTable,1,Cct)
  return CopyTable
end

------------------ AssemblyLib LOGS ------------------------

function SetLogControl(nLines,sFile)
  SetOpVar("LOG_LOGFILE",sFile or "")
  SetOpVar("LOG_MAXLOGS",nLines or 0)
  SetOpVar("LOG_CURLOGS",0)
  if(not file.Exists(GetOpVar("DIRPATH_BAS"),"DATA") and
    (string.len(GetOpVar("LOG_LOGFILE")) > 0)
  ) then
    file.CreateDir(GetOpVar("DIRPATH_BAS"))
  end
end

function Log(anyStuff)
  local MaxLogs = GetOpVar("LOG_MAXLOGS")
  if(MaxLogs > 0) then
    local LogFile = GetOpVar("LOG_LOGFILE")
    local CurLogs = GetOpVar("LOG_CURLOGS")
    if(LogFile ~= "") then
      local fName = GetOpVar("DIRPATH_BAS")..GetOpVar("DIRPATH_LOG")..LogFile..".txt"
      file.Append(fName,FormatNumberMax(CurLogs,MaxLogs)
                .." >> "..tostring(anyStuff).."\n")
      CurLogs = CurLogs + 1
      if(CurLogs > MaxLogs) then
        file.Delete(fName)
      end
      SetOpVar("LOG_CURLOGS",CurLogs)
    else
      print(GetToolNameU().." LOG: "..tostring(anyStuff))
    end
  end
end

function LogInstance(anyStuff)
  if(SERVER) then
    Log("SERVER > "..tostring(anyStuff))
  elseif(CLIENT) then
    Log("CLIENT > "..tostring(anyStuff))
  else
    Log("NOINST > "..tostring(anyStuff))
  end
end

function StatusLog(anyStatus,sError)
  LogInstance(sError)
  return anyStatus
end

function Print(tT,sS)
  if(not IsExistent(tT)) then
    return StatusLog(nil,"Print: No Data: Print( table, string = \"Data\" )!")
  end
  local S = type(sS)
  local T = type(tT)
  local Key  = ""
  if(S == "string") then
    S = sS
  elseif(S == "number") then
    S = tostring(sS)
  else
    S = "Data"
  end
  if(T ~= "table") then
    LogInstance("{"..T.."}["..tostring(sS or "N/A").."] = "..tostring(tT))
    return
  end
  T = tT
  if(next(T) == nil) then
    LogInstance(S.." = {}")
    return
  end
  LogInstance(S)
  for k,v in pairs(T) do
    if(type(k) == "string") then
      Key = S.."[\""..k.."\"]"
    else
      Key = S.."["..tostring(k).."]"
    end
    if(type(v) ~= "table") then
      if(type(v) == "string") then
        LogInstance(Key.." = \""..v.."\"")
      else
        LogInstance(Key.." = "..tostring(v))
      end
    else
      Print(v,Key)
    end
  end
end

function PrintArrLine(aTable,sName)
  local Line = (sName or "Data").."{"
  local Cnt  = 1
  while(aTable[Cnt]) do
    Line = Line..tostring(aTable[Cnt])
    if(aTable[Cnt + 1]) then
      Line = Line..", "
    end
    Cnt = Cnt + 1
  end
  LogInstance(Line.."}")
end

--------------------- STRINGS -----------------------

function StringReviseSQL(sStr)
  if(not IsString(sStr)) then
    return StatusLog(nil,"StringReviseSQL: Only strings can be revised")
  end
  local Cnt = 1
  local Out = ""
  local Chr = string.sub(sStr,Cnt,Cnt)
  while(Chr ~= "") do
    Out = Out..Chr
    if(Chr == "'") then
      Out = Out..Chr
    end
    Cnt = Cnt + 1
    Chr = string.sub(sStr,Cnt,Cnt)
  end
  return Out
end

function StringExplode(sStr,sDelim)
  if(not (IsString(sStr) and IsString(sDelim))) then
    return StatusLog(nil,"StringExplode: All parameters should be strings")
  end
  if(string.len(sDelim) <= 0) then
    return StatusLog(nil,"StringExplode: Delimiter has to be a symbol")
  end
  local Len = string.len(sStr)
  local S = 1
  local E = 1
  local V = ""
  local Ind = 1
  local Data = {}
  if(string.sub(sStr,Len,Len) ~= sDelim) then
    sStr = sStr..sDelim
    Len = Len + 1
  end
  while(E <= Len) do
    Ch = string.sub(sStr,E,E)
    if(Ch == sDelim) then
      V = string.sub(sStr,S,E-1)
      S = E + 1
      Data[Ind] = V or ""
      Ind = Ind + 1
    end
    E = E + 1
  end
  return Data
end

function StringImplode(tParts,sDelim)
  if(not (tParts and tParts[1])) then return "" end
  if(not IsString(sDelim)) then
    return StatusLog(nil,"StringImplode: The delimiter should be string")
  end
  local Cnt = 1
  local Implode = ""
  local Delim = string.sub(tostring(sDelim),1,1)
  while(tParts[Cnt]) do
    Implode = Implode..tostring(tParts[Cnt])
    if(tParts[Cnt+1]) then
      Implode = Implode..Delim
    end
    Cnt = Cnt + 1
  end
  return Implode
end

------------- SQL Handling --------------

function GetDisableString(sBase, anyDisable, anyDefault)
  if(IsString(sBase)) then
    if(string.len(sBase) > 0 and
       string.sub(sBase,1,1) ~= GetOpVar("OPSYM_DISABLE")
    ) then
      return StringReviseSQL(sBase)
    elseif(string.sub(sBase,1,1) == GetOpVar("OPSYM_DISABLE")) then
      return anyDisable
    end
  end
  return anyDefault
end

function SQLSetType(sType)
  if(not IsString(sType)) then return end
  SetOpVar("DEFAULT_TYPE",StringReviseSQL(sType))
end

function SQLSetTable(sTable)
  if(not IsString(sTable)) then return end
  SetOpVar("DEFAULT_TABLE",sTable)
end

function SQLGetBuildErr()
  return GetOpVar("SQL_BUILD_ERR") or ""
end

function SQLSetBuildErr(sError)
  if(not IsString(sError)) then return false end
  SetOpVar("SQL_BUILD_ERR", sError)
  return false
end

--------------------- USAGES --------------------

function Str2BGID(sStr,nLen)
  if(not sStr) then return nil end -- You never know ...
  local Len  = string.len(sStr)
  if(Len <= 0) then return nil end
  local Data = StringExplode(sStr,",")
  local Cnt = 1
  local exLen = nLen or Data.Len
  while(Cnt <= exLen) do
    local v = Data[Cnt]
    if(v == "") then return nil end
    local vV = tonumber(v)
    if(not vV) then return nil end
    if((math.floor(vV) - vV) ~= 0) then return nil end
    Data[Cnt] = vV
    Cnt = Cnt + 1
  end
  if(Data[1])then return Data end
  return nil
end

function ModelToHashLocation(sModel,tTable,anyValue)
  if(not (IsString(sModel) and type(tTable) == "table")) then return end
  local Key = StringExplode(sModel,"/")
  Print(Key,"Key")
  if(not (Key and Key[1])) then return end
  local Ind = 1
  local Len = 0
  local Val = ""
  local Place = tTable
  while(Key[Ind]) do
    Val = Key[Ind]
    Len = string.len(Val)
    if(string.sub(Val,Len-3,Len) == ".mdl") then
      Place[Val] = anyValue
    else
      if(not Place[Val]) then
        Place[Val] = {}
      end
      Place = Place[Val]
    end
    Ind = Ind + 1
  end
end

------------------------- PLAYER -----------------------------------

function PrintNotify(pPly,sText,sNotifType)
  if(not pPly) then return end
  if(SERVER) then
    pPly:SendLua("GAMEMODE:AddNotify(\""..sText.."\", NOTIFY_"..sNotifType..", 6)")
    pPly:SendLua("surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
  end
end

function EmitSoundPly(pPly)
  if(not pPly) then return end
  pPly:EmitSound("physics/metal/metal_canister_impact_hard"..math.floor(math.random(3))..".wav")
end

function PlyLoadKey(pPly, sKey)
  if(not LibCache["PLAYERKEYDOWN"]) then
    LibCache["PLAYERKEYDOWN"] = {
      ["ALTLFT"]  = false,
      ["ALTRGH"]  = false,
      ["ATTLFT"]  = false,
      ["ATTRGH"]  = false,
      ["FORWARD"] = false,
      ["BACK"]    = false,
      ["MOVELFT"] = false,
      ["MOVERGH"] = false,
      ["RELOAD"]  = false,
      ["USE"]     = false,
      ["DUCK"]    = false,
      ["JUMP"]    = false,
      ["SPEED"]   = false,
      ["SCORE"]   = false,
      ["ZOOM"]    = false,
      ["LEFT"]    = false,
      ["RIGHT"]   = false,
      ["WALK"]    = false
    }
  end
  local Cache = LibCache["PLAYERKEYDOWN"]
  if(not pPly) then
    for k,_ in pairs(Cache) do
      Cache[k] = false
    end
    return nil
  end
  if(sKey) then
    if(sKey == "DEBUG") then
      return Cache
    end
    return Cache[sKey]
  end
  Cache["ALTLFT"]  = pPly:KeyDown(IN_ALT1      )
  Cache["ALTRGH"]  = pPly:KeyDown(IN_ALT2      )
  Cache["ATTLFT"]  = pPly:KeyDown(IN_ATTACK    )
  Cache["ATTRGH"]  = pPly:KeyDown(IN_ATTACK2   )
  Cache["FORWARD"] = pPly:KeyDown(IN_FORWARD   )
  Cache["BACK"]    = pPly:KeyDown(IN_BACK      )
  Cache["MOVELFT"] = pPly:KeyDown(IN_MOVELEFT  )
  Cache["MOVERGH"] = pPly:KeyDown(IN_MOVERIGHT )
  Cache["RELOAD"]  = pPly:KeyDown(IN_RELOAD    )
  Cache["USE"]     = pPly:KeyDown(IN_USE       )
  Cache["DUCK"]    = pPly:KeyDown(IN_DUCK      )
  Cache["JUMP"]    = pPly:KeyDown(IN_JUMP      )
  Cache["SPEED"]   = pPly:KeyDown(IN_SPEED     )
  Cache["SCORE"]   = pPly:KeyDown(IN_SCORE     )
  Cache["ZOOM"]    = pPly:KeyDown(IN_ZOOM      )
  Cache["LEFT"]    = pPly:KeyDown(IN_LEFT      )
  Cache["RIGHT"]   = pPly:KeyDown(IN_RIGHT     )
  Cache["WALK"]    = pPly:KeyDown(IN_WALK      )
  return nil
end

-------------------------- AssemblyLib BUILDSQL ------------------------------

function SQLBuildCreate(sTable,tIndex)
  if(not IsExistent(sTable)) then
    return SQLSetBuildErr("SQLBuildCreate: Missing: Table name")
  end
  if(not LibTables[sTable]) then
    return SQLSetBuildErr("SQLBuildCreate: Missing: Table definition for "..sTable)
  end
  local defTable = LibTables[sTable]
  if(not defTable.Size) then
    return SQLSetBuildErr("SQLBuildCreate: Missing: Table definition SIZE for "..sTable)
  end
  if(not defTable[1]) then
    return SQLSetBuildErr("SQLBuildCreate: Missing: Table definition is empty for "..sTable)
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    return SQLSetBuildErr("SQLBuildCreate: Missing: Table "..sTable.." field definitions")
  end
  local Ind = 1
  local Command  = {}
  Command.Drop   = "DROP TABLE "..sTable..";"
  Command.Delete = "DELETE FROM "..sTable..";"
  Command.Create = "CREATE TABLE "..sTable.." ( "
  while(defTable[Ind]) do
    local v = defTable[Ind]
    if(not v[1]) then
      return SQLSetBuildErr("SQLBuildCreate: Missing Table "..sTable
                          .."'s field #"..tostring(Ind))
    end
    if(not v[2]) then
      return SQLSetBuildErr("SQLBuildCreate: Missing Table "..sTable
                                  .."'s field type #"..tostring(Ind))
    end
    Command.Create = Command.Create..string.upper(v[1]).." "..string.upper(v[2])
    if(defTable[Ind+1]) then
      Command.Create = Command.Create ..", "
    end
    Ind = Ind + 1
  end
  Command.Create = Command.Create.." );"
  if(tIndex and
     tIndex[1] and
     type(tIndex[1]) == "table" and
     tIndex[1][1] and
     type(tIndex[1][1]) == "number"
   ) then
    Command.Index = {}
    Ind = 1
    Cnt = 1
    while(tIndex[Ind]) do
      local vI = tIndex[Ind]
      if(type(vI) ~= "table") then
        return SQLSetBuildErr("SQLBuildCreate: Index creator mismatch on "
          ..sTable.." value "..vI.." is not a table for index ["..tostring(Ind).."]")
      end
      local FieldsU = ""
      local FieldsC = ""
      Command.Index[Ind] = "CREATE INDEX IND_"..sTable
      Cnt = 1
      while(vI[Cnt]) do
        local vF = vI[Cnt]
        if(type(vF) ~= "number") then
          return SQLSetBuildErr("SQLBuildCreate: Index creator mismatch on "
            ..sTable.." value "..vF.." is not a number for index ["
            ..tostring(Ind).."]["..tostring(Cnt).."]")
        end
        if(not defTable[vF]) then
          return SQLSetBuildErr("SQLBuildCreate: Index creator mismatch on "
            ..sTable..". The table does not have field index #"
            ..vF..", max is #"..Table.Size)
        end
        FieldsU = FieldsU.."_" ..string.upper(defTable[vF][1])
        FieldsC = FieldsC..string.upper(defTable[vF][1])
        if(vI[Cnt+1]) then
          FieldsC = FieldsC ..", "
        end
        Cnt = Cnt + 1
      end
      Command.Index[Ind] = Command.Index[Ind]..FieldsU.." ON "..sTable.." ( "..FieldsC.." );"
      Ind = Ind + 1
    end
  end
  SetOpVar("SQL_BUILD_ERR", "")
  return Command
end

function SQLHashQuery(sTable,tFields,tWhere,tOrderBy,sQuery)
  local Val
  local Base
  local nField = 1
  local nWhere = 1
  local nOrder = 1
  local Place  = LibGetSQL[sTable]
  if(not Place) then
    LibGetSQL[sTable] = {}
    Place = LibGetSQL[sTable]
  end
  local defTable = LibTables[sTable]
  if(not IsExistent(defTable)) then
    return StatusLog(nil,"SQLHashQuery: Missing: Table definition for "..tostring(sTable))
  end
  if(tFields) then
    while(tFields[nField]) do
      local Val = defTable[tFields[nField]][1]
      if(not IsExistent(Val)) then
        return StatusLog(nil,"SQLHashQuery: Missing: Field key for #"..tostring(nField))
      end
      if(Place[Val]) then
        Place = Place[Val]
      elseif(sQuery) then
        Base = Place
        Place[Val] = {}
        Place = Place[Val]
      else
        return nil
      end
      if(not Place) then return nil end
      nField = nField + 1
    end
  else
    Val = "ALL_FIELDS"
    if(Place[Val]) then
      Place = Place[Val]
    elseif(sQuery) then
      Base = Place
      Place[Val] = {}
      Place = Place[Val]
    else
      return nil
    end
  end
  if(tOrderBy) then
    while(tOrderBy[nOrder]) do
      Val = tOrderBy[nOrder]
      if(Place[Val]) then
        Base = Place
        Place = Place[Val]
      elseif(sQuery) then
        Base = Place
        Place[Val] = {}
        Place = Place[Val]
      else
        return nil
      end
      nOrder = nOrder + 1
    end
  end
  if(tWhere) then
    while(tWhere[nWhere]) do
      Val = defTable[tWhere[nWhere][1]][1]
      if(not IsExistent(Val)) then
        return StatusLog(nil,"SQLHashQuery: Missing: Where field key for #"..tostring(nWhere))
      end
      if(Place[Val]) then
        Base = Place
        Place = Place[Val]
      elseif(sQuery) then
        Base = Place
        Place[Val] = {}
        Place = Place[Val]
      else
        return nil
      end
      Val = tWhere[nWhere][2]
      if(not IsExistent(Val)) then
        return StatusLog(nil,"SQLHashQuery: Missing: Where value key for #"..tostring(nWhere))
      end
      if(Place[Val]) then
        Base = Place
        Place = Place[Val]
      elseif(sQuery) then
        Base = Place
        Place[Val] = {}
        Place = Place[Val]
      end
      nWhere = nWhere + 1
    end
  end
  if(sQuery) then
    Base[Val] = sQuery
  end
  return Base[Val]
end


function SQLBuildSelect(sTable,tFields,tWhere,tOrderBy)
  if(not IsExistent(sTable)) then
    return SQLSetBuildErr("SQLBuildCreate: Missing: Table name")
  end
  if(not LibTables[sTable]) then
    return SQLSetBuildErr("SQLBuildSelect: Missing: Table definition "..sTable)
  end
  local defTable = LibTables[sTable]
  if(not defTable.Size) then
    return SQLSetBuildErr("SQLBuildSelect: Missing: Table definition SIZE in "..sTable)
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    return SQLSetBuildErr("SQLBuildSelect: Missing: Table "..sTable.." field definitions")
  end
  local Hash = GetOpVar("QHASH_ENABLE") or false
  if(Hash) then
    local Q = SQLHashQuery(sTable,tFields,tWhere,tOrderBy)
    if(Q) then
      return Q
    end
  end
  local Cnt = 1
  local Command = "SELECT "
  if(tFields) then
    while(tFields[Cnt]) do
      local v = tonumber(tFields[Cnt])
      if(not v) then
        return SQLSetBuildErr("SQLBuildSelect: Index #"
          ..tostring(tFields[Cnt])
          .." type mismatch in "..sTable)
      end
      if(defTable[v]) then
        if(defTable[v][1]) then
          Command = Command..defTable[v][1]
        else
          return SQLSetBuildErr("SQLBuildSelect: No such field name by index #"
            ..v.." in the table "..sTable)
        end
      end
      if(tFields[Cnt+1]) then
        Command = Command ..", "
      end
      Cnt = Cnt + 1
    end
  else
    Command = Command.."*"
  end
  Command = Command .." FROM "..sTable
  if(tWhere and
     type(tWhere == "table") and
     type(tWhere[1]) == "table" and
     tWhere[1][1] and
     tWhere[1][2] and
     type(tWhere[1][1]) == "number" and
     (type(tWhere[1][2]) == "string" or type(tWhere[1][2]) == "number")
  ) then
    Cnt = 1
    local k = tonumber(tWhere[Cnt][1])
    local v = tWhere[Cnt][2]
    local t = defTable[k][2]
    if(k and v and t) then
      if(t == "TEXT" and type(v) == "number") then
        v = tostring(v)
      elseif(t == "INTEGER" and type(v) == "string") then
        local toNB = tonumber(v)
        if(not toNB) then
          return SQLSetBuildErr("SQLBuildSelect: Cannot convert string \""..v
             .."\" to a number for field index #"..Cnt.." in table "..sTable)
        end
        v = toNB
      end
      if(t == "TEXT") then
        v = "'"..v.."'"
      end
      Command = Command.." WHERE "..defTable[k][1].." = "..v
      Cnt = Cnt + 1
      while(tWhere[Cnt]) do
        local k = tonumber(tWhere[Cnt][1])
        local v = tWhere[Cnt][2]
        local t = defTable[k][2]
        if(not (k and v and t) ) then
          return SQLSetBuildErr("SQLBuildSelect: Missing eather "
            ..sTable.." field index, ".."value or type in the table definition")
        end
        if(t == "TEXT" and type(v) == "number") then
          v = tostring(v)
        elseif(t == "INTEGER" and type(v) == "string") then
          local toNB = tonumber(v)
          if(not toNB) then
            return SQLSetBuildErr("SQLBuildSelect: Cannot convert string \""
              ..v.."\" to a number for field index #"..Cnt
              .." in table "..sTable)
          end
          v = toNB
        end
        if(t == "TEXT") then
          v = "'"..v.."'"
        end
        Command = Command .." AND "..defTable[k][1].." = "..v
        Cnt = Cnt + 1
      end
    else
      if(Hash) then
        return SQLHashQuery(sTable,tFields,tWhere,tOrderBy,Command..";")
      else
        return Command..";"
      end
    end
  end
  if(tOrderBy and (type(tOrderBy) == "table")) then
    local Dire = ""
    Command = Command.." ORDER BY "
    Cnt = 1
    while(tOrderBy[Cnt]) do
      local v = tOrderBy[Cnt]
      if(v ~= 0) then
        if(v > 0) then
          Dire = " ASC"
        else
          Dire = " DESC"
          v = -v
        end
      else
        return SQLSetBuildErr("SQLBuildSelect: Wrong Table "..sTable
                              .." field index #"..Cnt)
      end
        Command = Command..defTable[v][1]..Dire
        if(tOrderBy[Cnt+1]) then
          Command = Command..", "
        end
      Cnt = Cnt + 1
    end
  end
  SetOpVar("SQL_BUILD_ERR", "")
  if(Hash) then
    return SQLHashQuery(sTable,tFields,tWhere,tOrderBy,Command..";")
  else
    return Command..";"
  end
end

function SQLBuildInsert(sTable,tInsert,tValues)
  if(not IsExistent(sTable)) then
    return SQLSetBuildErr("SQLBuildCreate: Missing: Table name")
  end
  if(not (LibTables[sTable] and tInsert and tValues)) then
    return SQLSetBuildErr("SQLBuildInsert: Missing Table definition and Chosen fields")
  end
  local defTable = LibTables[sTable]
  if(not (defTable[1] and tInsert[1])) then
    return SQLSetBuildErr("SQLBuildInsert: The table and the chosen fields must not be empty")
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    return SQLSetBuildErr("SQLBuildInsert: Missing: Table "..sTable.." field definition")
  end
  local qIns = "INSERT INTO "..sTable.." ( "
  local qVal = " VALUES ( "
  local Cnt = 1
  local Val = ""
  while(tInsert[Cnt]) do
    local k = tInsert[Cnt]
    local v = defTable[k]
          Val = tValues[Cnt]
    local tyVal = type(Val)
    if(Val and
       tostring(Val) ~= "" and
      ((tyVal == "number") or (tyVal == "string"))
    ) then
      if(v[2] == "TEXT") then
        Val = "'"..tostring(Val).."'"
      end
    elseif((not Val) or (tostring(Val) == "")) then
      Val = "NULL"
    else
      return SQLSetBuildErr("SQLBuildInsert: Cannot insert tables into the DB for index #"..Cnt)
    end
    qIns = qIns..defTable[k][1]
    qVal = qVal..Val
    if(tInsert[Cnt+1]) then
      qIns = qIns ..", "
      qVal = qVal ..", "
    else
      qIns = qIns .." ) "
      qVal = qVal .." );"
    end
    Cnt = Cnt + 1
  end
  SetOpVar("SQL_BUILD_ERR", "")
  return qIns..qVal
end

function SQLInsertRecord(sTable,tData)
  if(not IsExistent(sTable)) then
    return StatusLog(false,"SQLBuildCreate: Missing: Table name/values")
  end
  if(type(sTable) == "table") then
    tData  = sTable
    sTable = GetOpVar("DEFAULT_TABLE")
    if(not (IsExistent(sTable) and sTable ~= "")) then
      return StatusLog(false,"SQLInsertRecord: Missing: Table default name for "..sTable)
    end
  end
  if(not IsString(sTable)) then
    return StatusLog(false,"SQLInsertRecord: Indexing cache failed by "..tostring(sTable).." ("..type(sTable)..")")
  end
  local TableKey = GetOpVar("QTABLE_"..sTable)
  local defTable = LibTables[TableKey]
  if(not (defTable and TableKey)) then
    return StatusLog(false,"SQLInsertRecord: Missing: Table definition for "..sTable)
  end
  if(not defTable.Size) then
    return StatusLog(false,"SQLInsertRecord: Missing: Table definition SIZE for "..sTable)
  end
  if(not defTable[1])  then
    return StatusLog(false,"SQLInsertRecord: Missing: Table definition is empty for "..sTable)
  end
  if(not tData)      then
    return StatusLog(false,"SQLInsertRecord: Missing: Data table for "..sTable)
  end
  if(not tData[1])   then
    return StatusLog(false,"SQLInsertRecord: Missing: Data table is empty for "..sTable)
  end

  if(sTable == "PIECES") then
    tData[2] = GetDisableString(tData[2],GetOpVar("DEFAULT_TYPE"),"TYPE")
    tData[3] = GetDisableString(tData[3],ModelToName(tData[1]),"MODEL")
  end

  -- Malloc Some Index Arrays
  local Fields = {}
  local Ind = 1
  while(defTable[Ind]) do
    local FieldDef = defTable[Ind]
    local FieldTyp = type(tData[Ind])

    -- Different Type handling
    if(( FieldTyp == "string" and FieldDef[2] == "TEXT" ) or
       ( FieldTyp == "number" and FieldDef[2] == "INTEGER" ) or
       ( FieldTyp == "number" and FieldDef[2] == "REAL" )
    ) then
      if(FieldTyp    == "number" and
        (FieldDef[2] == "INTEGER" or FieldDef[2] == "REAL")
      ) then
        if(FieldDef[2] == "INTEGER") then
          tData[Ind] = math.floor(tData[Ind])
        end
      end
    elseif(FieldTyp    == "string" and
          (FieldDef[2] == "INTEGER" or FieldDef[2] == "REAL")
    ) then
      local toNB = tonumber(tData[Ind])
      if(toNB) then
        if(FieldDef[2] == "INTEGER") then
          tData[Ind] = math.floor(toNB)
        end
      else
        LogInstance("SQLInsertRecord: Cannot convert string to a number for "
                                   ..tData[Ind].." at field "..FieldDef[1].." ("..Ind..")")
        return false
      end
    elseif(FieldTyp == "number" and FieldDef[2] == "TEXT") then
      tData[Ind] = tostring(tData[Ind])
    else
      LogInstance("SQLInsertRecord: Data type mismatch: "
              ..FieldTyp.." <> "..FieldDef[2].." value ["..tostring(tData[Ind]).."]"
              .." at field "..FieldDef[1].." ("..Ind..") on table "..sTable)
      return false
    end

    -- Low Caps the Model for use in Ent:GetModel()
    if(    FieldDef[3] == "L" and FieldDef[2] == "TEXT") then
      tData[Ind] = string.lower(tData[Ind])
    elseif(FieldDef[3] == "U" and FieldDef[2] == "TEXT") then
      tData[Ind] = string.upper(tData[Ind])
    end
    Fields[Ind] = Ind
    Ind = Ind + 1
  end
  local Q = SQLBuildInsert(TableKey,Fields,tData)
  if(Q) then
    local qRez = sql.Query(Q)
    if(not qRez and type(qRez) == "boolean") then
       return StatusLog(false,"SQLInsertRecord: Failed to insert a record because of "
              ..tostring(sql.LastError()).." Query ran > "..Q)
    end
    return true
  end
  return StatusLog(false,"SQLInsertRecord: "..SQLGetBuildErr())
end

function SQLCreateTable(sTable,tIndex,bDelete,bReload)
  if(not IsString(sTable)) then return false end
  local TableKey = GetToolPrefU()..sTable
  local tQ = SQLBuildCreate(TableKey,tIndex)
  if(tQ) then
    if(bDelete and sql.TableExists(TableKey)) then
      local qRez = sql.Query(tQ.Delete)
      if(not qRez and type(qRez) == "boolean") then
        LogInstance("SQLCreateTable: Table "..sTable
          .." is not present. Skipping delete !")
      else
        LogInstance("SQLCreateTable: Table "..sTable.." deleted !")
      end
    end
    if(bReload) then
      local qRez = sql.Query(tQ.Drop)
      if(not qRez and type(qRez) == "boolean") then
        LogInstance("SQLCreateTable: Table "..sTable
          .." is not present. Skipping drop !")
      else
        LogInstance("SQLCreateTable: Table "..sTable.." dropped !")
      end
    end
    if(sql.TableExists(TableKey)) then
      LogInstance("SQLCreateTable: Table "..sTable.." exists!")
      return true
    else
      local qRez = sql.Query(tQ.Create)
      if(not qRez and type(qRez) == "boolean") then
        return StatusLog(false,"SQLCreateTable: Table "..sTable
          .." failed to create because of "..tostring(sql.LastError()))
      end
      if(sql.TableExists(TableKey)) then
        for k, v in pairs(tQ.Index) do
          qRez = sql.Query(v)
          if(not qRez and type(qRez) == "boolean") then
            return StatusLog(false,"SQLCreateTable: Table "..sTable
              .." failed to create index ["..k.."] > "..v .." > because of "
              ..tostring(sql.LastError()))
          end
        end
        LogInstance("SQLCreateTable: Indexed Table "..sTable.." created !")
        return true
      else
        return StatusLog(false,"SQLCreateTable: Table "..sTable
          .." failed to create because of "..tostring(sql.LastError())
          .." Query ran > "..tQ.Create)
      end
    end
  else
    return StatusLog(false,"SQLCreateTable: "..SQLGetBuildErr())
  end
end

--------------------------- AssemblyLib PIECE QUERY -----------------------------

function NavigateTable(oLocation,tKeys)
  if(not (oLocation and tKeys)) then return nil, nil end
  if(not tKeys[1]) then return nil, nil end
  local Cnt = 1
  local Place, Key
  while(tKeys[Cnt]) do
    Key = tKeys[Cnt]
    LogInstance("NavigateTable: Key: <"..Key..">")
    if(Place) then
      if(tKeys[Cnt+1]) then
        LogInstance("NavigateTable: Jump: "..Key)
        Place = Place[Key]
        if(not IsExistent(Place)) then return nil, nil end
      end
    else
      LogInstance("NavigateTable: Start: "..Key)
      Place = oLocation[Key]
      if(not IsExistent(Place)) then return nil, nil end
    end
    Cnt = Cnt + 1
  end
  return Place, Key
end

function AttachKillTimer(oLocation,tKeys,defTable,anyMessage)
  local Place, Key = NavigateTable(oLocation,tKeys)
  if(not (IsExistent(Place) and IsExistent(Key))) then
    return StatusLog(false,"AttachKillTimer: Navigation failed")
  end
  local Duration = 0
  local TimerID = StringImplode(tKeys,"_")
  if(defTable) then
    Duration = tonumber(defTable.CacheLife) or 0
  end
  LogInstance("AttachKillTimer: Place["..tostring(Key).."] Marked !")
  LogInstance("AttachKillTimer: TimID: <"..TimerID..">")
  if(Place[Key] and
     Duration > 0 and
     not timer.Exists(TimerID)
  ) then
    timer.Create(TimerID, Duration, 1, function()
      LogInstance("AttachKillTimer["..TimerID.."]("..Duration.."): "
                     ..tostring(anyMessage).." > Dead")
      Place[Key] = nil
      timer.Stop(TimerID)
      timer.Destroy(TimerID)
      collectgarbage()
    end)
    return timer.Start(TimerID)
  end
  return StatusLog(false,"Timer exists or it is not enabled")
end

function RestartTimer(tKeys)
  local TimerID = StringImplode(tKeys,GetOpVar("OPSYM_DIVIDER"))
  if(not timer.Exists(TimerID)) then return false end
  return timer.Start(TimerID)
end

-- Cashing the selected Piece Result
function CacheQueryPiece(sModel)
  if(not sModel) then return nil end
  if(not IsString(sModel)) then return nil end
  if(sModel == "") then return nil end
  if(not util.IsValidModel(sModel)) then return nil end
  local TableKey = GetOpVar("QTABLE_PIECES")
  local Cache    = LibCache[TableKey]
  if(not IsExistent(Cache)) then
    LibCache[TableKey] = {}
    Cache = LibCache[TableKey]
  end
  local defTable = LibTables[TableKey]
  local stPiece  = Cache[sModel]
  local CacheInd = {TableKey,sModel}
  if(stPiece and IsExistent(stPiece.Kept)) then
    if(stPiece.Kept) then
      RestartTimer(CacheInd)
      return LibCache[TableKey][sModel]
    end
    return nil
  end
  LogInstance("CacheQueryPiece: Model >> Pool: "..GetModelFileName(sModel))
  LibCache[TableKey][sModel] = {}
  stPiece = LibCache[TableKey][sModel]
  AttachKillTimer(LibCache,CacheInd,defTable,"CacheQueryPiece")
  local Q = SQLBuildSelect(TableKey,nil,{{1,sModel}})
  if(Q) then
    local qData = sql.Query(Q)
    if(qData and qData[1]) then
      local qRec   = qData[1]
      local arConv = GetOpVar("ARRAY_DECODEPOA")
      local Item
      stPiece.O = {}
      stPiece.M = {}
      stPiece.A = {}
      stPiece.Kept = true
      stPiece.Type = qRec[defTable[2][1]]
      stPiece.Name = qRec[defTable[3][1]]
      stPiece.Mesh = tonumber(qRec[defTable[4][1]])
      Item = qRec[defTable[5][1]] -- Origin
      if((Item ~= "") and (Item ~= "NULL")) then
        DecodeOffset(arConv,Item)
        stPiece.O[cvX] = arConv[1]
        stPiece.O[cvY] = arConv[2]
        stPiece.O[cvZ] = arConv[3]
        stPiece.O[csX] = arConv[4]
        stPiece.O[csY] = arConv[5]
        stPiece.O[csZ] = arConv[6]
        stPiece.O[csD] = arConv[7]
      else
        stPiece.O[cvX] = 0
        stPiece.O[cvY] = 0
        stPiece.O[cvZ] = 0
        stPiece.O[csX] = 1
        stPiece.O[csY] = 1
        stPiece.O[csZ] = 1
        stPiece.O[csD] = false
      end
      Item = qRec[defTable[6][1]] -- Angle
      if((Item ~= "") and (Item ~= "NULL")) then
        DecodeOffset(arConv,Item)
        stPiece.A[caP] = arConv[1]
        stPiece.A[caY] = arConv[2]
        stPiece.A[caR] = arConv[3]
        stPiece.A[csX] = arConv[4]
        stPiece.A[csY] = arConv[5]
        stPiece.A[csZ] = arConv[6]
        stPiece.A[csD] = arConv[7]
      else
        stPiece.A[caP] = 0
        stPiece.A[caY] = 0
        stPiece.A[caR] = 0
        stPiece.A[csX] = 1
        stPiece.A[csY] = 1
        stPiece.A[csZ] = 1
        stPiece.A[csD] = false
      end
      Item = qRec[defTable[7][1]]-- MassCentre
      if((Item ~= "") and (Item ~= "NULL")) then
        DecodeOffset(arConv,Item)
        stPiece.M[cvX] = arConv[1]
        stPiece.M[cvY] = arConv[2]
        stPiece.M[cvZ] = arConv[3]
        stPiece.M[csX] = arConv[4]
        stPiece.M[csY] = arConv[5]
        stPiece.M[csZ] = arConv[6]
        stPiece.M[csD] = arConv[7]
      else
        stPiece.M[cvX] = 0
        stPiece.M[cvY] = 0
        stPiece.M[cvZ] = 0
        stPiece.M[csX] = 1
        stPiece.M[csY] = 1
        stPiece.M[csZ] = 1
        stPiece.M[csD] = false
      end
      Print(stPiece)
      return stPiece
    else
      stPiece.Kept = false
    end
  else
    LogInstance("CacheQueryPiece: "..GetSQLBuildError().."\n")
    return nil
  end
  return nil
end

----------------------- AssemblyLib PANEL QUERY -------------------------------

--- Used to Populate the CPanel Tree
function CacheQueryPanel()
  local TableKey = GetOpVar("QTABLE_PIECES")
  local CacheKey = "USER_PANEL"
  local Cache = LibCache[TableKey]
  if(not IsExistent(Cache)) then
    LibCache[TableKey] = {}
    Cache = LibCache[TableKey]
  end
  local Panel = Cache[CacheKey]
  if(IsExistent(Panel)) then
    LogInstance("CacheQueryPanel: From Pool")
    return Panel
  else
  local Q = SQLBuildSelect(TableKey,{1,2,3},nil,{2,3})
  if(Q) then
    local qData = sql.Query(Q)
    if(qData and qData[1]) then
        Cache[CacheKey] = qData
        LogInstance("CacheQueryPanel: To Pool")
      return qData
    end
      return StatusLog(nil,"CacheQueryPanel: No data found >"..Q.."<")
    end
    return StatusLog(nil,"CacheQueryPanel: "..SQLGetBuildErr())
  end
  return StatusLog(nil,"PanelQueryPieces: "..GetSQLBuildError())
end

---------------------- AssemblyLib EXPORT --------------------------------

-- Used to define DB as a Lua table
function SQLExportIntoLua(sTable,sPrefix)
  if(not IsString(sTable)) then return end
  local TableKey = GetToolPrefU()..sTable
  if(not LibTables[TableKey]) then return end
  local defTable = LibTables[TableKey]
  local Bas = GetOpVar("DIRPATH_BAS")
  local Exp = GetOpVar("DIRPATH_EXP")
  local BasExp = Bas..Exp
  if(not file.Exists(Bas,"DATA")) then
    file.CreateDir(Bas)
  end
  if(not file.Exists(BasExp,"DATA")) then
    file.CreateDir(BasExp)
  end
  local F = file.Open(BasExp..(sPrefix or GetInstPref())..
                      "sql2lua_"..TableKey..".txt", "w", "DATA" )
  if(not F) then
    return StatusLog(false,"SQLExportIntoLua: file.Open("
                          ..BasExp..(sPrefix or GetInstPref())..
                          "sql2lua_"..TableKey..".txt) Failed")
  end
  local Q
  if(sTable == "PIECES") then
    Q = SQLBuildSelect(TableKey,nil,nil,{2,3,1,4})
  else
    Q = SQLBuildSelect(TableKey,nil,nil,nil)
  end
  if(Q) then
    local qData = sql.Query(Q)
    if(qData and qData[1]) then
      local Ind = 1
      local Line = ""
      F:Write("Exported on: "..os.date().."\n")
      F:Write("DB Query Ran: "..Q.."\n")
      F:Write("Return "..#qData.." results !\n")
      F:Write("Function SQLExportIntoLua: \n\n")
      F:Write("local "..TableKey.." = {\n")
      while(qData[Ind]) do
        local Cnt  = 2
        local qRec = qData[Ind]
        local fMod = defTable[1][1]
        Line = "  [\""..qRec[fMod].."\"] = {"
        while(Cnt <= defTable.Size) do
          local f = defTable[Cnt][1]
          local v = qRec[f]
          if(defTable[Cnt][2] == "TEXT") then
            v = "\""..v.."\""
          end
          Line = Line .. tostring(v)
          if(Cnt < defTable.Size) then Line = Line .. ", " end
          Cnt = Cnt + 1
        end
        Line = Line .. "}"
        if(qData[Ind+1]) then Line = Line .. "," end
        F:Write(Line.."\n")
        Ind = Ind + 1
      end
      F:Write("}")
    else
       F:Write("SQLExportIntoLua: No data found >"..Q.."<")
    end
  else
     F:Write("SQLExportIntoLua: "..SQLGetBuildErr().."\n")
  end
  F:Flush()
  F:Close()
end

-- Used to generate inserts based on the DB itself
function SQLExportIntoInserts(sTable,sPrefix)
  if(not IsString(sTable)) then return end
  local TableKey = GetToolPrefU()..sTable
  if(not LibTables[TableKey]) then
    return StatusLog(false,"SQLExportIntoInserts: Missing: Table definition for "..sTable)
  end
  local defTable = LibTables[TableKey]
  local Bas = GetOpVar("DIRPATH_BAS")
  local Exp = GetOpVar("DIRPATH_EXP")
  local BasExp = Bas..Exp
  if(not file.Exists(Bas,"DATA")) then
    file.CreateDir(Bas)
  end
  if(not file.Exists(BasExp,"DATA")) then
    file.CreateDir(BasExp)
  end
  local F = file.Open(BasExp..(sPrefix or GetInstPref())..
                      "sql2inserts_"..TableKey..".txt", "w", "DATA" )
  if(not F) then
    return StatusLog(false,"SQLExportIntoInserts: file.Open("..BasExp..
                          (sPrefix or GetInstPref()).."sql2inserts_"..
                          TableKey..".txt) Failed")
  end
  local Q
  if(sTable == "PIECES") then
    Q = SQLBuildSelect(TableKey,nil,nil,{2,3,1,4})
  else
    Q = SQLBuildSelect(TableKey,nil,nil,nil)
  end
  if(Q) then
  local qData = sql.Query(Q)
    if(qData and qData[1]) then
      local Cnt = 1
      local Ind = 1
      local qRec
      F:Write("Exported on: "..os.date().."\n")
      F:Write("DB Query Ran: "..Q.."\n")
      F:Write("Return "..#qData.." results !\n")
      F:Write("Function SQLExportIntoInserts: \n\n")
      while(qData[Ind]) do
        F:Write("SQLInsertRecord(\""..sTable.."\", {")
        Cnt  = 1
        qRec = qData[Ind]
        while(Cnt <= defTable.Size) do
          local f = defTable[Cnt][1]
          local v = qRec[f]
          if(defTable[Cnt][2] == "TEXT") then
            v = "\""..v.."\""
          end
          F:Write(tostring(v))
          if(Cnt < defTable.Size) then F:Write(", ") end
          Cnt = Cnt + 1
        end
        F:Write(" }\n")
        Ind = Ind + 1
      end
    end
  else
    return StatusLog(false,"SQLExportIntoInserts: "..SQLGetBuildErr().."\n")
  end
  F:Flush()
  F:Close()
end

function LuaExportIntoInserts(tTable,sName,sPrefix)
  if(not (tTable and type(tTable) == "table"))  then return end
  if(not IsString(sName)) then return end
  local Bas = GetOpVar("DIRPATH_BAS")
  local Exp = GetOpVar("DIRPATH_EXP")
  local BasExp = Bas..Exp
  if(not file.Exists(Bas,"DATA")) then
    file.CreateDir(Bas)
  end
  if(not file.Exists(BasExp,"DATA")) then
    file.CreateDir(BasExp)
  end
  local F = file.Open(BasExp..(sPrefix or GetInstPref())..
                      "lua2inserts_"..(sName or "Data")..
                      ".txt", "w", "DATA" )
  if(not F) then
    return StatusLog(false,"LuaExportIntoInserts: file.Open("..BasExp..
                    (sPrefix or GetInstPref()).."lua2inserts_"..
                    (sName or "Data")..".txt) Failed")
  end
  if(tTable) then
    F:Write("Exported on: "..os.date().."\n")
    F:Write("Function LuaExportIntoInserts: \n\n")
    local Sorted = Sort(tTable,{1,3,4,2})
    local Ind = 1
    while(tTable[Ind]) do
      F:Write("SQLInsertRecord(\""..sName.."\", {")
      local Rec = tTable[Ind]
      local Cnt = 1
      while(Rec[Cnt]) do
        local Data = Rec[Cnt]
        if(Data == "NULL") then
          Data = "\"\""
        end
        F:Write(tostring(Data))
        if(Rec[Cnt+1]) then F:Write(", ") end
        Cnt = Cnt + 1
      end
      F:Write(" }\n")
      Ind = Ind + 1
    end
  end
  F:Flush()
  F:Close()
end

--[[
 * Save/Load the DB Using Excel or
 * anything that supports delimiter
 * separated digital tables
 * sPrefix = Something that separates exported table from the rest ( e.g. db_ )
 * sTable  = Definition KEY to export to
 * sDelim  = Delimiter CHAR data separator
 * bCommit = true to insert the read values
]]
function SQLImportFromDSV(sTable,sDelim,bCommit,sPrefix)
  if(not IsString(sTable)) then return end
  local TableKey = GetToolPrefU()..sTable
  if(not LibTables[TableKey]) then
    return StatusLog(false,"SQLImportFromDSV: Missing: Table definition for "..sTable)
  end
  local Bas = GetOpVar("DIRPATH_BAS")
  local Dsv = GetOpVar("DIRPATH_DSV")
  local BasDsv = Bas..Dsv
  local F = file.Open(BasDsv..(sPrefix or GetInstPref())
                      ..TableKey..".txt", "r", "DATA")
  if(not F) then
    return StatusLog(false,"SQLImportFromDSV: file.Open("..BasDsv..
                    (sPrefix or GetInstPref())..TableKey..".txt) Failed")
  end
  local Line = ""
  local TabLen = string.len(TableKey)
  local LinLen = 0
  local ComCnt = 0
  local SymOff = GetOpVar("OPSYM_DISABLE")
  local Ch = "X" -- Just to be something
  while(Ch) do
    Ch = F:Read(1)
    if(not Ch) then return end
    if(Ch == "\n") then
      LinLen = string.len(Line)
      if(string.sub(Line,LinLen,LinLen) == "\r") then
        Line = string.sub(Line,1,LinLen-1)
        LinLen = LinLen - 1
      end
      if(not (string.sub(Line,1,1) == SymOff)) then
        if(string.sub(Line,1,TabLen) == TableKey) then
          local Data = StringExplode(string.sub(Line,TabLen+2,LinLen),sDelim)
          for k,v in pairs(Data) do
            local vLen = string.len(v)
            if(string.sub(v,1,1) == "\"" and string.sub(v,vLen,vLen) == "\"") then
              Data[k] = string.sub(v,2,vLen-1)
            end
          end
          if(bCommit) then
            SQLInsertRecord(sTable,Data)
          end
        end
      end
      Line = ""
    else
      Line = Line..Ch
    end
  end
  F:Close()
end

function SQLExportIntoDSV(sTable,sDelim,sPrefix)
  if(not IsString(sTable)) then return end
  local TableKey = GetToolPrefU()..sTable
  if(not LibTables[TableKey]) then
    return StatusLog(false,"SQLImportFromDSV: Missing: Table definition for "..sTable)
  end
  local defTable = LibTables[TableKey]
  local Bas = GetOpVar("DIRPATH_BAS")
  local Dsv = GetOpVar("DIRPATH_DSV")
  local BasDsv = Bas..Dsv
  if(not file.Exists(Bas,"DATA")) then
    file.CreateDir(Bas)
  end
  if(not file.Exists(BasDsv,"DATA")) then
    file.CreateDir(BasDsv)
  end
  local F = file.Open(BasDsv..(sPrefix or GetInstPref())
                      ..TableKey..".txt", "w", "DATA" )
  if(not F) then
    return StatusLog(false,"SQLExportIntoDSV: file.Open("..BasDsv..
                    (sPrefix or GetInstPref())..TableKey..".txt) Failed")
  end
  local Q
  if(sTable == "PIECES") then
    Q = SQLBuildSelect(TableKey,nil,nil,{2,3,1,4})
  else
    Q = SQLBuildSelect(TableKey,nil,nil,nil)
  end
  LogInstance("SQLExportIntoDSV: "..Q)
  if(Q) then
    local qData = sql.Query(Q)
    if(qData) then
      F:Write("# Exported on: "..os.date().."\n")
      local Line = "# Table: "..TableKey..sDelim
      local Cnt = 1
      while(defTable[Cnt]) do
        Line = Line ..defTable[Cnt][1]
        if(defTable[Cnt+1]) then
          Line = Line..sDelim
        end
        Cnt = Cnt + 1
      end
      F:Write(Line.."\n")
      Cnt = 1
      while(qData[Cnt]) do
        Line = TableKey..sDelim
        local qRec = qData[Cnt]
        local Ind  = 1
        while(defTable[Ind]) do
          local f = defTable[Ind][1]
          if(not f) then
            return StatusLog(false,"SQLExportIntoDSV: Missing field name in table "
              ..sTable.." index #"..Ind)
          end
          local v = tostring(qRec[f]) or ""
          Line = Line..v
          if(defTable[Ind+1]) then
            Line = Line..sDelim
          end
          Ind = Ind + 1
          v = qRec[defTable[Ind]]
        end
        F:Write(Line.."\n")
        Cnt = Cnt + 1
      end
    end
  else
    return StatusLog(false,"SQLExportIntoDSV: Failed to assemble query >> "
      ..SQLGetBuildErr())
  end
  F:Flush()
  F:Close()
end

function SetMCWorld(oEnt,vdbMCL,vMCW)
  if(not vMCW) then return end
  if(not vdbMCL) then return end
  if(not (oEnt and oEnt:IsValid())) then return end
  local vPos = Vector(vdbMCL[cvX],vdbMCL[cvY],vdbMCL[cvZ])
        vPos:Mul(-1)
        vPos:Rotate(oEnt:GetAngles())
        vPos:Add(vMCW)
        oEnt:SetPos(vPos)
end

function vGetMCWorld(oEnt,vdbMCL)
  if(not vdbMCL) then return end
  if(not (oEnt and oEnt:IsValid())) then return end
  local vMCW = Vector(vdbMCL[cvX],vdbMCL[cvY],vdbMCL[cvZ])
        vMCW:Rotate(oEnt:GetAngles())
        vMCW:Add(oEnt:GetPos())
  return vMCW
end

function vGetMCWorldPosAng(vPos,vAng,vdbMCL)
  if(not (vdbMCL and vPos and vAng)) then return end
  local vMCW = Vector(vdbMCL[cvX],vdbMCL[cvY],vdbMCL[cvZ])
        vMCW:Rotate(vAng)
        vMCW:Add(vPos)
  return vMCW
end

function GetCustomAngBBZ(oEnt,oRec,nMode)
  if(not (oEnt and oEnt:IsValid())) then return 0 end
  local Mode = nMode or 0
  if(oRec and Mode ~= 0) then
    local aAngDB = Angle(oRec.A[caP],oRec.A[caY],oRec.A[caR])
    local vOBB = oEnt:OBBMins()
          SubVector(vOBB,oRec.M)
          vOBB:Rotate(aAngDB)
          vOBB:Set(DecomposeByAngle(vOBB,Angle(0,0,0)))
    return math.abs(vOBB[cvZ])
  else
    return (oEnt:OBBMaxs() - oEnt:OBBMins()):Length() / 2.828 -- 2 * sqrt(2)
  end
  return 0
end

----------------------------- AssemblyLib SNAPPING ------------------------------

--[[
 * This function is the backbone of the tool for Trace.Normal
 * Calculates SPos, SAng based on the DB inserts and input parameters
 * stTrace       = Trace result
 * hModel        = Piece holds model
 * ucsPos(X,Y,Z) = Offset position
 * ucsAng(P,Y,R) = Offset angle
]]--

function GetNormalSpawn(stTrace, hModel, ucsPosX, ucsPosY, ucsPosZ,
                        ucsAngP, ucsAngY, ucsAngR)
  if(not stTrace) then return nil end
  if(not stTrace.Hit) then return nil end
  local hdRec = CacheQueryPiece(hModel)
  if(not hdRec) then return nil end
  local stSpawn = GetOpVar("SPAWN_NORMAL")
  stSpawn.HRec = hdRec
  stSpawn.CAng:Set(stTrace.HitNormal:Angle())
  stSpawn.CAng[caP] = stSpawn.CAng[caP] + 90
  stSpawn.DAng:Set(stSpawn.CAng)
  stSpawn.DAng:RotateAroundAxis(stSpawn.CAng:Right()  ,(ucsAngP or 0))
  stSpawn.DAng:RotateAroundAxis(stSpawn.CAng:Forward(),(ucsAngR or 0))
  stSpawn.DAng:RotateAroundAxis(stSpawn.DAng:Up()     ,(ucsAngY or 0))
  stSpawn.F:Set(stSpawn.DAng:Forward())
  stSpawn.R:Set(stSpawn.DAng:Right())
  stSpawn.U:Set(stSpawn.DAng:Up())
  stSpawn.SAng:Set(stSpawn.DAng)
  RotateAngleDir(stSpawn.SAng,"RUF", hdRec.A[caP] * hdRec.A[csX],
                                     hdRec.A[caY] * hdRec.A[csY],
                                     hdRec.A[caR] * hdRec.A[csZ])
  stSpawn.SPos:Set(stTrace.HitPos)
  stSpawn.SPos:Add((ucsPosX or 0) * stSpawn.F)
  stSpawn.SPos:Add((ucsPosY or 0) * stSpawn.R)
  stSpawn.SPos:Add((ucsPosZ or 0) * stSpawn.U)
  return stSpawn
end

--[[
 * This function is the backbone of the tool for Trace.Entity
 * Calculates SPos, SAng based on the DB inserts and input parameters
 * trEnt         = Trace.Entity
 * nRotPivot     = Start angle to rotate trAng to
 * hdModel       = Node:Model()
 * enIgnTyp      = Ignore Gear Type
 * enOrAngTr     = F,R,U Come from trace's angles
 * ucsPos(X,Y,Z) = Offset position
 * ucsAng(P,Y,R) = Offset angle
]]--
function GetEntitySpawn(trEnt,nRotPivot,hdModel,enIgnTyp,
                        enOrAngTr,ucsPosX,ucsPosY,ucsPosZ,
                        ucsAngP,ucsAngY,ucsAngR)
  if(not ( trEnt      and
           nRotPivot  and
           hdModel    and
           enIgnTyp   and
           enOrAngTr )
  ) then return nil end

  local trRec = CacheQueryPiece(trEnt:GetModel())
  local hdRec = CacheQueryPiece(hdModel)

  if(not ( trRec and hdRec )) then return nil end

  if(enIgnTyp   == 0 and
     trRec.Type ~= hdRec.Type ) then return nil end

  -- We have the next Piece Offset
  local stSpawn = GetOpVar("SPAWN_ENTITY")

  stSpawn.CPos:Set(vGetMCWorld(trEnt,trRec.M))
  SetAngle(stSpawn.CAng,trRec.A)
  stSpawn.CAng:Set(trEnt:LocalToWorldAngles(stSpawn.CAng))
  stSpawn.CAng:RotateAroundAxis(stSpawn.CAng:Up(),-nRotPivot)
  -- Do origin !
  SetVector(stSpawn.OPos,trRec.O)
  stSpawn.OPos:Rotate(stSpawn.CAng)
  stSpawn.OPos:Add(stSpawn.CPos)
  -- Do Origin UCS World angle
  stSpawn.SAng:Set(stSpawn.CAng)
  -- Do Origin F,R,U
  RotateAngleDir(stSpawn.SAng,"RF",trRec.Mesh + (ucsAngP or 0),(ucsAngR or 0))
  stSpawn.F:Set(stSpawn.SAng:Forward())
  stSpawn.R:Set(stSpawn.SAng:Right())
  stSpawn.U:Set(stSpawn.SAng:Up())
  -- Save our records
  stSpawn.HRec = hdRec
  stSpawn.TRec = trRec
  -- Get the new Domain
  stSpawn.DAng:Set(stSpawn.SAng)
  RotateAngleDir(stSpawn.DAng,"RU",hdRec.Mesh,(ucsAngY or 0) + 180)

  -- Get Hold model stuff

  SetAngle(stSpawn.MAng, hdRec.A)
  SetVector(stSpawn.MPos, hdRec.O)
  NegAngle(stSpawn.MAng)
  stSpawn.MPos:Rotate(stSpawn.MAng)
  RotateAngleDir(stSpawn.MAng,"UR",180,-hdRec.Mesh)

  NegVector(stSpawn.MPos)
  stSpawn.MPos:Set(DecomposeByAngle(stSpawn.MPos,stSpawn.MAng))

  SetAngle(stSpawn.MAng,hdRec.A)
  NegAngle(stSpawn.MAng)

  stSpawn.SAng:Set(stSpawn.DAng)

  RotateAngleDir(stSpawn.SAng,"RUF",stSpawn.MAng[caP] * hdRec.A[csX],
                                    stSpawn.MAng[caY] * hdRec.A[csY],
                                    stSpawn.MAng[caR] * hdRec.A[csZ])
  -- Do Spawn Position
  stSpawn.SPos:Set(stSpawn.OPos)
  stSpawn.SPos:Add((hdRec.O[csX] * stSpawn.MPos[cvX]) * stSpawn.F)
  stSpawn.SPos:Add((hdRec.O[csY] * stSpawn.MPos[cvY]) * stSpawn.R)
  stSpawn.SPos:Add((hdRec.O[csZ] * stSpawn.MPos[cvZ]) * stSpawn.U)
  if(enOrAngTr ~= 0) then
    stSpawn.F:Set(stSpawn.CAng:Forward())
    stSpawn.R:Set(stSpawn.CAng:Right())
    stSpawn.U:Set(stSpawn.CAng:Up())
  end
  stSpawn.SPos:Add(ucsPosX * stSpawn.F)
  stSpawn.SPos:Add(ucsPosY * stSpawn.R)
  stSpawn.SPos:Add(ucsPosZ * stSpawn.U)
  return stSpawn
end

function GetPropBodyGrp(oEnt)
  local bgEnt
  if(oEnt and oEnt:IsValid()) then
    bgEnt = oEnt
  else
    local Ply = LocalPlayer()
    if(not Ply) then return "" end
    local tr  = Ply:GetEyeTrace()
    if(not tr) then return "" end
    if(tr.HitWorld) then return "" end
    bgEnt = tr.Entity
  end
  if(bgEnt and bgEnt:IsValid()) then
    LogInstance("GetPropBodyGrp: ")
    if(IsOther(bgEnt)) then return "" end
    local BG = bgEnt:GetBodyGroups()
    if(not (BG and BG[1])) then return "" end
    Print(BG,"GetPropBodyGrp: BG")
    local Rez = ""
    local Cnt = 1
    while(BG[Cnt]) do
      Rez = Rez..","..(bgEnt:GetBodygroup(BG[Cnt].id) or 0)
      Cnt = Cnt + 1
    end
    return string.sub(Rez,2,string.len(Rez))
  end
  return ""
end

function AttachBodyGroups(ePiece,sBgrpIDs)
  LogInstance("AttachBodyGroups: ")
  local NumBG = ePiece:GetNumBodyGroups()
  LogInstance("BG: "..sBgrpIDs)
  LogInstance("NU: "..NumBG)
  local IDs = Str2BGID(sBgrpIDs,NumBG)
  if(not IDs) then return end
  local BG = ePiece:GetBodyGroups()
  Print(IDs,"IDs")
  local Cnt = 1
  while(BG[Cnt]) do
    local CurBG = BG[Cnt]
    local BGCnt = ePiece:GetBodygroupCount(CurBG.id)
    if(IDs[Cnt] > BGCnt or
       IDs[Cnt] < 0) then IDs[Cnt] = 0 end
    LogInstance("ePiece:SetBodygroup("..CurBG.id..","..(IDs[Cnt] or 0)..")")
    ePiece:SetBodygroup(CurBG.id,IDs[Cnt] or 0)
    Cnt = Cnt + 1
  end
end

function GetPropSkin(oEnt)
  local skEnt
  if(oEnt and oEnt:IsValid()) then
    skEnt = oEnt
  else
    local Ply = LocalPlayer()
    if(not Ply) then return "" end
    local tr = Ply:GetEyeTrace()
    if(not tr) then return "" end
    if(tr.HitWorld) then return "" end
    skEnt = tr.Entity
  end
  if(skEnt and skEnt:IsValid()) then
    if(IsOther(skEnt)) then return "" end
    local Skin = skEnt:GetSkin()
    if(not tonumber(Skin)) then return "" end
    return tostring(Skin)
  end
  return ""
end

function GetModelFileName(sModel)
  if(not sModel or
         sModel == "") then return "NULL" end
  local Len = string.len(sModel)
  local Cnt = Len
  local Ch  = string.sub(sModel,Cnt,Cnt)
  while(Ch ~= "/" and Cnt > 0) do
    Cnt = Cnt - 1
    Ch  = string.sub(sModel,Cnt,Cnt)
  end
  return string.sub(sModel,Cnt+1,Len)
end

function HookOnRemove(oBas,oEnt,arCTable,nMax)
  if(not (oBas and oBas:IsValid())) then return end
  if(not (oEnt and oEnt:IsValid())) then return end
  if(not (arCTable and nMax)) then return end
  if(nMax < 1) then return end
  local Ind = 1
  while(Ind <= nMax) do
    if(not arCTable[Ind]) then
      StatusLog(nil,"HookOnRemove > Nil value on index "..Ind..", ignored !")
    end
    oEnt:DeleteOnRemove(arCTable[Ind])
    oBas:DeleteOnRemove(arCTable[Ind])
    Ind = Ind + 1
  end
  LogInstance("HookOnRemove > Done "..(Ind-1).." of "..nMax..".")
end

function MakePiece(sModel,vPos,aAng,nMass,sBgSkIDs,clColor)
  -- You never know .. ^_^
  local stPiece = CacheQueryPiece(sModel)
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
    ePiece:SetColor(clColor)
    ePiece:DrawShadow(true)
    ePiece:PhysWake()
    local phPiece = ePiece:GetPhysicsObject()
    if(phPiece and phPiece:IsValid()) then
      local IDs = StringExplode(sBgSkIDs,"/")
      phPiece:SetMass(nMass)
      phPiece:EnableMotion(false)
      ePiece:SetSkin(math.Clamp(tonumber(IDs[2]) or 0,0,ePiece:SkinCount()-1))
      AttachBodyGroups(ePiece,IDs[1] or "")
      ePiece.Duplicate = function(ePiece)
        return MakePiece(ePiece:GetModel(),ePiece:GetPos(),
                         GetOpVar("ANG_ZERO"),phPiece:GetMass(),
                         GetPropBodyGrp(ePiece).."/"..GetPropSkin(ePiece),
                         ePiece:GetColor())
      end
      ePiece.Create = MakePiece
      ePiece.Anchor = function(ePiece,eBase,vPos,vNorm,nID,nNoCollid,nForceLim,nFreeze,nGrav,nNoPhyGun)
        local ConstrDB = GetOpVar("CONSTRAINT_TYPE")
        local ConID    = tonumber(nID) or 1
        local Freeze   = nFreeze       or 0
        local Grav     = nGrav         or 0
        local NoCollid = nNoCollid     or 0
        local ForceLim = nForceLim     or 0
        local NoPhyGun = nNoPhyGun     or 0
        local IsIn
        local ConstrInfo = ConstrDB:Select(ConID)
        if(not IsExistent(ConstrInfo)) then
          return StatusLog(false,"Piece:Anchor() Constraint not available")
        end
        LogInstance("Piece:Anchor() Creating "..ConstrInfo.Name)
        if(not (ePiece and ePiece:IsValid())) then
          return StatusLog(false,"Piece:Anchor() Piece not valid")
        end
        if(IsOther(ePiece)) then
          return StatusLog(false,"Piece:Anchor() Piece is other object")
        end
        if(not constraint.CanConstrain(ePiece,0)) then
          return StatusLog(false,"Piece:Anchor() Cannot constrain Piece")
        end
        local pyPiece = ePiece:GetPhysicsObject()
        if(not (pyPiece and pyPiece:IsValid())) then
          return StatusLog(false,"Piece:Anchor() Phys Piece not valid")
        end
        construct.SetPhysProp(nil,ePiece,0,pyPiece,{Material = "gmod_ice"})
        if(nFreeze and Freeze == 0) then
          pyPiece:EnableMotion(true)
        end
        if(Grav == 0) then
          construct.SetPhysProp(nil,ePiece,0,pyPiece,{GravityToggle = false})
        end
        if(NoPhyGun and NoPhyGun ~= 0) then --  is my custom child ...
          ePiece:SetUnFreezable(true)
          ePiece.PhysgunDisabled = true
          duplicator.StoreEntityModifier(ePiece,GetToolPrefL().."nophysgun",{[1] = true})
        end
        if(not IsIn and ConID == 1) then
            IsIn = ConID
        end
        if(not (eBase and eBase:IsValid())) then
          return StatusLog(0,"Piece:Anchor() Base not valid")
        end
        if(not constraint.CanConstrain(eBase,0)) then
          return StatusLog(false,"Piece:Anchor() Cannot constrain Base")
        end
        if(IsOther(eBase)) then
          return StatusLog(false,"Piece:Anchor() Base is other object")
        end
        if(not IsIn and ConID == 2) then
          -- http://wiki.garrysmod.com/page/Entity/SetParent
          ePiece:SetParent(eBase)
          IsIn = ConID
        elseif(not IsIn and ConID == 3) then
          -- http://wiki.garrysmod.com/page/constraint/Weld
          local C = ConstrInfo.Make(ePiece,eBase,0,0,ForceLim,(NoCollid ~= 0),false)
          HookOnRemove(eBase,ePiece,{C},1)
          IsIn = ConID
        end
        if(not IsIn and ConID == 4 and vNorm) then
          -- http://wiki.garrysmod.com/page/constraint/Axis
          local LPos1 = pyPiece:GetMassCenter()
          local LPos2 = ePiece:LocalToWorld(LPos1)
                LPos2:Add(vNorm)
                LPos2:Set(eBase:WorldToLocal(LPos2))
          local C = ConstrInfo.Make(ePiece,eBase,0,0,
                      LPos1,LPos2,ForceLim,0,0,NoCollid)
           HookOnRemove(eBase,ePiece,{C},1)
           IsIn = ConID
        elseif(not IsIn and ConID == 5) then
          -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( HD )
          local C = ConstrInfo.Make(eBase,ePiece,0,0,pyPiece:GetMassCenter(),ForceLim,0,NoCollid)
          HookOnRemove(eBase,ePiece,{C},1)
          IsIn = ConID
        elseif(not IsIn and ConID == 6 and vPos) then
          -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( TR )
          local vLPos2 = eBase:WorldToLocal(vPos)
          local C = ConstrInfo.Make(ePiece,eBase,0,0,vLPos2,ForceLim,0,NoCollid)
          HookOnRemove(eBase,ePiece,{C},1)
          IsIn = ConID
        end
        -- http://wiki.garrysmod.com/page/constraint/AdvBallsocket
        local pyBase = eBase:GetPhysicsObject()
        if(not (pyBase and pyBase:IsValid())) then
          return StatusLog(false,"Piece:Anchor() Phys Base not valid")
        end
        local Min,Max = 0.01,180
        local LPos1 = pyBase:GetMassCenter()
        local LPos2 = pyPiece:GetMassCenter()
        if(not IsIn and ConID == 7) then -- Lock X
          local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Min,-Max,-Max,Min,Max,Max,0,0,0,1,NoCollid)
          HookOnRemove(eBase,ePiece,{C},1)
          IsIn = ConID
        elseif(not IsIn and ConID == 8) then -- Lock Y
          local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max,-Min,-Max,Max,Min,Max,0,0,0,1,NoCollid)
          HookOnRemove(eBase,ePiece,{C},1)
          IsIn = ConID
        elseif(not IsIn and ConID == 9) then -- Lock Z
          local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max,-Max,-Min,Max,Max,Min,0,0,0,1,NoCollid)
          HookOnRemove(eBase,ePiece,{C},1)
          IsIn = ConID
        elseif(not IsIn and ConID == 10) then -- Spin X
          local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max,-Min,-Min,Max, Min, Min,0,0,0,1,NoCollid)
          local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max, Min, Min,Max,-Min,-Min,0,0,0,1,NoCollid)
          HookOnRemove(eBase,ePiece,{C1,C2},2)
          IsIn = ConID
        elseif(not IsIn and ConID == 11) then -- Spin Y
          local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Min,-Max,-Min, Min,Max, Min,0,0,0,1,NoCollid)
          local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0, Min,-Max, Min,-Min,Max,-Min,0,0,0,1,NoCollid)
          HookOnRemove(eBase,ePiece,{C1,C2},2)
          IsIn = ConID
        elseif(not IsIn and ConID == 12) then -- Spin Z
          local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Min,-Min,-Max, Min, Min,Max,0,0,0,1,NoCollid)
          local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0, Min, Min,-Max,-Min,-Min,Max,0,0,0,1,NoCollid)
          HookOnRemove(eBase,ePiece,{C1,C2},2)
          IsIn = ConID
        end
        return StatusLog(IsIn,"Piece:Anchor() status is <"..tostring(IsIn)..">")
      end
      return ePiece
    end
    ePiece:Remove()
    return nil
  end
  return nil
end
