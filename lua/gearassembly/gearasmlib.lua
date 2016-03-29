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
local csA -- Sign of the first component
local csB -- Sign of the second component
local csC -- Sign of the third component
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
local SOLID_VPHYSICS        = SOLID_VPHYSICS
local MOVETYPE_VPHYSICS     = MOVETYPE_VPHYSICS
local COLLISION_GROUP_NONE  = COLLISION_GROUP_NONE
local RENDERMODE_TRANSALPHA = RENDERMODE_TRANSALPHA

---------------- Localizing needed functions ----------------
local next                  = next
local type                  = type
local Angle                 = Angle
local Color                 = Color
local pairs                 = pairs
local print                 = print
local tobool                = tobool
local Vector                = Vector
local include               = include
local IsValid               = IsValid
local require               = require
local Time                  = SysTime
local tonumber              = tonumber
local tostring              = tostring
local GetConVar             = GetConVar
local LocalPlayer           = LocalPlayer
local CreateConVar          = CreateConVar
local getmetatable          = getmetatable
local setmetatable          = setmetatable
local collectgarbage        = collectgarbage
local osClock               = os and os.clock
local osDate                = os and os.date
local sqlQuery              = sql and sql.Query
local sqlLastError          = sql and sql.LastError
local sqlTableExists        = sql and sql.TableExists
local utilTraceLine         = util and util.TraceLine
local utilIsInWorld         = util and util.IsInWorld
local utilIsValidModel      = util and util.IsValidModel
local utilGetPlayerTrace    = util and util.GetPlayerTrace
local entsCreate            = ents and ents.Create
local fileOpen              = file and file.Open
local fileExists            = file and file.Exists
local fileAppend            = file and file.Append
local fileDelete            = file and file.Delete
local fileCreateDir         = file and file.CreateDir
local mathAbs               = math and math.abs
local mathCeil              = math and math.ceil
local mathModf              = math and math.modf
local mathSqrt              = math and math.sqrt
local mathFloor             = math and math.floor
local mathClamp             = math and math.Clamp
local mathRandom            = math and math.random
local undoCreate            = undo and undo.Create
local undoFinish            = undo and undo.Finish
local undoAddEntity         = undo and undo.AddEntity
local undoSetPlayer         = undo and undo.SetPlayer
local undoSetCustomUndoText = undo and undo.SetCustomUndoText
local timerStop             = timer and timer.Stop
local timerStart            = timer and timer.Start
local timerExists           = timer and timer.Exists
local timerCreate           = timer and timer.Create
local timerDestroy          = timer and timer.Destroy
local tableEmpty            = table and table.Empty
local tableMaxn             = table and table.maxn
local stringLen             = string and string.len
local stringSub             = string and string.sub
local stringFind            = string and string.find
local stringGsub            = string and string.gsub
local stringUpper           = string and string.upper
local stringLower           = string and string.lower
local stringFormat          = string and string.format
local stringExplode         = string and string.Explode
local stringImplode         = string and string.Implode
local stringToFileName      = string and string.GetFileFromFilename
local surfaceSetFont        = surface and surface.SetFont
local surfaceDrawLine       = surface and surface.DrawLine
local surfaceDrawText       = surface and surface.DrawText
local surfaceDrawCircle     = surface and surface.DrawCircle
local surfaceSetTexture     = surface and surface.SetTexture
local surfaceSetTextPos     = surface and surface.SetTextPos
local surfaceGetTextSize    = surface and surface.GetTextSize
local surfaceGetTextureID   = surface and surface.GetTextureID
local surfaceSetDrawColor   = surface and surface.SetDrawColor
local surfaceSetTextColor   = surface and surface.SetTextColor
local constructSetPhysProp  = construct and construct.SetPhysProp
local constraintWeld        = constraint and constraint.Weld
local constraintNoCollide   = constraint and constraint.NoCollide
local surfaceDrawTexturedRect = surface and surface.DrawTexturedRect
local duplicatorStoreEntityModifier = duplicator and duplicator.StoreEntityModifier

---------------- CASHES SPACE --------------------

local libCache  = {} -- Used to cache stuff in a Pool
local libAction = {} -- Used to attach external function to the lib
local libOpVars = {} -- Used to Store operational Variable Values

module( "gearasmlib" )

---------------------------- COMMON ----------------------------

function Delay(nAdd)
  local nAdd = tonumber(nAdd) or 0
  if(nAdd > 0) then
    local tmEnd = osClock() + nAdd
    while(osClock() < tmEnd) do end
  end
end

function GetIndexes(sType)
  if    (sType == "V") then return cvX, cvY, cvZ
  elseif(sType == "A") then return caP, caY, caR
  elseif(sType == "S") then return csA, csB, csC, csD end
  return nil
end

function SetIndexes(sType,I1,I2,I3,I4)
  if    (sType == "V") then cvX, cvY, cvZ      = I1, I2, I3
  elseif(sType == "A") then caP, caY, caR      = I1, I2, I3
  elseif(sType == "S") then csA, csB, csC, csD = I1, I2, I3, I4 end
  return nil
end

function GetInstPref()
  if    (CLIENT) then return "cl_"
  elseif(SERVER) then return "sv_" end
  return "na_"
end

function GetOpVar(sName)
  return libOpVars[sName]
end

function SetOpVar(sName, anyValue)
  libOpVars[sName] = anyValue
end

function IsExistent(anyValue)
  return (anyValue ~= nil)
end

function IsString(anyValue)
  return (getmetatable(anyValue) == GetOpVar("TYPEMT_STRING"))
end

local function IsEmptyString(anyValue)
  if(not IsString(anyValue)) then return false end
  return (anyValue == "")
end

function IsBool(anyValue)
  if    (anyValue == true ) then return true
  elseif(anyValue == false) then return true end
  return false
end

function IsNumber(anyValue)
  return ((tonumber(anyValue) and true) or false)
end

------------------ LOGS ------------------------

local function FormatNumberMax(nNum,nMax)
  local nNum = tonumber(nNum)
  local nMax = tonumber(nMax)
  if(not (nNum and nMax)) then return "" end
  return stringFormat("%"..stringLen(tostring(mathFloor(nMax))).."d",nNum)
end

function SetLogControl(nLines,sFile)
  SetOpVar("LOG_LOGFILE",tostring(sFile) or "")
  SetOpVar("LOG_MAXLOGS",tonumber(nLines) or 0)
  SetOpVar("LOG_CURLOGS",0)
  if(not fileExists(GetOpVar("DIRPATH_BAS"),"DATA") and
     not IsEmptyString(GetOpVar("LOG_LOGFILE"))) then
    fileCreateDir(GetOpVar("DIRPATH_BAS"))
  end
end

local function Log(anyStuff)
  local nMaxLogs = GetOpVar("LOG_MAXLOGS")
  if(nMaxLogs <= 0) then return end
  local sLogFile = GetOpVar("LOG_LOGFILE")
  local nCurLogs = GetOpVar("LOG_CURLOGS")
  if(sLogFile ~= "") then
    local fName = GetOpVar("DIRPATH_BAS")..GetOpVar("DIRPATH_LOG")..sLogFile..".txt"
    fileAppend(fName,FormatNumberMax(nCurLogs,nMaxLogs).." >> "..tostring(anyStuff).."\n")
    nCurLogs = nCurLogs + 1
    if(nCurLogs > nMaxLogs) then
      fileDelete(fName)
      nCurLogs = 0
    end
    SetOpVar("LOG_CURLOGS",nCurLogs)
  else
    print(FormatNumberMax(nCurLogs,nMaxLogs).." >> "..tostring(anyStuff))
    nCurLogs = nCurLogs + 1
    if(nCurLogs > nMaxLogs) then
      nCurLogs = 0
    end
    SetOpVar("LOG_CURLOGS",nCurLogs)
  end
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

function LogInstance(anyStuff)
  if(GetOpVar("LOG_MAXLOGS") <= 0) then return end
  local anyStuff = tostring(anyStuff)
  local logStats = GetOpVar("LOG_SKIP")
  if(logStats and logStats[1]) then
    local iNdex = 1
    while(logStats[iNdex]) do
      if(stringFind(anyStuff,tostring(logStats[iNdex]))) then return end
      iNdex = iNdex + 1
    end
  end -- Should the current log being skipped
  logStats = GetOpVar("LOG_ONLY")
  if(logStats and logStats[1]) then
    local iNdex = 1
    local logMe = false
    while(logStats[iNdex]) do
      if(stringFind(anyStuff,tostring(logStats[iNdex]))) then
        logMe = true
      end
      iNdex = iNdex + 1
    end
    if(not logMe) then return end
  end -- Only the chosen messages are processed
  local sModeDB  = GetOpVar("MODE_DATABASE")
  if(SERVER) then
    Log("SERVER > "..GetOpVar("TOOLNAME_NU").." ["..sModeDB.."] "..anyStuff)
  elseif(CLIENT) then
    Log("CLIENT > "..GetOpVar("TOOLNAME_NU").." ["..sModeDB.."] "..anyStuff)
  else
    Log("NOINST > "..GetOpVar("TOOLNAME_NU").." ["..sModeDB.."] "..anyStuff)
  end
end

function StatusPrint(anyStatus,sError)
  PrintInstance(sError)
  return anyStatus
end

function StatusLog(anyStatus,sError)
  LogInstance(sError)
  return anyStatus
end

function Print(tT,sS)
  if(not IsExistent(tT)) then
    return StatusLog(nil,"Print: {nil, name="..tostring(sS or "\"Data\"").."}") end
  local S = type(sS)
  local T = type(tT)
  local Key = ""
  if    (S == "string") then S = sS
  elseif(S == "number") then S = tostring(sS)
  else                       S = "Data" end
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

----------------- INITAIALIZATION -----------------

function InitAssembly(sName,sPurpose)
  SetOpVar("TYPEMT_STRING",getmetatable("TYPEMT_STRING"))
  SetOpVar("TYPEMT_SCREEN",{})
  SetOpVar("TYPEMT_CONTAINER",{})
  if(not (IsString(sName) and IsString(sPurpose))) then
    return StatusPrint(false,"InitAssembly: Expecting string argument"
             .." {"..type(sName)..","..type(sPurpose).."}") end
  if(IsEmptyString(sName) or tonumber(stringSub(sName,1,1))) then
    return StatusPrint(false,"InitAssembly: Name invalid") end
  if(IsEmptyString(sPurpose) or tonumber(stringSub(sPurpose,1,1))) then
    return StatusPrint(false,"InitAssembly: Purpose invalid") end
  SetOpVar("TIME_EPOCH",Time())
  SetOpVar("NAME_INIT",stringLower(sName))
  SetOpVar("NAME_PERP",stringLower(sPurpose))
  SetOpVar("TOOLNAME_NL",stringLower(GetOpVar("NAME_INIT")..GetOpVar("NAME_PERP")))
  SetOpVar("TOOLNAME_NU",stringUpper(GetOpVar("NAME_INIT")..GetOpVar("NAME_PERP")))
  SetOpVar("TOOLNAME_PL",GetOpVar("TOOLNAME_NL").."_")
  SetOpVar("TOOLNAME_PU",GetOpVar("TOOLNAME_NU").."_")
  SetOpVar("MISS_NOID","N")    -- No ID selected
  SetOpVar("MISS_NOAV","N/A")  -- Not Available
  SetOpVar("MISS_NOMD","X")    -- No model
  SetOpVar("ARRAY_DECODEPOA",{0,0,0,1,1,1,false})
  SetOpVar("TABLE_FREQUENT_MODELS",{})
  SetOpVar("TABLE_BORDERS",{})
  SetOpVar("FILE_MODEL","%.mdl")
  SetOpVar("MODE_DATABASE",GetOpVar("MISS_NOAV"))
  SetOpVar("HASH_USER_PANEL",GetOpVar("TOOLNAME_PU").."USER_PANEL")
  SetOpVar("HASH_QUERY_STORE",GetOpVar("TOOLNAME_PU").."QHASH_QUERY")
  SetOpVar("HASH_PLAYER_KEYDOWN","PLAYER_KEYDOWN")
  SetOpVar("HASH_PROPERTY_NAMES","PROPERTY_NAMES")
  SetOpVar("HASH_PROPERTY_TYPES","PROPERTY_TYPES")
  SetOpVar("ANG_ZERO",Angle())
  SetOpVar("VEC_ZERO",Vector())
  SetOpVar("OPSYM_DISABLE","#")
  SetOpVar("OPSYM_REVSIGN","@")
  SetOpVar("OPSYM_DIVIDER","_")
  SetOpVar("OPSYM_DIRECTORY","/")
  SetOpVar("OPSYM_SEPARATOR",",")
  SetOpVar("SPAWN_ENTITY",{
    F    = Vector(),
    R    = Vector(),
    U    = Vector(),
    OPos = Vector(),
    OAng = Angle (),
    SPos = Vector(),
    SAng = Angle (),
    MPos = Vector(),
    MAng = Angle (),
    CPos = Vector(),
    CAng = Angle (),
    DPos = Vector(),
    DAng = Angle (),
    HRec = 0,
    TRec = 0
  })
  return StatusPrint(true,"InitAssembly: Success")
