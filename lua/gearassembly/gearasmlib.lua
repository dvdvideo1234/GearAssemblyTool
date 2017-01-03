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

---------------------------- PRIMITIVES ----------------------------
function Delay(nAdd)
  local nAdd = tonumber(nAdd) or 0
  if(nAdd > 0) then
    local tmEnd = osClock() + nAdd
    while(osClock() < tmEnd) do end
  end
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

function IsEmptyString(anyValue)
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

function IsPlayer(oPly)
  if(not IsExistent(oPly)) then return false end
  if(not oPly:IsValid  ()) then return false end
  if(not oPly:IsPlayer ()) then return false end
  return true
end

function IsOther(oEnt)
  if(not IsExistent(oEnt)) then return true end
  if(not oEnt:IsValid())   then return true end
  if(oEnt:IsPlayer())      then return true end
  if(oEnt:IsVehicle())     then return true end
  if(oEnt:IsNPC())         then return true end
  if(oEnt:IsRagdoll())     then return true end
  if(oEnt:IsWeapon())      then return true end
  if(oEnt:IsWidget())      then return true end
  return false
end

------------------ LOGS ------------------------
local function FormatNumberMax(nNum,nMax)
  local nNum = tonumber(nNum)
  local nMax = tonumber(nMax)
  if(not (nNum and nMax)) then return "" end
  return stringFormat("%"..stringLen(tostring(mathFloor(nMax))).."d",nNum)
end

function SetLogControl(nLines,sFile)
  SetOpVar("LOG_CURLOGS",0)
  SetOpVar("LOG_LOGFILE",tostring(sFile or ""))
  SetOpVar("LOG_MAXLOGS",mathFloor(tonumber(nLines) or 0))
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
  local sSors = ""
  if(GetOpVar("LOG_DEBUGEN")) then
    local sInfo = debugGetinfo(3) or {}
    sSors = sSors..(sInfo.linedefined and "["..sInfo.linedefined.."]" or "[n/a]")
    sSors = sSors..(sInfo.name and sInfo.name or "Main")
    sSors = sSors..(sInfo.currentline and ("["..sInfo.currentline.."]") or "[n/a]")
    sSors = sSors..(sInfo.nparams and (" #"..sInfo.nparams) or " #N")
    sSors = sSors..(sInfo.source and (" "..sInfo.source) or " @N")
  end
  local sInst   = ((SERVER and "SERVER" or nil) or (CLIENT and "CLIENT" or nil) or "NOINST")
  local sModeDB = GetOpVar("MODE_DATABASE")
  Log(sInst.." > "..sTrac..GetOpVar("TOOLNAME_NU").." ["..sModeDB.."] "..anyStuff)
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

function GetIndexes(sType)
  if(not IsString(sType)) then
    return StatusLog(nil,"GetIndexes: Type {"..type(sType).."}<"..tostring(sType).."> not string") end
  if    (sType == "V") then return cvX, cvY, cvZ
  elseif(sType == "A") then return caP, caY, caR
  elseif(sType == "S") then return csA, csB, csC, csD
  else return StatusLog(nil,"GetIndexes: Type <"..sType.."> not found") end
end

function SetIndexes(sType,I1,I2,I3,I4)
  if(not IsString(sType)) then
    return StatusLog(false,"SetIndexes: Type {"..type(sType).."}<"..tostring(sType).."> not string") end
  if    (sType == "V") then cvX, cvY, cvZ      = I1, I2, I3
  elseif(sType == "A") then caP, caY, caR      = I1, I2, I3
  elseif(sType == "S") then csA, csB, csC, csD = I1, I2, I3, I4
  else return StatusLog(false,"SetIndexes: Type <"..sType.."> not found") end
  return StatusLog(true,"SetIndexes["..sType.."]: Success")
end

function Init(sName,sPurpose)
  SetOpVar("TYPEMT_STRING",getmetatable("TYPEMT_STRING"))
  SetOpVar("TYPEMT_SCREEN",{})
  SetOpVar("TYPEMT_CONTAINER",{})
  if(not IsString(sName)) then
    return StatusPrint(false,"InitAssembly: Name <"..tostring(sName).."> not string") end
  if(not IsString(sPurpose)) then
    return StatusPrint(false,"InitAssembly: Purpose <"..tostring(sPurpose).."> not string") end
  if(IsEmptyString(sName) or tonumber(stringSub(sName,1,1))) then
    return StatusPrint(false,"InitAssembly: Name invalid") end
  if(IsEmptyString(sPurpose) or tonumber(stringSub(sPurpose,1,1))) then
    return StatusPrint(false,"InitAssembly: Purpose invalid") end
  SetOpVar("TIME_INIT",Time())
  SetOpVar("LOG_MAXLOGS",0)
  SetOpVar("LOG_CURLOGS",0)
  SetOpVar("LOG_LOGFILE","")
  SetOpVar("MAX_ROTATION",360)
  SetOpVar("ANG_ZERO",Angle())
  SetOpVar("VEC_ZERO",Vector())
  SetOpVar("OPSYM_DISABLE","#")
  SetOpVar("OPSYM_REVSIGN","@")
  SetOpVar("OPSYM_DIVIDER","_")
  SetOpVar("OPSYM_DIRECTORY","/")
  SetOpVar("OPSYM_SEPARATOR",",")
  SetOpVar("DIAG_SQUARE", 2 * mathSqrt(2))
  SetOpVar("GOLDEN_RATIO",1.61803398875)
  SetOpVar("NAME_INIT",stringLower(sName))
  SetOpVar("NAME_PERP",stringLower(sPurpose))
  SetOpVar("TOOLNAME_NL",stringLower(GetOpVar("NAME_INIT")..GetOpVar("NAME_PERP")))
  SetOpVar("TOOLNAME_NU",stringUpper(GetOpVar("NAME_INIT")..GetOpVar("NAME_PERP")))
  SetOpVar("TOOLNAME_PL",GetOpVar("TOOLNAME_NL").."_")
  SetOpVar("TOOLNAME_PU",GetOpVar("TOOLNAME_NU").."_")
  SetOpVar("DIRPATH_BAS",GetOpVar("TOOLNAME_NL")..GetOpVar("OPSYM_DIRECTORY"))
  SetOpVar("DIRPATH_INS","exp"..GetOpVar("OPSYM_DIRECTORY"))
  SetOpVar("DIRPATH_DSV","dsv"..GetOpVar("OPSYM_DIRECTORY"))
  SetOpVar("DIRPATH_LOG","")
  SetOpVar("MISS_NOID","N")    -- No ID selected
  SetOpVar("MISS_NOAV","N/A")  -- Not Available
  SetOpVar("MISS_NOMD","X")    -- No model
  SetOpVar("ARRAY_DECODEPOA",{0,0,0,1,1,1,false})
  SetOpVar("TABLE_FREQUENT_MODELS",{})
  SetOpVar("TABLE_BORDERS",{})
  SetOpVar("TABLE_CATEGORIES",{})
  SetOpVar("FILE_MODEL","%.mdl")
  SetOpVar("OOP_DEFAULTKEY","(!@<#_$|%^|&>*)DEFKEY(*>&|^%|$_#<@!)")
  SetOpVar("CVAR_LIMITNAME","asm"..GetOpVar("NAME_INIT").."s")
  SetOpVar("MODE_DATABASE",GetOpVar("MISS_NOAV"))
  SetOpVar("HASH_USER_PANEL",GetOpVar("TOOLNAME_PU").."USER_PANEL")
  SetOpVar("HASH_QUERY_STORE",GetOpVar("TOOLNAME_PU").."QHASH_QUERY")
  SetOpVar("HASH_PLAYER_KEYDOWN","PLAYER_KEYDOWN")
  SetOpVar("NAV_PIECE",{})
  SetOpVar("NAV_PANEL",{})
  SetOpVar("STRUCT_SPAWN",{
    F    = Vector(),
    R    = Vector(),
    U    = Vector(),
    OPos = Vector(),
    OAng = Angle (),
    SPos = Vector(),
    SAng = Angle (),
    DAng = Angle (),
    -- Holder
    HRec = 0,
    HPnt = Vector(), -- P
    HPos = Vector(), -- O
    HAng = Angle (), -- A
    -- Traced
    TRec = 0,
    TPnt = Vector(), -- P
    TPos = Vector(), -- O
    TAng = Angle ()  -- A
  })
  return StatusPrint(true,"InitAssembly: Success")
end

------------- ANGLE ---------------
function ToAngle(aBase)
  if(not aBase) then return StatusLog(nil,"ToAngle: Base invalid") end
  return Angle((tonumber(aBase[caP]) or 0), (tonumber(aBase[caY]) or 0), (tonumber(aBase[caR]) or 0))
end

function ExpAngle(aBase)
  if(not aBase) then return StatusLog(nil,"ExpAngle: Base invalid") end
  return (tonumber(aBase[caP]) or 0), (tonumber(aBase[caY]) or 0), (tonumber(aBase[caR]) or 0)
end

function AddAngle(aBase, aUnit)
  if(not aBase) then return StatusLog(nil,"AddAngle: Base invalid") end
  if(not aUnit) then return StatusLog(nil,"AddAngle: Unit invalid") end
  aBase[caP] = (tonumber(aBase[caP]) or 0) + (tonumber(aUnit[caP]) or 0)
  aBase[caY] = (tonumber(aBase[caY]) or 0) + (tonumber(aUnit[caY]) or 0)
  aBase[caR] = (tonumber(aBase[caR]) or 0) + (tonumber(aUnit[caR]) or 0)
end

function AddAnglePYR(aBase, nP, nY, nR)
  if(not aBase) then return StatusLog(nil,"AddAnglePYR: Base invalid") end
  aBase[caP] = (tonumber(aBase[caP]) or 0) + (tonumber(nP) or 0)
  aBase[caY] = (tonumber(aBase[caY]) or 0) + (tonumber(nY) or 0)
  aBase[caR] = (tonumber(aBase[caR]) or 0) + (tonumber(nR) or 0)
end

function SubAngle(aBase, aUnit)
  if(not aBase) then return StatusLog(nil,"SubAngle: Base invalid") end
  if(not aUnit) then return StatusLog(nil,"SubAngle: Unit invalid") end
  aBase[caP] = (tonumber(aBase[caP]) or 0) - (tonumber(aUnit[caP]) or 0)
  aBase[caY] = (tonumber(aBase[caY]) or 0) - (tonumber(aUnit[caY]) or 0)
  aBase[caR] = (tonumber(aBase[caR]) or 0) - (tonumber(aUnit[caR]) or 0)
end

function SubAnglePYR(aBase, nP, nY, nR)
  if(not aBase) then return StatusLog(nil,"SubAnglePYR: Base invalid") end
  aBase[caP] = (tonumber(aBase[caP]) or 0) - (tonumber(nP) or 0)
  aBase[caY] = (tonumber(aBase[caY]) or 0) - (tonumber(nY) or 0)
  aBase[caR] = (tonumber(aBase[caR]) or 0) - (tonumber(nR) or 0)
end

function NegAngle(aBase)
  if(not aBase ) then return StatusLog(nil,"NegAngle: Base invalid") end
  aBase[caP] = -(tonumber(aBase[caP]) or 0)
  aBase[caY] = -(tonumber(aBase[caY]) or 0)
  aBase[caR] = -(tonumber(aBase[caR]) or 0)
end

function SetAngle(aBase, aUnit)
  if(not aBase) then return StatusLog(nil,"SetAngle: Base invalid") end
  if(not aUnit) then return StatusLog(nil,"SetAngle: Unit invalid") end
  aBase[caP] = (tonumber(aUnit[caP]) or 0)
  aBase[caY] = (tonumber(aUnit[caY]) or 0)
  aBase[caR] = (tonumber(aUnit[caR]) or 0)
end

