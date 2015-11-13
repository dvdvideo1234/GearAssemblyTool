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
local setmetatable   = setmetatable
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
local LibAction = {} -- Used to attach external function to the lib
local LibOpVars = {} -- Used to Store operational Variable Values

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
  local sModeDB = GetOpVar("MODE_DATABASE")
  if(SERVER) then
    print("SERVER > "..GetOpVar("TOOLNAME_NU").." ["..sModeDB.."] "..tostring(anyStuff))
  elseif(CLIENT) then
    print("CLIENT > "..GetOpVar("TOOLNAME_NU").." ["..sModeDB.."] "..tostring(anyStuff))
  else
    print("NOINST > "..GetOpVar("TOOLNAME_NU").." ["..sModeDB.."] "..tostring(anyStuff))
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

function IsBool(anyArg)
  if    (anyArg == true ) then return true
  elseif(anyArg == false) then return true end
  return false
end

function InitAssembly(sName)
  SetOpVar("TYPEMT_STRING",getmetatable("TYPEMT_STRING"))
  SetOpVar("TYPEMT_SCREEN",{})
  SetOpVar("TYPEMT_CONTAINER",{})
  if(not IsString(sName)) then
    PrintInstance("gearasmlib.lua: Error initializing. Expecting string argument")
    return false
  end
  if(string.len(sName) < 1 and tonumber(string.sub(sName,1,1))) then return end
  SetOpVar("TIME_EPOCH",os.clock())
  SetOpVar("INIT_NL" ,string.lower(sName))
  SetOpVar("INIT_FAN",string.sub(string.upper(GetOpVar("INIT_NL")),1,1)
                    ..string.sub(string.lower(GetOpVar("INIT_NL")),2,string.len(GetOpVar("INIT_NL"))))
  SetOpVar("PERP_UL","assembly")
  SetOpVar("PERP_FAN",string.sub(string.upper(GetOpVar("PERP_UL")),1,1)
                    ..string.sub(string.lower(GetOpVar("PERP_UL")),2,string.len(GetOpVar("PERP_UL"))))
  SetOpVar("TOOLNAME_NL",string.lower(GetOpVar("INIT_NL")..GetOpVar("PERP_UL")))
  SetOpVar("TOOLNAME_NU",string.upper(GetOpVar("INIT_NL")..GetOpVar("PERP_UL")))
  SetOpVar("TOOLNAME_PL",GetOpVar("TOOLNAME_NL").."_")
  SetOpVar("TOOLNAME_PU",GetOpVar("TOOLNAME_NU").."_")
  SetOpVar("MISS_NOID","N")    -- No ID selected
  SetOpVar("MISS_NOAV","N/A")  -- Not Available
  SetOpVar("MISS_NOMD","X")    -- No model
  SetOpVar("ARRAY_DECODEPOA",{0,0,0,1,1,1,false})
  SetOpVar("TABLE_FREQUENT_MODELS",{})
  SetOpVar("HASH_USER_PANEL",GetOpVar("TOOLNAME_PU").."USER_PANEL")
  SetOpVar("HASH_QUERY_STORE",GetOpVar("TOOLNAME_PU").."QHASH_QUERY")
  SetOpVar("ANG_ZERO",Angle())
  SetOpVar("VEC_ZERO",Vector())
  SetOpVar("OPSYM_DISABLE","#")
  SetOpVar("OPSYM_REVSIGN","@")
  SetOpVar("OPSYM_DIVIDER","_")
  SetOpVar("OPSYM_DIRECTORY","/")
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
  setmetatable(self,GetOpVar("TYPEMT_CONTAINER"))
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
  if(getmetatable(conPalette) == GetOpVar("TYPEMT_CONTAINER")) then
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
  setmetatable(self,GetOpVar("TYPEMT_SCREEN"))
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

local function AddLineListView(pnListView,frUsed,iNdex)
  if(not IsExistent(pnListView)) then return StatusLog(nil,"LineAddListView: Missing panel") end
  if(not IsValid(pnListView)) then return StatusLog(nil,"LineAddListView: Invalid panel") end
  if(not IsExistent(frUsed)) then return StatusLog(nil,"LineAddListView: Missing data") end
  local iNdex = tonumber(iNdex)
  if(not IsExistent(iNdex)) then return StatusLog(nil,"LineAddListView: Index <"..tostring(iNdex).."> not a number but "..type(iNdex)) end
  local tValue = frUsed[iNdex]
  if(not IsExistent(tValue)) then return StatusLog(nil,"LineAddListView: Missing data on index #"..tostring(iNdex)) end
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not IsExistent(defTable)) then return StatusLog(nil,"LineAddListView: Missing: Table definition") end
  local sModel = tValue.Table[defTable[1][1]]
  local sType  = tValue.Table[defTable[2][1]]
  local nAct   = tValue.Table[defTable[4][1]]
  local nLife  = RoundValue(tValue.Value,0.001)
  local pnRec  = pnListView:AddLine(nLife,nAct,sType,sModel)
  if(not IsExistent(pnRec)) then
    return StatusLog(false,"LineAddListView: Failed to create a ListView line for <"..sModel.."> #"..iNdex)
  end
  return pnRec, tValue
end

--[[
 * Updates a VGUI pnListView with a search preformed in the already generated
 * frequently used pieces "frUsed" for the pattern "sPattern" given by the user
 * and a filed selected "sField". Draws the progress on the progress bar (if any).
 * On success populates "pnListView" with the search preformed
 * On fail a parameter is not valid or missing and returns non-success
]]--
function UpdateListView(pnListView,frUsed,nCount,sField,sPattern)
  if(not (IsExistent(frUsed) and IsExistent(frUsed[1]))) then return StatusLog(false,"UpdateListView: Missing data") end
  local nCount = tonumber(nCount) or 0
  if(not IsExistent(nCount)) then return StatusLog(false,"UpdateListView: Number conversion failed "..tostring(nCount)) end
  if(nCount <= 0) then return StatusLog(false,"UpdateListView: Count not applicable") end
  if(IsExistent(pnListView)) then
    if(not IsValid(pnListView)) then return StatusLog(false,"UpdateListView: Invalid ListView") end
    pnListView:SetVisible(false)
    pnListView:Clear()
  else
    return StatusLog(false,"UpdateListView: Missing ListView")
  end
  local sField   = tostring(sField   or "")
  local sPattern = tostring(sPattern or "")
  local iNdex, pnRec, sData = 1, nil, nil
  while(frUsed[iNdex]) do
    if(sPattern == "") then
      pnRec = AddLineListView(pnListView,frUsed,iNdex)
      if(not IsExistent(pnRec)) then
        return StatusLog(false,"UpdateListView: Failed to add line on #"..tostring(iNdex))
      end
    else
      sData = tostring(frUsed[iNdex].Table[sField] or "")
      if(string.find(sData,sPattern)) then
        pnRec = AddLineListView(pnListView,frUsed,iNdex)
        if(not IsExistent(pnRec)) then
          return StatusLog(false,"UpdateListView: Failed to add pattern <"..sPattern.."> on #"..tostring(iNdex))
        end
      end
    end
    iNdex = iNdex + 1
  end
  pnListView:SetVisible(true)
  return StatusLog(true,"UpdateListView: Crated #"..tostring(iNdex-1))
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
  local snCount = tonumber(snCount) or 0
  if(snCount < 1) then return StatusLog(nil,"GetFrequentModels: Count not applicable") end
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not IsExistent(defTable)) then return StatusLog(nil,"GetFrequentModels: Missing: Table definition") end
  local Cache = LibCache[defTable.Name]
  if(not IsExistent(Cache)) then return StatusLog(nil,"GetFrequentModels: Missing: Table cache") end
  local iInd, tmNow = 1, Time()
  local frUsed = GetOpVar("TABLE_FREQUENT_MODELS")
  table.Empty(frUsed)
  for Model, Record in pairs(Cache) do
    if(IsExistent(Record.Used) and IsExistent(Record.Kept) and Record.Kept > 0) then
      iInd = PushSortValues(frUsed,snCount,tmNow-Record.Used,{
               [defTable[1][1]] = Model,
               [defTable[2][1]] = Record.Type,
               [defTable[3][1]] = Record.Name,
               [defTable[4][1]] = Record.Mesh
             })
      if(iInd < 1) then return StatusLog(nil,"GetFrequentModels: Array index out of border") end
    end
  end
  if(IsExistent(frUsed) and IsExistent(frUsed[1])) then return frUsed, snCount end
  return StatusLog(nil,"GetFrequentModels: Array is empty or not available")
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
  if(getmetatable(oContainer) ~= GetOpVar("TYPEMT_CONTAINER")) then return 1 end
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