end

------------- ANGLE ---------------
function ToAngle(aBase)
  return Angle((aBase[caP] or 0), (aBase[caY] or 0), (aBase[caR] or 0))
end

function ExpAngle(aBase)
  return (aBase[caP] or 0), (aBase[caY] or 0), (aBase[caR] or 0)
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
  return Vector((vBase[cvX] or 0), (vBase[cvY] or 0), (vBase[cvZ] or 0))
end

function ExpVector(vBase)
  return (vBase[cvX] or 0), (vBase[cvY] or 0), (vBase[cvZ] or 0)
end

function GetLengthVector(vdbBase)
  local X = (vdbBase[cvX] or 0); X = X * X
  local Y = (vdbBase[cvY] or 0); Y = Y * Y
  local Z = (vdbBase[cvZ] or 0); Z = Z * Z
  return mathSqrt(X+Y+Z)
end

function RoundVector(vBase,nRound)
  local X = vBase[cvX] or 0; X = RoundValue(X,nRound or 0.1); vBase[cvX] = X
  local Y = vBase[cvY] or 0; Y = RoundValue(Y,nRound or 0.1); vBase[cvY] = Y
  local Z = vBase[cvZ] or 0; Z = RoundValue(Z,nRound or 0.1); vBase[cvZ] = Z
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
  if(not ( V and A ) ) then return Vector() end
  return Vector(V:DotProduct(A:Forward()), V:DotProduct(A:Right()), V:DotProduct(A:Up()))
end

---------- OOP -----------------

function MakeContainer(sInfo,sDefKey)
  local Curs = 0
  local Data = {}
  local Sel, Ins, Del, Met = "", "", "", ""
  local Info = tostring(sInfo or "Store Container")
  local Key  = sDefKey or "(!_+*#-$@DEFKEY@$-#*+_!)"
  local self = {}
  function self:GetInfo() return Info end
  function self:GetSize() return Curs end
  function self:GetData() return Data end
  function self:Insert(nsKey,anyValue)
    Ins = nsKey or Key
    Met = "I"
    if(not IsExistent(Data[Ins])) then
      Curs = Curs + 1
    end
    Data[Ins] = anyValue
  end
  function self:Select(nsKey)
    Sel = nsKey or Key
    return Data[Sel]
  end
  function self:Delete(nsKey,fnDel)
    Del = nsKey or Key
    Met = "D"
    if(IsExistent(Data[Del])) then
      if(IsExistent(fnDel)) then
        fnDel(Data[Del])
      end
      Data[Del] = nil
      Curs = Curs - 1
    end
  end
  function self:GetHistory()
    return tostring(Met)..GetOpVar("OPSYM_REVSIGN")..
           tostring(Sel)..GetOpVar("OPSYM_DIRECTORY")..
           tostring(Ins)..GetOpVar("OPSYM_DIRECTORY")..
           tostring(Del)
  end
  setmetatable(self,GetOpVar("TYPEMT_CONTAINER"))
  return self
end

function MakeScreen(sW,sH,eW,eH,conPalette)
  if(SERVER) then return nil end
  local sW, sH = (tonumber(sW) or 0), (tonumber(sH) or 0)
  local eW, eH = (tonumber(eW) or 0), (tonumber(eH) or 0)
  if(eW <= 0 or eH <= 0) then return nil end
  if(type(conPalette) ~= "table") then return nil end
  local White  = Color(255,255,255,255)
  local Palette
  local ColorKey
  local Text = {}
        Text.Font = "Trebuchet18"
        Text.DrawX = 0
        Text.DrawY = 0
        Text.ScrW  = 0
        Text.ScrH  = 0
        Text.LastW = 0
        Text.LastH = 0
  if(getmetatable(conPalette) == GetOpVar("TYPEMT_CONTAINER")) then
    Palette = conPalette
  end
  local Texture = {}
        Texture.Path = "vgui/white"
        Texture.ID   = surfaceGetTextureID(Texture.Path)
  local self = {}
  function self:GetSize() return (eW-sW), (eH-sH) end
  function self:GetCenter(nX,nY)
    local w, h = self:GetSize()
    w = (w / 2) + (tonumber(nX) or 0)
    h = (h / 2) + (tonumber(nY) or 0)
    return w, h
  end
  function self:SetColor(sColor)
    if(not sColor) then return end
    if(Palette) then
      local Colour = Palette:Select(sColor)
      if(Colour) then
        surfaceSetDrawColor(Colour.r, Colour.g, Colour.b, Colour.a)
        surfaceSetTextColor(Colour.r, Colour.g, Colour.b, Colour.a)
        ColorKey = sColor
      end
    else
      surfaceSetDrawColor(White.r,White.g,White.b,White.a)
      surfaceSetTextColor(White.r,White.g,White.b,White.a)
    end
  end
  function self:SetTexture(sTexture)
    if(not IsString(sTexture)) then return end
    if(IsEmptyString(sTexture)) then return end
    Texture.Path = sTexture
    Texture.ID   = surfaceGetTextureID(Texture.Path)
  end
  function self:GetTexture() return Texture.ID, Texture.Path end
  function self:DrawBackGround(sColor)
    self:SetColor(sColor)
    surfaceSetTexture(Texture.ID)
    surfaceDrawTexturedRect(sW,sH,eW-sW,eH-sH)
  end
  function self:DrawRect(nX,nY,nW,nH,sColor)
    self:SetColor(sColor)
    surfaceSetTexture(Texture.ID)
    surfaceDrawTexturedRect(nX,nY,nW,nH)
  end
  function self:SetTextEdge(nX,nY)
    Text.DrawX = (tonumber(nX) or 0)
    Text.DrawY = (tonumber(nY) or 0)
    Text.ScrW  = 0
    Text.ScrH  = 0
    Text.LastW = 0
    Text.LastH = 0
  end
  function self:SetFont(sFont)
    if(not IsString(sFont)) then return end
    Text.Font = sFont or "Trebuchet18"
    surfaceSetFont(Text.Font)
  end
  function self:GetTextState(nX,nY,nW,nH)
    return (Text.DrawX + (nX or 0)), (Text.DrawY + (nY or 0)),
           (Text.ScrW  + (nW or 0)), (Text.ScrH  + (nH or 0)),
            Text.LastW, Text.LastH
  end
  function self:DrawText(sText,sColor)
    surfaceSetTextPos(Text.DrawX,Text.DrawY)
    self:SetColor(sColor)
    surfaceDrawText(sText)
    Text.LastW, Text.LastH = surfaceGetTextSize(sText)
    Text.DrawY = Text.DrawY + Text.LastH
    if(Text.LastW > Text.ScrW) then
      Text.ScrW = Text.LastW
    end
    Text.ScrH = Text.DrawY
  end
  function self:DrawTextAdd(sText,sColor)
    surfaceSetTextPos(Text.DrawX + Text.LastW,Text.DrawY - Text.LastH)
    self:SetColor(sColor)
    surfaceDrawText(sText)
    local LastW, LastH = surfaceGetTextSize(sText)
    Text.LastW = Text.LastW + LastW
    Text.LastH = LastH
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
          surfaceDrawCircle( xyPos.x, xyPos.y, nRad, Colour)
          ColorKey = sColor
          return
        end
      else
        if(IsExistent(ColorKey)) then
          local Colour = Palette:Select(ColorKey)
          surfaceDrawCircle( xyPos.x, xyPos.y, nRad, Colour)
          return
        end
      end
      return
    else
      surfaceDrawCircle( xyPos.x, xyPos.y, nRad, White)
    end
  end
  function self:Enclose(xyPnt)
    if(xyPnt.x < sW) then return -1 end
    if(xyPnt.x > eW) then return -1 end
    if(xyPnt.y < sH) then return -1 end
    if(xyPnt.y > eH) then return -1 end
    return 1
  end
  function self:DrawLine(xyS,xyE,sColor)
    if(not (xyS and xyE)) then return end
    if(not (xyS.x and xyS.y and xyE.x and xyE.y)) then return end
    self:SetColor(sColor)
    if(self:Enclose(xyS) == -1 or self:Enclose(xyE) == -1) then return end
    surfaceDrawLine(xyS.x,xyS.y,xyE.x,xyE.y)
  end
  setmetatable(self,GetOpVar("TYPEMT_SCREEN"))
  return self
end

function SetAction(sKey,fAct,tDat)
  if(not (sKey and IsString(sKey))) then return false end
  if(not (fAct and type(fAct) == "function")) then return false end
  if(not libAction[sKey]) then
    libAction[sKey] = {}
  end
  libAction[sKey].Act = fAct
  libAction[sKey].Dat = tDat
  return true
end

function GetActionCode(sKey)
  if(not (sKey and IsString(sKey))) then return StatusLog(nil,"GetActionCode: ") end
  if(not (libAction and libAction[sKey])) then return nil end
  return libAction[sKey].Act
end

function GetActionData(sKey)
  if(not (sKey and IsString(sKey))) then return nil end
  if(not (libAction and libAction[sKey])) then return nil end
  return libAction[sKey].Dat
end

function CallAction(sKey,A1,A2,A3,A4)
  if(not (sKey and IsString(sKey))) then return false end
  if(not (libAction and libAction[sKey])) then return false end
  return libAction[sKey].Act(A1,A2,A3,A4,libAction[sKey].Dat)
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

local function AddLineListView(pnListView,frUsed,ivNdex)
  if(not IsExistent(pnListView)) then
    return StatusLog(nil,"LineAddListView: Missing panel") end
  if(not IsValid(pnListView)) then
    return StatusLog(nil,"LineAddListView: Invalid panel") end
  if(not IsExistent(frUsed)) then
    return StatusLog(nil,"LineAddListView: Missing data") end
  local iNdex = tonumber(ivNdex)
  if(not IsExistent(iNdex)) then
    return StatusLog(nil,"LineAddListView: Index NAN {"..type(ivNdex).."}<"..tostring(ivNdex)..">") end
  local tValue = frUsed[iNdex]
  if(not IsExistent(tValue)) then
    return StatusLog(nil,"LineAddListView: Missing data on index #"..tostring(iNdex)) end
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not IsExistent(defTable)) then
    return StatusLog(nil,"LineAddListView: Missing table definition") end
  local sModel = tValue.Table[defTable[1][1]]
  local sType  = tValue.Table[defTable[2][1]]
  local nAct   = tValue.Table[defTable[4][1]]
  local nUsed  = RoundValue(tValue.Value,0.001)
  local pnRec  = pnListView:AddLine(nUsed,nAct,sType,sModel)
  if(not IsExistent(pnRec)) then
    return StatusLog(nil,"LineAddListView: Failed to create a ListView line for <"..sModel.."> #"..tostring(iNdex)) end
  return pnRec, tValue
end

--[[
 * Updates a VGUI pnListView with a search preformed in the already generated
 * frequently used pieces "frUsed" for the pattern "sPattern" given by the user
 * and a field name selected "sField".
 * On success populates "pnListView" with the search preformed
 * On fail a parameter is not valid or missing and returns non-success
]]--
function UpdateListView(pnListView,frUsed,nCount,sField,sPattern)
  if(not (IsExistent(frUsed) and IsExistent(frUsed[1]))) then
    return StatusLog(false,"UpdateListView: Missing data") end
  local nCount = tonumber(nCount) or 0
  if(nCount <= 0) then
    return StatusLog(false,"UpdateListView: Count not applicable") end
  if(IsExistent(pnListView)) then
    if(not IsValid(pnListView)) then
      return StatusLog(false,"UpdateListView: Invalid ListView") end
    pnListView:SetVisible(false)
    pnListView:Clear()
  else
    return StatusLog(false,"UpdateListView: Missing ListView")
  end
  local sField   = tostring(sField   or "")
  local sPattern = tostring(sPattern or "")
  local iNdex, pnRec, sData = 1, nil, nil
  while(frUsed[iNdex]) do
    if(IsEmptyString(sPattern)) then
      pnRec = AddLineListView(pnListView,frUsed,iNdex)
      if(not IsExistent(pnRec)) then
        return StatusLog(false,"UpdateListView: Failed to add line on #"..tostring(iNdex)) end
    else
      sData = tostring(frUsed[iNdex].Table[sField] or "")
      if(stringFind(sData,sPattern)) then
        pnRec = AddLineListView(pnListView,frUsed,iNdex)
        if(not IsExistent(pnRec)) then
          return StatusLog(false,"UpdateListView: Failed to add line <"
                   ..sData.."> pattern <"..sPattern.."> on <"..sField.."> #"..tostring(iNdex)) end
      end
    end
    iNdex = iNdex + 1
  end
  pnListView:SetVisible(true)
  return StatusLog(true,"UpdateListView: Crated #"..tostring(iNdex-1))