function SetAnglePYR(aBase, nP, nY, nR)
  if(not aBase) then return StatusLog(nil,"SetAnglePYR: Base invalid") end
  aBase[caP] = (tonumber(nP) or 0)
  aBase[caY] = (tonumber(nY) or 0)
  aBase[caR] = (tonumber(nR) or 0)
end

------------- VECTOR ---------------

function ToVector(vBase)
  if(not vBase) then return StatusLog(nil,"ToVector: Base invalid") end
  return Vector((tonumber(vBase[cvX]) or 0), (tonumber(vBase[cvY]) or 0), (tonumber(vBase[cvZ]) or 0))
end

function ExpVector(vBase)
  if(not vBase) then return StatusLog(nil,"ExpVector: Base invalid") end
  return (tonumber(vBase[cvX]) or 0), (tonumber(vBase[cvY]) or 0), (tonumber(vBase[cvZ]) or 0)
end

function GetLengthVector(vBase)
  if(not vBase) then return StatusLog(nil,"GetLengthVector: Base invalid") end
  local X = (tonumber(vBase[cvX]) or 0); X = X * X
  local Y = (tonumber(vBase[cvY]) or 0); Y = Y * Y
  local Z = (tonumber(vBase[cvZ]) or 0); Z = Z * Z
  return mathSqrt(X + Y + Z)
end

function RoundVector(vBase,nvRound)
  if(not vBase) then return StatusLog(nil,"RoundVector: Base invalid") end
  local R = tonumber(nvRound)
  if(not IsExistent(R)) then
    return StatusLog(nil,"RoundVector: Round NAN {"..type(nvRound).."}<"..tostring(nvRound)..">") end
  local X = (tonumber(vBase[cvX]) or 0); X = RoundValue(X,R); vBase[cvX] = X
  local Y = (tonumber(vBase[cvY]) or 0); Y = RoundValue(Y,R); vBase[cvY] = Y
  local Z = (tonumber(vBase[cvZ]) or 0); Z = RoundValue(Z,R); vBase[cvZ] = Z
end

function AddVector(vBase, vUnit)
  if(not vBase) then return StatusLog(nil,"AddVector: Base invalid") end
  if(not vUnit) then return StatusLog(nil,"AddVector: Unit invalid") end
  vBase[cvX] = (tonumber(vBase[cvX]) or 0) + (tonumber(vUnit[cvX]) or 0)
  vBase[cvY] = (tonumber(vBase[cvY]) or 0) + (tonumber(vUnit[cvY]) or 0)
  vBase[cvZ] = (tonumber(vBase[cvZ]) or 0) + (tonumber(vUnit[cvZ]) or 0)
end

function AddVectorXYZ(vBase, nX, nY, nZ)
  if(not vBase) then return StatusLog(nil,"AddVectorXYZ: Base invalid") end
  vBase[cvX] = (tonumber(vBase[cvX]) or 0) + (tonumber(nX) or 0)
  vBase[cvY] = (tonumber(vBase[cvY]) or 0) + (tonumber(nY) or 0)
  vBase[cvZ] = (tonumber(vBase[cvZ]) or 0) + (tonumber(nZ) or 0)
end

function SubVector(vBase, vUnit)
  if(not vBase) then return StatusLog(nil,"SubVector: Base invalid") end
  if(not vUnit) then return StatusLog(nil,"SubVector: Unit invalid") end
  vBase[cvX] = (tonumber(vBase[cvX]) or 0) - (tonumber(vUnit[cvX]) or 0)
  vBase[cvY] = (tonumber(vBase[cvY]) or 0) - (tonumber(vUnit[cvY]) or 0)
  vBase[cvZ] = (tonumber(vBase[cvZ]) or 0) - (tonumber(vUnit[cvZ]) or 0)
end

function SubVectorXYZ(vBase, nX, nY, nZ)
  if(not vBase) then return StatusLog(nil,"SubVectorXYZ: Base invalid") end
  vBase[cvX] = (tonumber(vBase[cvX]) or 0) - (tonumber(nX) or 0)
  vBase[cvY] = (tonumber(vBase[cvY]) or 0) - (tonumber(nY) or 0)
  vBase[cvZ] = (tonumber(vBase[cvZ]) or 0) - (tonumber(nZ) or 0)
end

function NegVector(vBase)
  if(not vBase) then return StatusLog(nil,"NegVector: Base invalid") end
  vBase[cvX] = -(tonumber(vBase[cvX]) or 0)
  vBase[cvY] = -(tonumber(vBase[cvY]) or 0)
  vBase[cvZ] = -(tonumber(vBase[cvZ]) or 0)
end

function SetVector(vBase, vUnit)
  if(not vBase) then return StatusLog(nil,"SetVector: Base invalid") end
  if(not vUnit) then return StatusLog(nil,"SetVector: Unit invalid") end
  vBase[cvX] = (tonumber(vUnit[cvX]) or 0)
  vBase[cvY] = (tonumber(vUnit[cvY]) or 0)
  vBase[cvZ] = (tonumber(vUnit[cvZ]) or 0)
end

function SetVectorXYZ(vBase, nX, nY, nZ)
  if(not vBase) then return StatusLog(nil,"SetVector: Base invalid") end
  vBase[cvX] = (tonumber(nX or 0))
  vBase[cvY] = (tonumber(nY or 0))
  vBase[cvZ] = (tonumber(nZ or 0))
end

function DecomposeByAngle(vBase,aUnit)
  if(not vBase) then return StatusLog(Vector(),"DecomposeByAngle: Base invalid") end
  if(not aUnit) then return StatusLog(Vector(),"DecomposeByAngle: Unit invalid") end
  local X = vBase:DotProduct(aUnit:Forward())
  local Y = vBase:DotProduct(aUnit:Right())
  local Z = vBase:DotProduct(aUnit:Up())
  SetVectorXYZ(vBase,X,Y,Z)
end

---------- OOP -----------------

function MakeContainer(sInfo,sDefKey)
  local Curs, Data = 0, {}
  local sSel, sIns, sDel, sMet = "", "", "", ""
  local Info = tostring(sInfo or "Storage container")
  local Key  = sDefKey or GetOpVar("OOP_DEFAULTKEY")
  local self = {}
  function self:GetInfo() return Info end
  function self:GetSize() return Curs end
  function self:GetData() return Data end
  function self:Insert(nsKey,anyValue)
    sIns = nsKey or Key; sMet = "I"
    if(not IsExistent(Data[sIns])) then Curs = Curs + 1; end
    Data[sIns] = anyValue
  end
  function self:Select(nsKey)
    sSel = nsKey or Key; return Data[sSel]
  end
  function self:Delete(nsKey,fnDel)
    sDel = nsKey or Key; sMet = "D"
    if(IsExistent(Data[sDel])) then
      if(IsExistent(fnDel)) then
        fnDel(Data[sDel])
      end
      Data[sDel] = nil
      Curs = Curs - 1
    end
  end
  function self:GetHistory()
    return tostring(sMet)..GetOpVar("OPSYM_REVSIGN")..
           tostring(sSel)..GetOpVar("OPSYM_DIRECTORY")..
           tostring(sIns)..GetOpVar("OPSYM_DIRECTORY")..
           tostring(sDel)
  end
  setmetatable(self,GetOpVar("TYPEMT_CONTAINER"))
  return self
end