local function BorderValue(nsVal,sName)
  if(not IsString(sName)) then return nsVal end
  if(not (IsString(nsVal) or tonumber(nsVal))) then return StatusLog(nsVal,"BorderValue: Value not comparable") end
  local Border = GetOpVar("TABLE_BORDERS")
        Border = Border[sName]
  if(IsExistent(Border)) then
    if    (nsVal < Border[1]) then return Border[1]
    elseif(nsVal > Border[2]) then return Border[2] end
  end
  return nsVal
end

function ModelToName(sModel)
  if(not IsString(sModel)) then return "" end
  local Cnt = 1   -- If is model remove *.mdl
  local sModel = string.gsub(sModel,GetOpVar("FILE_MODEL"),"")
  local Len = string.len(sModel)
  if(Len <= 0) then return "" end
  local sSymDiv = GetOpVar("OPSYM_DIVIDER")
  local sSymDir = GetOpVar("OPSYM_DIRECTORY")
  local gModel = ""
        sModel = string.sub(sModel,1,Len)
  -- Locate the model part and exclude the directories
  Cnt = string.len(sModel)
  local fCh, bCh = "", ""
  while(Cnt > 0) do
    fCh = string.sub(sModel,Cnt,Cnt)
    if(fCh == sSymDir) then
      break
    end
    Cnt = Cnt - 1
  end
  sModel = string.sub(sModel,Cnt+1,Len)
  -- Remove the unneeded parts by indexing sModel
  Cnt = 1
  gModel = sModel
  local tCut, tSub, tApp = SettingsModelToName("GET")
  if(tCut and tCut[1]) then
    while(tCut[Cnt] and tCut[Cnt+1]) do
      fCh = tonumber(tCut[Cnt])
      bCh = tonumber(tCut[Cnt+1])
      if(not (fCh and bCh)) then
        return StatusLog("","ModelToName: Cannot cut the model in {"
                 ..tostring(tCut[Cnt])..", "..tostring(tCut[Cnt+1]).."} for "..sModel)
      end
      LogInstance("ModelToName[CUT]: {"..tostring(tCut[Cnt])..", "..tostring(tCut[Cnt+1]).."} << "..gModel)
      gModel = string.gsub(gModel,string.sub(sModel,fCh,bCh),"")
      LogInstance("ModelToName[CUT]: {"..tostring(tCut[Cnt])..", "..tostring(tCut[Cnt+1]).."} >> "..gModel)
      Cnt = Cnt + 2
    end
    Cnt = 1
  end
  -- Replace the unneeded parts by finding an in-string gModel
  if(tSub and tSub[1]) then
    while(tSub[Cnt]) do
      fCh = tostring(tSub[Cnt]   or "")
      bCh = tostring(tSub[Cnt+1] or "")
      if(not (fCh and bCh)) then
        return StatusLog("","ModelToName: Cannot sub the model in {"..fCh..", "..bCh.."}")
      end
      LogInstance("ModelToName:[SUB] {"..tostring(tSub[Cnt])..", "..tostring(tSub[Cnt+1]).."} << "..gModel)
      gModel = string.gsub(gModel,fCh,bCh)
      LogInstance("ModelToName:[SUB] {"..tostring(tSub[Cnt])..", "..tostring(tSub[Cnt+1]).."} >> "..gModel)
      Cnt = Cnt + 2
    end
    Cnt = 1
  end
  -- Append something if needed
  if(tApp and tApp[1]) then
    LogInstance("ModelToName:[APP] {"..tostring(tApp[Cnt])..", "..tostring(tApp[Cnt+1]).."} << "..gModel)
    gModel = tostring(tApp[1] or "")..gModel..tostring(tApp[2] or "")
    LogInstance("ModelToName:[APP] {"..tostring(tSub[Cnt])..", "..tostring(tSub[Cnt+1]).."} >> "..gModel)
  end
  -- Trigger the capital-space using the divider
  sModel = sSymDiv..gModel
  Len = string.len(sModel)
  fCh, bCh, gModel = "", "", ""
  while(Cnt <= Len) do
    bCh = string.sub(sModel,Cnt,Cnt)
    fCh = string.sub(sModel,Cnt+1,Cnt+1)
    if(bCh == sSymDiv) then
       bCh = " "
       fCh = string.upper(fCh)
       gModel = gModel..bCh..fCh
       Cnt = Cnt + 1
    else
      gModel = gModel..bCh
    end
    Cnt = Cnt + 1
  end
  return string.sub(gModel,2,Len)
end

local function ReloadPOA(nXP,nYY,nZR,nSX,nSY,nSZ,nSD)
  local arPOA = GetOpVar("ARRAY_DECODEPOA")
        arPOA[1] = tonumber(nXP) or 0
        arPOA[2] = tonumber(nYY) or 0
        arPOA[3] = tonumber(nZR) or 0
        arPOA[4] = tonumber(nSX) or 1
        arPOA[5] = tonumber(nSY) or 1
        arPOA[6] = tonumber(nSZ) or 1
        arPOA[7] = (nSD) and true or false
  return arPOA
end

local function ReloadPOA(nXP,nYY,nZR,nSX,nSY,nSZ,nSD)
  local arPOA = GetOpVar("ARRAY_DECODEPOA")
        arPOA[1] = tonumber(nXP) or 0
        arPOA[2] = tonumber(nYY) or 0
        arPOA[3] = tonumber(nZR) or 0
        arPOA[4] = tonumber(nSX) or 1
        arPOA[5] = tonumber(nSY) or 1
        arPOA[6] = tonumber(nSZ) or 1
        arPOA[7] = (nSD) and true or false
  return arPOA
end

local function IsEqualPOA(stOffsetA,stOffsetB)
  if(not IsExistent(stOffsetA)) then return StatusLog(nil,"EqualPOA: Missing OffsetA") end
  if(not IsExistent(stOffsetB)) then return StatusLog(nil,"EqualPOA: Missing OffsetB") end
  for Ind, Comp in pairs(stOffsetA) do
    if(Ind ~= csD and stOffsetB[Ind] ~= Comp) then return false end
  end
  return true
end