end

local function PushSortValues(tTable,snCnt,nsValue,tData)
  local Cnt = mathFloor(tonumber(snCnt) or 0)
  if(not (tTable and (type(tTable) == "table") and (Cnt > 0))) then return 0 end
  local Ind  = 1
  if(not tTable[Ind]) then
    tTable[Ind] = {Value = nsValue, Table = tData }
    return Ind
  else
    while(tTable[Ind] and (tTable[Ind].Value < nsValue)) do
      Ind = Ind + 1
    end
    if(Ind > Cnt) then return Ind end
    while(Ind < Cnt) do
      tTable[Cnt] = tTable[Cnt - 1]
      Cnt = Cnt - 1
    end
    tTable[Ind] = { Value = nsValue, Table = tData }
    return Ind
  end
end

function GetFrequentModels(snCount)
  local snCount = tonumber(snCount) or 0
  if(snCount < 1) then
    return StatusLog(nil,"GetFrequentModels: Count not applicable") end
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not IsExistent(defTable)) then
    return StatusLog(nil,"GetFrequentModels: Missing table definition") end
  local Cache = libCache[defTable.Name]
  if(not IsExistent(Cache)) then
    return StatusLog(nil,"GetFrequentModels: Missing table cache space") end
  local iInd, tmNow = 1, Time()
  local frUsed = GetOpVar("TABLE_FREQUENT_MODELS")
  tableEmpty(frUsed)
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

function RoundValue(nvExact, nFrac)
  local nExact = tonumber(nvExact)
  if(not IsExistent(nExact)) then
    return StatusLog(nil,"RoundValue: Cannot round NAN {"..type(nvExact).."}<"..tostring(nvExact)..">") end
  local nFrac = tonumber(nFrac) or 0
  if(nFrac == 0) then
    return StatusLog(nil,"RoundValue: Fraction must be <> 0") end
  local q, f = mathModf(nExact/nFrac)
  return nFrac * (q + (f > 0.5 and 1 or 0))
end

function SnapValue(nvVal, nvSnap)
  if(not nvVal) then return 0 end
  local nVal = tonumber(nvVal)
  if(not IsExistent(nVal)) then
    return StatusLog(0,"SnapValue: Convert value NAN {"..type(nvVal).."}<"..tostring(nvVal)..">") end
  if(not IsExistent(nvSnap)) then return nVal end
  local nSnap = tonumber(nvSnap)
  if(not IsExistent(nSnap)) then
    return StatusLog(0,"SnapValue: Convert snap NAN {"..type(nvSnap).."}<"..tostring(nvSnap)..">") end
  if(nSnap == 0) then return nVal end
  local Rez
  local Snp = mathAbs(nSnap)
  local Val = mathAbs(nVal)
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

function GetCorrectID(anyValue,oContainer)
  local Value = tonumber(anyValue)
  if(not Value) then return 1 end
  if(getmetatable(oContainer) ~= GetOpVar("TYPEMT_CONTAINER")) then return 1 end
  local Max = oContainer:GetSize()
  if(Value > Max) then Value = 1 end
  if(Value < 1) then Value = Max end
  return Value
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
  if(not (IsString(nsVal) or tonumber(nsVal))) then
    return StatusLog(nsVal,"BorderValue: Value not comparable") end
  local Border = GetOpVar("TABLE_BORDERS")
        Border = Border[sName]
  if(IsExistent(Border)) then
    if    (nsVal < Border[1]) then return Border[1]
    elseif(nsVal > Border[2]) then return Border[2] end
  end
  return nsVal
end

function ModelToName(sModel)
  if(not IsString(sModel)) then
    return StatusLog("","ModelToName: Argument {"..type(sModel).."}<"..tostring(sModel)..">") end
  if(IsEmptyString(sModel)) then return StatusLog("","ModelToName: Empty string") end
  local fCh, bCh, Cnt = "", "", 1
  local sSymDiv = GetOpVar("OPSYM_DIVIDER")
  local sSymDir = GetOpVar("OPSYM_DIRECTORY")
  local sModel  = stringGsub(stringToFileName(sModel),GetOpVar("FILE_MODEL"),"")
  local gModel  = stringSub(sModel,1,-1) -- Create a copy so we can select cut-off parts later on
  local tCut, tSub, tApp = SettingsModelToName("GET")
  if(tCut and tCut[1]) then
    while(tCut[Cnt] and tCut[Cnt+1]) do
      fCh = tonumber(tCut[Cnt])
      bCh = tonumber(tCut[Cnt+1])
      if(not (IsExistent(fCh) and IsExistent(bCh))) then
        return StatusLog("","ModelToName: Cannot cut the model in {"
                 ..tostring(tCut[Cnt])..","..tostring(tCut[Cnt+1]).."} for "..sModel)
      end
      LogInstance("ModelToName[CUT]: {"..tostring(tCut[Cnt])..", "..tostring(tCut[Cnt+1]).."} << "..gModel)
      gModel = stringGsub(gModel,stringSub(sModel,fCh,bCh),"")
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
      LogInstance("ModelToName[SUB]: {"..tostring(tSub[Cnt])..", "..tostring(tSub[Cnt+1]).."} << "..gModel)
      gModel = stringGsub(gModel,fCh,bCh)
      LogInstance("ModelToName[SUB]: {"..tostring(tSub[Cnt])..", "..tostring(tSub[Cnt+1]).."} >> "..gModel)
      Cnt = Cnt + 2
    end
    Cnt = 1
  end
  -- Append something if needed
  if(tApp and tApp[1]) then
    LogInstance("ModelToName[APP]: {"..tostring(tApp[Cnt])..", "..tostring(tApp[Cnt+1]).."} << "..gModel)
    gModel = tostring(tApp[1] or "")..gModel..tostring(tApp[2] or "")
    LogInstance("ModelToName[APP]: {"..tostring(tSub[Cnt])..", "..tostring(tSub[Cnt+1]).."} >> "..gModel)
  end
  -- Trigger the capital-space using the divider
  if(stringSub(gModel,1,1) ~= sSymDiv) then gModel = sSymDiv..gModel end
  -- Here in gModel we have: _aaaaa_bbbb_ccccc
  fCh, bCh, sModel = stringFind(gModel,sSymDiv,1), 1, ""
  while(fCh) do
    if(fCh > bCh) then
      sModel = sModel..stringSub(gModel,bCh+2,fCh-1)
    end
    if(not IsEmptyString(sModel)) then
      sModel = sModel.." "
    end
    sModel = sModel..stringUpper(stringSub(gModel,fCh+1,fCh+1))
    bCh = fCh
    fCh = stringFind(gModel,sSymDiv,fCh+1)
  end
  return sModel..stringSub(gModel,bCh+2,-1)
end

function LocatePOA(oRec, ivPointID)
  if(not oRec) then
    return StatusLog(nil,"LocatePOA: Missing record") end
  if(not oRec.Offs) then
    return StatusLog(nil,"LocatePOA: Missing offsets for <"..tostring(oRec.Slot)..">") end
  local iPointID = mathFloor(tonumber(ivPointID) or 0)
  local stPOA = oRec.Offs[iPointID]
  if(not IsExistent(stPOA)) then
    return StatusLog(nil,"LocatePOA: Missing ID #"..tostring(iPointID).." <"
             ..tostring(ivPointID).."> for <"..tostring(oRec.Slot)..">") end
  return stPOA
end

local function ReloadPOA(nXP,nYY,nZR,nSX,nSY,nSZ,nSD)
  local arPOA = GetOpVar("ARRAY_DECODEPOA")
        arPOA[1] = tonumber(nXP) or 0
        arPOA[2] = tonumber(nYY) or 0
        arPOA[3] = tonumber(nZR) or 0
        arPOA[4] = tonumber(nSX) or 1
        arPOA[5] = tonumber(nSY) or 1
        arPOA[6] = tonumber(nSZ) or 1
        arPOA[7] = (tonumber(nSD) and (nSD ~= 0)) and true or false
  return arPOA
end

local function IsEqualPOA(stOffsetA,stOffsetB)
  if(not IsExistent(stOffsetA)) then
    return StatusLog(false,"EqualPOA: Missing OffsetA") end
  if(not IsExistent(stOffsetB)) then
    return StatusLog(false,"EqualPOA: Missing OffsetB") end
  for Ind, Comp in pairs(stOffsetA) do
    if(Ind ~= csD and stOffsetB[Ind] ~= Comp) then return false end
  end
  return true
end

local function StringPOA(arPOA,sOffs)
  if(not IsString(sOffs)) then
    return StatusLog(nil,"StringPOA: Mode {"..type(sOffs).."}<"..tostring(sOffs).."> not string") end
  if(not IsExistent(arPOA)) then
    return StatusLog(nil,"StringPOA: Missing Offsets") end
  local symRevs = GetOpVar("OPSYM_REVSIGN")
  local symDisa = GetOpVar("OPSYM_DISABLE")
  local symSepa = GetOpVar("OPSYM_SEPARATOR")
  local sModeDB = GetOpVar("MODE_DATABASE")
  local Result = ((arPOA[csD] and symDisa) or "")
  if(sOffs == "V") then
    Result = Result..((arPOA[csA] == -1) and symRevs or "")..tostring(arPOA[cvX])..symSepa
                   ..((arPOA[csB] == -1) and symRevs or "")..tostring(arPOA[cvY])..symSepa
                   ..((arPOA[csC] == -1) and symRevs or "")..tostring(arPOA[cvZ])
  elseif(sOffs == "A") then
    Result = Result..((arPOA[csA] == -1) and symRevs or "")..tostring(arPOA[caP])..symSepa
                   ..((arPOA[csB] == -1) and symRevs or "")..tostring(arPOA[caY])..symSepa
                   ..((arPOA[csC] == -1) and symRevs or "")..tostring(arPOA[caR])
  else return StatusLog("","StringPOA: Missed offset mode "..sOffs) end
  return stringGsub(Result," ","") -- Get rid of the spaces
end

local function TransferPOA(stOffset,sMode)
  if(not IsExistent(stOffset)) then
    return StatusLog(nil,"TransferPOA: Destination needed") end
  if(not IsString(sMode)) then
    return StatusLog(nil,"TransferPOA: Mode {"..type(sMode).."}<"..tostring(sMode).."> not string") end
  local arPOA = GetOpVar("ARRAY_DECODEPOA")
  if    (sMode == "V") then stOffset[cvX] = arPOA[1]; stOffset[cvY] = arPOA[2]; stOffset[cvZ] = arPOA[3]
  elseif(sMode == "A") then stOffset[caP] = arPOA[1]; stOffset[caY] = arPOA[2]; stOffset[caR] = arPOA[3]
  else return StatusLog(nil,"TransferPOA: Missed mode "..sMode) end
  stOffset[csA] = arPOA[4]; stOffset[csB] = arPOA[5]; stOffset[csC] = arPOA[6]; stOffset[csD] = arPOA[7]
  return arPOA
end