--[[
 * Creates a screen object better user api fro drawing on the gmod screens
 * The drawing methods are the following:
 * SURF - Uses the surface library to draw directly
 * SEGM - Uses the surface library to draw line segment interpolations
 * CAM3 - Uses the render  library to draw shapes in 3D space
 * Operation keys for storing initial arguments are the following:
 * TXT - Drawing text
 * LIN - Drawing lines
 * REC - Drawing a rectangle
 * CIR - Drawing a circle
]]--
function MakeScreen(sW,sH,eW,eH,conColors)
  if(SERVER) then return nil end
  local sW, sH = (tonumber(sW) or 0), (tonumber(sH) or 0)
  local eW, eH = (tonumber(eW) or 0), (tonumber(eH) or 0)
  if(sW < 0 or sH < 0) then return StatusLog(nil,"MakeScreen: Start dimension invalid") end
  if(eW < 0 or eH < 0) then return StatusLog(nil,"MakeScreen: End dimension invalid") end
  local Colors = {List = conColors, Key = GetOpVar("OOP_DEFAULTKEY"), Default = Color(255,255,255,255)}
  if(Colors.List) then -- Container check
    if(getmetatable(Colors.List) ~= GetOpVar("TYPEMT_CONTAINER"))
      then return StatusLog(nil,"MakeScreen: Color list not container") end
  else -- Color list is not present then create one
    Colors.List = MakeContainer("Colors")
  end
  local DrawMeth, DrawArgs, Text = {}, {}, {}
  Text.DrwX, Text.DrwY = 0, 0
  Text.ScrW, Text.ScrH = 0, 0
  Text.LstW, Text.LstH = 0, 0
  local self = {}
  function self:GetSize() return (eW-sW), (eH-sH) end
  function self:GetCenter(nX,nY)
    local nW, nH = self:GetSize()
    local nX = (nW / 2) + (tonumber(nX) or 0)
    local nY = (nH / 2) + (tonumber(nY) or 0)
    return nX, nY
  end
  function self:SetColor(keyColor,sMeth)
    if(not IsExistent(keyColor) and not IsExistent(sMeth)) then
      Colors.Key = GetOpVar("OOP_DEFAULTKEY")
      return StatusLog(nil,"MakeScreen.SetColor: Color reset") end
    local keyColor = keyColor or Colors.Key
    if(not IsExistent(keyColor)) then
      return StatusLog(nil,"MakeScreen.SetColor: Indexing skipped") end
    if(not IsString  (   sMeth)) then
      return StatusLog(nil,"MakeScreen.SetColor: Method <"..tostring(method).."> invalid") end
    local rgbColor = Colors.List:Select(keyColor)
    if(not IsExistent(rgbColor)) then rgbColor = Colors.Default end
    if(tostring(Colors.Key) ~= tostring(keyColor)) then -- Update the color only on change
      surfaceSetDrawColor(rgbColor.r, rgbColor.g, rgbColor.b, rgbColor.a)
      surfaceSetTextColor(rgbColor.r, rgbColor.g, rgbColor.b, rgbColor.a)
      Colors.Key = keyColor;
    end -- The drawing color for these two methods uses surface library
    return rgbColor, keyColor
  end
  function self:SetDrawParam(sMeth,tArgs,sKey)
    sMeth = tostring(sMeth or DrawMeth[sKey])
    tArgs =         (tArgs or DrawArgs[sKey])
    if(sMeth == "SURF") then
      if(sKey == "TXT" and tArgs ~= DrawArgs[sKey]) then
        surfaceSetFont(tostring(tArgs[1] or "Default")) end -- Time to set the font again
    end
    DrawMeth[sKey] = sMeth; DrawArgs[sKey] = tArgs
    return sMeth, tArgs
  end
  function self:SetTextEdge(nX,nY)
    Text.ScrW, Text.ScrH = 0, 0
    Text.LstW, Text.LstH = 0, 0
    Text.DrwX = (tonumber(nX) or 0)
    Text.DrwY = (tonumber(nY) or 0)
  end
  function self:GetTextState(nX,nY,nW,nH)
    return (Text.DrwX + (nX or 0)), (Text.DrwY + (nY or 0)),
           (Text.ScrW  + (nW or 0)), (Text.ScrH  + (nH or 0)),
            Text.LstW, Text.LstH
  end
  function self:DrawText(sText,keyColor,sMeth,tArgs)
    local sMeth, tArgs = self:SetDrawParam(sMeth,tArgs,"TXT")
    self:SetColor(keyColor, sMeth)
    if(sMeth == "SURF") then
      surfaceSetTextPos(Text.DrwX,Text.DrwY); surfaceDrawText(sText)
      Text.LstW, Text.LstH = surfaceGetTextSize(sText)
      Text.DrwY = Text.DrwY + Text.LstH
      if(Text.LstW > Text.ScrW) then Text.ScrW = Text.LstW end
      Text.ScrH = Text.DrwY
    else return StatusLog(nil,"MakeScreen.DrawText: Draw method <"..sMeth.."> invalid") end
  end
  function self:DrawTextAdd(sText,keyColor,sMeth,tArgs)
    local sMeth, tArgs = self:SetDrawParam(sMeth,tArgs,"TXT")
    self:SetColor(keyColor, sMeth)
    if(sMeth == "SURF") then
      surfaceSetTextPos(Text.DrwX + Text.LstW,Text.DrwY - Text.LstH)
      surfaceDrawText(sText)
      local LstW, LstH = surfaceGetTextSize(sText)
      Text.LstW, Text.LstH = (Text.LstW + LstW), LstH
      if(Text.LstW > Text.ScrW) then Text.ScrW = Text.LstW end
      Text.ScrH = Text.DrwY
    else return StatusLog(nil,"MakeScreen.DrawTextAdd: Draw method <"..sMeth.."> invalid") end
  end
  function self:Enclose(xyPnt)
    if(xyPnt.x < sW) then return -1 end
    if(xyPnt.x > eW) then return -1 end
    if(xyPnt.y < sH) then return -1 end
    if(xyPnt.y > eH) then return -1 end
    return 1
  end
  function self:DrawLine(pS,pE,keyColor,sMeth,tArgs)
    if(not (pS and pE)) then return end
    local sMeth, tArgs = self:SetDrawParam(sMeth,tArgs,"LIN")
    local rgbCl, keyCl = self:SetColor(keyColor, sMeth)
    if(sMeth == "SURF") then
      if(self:Enclose(pS) == -1) then
        return StatusLog(nil,"MakeScreen.DrawLine: Start out of border") end
      if(self:Enclose(pE) == -1) then
        return StatusLog(nil,"MakeScreen.DrawLine: End out of border") end
      surfaceDrawLine(pS.x,pS.y,pE.x,pE.y)
    elseif(sMeth == "SEGM") then
      if(self:Enclose(pS) == -1) then
        return StatusLog(nil,"MakeScreen.DrawLine: Start out of border") end
      if(self:Enclose(pE) == -1) then
        return StatusLog(nil,"MakeScreen.DrawLine: End out of border") end
      local nIter = mathClamp((tonumber(tArgs[1]) or 1),1,200)
      if(nIter <= 0) then return end
      local nLx, nLy = (pE.x - pS.x), (pE.y - pS.y)
      local xyD = {x = (nLx / nIter), y = (nLy / nIter)}
      local xyOld, xyNew = {x = pS.x, y = pS.y}, {x = 0,y = 0}
      while(nIter > 0) do
        xyNew.x = xyOld.x + xyD.x
        xyNew.y = xyOld.y + xyD.y
        surfaceDrawLine(xyOld.x,xyOld.y,xyNew.x,xyNew.y)
        xyOld.x, xyOld.y = xyNew.x, xyNew.y
        nIter = nIter - 1;
      end
    elseif(sMeth == "CAM3") then
      renderDrawLine(pS,pE,rgbCl,(tArgs[1] and true or false))
    else return StatusLog(nil,"MakeScreen.DrawLine: Draw method <"..sMeth.."> invalid") end
  end
  function self:DrawRect(pS,pE,keyColor,sMeth,tArgs)
    local sMeth, tArgs = self:SetDrawParam(sMeth,tArgs,"REC")
    self:SetColor(keyColor,sMeth)
    if(sMeth == "SURF") then
      if(self:Enclose(pS) == -1) then
        return StatusLog(nil,"MakeScreen.DrawRect: Start out of border") end
      if(self:Enclose(pE) == -1) then
        return StatusLog(nil,"MakeScreen.DrawRect: End out of border") end
      surfaceSetTexture(surfaceGetTextureID(tostring(tArgs[1])))
      surfaceDrawTexturedRect(pS.x,pS.y,pE.x-pS.x,pE.y-pS.y)
    else return StatusLog(nil,"MakeScreen.DrawRect: Draw method <"..sMeth.."> invalid") end
  end
  function self:DrawCircle(pC,nRad,keyColor,sMeth,tArgs)
    local sMeth, tArgs = self:SetDrawParam(sMeth,tArgs,"CIR")
    local rgbCl, keyCl = self:SetColor(keyColor,sMeth)
    if(sMeth == "SURF") then surfaceDrawCircle(pC.x, pC.y, nRad, rgbCl)
    elseif(sMeth == "SEGM") then
      local nItr = mathClamp((tonumber(tArgs[1]) or 1),1,200)
      local nMax = (GetOpVar("MAX_ROTATION") * mathPi / 180)
      local nStp, nAng = (nMax / nItr), 0
      local xyOld, xyNew, xyRad = {x=0,y=0}, {x=0,y=0}, {x=nRad,y=0}
            xyOld.x = pC.x + xyRad.x
            xyOld.y = pC.y + xyRad.y
      while(nItr > 0) do
        nAng = nAng + nStp
        local nSin, nCos = mathSin(nAng), mathCos(nAng)
        xyNew.x = pC.x + (xyRad.x * nCos - xyRad.y * nSin)
        xyNew.y = pC.y + (xyRad.x * nSin + xyRad.y * nCos)
        surfaceDrawLine(xyOld.x,xyOld.y,xyNew.x,xyNew.y)
        xyOld.x, xyOld.y = xyNew.x, xyNew.y
        nItr = nItr - 1;
      end
    elseif(sMeth == "CAM3") then -- It is a projection of a sphere
      renderSetMaterial(Material(tostring(tArgs[1] or "color")))
      renderDrawSphere (pC,nRad,mathClamp(tArgs[2] or 1,1,200),
                                mathClamp(tArgs[3] or 1,1,200),rgbCl)
    else return StatusLog(nil,"MakeScreen.DrawCircle: Draw method <"..sMeth.."> invalid") end
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
  local nMesh  = tValue.Table[defTable[4][1]]
  local nUsed  = RoundValue(tValue.Value,0.001)
  local pnRec  = pnListView:AddLine(nUsed,nMesh,sType,sModel)
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
  local iCnt = mathFloor(tonumber(snCnt) or 0)
  if(not (tTable and (type(tTable) == "table") and (iCnt > 0))) then return 0 end
  local iInd  = 1
  if(not tTable[iInd]) then
    tTable[iInd] = {Value = nsValue, Table = tData }
    return iInd
  else
    while(tTable[iInd] and (tTable[iInd].Value < nsValue)) do
      iInd = iInd + 1
    end
    if(iInd > iCnt) then return iInd end
    while(iInd < iCnt) do
      tTable[iCnt] = tTable[iCnt - 1]
      iCnt = iCnt - 1
    end
    tTable[iInd] = { Value = nsValue, Table = tData }
    return iInd
  end
end

function GetFrequentModels(snCount)
  local snCount = tonumber(snCount) or 0
  if(snCount < 1) then
    return StatusLog(nil,"GetFrequentModels: Count not applicable") end
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not IsExistent(defTable)) then
    return StatusLog(nil,"GetFrequentModels: Missing table definition") end
  local tCache = libCache[defTable.Name]
  if(not IsExistent(tCache)) then
    return StatusLog(nil,"GetFrequentModels: Missing table cache space") end
  local iInd, tmNow = 1, Time()
  local frUsed = GetOpVar("TABLE_FREQUENT_MODELS")
  tableEmpty(frUsed)
  for Model, Record in pairs(tCache) do
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
  local nvSnp, nvVal = mathAbs(nSnap), mathAbs(nVal)
  local nRst, nRez = (nvVal % nvSnp), 0
  if((nvSnp - nRst) < nRst) then nRez = nvVal + nvSnp - nRst else nRez = nvVal - nRst end
  if(nVal < 0) then return -nRez; end
  return nRez;
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
  if(not Trace.Hit) then return false end
  if(Trace.HitWorld) then return false end
  local eEnt = Trace.Entity
  if(not eEnt) then return false end
  if(not eEnt:IsValid()) then return false end
  if(not eEnt:GetPhysicsObject():IsValid()) then return false end
  return true
end

local function BorderValue(nsVal,sName)
  if(not IsString(sName)) then return nsVal end
  if(not (IsString(nsVal) or tonumber(nsVal))) then
    return StatusLog(nsVal,"BorderValue: Value not comparable") end
  local Border = GetOpVar("TABLE_BORDERS")
        Border = Border[sName]
  if(IsExistent(Border)) then
    if(Border[1] and nsVal < Border[1]) then return Border[1] end
    if(Border[2] and nsVal > Border[2]) then return Border[2] end
  end
  return nsVal
end

function ModelToName(sModel,bNoSettings)
  if(not IsString(sModel)) then
    return StatusLog("","ModelToName: Argument {"..type(sModel).."}<"..tostring(sModel)..">") end
  if(IsEmptyString(sModel)) then return StatusLog("","ModelToName: Empty string") end
  local fCh, bCh, Cnt = "", "", 1
  local sSymDiv, sSymDir = GetOpVar("OPSYM_DIVIDER"), GetOpVar("OPSYM_DIRECTORY")
  local sModel = (stringSub(sModel,1, 1) ~= sSymDir) and (sSymDir..sModel) or sModel
        sModel =  stringGsub(stringToFileName(sModel),GetOpVar("FILE_MODEL"),"")
  local gModel =  stringSub(sModel,1,-1) -- Create a copy so we can select cut-off parts later on
  if(not bNoSettings) then
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
  end
  -- Trigger the capital-space using the divider
  if(stringSub(gModel,1,1) ~= sSymDiv) then gModel = sSymDiv..gModel end
  -- Here in gModel we have: _aaaaa_bbbb_ccccc
  fCh, bCh, sModel = stringFind(gModel,sSymDiv,1), 1, ""
  while(fCh) do
    if(fCh > bCh) then
      sModel = sModel..stringSub(gModel,bCh+2,fCh-1)
    end
    if(not IsEmptyString(sModel)) then sModel = sModel.." " end
    sModel = sModel..stringUpper(stringSub(gModel,fCh+1,fCh+1))
    bCh = fCh
    fCh = stringFind(gModel,sSymDiv,fCh+1)
  end
  return sModel..stringSub(gModel,bCh+2,-1)
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

local function IsEqualPOA(staPOA,stbPOA)
  if(not IsExistent(staPOA)) then
    return StatusLog(false,"EqualPOA: Missing offset A") end
  if(not IsExistent(stbPOA)) then
    return StatusLog(false,"EqualPOA: Missing offset B") end
  for kKey, vComp in pairs(staPOA) do
    if(kKey ~= csD and stbPOA[kKey] ~= vComp) then return false end
  end
  return true
end

local function IsZeroPOA(stPOA,sOffs)
  if(not IsString(sOffs)) then
    return StatusLog(nil,"IsZeroPOA: Mode {"..type(sOffs).."}<"..tostring(sOffs).."> not string") end
  if(not IsExistent(stPOA)) then
    return StatusLog(nil,"IsZeroPOA: Missing offset") end
  local ctA, ctB, ctC
  if    (sOffs == "V") then ctA, ctB, ctC = cvX, cvY, cvZ
  elseif(sOffs == "A") then ctA, ctB, ctC = caP, caY, caR
  else return StatusLog(nil,"IsZeroPOA: Missed offset mode "..sOffs) end
  if(stPOA[ctA] == 0 and stPOA[ctB] == 0 and stPOA[ctC] == 0) then return true end
  return false
end