local function StringPOA(arOffs,iID,sOffs)
  if(not IsString(sOffs)) then return StatusLog(nil,"StringPOA: Mode is not a string but "..type(sOffs)) end
  if(not IsExistent(arOffs)) then return StatusLog(nil,"StringPOA: Missing Offsets") end
  local iID = tonumber(iID)
  if(not IsExistent(iID)) then return StatusLog(nil,"StringPOA: Missing PointID") end
  local Offset = arOffs[iID]
  if(not IsExistent(Offset)) then return StatusLog(nil,"StringPOA: No offset for ID #"..tostring(iID)) end
  local Empty
  local Result = ""
  local symRevs = GetOpVar("OPSYM_REVSIGN")
  local symDisa = GetOpVar("OPSYM_DISABLE")
  local sModeDB = GetOpVar("MODE_DATABASE")
  if    (sModeDB == "SQL") then Empty = "NULL"
  elseif(sModeDB == "LUA") then Empty = "NULL"
  else return StatusLog("","StringPOA: Missed database mode "..sModeDB)
  end
  if(sOffs == "P") then
    if(not Offset.P[csD]) then
      if(IsEqualPOA(Offset.P,Offset.O)) then
        Result = Empty
      else
        Result =  ((Offset.P[csX] == -1) and symRevs or "")..tostring(Offset.P[cvX])..","
                ..((Offset.P[csY] == -1) and symRevs or "")..tostring(Offset.P[cvY])..","
                ..((Offset.P[csZ] == -1) and symRevs or "")..tostring(Offset.P[cvZ])
      end
    else
      Result = symDisa
    end
  elseif(sOffs == "O") then
    Result =  ((Offset.O[csX] == -1) and symRevs or "")..tostring(Offset.O[cvX])..","
            ..((Offset.O[csY] == -1) and symRevs or "")..tostring(Offset.O[cvY])..","
            ..((Offset.O[csZ] == -1) and symRevs or "")..tostring(Offset.O[cvZ])
  elseif(sOffs == "A") then
    if(Offset.A[caP] == 0 and Offset.A[caY] == 0 and Offset.A[caR] == 0) then
      Result = Empty
    else
      Result =  ((Offset.A[csX] == -1) and symRevs or "")..tostring(Offset.A[caP])..","
              ..((Offset.A[csY] == -1) and symRevs or "")..tostring(Offset.A[caY])..","
              ..((Offset.A[csZ] == -1) and symRevs or "")..tostring(Offset.A[caR])
    end
  else
    return StatusLog("","StringPOA: Missed offset mode "..sOffs)
  end
  return string.gsub(Result," ","") -- Get rid of the spaces
end

local function TransferPOA(stOffset,sMode)
  if(not IsExistent(stOffset)) then return StatusLog(nil,"TransferPOA: Destination needed") end
  if(not IsString(sMode)) then return StatusLog(nil,"TransferPOA: Mode must be string") end
  local arPOA = GetOpVar("ARRAY_DECODEPOA")
  if(sMode == "V") then
    stOffset[cvX] = arPOA[1]
    stOffset[cvY] = arPOA[2]
    stOffset[cvZ] = arPOA[3]
  elseif(sMode == "A") then
    stOffset[caP] = arPOA[1]
    stOffset[caY] = arPOA[2]
    stOffset[caR] = arPOA[3]
  else
    return StatusLog(nil,"TransferPOA: Missed mode "..sMode)
  end
  stOffset[csX] = arPOA[4]
  stOffset[csY] = arPOA[5]
  stOffset[csZ] = arPOA[6]
  stOffset[csD] = arPOA[7]
  return arPOA
end

local function DecodePOA(sStr)
  if(not IsString(sStr)) then return StatusLog(nil,"DecodePOA: Argument must be string") end
  local DatInd = 1
  local ComCnt = 0
  local Len    = string.len(sStr)
  local SymOff = GetOpVar("OPSYM_DISABLE")
  local SymRev = GetOpVar("OPSYM_REVSIGN")
  local arPOA  = GetOpVar("ARRAY_DECODEPOA")
  local Ch = ""
  local S = 1
  local E = 1
  local Cnt = 1
  ReloadPOA()
  if(string.sub(sStr,Cnt,Cnt) == SymOff) then
    arPOA[7] = true
    Cnt = Cnt + 1
    S   = S   + 1
  end
  while(Cnt <= Len) do
    Ch = string.sub(sStr,Cnt,Cnt)
    if(Ch == SymRev) then
      arPOA[3+DatInd] = -arPOA[3+DatInd]
      S   = S + 1
    elseif(Ch == ",") then
      ComCnt = ComCnt + 1
      E = Cnt - 1
      if(ComCnt > 2) then break end
      arPOA[DatInd] = tonumber(string.sub(sStr,S,E)) or 0
      DatInd = DatInd + 1
      S = Cnt + 1
      E = S
    else
      E = E + 1
    end
    Cnt = Cnt + 1
  end
  arPOA[DatInd] = tonumber(string.sub(sStr,S,E)) or 0
  return arPOA
end

local function RegisterPOA(stPiece, nID, sP, sO, sA)
  if(not stPiece) then return StatusLog(nil,"RegisterPOA: Cache record invalid") end
  local nID = tonumber(nID)
  if(not nID) then return StatusLog(nil,"RegisterPOA: OffsetID is not a number") end
  local sP = sP or "NULL"
  local sO = sO or "NULL"
  local sA = sA or "NULL"
  if(not IsString(sP)) then return StatusLog(nil,"RegisterPOA: Point is not a string but "..type(sP)) end
  if(not IsString(sO)) then return StatusLog(nil,"RegisterPOA: Origin is not a string but "..type(sO)) end
  if(not IsString(sA)) then return StatusLog(nil,"RegisterPOA: Angle is not a string but "..type(sA)) end
  if(not stPiece.Offs) then
    if(nID > 1) then return StatusLog(nil,"RegisterPOA: First ID cannot be "..tostring(nID)) end
    stPiece.Offs = {}
  end
  local tOffs = stPiece.Offs
  if(tOffs[nID]) then
    return StatusLog(nil,"RegisterPOA: Exists ID #"..tostring(nID))
  else
    if((nID > 1) and (not tOffs[nID - 1])) then
      return StatusLog(nil,"RegisterPOA: No sequential ID #"..tostring(nID - 1))
    end
    tOffs[nID]   = {}
    tOffs[nID].P = {}
    tOffs[nID].O = {}
    tOffs[nID].A = {}
    tOffs        = tOffs[nID]
  end
  if((sP ~= "") and (sP ~= "NULL")) then DecodePOA(sP) else ReloadPOA() end
  if(not IsExistent(TransferPOA(tOffs.P,"V"))) then
    return StatusLog(nil,"RegisterPOA: Cannot transfer point")
  end
  if((sO ~= "") and (sO ~= "NULL")) then DecodePOA(sO) else ReloadPOA() end
  if(not IsExistent(TransferPOA(tOffs.O,"V"))) then
    return StatusLog(nil,"RegisterPOA: Cannot transfer origin")
  end
  if((sA ~= "") and (sA ~= "NULL")) then DecodePOA(sA) else ReloadPOA() end
  if(not IsExistent(TransferPOA(tOffs.A,"A"))) then
    return StatusLog(nil,"RegisterPOA: Cannot transfer angle")
  end
  return tOffs
end

function FormatNumberMax(nNum,nMax)
  local nNum = tonumber(nNum)
  local nMax = tonumber(nMax)
  if(not (nNum and nMax)) then return "" end
  return string.format("%"..string.len(tostring(math.floor(nMax))).."d",nNum)
end

local function Qsort(Data,Lo,Hi)
  if(not (Lo and Hi and (Lo > 0) and (Lo < Hi))) then return StatusLog(nil,"Qsort: Data dimensions mismatch") end
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

local function Ssort(Data,Lo,Hi)
  if(not (Lo and Hi and (Lo > 0) and (Lo < Hi))) then return StatusLog(nil,"Ssort: Data dimensions mismatch") end
  local Ind = 1
  local Sel
  while(Data[Ind]) do
    Sel = Ind + 1
    while(Data[Sel]) do
      if(Data[Sel].Val < Data[Ind].Val) then
        Data[Ind], Data[Sel] = Data[Sel], Data[Ind]
      end
      Sel = Sel + 1
    end
    Ind = Ind + 1
  end