local function DecodePOA(sStr)
  if(not IsString(sStr)) then
    return StatusLog(nil,"DecodePOA: Argument {"..type(sStr).."}<"..tostring(sStr).."> not string") end
  local DatInd = 1
  local ComCnt = 0
  local Len    = stringLen(sStr)
  local symOff = GetOpVar("OPSYM_DISABLE")
  local symRev = GetOpVar("OPSYM_REVSIGN")
  local symSep = GetOpVar("OPSYM_SEPARATOR")
  local arPOA  = GetOpVar("ARRAY_DECODEPOA")
  local Ch = ""
  local S = 1
  local E = 1
  local Cnt = 1
  ReloadPOA()
  if(stringSub(sStr,Cnt,Cnt) == symOff) then
    arPOA[7] = true
    Cnt = Cnt + 1
    S   = S   + 1
  end
  while(Cnt <= Len) do
    Ch = stringSub(sStr,Cnt,Cnt)
    if(Ch == symRev) then
      arPOA[3+DatInd] = -arPOA[3+DatInd]
      S   = S + 1
    elseif(Ch == symSep) then
      ComCnt = ComCnt + 1
      E = Cnt - 1
      if(ComCnt > 2) then break end
      arPOA[DatInd] = tonumber(stringSub(sStr,S,E)) or 0
      DatInd = DatInd + 1
      S = Cnt + 1
      E = S
    else
      E = E + 1
    end
    Cnt = Cnt + 1
  end
  arPOA[DatInd] = tonumber(stringSub(sStr,S,E)) or 0
  return arPOA
end

local function RegisterPOA(stPiece, ivID, sP, sO, sA)
  if(not stPiece) then
    return StatusLog(nil,"RegisterPOA: Cache record invalid") end
  local iID = tonumber(ivID)
  if(not IsExistent(iID)) then
    return StatusLog(nil,"RegisterPOA: OffsetID NAN {"..type(ivID).."}<"..tostring(ivID)..">") end
  local sP = sP or "NULL"
  local sO = sO or "NULL"
  local sA = sA or "NULL"
  if(not IsString(sP)) then
    return StatusLog(nil,"RegisterPOA: Point  {"..type(sP).."}<"..tostring(sP)..">") end
  if(not IsString(sO)) then
    return StatusLog(nil,"RegisterPOA: Origin {"..type(sO).."}<"..tostring(sO)..">") end
  if(not IsString(sA)) then
    return StatusLog(nil,"RegisterPOA: Angle  {"..type(sA).."}<"..tostring(sA)..">") end
  if(not stPiece.Offs) then
    if(iID > 1) then return StatusLog(nil,"RegisterPOA: First ID cannot be #"..tostring(iID)) end
    stPiece.Offs = {}
  end
  local tOffs = stPiece.Offs
  if(tOffs[iID]) then
    return StatusLog(nil,"RegisterPOA: Exists ID #"..tostring(iID))
  else
    if((iID > 1) and (not tOffs[iID - 1])) then
      return StatusLog(nil,"RegisterPOA: No sequential ID #"..tostring(iID - 1))
    end
    tOffs[iID]   = {}
    tOffs[iID].P = {}
    tOffs[iID].O = {}
    tOffs[iID].A = {}
    tOffs        = tOffs[iID]
  end
  if((sO ~= "") and (sO ~= "NULL")) then DecodePOA(sO) else ReloadPOA() end
  if(not IsExistent(TransferPOA(tOffs.O,"V"))) then
    return StatusLog(nil,"RegisterPOA: Cannot transfer origin") end
  if((sP ~= "") and (sP ~= "NULL")) then DecodePOA(sP) end
  if(not IsExistent(TransferPOA(tOffs.P,"V"))) then
    return StatusLog(nil,"RegisterPOA: Cannot transfer point")
  end -- In the POA array still persists the decoded Origin
  if(stringSub(sP,1,1) == GetOpVar("OPSYM_DISABLE")) then tOffs.P[csD] = true else tOffs.P[csD] = false end
  if((sA ~= "") and (sA ~= "NULL")) then DecodePOA(sA) else ReloadPOA() end
  if(not IsExistent(TransferPOA(tOffs.A,"A"))) then
    return StatusLog(nil,"RegisterPOA: Cannot transfer angle") end
  return tOffs
end

local function Sort(tTable,tKeys,tFields)

  local function Qsort(Data,Lo,Hi)
    if(not (Lo and Hi and (Lo > 0) and (Lo < Hi))) then
      return StatusLog(nil,"Qsort: Data dimensions mismatch") end
    local Mid = mathRandom(Hi-(Lo-1))+Lo-1
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
      return StatusLog(nil,"Sort: Key <"..Key.."> does not exist in the primary table")
    end
    Match[Cnt] = {}
    Match[Cnt].Key = Key
    if(type(Val) == "table") then
      Match[Cnt].Val = ""
      Ind = 1
      while(tFields[Ind]) do
        Fld = tFields[Ind]
        if(not IsExistent(Val[Fld])) then
          return StatusLog(nil,"Sort: Field <"..Fld.."> not found on the current record")
        end
        Match[Cnt].Val = Match[Cnt].Val..tostring(Val[Fld])
        Ind = Ind + 1
      end
    else
      Match[Cnt].Val = Val
    end
    Cnt = Cnt + 1
  end Qsort(Match,1,Cnt-1)
  return Match
end

--------------------- STRING -----------------------

function DisableString(sBase, anyDisable, anyDefault)
  if(IsString(sBase)) then
    local sFirst = stringSub(sBase,1,1)
    if(sFirst ~= GetOpVar("OPSYM_DISABLE") and not IsEmptyString(sBase)) then
      return sBase
    elseif(sFirst == GetOpVar("OPSYM_DISABLE")) then
      return anyDisable
    end
  end
  return anyDefault
end

function DefaultString(sBase, sDefault)
  if(IsString(sBase)) then
    if(not IsEmptyString(sBase)) then return sBase end
  end
  if(IsString(sDefault)) then return sDefault end
  return ""
end

------------- VARIABLE INTERFACES --------------

local function SQLBuildError(anyError)
  if(not IsExistent(anyError)) then
    return GetOpVar("SQL_BUILD_ERR") or "" end
  SetOpVar("SQL_BUILD_ERR", tostring(anyError))
  return nil -- Nothing assembled
end

function SettingsModelToName(sMode, gCut, gSub, gApp)
  if(not IsString(sMode)) then
    return StatusLog(false,"SettingsModelToName: Mode {"..type(sMode).."}<"..tostring(sMode).."> not string") end
  if(sMode == "SET") then
    if(gCut and gCut[1]) then SetOpVar("TABLE_GCUT_MODEL",gCut) else SetOpVar("TABLE_GCUT_MODEL",{}) end
    if(gSub and gSub[1]) then SetOpVar("TABLE_GSUB_MODEL",gSub) else SetOpVar("TABLE_GSUB_MODEL",{}) end
    if(gApp and gApp[1]) then SetOpVar("TABLE_GAPP_MODEL",gApp) else SetOpVar("TABLE_GAPP_MODEL",{}) end
  elseif(sMode == "GET") then
    return GetOpVar("TABLE_GCUT_MODEL"), GetOpVar("TABLE_GSUB_MODEL"), GetOpVar("TABLE_GAPP_MODEL")
  elseif(sMode == "CLR") then
    SetOpVar("TABLE_GCUT_MODEL",{})
    SetOpVar("TABLE_GSUB_MODEL",{})
    SetOpVar("TABLE_GAPP_MODEL",{})
  else
    return StatusLog(false,"SettingsModelToName: Wrong mode name "..sMode)
  end
end

function DefaultType(anyType)
  if(not IsExistent(anyType)) then
    return GetOpVar("DEFAULT_TYPE") or "" end
  SetOpVar("DEFAULT_TYPE",tostring(anyType))
  SettingsModelToName("CLR")
end

function DefaultTable(anyTable)
  if(not IsExistent(anyTable)) then
    return GetOpVar("DEFAULT_TABLE") or "" end
  SetOpVar("DEFAULT_TABLE",anyTable)
  SettingsModelToName("CLR")
end

------------------------- PLAYER -----------------------------------

function ConCommandPly(pPly,sCvar,snValue)
  if(not pPly) then return StatusLog("","StringConCmd: Player invalid") end
  if(not IsString(sCvar)) then
    return StatusLog("","StringConCmd: Convar {"..type(sCvar).."}<"..tostring(sCvar).."> not string") end
  return pPly:ConCommand(GetOpVar("TOOLNAME_PL")..sCvar.." "..tostring(snValue).."\n")
end

function PrintNotifyPly(pPly,sText,sNotifType)
  if(not pPly) then return StatusLog(false,"PrintNotifyPly: Player invalid") end
  if(SERVER) then
    pPly:SendLua("GAMEMODE:AddNotify(\""..sText.."\", NOTIFY_"..sNotifType..", 6)")
    pPly:SendLua("surface.PlaySound(\"ambient/water/drip"..mathRandom(1, 4)..".wav\")")
  end
  return StatusLog(true,"PrintNotifyPly: Success")
end

function UndoCratePly(anyMessage)
  SetOpVar("LABEL_UNDO",tostring(anyMessage))
  undoCreate(GetOpVar("LABEL_UNDO"))
  return true
end

function UndoAddEntityPly(oEnt)
  if(not (oEnt and oEnt:IsValid())) then
    return StatusLog(false,"AddUndoPly: Entity invalid") end
  undoAddEntity(oEnt)
  return true
end

function UndoFinishPly(pPly,anyMessage)
  if(not pPly) then return StatusLog(false,"UndoFinishPly: Player invalid") end
  pPly:EmitSound("physics/metal/metal_canister_impact_hard"..mathFloor(mathRandom(3))..".wav")
  undoSetCustomUndoText(GetOpVar("LABEL_UNDO")..tostring(anyMessage or ""))
  undoSetPlayer(pPly)
  undoFinish()
  return true
end