local function StringPOA(stPOA,sOffs)
  if(not IsString(sOffs)) then
    return StatusLog(nil,"StringPOA: Mode {"..type(sOffs).."}<"..tostring(sOffs).."> not string") end
  if(not IsExistent(stPOA)) then
    return StatusLog(nil,"StringPOA: Missing Offsets") end
  local symRevs = GetOpVar("OPSYM_REVSIGN")
  local symDisa = GetOpVar("OPSYM_DISABLE")
  local symSepa = GetOpVar("OPSYM_SEPARATOR")
  local sModeDB = GetOpVar("MODE_DATABASE")
  if    (sOffs == "V") then ctA, ctB, ctC = cvX, cvY, cvZ
  elseif(sOffs == "A") then ctA, ctB, ctC = caP, caY, caR
  else return StatusLog(nil,"StringPOA: Missed offset mode "..sOffs) end
  return stringGsub((stPOA[csD] and symDisa or "")  -- Get rid of the spaces
                 ..((stPOA[csA] == -1) and symRevs or "")..tostring(stPOA[ctA])..symSepa
                 ..((stPOA[csB] == -1) and symRevs or "")..tostring(stPOA[ctB])..symSepa
                 ..((stPOA[csC] == -1) and symRevs or "")..tostring(stPOA[ctC])," ","")
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
  local sCh = ""
  local dInd, iSep = 1, 0
  local S, E, iCnt = 1, 1, 1
  local strLen = stringLen(sStr)
  local symOff = GetOpVar("OPSYM_DISABLE")
  local symRev = GetOpVar("OPSYM_REVSIGN")
  local symSep = GetOpVar("OPSYM_SEPARATOR")
  local arPOA  = GetOpVar("ARRAY_DECODEPOA")
  ReloadPOA()
  if(stringSub(sStr,iCnt,iCnt) == symOff) then
    arPOA[7] = true; iCnt = iCnt + 1; S = S + 1 end
  while(iCnt <= strLen) do
    sCh = stringSub(sStr,iCnt,iCnt)
    if(sCh == symRev) then
      arPOA[3+dInd] = -arPOA[3+dInd]; S = S + 1
    elseif(sCh == symSep) then
      iSep = iSep + 1; E = iCnt - 1
      if(iSep > 2) then break end
      arPOA[dInd] = tonumber(stringSub(sStr,S,E)) or 0
      dInd = dInd + 1; S = iCnt + 1; E = S
    else E = E + 1 end
    iCnt = iCnt + 1
  end
  arPOA[dInd] = tonumber(stringSub(sStr,S,E)) or 0
  return arPOA
end

local function RegisterPOA(stPiece, sMod, sP, sO, sA)
  if(not stPiece) then
    return StatusLog(nil,"RegisterPOA: Cache record invalid") end
  if(not IsString(sMod)) then
    return StatusLog(nil,"RegisterPOA: Hash <"..tostring(sMod).."> invalid") end
  local sP = sP or "NULL"
  local sO = sO or "NULL"
  local sA = sA or "NULL"
  if(not IsString(sP)) then
    return StatusLog(nil,"RegisterPOA: Point  {"..type(sP).."}<"..tostring(sP)..">") end
  if(not IsString(sO)) then
    return StatusLog(nil,"RegisterPOA: Origin {"..type(sO).."}<"..tostring(sO)..">") end
  if(not IsString(sA)) then
    return StatusLog(nil,"RegisterPOA: Angle  {"..type(sA).."}<"..tostring(sA)..">") end
  local stPOA = stPiece.Offs
  if(not stPOA) then
    stPiece.Offs = {}; stPOA = stPiece.Offs
    stPOA.P = {}; stPOA.O = {}; stPOA.A = {}
  else return StatusLog(nil,"RegisterPOA: Hash <"..tostring(sMod).."> exists") end
  ---------------- Origin ----------------
  if((sO ~= "NULL") and not IsEmptyString(sO)) then DecodePOA(sO) else ReloadPOA() end
  if(not IsExistent(TransferPOA(tOffs.O,"V"))) then
    return StatusLog(nil,"RegisterPOA: Cannot transfer origin") end
  ---------------- Point ----------------
  if((sP ~= "NULL") and not IsEmptyString(sP)) then DecodePOA(sP) else ReloadPOA() end
  if(not IsExistent(TransferPOA(tOffs.P,"V"))) then
    return StatusLog(nil,"RegisterPOA: Cannot transfer point") end
  ---------------- Angle ----------------
  if((sA ~= "NULL") and not IsEmptyString(sA)) then DecodePOA(sA) else ReloadPOA() end
  if(not IsExistent(TransferPOA(tOffs.A,"A"))) then
    return StatusLog(nil,"RegisterPOA: Cannot transfer angle") end
  return tOffs
end

local function Sort(tTable,tKeys,tFields)

  local function QuickSort(Data,Lo,Hi)
    if(not (Lo and Hi and (Lo > 0) and (Lo < Hi))) then
      return StatusLog(nil,"QuickSort: Data dimensions mismatch") end
    local iMid = mathRandom(Hi-(Lo-1))+Lo-1
    Data[Lo], Data[iMid] = Data[iMid], Data[Lo]
    iMid = Lo
    local vMid = Data[Lo].Val
    local iCnt = Lo + 1
    while(iCnt <= Hi)do
      if(Data[iCnt].Val < vMid) then
        iMid = iMid + 1
        Data[iMid], Data[iCnt] = Data[iCnt], Data[iMid]
      end
      iCnt = iCnt + 1
    end
    Data[Lo], Data[iMid] = Data[iMid], Data[Lo]
    QuickSort(Data,Lo,iMid-1)
    QuickSort(Data,iMid+1,Hi)
  end

  local Match = {}
  local tKeys = tKeys or {}
  local tFields = tFields or {}
  local iCnt, iInd, sKey, vRec, sFld = 1, nil, nil, nil, nil
  if(not tKeys[1]) then
    for k,v in pairs(tTable) do
      tKeys[iCnt] = k; iCnt = iCnt + 1
    end; iCnt = 1
  end
  while(tKeys[iCnt]) do
    sKey = tKeys[iCnt]; vRec = tTable[sKey]
    if(not vRec) then
      return StatusLog(nil,"Sort: Key <"..sKey.."> does not exist in the primary table") end
    Match[iCnt] = {}
    Match[iCnt].Key = sKey
    if(type(vRec) == "table") then
      Match[iCnt].Val, iInd = "", 1
      while(tFields[iInd]) do
        sFld = tFields[iInd]
        if(not IsExistent(vRec[sFld])) then
          return StatusLog(nil,"Sort: Field <"..sFld.."> not found on the current record") end
        Match[iCnt].Val = Match[iCnt].Val..tostring(vRec[sFld])
        iInd = iInd + 1
      end
    else Match[iCnt].Val = vRec end
    iCnt = iCnt + 1
  end; QuickSort(Match,1,iCnt-1)
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

function DefaultType(anyType,fooCateg)
  if(not IsExistent(anyType)) then
    return (GetOpVar("DEFAULT_TYPE") or "") end
  SettingsModelToName("CLR")
  if(type(fooCateg) == "function") then
    local Categ = GetOpVar("TABLE_CATEGORIES")
          Categ[anyType] = fooCateg
  end
  SetOpVar("DEFAULT_TYPE",tostring(anyType))
end

function DefaultTable(anyTable)
  if(not IsExistent(anyTable)) then
    return (GetOpVar("DEFAULT_TABLE") or "") end
  SetOpVar("DEFAULT_TABLE",anyTable)
  SettingsModelToName("CLR")
end

------------------------- PLAYER -----------------------------------

function ConCommandPly(pPly,sCvar,snValue)
  if(not IsPlayer(pPly)) then return StatusLog("","ConCommandPly: Player <"..type(pPly)"> invalid") end
  if(not IsString(sCvar)) then -- Make it like so the space will not be forgotten
    return StatusLog("","ConCommandPly: Convar {"..type(sCvar).."}<"..tostring(sCvar).."> not string") end
  return pPly:ConCommand(GetOpVar("TOOLNAME_PL")..sCvar.." "..tostring(snValue).."\n")
end

function PrintNotifyPly(pPly,sText,sNotifType)
  if(not IsPlayer(pPly)) then
    return StatusLog(false,"PrintNotifyPly: Player <"..type(pPly)"> invalid") end
  if(SERVER) then -- Send notification to client that something happened
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
    return StatusLog(false,"UndoAddEntityPly: Entity invalid") end
  undoAddEntity(oEnt)
  return true
end

function UndoFinishPly(pPly,anyMessage)
  if(not IsPlayer(pPly)) then return StatusLog(false,"UndoFinishPly: Player <"..type(pPly)"> invalid") end
  pPly:EmitSound("physics/metal/metal_canister_impact_hard"..mathFloor(mathRandom(3))..".wav")
  undoSetCustomUndoText(GetOpVar("LABEL_UNDO")..tostring(anyMessage or ""))
  undoSetPlayer(pPly)
  undoFinish()
  return true
end