end

local function Bsort(Data,Lo,Hi)
  if(not (Lo and Hi and (Lo > 0) and (Lo < Hi))) then return StatusLog(nil,"Bsort: Data dimensions mismatch") end
  local Ind, End = 1, false
  while(not End) do
    End = true
    for Ind = Lo, (Hi-1), 1 do
      if(Data[Ind].Val > Data[Ind+1].Val) then
        End = false
        Data[Ind], Data[Ind+1] = Data[Ind+1], Data[Ind]
      end
    end
  end
end

function Sort(tTable,tKeys,tFields,sMethod)
  local Match = {}
  local tKeys = tKeys or {}
  local tFields = tFields or {}
  local Cnt, Ind, Key, Val, Fld = 1, nil, nil, nil, nil
  if(not tKeys[1]) then
    for k,v in pairs(tTable) do
      tKeys[Cnt] = k
      Cnt = Cnt + 1
    end
    Cnt = 1
  end
  while(tKeys[Cnt]) do
    Key = tKeys[Cnt]
    Val = tTable[Key]
    if(not Val) then
      return StatusLog(nil,"Sort: Key >"..Key.."< does not exist in the primary table")
    end
    Match[Cnt] = {}
    Match[Cnt].Key = Key
    if(type(Val) == "table") then
      Match[Cnt].Val = ""
      Ind = 1
      while(tFields[Ind]) do
        Fld = tFields[Ind]
        if(not IsExistent(Val[Fld])) then
          return StatusLog(nil,"Sort: Field >"..Fld.."< not found on the current record")
        end
        Match[Cnt].Val = Match[Cnt].Val..tostring(Val[Fld])
        Ind = Ind + 1
      end
    else
      Match[Cnt].Val = Val
    end
    Cnt = Cnt + 1
  end
  local sMethod = tostring(sMethod or "QIK")
  if(sMethod == "QIK") then
    Qsort(Match,1,Cnt-1)
  elseif(sMethod == "SEL") then
    Ssort(Match,1,Cnt-1)
  elseif(sMethod == "BBL") then
    Bsort(Match,1,Cnt-1)
  else
    return StatusLog(nil,"Sort: Method >"..sMethod.."< not found")
  end
  return Match
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