function LoadKeyPly(pPly, sKey)
  local keyPly   = GetOpVar("HASH_PLAYER_KEYDOWN")
  local plyCache = libCache[keyPly]
  if(not IsExistent(plyCache)) then
    libCache[keyPly] = {}
    plyCache = libCache[keyPly]
  end
  if(not pPly) then
    return StatusLog(false,"LoadKeyPly: Player not available") end
  local spName   = pPly:GetName()
  local plyPlace = plyCache[spName]
  if(not IsExistent(plyPlace)) then
    plyCache[spName] = {
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
    plyPlace = plyCache[spName]
  end
  if(IsExistent(sKey)) then
    if(not IsString(sKey)) then
      return StatusLog(false,"LoadKeyPly: Key hash {"..type(sKey).."}<"..tostring(sKey).."> not string") end
    if(sKey == "DEBUG") then
      return plyPlace
    end
    LogInstance("LoadKeyPly: NamePK <"..sKey.."> = "..tostring(plyPlace[sKey]))
    return plyPlace[sKey]
  end
  plyPlace["ALTLFT"]  = pPly:KeyDown(IN_ALT1      )
  plyPlace["ALTRGH"]  = pPly:KeyDown(IN_ALT2      )
  plyPlace["ATTLFT"]  = pPly:KeyDown(IN_ATTACK    )
  plyPlace["ATTRGH"]  = pPly:KeyDown(IN_ATTACK2   )
  plyPlace["FORWARD"] = pPly:KeyDown(IN_FORWARD   )
  plyPlace["BACK"]    = pPly:KeyDown(IN_BACK      )
  plyPlace["MOVELFT"] = pPly:KeyDown(IN_MOVELEFT  )
  plyPlace["MOVERGH"] = pPly:KeyDown(IN_MOVERIGHT )
  plyPlace["RELOAD"]  = pPly:KeyDown(IN_RELOAD    )
  plyPlace["USE"]     = pPly:KeyDown(IN_USE       )
  plyPlace["DUCK"]    = pPly:KeyDown(IN_DUCK      )
  plyPlace["JUMP"]    = pPly:KeyDown(IN_JUMP      )
  plyPlace["SPEED"]   = pPly:KeyDown(IN_SPEED     )
  plyPlace["SCORE"]   = pPly:KeyDown(IN_SCORE     )
  plyPlace["ZOOM"]    = pPly:KeyDown(IN_ZOOM      )
  plyPlace["LEFT"]    = pPly:KeyDown(IN_LEFT      )
  plyPlace["RIGHT"]   = pPly:KeyDown(IN_RIGHT     )
  plyPlace["WALK"]    = pPly:KeyDown(IN_WALK      )
  return StatusLog(true,"LoadKeyPly: Player <"..spName.."> keys loaded")
end

-------------------------- BUILDSQL ------------------------------

local function MatchType(defTable,snValue,ivIndex,bQuoted,sQuote,bStopRevise,bStopEmpty)
  if(not defTable) then
    return StatusLog(nil,"MatchType: Missing table definition") end
  local nIndex = tonumber(ivIndex)
  if(not IsExistent(nIndex)) then
    return StatusLog(nil,"MatchType: Field NAN {"..type(ivIndex)"}<"
             ..tostring(ivIndex).."> invalid on table "..defTable.Name) end
  local defField = defTable[nIndex]
  if(not IsExistent(defField)) then
    return StatusLog(nil,"MatchType: Invalid field #"
             ..tostring(nIndex).." on table "..defTable.Name) end
  local snOut
  local tipField = tostring(defField[2])
  local sModeDB  = GetOpVar("MODE_DATABASE")
  if(tipField == "TEXT") then
    snOut = tostring(snValue)
    if(not bStopEmpty and (snOut == "nil" or IsEmptyString(snOut))) then
      if    (sModeDB == "SQL") then snOut = "NULL"
      elseif(sModeDB == "LUA") then snOut = "NULL"
      else return StatusLog(nil,"MatchType: Wrong database mode <"..sModeDB..">") end
    end
    if    (defField[3] == "LOW") then snOut = stringLower(snOut)
    elseif(defField[3] == "CAP") then snOut = stringUpper(snOut) end
    if(not bStopRevise and sModeDB == "SQL" and defField[4] == "QMK") then
      snOut = stringGsub(snOut,"'","''")
    end
    if(bQuoted) then
      local sqChar
      if(sQuote) then
        sqChar = stringSub(tostring(sQuote),1,1)
      else
        if    (sModeDB == "SQL") then sqChar = "'"
        elseif(sModeDB == "LUA") then sqChar = "\"" end
      end
      snOut = sqChar..snOut..sqChar
    end
  elseif(tipField == "REAL" or tipField == "INTEGER") then
    snOut = tonumber(snValue)
    if(not IsExistent(snOut)) then
      return StatusLog(nil,"MatchType: Failed converting {"
               ..type(snValue).."}<"..tostring(snValue).."> to NUMBER for table "
               ..defTable.Name.." field #"..nIndex) end
    if(tipField == "INTEGER") then
      if(defField[3] == "FLR") then
        snOut = mathFloor(snOut)
      elseif(defField[3] == "CEL") then
        snOut = mathCeil(snOut)
      end
    end
  else
    return StatusLog(nil,"MatchType: Invalid field type <"
      ..tipField.."> on table "..defTable.Name) end
  return snOut
end

local function SQLBuildCreate(defTable)
  if(not defTable) then
    return SQLBuildError("SQLBuildCreate: Missing table definition") end
  local namTable = defTable.Name
  local indTable = defTable.Index
  if(not defTable[1]) then
    return SQLBuildError("SQLBuildCreate: Missing table definition is empty for "..namTable) end
  if(not (defTable[1][1] and defTable[1][2])) then
    return SQLBuildError("SQLBuildCreate: Missing table "..namTable.." field definitions") end
  local Ind = 1
  local Command  = {}
  Command.Drop   = "DROP TABLE "..namTable..";"
  Command.Delete = "DELETE FROM "..namTable..";"
  Command.Create = "CREATE TABLE "..namTable.." ( "
  while(defTable[Ind]) do
    local v = defTable[Ind]
    if(not v[1]) then
      return SQLBuildError("SQLBuildCreate: Missing Table "..namTable
                          .."'s field #"..tostring(Ind)) end
    if(not v[2]) then
      return SQLBuildError("SQLBuildCreate: Missing Table "..namTable
                                  .."'s field type #"..tostring(Ind)) end
    Command.Create = Command.Create..stringUpper(v[1]).." "..stringUpper(v[2])
    if(defTable[Ind+1]) then Command.Create = Command.Create ..", " end
    Ind = Ind + 1
  end
  Command.Create = Command.Create.." );"
  if(indTable and
     indTable[1] and
     type(indTable[1]) == "table" and
     indTable[1][1] and
     type(indTable[1][1]) == "number"
   ) then
    Command.Index = {}
    Ind = 1
    Cnt = 1
    while(indTable[Ind]) do
      local vI = indTable[Ind]
      if(type(vI) ~= "table") then
        return SQLBuildError("SQLBuildCreate: Index creator mismatch on "
          ..namTable.." value "..vI.." is not a table for index ["..tostring(Ind).."]") end
      local FieldsU = ""
      local FieldsC = ""
      Command.Index[Ind] = "CREATE INDEX IND_"..namTable
      Cnt = 1
      while(vI[Cnt]) do
        local vF = vI[Cnt]
        if(type(vF) ~= "number") then
          return SQLBuildError("SQLBuildCreate: Index creator mismatch on "
            ..namTable.." value "..vF.." is not a number for index ["
            ..tostring(Ind).."]["..tostring(Cnt).."]") end
        if(not defTable[vF]) then
          return SQLBuildError("SQLBuildCreate: Index creator mismatch on "
            ..namTable..". The table does not have field index #"
            ..vF..", max is #"..Table.Size) end
        FieldsU = FieldsU.."_" ..stringUpper(defTable[vF][1])
        FieldsC = FieldsC..stringUpper(defTable[vF][1])
        if(vI[Cnt+1]) then FieldsC = FieldsC ..", " end
        Cnt = Cnt + 1
      end
      Command.Index[Ind] = Command.Index[Ind]..FieldsU.." ON "..namTable.." ( "..FieldsC.." );"
      Ind = Ind + 1
    end
  end
  SQLBuildError("")
  return Command
end

local function SQLStoreQuery(defTable,tFields,tWhere,tOrderBy,sQuery)
  if(not GetOpVar("EN_QUERY_STORE")) then return sQuery end
  local Val
  local Base
  if(not defTable) then
    return StatusLog(nil,"SQLStoreQuery: Missing table definition") end
  local tTimer = defTable.Timer
  if(not (tTimer and ((tonumber(tTimer[2]) or 0) > 0))) then
    return StatusLog(sQuery,"SQLStoreQuery: Skipped. Cache persistent forever") end
  local Field = 1
  local Where = 1
  local Order = 1
  local keyStore = GetOpVar("HASH_QUERY_STORE")
  local Cache    = libCache[keyStore]
  local namTable = defTable.Name
  if(not IsExistent(Cache)) then
    libCache[keyStore] = {}
    Cache = libCache[keyStore]
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
        return StatusLog(nil,"SQLStoreQuery: Missing field key for #"..tostring(Field)) end
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
      else return StatusLog(nil,"SQLStoreQuery: Missing order field key for #"..tostring(Order)) end
      Order = Order + 1
    end
  end
  if(tWhere) then
    while(tWhere[Where]) do
      Val = defTable[tWhere[Where][1]][1]
      if(not IsExistent(Val)) then
        return StatusLog(nil,"SQLStoreQuery: Missing where field key for #"..tostring(Where)) end
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
        return StatusLog(nil,"SQLStoreQuery: Missing where value key for #"..tostring(Where)) end
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
  if(sQuery) then Base[Val] = sQuery end
  return Base[Val]
end

local function SQLBuildSelect(defTable,tFields,tWhere,tOrderBy)
  if(not defTable) then
    return SQLBuildError("SQLBuildSelect: Missing table definition") end
  local namTable = defTable.Name
  if(not (defTable[1][1] and defTable[1][2])) then
    return SQLBuildError("SQLBuildSelect: Missing table "..namTable.." field definitions") end
  local Command = SQLStoreQuery(defTable,tFields,tWhere,tOrderBy)
  if(IsString(Command)) then
    SQLBuildError("")
    return Command
  else Command = "SELECT " end
  local Cnt = 1
  if(tFields) then
    while(tFields[Cnt]) do
      local v = tonumber(tFields[Cnt])
      if(not IsExistent(v)) then
        return SQLBuildError("SQLBuildSelect: Select index NAN {"
             ..type(tFields[Cnt]).."}<"..tostring(tFields[Cnt])
             .."> type mismatch in "..namTable) end
      if(defTable[v]) then
        if(defTable[v][1]) then
          Command = Command..defTable[v][1]
        else
          return SQLBuildError("SQLBuildSelect: Select no such field name by index #"
            ..v.." in the table "..namTable) end
      end
      if(tFields[Cnt+1]) then
        Command = Command ..", "
      end
      Cnt = Cnt + 1
    end
  else
    Command = Command.."*"
  end
  Command = Command .." FROM "..namTable
  if(tWhere and
     type(tWhere == "table") and
     type(tWhere[1]) == "table" and
     tWhere[1][1] and
     tWhere[1][2] and
     type(tWhere[1][1]) == "number" and
     (type(tWhere[1][2]) == "string" or type(tWhere[1][2]) == "number")
  ) then
    Cnt = 1
    while(tWhere[Cnt]) do
      k = tonumber(tWhere[Cnt][1])
      v = tWhere[Cnt][2]
      t = defTable[k][2]
      if(not (k and v and t) ) then
        return SQLBuildError("SQLBuildSelect: Where clause inconsistent on "
          ..namTable.." field index, {"..tostring(k)..","..tostring(v)..","..tostring(t)
          .."} value or type in the table definition") end
      v = MatchType(defTable,v,k,true)
      if(not IsExistent(v)) then
        return SQLBuildError("SQLBuildSelect: Data matching failed on "
          ..namTable.." field index #"..Cnt.." value <"..tostring(v)..">") end
      if(Cnt == 1) then
        Command = Command.." WHERE "..defTable[k][1].." = "..v
      else
        Command = Command.." AND "..defTable[k][1].." = "..v
      end
      Cnt = Cnt + 1
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
        return SQLBuildError("SQLBuildSelect: Order wrong for "
                           ..namTable .." field index #"..Cnt) end
        Command = Command..defTable[v][1]..Dire
        if(tOrderBy[Cnt+1]) then
          Command = Command..", "
        end
      Cnt = Cnt + 1
    end
  end
  SQLBuildError("")
  return SQLStoreQuery(defTable,tFields,tWhere,tOrderBy,Command..";")
end

local function SQLBuildInsert(defTable,tInsert,tValues)
  if(not (defTable and tValues)) then
    return SQLBuildError("SQLBuildInsert: Missing Table definition or value fields")
  end
  local namTable = defTable.Name
  if(not defTable[1]) then
    return SQLBuildError("SQLBuildInsert: The table and the chosen fields must not be empty")
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    return SQLBuildError("SQLBuildInsert: Missing table "..namTable.." field definition")
  end
  local tInsert = tInsert or {}
  if(not tInsert[1]) then
    local iCnt = 1
    while(defTable[iCnt]) do
      tInsert[iCnt] = iCnt
      iCnt = iCnt + 1
    end
  end
  local iCnt = 1
  local qVal = " VALUES ( "
  local qIns = "INSERT INTO "..namTable.." ( "
  local Val, Ind, Fld
  while(tInsert[iCnt]) do
    Ind = tInsert[iCnt]
    Fld = defTable[Ind]
    if(not IsExistent(Fld)) then
      return SQLBuildError("SQLBuildInsert: No such field #"..Ind.." on table "..namTable)
    end
    Val = MatchType(defTable,tValues[iCnt],Ind,true)
    if(not IsExistent(Val)) then
      return SQLBuildError("SQLBuildInsert: Cannot match value <"..tostring(tValues[iCnt]).."> #"..Ind.." on table "..namTable)
    end
    qIns = qIns..Fld[1]
    qVal = qVal..Val
    if(tInsert[iCnt+1]) then
      qIns = qIns ..", "
      qVal = qVal ..", "
    else
      qIns = qIns .." ) "
      qVal = qVal .." );"
    end
    iCnt = iCnt + 1
  end
  SQLBuildError("")
  return qIns..qVal
end

function CreateTable(sTable,defTable,bDelete,bReload)
  if(not IsString(sTable)) then
    return StatusLog(false,"CreateTable: Table key {"..type(sTable).."}<"..tostring(sTable).."> not string") end
  if(not (type(defTable) == "table")) then
    return StatusLog(false,"CreateTable: Table definition missing for "..sTable) end
  if(#defTable <= 0) then
    return StatusLog(false,"CreateTable: Record definition missing for "..sTable) end
  if(#defTable ~= tableMaxn(defTable)) then
    return StatusLog(false,"CreateTable: Record definition mismatch for "..sTable) end
  defTable.Size = #defTable
  local sModeDB = GetOpVar("MODE_DATABASE")
  local sTable  = stringUpper(sTable)
  defTable.Name = GetOpVar("TOOLNAME_PU")..sTable
  SetOpVar("DEFTABLE_"..sTable,defTable)
  local symDis = GetOpVar("OPSYM_DISABLE")
  local namTable = defTable.Name
  local Cnt, defField = 1, nil
  while(defTable[Cnt]) do
    defField    = defTable[Cnt]
    defField[3] = DefaultString(tostring(defField[3] or symDis), symDis)
    defField[4] = DefaultString(tostring(defField[4] or symDis), symDis)
    Cnt = Cnt + 1
  end
  libCache[namTable] = {}
  if(sModeDB == "SQL") then
    defTable.Life = tonumber(defTable.Life) or 0
    local tQ = SQLBuildCreate(defTable)
    if(not IsExistent(tQ)) then return StatusLog(false,"CreateTable: "..SQLBuildError()) end
    if(bDelete and sqlTableExists(namTable)) then
      local qRez = sqlQuery(tQ.Delete)
      if(not qRez and IsBool(qRez)) then
        LogInstance("CreateTable: Table "..sTable.." is not present. Skipping delete !")
      else
        LogInstance("CreateTable: Table "..sTable.." deleted !")
      end
    end
    if(bReload) then
      local qRez = sqlQuery(tQ.Drop)
      if(not qRez and IsBool(qRez)) then
        LogInstance("CreateTable: Table "..sTable.." is not present. Skipping drop !")
      else
        LogInstance("CreateTable: Table "..sTable.." dropped !")
      end
    end
    if(sqlTableExists(namTable)) then
      LogInstance("CreateTable: Table "..sTable.." exists!")
      return true
    else
      local qRez = sqlQuery(tQ.Create)
      if(not qRez and IsBool(qRez)) then
        return StatusLog(false,"CreateTable: Table "..sTable
          .." failed to create because of "..sqlLastError()) end
      if(sqlTableExists(namTable)) then
        for k, v in pairs(tQ.Index) do
          qRez = sqlQuery(v)
          if(not qRez and IsBool(qRez)) then
            return StatusLog(false,"CreateTable: Table "..sTable..
              " failed to create index ["..k.."] > "..v .." > because of "..sqlLastError()) end
        end return StatusLog(true,"CreateTable: Indexed Table "..sTable.." created !")
      else
        return StatusLog(false,"CreateTable: Table "..sTable..
          " failed to create because of "..sqlLastError().." Query ran > "..tQ.Create) end
    end
  elseif(sModeDB == "LUA") then sModeDB = "LUA" else -- Just to do something here.
    return StatusLog(false,"CreateTable: Wrong database mode <"..sModeDB..">")
  end
end

function InsertRecord(sTable,tData)
  if(not IsExistent(sTable)) then
    return StatusLog(false,"InsertRecord: Missing table name/values")
  end
  if(type(sTable) == "table") then
    tData  = sTable
    sTable = DefaultTable()
    if(not (IsExistent(sTable) and sTable ~= "")) then
      return StatusLog(false,"InsertRecord: Missing table default name for "..sTable) end
  end
  if(not IsString(sTable)) then
    return StatusLog(false,"InsertRecord: Table name {"..type(sTable).."}<"..tostring(sTable).."> not string") end
  local defTable = GetOpVar("DEFTABLE_"..sTable)
  if(not defTable) then
    return StatusLog(false,"InsertRecord: Missing table definition for "..sTable) end
  if(not defTable[1])  then
    return StatusLog(false,"InsertRecord: Missing table definition is empty for "..sTable) end
  if(not tData)      then
    return StatusLog(false,"InsertRecord: Missing data table for "..sTable) end
  if(not tData[1])   then
    return StatusLog(false,"InsertRecord: Missing data table is empty for "..sTable) end
  local namTable = defTable.Name

  if(sTable == "PIECES") then
    tData[2] = GetDisableString(tData[2],GetOpVar("DEFAULT_TYPE"),"TYPE")
    tData[3] = GetDisableString(tData[3],ModelToName(tData[1]),"MODEL")
  end

  local sModeDB = GetOpVar("MODE_DATABASE")
  if(sModeDB == "SQL") then
    local Q = SQLBuildInsert(defTable,nil,tData)
    if(not IsExistent(Q)) then return StatusLog(false,"InsertRecord: Build error <"..SQLBuildError()..">") end
    local qRez = sqlQuery(Q)
    if(not qRez and IsBool(qRez)) then
       return StatusLog(false,"InsertRecord: Failed to insert a record because of <"
              ..sqlLastError().."> Query ran <"..Q..">") end
    return true
  elseif(sModeDB == "LUA") then
    local snPrimaryKey = MatchType(defTable,tData[1],1)
    if(not IsExistent(snPrimaryKey)) then -- If primary key becomes a number
      return StatusLog(nil,"InsertRecord: Cannot match primary key "
                          ..sTable.." <"..tostring(tData[1]).."> to "
                          ..defTable[1][1].." for "..tostring(snPrimaryKey)) end
    local Cache = libCache[namTable]
    if(not IsExistent(Cache)) then
      return StatusLog(false,"InsertRecord: Cache not allocated for "..namTable) end
    if(sTable == "PIECES") then
      local tLine = Cache[snPrimaryKey]
      if(not tLine) then
        Cache[snPrimaryKey] = {}
        tLine = Cache[snPrimaryKey]
      end
      if(not IsExistent(tLine.Kept)) then tLine.Kept = 1        end
      if(not IsExistent(tLine.Type)) then tLine.Type = tData[2] end
      if(not IsExistent(tLine.Name)) then tLine.Name = tData[3] end
      if(not IsExistent(tLine.Slot)) then tLine.Slot = snPrimaryKey end
      if(not IsExistent(tLine.Mesh)) then tLine.Mesh = MatchType(defTable,tData[4],4) end
      if(not IsExistent(tLine.Mesh)) then
        return StatusLog(nil,"InsertRecord: Cannot match "
                            ..sTable.." <"..tostring(tData[4]).."> to "
                            ..defTable[4][1].." for "..tostring(snPrimaryKey))
      end
      local stRezul = RegisterPOA(tLine,tLine.Kept,tData[5],tData[6],tData[7])
      if(not IsExistent(stRezul)) then
        return StatusLog(nil,"InsertRecord: Cannot process offset for "..tostring(snPrimaryKey)) end
    else
      return StatusLog(false,"InsertRecord: No settings for table "..sTable)
    end
  end
end

--------------------------- PIECE QUERY -----------------------------

local function NavigateTable(oLocation,tKeys)
  if(not IsExistent(oLocation)) then
    return StatusLog(nil,"NavigateTable: Location missing") end
  if(not IsExistent(tKeys)) then
    return StatusLog(nil,"NavigateTable: Key table missing") end
  if(not IsExistent(tKeys[1])) then
    return StatusLog(nil,"NavigateTable: First key missing") end
  local Place, Key, Cnt = oLocation, tKeys[1], 1
  while(tKeys[Cnt]) do
    Key = tKeys[Cnt]
    if(tKeys[Cnt+1]) then
      Place = Place[Key]
      if(not IsExistent(Place)) then
        return StatusLog(nil,"NavigateTable: Key #"..tostring(Key).." irrelevant to location") end
    end
    Cnt = Cnt + 1
  end
  return Place, Key
end

--------------- TIMER MEMORY MANAGMENT ----------------------------

function TimerSetting(sTimerSet) -- Generates a timer settings table and keeps the defaults
  if(not IsExistent(sTimerSet)) then
    return StatusLog(nil,"TimerSetting: Timer set missing for setup") end
  if(not IsString(sTimerSet)) then
    return StatusLog(nil,"TimerSetting: Timer set {"..type(sTimerSet).."}<"..tostring(sTimerSet).."> not string") end
  local tBoom = stringExplode(GetOpVar("OPSYM_REVSIGN"),sTimerSet)
  tBoom[1] =   tostring(tBoom[1]  or "CQT")
  tBoom[2] =  (tonumber(tBoom[2]) or 0)
  tBoom[3] = ((tonumber(tBoom[3]) or 0) ~= 0) and true or false
  tBoom[4] = ((tonumber(tBoom[4]) or 0) ~= 0) and true or false
  return tBoom
end

local function TimerAttach(oLocation,tKeys,defTable,anyMessage)
  if(not defTable) then
    return StatusLog(nil,"TimerAttach: Missing table definition") end
  local Place, Key = NavigateTable(oLocation,tKeys)
  if(not (IsExistent(Place) and IsExistent(Key))) then
    return StatusLog(nil,"TimerAttach: Navigation failed") end
  if(not IsExistent(Place[Key])) then
    return StatusLog(nil,"TimerAttach: Data not found") end
  local sModeDB = GetOpVar("MODE_DATABASE")
  LogInstance("TimerAttach: Called by <"..anyMessage.."> for Place["..tostring(Key).."]")
  if(sModeDB == "SQL") then
    if(IsExistent(Place[Key].Kept)) then Place[Key].Kept = Place[Key].Kept - 1 end -- Get the proper line count
    local tTimer = defTable.Timer -- If we have a timer, and it does speak, we advise you send your regards..
    if(not IsExistent(tTimer)) then
      return StatusLog(Place[Key],"TimerAttach: Missing timer settings") end
    local nLifeTM = tTimer[2]
    if(nLifeTM <= 0) then
      return StatusLog(Place[Key],"TimerAttach: Timer attachment ignored") end
    local sModeTM = tTimer[1]
    local bKillRC = tTimer[3]
    local bCollGB = tTimer[4]
    LogInstance("TimerAttach: ["..sModeTM.."] ("..tostring(nLifeTM)..") "..tostring(bKillRC)..", "..tostring(bCollGB))
    if(sModeTM == "CQT") then
      Place[Key].Load = Time()
      for k, v in pairs(Place) do
        if(IsExistent(v.Used) and IsExistent(v.Load) and ((v.Used - v.Load) > nLifeTM)) then
          LogInstance("TimerAttach: ("..tostring(v.Used - v.Load).." > "..tostring(nLifeTM)..") > Dead")
          if(bKillRC) then
            LogInstance("TimerAttach: Killed <"..tostring(k)..">")
            Place[k] = nil
          end
        end
      end
      if(bCollGB) then
        collectgarbage()
        LogInstance("TimerAttach: Garbage collected")
      end
      return StatusLog(Place[Key],"TimerAttach: Place["..tostring(Key).."].Load = "..tostring(Place[Key].Load))
    elseif(sModeTM == "OBJ") then
      local TimerID = stringImplode(GetOpVar("OPSYM_DIVIDER"),tKeys)
      LogInstance("TimerAttach: TimID <"..TimerID..">")
      if(timerExists(TimerID)) then return StatusLog(Place[Key],"TimerAttach: Timer exists") end
      timerCreate(TimerID, nLifeTM, 1, function()
        LogInstance("TimerAttach["..TimerID.."]("..nLifeTM..") > Dead")
        if(bKillRC) then
          LogInstance("TimerAttach: Killed <"..Key..">")
          Place[Key] = nil
        end
        timerStop(TimerID)
        timerDestroy(TimerID)
        if(bCollGB) then
          collectgarbage()
          LogInstance("TimerAttach: Garbage collected")
        end
      end)
      timerStart(TimerID)
      return Place[Key]
    else
      return StatusLog(Place[Key],"TimerAttach: Timer mode not found <"..sModeTM..">")
    end
  elseif(sModeDB == "LUA") then
    return StatusLog(Place[Key],"TimerAttach: Memory manager not available")
  else
    return StatusLog(nil,"TimerAttach: Wrong database mode")
  end
end

local function TimerRestart(oLocation,tKeys,defTable,anyMessage)
  if(not defTable) then
    return StatusLog(nil,"TimerRestart: Missing table definition") end
  local Place, Key = NavigateTable(oLocation,tKeys)
  if(not (IsExistent(Place) and IsExistent(Key))) then
    return StatusLog(nil,"TimerRestart: Navigation failed") end
  if(not IsExistent(Place[Key])) then
    return StatusLog(nil,"TimerRestart: Place not found") end
  local sModeDB = GetOpVar("MODE_DATABASE")
  if(sModeDB == "SQL") then
    local tTimer = defTable.Timer
    if(not IsExistent(tTimer)) then
      return StatusLog(Place[Key],"TimerRestart: Missing timer settings") end
    Place[Key].Used = Time()
    local nLifeTM = tTimer[2]
    if(nLifeTM <= 0) then
      return StatusLog(Place[Key],"TimerRestart: Timer life ignored") end
    local sModeTM = tTimer[1]
    if(sModeTM == "CQT") then
      sModeTM = "CQT" -- Just for something to do here and to be known that this is mode CQT
    elseif(sModeTM == "OBJ") then
      local keyTimerID = stringImplode(GetOpVar("OPSYM_DIVIDER"),tKeys)
      if(not timerExists(keyTimerID)) then
        return StatusLog(nil,"TimerRestart: Timer missing <"..keyTimerID..">") end
      timerStart(keyTimerID)
    else return StatusLog(nil,"TimerRestart: Timer mode not found <"..sModeTM..">") end
  elseif(sModeDB == "LUA") then Place[Key].Used = Time()
  else return StatusLog(nil,"TimerRestart: Wrong database mode") end
  return Place[Key]
end

function CacheBoxLayout(oEnt,nRot,nCamX,nCamZ)
  if(not (oEnt and oEnt:IsValid())) then
    return StatusLog(nil,"CacheBoxLayout: Entity invalid") end
  local sMod = oEnt:GetModel()
  local oRec = CacheQueryPiece(sMod)  
  if(not IsExistent(oRec)) then
    return StatusLog(nil,"CacheBoxLayout: Piece record invalid <"..sMod..">") end
  local Box = oRec.Layout
  if(not IsExistent(Box)) then
    local vMin, vMax
    oRec.Layout = {}; Box = oRec.Layout
    if    (CLIENT) then vMin, vMax = oEnt:GetRenderBounds()
    elseif(SERVER) then vMin, vMax = oEnt:OBBMins(), oEnt:OBBMaxs()
    else return StatusLog(nil,"CacheBoxLayout: Wrong instance") end
    Box.Ang = Angle()  -- Layout entity angle
    Box.Cen = Vector() -- Layout entity centre
    Box.Cen:Set(vMax); Box.Cen:Add(vMin); Box.Cen:Mul(0.5)
    Box.Eye = oEnt:LocalToWorld(Box.Cen) -- Layout camera eye
    Box.Len = ((vMax - vMin):Length() / 2) -- Layout border sphere radius
    Box.Cam = Vector(); Box.Cam:Set(Box.Eye)  -- Layout camera position
    AddVectorXYZ(Box.Cam,Box.Len*(tonumber(nCamX) or 0),0,Box.Len*(tonumber(nCamZ) or 0))
    LogInstance("CacheBoxLayout: "..tostring(Box.Cen).." #"..tostring(Box.Len))
  end; Box.Ang[caY] = (tonumber(nRot) or 0) * Time()
  return Box
end

-- Cashing the selected Piece Result
function CacheQueryPiece(sModel)
  if(not IsExistent(sModel)) then
    return StatusLog(nil,"CacheQueryPiece: Model does not exist") end
  if(not IsString(sModel)) then
    return StatusLog(nil,"CacheQueryPiece: Model {"..type(sModel).."}<"..tostring(sModel).."> not string") end
  if(IsEmptyString(sModel)) then
    return StatusLog(nil,"CacheQueryPiece: Model empty string") end
  if(not utilIsValidModel(sModel)) then
    return StatusLog(nil,"CacheQueryPiece: Model invalid") end
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not defTable) then
    return StatusLog(nil,"CacheQueryPiece: Table definition missing") end
  local namTable = defTable.Name
  local Cache    = libCache[namTable] -- Match the model casing
  local sModel   = MatchType(defTable,sModel,1,false,"",true,true)
  if(not IsExistent(Cache)) then
    return StatusLog(nil,"CacheQueryPiece: Cache not allocated for <"..namTable..">") end
  local caInd    = {namTable,sModel}
  local stPiece  = Cache[sModel]
  if(IsExistent(stPiece) and IsExistent(stPiece.Kept)) then
    if(stPiece.Kept > 0) then
      return TimerRestart(libCache,caInd,defTable,"CacheQueryPiece") end
    return nil
  else
    local sModeDB = GetOpVar("MODE_DATABASE")
    if(sModeDB == "SQL") then
      LogInstance("CacheQueryPiece: Model >> Pool <"..stringToFileName(sModel)..">")
      Cache[sModel] = {}
      stPiece = Cache[sModel]
      stPiece.Kept = 0
      local Q = SQLBuildSelect(defTable,nil,{{1,sModel}})
      if(not IsExistent(Q)) then
        return StatusLog(nil,"CacheQueryPiece: Build error <"..SQLBuildError()..">") end
      local qData = sqlQuery(Q)
      if(not qData and IsBool(qData)) then
        return StatusLog(nil,"CacheQueryPiece: SQL exec error <"..sqlLastError()..">") end
      if(not (qData and qData[1])) then
        return StatusLog(nil,"CacheQueryPiece: No data found <"..Q..">") end
      stPiece.Kept = 1 --- Found at least one record
      stPiece.Slot = sModel
      stPiece.Type = qData[1][defTable[2][1]]
      stPiece.Name = qData[1][defTable[3][1]]
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
          return StatusLog(nil,"CacheQueryPiece: Cannot process offset #"..tostring(stPiece.Kept).." for <"..sModel..">")
        end
        stPiece.Kept = stPiece.Kept + 1
      end
      return TimerAttach(libCache,caInd,defTable,"CacheQueryPiece")
    elseif(sModeDB == "LUA") then return StatusLog(nil,"CacheQueryPiece: Record not located")
    else return StatusLog(nil,"CacheQueryPiece: Wrong database mode <"..sModeDB..">") end
  end
end


----------------------- PANEL QUERY -------------------------------

--- Used to Populate the CPanel Tree
function CacheQueryPanel()
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not defTable) then
    return StatusLog(false,"CacheQueryPanel: Missing table definition") end
  local namTable = defTable.Name
  local keyPanel = GetOpVar("HASH_USER_PANEL")
  if(not IsExistent(libCache[namTable])) then
    return StatusLog(nil,"CacheQueryPanel: Cache not allocated for <"..namTable..">") end
  local stPanel = libCache[keyPanel]
  local caInd = {keyPanel}
  if(IsExistent(stPanel) and IsExistent(stPanel.Kept)) then
    LogInstance("CacheQueryPanel: From Pool")
    if(stPanel.Kept > 0) then
      return TimerRestart(libCache,caInd,defTable,"CacheQueryPanel") end
    return nil
  else
    libCache[keyPanel] = {}
    stPanel = libCache[keyPanel]
    local sModeDB = GetOpVar("MODE_DATABASE")
    if(sModeDB == "SQL") then
      local Q = SQLBuildSelect(defTable,{1,2,3},{{4,1}},{2,3})
      if(not IsExistent(Q)) then
        return StatusLog(nil,"CacheQueryPanel: Build error: <"..SQLBuildError()..">") end
      local qData = sqlQuery(Q)
      if(not qData and IsBool(qData)) then
        return StatusLog(nil,"CacheQueryPanel: SQL exec error <"..sqlLastError()..">") end
      if(not (qData and qData[1])) then
        return StatusLog(nil,"CacheQueryPanel: No data found <"..Q..">") end
      stPanel.Kept = 1
      while(qData[stPanel.Kept]) do
        stPanel[stPanel.Kept] = qData[stPanel.Kept]
        stPanel.Kept = stPanel.Kept + 1
      end
      return TimerAttach(libCache,caInd,defTable,"CacheQueryPanel")
    elseif(sModeDB == "LUA") then
      local Cache = libCache[namTable]
      local tData = {}
      local iNdex = 0
      for sModel, tRecord in pairs(Cache) do
        tData[sModel] = {[defTable[1][1]] = sModel, [defTable[2][1]] = tRecord.Type, [defTable[3][1]] = tRecord.Name}
      end
      local tSorted = Sort(tData,nil,{defTable[2][1],defTable[3][1]})
      if(not tSorted) then
        return StatusLog(nil,"CacheQueryPanel: Cannot sort cache data") end
      iNdex = 1
      while(tSorted[iNdex]) do
        stPanel[iNdex] = tData[tSorted[iNdex].Key]
        iNdex = iNdex + 1
      end
      return stPanel
    else return StatusLog(nil,"CacheQueryPanel: Wrong database mode <"..sModeDB..">") end
    LogInstance("CacheQueryPanel: To Pool")
  end
end

---------------------- EXPORT --------------------------------

local function GetFieldsName(defTable,sDelim)
  if(not IsExistent(sDelim)) then return "" end
  local sDelim  = stringSub(tostring(sDelim),1,1)
  local sResult = ""
  if(IsEmptyString(sDelim)) then
    return StatusLog("","GetFieldsName: Invalid delimiter for <"..defTable.Name..">") end
  local iCount  = 1
  local namField
  while(defTable[iCount]) do
    namField = defTable[iCount][1]
    if(not IsString(namField)) then
      return StatusLog("","GetFieldsName: Field #"..iCount
               .." {"..type(namField).."}<"..tostring(namField).."> not string") end
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
    return StatusLog(false,"ImportFromDSV: Table {"..type(sTable).."}<"..tostring(sTable).."> not string") end
  local defTable = GetOpVar("DEFTABLE_"..sTable)
  if(not defTable) then
    return StatusLog(false,"ImportFromDSV: Missing table definition for <"..sTable..">") end
  local namTable = defTable.Name
  local fName = GetOpVar("DIRPATH_BAS")..GetOpVar("DIRPATH_DSV")
        fName = fName..(sPrefix or GetInstPref())..namTable..".txt"
  local F = fileOpen(fName, "r", "DATA")
  if(not F) then return StatusLog(false,"ImportFromDSV: fileOpen("..fName..".txt) Failed") end
  local Line = ""
  local TabLen = stringLen(namTable)
  local LinLen = 0
  local ComCnt = 0
  local SymOff = GetOpVar("OPSYM_DISABLE")
  local Ch = "X" -- Just to be something
  while(Ch) do
    Ch = F:Read(1)
    if(not Ch) then return end
    if(Ch == "\n") then
      LinLen = stringLen(Line)
      if(stringSub(Line,LinLen,LinLen) == "\r") then
        Line = stringSub(Line,1,LinLen-1)
        LinLen = LinLen - 1
      end
      if(not (stringSub(Line,1,1) == SymOff)) then
        if(stringSub(Line,1,TabLen) == namTable) then
          local Data = stringExplode(sDelim,stringSub(Line,TabLen+2,LinLen))
          for k,v in pairs(Data) do
            local vLen = stringLen(v)
            if(stringSub(v,1,1) == "\"" and stringSub(v,vLen,vLen) == "\"") then
              Data[k] = stringSub(v,2,vLen-1)
            end
          end
          if(bCommit) then InsertRecord(sTable,Data) end
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
    return StatusLog(false,"ExportIntoFile: Table {"..type(sTable).."}<"..tostring(sTable).."> not string") end
  if(not IsString(sMethod)) then
    return StatusLog(false,"ExportIntoFile: Export mode {"..type(sMethod).."}<"..tostring(sMethod).."> not string") end
  local defTable = GetOpVar("DEFTABLE_"..sTable)
  if(not defTable) then
    return StatusLog(false,"ExportIntoFile: Missing table definition for <"..sTable..">") end
  local fName = GetOpVar("DIRPATH_BAS")
  local namTable = defTable.Name
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  if    (sMethod == "DSV") then fName = fName..GetOpVar("DIRPATH_DSV")
  elseif(sMethod == "INS") then fName = fName..GetOpVar("DIRPATH_EXP")
  else return StatusLog(false,"Missed export method: <"..sMethod..">") end
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  fName = fName..(sPrefix or GetInstPref())..namTable..".txt"
  local F = fileOpen(fName, "w", "DATA" )
  if(not F) then return StatusLog(false,"ExportIntoFile: fileOpen("..fName..") Failed") end
  local sData = ""
  local sTemp = ""
  local sModeDB = GetOpVar("MODE_DATABASE")
  F:Write("# ExportIntoFile( "..sMethod.." ): "..osDate().." [ "..sModeDB.." ]".."\n")
  F:Write("# Data settings: "..GetFieldsName(defTable,sDelim).."\n")
  if(sModeDB == "SQL") then
    local Q = ""
    if(sTable == "PIECES") then Q = SQLBuildSelect(defTable,nil,nil,{2,3,1,4})
    else                        Q = SQLBuildSelect(defTable,nil,nil,nil) end
    if(not IsExistent(Q)) then return StatusLog(false,"ExportIntoFile: Build error <"..SQLBuildError()..">") end
    F:Write("# Query ran: <"..Q..">\n")
    local qData = sqlQuery(Q)
    if(not qData and IsBool(qData)) then
      return StatusLog(nil,"ExportIntoFile: SQL exec error <"..sqlLastError()..">") end
    if(not (qData and qData[1])) then
      return StatusLog(false,"ExportIntoFile: No data found <"..Q..">") end
    local iCnt, iInd, qRec = 1, 1, nil
    if    (sMethod == "DSV") then sData = namTable..sDelim
    elseif(sMethod == "INS") then sData = "  asmlib.InsertRecord(\""..sTable.."\", {" end
    while(qData[iCnt]) do
      iInd  = 1
      sTemp = sData
      qRec  = qData[iCnt]
      while(defTable[iInd]) do -- The data is already inserted, so matching will not crash
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
    local Cache = libCache[namTable]
    if(not IsExistent(Cache)) then
      return StatusLog(false,"ExportIntoFile: Table <"..namTable.."> cache not allocated") end
    if(sTable == "PIECES") then
      local tData = {}
      local iInd iNdex = 1,1
      for sModel, tRecord in pairs(Cache) do
        sData = tRecord.Type..tRecord.Name..sModel
        tData[sModel] = {[defTable[1][1]] = sData}
      end
      local tSorted = Sort(tData,nil,{defTable[1][1]})
      if(not tSorted) then
        return StatusLog(false,"ExportIntoFile: Cannot sort cache data") end
      iNdex = 1
      while(tSorted[iNdex]) do
        iInd = 1
        tData = Cache[tSorted[iNdex].Key]
        if    (sMethod == "DSV") then sData = namTable..sDelim
        elseif(sMethod == "INS") then sData = "  asmlib.InsertRecord(\""..sTable.."\", {" end
        sData = sData..MatchType(defTable,tSorted[iNdex].Key,1,true,"\"")..sDelim..
                       MatchType(defTable,tData.Type,2,true,"\"")..sDelim..
                       MatchType(defTable,tData.Name,3,true,"\"")..sDelim
        -- Matching crashes only for numbers
        while(tData.Offs[iInd]) do -- The number is already inserted, so there will be no crash
          sTemp = sData..MatchType(defTable,iInd,4,true,"\"")..sDelim..
                        "\""..StringPOA(tData.Offs[iInd].P,"V").."\""..sDelim..
                        "\""..StringPOA(tData.Offs[iInd].O,"V").."\""..sDelim..
                        "\""..StringPOA(tData.Offs[iInd].A,"A").."\""
          if    (sMethod == "DSV") then sTemp = sTemp.."\n"
          elseif(sMethod == "INS") then sTemp = sTemp.."})\n" end
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

function GetMCWorld(oEnt,vdbMCL)
  if(not vdbMCL) then return end
  if(not (oEnt and oEnt:IsValid())) then return end
  local vMCW = Vector(vdbMCL[cvX],vdbMCL[cvY],vdbMCL[cvZ])
        vMCW:Rotate(oEnt:GetAngles())
        vMCW:Add(oEnt:GetPos())
  return vMCW
end

function GetMCWorldPosAng(vPos,vAng,vdbMCL)
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

----------------------------- SNAPPING ------------------------------

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
  if(not IsExistent(Ply)) then
    return StatusLog(nil,"GetEntityOrTrace: Player missing") end
  local Trace = Ply:GetEyeTrace()
  if(not IsExistent(Trace)) then
    return StatusLog(nil,"GetEntityOrTrace: Trace missing") end
  if(not Trace.Hit) then -- Boolean
    return StatusLog(nil,"GetEntityOrTrace: Trace not hit") end
  if(Trace.HitWorld) then -- Boolean
    return StatusLog(nil,"GetEntityOrTrace: Trace hit world") end
  local trEnt = Trace.Entity
  if(not (trEnt and trEnt:IsValid())) then
    return StatusLog(nil,"GetEntityOrTrace: Trace entity invalid") end
  return StatusLog(trEnt,"GetEntityOrTrace: Success "..tostring(trEnt))
end

function GetPropSkin(oEnt)
  local skEnt = GetEntityOrTrace(oEnt)
  if(not IsExistent(skEnt)) then
    return StatusLog("","GetPropSkin: Failed to gather entity") end
  if(IsOther(skEnt)) then
    return StatusLog("","GetPropSkin: Entity other type") end
  local Skin = tonumber(skEnt:GetSkin())
  if(not IsExistent(Skin)) then return StatusLog("","GetPropSkin: Skin number mismatch") end
  return StatusLog(tostring(Skin),"GetPropSkin: Success "..tostring(skEn))
end

function GetPropBodyGrp(oEnt)
  local bgEnt = GetEntityOrTrace(oEnt)
  if(not IsExistent(bgEnt)) then
    return StatusLog("","GetPropBodyGrp: Failed to gather entity") end
  if(IsOther(bgEnt)) then
    return StatusLog("","GetPropBodyGrp: Entity other type") end
  local BGs = bgEnt:GetBodyGroups()
  if(not (BGs and BGs[1])) then
    return StatusLog("","GetPropBodyGrp: Bodygroup table empty") end
  local Rez, Cnt = "", 1
  local symSep = GetOpVar("OPSYM_SEPARATOR")
  while(BGs[Cnt]) do
    Rez = Rez..symSep..tostring(bgEnt:GetBodygroup(BGs[Cnt].id) or 0)
    Cnt = Cnt + 1
  end
  Rez = stringSub(Rez,2,-1)
  Print(BGs,"GetPropBodyGrp: BGs")
  return StatusLog(Rez,"GetPropBodyGrp: Success <"..Rez..">")
end

function AttachBodyGroups(ePiece,sBgrpIDs)
  if(not (ePiece and ePiece:IsValid())) then
    return StatusLog(false,"AttachBodyGroups: Base entity invalid") end
  local sBgrpIDs = tostring(sBgrpIDs or "")
  LogInstance("AttachBodyGroups: <"..sBgrpIDs..">")
  local Cnt = 1
  local BGs = ePiece:GetBodyGroups()
  local IDs = stringExplode(GetOpVar("OPSYM_SEPARATOR"),sBgrpIDs)
  while(BGs[Cnt] and IDs[Cnt]) do
    local itrBG = BGs[Cnt]
    local maxID = (ePiece:GetBodygroupCount(itrBG.id) - 1)
    local itrID = mathClamp(mathFloor(tonumber(IDs[Cnt]) or 0),0,maxID)
    LogInstance("ePiece:SetBodygroup("..tostring(itrBG.id)..","..tostring(itrID)..") ["..tostring(maxID).."]")
    ePiece:SetBodygroup(itrBG.id,itrID)
    Cnt = Cnt + 1
  end
  return StatusLog(true,"AttachBodyGroups: Success")
end

function MakePiece(sModel,vPos,aAng,nMass,sBgSkIDs,clColor)
  if(CLIENT) then return StatusLog(nil,"MakePiece: Working on client") end
  local stPiece = CacheQueryPiece(sModel)
  if(not IsExistent(stPiece)) then
    return StatusLog(nil,"MakePiece: Record missing <"..sModel..">") end
  local ePiece = entsCreate("prop_physics")
  if(not (ePiece and ePiece:IsValid())) then
    return StatusLog(nil,"MakePiece: Entity invalid") end
  ePiece:SetCollisionGroup(COLLISION_GROUP_NONE)
  ePiece:SetSolid(SOLID_VPHYSICS)
  ePiece:SetMoveType(MOVETYPE_VPHYSICS)
  ePiece:SetNotSolid(false)
  ePiece:SetModel(sModel)
  ePiece:SetPos(vPos or GetOpVar("VEC_ZERO"))
  ePiece:SetAngles(aAng or GetOpVar("ANG_ZERO"))
  ePiece:Spawn()
  ePiece:Activate()
  ePiece:SetRenderMode(RENDERMODE_TRANSALPHA)
  ePiece:SetColor(clColor or Color(255,255,255,255))
  ePiece:DrawShadow(false)
  ePiece:PhysWake()
  local phPiece = ePiece:GetPhysicsObject()
  if(not (phPiece and phPiece:IsValid())) then
    ePiece:Remove()
    return StatusLog(nil,"MakePiece: Entity phys object invalid")
  end
  phPiece:EnableMotion(false)
  phPiece:SetMass(mathClamp(tonumber(nMass) or 1,1,GetOpVar("MAX_MASS")))
  local BgSk = stringExplode(GetOpVar("OPSYM_DIRECTORY"),(sBgSkIDs or ""))
  ePiece:SetSkin(mathClamp(tonumber(BgSk[2]) or 0,0,ePiece:SkinCount()-1))
  if(not AttachBodyGroups(ePiece,BgSk[1] or "")) then
    ePiece:Remove()
    return StatusLog(nil,"MakePiece: Failed to attach bodygroups")
  end
  return StatusLog(ePiece,"MakePiece: Success "..tostring(ePiece))
end

function ApplyPhysicalAnchor(ePiece,eBase,vPos,vNorm,nID,nNoCollid,nForceLim,nFreeze,nGrav,nNoPhyGun)
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
  if(not constraintCanConstrain(ePiece,0)) then
    return StatusLog(false,"Piece:Anchor() Cannot constrain Piece")
  end
  local pyPiece = ePiece:GetPhysicsObject()
  if(not (pyPiece and pyPiece:IsValid())) then
    return StatusLog(false,"Piece:Anchor() Phys Piece not valid")
  end
  constructSetPhysProp(nil,ePiece,0,pyPiece,{Material = "gmod_ice"})
  if(Freeze == 0) then
    pyPiece:EnableMotion(true)
  end
  if(Gravity == 0) then
    constructSetPhysProp(nil,ePiece,0,pyPiece,{GravityToggle = false})
  end
  if(NoPhyGun ~= 0) then --  is my custom child ...
    ePiece:SetUnFreezable(true)
    ePiece.PhysgunDisabled = true
    duplicatorStoreEntityModifier(ePiece,GetToolPrefL().."nophysgun",{[1] = true})
  end
  if(not IsIn and ConID == 1) then
      IsIn = ConID
  end
  if(not (eBase and eBase:IsValid())) then
    return StatusLog(0,"Piece:Anchor() Base not valid")
  end
  if(not constraintCanConstrain(eBase,0)) then
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

function SetBoundPos(ePiece,vPos,oPly,sMode)
  if(not (ePiece and ePiece:IsValid())) then
    return StatusLog(false,"Piece:SetBoundPos: Entity invalid") end
  if(not vPos) then
    return StatusLog(false,"Piece:SetBoundPos: Position invalid") end
  if(not oPly) then
    return StatusLog(false,"Piece:SetBoundPos: Player invalid") end
  local sMode = tostring(sMode or "LOG")
  if(sMode == "OFF") then
    ePiece:SetPos(vPos)
    return StatusLog(true,"Piece:SetBoundPos("..sMode..") Tuned off")
  end
  if(utilIsInWorld(vPos)) then -- Error mode is "LOG" by default
    ePiece:SetPos(vPos)
  else
    ePiece:Remove()
    if(sMode == "HINT" or sMode == "GENERIC" or sMode == "ERROR") then
      PrintNotifyPly(oPly,"Position out of map bounds!",sMode) end
    return StatusLog(false,"Piece:SetBoundPos("..sMode.."): Position out of map bounds")
  end
  return StatusLog(true,"Piece:SetBoundPos("..sMode.."): Success")
end

function MakeCoVar(sShortName, sValue, tBorder, nFlags, sInfo)
  if(not IsString(sShortName)) then
    return StatusLog(nil,"MakeCvar: CVar name {"..type(sShortName).."}<"..tostring(sShortName).."> not string") end
  if(not IsExistent(sValue)) then
    return StatusLog(nil,"MakeCvar: Wrong default value <"..tostring(sValue)..">") end
  if(not IsString(sInfo)) then
    return StatusLog(nil,"MakeCvar: CVar info {"..type(sInfo).."}<"..tostring(sInfo).."> not string") end
  local sVar = GetOpVar("TOOLNAME_PL")..stringLower(sShortName)
  if(tBorder and (type(tBorder) == "table") and tBorder[1] and tBorder[2]) then
    local Border = GetOpVar("TABLE_BORDERS")
    Border["cvar_"..sVar] = tBorder
  end
  return CreateConVar(sVar, sValue, nFlags, sInfo)
end

function GetCoVar(sShortName, sMode)
  if(not IsString(sShortName)) then
    return StatusLog(nil,"GetCoVar: CVar name {"..type(sShortName).."}<"..tostring(sShortName).."> not string") end
  if(not IsString(sMode)) then
    return StatusLog(nil,"GetCoVar: CVar mode {"..type(sMode).."}<"..tostring(sMode).."> not string") end
  local sVar = GetOpVar("TOOLNAME_PL")..stringLower(sShortName)
  local CVar = GetConVar(sVar)
  if(not IsExistent(CVar)) then
    return StatusLog(nil,"GetCoVar("..sShortName..", "..sMode.."): Missing CVar object") end
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