function LoadKeyPly(pPly, sKey)
  local keyPly   = GetOpVar("HASH_PLAYER_INFO")
  local plyCache = libCache[keyPly]
  if(not IsExistent(plyCache)) then
    libCache[keyPly] = {}; plyCache = libCache[keyPly] end
  if(not IsPlayer(pPly)) then
    return StatusLog(false,"LoadKeyPly: Player <"..type(pPly)"> not available") end
  local plyNick  = pPly:Nick()
  local plyPlace = plyCache[plyNick]
  if(not IsExistent(plyPlace)) then
    plyCache[plyNick] = {
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
    plyPlace = plyCache[plyNick]
  end
  if(IsExistent(sKey)) then
    if(not IsString(sKey)) then
      return StatusLog(false,"LoadKeyPly: Key hash {"..type(sKey).."}<"..tostring(sKey).."> not string") end
    if(sKey == "DEBUG") then return plyPlace end
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
  return StatusLog(true,"LoadKeyPly: Player <"..plyNick.."> keys loaded")
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
  local indTable = defTable.Index
  if(not defTable[1]) then
    return SQLBuildError("SQLBuildCreate: Missing table definition is empty for "..defTable.Name) end
  if(not (defTable[1][1] and defTable[1][2])) then
    return SQLBuildError("SQLBuildCreate: Missing table "..defTable.Name.." field definitions") end
  local Command, iInd = {}, 1
  Command.Drop   = "DROP TABLE "..defTable.Name..";"
  Command.Delete = "DELETE FROM "..defTable.Name..";"
  Command.Create = "CREATE TABLE "..defTable.Name.." ( "
  while(defTable[iInd]) do
    local v = defTable[iInd]
    if(not v[1]) then
      return SQLBuildError("SQLBuildCreate: Missing Table "..defTable.Name
                          .."'s field #"..tostring(iInd)) end
    if(not v[2]) then
      return SQLBuildError("SQLBuildCreate: Missing Table "..defTable.Name
                                  .."'s field type #"..tostring(iInd)) end
    Command.Create = Command.Create..stringUpper(v[1]).." "..stringUpper(v[2])
    if(defTable[iInd+1]) then Command.Create = Command.Create ..", " end
    iInd = iInd + 1
  end
  Command.Create = Command.Create.." );"
  if(indTable and
     indTable[1] and
     type(indTable[1]) == "table" and
     indTable[1][1] and
     type(indTable[1][1]) == "number"
   ) then
    Command.Index = {}
    iInd, iCnt = 1, 1
    while(indTable[iInd]) do
      local vI = indTable[iInd]
      if(type(vI) ~= "table") then
        return SQLBuildError("SQLBuildCreate: Index creator mismatch on "
          ..defTable.Name.." value "..vI.." is not a table for index ["..tostring(iInd).."]") end
      local FieldsU = ""
      local FieldsC = ""
      Command.Index[iInd] = "CREATE INDEX IND_"..defTable.Name
      iCnt = 1
      while(vI[iCnt]) do
        local vF = vI[iCnt]
        if(type(vF) ~= "number") then
          return SQLBuildError("SQLBuildCreate: Index creator mismatch on "
            ..defTable.Name.." value "..vF.." is not a number for index ["
            ..tostring(iInd).."]["..tostring(iCnt).."]") end
        if(not defTable[vF]) then
          return SQLBuildError("SQLBuildCreate: Index creator mismatch on "
            ..defTable.Name..". The table does not have field index #"
            ..vF..", max is #"..Table.Size) end
        FieldsU = FieldsU.."_" ..stringUpper(defTable[vF][1])
        FieldsC = FieldsC..stringUpper(defTable[vF][1])
        if(vI[iCnt+1]) then FieldsC = FieldsC ..", " end
        iCnt = iCnt + 1
      end
      Command.Index[iInd] = Command.Index[iInd]..FieldsU.." ON "..defTable.Name.." ( "..FieldsC.." );"
      iInd = iInd + 1
    end
  end
  SQLBuildError("")
  return Command
end

local function SQLStoreQuery(defTable,tFields,tWhere,tOrderBy,sQuery)
  if(not GetOpVar("EN_QUERY_STORE")) then return sQuery end
  local Val, Base
  if(not defTable) then
    return StatusLog(nil,"SQLStoreQuery: Missing table definition") end
  local tTimer = defTable.Timer
  if(not (tTimer and ((tonumber(tTimer[2]) or 0) > 0))) then
    return StatusLog(sQuery,"SQLStoreQuery: Skipped. Cache persistent forever") end
  local Field, Where, Order = 1, 1, 1
  local keyStr = GetOpVar("HASH_QUERY_STORE")
  local tCache = libCache[keyStr]
  if(not IsExistent(tCache)) then
    libCache[keyStr] = {}; tCache = libCache[keyStr] end
  local Place = tCache[defTable.Name]
  if(not IsExistent(Place)) then
    tCache[defTable.Name] = {}; Place = tCache[defTable.Name] end
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
  if(not (defTable[1][1] and defTable[1][2])) then
    return SQLBuildError("SQLBuildSelect: Missing table "..defTable.Name.." field definitions") end
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
             .."> type mismatch in "..defTable.Name) end
      if(defTable[v]) then
        if(defTable[v][1]) then
          Command = Command..defTable[v][1]
        else
          return SQLBuildError("SQLBuildSelect: Select no such field name by index #"
            ..v.." in the table "..defTable.Name) end
      end
      if(tFields[Cnt+1]) then
        Command = Command ..", "
      end
      Cnt = Cnt + 1
    end
  else
    Command = Command.."*"
  end
  Command = Command .." FROM "..defTable.Name
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
          ..defTable.Name.." field index, {"..tostring(k)..","..tostring(v)..","..tostring(t)
          .."} value or type in the table definition") end
      v = MatchType(defTable,v,k,true)
      if(not IsExistent(v)) then
        return SQLBuildError("SQLBuildSelect: Data matching failed on "
          ..defTable.Name.." field index #"..Cnt.." value <"..tostring(v)..">") end
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
                           ..defTable.Name .." field index #"..Cnt) end
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
  if(not defTable) then
    return SQLBuildError("SQLBuildInsert: Missing Table definition") end
  if(not tValues) then
    return SQLBuildError("SQLBuildInsert: Missing Table value fields") end
  if(not defTable[1]) then
    return SQLBuildError("SQLBuildInsert: The table and the chosen fields must not be empty") end
  if(not (defTable[1][1] and defTable[1][2])) then
    return SQLBuildError("SQLBuildInsert: Missing table "..defTable.Name.." field definition") end
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
  local qIns = "INSERT INTO "..defTable.Name.." ( "
  local Val, iInd, dFld
  while(tInsert[iCnt]) do
    iInd = tInsert[iCnt]
    dFld = defTable[iInd]
    if(not IsExistent(dFld)) then
      return SQLBuildError("SQLBuildInsert: No such field #"..iInd.." on table "..defTable.Name)
    end
    Val = MatchType(defTable,tValues[iCnt],iInd,true)
    if(not IsExistent(Val)) then
      return SQLBuildError("SQLBuildInsert: Cannot match value <"..tostring(tValues[iCnt]).."> #"..iInd.." on table "..defTable.Name)
    end
    qIns = qIns..dFld[1]
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
  SetOpVar("DEFTABLE_"..sTable,defTable)
  defTable.Size = #defTable
  defTable.Name = GetOpVar("TOOLNAME_PU")..sTable
  local sModeDB = GetOpVar("MODE_DATABASE")
  local sTable  = stringUpper(sTable)
  local symDis  = GetOpVar("OPSYM_DISABLE")
  local iCnt, defField = 1, nil
  while(defTable[iCnt]) do
    defField    = defTable[iCnt]
    defField[3] = DefaultString(tostring(defField[3] or symDis), symDis)
    defField[4] = DefaultString(tostring(defField[4] or symDis), symDis)
    iCnt = iCnt + 1
  end
  libCache[defTable.Name] = {}
  if(sModeDB == "SQL") then
    local tQ = SQLBuildCreate(defTable)
    if(not IsExistent(tQ)) then return StatusLog(false,"CreateTable: "..SQLBuildError()) end
    if(bDelete and sqlTableExists(defTable.Name)) then
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
    if(sqlTableExists(defTable.Name)) then
      LogInstance("CreateTable: Table "..sTable.." exists!")
      return true
    else
      local qRez = sqlQuery(tQ.Create)
      if(not qRez and IsBool(qRez)) then
        return StatusLog(false,"CreateTable: Table "..sTable
          .." failed to create because of "..sqlLastError()) end
      if(sqlTableExists(defTable.Name)) then
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
  elseif(sModeDB == "LUA") then return StatusLog(true,"CreateTable: Datatabase mode <"..sModeDB..">")
  else return StatusLog(false,"CreateTable: Wrong database mode <"..sModeDB..">") end
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

  if(sTable == "PIECES") then
    tData[2] = DisableString(tData[2],GetOpVar("DEFAULT_TYPE"),"TYPE")
    tData[3] = DisableString(tData[3],ModelToName(tData[1]),"MODEL")
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
      local stRezul = RegisterPOA(tLine,snPrimaryKey,tData[5],tData[6],tData[7])
      if(not IsExistent(stRezul)) then
        return StatusLog(nil,"InsertRecord: Cannot process offset for "..tostring(snPrimaryKey)) end
    else
      return StatusLog(false,"InsertRecord: No settings for table "..sTable)
    end
  end
end

--------------- TIMER MEMORY MANAGMENT ----------------------------

local function NavigateTable(oLocation,tKeys)
  if(not IsExistent(oLocation)) then
    return StatusLog(nil,"NavigateTable: Location missing") end
  if(not IsExistent(tKeys)) then
    return StatusLog(nil,"NavigateTable: Key table missing") end
  if(not IsExistent(tKeys[1])) then
    return StatusLog(nil,"NavigateTable: First key missing") end
  local oPlace, kKey, iCnt = oLocation, tKeys[1], 1
  while(tKeys[iCnt]) do
    kKey = tKeys[iCnt]
    if(tKeys[iCnt+1]) then
      oPlace = oPlace[kKey]
      if(not IsExistent(oPlace)) then
        return StatusLog(nil,"NavigateTable: Key #"..tostring(kKey).." irrelevant to location") end
    end; iCnt = iCnt + 1
  end; return oPlace, kKey
end

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
  LogInstance("TimerAttach: Called by <"..tostring(anyMessage).."> for Place["..tostring(Key).."]")
  if(sModeDB == "SQL") then
    -- Get the proper line count to avoid doing in every caching function"
    if(IsExistent(Place[Key].Kept)) then Place[Key].Kept = Place[Key].Kept - 1 end
    local nNowTM, tTimer = Time(), defTable.Timer -- See that there is a timer and get "now"
    if(not IsExistent(tTimer)) then
      return StatusLog(Place[Key],"TimerAttach: Missing timer settings") end
    Place[Key].Used = nNowTM -- Make the first selected deletable to avoid phantom records
    local nLifeTM = tTimer[2]
    if(nLifeTM <= 0) then
      return StatusLog(Place[Key],"TimerAttach: Timer attachment ignored") end
    local sModeTM, bKillRC, bCollGB = tTimer[1], tTimer[3], tTimer[4]
    LogInstance("TimerAttach: ["..sModeTM.."] ("..tostring(nLifeTM)..") "..tostring(bKillRC)..", "..tostring(bCollGB))
    if(sModeTM == "CQT") then
      Place[Key].Load = nNowTM
      for k, v in pairs(Place) do
        if(IsExistent(v.Load) and IsExistent(v.Used) and  ((nNowTM - v.Used) > nLifeTM)) then
          LogInstance("TimerAttach: ("..tostring(RoundValue(nNowTM - v.Used,0.01)).." > "..tostring(nLifeTM)..") > Dead")
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
      return StatusLog(Place[Key],"TimerAttach: Place["..tostring(Key).."].Load = "..tostring(RoundValue(nNowTM,0.01)))
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
    return StatusLog(nil,"CacheBoxLayout: Entity invalid <"..tostring(oEnt)..">") end
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
    Box.Ang = Angle () -- Layout entity angle
    Box.Cen = Vector() -- Layout entity centre
    Box.Cen:Set(vMax); Box.Cen:Add(vMin); Box.Cen:Mul(0.5)
    Box.Eye = oEnt:LocalToWorld(Box.Cen) -- Layout camera eye
    Box.Len = ((vMax - vMin):Length() / 2) -- Layout border sphere radius
    Box.Cam = Vector(); Box.Cam:Set(Box.Eye)  -- Layout camera position
    AddVectorXYZ(Box.Cam,Box.Len*(tonumber(nCamX) or 0),0,Box.Len*(tonumber(nCamZ) or 0))
    LogInstance("CacheBoxLayout: "..tostring(Box.Cen).." # "..tostring(Box.Len))
  end; Box.Ang[caY] = (tonumber(nRot) or 0) * Time()
  return Box
end

--------------------------- PIECE QUERY -----------------------------

function CacheQueryPiece(sModel)
  if(not IsExistent(sModel)) then
    return StatusLog(nil,"CacheQueryPiece: Model does not exist") end
  if(not IsString(sModel)) then
    return StatusLog(nil,"CacheQueryPiece: Model {"..type(sModel).."}<"..tostring(sModel).."> not string") end
  if(IsEmptyString(sModel)) then
    return StatusLog(nil,"CacheQueryPiece: Model empty string") end
  if(not utilIsValidModel(sModel)) then
    return StatusLog(nil,"CacheQueryPiece: Model invalid <"..sModel..">") end
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not defTable) then
    return StatusLog(nil,"CacheQueryPiece: Table definition missing") end
  local tCache = libCache[defTable.Name] -- Match the model casing
  local sModel = MatchType(defTable,sModel,1,false,"",true,true)
  if(not IsExistent(tCache)) then
    return StatusLog(nil,"CacheQueryPiece: Cache not allocated for <"..defTable.Name..">") end
  local caInd    = GetOpVar("NAV_PIECE")
  if(not IsExistent(caInd[1])) then caInd[1] = defTable.Name end caInd[2] = sModel
  local stPiece  = tCache[sModel]
  if(IsExistent(stPiece) and IsExistent(stPiece.Kept)) then
    if(stPiece.Kept > 0) then
      return TimerRestart(libCache,caInd,defTable,"CacheQueryPiece") end
    return nil
  else
    local sModeDB = GetOpVar("MODE_DATABASE")
    if(sModeDB == "SQL") then
      LogInstance("CacheQueryPiece: Model >> Pool <"..stringToFileName(sModel)..">")
      tCache[sModel] = {}; stPiece = tCache[sModel]; stPiece.Kept = 0
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
        qRez = RegisterPOA(stPiece, sModel,
                           qRec[defTable[5][1]],
                           qRec[defTable[6][1]],
                           qRec[defTable[7][1]])
        if(not IsExistent(qRez)) then
          return StatusLog(nil,"CacheQueryPiece: Cannot process hash <"..sModel..">")
        end
        stPiece.Kept = stPiece.Kept + 1
      end
      return TimerAttach(libCache,caInd,defTable,"CacheQueryPiece")
    elseif(sModeDB == "LUA") then return StatusLog(nil,"CacheQueryPiece: Record not located")
    else return StatusLog(nil,"CacheQueryPiece: Wrong database mode <"..sModeDB..">") end
  end