function SQLBuildError(sError)
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
    return SQLBuildError("SQLBuildCreate: Missing: Table name")
  end
  if(not LibTables[sTable]) then
    return SQLBuildError("SQLBuildCreate: Missing: Table definition for "..sTable)
  end
  local defTable = LibTables[sTable]
  if(not defTable.Size) then
    return SQLBuildError("SQLBuildCreate: Missing: Table definition SIZE for "..sTable)
  end
  if(not defTable[1]) then
    return SQLBuildError("SQLBuildCreate: Missing: Table definition is empty for "..sTable)
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    return SQLBuildError("SQLBuildCreate: Missing: Table "..sTable.." field definitions")
  end
  local Ind = 1
  local Command  = {}
  Command.Drop   = "DROP TABLE "..sTable..";"
  Command.Delete = "DELETE FROM "..sTable..";"
  Command.Create = "CREATE TABLE "..sTable.." ( "
  while(defTable[Ind]) do
    local v = defTable[Ind]
    if(not v[1]) then
      return SQLBuildError("SQLBuildCreate: Missing Table "..sTable
                          .."'s field #"..tostring(Ind))
    end
    if(not v[2]) then
      return SQLBuildError("SQLBuildCreate: Missing Table "..sTable
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
        return SQLBuildError("SQLBuildCreate: Index creator mismatch on "
          ..sTable.." value "..vI.." is not a table for index ["..tostring(Ind).."]")
      end
      local FieldsU = ""
      local FieldsC = ""
      Command.Index[Ind] = "CREATE INDEX IND_"..sTable
      Cnt = 1
      while(vI[Cnt]) do
        local vF = vI[Cnt]
        if(type(vF) ~= "number") then
          return SQLBuildError("SQLBuildCreate: Index creator mismatch on "
            ..sTable.." value "..vF.." is not a number for index ["
            ..tostring(Ind).."]["..tostring(Cnt).."]")
        end
        if(not defTable[vF]) then
          return SQLBuildError("SQLBuildCreate: Index creator mismatch on "
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

local function SQLStoreQuery(defTable,tFields,tWhere,tOrderBy,sQuery)
  if(not GetOpVar("EN_QUERY_STORE")) then return sQuery end
  local Val
  local Base
  if(not defTable) then
    return StatusLog(nil,"SQLStoreQuery: Missing: Table definition")
  end
  local tTimer = defTable.Timer
  if(not (tTimer and ((tonumber(tTimer[2]) or 0) > 0))) then
    return StatusLog(sQuery,"SQLStoreQuery: Skipped. Cache persistent forever")
  end
  local Field = 1
  local Where = 1
  local Order = 1
  local CacheKey = GetOpVar("HASH_QUERY_STORE")
  local Cache    = LibCache[CacheKey]
  local namTable = defTable.Name
  if(not IsExistent(Cache)) then
    LibCache[CacheKey] = {}
    Cache = LibCache[CacheKey]
  end
  local Place = Cache[namTable]
  if(not IsExistent(Place)) then
    Cache[namTable] = {}
    Place = Cache[namTable]
  end
  if(tFields) then
    while(tFields[Field]) do
      Val = defTable[tFields[Field]][1]
      if(not IsExistent(Val)) then
        return StatusLog(nil,"SQLStoreQuery: Missing: Field key for #"..tostring(Field))
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
      Field = Field + 1
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
    while(tOrderBy[Order]) do
      Val = tOrderBy[Order]
      if(Place[Val]) then
        Base = Place
        Place = Place[Val]
      elseif(sQuery) then
        Base = Place
        Place[Val] = {}
        Place = Place[Val]
      else
        return StatusLog(nil,"SQLStoreQuery: Missing: Order field key for #"..tostring(Order))
      end
      Order = Order + 1
    end
  end
  if(tWhere) then
    while(tWhere[Where]) do
      Val = defTable[tWhere[Where][1]][1]
      if(not IsExistent(Val)) then
        return StatusLog(nil,"SQLStoreQuery: Missing: Where field key for #"..tostring(Where))
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
      Val = tWhere[Where][2]
      if(not IsExistent(Val)) then
        return StatusLog(nil,"SQLStoreQuery: Missing: Where value key for #"..tostring(Where))
      end
      if(Place[Val]) then
        Base = Place
        Place = Place[Val]
      elseif(sQuery) then
        Base = Place
        Place[Val] = {}
        Place = Place[Val]
      end
      Where = Where + 1
    end
  end
  if(sQuery) then
    Base[Val] = sQuery
  end
  return Base[Val]
end

function SQLBuildSelect(sTable,tFields,tWhere,tOrderBy)
  if(not IsExistent(sTable)) then
    return SQLBuildError("SQLBuildCreate: Missing: Table name")
  end
  if(not LibTables[sTable]) then
    return SQLBuildError("SQLBuildSelect: Missing: Table definition "..sTable)
  end
  local defTable = LibTables[sTable]
  if(not defTable.Size) then
    return SQLBuildError("SQLBuildSelect: Missing: Table definition SIZE in "..sTable)
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    return SQLBuildError("SQLBuildSelect: Missing: Table "..sTable.." field definitions")
  end
  local EnStore = GetOpVar("EN_QUERY_STORE") or false
  if(EnStore) then
    local Q = SQLStoreQuery(sTable,tFields,tWhere,tOrderBy)
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
        return SQLBuildError("SQLBuildSelect: Index #"
          ..tostring(tFields[Cnt])
          .." type mismatch in "..sTable)
      end
      if(defTable[v]) then
        if(defTable[v][1]) then
          Command = Command..defTable[v][1]
        else
          return SQLBuildError("SQLBuildSelect: No such field name by index #"
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
          return SQLBuildError("SQLBuildSelect: Cannot convert string \""..v
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
          return SQLBuildError("SQLBuildSelect: Missing eather "
            ..sTable.." field index, ".."value or type in the table definition")
        end
        if(t == "TEXT" and type(v) == "number") then
          v = tostring(v)
        elseif(t == "INTEGER" and type(v) == "string") then
          local toNB = tonumber(v)
          if(not toNB) then
            return SQLBuildError("SQLBuildSelect: Cannot convert string \""
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
      if(EnStore) then
        return SQLStoreQuery(sTable,tFields,tWhere,tOrderBy,Command..";")
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
        return SQLBuildError("SQLBuildSelect: Wrong Table "..sTable
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
  if(EnStore) then
    return SQLStoreQuery(sTable,tFields,tWhere,tOrderBy,Command..";")
  else
    return Command..";"
  end
end

function SQLBuildInsert(sTable,tInsert,tValues)
  if(not IsExistent(sTable)) then
    return SQLBuildError("SQLBuildCreate: Missing: Table name")
  end
  if(not (LibTables[sTable] and tInsert and tValues)) then
    return SQLBuildError("SQLBuildInsert: Missing Table definition and Chosen fields")
  end
  local defTable = LibTables[sTable]
  if(not (defTable[1] and tInsert[1])) then
    return SQLBuildError("SQLBuildInsert: The table and the chosen fields must not be empty")
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    return SQLBuildError("SQLBuildInsert: Missing: Table "..sTable.." field definition")
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
      return SQLBuildError("SQLBuildInsert: Cannot insert tables into the DB for index #"..Cnt)
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

function InsertRecord(sTable,tData)
  if(not IsExistent(sTable)) then
    return StatusLog(false,"SQLBuildCreate: Missing: Table name/values")
  end
  if(type(sTable) == "table") then
    tData  = sTable
    sTable = GetOpVar("DEFAULT_TABLE")
    if(not (IsExistent(sTable) and sTable ~= "")) then
      return StatusLog(false,"InsertRecord: Missing: Table default name for "..sTable)
    end
  end
  if(not IsString(sTable)) then
    return StatusLog(false,"InsertRecord: Indexing cache failed by "..tostring(sTable).." ("..type(sTable)..")")
  end
  local TableKey = GetOpVar("QTABLE_"..sTable)
  local defTable = LibTables[TableKey]
  if(not (defTable and TableKey)) then
    return StatusLog(false,"InsertRecord: Missing: Table definition for "..sTable)
  end
  if(not defTable.Size) then
    return StatusLog(false,"InsertRecord: Missing: Table definition SIZE for "..sTable)
  end
  if(not defTable[1])  then
    return StatusLog(false,"InsertRecord: Missing: Table definition is empty for "..sTable)
  end
  if(not tData)      then
    return StatusLog(false,"InsertRecord: Missing: Data table for "..sTable)
  end
  if(not tData[1])   then
    return StatusLog(false,"InsertRecord: Missing: Data table is empty for "..sTable)
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
        LogInstance("InsertRecord: Cannot convert string to a number for "
                                   ..tData[Ind].." at field "..FieldDef[1].." ("..Ind..")")
        return false
      end
    elseif(FieldTyp == "number" and FieldDef[2] == "TEXT") then
      tData[Ind] = tostring(tData[Ind])
    else
      LogInstance("InsertRecord: Data type mismatch: "
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
       return StatusLog(false,"InsertRecord: Failed to insert a record because of "
              ..tostring(sql.LastError()).." Query ran > "..Q)
    end
    return true
  end
  return StatusLog(false,"InsertRecord: "..SQLGetBuildErr())
end

function CreateTable(sTable,tIndex,bDelete,bReload)
  if(not IsString(sTable)) then return false end
  local TableKey = GetToolPrefU()..sTable
  local tQ = SQLBuildCreate(TableKey,tIndex)
  if(tQ) then
    if(bDelete and sql.TableExists(TableKey)) then
      local qRez = sql.Query(tQ.Delete)
      if(not qRez and type(qRez) == "boolean") then
        LogInstance("CreateTable: Table "..sTable
          .." is not present. Skipping delete !")
      else
        LogInstance("CreateTable: Table "..sTable.." deleted !")
      end
    end
    if(bReload) then
      local qRez = sql.Query(tQ.Drop)
      if(not qRez and type(qRez) == "boolean") then
        LogInstance("CreateTable: Table "..sTable
          .." is not present. Skipping drop !")
      else
        LogInstance("CreateTable: Table "..sTable.." dropped !")
      end
    end
    if(sql.TableExists(TableKey)) then
      LogInstance("CreateTable: Table "..sTable.." exists!")
      return true
    else
      local qRez = sql.Query(tQ.Create)
      if(not qRez and type(qRez) == "boolean") then
        return StatusLog(false,"CreateTable: Table "..sTable
          .." failed to create because of "..tostring(sql.LastError()))
      end
      if(sql.TableExists(TableKey)) then
        for k, v in pairs(tQ.Index) do
          qRez = sql.Query(v)
          if(not qRez and type(qRez) == "boolean") then
            return StatusLog(false,"CreateTable: Table "..sTable
              .." failed to create index ["..k.."] > "..v .." > because of "
              ..tostring(sql.LastError()))
          end
        end
        LogInstance("CreateTable: Indexed Table "..sTable.." created !")
        return true
      else
        return StatusLog(false,"CreateTable: Table "..sTable
          .." failed to create because of "..tostring(sql.LastError())
          .." Query ran > "..tQ.Create)
      end
    end
  else
    return StatusLog(false,"CreateTable: "..SQLGetBuildErr())
  end
end

--------------------------- AssemblyLib PIECE QUERY -----------------------------

local function NavigateTable(oLocation,tKeys)
  if(not IsExistent(oLocation)) then return StatusLog(nil,"NavigateTable: Location missing") end
  if(not IsExistent(tKeys)) then return StatusLog(nil,"NavigateTable: Key table missing") end
  if(not IsExistent(tKeys[1])) then return StatusLog(nil,"NavigateTable: First key missing") end
  local Cnt = 1
  local Place, Key
  while(tKeys[Cnt]) do
    Key = tKeys[Cnt]
    if(Place) then
      if(tKeys[Cnt+1]) then
        Place = Place[Key]
        if(not IsExistent(Place)) then return StatusLog(nil,"NavigateTable: Key #"..tostring(Key).." irrelevant to location") end
      end
    else
      Place = oLocation[Key]
      if(not IsExistent(Place)) then return StatusLog(nil,"NavigateTable: First key irrelevant to location") end
    end
    Cnt = Cnt + 1
  end
  return Place, Key
end

function TimerSettingMode(sTimerSetting)
  if(not IsExistent(sTimerSetting)) then return StatusLog(nil,"TimerSettingMode: No setting netting") end
  if(not IsString(sTimerSetting)) then return StatusLog(nil,"TimerSettingMode: Setting not a string") end
  local tBoom = StringExplode(sTimerSetting,GetOpVar("OPSYM_REVSIGN"))
  tBoom[1] = tostring(tBoom[1])
  tBoom[2] = (tonumber(tBoom[2])  or 0)
  tBoom[3] = ((tonumber(tBoom[3]) or 0) ~= 0) and true or false
  tBoom[4] = ((tonumber(tBoom[4]) or 0) ~= 0) and true or false
  return tBoom
end

local function AttachKillTimer(oLocation,tKeys,defTable,anyMessage)
  if(not defTable) then return false end
  if(not defTable.Timer) then return false end
  local tTimer = defTable.Timer
  if(not (tTimer and tTimer[1] and tTimer[2])) then return false end
  local nLife = tonumber(tTimer[2]) or 0
  if(nLife <= 0) then return false end
  local sModeDB = GetOpVar("MODE_DATABASE")
  local Place, Key = NavigateTable(oLocation,tKeys)
  if(not (IsExistent(Place) and IsExistent(Key))) then
    return StatusLog(false,"AttachKillTimer: Navigation failed")
  end
  if(sModeDB == "SQL") then
    LogInstance("AttachKillTimer: Place["..tostring(Key).."] Marked !")
    local sModeTM = tostring(tTimer[1] or "CQT")
    local bKillRC = tTimer[3] and true or false
    local bCollGB = tTimer[4] and true or false
    LogInstance("AttachKillTimer: ["..sModeTM.."] ("..tostring(nLife)..") "..tostring(bKillRC)..", "..tostring(bCollGB))
    if(sModeTM == "CQT") then
      Place[Key].Load = Time()
      for k, v in pairs(Place) do
        if(v.Used and v.Load and ((v.Used - v.Load) > nLife)) then
          LogInstance("AttachKillTimer: ("..tostring(v.Used - v.Load).." > "
                                          ..tostring(nLife)..") "
                                          ..tostring(anyMessage).." > Dead")
          if(bKillRC) then
            LogInstance("AttachKillTimer: Killed: Place["..tostring(k).."]")
            Place[k] = nil
          end
        end
      end
      if(bCollGB) then
        collectgarbage()
        LogInstance("AttachKillTimer: Garbage collected")
      end
      return StatusLog(true,"AttachKillTimer: Place["..tostring(Key).."].Load = "..tostring(Place[Key].Load))
    elseif(sModeTM == "OBJ") then
      local TimerID = StringImplode(tKeys,"_")
      LogInstance("AttachKillTimer: TimID: <"..TimerID..">")
      if(not IsExistent(Place[Key])) then return StatusLog(false,"AttachKillTimer: Place not found") end
      if(timer.Exists(TimerID)) then return StatusLog(false,"AttachKillTimer: Timer exists") end
      timer.Create(TimerID, nLife, 1, function()
        LogInstance("AttachKillTimer["..TimerID.."]("..nLife.."): "
                       ..tostring(anyMessage).." > Dead")
        if(bKillRC) then
          LogInstance("AttachKillTimer: Killed: Place["..Key.."]")
          Place[Key] = nil
        end
        timer.Stop(TimerID)
        timer.Destroy(TimerID)
        if(bCollGB) then
          collectgarbage()
          LogInstance("AttachKillTimer: Garbage collected")
        end
      end)
      return timer.Start(TimerID)
    else
      return StatusLog(false,"AttachKillTimer: Timer mode not found: "..sModeTM)
    end
  elseif(sModeDB == "LUA") then
    return StatusLog(true,"AttachKillTimer: Memory manager not available")
  else
    return StatusLog(false,"AttachKillTimer: Wrong database mode")
  end
end

local function RestartTimer(oLocation,tKeys,defTable,anyMessage)
  if(not defTable) then return nil end
  if(not defTable.Timer) then return nil end
  local tTimer = defTable.Timer
  if(not (tTimer and tTimer[1] and tTimer[2])) then return false end
  local nLife = tonumber(tTimer[2]) or 0
  if(nLife <= 0) then return false end
  local sModeDB = GetOpVar("MODE_DATABASE")
  local Place, Key = NavigateTable(oLocation,tKeys)
  if(not (IsExistent(Place) and IsExistent(Key))) then
    return StatusLog(nil,"RestartTimer: Navigation failed")
  end
  if(sModeDB == "SQL") then
    Place[Key].Used = Time()
    local sModeTM = tostring(tTimer[1] or "CQT")
    if(sModeTM == "CQT") then
      sModeTM = "CQT"
    elseif(sModeTM == "OBJ") then
      local TimerID = StringImplode(tKeys,GetOpVar("OPSYM_DIVIDER"))
      if(not timer.Exists(TimerID)) then return StatusLog(nil,"RestartTimer: Timer missing: "..TimerID) end
      timer.Start(TimerID)
    else
      return StatusLog(nil,"RestartTimer: Timer mode not found: "..sModeTM)
    end
  elseif(sModeDB == "LUA") then
    Place[Key].Used = Time()
  else
    return StatusLog(nil,"RestartTimer: Wrong database mode")
  end
  return Place[Key]
end

-- Cashing the selected Piece Result
function CacheQueryPiece(sModel)
  if(not sModel) then return nil end
  if(not IsString(sModel)) then return nil end
  if(sModel == "") then return nil end
  if(not util.IsValidModel(sModel)) then return nil end
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not defTable) then return StatusLog(nil,"CacheQueryPiece: Missing: Table definition") end
  local namTable = defTable.Name
  local Cache    = LibCache[namTable]
  if(not IsExistent(Cache)) then return StatusLog(nil,"CacheQueryPiece: Cache not allocated for "..namTable) end
  local CacheInd = {namTable,sModel}
  local stPiece  = Cache[sModel]
  if(stPiece and IsExistent(stPiece.Kept)) then
    if(stPiece.Kept > 0) then
      return RestartTimer(LibCache,CacheInd,defTable,"CacheQueryPiece")
    end
    return nil
  else
    local sModel  = MatchType(defTable,sModel,1,false,"",true,true)
    local sModeDB = GetOpVar("MODE_DATABASE")
    if(sModeDB == "SQL") then
      LogInstance("CacheQueryPiece: Model >> Pool: "..GetModelFileName(sModel))
      Cache[sModel] = {}
      stPiece = Cache[sModel]
      stPiece.Kept = 0
      local Q = SQLBuildSelect(namTable,nil,{{1,sModel}})
      if(not IsExistent(Q)) then return StatusLog(nil,"CacheQueryPiece: Build error: "..SQLBuildError()) end
      local qData = sql.Query(Q)
      if(not qData and IsBool(qData)) then return StatusLog(nil,"CacheQueryPiece: SQL exec error "..sql.LastError()) end
      if(not (qData and qData[1])) then return StatusLog(nil,"CacheQueryPiece: No data found >"..Q.."<") end
      stPiece.Kept = 1
      stPiece.Type = qRec[defTable[2][1]]
      stPiece.Name = qRec[defTable[3][1]]
      stPiece.Mesh = tonumber(qRec[defTable[4][1]])
      local qRec, qRez
      while(qData[stPiece.Kept]) do
        qRec = qData[stPiece.Kept]
        qRez = RegisterPOA(stPiece,
                           stPiece.Kept,
                           qRec[defTable[5][1]],
                           qRec[defTable[6][1]],
                           qRec[defTable[7][1]])
        if(not IsExistent(qRez)) then
          return StatusLog(nil,"CacheQueryPiece: Cannot process offset #"..tostring(stPiece.Kept).." for "..sModel)
        end
        stPiece.Kept = stPiece.Kept + 1
      end
      stPiece.Kept = stPiece.Kept - 1
      AttachKillTimer(LibCache,CacheInd,defTable,"CacheQueryPiece")
      return stPiece
    elseif(sModeDB == "LUA") then
      return nil -- The whole DB is in the cache
    else
      return StatusLog(nil,"CacheQueryPiece: Wrong database mode >"..sModeDB.."<")
    end
  end
end

----------------------- AssemblyLib PANEL QUERY -------------------------------

--- Used to Populate the CPanel Tree
function CacheQueryPanel()
  local TableKey = GetOpVar("QTABLE_PIECES")
  local CacheKey = GetOpVar("HASH_USER_PANEL")
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

local function GetFieldsName(defTable,sDelim)
  if(not IsExistent(sDelim)) then return "" end
  local sDelim  = string.sub(tostring(sDelim),1,1)
  local sResult = ""
  if(sDelim == "") then
    return StatusLog("","GetFieldsName: Invalid delimiter for "..defTable.Name)
  end
  local iCount  = 1
  local namField 
  while(defTable[iCount]) do
    namField = defTable[iCount][1]
    if(not IsString(namField)) then
      return StatusLog("","GetFieldsName: Invalid field #"..iCount.." for "..defTable.Name)
    end
    sResult = sResult..namField
    if(defTable[iCount + 1]) then sResult = sResult..sDelim end
    iCount = iCount + 1
  end
  return sResult
end

--[[
 * Save/Load the DB Using Excel or
 * anything that supports delimiter
 * separated digital tables
 * sPrefix = Something that separates exported table from the rest ( e.g. db_ )
 * sTable  = Definition KEY to export to
 * sDelim  = Delimiter CHAR data separator
 * bCommit = true to insert the read values
]]--
function ImportFromDSV(sTable,sDelim,bCommit,sPrefix)
  if(not IsString(sTable)) then
    return StatusLog(false,"ImportFromDSV: Table name should be string but "..type(sTable))
  end
  local defTable = GetOpVar("DEFTABLE_"..sTable)
  if(not defTable) then
    return StatusLog(false,"ImportFromDSV: Missing: Table definition for "..sTable)
  end
  local namTable = defTable.Name
  local fName = GetOpVar("DIRPATH_BAS")..GetOpVar("DIRPATH_DSV")
        fName = fName..(sPrefix or GetInstPref())..namTable..".txt"
  local F = file.Open(fName, "r", "DATA")
  if(not F) then return StatusLog(false,"ImportFromDSV: file.Open("..fName..".txt) Failed") end
  local Line = ""
  local TabLen = string.len(namTable)
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
        if(string.sub(Line,1,TabLen) == namTable) then
          local Data = StringExplode(string.sub(Line,TabLen+2,LinLen),sDelim)
          for k,v in pairs(Data) do
            local vLen = string.len(v)
            if(string.sub(v,1,1) == "\"" and string.sub(v,vLen,vLen) == "\"") then
              Data[k] = string.sub(v,2,vLen-1)
            end
          end
          if(bCommit) then
            InsertRecord(sTable,Data)
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

function ExportIntoFile(sTable,sDelim,sMethod,sPrefix)
  if(not IsString(sTable)) then
    return StatusLog(false,"ExportIntoFile: Table name should be string but "..type(sTable))
  end
  if(not IsString(sMethod)) then
    return StatusLog(false,"ExportIntoFile: Export mode should be string but "..type(sTable))
  end
  local defTable = GetOpVar("DEFTABLE_"..sTable)
  if(not defTable) then
    return StatusLog(false,"ExportIntoFile: Missing: Table definition for "..sTable)
  end
  local fName = GetOpVar("DIRPATH_BAS")
  local namTable = defTable.Name
  if(not file.Exists(fName,"DATA")) then file.CreateDir(fName) end
  if(sMethod == "DSV") then
    fName = fName..GetOpVar("DIRPATH_DSV")
  elseif(sMethod == "INS") then
    fName = fName..GetOpVar("DIRPATH_EXP")
  else
    return StatusLog(false,"Missed export method: "..sMethod)
  end  
  if(not file.Exists(fName,"DATA")) then file.CreateDir(fName) end
  fName = fName..(sPrefix or GetInstPref())..namTable..".txt"
  local F = file.Open(fName, "w", "DATA" )
  if(not F) then return StatusLog(false,"ExportIntoFile: file.Open("..fName..") Failed") end
  local sData = ""
  local sTemp = ""
  local sModeDB = GetOpVar("MODE_DATABASE")
  F:Write("# ExportIntoFile( "..sMethod.." ): "..os.date().." [ "..sModeDB.." ]".."\n")
  F:Write("# Data settings: "..GetFieldsName(defTable,sDelim).."\n")
  if(sModeDB == "SQL") then
    local Q = ""
    if(sTable == "PIECES") then
      Q = SQLBuildSelect(defTable,nil,nil,{2,3,1,4})
    else
      Q = SQLBuildSelect(defTable,nil,nil,nil)
    end
    if(not IsExistent(Q)) then return StatusLog(false,"ExportIntoFile: Build error: "..SQLBuildError()) end
    F:Write("# Query ran: >"..Q.."<\n")
    local qData = sql.Query(Q)
    if(not qData and IsBool(qData)) then return StatusLog(nil,"ExportIntoFile: SQL exec error "..sql.LastError()) end
    if(not (qData and qData[1])) then return StatusLog(false,"ExportIntoFile: No data found >"..Q.."<") end
    local iCnt, iInd, qRec = 1, 1, nil
    if(sMethod == "DSV") then
      sData = namTable..sDelim
    elseif(sMethod == "INS") then          
      sData = "  asmlib.InsertRecord(\""..sTable.."\", {"
    end
    while(qData[iCnt]) do
      iInd = 1
      sTemp = sData
      qRec = qData[iCnt]
      while(defTable[iInd]) do
        sTemp = sTemp..MatchType(defTable,qRec[defTable[iInd][1]],iInd,true,"\"",true)
        if(defTable[iInd + 1]) then sTemp = sTemp..sDelim end
        iInd = iInd + 1
      end
      if(sMethod == "DSV") then
        sTemp = sTemp.."\n"
      elseif(sMethod == "INS") then
        sTemp = sTemp.."})\n"
      end
      F:Write(sTemp)
      iCnt = iCnt + 1
    end
  elseif(sModeDB == "LUA") then
    local Cache = LibCache[namTable]
    if(not IsExistent(Cache)) then
      return StatusLog(false,"ExportIntoFile: Table "..namTable.." cache not allocated")
    end
    if(sTable == "PIECES") then   
      local tData = {}
      local iInd iNdex = 1,1
      for sModel, tRecord in pairs(Cache) do
        sData = tRecord.Type..tRecord.Name..sModel
        tData[sModel] = {[defTable[1][1]] = sData}
      end
      local tSorted = Sort(tData,nil,{defTable[1][1]})
      if(not tSorted) then
        return StatusLog(false,"ExportIntoFile: Cannot sort cache data")
      end
      iNdex = 1
      while(tSorted[iNdex]) do
        iInd = 1
        tData = Cache[tSorted[iNdex].Key]
        if(sMethod == "DSV") then
          sData = namTable..sDelim
        elseif(sMethod == "INS") then          
          sData = "  asmlib.InsertRecord(\""..sTable.."\", {"
        end
        sData = sData..MatchType(defTable,tSorted[iNdex].Key,1,true,"\"")..sDelim..
                       MatchType(defTable,tData.Type,2,true,"\"")..sDelim..
                       MatchType(defTable,tData.Name,3,true,"\"")..sDelim

        while(tData.Offs[iInd]) do
            sTemp = sData..MatchType(defTable,tostring(iInd),4,true,"\"")..sDelim..
                          "\""..StringPOA(tData.Offs,iInd,"P").."\""..sDelim..
                          "\""..StringPOA(tData.Offs,iInd,"O").."\""..sDelim..
                          "\""..StringPOA(tData.Offs,iInd,"A").."\""
          if(sMethod == "DSV") then
            sTemp = sTemp.."\n"
          elseif(sMethod == "INS") then
            sTemp = sTemp.."})\n"
          end
          F:Write(sTemp)         
          iInd = iInd  + 1
        end
        iNdex = iNdex + 1
      end
    end
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

local function GetEntityOrTrace(oEnt)
  if(oEnt and oEnt:IsValid()) then return oEnt end
  local Ply = LocalPlayer()
  if(not Ply) then return nil end
  local Trace = Ply:GetEyeTrace()
  if(not Trace) then return nil end
  if(not Trace.Hit) then return nil end
  if(Trace.HitWorld) then return nil end
  if(not (Trace.Entity and Trace.Entity:IsValid())) then return nil end
  return Trace.Entity
end

function GetPropSkin(oEnt)
  local skEnt = GetEntityOrTrace(oEnt)
  if(not skEnt) then return StatusLog("","GetPropSkin: Failed to gather entity") end
  LogInstance("GetPropSkin: "..tostring(skEn))
  if(IsOther(skEnt)) then return StatusLog("","GetPropSkin: Entity is of other type") end
  local Skin = skEnt:GetSkin()
  if(not tonumber(Skin)) then return StatusLog("","GetPropSkin: Skin is not a number") end
  return tostring(Skin)
end

function GetPropBodyGrp(oEnt)
  local bgEnt = GetEntityOrTrace(oEnt)
  if(not bgEnt) then return StatusLog("","GetPropBodyGrp: Failed to gather entity") end
  LogInstance("GetPropBodyGrp: "..tostring(bgEnt))
  if(IsOther(bgEnt)) then return StatusLog("","GetPropBodyGrp: Entity is of other type") end
  local BG = bgEnt:GetBodyGroups()
  if(not (BG and BG[1])) then return StatusLog("","GetPropBodyGrp: Bodygroup table empty") end
  Print(BG,"GetPropBodyGrp: BG")
  local Rez = ""
  local Cnt = 1
  while(BG[Cnt]) do
    Rez = Rez..","..tostring(bgEnt:GetBodygroup(BG[Cnt].id) or 0)
    Cnt = Cnt + 1
  end
  return string.sub(Rez,2,string.len(Rez))
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
        local ConstrDB = GetOpVar("CONTAIN_CONSTRAINT_TYPE")
        local ConID    = tonumber(nID      ) or 1
        local Freeze   = tonumber(nFreeze  ) or 0
        local Gravity  = tonumber(nGrav    ) or 0
        local NoCollid = tonumber(nNoCollid) or 0
        local ForceLim = tonumber(nForceLim) or 0
        local NoPhyGun = tonumber(nNoPhyGun) or 0
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
        if(Freeze == 0) then
          pyPiece:EnableMotion(true)
        end
        if(Gravity == 0) then
          construct.SetPhysProp(nil,ePiece,0,pyPiece,{GravityToggle = false})
        end
        if(NoPhyGun ~= 0) then --  is my custom child ...
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
      ePiece.SetMapBoundPos = function(ePiece,vPos,oPly,nBndErrMode,anyMessage)
        local Message = tostring(anyMessage)
        if(not vPos) then
          return StatusLog(true,"ePiece:SetMapBoundPos() Position invalid: \n"..Message)
        end
        if(not oPly) then
          return StatusLog(true,"ePiece:SetMapBoundPos() Player invalid: \n"..Message)
        end
        local BndErrMode = (tonumber(nBndErrMode) or 0)
        if(BndErrMode == 0) then
          ePiece:SetPos(vPos)
          return false
        elseif(BndErrMode == 1) then
          if(util.IsInWorld(vPos)) then
            ePiece:SetPos(vPos)
          else
            ePiece:Remove()
            return StatusLog(true,"ePiece:SetMapBoundPos("..BndErrMode..") Position out of map bounds: \n"..anyMessage)
          end
          return false
        elseif(BndErrMode == 2) then
          if(util.IsInWorld(vPos)) then
            ePiece:SetPos(vPos)
          else
            ePiece:Remove()
            PrintNotify(oPly,"Position out of map bounds!","HINT")
            return StatusLog(true,"ePiece:SetMapBoundPos("..BndErrMode..") Position out of map bounds: \n"..anyMessage)
          end
          return false
        elseif(BndErrMode == 3) then
          if(util.IsInWorld(vPos)) then
            ePiece:SetPos(vPos)
          else
            ePiece:Remove()
            PrintNotify(oPly,"Position out of map bounds!","GENERIC")
            return StatusLog(true,"ePiece:SetMapBoundPos("..BndErrMode..") Position out of map bounds: \n"..anyMessage)
          end
          return false
        elseif(BndErrMode == 4) then
          if(util.IsInWorld(vPos)) then
            ePiece:SetPos(vPos)
          else
            ePiece:Remove()
            PrintNotify(oPly,"Position out of map bounds!","ERROR")
            return StatusLog(true,"ePiece:SetMapBoundPos("..BndErrMode..") Position out of map bounds: \n"..anyMessage)
          end
          return false
        end
        return StatusLog(true,"ePiece:SetMapBoundPos() Mode #"..BndErrMode.." not found: \n"..Message)
      end
      return ePiece
    end
    ePiece:Remove()
    return nil
  end
  return nil
end

function MakeCoVar(sShortName, sValue, tBorder, nFlags, sInfo)
  if(not IsString(sShortName)) then return StatusLog(nil,"MakeCoVar("..tostring(sShortName).."): Wrong CVar name") end
  if(not IsExistent(sValue)) then return StatusLog(nil,"MakeCoVar("..tostring(sValue).."): Wrong default value") end
  if(not IsString(sInfo)) then return StatusLog(nil,"MakeCoVar("..tostring(sInfo).."): Wrong CVar information") end
  local sVar = GetOpVar("TOOLNAME_PL")..string.lower(sShortName)
  if(tBorder and (type(tBorder) == "table") and tBorder[1] and tBorder[2]) then
    local Border = GetOpVar("TABLE_BORDERS")
    Border["cvar_"..sVar] = tBorder
  end
  return CreateConVar(sVar, sValue, nFlags, sInfo)
end

function GetCoVar(sShortName, sMode)
  if(not IsString(sShortName)) then return StatusLog(nil,"GetCoVar("..tostring(sShortName).."): Wrong CVar name") end
  if(not IsString(sMode)) then return StatusLog(nil,"GetCoVar("..tostring(sMode).."): Wrong CVar mode") end
  local sVar = GetOpVar("TOOLNAME_PL")..string.lower(sShortName)
  local CVar = GetConVar(sVar)
  if(not IsExistent(CVar)) then return StatusLog(nil,"GetCoVar("..sShortName..", "..sMode.."): Missing CVar object") end
  if    (sMode == "INT") then
    return (tonumber(BorderValue(CVar:GetInt(),"cvar_"..sVar)) or 0)
  elseif(sMode == "FLT") then
    return (tonumber(BorderValue(CVar:GetFloat(),"cvar_"..sVar)) or 0)
  elseif(sMode == "STR") then
    return tostring(CVar:GetString() or "")
  elseif(sMode == "BUL") then
    return (CVar:GetBool() or false)
  elseif(sMode == "DEF") then
    return CVar:GetDefault()
  elseif(sMode == "INF") then
    return CVar:GetHelpText()
  elseif(sMode == "NAM") then
    return CVar:GetName()
  end
  return StatusLog(nil,"GetCoVar("..sShortName..", "..sMode.."): Missed mode")
end