end

----------------------- PANEL QUERY -------------------------------
--[[
 * Caches the date needed to populate the CPanel tree
]]--
function CacheQueryPanel()
  local defTable = GetOpVar("DEFTABLE_PIECES")
  if(not defTable) then
    return StatusLog(false,"CacheQueryPanel: Missing table definition") end
  if(not IsExistent(libCache[defTable.Name])) then
    return StatusLog(nil,"CacheQueryPanel: Cache not allocated for <"..defTable.Name..">") end
  local caInd  = GetOpVar("NAV_PANEL")
  local keyPan = GetOpVar("HASH_USER_PANEL")
  if(not IsExistent(caInd[1])) then caInd[1] = keyPan end
  local stPanel  = libCache[keyPan]
  if(IsExistent(stPanel) and IsExistent(stPanel.Kept)) then
    LogInstance("CacheQueryPanel: From Pool")
    if(stPanel.Kept > 0) then
      return TimerRestart(libCache,caInd,defTable,"CacheQueryPanel") end
    return nil
  else
    libCache[keyPan] = {}; stPanel = libCache[keyPan]
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
      local tCache = libCache[defTable.Name]
      local tData = {}
      local iNdex = 0
      for sModel, tRecord in pairs(tCache) do
        tData[sModel] = {
          [defTable[1][1]] = sModel,
          [defTable[2][1]] = tRecord.Type,
          [defTable[3][1]] = tRecord.Name
        }
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
function ImportDSV(sTable,sDelim,bCommit,sPrefix)
  if(not IsString(sTable)) then
    return StatusLog(false,"ImportDSV: Table {"..type(sTable).."}<"..tostring(sTable).."> not string") end
  local defTable = GetOpVar("DEFTABLE_"..sTable)
  if(not defTable) then
    return StatusLog(false,"ImportDSV: Missing table definition for <"..sTable..">") end
  local fName = GetOpVar("DIRPATH_BAS")..GetOpVar("DIRPATH_DSV")
        fName = fName..tostring(sPrefix or GetInstPref())..defTable.Name..".txt"
  local F = fileOpen(fName, "r", "DATA")
  if(not F) then return StatusLog(false,"ImportDSV: fileOpen("..fName..".txt) Failed") end
  local symOff = GetOpVar("OPSYM_DISABLE")
  local tabLen = stringLen(defTable.Name)
  local sLine, sChar, lenLine = "", "X", 0
  while(sChar) do
    sChar = F:Read(1)
    if(not sChar) then return end
    if(sChar == "\n") then
      lenLine = stringLen(sLine)
      if(stringSub(sLine,lenLine,lenLine) == "\r") then
        sLine = stringSub(sLine,1,lenLine-1)
        lenLine = lenLine - 1
      end
      if((stringSub(sLine,1,1) ~= symOff) and (stringSub(sLine,1,tabLen) == defTable.Name)) then
        local Data = stringExplode(sDelim,stringSub(sLine,tabLen+2,lenLine))
        for k,v in pairs(Data) do
          local vLen = stringLen(v)
          if(stringSub(v,1,1) == "\"" and stringSub(v,vLen,vLen) == "\"") then
            Data[k] = stringSub(v,2,vLen-1)
          end
        end
        if(bCommit) then InsertRecord(sTable,Data) end
      end; sLine = ""
    else sLine = sLine..sChar end
  end; F:Close()
end

function DeleteExternalDatabase(sTable,sMethod,sPrefix)
  if(not IsString(sTable)) then
    return StatusLog(false,"DeleteExternalDatabase: Table {"..type(sTable).."}<"..tostring(sTable).."> not string") end
  if(not IsString(sMethod)) then
    return StatusLog(false,"DeleteExternalDatabase: Delete method {"..type(sMethod).."}<"..tostring(sMethod).."> not string") end
  local defTable = GetOpVar("DEFTABLE_"..sTable)
  if(not defTable) then
    return StatusLog(false,"DeleteExternalDatabase: Missing table definition for <"..sTable..">") end
  local fName = GetOpVar("DIRPATH_BAS")
  if(not GetOpVar("DIRPATH_"..sMethod)) then
    return StatusLog(false,"DeleteExternalDatabase: Directory index <"..sMethod.."> missing") end
  fName = fName..GetOpVar("DIRPATH_"..sMethod)
  fName = fName..tostring(sPrefix or GetInstPref())..defTable.Name..".txt"
  if(not fileExists(fName,"DATA")) then
    return StatusLog(true,"DeleteExternalDatabase: File <"..fName.."> missing") end
  fileDelete(fName)
  return StatusLog(true,"DeleteExternalDatabase: Success")
end

function StoreExternalDatabase(sTable,sDelim,sMethod,sPrefix)
  if(not IsString(sTable)) then
    return StatusLog(false,"StoreExternalDatabase: Table {"..type(sTable).."}<"..tostring(sTable).."> not string") end
  if(not IsString(sMethod)) then
    return StatusLog(false,"StoreExternalDatabase: Export mode {"..type(sMethod).."}<"..tostring(sMethod).."> not string") end
  local defTable = GetOpVar("DEFTABLE_"..sTable)
  if(not defTable) then
    return StatusLog(false,"StoreExternalDatabase: Missing table definition for <"..sTable..">") end
  local fName = GetOpVar("DIRPATH_BAS")
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  if(not GetOpVar("DIRPATH_"..sMethod)) then
    return StatusLog(false,"StoreExternalDatabase: Directory index <"..sMethod.."> missing") end
  fName = fName..GetOpVar("DIRPATH_"..sMethod)
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  fName = fName..tostring(sPrefix or GetInstPref())..defTable.Name..".txt"
  local F = fileOpen(fName, "w", "DATA" )
  if(not F) then return StatusLog(false,"StoreExternalDatabase: fileOpen("..fName..") Failed") end
  local sData, sTemp = "", ""
  local sModeDB, symOff = GetOpVar("MODE_DATABASE"), GetOpVar("OPSYM_DISABLE")
  F:Write("# StoreExternalDatabase( "..sMethod.." ): "..osDate().." [ "..sModeDB.." ]".."\n")
  F:Write("# Data settings: "..GetFieldsName(defTable,sDelim).."\n")
  if(sModeDB == "SQL") then
    local Q = ""
    if(sTable == "PIECES") then Q = SQLBuildSelect(defTable,nil,nil,{2,3,1,4})
    else                        Q = SQLBuildSelect(defTable,nil,nil,nil) end
    if(not IsExistent(Q)) then return StatusLog(false,"ExportIntoFile: Build error <"..SQLBuildError()..">") end
    F:Write("# Query ran: <"..Q..">\n")
    local qData = sqlQuery(Q)
    if(not qData and IsBool(qData)) then
      return StatusLog(nil,"StoreExternalDatabase: SQL exec error <"..sqlLastError()..">") end
    if(not (qData and qData[1])) then
      return StatusLog(false,"StoreExternalDatabase: No data found <"..Q..">") end
    local iCnt, iInd, qRec = 1, 1, nil
    if    (sMethod == "DSV") then sData = defTable.Name..sDelim
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
      if    (sMethod == "DSV") then sTemp = sTemp.."\n"
      elseif(sMethod == "INS") then sTemp = sTemp.."})\n" end
      F:Write(sTemp)
      iCnt = iCnt + 1
    end
  elseif(sModeDB == "LUA") then
    local tCache = libCache[defTable.Name]
    if(not IsExistent(tCache)) then
      return StatusLog(false,"StoreExternalDatabase: Table <"..defTable.Name.."> cache not allocated") end
    if(sTable == "PIECES") then
      local tData = {}
      for sModel, tRecord in pairs(tCache) do
        sData = tRecord.Type..tRecord.Name..sModel
        tData[sModel] = {[defTable[1][1]] = sData}
      end
      local tSorted = Sort(tData,nil,{defTable[1][1]})
      if(not tSorted) then
        return StatusLog(false,"StoreExternalDatabase: Cannot sort cache data") end
      local iInd iNdex = 1, 1
      while(tSorted[iNdex]) do
        iInd  = 1
        tData = tCache[tSorted[iNdex].Key]
        if    (sMethod == "DSV") then sData = defTable.Name..sDelim
        elseif(sMethod == "INS") then sData = "  asmlib.InsertRecord(\""..sTable.."\", {" end
        sData = sData..MatchType(defTable,tSorted[iNdex].Key,1,true,"\"")..sDelim..
                       MatchType(defTable,tData.Type,2,true,"\"")..sDelim..
                       MatchType(defTable,((ModelToName(tSorted[iNdex].Key) == tData.Name) and symOff or tData.Name),3,true,"\"")..sDelim
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

function GetMCWorldPosAng(vPos,vAng,vdbMCL)
  if(not (vdbMCL and vPos and vAng)) then return end
  local vMCW = Vector(vdbMCL[cvX],vdbMCL[cvY],vdbMCL[cvZ])
        vMCW:Rotate(vAng)
        vMCW:Add(vPos)
  return vMCW
end

function GetCustomAngBBZ(oEnt,oRec,nMode)
  if(not (oEnt and oEnt:IsValid())) then return 0 end
  local Mode = tonumber(nMode) or 0
  if(oRec and Mode ~= 0) then
    local aAngDB = Angle(oRec.A[caP],oRec.A[caY],oRec.A[caR])
    local vOBB = oEnt:OBBMins()
          SubVector(vOBB,oRec.M)
          vOBB:Rotate(aAngDB)
          DecomposeByAngle(vOBB,Angle(0,0,0))
    return mathAbs(vOBB[cvZ])
  end
  return (oEnt:OBBMaxs() - oEnt:OBBMins()):Length() / GetOpVar("DIAG_SQUARE")
end

----------------------------- SNAPPING ------------------------------

--[[
 * This function is the backbone of the tool for Trace.Normal
 * Calculates SPos, SAng based on the DB inserts and input parameters
 * ucsPos,ucsAng = Origin position and angle of the snapping
 * hdModel       = Holder's piece model
 * enOrAng       = Position offset comes from origin angle F,R,U
 * ucsPos(X,Y,Z) = Offset position
 * ucsAng(P,Y,R) = Offset angle
]]--
function GetNormalSpawn(ucsPos,ucsAng,hdModel,hdPivot,ucsPosX,ucsPosY,ucsPosZ,ucsAngP,ucsAngY,ucsAngR)
  local hdRec = CacheQueryPiece(hdModel)
  if(not IsExistent(hdRec)) then return StatusLog(nil,"GetNormalSpawn: Holder is not a piece <"..hdModel..">") end
  if(not IsExistent(hdRec.Kept) and (hdRec.Kept < 1 or hdRec.Kept > 1)) then
    return StatusLog(nil,"GetNormalSpawn: Line count <"..tostring(hdRec.Kept).."> mismatch for <"..hdModel..">") end
  local stSpawn = GetOpVar("STRUCT_SPAWN")
        stSpawn.HRec = hdRec
  if(ucsPos) then SetVector(stSpawn.OPos,ucsPos) end
  if(ucsAng) then SetVector(stSpawn.OAng,ucsAng) end
  -- Calculate directions
  stSpawn.U:Set(stSpawn.OAng:Up()     )
  stSpawn.R:Set(stSpawn.OAng:Right()  )
  stSpawn.F:Set(stSpawn.OAng:Forward())
  -- Rotate origin
  stSpawn.OAng:RotateAroundAxis(stSpawn.U,(tonumber(ucsAngY) or 0))
  stSpawn.OAng:RotateAroundAxis(stSpawn.R,(tonumber(ucsAngP) or 0))
  stSpawn.OAng:RotateAroundAxis(stSpawn.F,(tonumber(ucsAngR) or 0))
  stSpawn.U:Set(stSpawn.OAng:Up()     )
  stSpawn.R:Set(stSpawn.OAng:Right()  )
  stSpawn.F:Set(stSpawn.OAng:Forward())
  -- Read holder's data
  SetVector(stSpawn.HPnt, hdRec.P)
  SetVector(stSpawn.HPos, hdRec.O)
  SetAngle (stSpawn.HAng, hdRec.A)
  -- Calcolate domain ( Angle )
  stSpawn.DAng:Set(stSpawn.OAng)
  stSpawn.DAng:RotateAroundAxis(stSpawn.R,hdRec.Mesh)
  stSpawn.DAng:RotateAroundAxis(stSpawn.DAng:Up(),(tonumber(hdPivot) or 0) + 180)
  stSpawn.HPnt:Mul(-1)
  stSpawn.HAng:RotateAroundAxis(stSpawn.HAng:Up(),180)
  DecomposeByAngle(stSpawn.HPnt,stSpawn.HAng)
  -- Calcolate spawns
  stSpawn.SAng:Set(stSpawn.DAng)
  stSpawn.SAng:RotateAroundAxis(stSpawn.U,stSpawn.HAng[caY] * hdRec.A[csB])
  stSpawn.SAng:RotateAroundAxis(stSpawn.R,stSpawn.HAng[caP] * hdRec.A[csA])
  stSpawn.SAng:RotateAroundAxis(stSpawn.F,stSpawn.HAng[caR] * hdRec.A[csC])
  stSpawn.SPos:Add(stSpawn.HPos)
  stSpawn.SPos:Mul(-1)
  stSpawn.SPos:Rotate(stSpawn.SAng)
  stSpawn.SPos:Add(stSpawn.HPnt)
  stSpawn.SPos:Add((tonumber(ucsPosX) or 0) * stSpawn.F)
  stSpawn.SPos:Add((tonumber(ucsPosY) or 0) * stSpawn.R)
  stSpawn.SPos:Add((tonumber(ucsPosZ) or 0) * stSpawn.U)
  return stSpawn
end

--[[
 * This function is the backbone of the tool for Trace.Entity
 * Calculates SPos, SAng based on the DB inserts and input parameters
 * From the position and angle of the entity, the masscenter is calculated
 * and used as an origin to build the spawn parameters,
 * trEnt         = Trace.Entity
 * nRotPivot     = Trace  pivot rotation
 * nRotPivot     = Holder pivot rotation
 * hdModel       = The holder model
 * enIgnTyp      = Ignore Gear Type
 * ucsPos(X,Y,Z) = Offset position
 * ucsAng(P,Y,R) = Offset angle
]]--
function GetEntitySpawn(trEnt,trPivot,hdPivot,hdModel,enIgnTyp,
                        ucsPosX,ucsPosY,ucsPosZ,ucsAngP,ucsAngY,ucsAngR)
  if(not (trEnt and trEnt:IsValid())) then
    return StatusLog(nil,"GetEntitySpawn: Entity origin invalid") end
  local trRec, hdRec = CacheQueryPiece(trEnt:GetModel()), CacheQueryPiece(hdModel)
  if(not IsExistent(trRec)) then
    return StatusLog(nil,"GetEntitySpawn: Trace not a piece <"..trEnt:GetModel()..">") end
  if(not IsExistent(hdRec)) then
    return StatusLog(nil,"GetEntitySpawn: Holder not a piece <"..hdModel..">") end
  if(not (IsExistent(trRec.Type) and IsString(trRec.Type))) then
    return StatusLog(nil,"GetEntitySpawn: Trace not grouped <"..tostring(trRec.Type)..">") end
  if(not (IsExistent(hdRec.Type) and IsString(hdRec.Type))) then
    return StatusLog(nil,"GetEntitySpawn: Holder not grouped <"..tostring(hdRec.Type)..">") end
  if(enIgnTyp == 0 and trRec.Type ~= hdRec.Type ) then
    return StatusLog(nil,"GetEntitySpawn: Type mismatch <"..tostring(trRec.Type)..","..tostring(hdRec.Type)..">") end
  local trPos  , trAng    = trEnt:GetPos(), trEnt:GetAngles()
  local trPivot, hdPivot  = (tonumber(trPivot) or  0), (tonumber(hdPivot ) or 0)
  local hdModel, enIgnTyp =  tostring(hdModel  or ""), (tonumber(enIgnTyp) or 0)
  local stSpawn = GetOpVar("STRUCT_SPAWN")   -- Get cached spawn
  stSpawn.HRec, stSpawn.TRec = hdRec, trRec  -- Save records
  SetVector(stSpawn.TPnt,trRec.P)            -- Store data in objects
  SetVector(stSpawn.TPos,trRec.O)
  SetAngle (stSpawn.TAng,trRec.A)
  stSpawn.TPos:Rotate(trAng); stSpawn.TPos:Add(trPos)       -- Trace mass-center world
  stSpawn.TAng:Set(trEnt:LocalToWorldAngles(stSpawn.TAng))  -- Initial coordinate system
  stSpawn.TAng:RotateAroundAxis(stSpawn.TAng:Up(),-trPivot) -- Apply the pivot rotation for trace
  -- Calculate the origin based on the center
  stSpawn.OPos:Set(stSpawn.TPnt)
  stSpawn.OPos:Rotate(stSpawn.TAng)
  stSpawn.OPos:Add(stSpawn.TPos)
  stSpawn.OAng:Set(stSpawn.TAng)
  stSpawn.OAng:RotateAroundAxis(stSpawn.TAng:Right(),trRec.Mesh)
  return GetNormalSpawn(nil,nil,hdModel,hdPivot,ucsPosX,ucsPosY,ucsPosZ,ucsAngP,ucsAngY,ucsAngR)
end

local function GetEntityOrTrace(oEnt)
  if(oEnt and oEnt:IsValid()) then return oEnt end
  local pPly = LocalPlayer()
  if(not IsPlayer(pPly)) then
    return StatusLog(nil,"GetEntityOrTrace: Player <"..type(pPly)"> missing") end
  local stTrace = pPly:GetEyeTrace()
  if(not IsExistent(stTrace)) then
    return StatusLog(nil,"GetEntityOrTrace: Trace missing") end
  if(not stTrace.Hit) then -- Boolean
    return StatusLog(nil,"GetEntityOrTrace: Trace not hit") end
  if(stTrace.HitWorld) then -- Boolean
    return StatusLog(nil,"GetEntityOrTrace: Trace hit world") end
  local trEnt = stTrace.Entity
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

function GetPropBodyGroup(oEnt)
  local bgEnt = GetEntityOrTrace(oEnt)
  if(not IsExistent(bgEnt)) then
    return StatusLog("","GetPropBodyGrp: Failed to gather entity") end
  if(IsOther(bgEnt)) then
    return StatusLog("","GetPropBodyGrp: Entity other type") end
  local BGs = bgEnt:GetBodyGroups()
  if(not (BGs and BGs[1])) then
    return StatusLog("","GetPropBodyGrp: Bodygroup table empty") end
  local sRez, iCnt = "", 1
  local symSep = GetOpVar("OPSYM_SEPARATOR")
  while(BGs[iCnt]) do
    sRez = sRez..symSep..tostring(bgEnt:GetBodygroup(BGs[iCnt].id) or 0)
    iCnt = iCnt + 1
  end
  sRez = stringSub(sRez,2,-1)
  Print(BGs,"GetPropBodyGrp: BGs")
  return StatusLog(sRez,"GetPropBodyGrp: Success <"..sRez..">")
end

function AttachBodyGroups(ePiece,sBgrpIDs)
  if(not (ePiece and ePiece:IsValid())) then
    return StatusLog(false,"AttachBodyGroups: Base entity invalid") end
  local sBgrpIDs = tostring(sBgrpIDs or "")
  LogInstance("AttachBodyGroups: <"..sBgrpIDs..">")
  local iCnt = 1
  local BGs = ePiece:GetBodyGroups()
  local IDs = stringExplode(GetOpVar("OPSYM_SEPARATOR"),sBgrpIDs)
  while(BGs[iCnt] and IDs[iCnt]) do
    local itrBG = BGs[iCnt]
    local maxID = (ePiece:GetBodygroupCount(itrBG.id) - 1)
    local itrID = mathClamp(mathFloor(tonumber(IDs[iCnt]) or 0),0,maxID)
    LogInstance("ePiece:SetBodygroup("..tostring(itrBG.id)..","..tostring(itrID)..") ["..tostring(maxID).."]")
    ePiece:SetBodygroup(itrBG.id,itrID)
    iCnt = iCnt + 1
  end
  return StatusLog(true,"AttachBodyGroups: Success")
end

local function SetPosBound(ePiece,vPos,oPly,sMode)
  if(not (ePiece and ePiece:IsValid())) then
    return StatusLog(false,"SetPosBound: Entity invalid") end
  if(not IsExistent(vPos)) then
    return StatusLog(false,"SetPosBound: Position missing") end
  if(not IsPlayer(oPly)) then
    return StatusLog(false,"SetPosBound: Player <"..tostring(oPly)"> invalid") end
  local sMode = tostring(sMode or "LOG") -- Error mode is "LOG" by default
  if(sMode == "OFF") then
    ePiece:SetPos(vPos)
    return StatusLog(true,"SetPosBound("..sMode..") Tuned off")
  end
  if(utilIsInWorld(vPos)) then ePiece:SetPos(vPos) else
    ePiece:Remove()
    if(sMode == "HINT" or sMode == "GENERIC" or sMode == "ERROR") then
      PrintNotifyPly(oPly,"Position out of map bounds!",sMode) end
    return StatusLog(false,"SetPosBound("..sMode.."): Position ["..tostring(vPos).."] out of map bounds")
  end
  return StatusLog(true,"SetPosBound("..sMode.."): Success")
end

function MakePiece(pPly,sModel,vPos,aAng,nMass,sBgSkIDs,clColor,sMode)
  if(CLIENT) then return StatusLog(nil,"MakePiece: Working on client") end
  if(not IsPlayer(pPly)) then -- If not player we cannot register limit
    return StatusLog(nil,"MakePiece: Player missing <"..tostring(pPly)..">") end
  local sLimit = GetOpVar("CVAR_LIMITNAME") -- Get limit name
  if(not pPly:CheckLimit(sLimit)) then -- Check TA interanl limit
    return StatusLog(nil,"MakePiece: Track limit reached") end
  if(not pPly:CheckLimit("props")) then -- Check the props limit
    return StatusLog(nil,"MakePiece: Prop limit reached") end
  local stPiece = CacheQueryPiece(sModel)
  if(not IsExistent(stPiece)) then -- Not present in the database
    return StatusLog(nil,"MakePiece: Record missing for <"..sModel..">") end
  local ePiece = entsCreate("prop_physics")
  if(not (ePiece and ePiece:IsValid())) then
    return StatusLog(nil,"MakePiece: Piece <"..tostring(ePiece).."> invalid") end
  ePiece:SetCollisionGroup(COLLISION_GROUP_NONE)
  ePiece:SetSolid(SOLID_VPHYSICS)
  ePiece:SetMoveType(MOVETYPE_VPHYSICS)
  ePiece:SetNotSolid(false)
  ePiece:SetModel(sModel)
  if(not SetPosBound(ePiece,vPos or GetOpVar("VEC_ZERO"),pPly)) then
    return StatusLog(nil,"MakePiece: "..pPly:Nick().." spawned <"..sModel.."> outside of bounds") end
  ePiece:SetAngles(aAng or GetOpVar("ANG_ZERO"))
  ePiece:Spawn()
  ePiece:Activate()
  ePiece:SetRenderMode(RENDERMODE_TRANSALPHA)
  ePiece:SetColor(clColor or Color(255,255,255,255))
  ePiece:DrawShadow(false)
  ePiece:PhysWake()
  local phPiece = ePiece:GetPhysicsObject()
  if(not (phPiece and phPiece:IsValid())) then ePiece:Remove()
    return StatusLog(nil,"MakePiece: Entity phys object invalid") end
  phPiece:EnableMotion(false)
  phPiece:SetMass(mathClamp(tonumber(nMass) or 1,1,GetOpVar("MAX_MASS")))
  local BgSk = stringExplode(GetOpVar("OPSYM_DIRECTORY"),(sBgSkIDs or ""))
  ePiece:SetSkin(mathClamp(tonumber(BgSk[2]) or 0,0,ePiece:SkinCount()-1))
  if(not AttachBodyGroups(ePiece,BgSk[1] or "")) then ePiece:Remove()
    return StatusLog(nil,"MakePiece: Failed to attach bodygroups") end
  pPly:AddCount(sLimit , ePiece); pPly:AddCleanup(sLimit , ePiece) -- This sets the ownership
  pPly:AddCount("props", ePiece); pPly:AddCleanup("props", ePiece) -- To be deleted with clearing props
  return StatusLog(ePiece,"MakePiece: "..tostring(ePiece)..sModel)
end

function HookOnRemove(oBas,oEnt,arCTable,nMax)
  if(not (oBas and oBas:IsValid())) then return StatusLog(nil,"HookOnRemove: Base invalid") end
  if(not (oEnt and oEnt:IsValid())) then return StatusLog(nil,"HookOnRemove: Prop invalid") end
  if(not (arCTable and nMax)) then return StatusLog(nil,"HookOnRemove: Constraint list empty") end
  if(nMax < 1) then return end
  local Ind = 1
  while(Ind <= nMax) do
    if(not arCTable[Ind]) then
      StatusLog(nil,"HookOnRemove: Empty value on index "..tostring(Ind)..", ignored !")
    else oEnt:DeleteOnRemove(arCTable[Ind]); oBas:DeleteOnRemove(arCTable[Ind]); Ind = Ind + 1 end
  end; LogInstance("HookOnRemove: Done "..(Ind-1).." of "..nMax..".")
end

function ApplyPhysicalSettings(ePiece,bFr,bGr,nNo)
  if(not (ePiece and ePiece:IsValid())) then
    return StatusLog(false,"ApplyPhysicalSettings: Piece not valid") end
  local bGr = tobool(bGr) or false
  local Frz = tobool(bFr) or false
  local bNo = tobool(bNo) or false
  LogInstance("ApplyPhysicalSettings: {"..tostring(bGr)..","..tostring(bFr)..","..tostring(bNo).."}")
  dataSettings = {bGr,bFr,bNo}
  ePiece:SetUnFreezable(bNo)
  ePiece.PhysgunDisabled = bNo
  local pyPiece = ePiece:GetPhysicsObject()
  if(not (pyPiece and pyPiece:IsValid())) then
    return StatusLog(false,"ApplyPhysicalSettings: Phys Piece not valid") end
  pyPiece:EnableMotion(not bFr)
  constructSetPhysProp(nil,ePiece,0,pyPiece,{GravityToggle = bGr, Material = "gmod_ice"})
  duplicatorStoreEntityModifier(ePiece,GetOpVar("TOOLNAME_PL").."dupe_phys_set",dataSettings)
  return StatusLog(true,"ApplyPhysicalSettings: Success")
end

function ApplyPhysicalAnchor(ePiece,eBase,vPos,vNorm,nCID,nNoC,nFoL)
  local ConstrDB = GetOpVar("CONTAIN_CONSTRAINT_TYPE")
  local CID = tonumber(nCID) or 1
  local NoC = tonumber(nNoC) or 0
  local FrL = tonumber(nFoL) or 0
  local IsIn
  local ConstrInfo = ConstrDB:Select(CID)
  if(not IsExistent(ConstrInfo)) then
    return StatusLog(false,"ApplyPhysicalAnchor: Constraint not available") end
  LogInstance("ApplyPhysicalAnchor: ["..ConstrInfo.Name.."] {"..CID..","..NoC..","..FrL.."}")
  if(not (ePiece and ePiece:IsValid())) then
    return StatusLog(false,"ApplyPhysicalAnchor: Piece not valid") end
  if(IsOther(ePiece)) then
    return StatusLog(false,"ApplyPhysicalAnchor: Piece is other object") end
  if(not constraintCanConstrain(ePiece,0)) then
    return StatusLog(false,"ApplyPhysicalAnchor: Cannot constrain Piece") end
  local pyPiece = ePiece:GetPhysicsObject()
  if(not (pyPiece and pyPiece:IsValid())) then
    return StatusLog(false,"ApplyPhysicalAnchor: Phys Piece not valid") end
  if(not IsIn and CID == 1) then IsIn = CID end
  if(not (eBase and eBase:IsValid())) then
    return StatusLog(0,"ApplyPhysicalAnchor: Base not valid") end
  if(not constraintCanConstrain(eBase,0)) then
    return StatusLog(false,"ApplyPhysicalAnchor: Cannot constrain Base") end
  if(IsOther(eBase)) then
    return StatusLog(false,"ApplyPhysicalAnchor: Base is other object") end
  if(not IsIn and CID == 2) then
    -- http://wiki.garrysmod.com/page/Entity/SetParent
    ePiece:SetParent(eBase)
    IsIn = CID
  elseif(not IsIn and CID == 3) then
    -- http://wiki.garrysmod.com/page/constraint/Weld
    local C = ConstrInfo.Make(ePiece,eBase,0,0,FrL,(NoC ~= 0),false)
    HookOnRemove(eBase,ePiece,{C},1)
    IsIn = CID
  end
  if(not IsIn and CID == 4 and vNorm) then
    -- http://wiki.garrysmod.com/page/constraint/Axis
    local LPos1 = pyPiece:GetMassCenter()
    local LPos2 = ePiece:LocalToWorld(LPos1)
          LPos2:Add(vNorm)
          LPos2:Set(eBase:WorldToLocal(LPos2))
    local C = ConstrInfo.Make(ePiece,eBase,0,0,
                LPos1,LPos2,FrL,0,0,NoC)
     HookOnRemove(eBase,ePiece,{C},1)
     IsIn = CID
  elseif(not IsIn and CID == 5) then
    -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( HD )
    local C = ConstrInfo.Make(eBase,ePiece,0,0,pyPiece:GetMassCenter(),FrL,0,NoC)
    HookOnRemove(eBase,ePiece,{C},1)
    IsIn = CID
  elseif(not IsIn and CID == 6 and vPos) then
    -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( TR )
    local vLPos2 = eBase:WorldToLocal(vPos)
    local C = ConstrInfo.Make(ePiece,eBase,0,0,vLPos2,FrL,0,NoC)
    HookOnRemove(eBase,ePiece,{C},1)
    IsIn = CID
  end
  -- http://wiki.garrysmod.com/page/constraint/AdvBallsocket
  local pyBase = eBase:GetPhysicsObject()
  if(not (pyBase and pyBase:IsValid())) then
    return StatusLog(false,"ApplyPhysicalAnchor: Phys Base not valid") end
  local Min,Max = 0.01,180
  local LPos1 = pyBase:GetMassCenter()
  local LPos2 = pyPiece:GetMassCenter()
  if(not IsIn and CID == 7) then -- Lock X
    local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Min,-Max,-Max,Min,Max,Max,0,0,0,1,NoC)
    HookOnRemove(eBase,ePiece,{C},1)
    IsIn = CID
  elseif(not IsIn and CID == 8) then -- Lock Y
    local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Max,-Min,-Max,Max,Min,Max,0,0,0,1,NoC)
    HookOnRemove(eBase,ePiece,{C},1)
    IsIn = CID
  elseif(not IsIn and CID == 9) then -- Lock Z
    local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Max,-Max,-Min,Max,Max,Min,0,0,0,1,NoC)
    HookOnRemove(eBase,ePiece,{C},1)
    IsIn = CID
  elseif(not IsIn and CID == 10) then -- Spin X
    local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Max,-Min,-Min,Max, Min, Min,0,0,0,1,NoC)
    local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Max, Min, Min,Max,-Min,-Min,0,0,0,1,NoC)
    HookOnRemove(eBase,ePiece,{C1,C2},2)
    IsIn = CID
  elseif(not IsIn and CID == 11) then -- Spin Y
    local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Min,-Max,-Min, Min,Max, Min,0,0,0,1,NoC)
    local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0, Min,-Max, Min,-Min,Max,-Min,0,0,0,1,NoC)
    HookOnRemove(eBase,ePiece,{C1,C2},2)
    IsIn = CID
  elseif(not IsIn and CID == 12) then -- Spin Z
    local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Min,-Min,-Max, Min, Min,Max,0,0,0,1,NoC)
    local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0, Min, Min,-Max,-Min,-Min,Max,0,0,0,1,NoC)
    HookOnRemove(eBase,ePiece,{C1,C2},2)
    IsIn = CID
  end
  return StatusLog(IsIn,"ApplyPhysicalAnchor: Status <"..tostring(IsIn)..">")
end

function MakeAsmVar(sShortName, sValue, tBorder, nFlags, sInfo)
  if(not IsString(sShortName)) then
    return StatusLog(nil,"MakeAsmVar: CVar name {"..type(sShortName).."}<"..tostring(sShortName).."> not string") end
  if(not IsExistent(sValue)) then
    return StatusLog(nil,"MakeAsmVar: Wrong default value <"..tostring(sValue)..">") end
  if(not IsString(sInfo)) then
    return StatusLog(nil,"MakeAsmVar: CVar info {"..type(sInfo).."}<"..tostring(sInfo).."> not string") end
  local sVar = GetOpVar("TOOLNAME_PL")..stringLower(sShortName)
  if(tBorder and (type(tBorder) == "table") and tBorder[1] and tBorder[2]) then
    local Border = GetOpVar("TABLE_BORDERS")
    Border["cvar_"..sVar] = tBorder
  end
  return CreateConVar(sVar, sValue, nFlags, sInfo)
end

function GetAsmVar(sShortName, sMode)
  if(not IsString(sShortName)) then
    return StatusLog(nil,"GetAsmVar: CVar name {"..type(sShortName).."}<"..tostring(sShortName).."> not string") end
  if(not IsString(sMode)) then
    return StatusLog(nil,"GetAsmVar: CVar mode {"..type(sMode).."}<"..tostring(sMode).."> not string") end
  local sVar = GetOpVar("TOOLNAME_PL")..stringLower(sShortName)
  local CVar = GetConVar(sVar)
  if(not IsExistent(CVar)) then
    return StatusLog(nil,"GetAsmVar("..sShortName..", "..sMode.."): Missing CVar object") end
  if    (sMode == "INT") then return (tonumber(BorderValue(CVar:GetInt()  ,"cvar_"..sVar)) or 0)
  elseif(sMode == "FLT") then return (tonumber(BorderValue(CVar:GetFloat(),"cvar_"..sVar)) or 0)
  elseif(sMode == "STR") then return  tostring(CVar:GetString() or "")
  elseif(sMode == "BUL") then return (CVar:GetBool() or false)
  elseif(sMode == "DEF") then return  CVar:GetDefault()
  elseif(sMode == "INF") then return  CVar:GetHelpText()
  elseif(sMode == "NAM") then return  CVar:GetName()
  end; return StatusLog(nil,"GetAsmVar("..sShortName..", "..sMode.."): Missed mode")
end
