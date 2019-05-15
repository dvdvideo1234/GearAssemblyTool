local cvX, cvY, cvZ -- Vector Component indexes
local caP, caY, caR -- Angle Component indexes
local wvX, wvY, wvZ -- Wire vector Component indexes
local waP, waY, waR -- Wire angle Component indexes

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

local MASK_SOLID            = MASK_SOLID
local SOLID_VPHYSICS        = SOLID_VPHYSICS
local SOLID_NONE            = SOLID_NONE
local MOVETYPE_VPHYSICS     = MOVETYPE_VPHYSICS
local MOVETYPE_NONE         = MOVETYPE_NONE
local COLLISION_GROUP_NONE  = COLLISION_GROUP_NONE
local RENDERMODE_TRANSALPHA = RENDERMODE_TRANSALPHA

---------------- Localizing needed functions ----------------

local next                    = next
local type                    = type
local pcall                   = pcall
local Angle                   = Angle
local Color                   = Color
local pairs                   = pairs
local print                   = print
local tobool                  = tobool
local Vector                  = Vector
local Matrix                         = Matrix
local unpack                  = unpack
local include                 = include
local IsValid                 = IsValid
local Material                = Material
local require                 = require
local Time                           = CurTime
local tonumber                = tonumber
local tostring                = tostring
local GetConVar               = GetConVar
local LocalPlayer             = LocalPlayer
local CreateConVar            = CreateConVar
local RunConsoleCommand              = RunConsoleCommand
local SetClipboardText        = SetClipboardText
local CompileString           = CompileString
local CompileFile                    = CompileFile
local getmetatable            = getmetatable
local setmetatable            = setmetatable
local collectgarbage          = collectgarbage
local osClock                 = os and os.clock
local osDate                  = os and os.date
local bitBand                 = bit and bit.band
local sqlQuery                = sql and sql.Query
local sqlLastError            = sql and sql.LastError
local sqlTableExists          = sql and sql.TableExists
local gameSinglePlayer        = game and game.SinglePlayer
local utilTraceLine           = util and util.TraceLine
local utilIsInWorld           = util and util.IsInWorld
local utilIsValidModel        = util and util.IsValidModel
local utilGetPlayerTrace      = util and util.GetPlayerTrace
local entsCreate              = ents and ents.Create
local entsCreateClientProp           = ents and ents.CreateClientProp
local fileOpen                = file and file.Open
local fileExists              = file and file.Exists
local fileAppend              = file and file.Append
local fileDelete              = file and file.Delete
local fileCreateDir           = file and file.CreateDir
local mathPi                  = math and math.pi
local mathAbs                 = math and math.abs
local mathSin                 = math and math.sin
local mathCos                 = math and math.cos
local mathCeil                = math and math.ceil
local mathModf                = math and math.modf
local mathSqrt                = math and math.sqrt
local mathFloor               = math and math.floor
local mathClamp               = math and math.Clamp
local mathHuge                       = math and math.huge
local mathAtan2                      = math and math.atan2
local mathRound                      = math and math.Round
local mathRandom              = math and math.random
local mathNormalizeAngle             = math and math.NormalizeAngle
local vguiCreate                     = vgui and vgui.Create
local undoCreate              = undo and undo.Create
local undoFinish              = undo and undo.Finish
local undoAddEntity           = undo and undo.AddEntity
local undoSetPlayer           = undo and undo.SetPlayer
local undoSetCustomUndoText   = undo and undo.SetCustomUndoText
local timerStop               = timer and timer.Stop
local timerStart              = timer and timer.Start
local timerSimple             = timer and timer.Simple
local timerExists             = timer and timer.Exists
local timerCreate             = timer and timer.Create
local timerDestroy            = timer and timer.Destroy
local tableEmpty              = table and table.Empty
local tableMaxn               = table and table.maxn
local tableGetKeys            = table and table.GetKeys
local tableInsert             = table and table.insert
local tableCopy                      = table and table.Copy
local debugGetinfo            = debug and debug.getinfo
local debugTrace                     = debug and debug.Trace
local renderDrawLine          = render and render.DrawLine
local renderDrawSphere        = render and render.DrawSphere
local renderSetMaterial       = render and render.SetMaterial
local surfaceSetFont          = surface and surface.SetFont
local surfaceDrawLine         = surface and surface.DrawLine
local surfaceDrawText         = surface and surface.DrawText
local surfaceDrawCircle       = surface and surface.DrawCircle
local surfaceSetTexture       = surface and surface.SetTexture
local surfaceSetTextPos       = surface and surface.SetTextPos
local surfaceGetTextSize      = surface and surface.GetTextSize
local surfaceGetTextureID     = surface and surface.GetTextureID
local surfaceSetDrawColor     = surface and surface.SetDrawColor
local surfaceSetTextColor     = surface and surface.SetTextColor
local surfaceScreenWidth             = surface and surface.ScreenWidth
local surfaceScreenHeight            = surface and surface.ScreenHeight
local surfaceDrawTexturedRect = surface and surface.DrawTexturedRect
local surfaceDrawTexturedRectRotated = surface and surface.DrawTexturedRectRotated
local languageAdd             = language and language.Add
local constructSetPhysProp    = construct and construct.SetPhysProp
local constraintWeld          = constraint and constraint.Weld
local constraintNoCollide     = constraint and constraint.NoCollide
local constraintCanConstrain  = constraint and constraint.CanConstrain
local cvarsAddChangeCallback  = cvars and cvars.AddChangeCallback
local cvarsRemoveChangeCallback = cvars and cvars.RemoveChangeCallback
local duplicatorStoreEntityModifier = duplicator and duplicator.StoreEntityModifier

---------------- CASHES SPACE --------------------

local libCache  = {} -- Used to cache stuff in a pool
local libAction = {} -- Used to attach external function to the lib
local libOpVars = {} -- Used to Store operational variable values
local libPlayer = {} -- Used to allocate personal space for players
local libQTable = {} -- Used to allocate SQL table builder objects

module( "gearasmlib" )

---------------------------- PRIMITIVES ----------------------------

function GetInstPref()
  if    (CLIENT) then return "cl_"
  elseif(SERVER) then return "sv_" end
  return "na_"
end

function GetOpVar(sName)
  return libOpVars[sName]
end

function SetOpVar(sName, vVal)
  libOpVars[sName] = vVal
end

function IsHere(vVal)
  return (vVal ~= nil)
end

function IsString(vVal)
  return (getmetatable(vVal) == GetOpVar("TYPEMT_STRING"))
end

function IsBlank(vVal)
  if(not IsString(vVal)) then return false end
  return (vVal == "")
end

function IsNull(vVal)
  if(not IsString(vVal)) then return false end
  return (vVal == GetOpVar("MISS_NOSQL"))
end

function IsExact(vVal)
  if(not IsString(vVal)) then return false end
  return (vVal:sub(1,1) == "*")
end

function IsBool(vVal)
  if    (vVal == true ) then return true
  elseif(vVal == false) then return true end
  return false
end

function IsNumber(vVal)
  return ((tonumber(vVal) and true) or false)
end

function IsTable(vVal)
  return (type(vVal) == "table")
end

function IsFunction(vVal)
  return (type(vVal) == "function")
end

function IsPlayer(oPly)
  if(not IsHere(oPly)) then return false end
  if(not oPly:IsValid  ()) then return false end
  if(not oPly:IsPlayer ()) then return false end
  return true
end

function IsOther(oEnt)
  if(not IsHere(oEnt))   then return true end
  if(not oEnt:IsValid())   then return true end
  if(oEnt:IsPlayer())      then return true end
  if(oEnt:IsVehicle())     then return true end
  if(oEnt:IsNPC())         then return true end
  if(oEnt:IsRagdoll())     then return true end
  if(oEnt:IsWeapon())      then return true end
  if(oEnt:IsWidget())      then return true end
  return false
end

-- Reports the type and actual value
function GetReport(vVal)
  return ("{"..type(sKey).."}<"..tostring(sKey)..">")
end

-- Returns the sign of a number [-1,0,1]
function GetSign(nVal)
  return (nVal / mathAbs(nVal))
end

-- Gets the date according to the specified format
function GetDate()
  return (osDate(GetOpVar("DATE_FORMAT"))
   .." "..osDate(GetOpVar("TIME_FORMAT")))
end

-- Strips a string from quotes
function GetStrip(vV, vQ)
  local sV = tostring(vV or ""):Trim()
  local sQ = tostring(vQ or "\""):sub(1,1)
  if(sV:sub( 1, 1) == sQ) then sV = sV:sub(2,-1) end
  if(sV:sub(-1,-1) == sQ) then sV = sV:sub(1,-2) end
  return sV:Trim()
end

------------------ LOGS ------------------------

local function GetLogID()
  local nNum, nMax = GetOpVar("LOG_CURLOGS"), GetOpVar("LOG_MAXLOGS")
  if(not (nNum and nMax)) then return "" end
  return ("%"..(tostring(mathFloor(nMax))):len().."d"):format(nNum)
end

local function Log(vMsg, bCon)
  local iMax = GetOpVar("LOG_MAXLOGS")
  if(iMax <= 0) then return end
  local iCur = GetOpVar("LOG_CURLOGS") + 1
  local sData = tostring(vMsg); SetOpVar("LOG_CURLOGS",iCur)
  if(GetOpVar("LOG_LOGFILE") and not bCon) then
    local lbNam = GetOpVar("NAME_LIBRARY")
    local fName = GetOpVar("DIRPATH_BAS")..lbNam.."_log.txt"
    if(iCur > iMax) then iCur = 0; fileDelete(fName) end
    fileAppend(fName,GetLogID().." ["..GetDate().."] "..sData.."\n")
  else -- The current has values 1..nMaxLogs(0)
    if(iCur > iMax) then iCur = 0 end
    print(GetLogID().." ["..GetDate().."] "..sData)
  end
end

--[[
  sMsg > Message being displayed
  sKey > SKIP / ONLY
  Return: exist, found
]]
local function IsLogFound(sMsg, sKey)
  local sMsg = tostring(sMsg or "")
  local sKey = tostring(sKey or "")
  if(IsBlank(sKey)) then return nil end
  local oStat = GetOpVar("LOG_"..sKey)
  if(IsTable(oStat) and oStat[1]) then
    local iCnt = 1; while(oStat[iCnt]) do
      if(sMsg:find(tostring(oStat[iCnt]))) then
        return true, true
      end; iCnt = iCnt + 1
    end; return true, false
  else return false, false end
end

--[[
  vMsg > Message being displayed
  vSrc > Name of the sub-routine call (string) or parameter stack (table)
  bCon > Force output in console flag
  iDbg > Debug table overrive depth
  tDbg > Debug table overrive
]]
function LogInstance(vMsg, vSrc, bCon, iDbg, tDbg)
  local nMax = (tonumber(GetOpVar("LOG_MAXLOGS")) or 0)
  if(nMax and (nMax <= 0)) then return end
  local vSrc, bCon, iDbg, tDbg = vSrc, bCon, iDbg, tDbg
  if(vSrc and IsTable(vSrc)) then -- Recieve the stack as table
    vSrc, bCon, iDbg, tDbg = vSrc[1], vSrc[2], vSrc[3], vSrc[4] end
  iDbg = mathFloor(tonumber(iDbg) or 0); iDbg = ((iDbg > 0) and iDbg or nil)
  local tInfo = (iDbg and debugGetinfo(iDbg) or nil) -- Pass stack index
        tInfo = (tInfo or (tDbg and tDbg or nil))    -- Override debug information
        tInfo = (tInfo or debugGetinfo(2))           -- Default value
  local sDbg, sFunc = "", tostring(sFunc or (tInfo.name and tInfo.name or "Incognito"))
  if(GetOpVar("LOG_DEBUGEN")) then
    local snID, snAV = GetOpVar("MISS_NOID"), GetOpVar("MISS_NOAV")
    sDbg = sDbg.." "..(tInfo.linedefined and "["..tInfo.linedefined.."]" or snAV)
    sDbg = sDbg..(tInfo.currentline and ("["..tInfo.currentline.."]") or snAV)
    sDbg = sDbg.."@"..(tInfo.source and (tInfo.source:gsub("^%W+", ""):gsub("\\","/")) or snID)
  end; local sSrc, bF, bL = tostring(vSrc or "")
  if(IsExact(sSrc)) then sSrc = sSrc:sub(2,-1); sFunc = "" else
    if(not IsBlank(sSrc)) then sSrc = sSrc.."." end end
  local sInst   = ((SERVER and "SERVER" or nil) or (CLIENT and "CLIENT" or nil) or "NOINST")
  local sMoDB, sToolMD = tostring(GetOpVar("MODE_DATABASE")), tostring(GetOpVar("TOOLNAME_NU"))
  local sLast, sData = GetOpVar("LOG_LOGLAST"), (sSrc..sFunc..": "..tostring(vMsg))
  bF, bL = IsLogFound(sData, "SKIP"); if(bF and bL) then return end
  bF, bL = IsLogFound(sData, "ONLY"); if(bF and not bL) then return end
  if(sLast == sData) then return end; SetOpVar("LOG_LOGLAST",sData)
  Log(sInst.." > "..sToolMD.." ["..sMoDB.."]"..sDbg.." "..sData, bCon)
end

local function LogCeption(tT,sS,tP)
  local vS, vT = type(sS), type(tT)
  local vK, sS = "", tostring(sS or "Data")
  if(vT ~= "table") then
    LogInstance("{"..vT.."}["..sS.."] = <"..tostring(tT)..">",tP); return nil end
  if(next(tT) == nil) then
    LogInstance(sS.." = {}",tP); return nil end; LogInstance(sS.." = {}",tP)
  for k,v in pairs(tT) do
    if(type(k) == "string") then
      vK = sS.."[\""..k.."\"]"
    else vK = sS.."["..tostring(k).."]" end
    if(type(v) ~= "table") then
      if(type(v) == "string") then
        LogInstance(vK.." = \""..v.."\"",tP)
      else LogInstance(vK.." = "..tostring(v),tP) end
    else
      if(v == tT) then LogInstance(vK.." = "..sS,tP)
      else LogCeption(v,vK,tP) end
    end
  end
end

function LogTable(tT, sS, vSrc, bCon, iDbg, tDbg)
  local vSrc, bCon, iDbg, tDbg = vSrc, bCon, iDbg, tDbg
  if(vSrc and IsTable(vSrc)) then -- Recieve the stack as table
    vSrc, bCon, iDbg, tDbg = vSrc[1], vSrc[2], vSrc[3], vSrc[4] end
  local tP = {vSrc, bCon, iDbg, tDbg} -- Normalize parameters
  tP[1], tP[2] = tostring(vSrc or ""), tobool(bCon)
  tP[3], tP[4] = (nil), debugGetinfo(2); LogCeption(tT,sS,tP)
end
----------------- INITAIALIZATION -----------------

-- Golden retriever. Retrieves file line as string
-- But seriously returns the sting line and EOF flag
local function GetStringFile(pFile)
  if(not pFile) then LogInstance("No file"); return "", true end
  local sCh, sLine = "X", "" -- Use a value to start cycle with
  while(sCh) do sCh = pFile:Read(1); if(not sCh) then break end
    if(sCh == "\n") then return sLine:Trim(), false else sLine = sLine..sCh end
  end; return sLine:Trim(), true -- EOF has been reached. Return the last data
end

function SetLogControl(nLines,bFile)
  SetOpVar("LOG_CURLOGS",0)
  SetOpVar("LOG_LOGFILE",tobool(bFile))
  SetOpVar("LOG_MAXLOGS",mathFloor(tonumber(nLines) or 0))
  local sBas = GetOpVar("DIRPATH_BAS")
  local sMax = tostring(GetOpVar("LOG_MAXLOGS"))
  local sNam = tostring(GetOpVar("LOG_LOGFILE"))
  if(sBas and not fileExists(sBas,"DATA") and
     not IsBlank(GetOpVar("LOG_LOGFILE"))) then fileCreateDir(sBas)
  end; LogInstance("("..sMax..","..sNam..")")
end

function SettingsLogs(sHash)
  local sKey = tostring(sHash or ""):upper():Trim()
  if(not (sKey == "SKIP" or sKey == "ONLY")) then
    LogInstance("Invalid <"..sKey..">"); return false end
  local tLogs, lbNam = GetOpVar("LOG_"..sKey), GetOpVar("NAME_LIBRARY")
  if(not tLogs) then LogInstance("Skip <"..sKey..">"); return false end
  local fName = GetOpVar("DIRPATH_BAS")..lbNam.."_sl"..sKey:lower()..".txt"
  local S = fileOpen(fName, "rb", "DATA"); tableEmpty(tLogs)
  if(S) then local sLine, isEOF = "", false
    while(not isEOF) do sLine, isEOF = GetStringFile(S)
      if(not IsBlank(sLine)) then tableInsert(tLogs, sLine) end
    end; S:Close(); LogInstance("Success <"..sKey.."@"..fName..">"); return false
  else LogInstance("Missing <"..sKey.."@"..fName..">"); return false end
end

function GetIndexes(sType)
  if(not IsString(sType)) then
    LogInstance("Type "..GetReport(sType).." not string"); return nil end
  if    (sType == "V")  then return cvX, cvY, cvZ
  elseif(sType == "A")  then return caP, caY, caR
  else LogInstance("Type <"..sType.."> not found"); return nil end
end

function SetIndexes(sType,...)
  if(not IsString(sType)) then
    LogInstance("Type "..GetReport(sType).." not string"); return false end
  if    (sType == "V")  then cvX, cvY, cvZ = ...
  elseif(sType == "A")  then caP, caY, caR = ...
  else LogInstance("Type <"..sType.."> not found"); return false end
  LogInstance("Success"); return true
end

function UseIndexes(pB1,pB2,pB3,pD1,pD2,pD3)
  return (pB1 or pD1), (pB2 or pD2), (pB3 or pD3)
end

function InitBase(sName,sPurpose)
  SetOpVar("TYPEMT_STRING",getmetatable("TYPEMT_STRING"))
  SetOpVar("TYPEMT_SCREEN",{})
  SetOpVar("TYPEMT_CONTAINER",{})
  if(not IsString(sName)) then
    LogInstance("Name <"..tostring(sName).."> not string", true); return false end
  if(not IsString(sPurpose)) then
    LogInstance("Purpose <"..tostring(sPurpose).."> not string", true); return false end
  if(IsBlank(sName) or tonumber(sName:sub(1,1))) then
    LogInstance("Name invalid <"..sName..">", true); return false end
  if(IsBlank(sPurpose) or tonumber(sPurpose:sub(1,1))) then
    LogInstance("Purpose invalid <"..sPurpose..">", true); return false end
  SetOpVar("TIME_INIT",Time())
  SetOpVar("LOG_MAXLOGS",0)
  SetOpVar("LOG_CURLOGS",0)
  SetOpVar("LOG_SKIP",{})
  SetOpVar("LOG_ONLY",{})
  SetOpVar("LOG_LOGFILE","")
  SetOpVar("LOG_LOGLAST","")
  SetOpVar("MAX_ROTATION",360)
  SetOpVar("DELAY_FREEZE",0.01)
  SetOpVar("ANG_ZERO",Angle())
  SetOpVar("VEC_ZERO",Vector())
  SetOpVar("ANG_REV",Angle(0,180,0))
  SetOpVar("VEC_FW",Vector(1,0,0))
  SetOpVar("VEC_RG",Vector(0,-1,1))
  SetOpVar("VEC_UP",Vector(0,0,1))
  SetOpVar("OPSYM_DISABLE","#")
  SetOpVar("OPSYM_REVISION","@")
  SetOpVar("OPSYM_DIVIDER","_")
  SetOpVar("OPSYM_DIRECTORY","/")
  SetOpVar("OPSYM_SEPARATOR",",")
  SetOpVar("OPSYM_ENTPOSANG","!")
  SetOpVar("DEG_RAD", mathPi / 180)
  SetOpVar("WIDTH_CPANEL", 281)
  SetOpVar("EPSILON_ZERO", 1e-5)
  SetOpVar("COLOR_CLAMP", {0, 255})
  SetOpVar("GOLDEN_RATIO",1.61803398875)
  SetOpVar("DATE_FORMAT","%d-%m-%y")
  SetOpVar("INFINITY",mathHuge)
  SetOpVar("TIME_FORMAT","%H:%M:%S")
  SetOpVar("NAME_INIT",sName:lower())
  SetOpVar("NAME_PERP",sPurpose:lower())
  SetOpVar("NAME_LIBRARY", GetOpVar("NAME_INIT").."asmlib")
  SetOpVar("TOOLNAME_NL",(GetOpVar("NAME_INIT")..GetOpVar("NAME_PERP")):lower())
  SetOpVar("TOOLNAME_NU",(GetOpVar("NAME_INIT")..GetOpVar("NAME_PERP")):upper())
  SetOpVar("TOOLNAME_PL",GetOpVar("TOOLNAME_NL").."_")
  SetOpVar("TOOLNAME_PU",GetOpVar("TOOLNAME_NU").."_")
  SetOpVar("DIRPATH_BAS",GetOpVar("TOOLNAME_NL")..GetOpVar("OPSYM_DIRECTORY"))
  SetOpVar("DIRPATH_INS","exp"..GetOpVar("OPSYM_DIRECTORY"))
  SetOpVar("DIRPATH_DSV","dsv"..GetOpVar("OPSYM_DIRECTORY"))
  SetOpVar("MISS_NOID","N")     -- No ID selected
  SetOpVar("MISS_NOAV","N/A")   -- Not Available
  SetOpVar("MISS_NOMD","X")     -- No model
  SetOpVar("MISS_NOTP","TYPE")  -- No track type
  SetOpVar("MISS_NOSQL","NULL") -- No SQL value
  SetOpVar("MISS_NOTR","Oops, missing ?") -- No translation found
  SetOpVar("FORM_KEYSTMT","%s(%s)")
  SetOpVar("FORM_LOGSOURCE","%s.%s(%s)")
  SetOpVar("ARRAY_DECODEPOA",{0,0,0,Size=3})
  SetOpVar("FORM_LANGPATH","%s"..GetOpVar("TOOLNAME_NL").."/lang/%s")
  SetOpVar("FORM_SNAPSND", "physics/metal/metal_canister_impact_hard%d.wav")
  SetOpVar("FORM_NTFGAME", "GAMEMODE:AddNotify(\"%s\", NOTIFY_%s, 6)")
  SetOpVar("FORM_NTFPLAY", "surface.PlaySound(\"ambient/water/drip%d.wav\")")
  SetOpVar("FORM_CONCMD", GetOpVar("TOOLNAME_PL").."%s %s\n")
  if(CLIENT) then
    SetOpVar("ARRAY_GHOST",{Size=0, Slot=GetOpVar("MISS_NOMD")})
    SetOpVar("LOCALIFY_AUTO","en")
    SetOpVar("LOCALIFY_TABLE",{})
    SetOpVar("TABLE_CATEGORIES",{})
    SetOpVar("STRUCT_SPAWN",{
      {"--- Origin ---"},
      {"F", "VEC", "Forward direction"},
      {"R", "VEC", "Right direction"},
      {"U", "VEC", "Up direction"},
      {"OPos", "VEC", "Origin position"},
      {"OAng", "ANG", "Origin angles"},
      {"SPos", "VEC", "Spawn position"},
      {"SAng", "ANG", "Spawn angles"},
      {"DPos", "VEC", "Domain position"},
      {"DAng", "ANG", "Domain angles"},
      {"--- Holder ---"},
      {"HPnt", "VEC", "Radius vector"},
      {"HOrg", "VEC", "Mass center position"},
      {"HAng", "ANG", "Custom angles"},
      {"--- Traced ---"},
      {"TPnt", "VEC", "Radius vector"},
      {"TOrg", "VEC", "Mass center position"},
      {"TAng", "ANG", "Custom angles"},
      {"--- Offset ---"},
      {"PNxt", "VEC", "Custom user position"},
      {"ANxt", "ANG", "Custom user angles"}})
  end
  SetOpVar("MODELNAM_FILE","%.mdl")
  SetOpVar("MODELNAM_FUNC",function(x) return " "..x:sub(2,2):upper() end)
  SetOpVar("QUERY_STORE", {})
  SetOpVar("TABLE_BORDERS",{})
  SetOpVar("TABLE_CONVARLIST",{})
  SetOpVar("TOOL_DEFMODE","gmod_tool")
  SetOpVar("ENTITY_DEFCLASS", "prop_physics")
  SetOpVar("TABLE_FREQUENT_MODELS",{})
  SetOpVar("OOP_DEFAULTKEY","(!@<#_$|%^|&>*)DEFKEY(*>&|^%|$_#<@!)")
  SetOpVar("CVAR_LIMITNAME","asm"..GetOpVar("NAME_INIT").."s")
  SetOpVar("MODE_DATABASE",GetOpVar("MISS_NOAV"))
  SetOpVar("HASH_USER_PANEL",GetOpVar("TOOLNAME_PU").."USER_PANEL")
  LogInstance("Success"); return true
end

------------- VALUE ---------------
--[[
 * When requested wraps the first value according to
 * the interval described by the other two values
 * Inp: -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10
 * Out:  3  1  2  3  1  2 3 1 2 3 1 2 3 1 2 3  1
 * This is an example call for the input between 1 and 3
]]
function GetWrap(nVal,nMin,nMax) local nVal = nVal
  while(nVal < nMin or nVal > nMax) do
    nVal = ((nVal < nMin) and (nMax - (nMin - nVal) + 1) or nVal)
    nVal = ((nVal > nMax) and (nMin + (nVal - nMax) - 1) or nVal)
  end; return nVal -- Returns the N-stepped value
end

--[[
 * Applies border if existent to the input value
 * according to the given gorder name. Basicly
 * custom version of a clamp with vararg border limits
]]
local function BorderValue(nsVal, vKey)
  if(not IsHere(vKey)) then return nsVal end
  if(not (IsString(nsVal) or IsNumber(nsVal))) then
    LogInstance("Value not comparable"); return nsVal end
  local tB = GetOpVar("TABLE_BORDERS")[vKey]; if(not IsHere(tB)) then
    LogInstance("Missing <"..tostring(vKey)..">"); return nsVal end
  if(tB and tB[1] and nsVal < tB[1]) then return tB[1] end
  if(tB and tB[2] and nsVal > tB[2]) then return tB[2] end
  return nsVal
end

function SetBorder(vKey, vLow, vHig)
  if(not IsHere(vKey)) then
    LogInstance("Key missing"); return false end
  local tB = GetOpVar("TABLE_BORDERS")
  if(IsHere(tB[vKey])) then local tU = tB[vKey]
    local vL, vH = tostring(tU[1]), tostring(tU[2])
    LogInstance("Exists ("..tostring(vKey)..")<"..vL.."/"..vH..">")
  end; tB[vKey] = {vLow, vHig}; local vL, vH = tostring(vLow), tostring(vHig)
  LogInstance("Apply ("..tostring(vKey)..")<"..vL.."/"..vH..">"); return true
end

------------- COLOR ---------------

function FixColor(nC)
  local tC = GetOpVar("COLOR_CLAMP")
  return mathFloor(mathClamp((tonumber(nC) or 0), tC[1], tC[2]))
end

function GetColor(xR, xG, xB, xA)
  local nR, nG = FixColor(xR), FixColor(xG)
  local nB, nA = FixColor(xB), FixColor(xA)
  return Color(nR, nG, nB, nA)
end

function ToColor(vBase, pX, pY, pZ, vA)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  local iX, iY, iZ = UseIndexes(pX, pY, pZ, cvX, cvY, cvZ)
  return GetColor(vBase[iX], vBase[iY], vBase[iZ], vA)
end

------------- ANGLE ---------------

function ToAngle(aBase, pP, pY, pR)
  if(not aBase) then LogInstance("Base invalid"); return nil end
  local aP, aY, aR = UseIndexes(pP, pY, pR, caP, caY, caR)
  return Angle((tonumber(aBase[aP]) or 0), (tonumber(aBase[aY]) or 0), (tonumber(aBase[aR]) or 0))
end

function ExpAngle(aBase, pP, pY, pR)
  if(not aBase) then LogInstance("Base invalid"); return nil end
  local aP, aY, aR = UseIndexes(pP, pY, pR, caP, caY, caR)
  return (tonumber(aBase[aP]) or 0), (tonumber(aBase[aY]) or 0), (tonumber(aBase[aR]) or 0)
end

function AddAngle(aBase, aUnit)
  if(not aBase) then LogInstance("Base invalid"); return nil end
  if(not aUnit) then LogInstance("Unit invalid"); return nil end
  aBase[caP] = (tonumber(aBase[caP]) or 0) + (tonumber(aUnit[caP]) or 0)
  aBase[caY] = (tonumber(aBase[caY]) or 0) + (tonumber(aUnit[caY]) or 0)
  aBase[caR] = (tonumber(aBase[caR]) or 0) + (tonumber(aUnit[caR]) or 0)
end

function AddAnglePYR(aBase, nP, nY, nR)
  if(not aBase) then LogInstance("Base invalid"); return nil end
  aBase[caP] = (tonumber(aBase[caP]) or 0) + (tonumber(nP) or 0)
  aBase[caY] = (tonumber(aBase[caY]) or 0) + (tonumber(nY) or 0)
  aBase[caR] = (tonumber(aBase[caR]) or 0) + (tonumber(nR) or 0)
end

function SubAngle(aBase, aUnit)
  if(not aBase) then LogInstance("Base invalid"); return nil end
  if(not aUnit) then LogInstance("Unit invalid"); return nil end
  aBase[caP] = (tonumber(aBase[caP]) or 0) - (tonumber(aUnit[caP]) or 0)
  aBase[caY] = (tonumber(aBase[caY]) or 0) - (tonumber(aUnit[caY]) or 0)
  aBase[caR] = (tonumber(aBase[caR]) or 0) - (tonumber(aUnit[caR]) or 0)
end

function SubAnglePYR(aBase, nP, nY, nR)
  if(not aBase) then LogInstance("Base invalid"); return nil end
  aBase[caP] = (tonumber(aBase[caP]) or 0) - (tonumber(nP) or 0)
  aBase[caY] = (tonumber(aBase[caY]) or 0) - (tonumber(nY) or 0)
  aBase[caR] = (tonumber(aBase[caR]) or 0) - (tonumber(nR) or 0)
end

function NegAngle(vBase, bP, bY, bR)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  local P = (tonumber(vBase[caP]) or 0); P = (IsHere(bP) and (bP and -P or P) or -P)
  local Y = (tonumber(vBase[caY]) or 0); Y = (IsHere(bY) and (bY and -Y or Y) or -Y)
  local R = (tonumber(vBase[caR]) or 0); R = (IsHere(bR) and (bR and -R or R) or -R)
  vBase[caP], vBase[caY], vBase[caR] = P, Y, R
end

function SetAngle(aBase, aUnit)
  if(not aBase) then LogInstance("Base invalid"); return nil end
  if(not aUnit) then LogInstance("Unit invalid"); return nil end
  aBase[caP] = (tonumber(aUnit[caP]) or 0)
  aBase[caY] = (tonumber(aUnit[caY]) or 0)
  aBase[caR] = (tonumber(aUnit[caR]) or 0)
end

function SetAnglePYR(aBase, nP, nY, nR)
  if(not aBase) then LogInstance("Base invalid"); return nil end
  aBase[caP] = (tonumber(nP) or 0)
  aBase[caY] = (tonumber(nY) or 0)
  aBase[caR] = (tonumber(nR) or 0)
end

------------- VECTOR ---------------

function ToVector(vBase, pX, pY, pZ)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  local vX, vY, vZ = UseIndexes(pX, pY, pZ, cvX, cvY, cvZ)
  return Vector((tonumber(vBase[vX]) or 0), (tonumber(vBase[vY]) or 0), (tonumber(vBase[vZ]) or 0))
end

function ExpVector(vBase, pX, pY, pZ)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  local vX, vY, vZ = UseIndexes(pX, pY, pZ, cvX, cvY, cvZ)
  return (tonumber(vBase[vX]) or 0), (tonumber(vBase[vY]) or 0), (tonumber(vBase[vZ]) or 0)
end

function GetLengthVector(vBase)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  local X = (tonumber(vBase[cvX]) or 0); X = X * X
  local Y = (tonumber(vBase[cvY]) or 0); Y = Y * Y
  local Z = (tonumber(vBase[cvZ]) or 0); Z = Z * Z
  return mathSqrt(X + Y + Z)
end

function RoundVector(vBase,nvDec)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  local D = tonumber(nvDec); if(not IsHere(R)) then
    LogInstance("Round NAN "..GetReport(nvDec)); return nil end
  local X = (tonumber(vBase[cvX]) or 0); X = mathRound(X,D); vBase[cvX] = X
  local Y = (tonumber(vBase[cvY]) or 0); Y = mathRound(Y,D); vBase[cvY] = Y
  local Z = (tonumber(vBase[cvZ]) or 0); Z = mathRound(Z,D); vBase[cvZ] = Z
end

function AddVector(vBase, vUnit)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  if(not vUnit) then LogInstance("Unit invalid"); return nil end
  vBase[cvX] = (tonumber(vBase[cvX]) or 0) + (tonumber(vUnit[cvX]) or 0)
  vBase[cvY] = (tonumber(vBase[cvY]) or 0) + (tonumber(vUnit[cvY]) or 0)
  vBase[cvZ] = (tonumber(vBase[cvZ]) or 0) + (tonumber(vUnit[cvZ]) or 0)
end

function AddVectorXYZ(vBase, nX, nY, nZ)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  vBase[cvX] = (tonumber(vBase[cvX]) or 0) + (tonumber(nX) or 0)
  vBase[cvY] = (tonumber(vBase[cvY]) or 0) + (tonumber(nY) or 0)
  vBase[cvZ] = (tonumber(vBase[cvZ]) or 0) + (tonumber(nZ) or 0)
end

function SubVector(vBase, vUnit)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  if(not vUnit) then LogInstance("Unit invalid"); return nil end
  vBase[cvX] = (tonumber(vBase[cvX]) or 0) - (tonumber(vUnit[cvX]) or 0)
  vBase[cvY] = (tonumber(vBase[cvY]) or 0) - (tonumber(vUnit[cvY]) or 0)
  vBase[cvZ] = (tonumber(vBase[cvZ]) or 0) - (tonumber(vUnit[cvZ]) or 0)
end

function SubVectorXYZ(vBase, nX, nY, nZ)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  vBase[cvX] = (tonumber(vBase[cvX]) or 0) - (tonumber(nX) or 0)
  vBase[cvY] = (tonumber(vBase[cvY]) or 0) - (tonumber(nY) or 0)
  vBase[cvZ] = (tonumber(vBase[cvZ]) or 0) - (tonumber(nZ) or 0)
end

function NegVector(vBase, bX, bY, bZ)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  local X = (tonumber(vBase[cvX]) or 0); X = (IsHere(bX) and (bX and -X or X) or -X)
  local Y = (tonumber(vBase[cvY]) or 0); Y = (IsHere(bY) and (bY and -Y or Y) or -Y)
  local Z = (tonumber(vBase[cvZ]) or 0); Z = (IsHere(bZ) and (bZ and -Z or Z) or -Z)
  vBase[cvX], vBase[cvY], vBase[cvZ] = X, Y, Z
end

function SetVector(vBase, vUnit)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  if(not vUnit) then LogInstance("Unit invalid"); return nil end
  vBase[cvX] = (tonumber(vUnit[cvX]) or 0)
  vBase[cvY] = (tonumber(vUnit[cvY]) or 0)
  vBase[cvZ] = (tonumber(vUnit[cvZ]) or 0)
end

function SetVectorXYZ(vBase, nX, nY, nZ)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  vBase[cvX] = (tonumber(nX or 0))
  vBase[cvY] = (tonumber(nY or 0))
  vBase[cvZ] = (tonumber(nZ or 0))
end

function MulVectorXYZ(vBase, nX, nY, nZ)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  vBase[cvX] = vBase[cvX] * (tonumber(nX or 0))
  vBase[cvY] = vBase[cvY] * (tonumber(nY or 0))
  vBase[cvZ] = vBase[cvZ] * (tonumber(nZ or 0))
end

function DecomposeByAngle(vBase, aUnit)
  if(not vBase) then LogInstance("Base invalid"); return nil end
  if(not aUnit) then LogInstance("Unit invalid"); return nil end
  local X = vBase:Dot(aUnit:Forward())
  local Y = vBase:Dot(aUnit:Right())
  local Z = vBase:Dot(aUnit:Up())
  SetVectorXYZ(vBase,X,Y,Z)
end

-------------- 2DVECTOR ----------------

function NewXY(nX, nY)
  return {x=(tonumber(nX) or 0), y=(tonumber(nY) or 0)}
end

function SetXY(xyR, vA, vB) local xA, yA
  if(not xyR) then LogInstance("Base R invalid"); return nil end
  if(not vA ) then LogInstance("Base A invalid"); return nil end
  if(vB) then xA, yA = (tonumber(vA) or 0), (tonumber(vB) or 0)
  else xA, yA = (tonumber(vA.x) or 0), (tonumber(vA.y) or 0) end
  xyR.x, xyR.y = xA, yA; return xyR
end

function NegXY(xyR)
  if(not xyR) then LogInstance("Base invalid"); return nil end
  xyR.x, xyR.y = -xyR.x, -xyR.y; return xyR
end

function NegX(xyR)
  if(not xyR) then LogInstance("Base invalid"); return nil end
  xyR.x = -xyR.x; return xyR
end

function NegY(xyR)
  if(not xyR) then LogInstance("Base invalid"); return nil end
  xyR.y = -xyR.y; return xyR
end

function MulXY(xyR, vM)
  if(not xyR) then LogInstance("Base invalid"); return nil end
  local nM = (tonumber(vM) or 0)
  xyR.x, xyR.y = (xyR.x * nM), (xyR.y * nM); return xyR
end

function DivXY(xyR, vD)
  if(not xyR) then LogInstance("Base invalid"); return nil end
  local nD = (tonumber(vM) or 0)
  xyR.x, xyR.y = (xyR.x / nD), (xyR.y / nD); return xyR
end

function AddXY(xyR, xyA, xyB)
  if(not xyR) then LogInstance("Base R invalid"); return nil end
  if(not xyA) then LogInstance("Base A invalid"); return nil end
  if(not xyB) then LogInstance("Base B invalid"); return nil end
  local xA, yA = (tonumber(xyA.x) or 0), (tonumber(xyA.y) or 0)
  local xB, yB = (tonumber(xyB.x) or 0), (tonumber(xyB.y) or 0)
  xyR.x, xyR.y = (xA + xB), (yA + yB); return xyR
end

function SubXY(xyR, xyA, xyB)
  if(not xyR) then LogInstance("Base R invalid"); return nil end
  if(not xyA) then LogInstance("Base A invalid"); return nil end
  if(not xyB) then LogInstance("Base B invalid"); return nil end
  local xA, yA = (tonumber(xyA.x) or 0), (tonumber(xyA.y) or 0)
  local xB, yB = (tonumber(xyB.x) or 0), (tonumber(xyB.y) or 0)
  xyR.x, xyR.y = (xA - xB), (yA - yB); return xyR
end

function LenXY(xyR)
  if(not xyR) then LogInstance("Base invalid"); return nil end
  local xA, yA = (tonumber(xyR.x) or 0), (tonumber(xyR.y) or 0)
  return mathSqrt(xA * xA + yA * yA)
end

function ExpXY(xyR)
  if(not xyR) then LogInstance("Base invalid"); return nil end
  return (tonumber(xyR.x) or 0), (tonumber(xyR.y) or 0)
end

function UnitXY(xyR)
  if(not xyR) then LogInstance("Base invalid"); return nil end
  local nL = LenXY(xyR); if(nL == nL ) then
    LogInstance("Length A invalid"); return nil end
  xyR.xm, xyR.y = (tonumber(xyR.x) / nL), (tonumber(xyR.y) / nL)
  return xyR -- Return scaled unit vector
end

function MidXY(xyR, xyA, xyB)
  if(not xyR) then LogInstance("Base R invalid"); return nil end
  if(not xyA) then LogInstance("Base A invalid"); return nil end
  if(not xyB) then LogInstance("Base B invalid"); return nil end
  local xA, yA = (tonumber(xyA.x) or 0), (tonumber(xyA.y) or 0)
  local xB, yB = (tonumber(xyB.x) or 0), (tonumber(xyB.y) or 0)
  xyR.x, xyR.y = ((xA + xB) / 2), ((yA + yB) / 2); return xyR
end

function RotateXY(xyR, nR)
  if(not xyR) then LogInstance("Base invalid"); return nil end
  local nA = (tonumber(nR) or 0)
  if(nA == 0) then return xyR end
  local nX = (tonumber(xyR.x) or 0)
  local nY = (tonumber(xyR.y) or 0)
  local nS, nC = mathSin(nA), mathCos(nA)
  xyR.x = (nX * nC - nY * nS)
  xyR.y = (nX * nS + nY * nC); return xyR
end

function GetAngleXY(xyR)
  if(not xyR) then LogInstance("Base V invalid"); return nil end
  return mathAtan2(xyR.y, xyR.x)
end

----------------- OOP ------------------

function MakeContainer(sInfo,sDefKey)
  local Curs, Data, self = 0, {}, {}
  local sSel, sIns, sDel, sMet = "", "", "", ""
  local Info = tostring(sInfo or "Storage container")
  local Key  = sDefKey or GetOpVar("OOP_DEFAULTKEY")
  function self:GetInfo() return Info end
  function self:GetSize() return Curs end
  function self:GetData() return Data end
  function self:Insert(nsKey,vVal)
    sIns = nsKey or Key; sMet = "I"
    if(not IsHere(Data[sIns])) then Curs = Curs + 1; end
    Data[sIns] = vVal
  end
  function self:Select(nsKey)
    sSel = nsKey or Key; return Data[sSel]
  end
  function self:Delete(nsKey,fnDel)
    sDel = nsKey or Key; sMet = "D"
    if(IsHere(Data[sDel])) then
      if(IsHere(fnDel)) then fnDel(Data[sDel]) end
      Curs, Data[sDel] = (Curs - 1), nil
    end
  end
  function self:GetHistory()
    return tostring(sMet)..GetOpVar("OPSYM_REVISION")..
           tostring(sSel)..GetOpVar("OPSYM_DIRECTORY")..
           tostring(sIns)..GetOpVar("OPSYM_DIRECTORY")..tostring(sDel)
  end
  setmetatable(self,GetOpVar("TYPEMT_CONTAINER"))
  return self
end

--[[
 * Creates a screen object better user API for drawing on the gmod screens
 * The drawing methods are the following:
 * SURF - Uses the surface library to draw directly
 * SEGM - Uses the surface library to draw line segment interpolations
 * CAM3 - Uses the render  library to draw shapes in 3D space
 * Operation keys for storing initial arguments are the following:
 * TXT - Drawing text
 * LIN - Drawing lines
 * REC - Drawing a rectangle
 * CIR - Drawing a circle
 * UCS - Drawing a coordinate system
]]--
function MakeScreen(sW,sH,eW,eH,conColors)
  if(SERVER) then return nil end; local tLogs = {"MakeScreen"}
  local sW, sH = (tonumber(sW) or 0), (tonumber(sH) or 0)
  local eW, eH = (tonumber(eW) or 0), (tonumber(eH) or 0)
  if(sW < 0 or sH < 0) then LogInstance("Start dimension invalid", tLogs); return nil end
  if(eW < 0 or eH < 0) then LogInstance("End dimension invalid", tLogs); return nil end
  local xyS, xyE, self = NewXY(sW, sH), NewXY(eW, eH), {}
  local Colors = {List = conColors, Key = GetOpVar("OOP_DEFAULTKEY"), Default = GetColor(255,255,255,255)}
  if(Colors.List) then -- Container check
    if(getmetatable(Colors.List) ~= GetOpVar("TYPEMT_CONTAINER"))
      then LogInstance("Color list not container", tLogs); return nil end
  else -- Color list is not present then create one
    Colors.List = MakeContainer("Colors")
  end
  local DrawMeth, DrawArgs, Text, TxID = {}, {}, {}, {}
  Text.DrwX, Text.DrwY = 0, 0
  Text.ScrW, Text.ScrH = 0, 0
  Text.LstW, Text.LstH = 0, 0
  function self:GetCorners() return xyS, xyE end
  function self:GetSize() return (eW-sW), (eH-sH) end
  function self:GetCenter(nX,nY)
    local nW, nH = self:GetSize()
    local nX = (nW / 2) + (tonumber(nX) or 0)
    local nY = (nH / 2) + (tonumber(nY) or 0)
    return nX, nY
  end
  function self:GetMaterial(fC, sP) local tS = TxID[fC]
    if(not tS) then TxID[fC] = {} end; tS = TxID[fC]
    if(not tS[sP]) then bS, vV = pcall(fC, sP)
      if(not bS) then LogInstance("Call fail <"..vV..">", tLogs); return nil end
      tS[sP] = vV -- Store the value in the cache
    end; return tS[sP] -- Return cached material or texture
  end
  function self:GetColor(keyCl,sMeth)
    if(not IsHere(keyCl) and not IsHere(sMeth)) then
      Colors.Key = GetOpVar("OOP_DEFAULTKEY")
      LogInstance("Color reset", tLogs); return self end
    local keyCl = (keyCl or Colors.Key); if(not IsHere(keyCl)) then
      LogInstance("Indexing skipped", tLogs); return self end
    if(not IsString(sMeth)) then
      LogInstance("Method <"..tostring(method).."> invalid", tLogs); return self end
    local rgbCl = Colors.List:Select(keyCl)
    if(not IsHere(rgbCl)) then rgbCl = Colors.Default end
    if(tostring(Colors.Key) ~= tostring(keyCl)) then -- Update the color only on change
      surfaceSetDrawColor(rgbCl.r, rgbCl.g, rgbCl.b, rgbCl.a)
      surfaceSetTextColor(rgbCl.r, rgbCl.g, rgbCl.b, rgbCl.a)
      Colors.Key = keyCl; -- The drawing color for these two methods uses surface library
    end; return rgbCl, keyCl
  end
  function self:GetDrawParam(sMeth,tArgs,sKey)
    tArgs = (tArgs or DrawArgs[sKey])
    sMeth = tostring(sMeth or DrawMeth[sKey])
    if(sMeth == "SURF") then
      if(sKey == "TXT" and tArgs ~= DrawArgs[sKey]) then
        surfaceSetFont(tostring(tArgs[1] or "Default")) end -- Time to set the font again
    end; DrawMeth[sKey], DrawArgs[sKey] = sMeth, tArgs; return sMeth, tArgs
  end
  function self:SetTextEdge(nX,nY)
    Text.ScrW, Text.ScrH = 0, 0
    Text.LstW, Text.LstH = 0, 0
    Text.DrwX = (tonumber(nX) or 0)
    Text.DrwY = (tonumber(nY) or 0); return self
  end
  function self:GetTextState(nX,nY,nW,nH)
    return (Text.DrwX + (nX or 0)), (Text.DrwY + (nY or 0)),
           (Text.ScrW + (nW or 0)), (Text.ScrH + (nH or 0)),
            Text.LstW, Text.LstH
  end
  function self:DrawText(sText,keyCl,sMeth,tArgs)
    local sMeth, tArgs = self:GetDrawParam(sMeth,tArgs,"TXT")
    self:GetColor(keyCl, sMeth)
    if(sMeth == "SURF") then
      surfaceSetTextPos(Text.DrwX,Text.DrwY); surfaceDrawText(sText)
      Text.LstW, Text.LstH = surfaceGetTextSize(sText)
      Text.DrwY = Text.DrwY + Text.LstH
      if(Text.LstW > Text.ScrW) then Text.ScrW = Text.LstW end
      Text.ScrH = Text.DrwY
    else
      LogInstance("Draw method <"..sMeth.."> invalid", tLogs)
    end; return self
  end
  function self:DrawTextAdd(sText,keyCl,sMeth,tArgs)
    local sMeth, tArgs = self:GetDrawParam(sMeth,tArgs,"TXT")
    self:GetColor(keyCl, sMeth)
    if(sMeth == "SURF") then
      surfaceSetTextPos(Text.DrwX + Text.LstW,Text.DrwY - Text.LstH)
      surfaceDrawText(sText)
      local LstW, LstH = surfaceGetTextSize(sText)
      Text.LstW, Text.LstH = (Text.LstW + LstW), LstH
      if(Text.LstW > Text.ScrW) then Text.ScrW = Text.LstW end
      Text.ScrH = Text.DrwY
    else
      LogInstance("Draw method <"..sMeth.."> invalid", tLogs)
    end; return self
  end
  function self:DrawTextCenter(xyP,sText,keyCl,sMeth,tArgs)
    local sMeth, tArgs = self:GetDrawParam(sMeth,tArgs,"TXT")
    self:GetColor(keyCl, sMeth)
    if(sMeth == "SURF") then
      local LstW, LstH = surfaceGetTextSize(sText)
      LstW, LstH = (LstW / 2), (LstH / 2)
      surfaceSetTextPos(xyP.x - LstW, xyP.y - LstH)
      surfaceDrawText(sText)
    end; return self
  end
  function self:Enclose(xyP)
    if(xyP.x < sW) then return -1 end
    if(xyP.x > eW) then return -1 end
    if(xyP.y < sH) then return -1 end
    if(xyP.y > eH) then return -1 end; return 1
  end
  function self:GetDistance(pS, pE)
    if(self:Enclose(pS) == -1) then
      LogInstance("Start out of border", tLogs); return nil end
    if(self:Enclose(pE) == -1) then
      LogInstance("End out of border", tLogs); return nil end
    return mathSqrt((pE.x - pS.x)^2 + (pE.y - pS.y)^2)
  end
  function self:DrawLine(pS,pE,keyCl,sMeth,tArgs)
    if(not (pS and pE)) then return self end
    local sMeth, tArgs = self:GetDrawParam(sMeth,tArgs,"LIN")
    local rgbCl, keyCl = self:GetColor(keyCl, sMeth)
    if(sMeth == "SURF") then
      if(self:Enclose(pS) == -1) then
        LogInstance("Start out of border", tLogs); return self end
      if(self:Enclose(pE) == -1) then
        LogInstance("End out of border", tLogs); return self end
      surfaceDrawLine(pS.x,pS.y,pE.x,pE.y)
    elseif(sMeth == "SEGM") then
      if(self:Enclose(pS) == -1) then
        LogInstance("Start out of border", tLogs); return self end
      if(self:Enclose(pE) == -1) then
        LogInstance("End out of border", tLogs); return self end
      local nItr = mathClamp((tonumber(tArgs[1]) or 1),1,200)
      if(nIter <= 0) then return self end
      local xyD = NewXY((pE.x - pS.x) / nItr, (pE.y - pS.y) / nItr)
      local xyOld, xyNew = NewXY(pS.x, pS.y), NewXY()
      while(nItr > 0) do AddXY(xyNew, xyOld, xyD)
        surfaceDrawLine(xyOld.x,xyOld.y,xyNew.x,xyNew.y)
        SetXY(xyOld, xyNew); nItr = nItr - 1
      end
    elseif(sMeth == "CAM3") then
      renderDrawLine(pS,pE,rgbCl,(tArgs[1] and true or false))
    else LogInstance("Draw method <"..sMeth.."> invalid", tLogs); return self end
  end
  function self:DrawRect(pO,pS,keyCl,sMeth,tArgs)
    local sMeth, tArgs = self:GetDrawParam(sMeth,tArgs,"REC")
    self:GetColor(keyCl,sMeth)
    if(sMeth == "SURF") then
      if(self:Enclose(pO) == -1) then
        LogInstance("Start out of border", tLogs); return self end
      if(self:Enclose(pS) == -1) then
        LogInstance("End out of border", tLogs); return self end
      local nR = tonumber(tArgs[2])
      surfaceSetTexture(self:GetMaterial(surfaceGetTextureID, tArgs[1]))
      if(nR) then local nD = (nR / GetOpVar("DEG_RAD"))
        surfaceDrawTexturedRectRotated(pO.x,pO.y,pS.x,pS.y,nD)
      else -- Use the regular rectangle function without sin/cos rotation
        surfaceDrawTexturedRect(pO.x,pO.y,pS.x,pS.y)
      end
    else -- Unsuppoerted method
      LogInstance("Draw method <"..sMeth.."> invalid", tLogs)
    end; return self
  end
  function self:DrawCircle(pC,nRad,keyCl,sMeth,tArgs)
    local sMeth, tArgs = self:GetDrawParam(sMeth,tArgs,"CIR")
    local rgbCl, keyCl = self:GetColor(keyCl,sMeth)
    if(sMeth == "SURF") then surfaceDrawCircle(pC.x, pC.y, nRad, rgbCl)
    elseif(sMeth == "SEGM") then
      local nItr = mathClamp((tonumber(tArgs[1]) or 1),1,200)
      local nMax = (GetOpVar("MAX_ROTATION") * GetOpVar("DEG_RAD"))
      local xyOld, xyNew, xyRad = NewXY(), NewXY(), NewXY(nRad, 0)
      local nStp, nAng = (nMax / nItr), 0; AddXY(xyOld, xyRad, pC)
      while(nItr > 0) do nAng = nAng + nStp
        SetXY(xyNew, xyRad); RotateXY(xyNew, nAng); AddXY(xyNew, xyNew, pC)
        surfaceDrawLine(xyOld.x,xyOld.y,xyNew.x,xyNew.y)
        SetXY(xyOld, xyNew); nItr = (nItr - 1)
      end
    elseif(sMeth == "CAM3") then -- It is a projection of a sphere
      renderSetMaterial(self:GetMaterial(Material, (tArgs[1] or "color")))
      renderDrawSphere (pC,nRad,mathClamp(tArgs[2] or 1,1,200),
                                mathClamp(tArgs[3] or 1,1,200),rgbCl)
    else LogInstance("Draw method <"..sMeth.."> invalid", tLogs); return nil end
  end
  function self:DrawUCS(vO,aO,sMeth,tArgs)
    local sMeth, tArgs = self:GetDrawParam(sMeth,tArgs,"UCS")
    local nSiz = BorderValue(tonumber(tArgs[1]) or 0, "non-neg")
    local nRad = BorderValue(tonumber(tArgs[2]) or 0, "non-neg")
    if(nSiz > 0) then
      if(sMeth == "SURF") then
        local xyP = vO:ToScreen()
        local xyZ = (vO + nSiz * aO:Up()):ToScreen()
        local xyY = (vO + nSiz * aO:Right()):ToScreen()
        local xyX = (vO + nSiz * aO:Forward()):ToScreen()
        self:DrawCircle(xyP,nRad,"y",sMeth)
        self:DrawLine(xyP,xyX,"r",sMeth)
        self:DrawLine(xyP,xyY,"g")
        self:DrawLine(xyP,xyZ,"b"); return xyP, xyX, xyY, xyZ
      else LogInstance("Draw method <"..sMeth.."> invalid", tLogs); return nil end
    end
  end; setmetatable(self, GetOpVar("TYPEMT_SCREEN")); return self
end

function SetAction(sKey,fAct,tDat)
  if(not (sKey and IsString(sKey))) then
    LogInstance("Key "..GetReport(sKey).." not string"); return nil end
  if(not (fAct and type(fAct) == "function")) then
    LogInstance("Act "..GetReport(fAct).." not function"); return nil end
  if(not libAction[sKey]) then libAction[sKey] = {} end
  libAction[sKey].Act, libAction[sKey].Dat = fAct, {}
  if(IsTable(tDat)) then for key, val in pairs(tDat) do
    libAction[sKey].Dat[key] = tDat[key] end
  else libAction[sKey].Dat[1] = tDat end
  libAction[sKey].Dat.Slot = sKey; return true
end

function GetActionCode(sKey)
  if(not (sKey and IsString(sKey))) then
    LogInstance("Key "..GetReport(sKey).." not string"); return nil end
  if(not (libAction and libAction[sKey])) then
    LogInstance("Missing key <"..sKey..">"); return nil end
  return libAction[sKey].Act
end

function GetActionData(sKey)
  if(not (sKey and IsString(sKey))) then
    LogInstance("Key "..GetReport(sKey).." not string"); return nil end
  if(not (libAction and libAction[sKey])) then
    LogInstance("Missing key <"..sKey..">"); return nil end
  return libAction[sKey].Dat
end

function CallAction(sKey,...)
  if(not (sKey and IsString(sKey))) then
    LogInstance("Key "..GetReport(sKey).." not string"); return nil end
  if(not (libAction and libAction[sKey])) then
    LogInstance("Missing key <"..sKey..">"); return nil end
  local fAct, tDat = libAction[sKey].Act, libAction[sKey].Dat
  return pcall(fAct, tDat, ...)
end

local function AddLineListView(pnListView,frUsed,ivNdex)
  if(not IsHere(pnListView)) then
    LogInstance("Missing panel"); return false end
  if(not IsValid(pnListView)) then
    LogInstance("Invalid panel"); return false end
  if(not IsHere(frUsed)) then
    LogInstance("Missing data"); return false end
  local iNdex = tonumber(ivNdex); if(not IsHere(iNdex)) then
    LogInstance("Index NAN "..GetReport(ivNdex)); return false end
  local tValue = frUsed[iNdex]; if(not IsHere(tValue)) then
    LogInstance("Missing data on index #"..tostring(iNdex)); return false end
  local makTab = libQTable["PIECES"]; if(not IsHere(makTab)) then
    LogInstance("Missing table builder"); return nil end
  local defTab = makTab:GetDefinition(); if(not IsHere(defTab)) then
    LogInstance("Missing table definition"); return false end
  local sModel = tValue.Table[defTable[1][1]]
  local sType  = tValue.Table[defTable[2][1]]
  local sName  = tValue.Table[defTable[3][1]]
  local nRake  = tValue.Table[defTable[4][1]]
  local nUsed  = RoundValue(tValue.Value,0.001)
  local pnLine = pnListView:AddLine(nUsed,nRake,sType,sName,sModel)
        pnLine:SetTooltip(sModel)
  return true
end

--[[
 * Updates a VGUI pnListView with a search preformed in the already generated
 * frequently used pieces "frUsed" for the pattern "sPat" given by the user
 * and a column name selected `sCol`.
 * On success populates "pnListView" with the search preformed
 * On fail a parameter is not valid or missing and returns non-success
]]--
function UpdateListView(pnListView,frUsed,nCount,sCol,sPat)
  if(not (IsHere(frUsed) and IsHere(frUsed[1]))) then
    LogInstance("Missing data"); return false end
  local nCount = tonumber(nCount) or 0
  if(nCount <= 0) then
    LogInstance("Count not applicable"); return false end
  if(IsHere(pnListView)) then
    if(not IsValid(pnListView)) then
      LogInstance("Invalid ListView"); return false end
    pnListView:SetVisible(false)
    pnListView:Clear()
  else LogInstance("Missing ListView"); return false end
  local sCol, sPat = tostring(sCol or ""), tostring(sPat or "")
  local iCnt, sDat = 1, nil
  while(frUsed[iCnt]) do
    if(IsBlank(sPat)) then
      if(not AddLineListView(pnListView,frUsed,iCnt)) then
        LogInstance("Failed to add line on #"..tostring(iCnt)); return false end
    else
      sDat = tostring(frUsed[iCnt].Table[sCol] or "")
      if(sDat:find(sPat)) then
        if(not AddLineListView(pnListView,frUsed,iCnt)) then
          LogInstance("Failed to add line <"..sDat.."> pattern <"..sPat.."> on <"..sCol.."> #"..tostring(iCnt)); return false end
      end
    end; iCnt = iCnt + 1
  end; pnListView:SetVisible(true)
  LogInstance("Crated #"..tostring(iCnt-1)); return true
end

function GetDirectoryObj(pCurr, vName)
  if(not pCurr) then
    LogInstance("Location invalid"); return nil end
  local sName = tostring(vName or "")
        sName = IsBlank(sName) and "Other" or sName
  if(not pCurr[sName]) then
    LogInstance("Name missing <"..sName..">"); return nil end
  return pCurr[sName], pCurr[sName].__ObjPanel__
end

function SetDirectoryObj(pnBase, pCurr, vName, sImage, txCol)
  if(not IsValid(pnBase)) then
    LogInstance("Base panel invalid"); return nil end
  if(not pCurr) then
    LogInstance("Location invalid"); return nil end
  local sName = tostring(vName or "")
        sName = IsBlank(sName) and "Other" or sName
  local pItem = pnBase:AddNode(sName)
  pCurr[sName] = {}; pCurr[sName].__ObjPanel__ = pItem
  pItem.Icon:SetImage(tostring(sImage or "icon16/folder.png"))
  pItem.InternalDoClick = function() end
  pItem.DoClick         = function() return false end
  pItem.DoRightClick    = function() SetClipboardText(pItem:GetText()) end
  pItem.Label.UpdateColours = function(pSelf)
    return pSelf:SetTextStyleColor(txCol or GetColor(0,0,0,255)) end
  return pCurr[sName], pItem
end

local function PushSortValues(tTable,snCnt,nsValue,tData)
  local iCnt, iInd = mathFloor(tonumber(snCnt) or 0), 1
  if(not (tTable and (type(tTable) == "table") and (iCnt > 0))) then return 0 end
  if(not tTable[iInd]) then
    tTable[iInd] = {Value = nsValue, Table = tData }; return iInd
  else
    while(tTable[iInd] and (tTable[iInd].Value < nsValue)) do iInd = iInd + 1 end
    if(iInd > iCnt) then return iInd end
    while(iInd < iCnt) do
      tTable[iCnt] = tTable[iCnt - 1]
      iCnt = iCnt - 1
    end; tTable[iInd] = { Value = nsValue, Table = tData }; return iInd
  end
end

function GetFrequentModels(snCount)
  local snCount = (tonumber(snCount) or 0); if(snCount < 1) then
    LogInstance("Count not applicable"); return nil end
  local makTab = libQTable["PIECES"]; if(not IsHere(makTab)) then
    LogInstance("Missing table builder"); return nil end
  local defTab = makTab:GetDefinition(); if(not IsHere(defTab)) then
    LogInstance("Missing table definition"); return nil end
  local tCache = libCache[defTab.Name]; if(not IsHere(tCache)) then
    LogInstance("Missing table cache space"); return nil end
  local iInd, tmNow, frUsed = 1, Time(), GetOpVar("TABLE_FREQUENT_MODELS"); tableEmpty(frUsed)
  for mod, rec in pairs(tCache) do
    if(IsHere(rec.Used) and IsHere(rec.Size) and rec.Size > 0) then
      iInd = PushSortValues(frUsed,snCount,tmNow-rec.Used,{
               [defTab[1][1]] = mod,
               [defTab[2][1]] = rec.Type,
               [defTab[3][1]] = rec.Name,
               [defTab[4][1]] = rec.Rake
             })
      if(iInd < 1) then LogInstance("Array index out of border"); return nil end
    end
  end
  if(IsHere(frUsed) and IsHere(frUsed[1])) then return frUsed, snCount end
  LogInstance("Array is empty or not available"); return nil
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

function ModelToName(sModel, bNoSet)
  if(not IsString(sModel)) then
    LogInstance("Argument "..GetReport(sModel)); return "" end
  if(IsBlank(sModel)) then LogInstance("Empty string"); return "" end
  local sSymDiv, sSymDir = GetOpVar("OPSYM_DIVIDER"), GetOpVar("OPSYM_DIRECTORY")
  local sModel = (sModel:sub(1, 1) ~= sSymDir) and (sSymDir..sModel) or sModel
        sModel = (sModel:GetFileFromFilename():gsub(GetOpVar("MODELNAM_FILE"),""))
  local gModel = (sModel:sub(1,-1)) -- Create a copy so we can select cut-off parts later
  if(not bNoSet) then local iCnt, iNxt
    local tCut, tSub, tApp = ModelToNameRule("GET")
    if(tCut and tCut[1]) then iCnt, iNxt = 1, 2
      while(tCut[iCnt] and tCut[iNxt]) do
        local fNu, bNu = tonumber(tCut[iCnt]), tonumber(tCut[iNxt])
        local fCh, bCh = tostring(tCut[iCnt]), tostring(tCut[iNxt])
        if(not (IsHere(fNu) and IsHere(bNu))) then
          LogInstance("Cut mismatch{"..fCh..","..bCh.."}@"..sModel); return "" end
        gModel = gModel:gsub(sModel:sub(fNu, bNu),""); iCnt, iNxt = (iCnt + 2), (iNxt + 2)
        LogInstance("Cut{"..fCh..","..bCh.."}@"..gModel)
      end
    end -- Replace the unneeded parts by finding an in-string gModel
    if(tSub and tSub[1]) then iCnt, iNxt = 1, 2
      while(tSub[iCnt]) do
        local fCh, bCh = tostring(tSub[iCnt] or ""), tostring(tSub[iNxt] or "")
        gModel = gModel:gsub(fCh,bCh); LogInstance("Sub{"..fCh..","..bCh.."}@"..gModel)
        iCnt, iNxt = (iCnt + 2), (iNxt + 2)
      end
    end -- Append something if needed
    if(tApp and tApp[1]) then
      local fCh, bCh = tostring(tApp[1] or ""), tostring(tApp[2] or "")
      gModel = (fCh..gModel..bCh); LogInstance("App{"..fCh..","..bCh.."}@"..gModel)
    end
  end -- Trigger the capital spacing using the divider ( _aaaaa_bbbb_ccccc )
  if(gModel:sub(1,1) ~= sSymDiv) then gModel = sSymDiv..gModel end
  return gModel:gsub(sSymDiv.."%w",GetOpVar("MODELNAM_FUNC")):sub(2,-1)
end

--[[
 * Creates a basis instance for entity-related operations
 * The instance is invisible and cannot be hit by traces
 * By default spawns at origin  and angle {0,0,0}
 * sModel --> The model to use for creating the entity
]]
local function MakeEntityNone(sModel) local eNone
  if(SERVER) then eNone = entsCreate(GetOpVar("ENTITY_DEFCLASS"))
  elseif(CLIENT) then eNone = entsCreateClientProp(sModel) end
  if(not (eNone and eNone:IsValid())) then
    LogInstance("Entity invalid @"..sModel); return nil end
  eNone:SetCollisionGroup(COLLISION_GROUP_NONE)
  eNone:SetSolid(SOLID_NONE); eNone:SetMoveType(MOVETYPE_NONE)
  eNone:SetNotSolid(true); eNone:SetNoDraw(true); eNone:SetModel(sModel)
  LogInstance("{"..tostring(eNone).."}@"..sModel); return eNone
end

--[[
 * Locates an active point on the piece offset record.
 * This function is used to check the correct offset and return it.
 * It also returns the normalized active point ID if needed
 * oRec   --> Record structure of a track piece
 * ivPoID --> The POA offset ID to check and locate
]]--
function LocatePOA(oRec, ivPoID)
  if(not oRec) then LogInstance("Missing record"); return nil end
  if(not oRec.Offs) then LogInstance("Missing offsets for <"..tostring(oRec.Slot)..">"); return nil end
  local iPoID = mathFloor(tonumber(ivPoID) or 0)
  local stPOA = oRec.Offs[iPoID]; if(not IsHere(stPOA)) then
    LogInstance("Missing ID #"..tostring(ivPoID)..">"..tostring(iPoID).."| for <"..tostring(oRec.Slot)..">"); return nil end
  return stPOA, iPoID
end

function ReloadPOA(nXP,nYY,nZR)
  local arPOA = GetOpVar("ARRAY_DECODEPOA")
        arPOA[1] = (tonumber(nXP) or 0)
        arPOA[2] = (tonumber(nYY) or 0)
        arPOA[3] = (tonumber(nZR) or 0)
  return arPOA
end

function IsEqualPOA(staPOA,stbPOA)
  if(not IsHere(staPOA)) then
    LogInstance("Missing offset A"); return false end
  if(not IsHere(stbPOA)) then
    LogInstance("Missing offset B"); return false end
  for kKey, vComp in pairs(staPOA) do
    if(stbPOA[kKey] ~= vComp) then return false end
  end; return true
end

function IsZeroPOA(stPOA,sMode)
  if(not IsString(sMode)) then
    LogInstance("Mode "..GetReport(sMode).." not string"); return nil end
  if(not IsHere(stPOA)) then LogInstance("Missing offset"); return nil end
  local ctA, ctB, ctC = GetIndexes(sMode); if(not (ctA and ctB and ctC)) then
    LogInstance("Missed offset mode "..sMode); return nil end
  return (stPOA[ctA] == 0 and stPOA[ctB] == 0 and stPOA[ctC] == 0)
end

function StringPOA(stPOA,sMode)
  if(not IsString(sMode)) then
    LogInstance("Mode "..GetReport(sMode).." not string"); return nil end
  if(not IsHere(stPOA)) then
    LogInstance("Missing Offsets"); return nil end
  local ctA, ctB, ctC = GetIndexes(sMode); if(not (ctA and ctB and ctC)) then
    LogInstance("Missed offset mode "..sMode); return nil end
  local symSep, sNo = GetOpVar("OPSYM_SEPARATOR"), ""
  local svA = tostring(stPOA[ctA] or sNo)
  local svB = tostring(stPOA[ctB] or sNo)
  local svC = tostring(stPOA[ctC] or sNo)
  return (svA..symSep..svB..symSep..svC):gsub("%s","")
end

function TransferPOA(tData,sMode)
  if(not IsHere(tData)) then
    LogInstance("Destination needed"); return nil end
  if(not IsString(sMode)) then
    LogInstance("Mode "..GetReport(sMode).." not string"); return nil end
  local arPOA = GetOpVar("ARRAY_DECODEPOA")
  local ctA, ctB, ctC = GetIndexes(sMode); if(not (ctA and ctB and ctC)) then
    LogInstance("Missed offset mode <"..sMode..">"); return nil end
  tData[ctA], tData[ctB], tData[ctC] = arPOA[1], arPOA[2], arPOA[3]; return arPOA
end

function DecodePOA(sStr)
  if(not IsString(sStr)) then
    LogInstance("Argument "..GetReport(sStr).." not string"); return nil end
  if(sStr:len() == 0) then return ReloadPOA() end; ReloadPOA()
  local symSep, arPOA = GetOpVar("OPSYM_SEPARATOR"), GetOpVar("ARRAY_DECODEPOA")
  local atPOA = symSep:Explode(sStr)
  for iD = 1, arPOA.Size do local nCom = tonumber(atPOA[iD])
    if(not IsHere(nCom)) then nCom = 0
      LogInstance("Mismatch <"..sStr..">") end; arPOA[iD] = nCom
  end; return arPOA
end

function GetTransformPOA(sModel,sKey)
  if(not IsString(sModel)) then
    LogInstance("Model mismatch <"..tostring(sModel)..">"); return nil end
  if(not IsString(sKey)) then
    LogInstance("Key mismatch <"..tostring(sKey)..">@"..sModel); return nil end
  local ePiece = GetOpVar("ENTITY_TRANSFORMPOA")
  if(ePiece and ePiece:IsValid()) then -- There is basis entity then update and extract
    if(ePiece:GetModel() ~= sModel) then ePiece:SetModel(sModel)
      LogInstance("Update {"..tostring(ePiece).."}@"..sModel) end
  else -- If there is no basis need to create one for attachment extraction
    ePiece = MakeEntityNone(sModel); if(not ePiece) then
      LogInstance("Basis invalid @"..sModel); return nil end
    SetOpVar("ENTITY_TRANSFORMPOA", ePiece) -- Register the entity transform basis
  end -- Transfer the data from the transform attachment location
  local mOA = ePiece:GetAttachment(ePiece:LookupAttachment(sKey)); if(not mOA) then
    LogInstance("Attachment missing <"..sKey..">@"..sModel); return nil end
  local vtPos, atAng = mOA[sKey].Pos, mOA[sKey].Ang -- Extract transform data
  LogInstance("Extract {"..sKey.."}<"..tostring(vtPos).."><"..tostring(atAng)..">")
  return vtPos, atAng -- The function must return transform position and angle
end

function RegisterPOA(stPiece, sP, sO, sA)
  if(not stPiece) then
    LogInstance("Cache record invalid"); return nil end
  local iID = tonumber(ivID); if(not IsHere(iID)) then
    LogInstance("OffsetID NAN "..GetReport(ivID)); return nil end
  local sP = (sP or sNull); if(not IsString(sP)) then
    LogInstance("Point  "..GetReport(sP)); return nil end
  local sO = (sO or sNull); if(not IsString(sO)) then
    LogInstance("Origin "..GetReport(sO)); return nil end
  local sA = (sA or sNull); if(not IsString(sA)) then
    LogInstance("Angle  "..GetReport(sA)); return nil end
  local tOffs = stPiece.Offs; if(not tOffs) then
    stPiece.Offs = {}; tOffs = stPiece.Offs
    tOffs.P = {}; tOffs.O = {}; tOffs.A = {}
  else LogInstance("Hash <"..tostring(stPiece.Slot).."> exists"); return nil end
  local sE, sD = GetOpVar("OPSYM_ENTPOSANG"), GetOpVar("OPSYM_DISABLE")
  ---------- Origin ----------
  if(sO:sub(1,1) == sD) then ReloadPOA() else
    if(sO:sub(1,1) == sE) then tOffs.O.Slot = sO; sO = sO:sub(2,-1)
      local vtPos, atAng = GetTransformPOA(stPiece.Slot, sO)
      if(IsHere(vtPos)) then ReloadPOA(vtPos[cvX], vtPos[cvY], vtPos[cvZ]) else
        if(IsNull(sO) or IsBlank(sO)) then ReloadPOA() else
          if(not DecodePOA(sO)) then LogInstance("Origin mismatch ["..iID.."]@"..stPiece.Slot) end
      end end -- Reload the transformation when is not null or empty string
    elseif(IsNull(sO) or IsBlank(sO)) then ReloadPOA() else
      if(not DecodePOA(sO)) then LogInstance("Origin mismatch ["..iID.."]@"..stPiece.Slot) end
    end
  end; if(not IsHere(TransferPOA(tOffs.O, "V"))) then LogInstance("Origin mismatch"); return nil end
  ---------- Angle ----------
  if(sA:sub(1,1) == sD) then ReloadPOA() else
    if(sA:sub(1,1) == sE) then tOffs.A.Slot = sA; sA = sA:sub(2,-1)
      local vtPos, atAng = GetTransformPOA(stPiece.Slot, sA)
      if(IsHere(atAng)) then ReloadPOA(atAng[caP], atAng[caY], atAng[caR]) else
        if(IsNull(sA) or IsBlank(sA)) then ReloadPOA() else
          if(not DecodePOA(sA)) then LogInstance("Angle mismatch ["..iID.."]@"..stPiece.Slot) end
      end end -- Reload the transformation when is not null or empty string
    elseif(IsNull(sA) or IsBlank(sA)) then ReloadPOA() else
      if(not DecodePOA(sA)) then LogInstance("Angle mismatch ["..iID.."]@"..stPiece.Slot) end
    end
  end; if(not IsHere(TransferPOA(tOffs.A, "A"))) then LogInstance("Angle mismatch"); return nil end
  ---------- Point ----------
  if(sP:sub(1,1) == sD) then ReloadPOA() else
    if(IsNull(sP) or IsBlank(sP)) then ReloadPOA() else
      if(not DecodePOA(sP)) then LogInstance("Point mismatch ["..iID.."]@"..stPiece.Slot) end  
    end -- When the point is empty use a zero vector for the mass center
  end; if(not IsHere(TransferPOA(tOffs.P, "V"))) then LogInstance("Point mismatch"); return nil end
  return tOffs
end

local function QuickSort(tD, iL, iH)
  if(not (iL and iH and (iL > 0) and (iL < iH))) then
    LogInstance("Data dimensions mismatch"); return nil end
  local iM = mathRandom(iH-iL-1)+iL-1
  tD[iL], tD[iM] = tD[iM], tD[iL]; iM = iL
  local vM, iC = tD[iL].Val, (iL + 1)
  while(iC <= iH)do
    if(tD[iC].Val < vM) then iM = iM + 1
      tD[iM], tD[iC] = tD[iC], tD[iM]
    end; iC = iC + 1
  end; tD[iL], tD[iM] = tD[iM], tD[iL]
  QuickSort(tD,iL,iM-1)
  QuickSort(tD,iM+1,iH)
end

function Sort(tTable, tCols)
  local tS, iS = {Size = 0}, 0
  local tC = tCols or {}; tC.Size = #tC
  for key, rec in pairs(tTable) do
    iS = (iS + 1); tS[iS] = {}; tS[iS].Key = key
    if(type(rec) == "table") then tS[iS].Val = ""
      if(tC.Size > 0) then
        for iI = 1, tC.Size do local sC = tC[iI]; if(not IsHere(rec[sC])) then
          LogInstance("Col <"..sC.."> not found on the current record"); return nil end
            tS[iS].Val = tS[iS].Val..tostring(rec[sC])
        end -- When no sort columns are provided use keys instead
      else tS[iS].Val = key end -- Use the table key
    else tS[iS].Val = rec end -- Use the actual value
  end; tS.Size = iS; QuickSort(tS,1,iS); return tS
end

------------- VARIABLE INTERFACES --------------

function GetTerm(sBas, vDef, vDsb)
  local sM, sS = GetOpVar("MISS_NOAV"), GetOpVar("MISS_NOSQL")
  if(IsString(sBas)) then local sD = GetOpVar("OPSYM_DISABLE")
    if(sBas:sub(1,1) == sD) then return tostring(vDsb or sM)
    elseif(not (IsNull(sBas) or IsBlank(sBas))) then return sBas end
  end; if(IsString(vDef)) then return vDef end; return sM
end

function ModelToNameRule(sRule, gCut, gSub, gApp)
  if(not IsString(sRule)) then
    LogInstance("Rule "..GetReport(sRule).." not string"); return false end
  if(sRule == "SET") then
    if(gCut and gCut[1]) then SetOpVar("TABLE_GCUT_MODEL",gCut) else SetOpVar("TABLE_GCUT_MODEL",{}) end
    if(gSub and gSub[1]) then SetOpVar("TABLE_GSUB_MODEL",gSub) else SetOpVar("TABLE_GSUB_MODEL",{}) end
    if(gApp and gApp[1]) then SetOpVar("TABLE_GAPP_MODEL",gApp) else SetOpVar("TABLE_GAPP_MODEL",{}) end
  elseif(sRule == "GET") then
    return GetOpVar("TABLE_GCUT_MODEL"), GetOpVar("TABLE_GSUB_MODEL"), GetOpVar("TABLE_GAPP_MODEL")
  elseif(sRule == "CLR") then
    SetOpVar("TABLE_GCUT_MODEL",{}); SetOpVar("TABLE_GSUB_MODEL",{}); SetOpVar("TABLE_GAPP_MODEL",{})
  elseif(sRule == "REM") then
    SetOpVar("TABLE_GCUT_MODEL",nil); SetOpVar("TABLE_GSUB_MODEL",nil); SetOpVar("TABLE_GAPP_MODEL",nil)
  else LogInstance("Wrong mode name "..sRule); return false end
end

function GetCategory(oTyp,fCat)
  local tCat = GetOpVar("TABLE_CATEGORIES")
  if(not IsHere(oTyp)) then
    local sTyp = tostring(GetOpVar("DEFAULT_TYPE") or "")
    local tTyp = (tCat and tCat[sTyp] or nil)
    return sTyp, (tTyp and tTyp.Txt), (tTyp and tTyp.Cmp)
  end; ModelToNameRule("CLR"); SetOpVar("DEFAULT_TYPE", tostring(oTyp))
  if(CLIENT) then local tTyp -- Categories for the panel
    local sTyp = tostring(GetOpVar("DEFAULT_TYPE") or "")
      local fsLog = GetOpVar("FORM_LOGSOURCE") -- The actual format value
      local ssLog = "*"..fsLog:format("TYPE","GetCategory",tostring(oTyp))
    if(IsString(fCat)) then tCat[sTyp] = {}
      tCat[sTyp].Txt = fCat; tTyp = (tCat and tCat[sTyp] or nil)
      tCat[sTyp].Cmp = CompileString("return ("..fCat..")", sTyp)
      local suc, out = pcall(tCat[sTyp].Cmp); if(not suc) then
        LogInstance("Compilation failed <"..fCat.."> ["..sTyp.."]", ssLog); return nil end
      tCat[sTyp].Cmp = out; tTyp = tCat[sTyp]
      return sTyp, (tTyp and tTyp.Txt), (tTyp and tTyp.Cmp)
    else LogInstance("Avoided "..GetReport(fCat).." ["..sTyp.."]", ssLog) end
  end
end

------------------------- PLAYER -----------------------------------

local function GetPlayerSpot(pPly)
  if(not IsPlayer(pPly)) then
    LogInstance("Player <"..tostring(pPly)"> invalid"); return nil end
  local stSpot = libPlayer[pPly]; if(not IsHere(stSpot)) then
    LogInstance("Cached <"..pPly:Nick()..">")
    libPlayer[pPly] = {}; stSpot = libPlayer[pPly]
  end; return stSpot
end

function GetCacheSpawn(pPly)
  local stSpot = GetPlayerSpot(pPly); if(not IsHere(stSpot)) then
    LogInstance("Spot missing"); return nil end
  local stData = stSpot["SPAWN"]
  if(not IsHere(stData)) then
    LogInstance("Allocate <"..pPly:Nick()..">")
    stSpot["SPAWN"] = {}; stData = stSpot["SPAWN"]
    stData.F    = Vector() -- Origin forward vector
    stData.R    = Vector() -- Origin right vector
    stData.U    = Vector() -- Origin up vector
    stData.OPos = Vector() -- Origin position
    stData.OAng = Angle () -- Origin angle
    stData.SPos = Vector() -- Piece spawn position
    stData.SAng = Angle () -- Piece spawn angle
    stData.DPos = Vector() -- Domain position. Used for decomposition
    stData.DAng = Angle () -- Domain angle. Used for constraints
    --- Holder ---
    stData.HRec = 0        -- Pointer to the holder record
    stData.HPnt = Vector() -- P > Local radius vector edge offset
    stData.HOrg = Vector() -- O > Local piece mass-center center
    stData.HAng = Angle () -- A > Local piece orientation origin when meshed
    --- Traced ---
    stData.TRec = 0        -- Pointer to the trace record
    stData.TPnt = Vector() -- P > Local radius vector edge offset
    stData.TOrg = Vector() -- O > Local piece mass-center center
    stData.TAng = Angle () -- A > Local piece orientation origin when meshed
    --- Offsets ---
    stData.ANxt = Angle () -- Origin angle offsets
    stData.PNxt = Vector() -- Piece position offsets
  end; return stData
end

function CacheClear(pPly)
  if(not IsPlayer(pPly)) then
    LogInstance("Player <"..tostring(pPly)"> invalid"); return false end
  local stSpot = libPlayer[pPly]; if(not IsHere(stSpot)) then
    LogInstance("Clean"); return true end
  libPlayer[pPly] = nil; collectgarbage(); return true
end

function GetDistanceHit(pPly, vHit)
  if(not IsPlayer(pPly)) then
    LogInstance("Player <"..tostring(pPly)"> invalid"); return nil end
  return (vHit - pPly:GetPos()):Length()
end

function GetCacheRadius(pPly, vHit, nSca)
  local stSpot = GetPlayerSpot(pPly); if(not IsHere(stSpot)) then
    LogInstance("Spot missing"); return nil end
  local stData = stSpot["RADIUS"]
  if(not IsHere(stData)) then
    LogInstance("Allocate <"..pPly:Nick()..">")
    stSpot["RADIUS"] = {}; stData = stSpot["RADIUS"]
    stData["MAR"] =  (GetOpVar("GOLDEN_RATIO") * 1000)
    stData["LIM"] = ((GetOpVar("GOLDEN_RATIO") - 1) * 100)
  end
  local nMul = (tonumber(nSca) or 1) -- Disable scaling on missing or outside
        nMul = ((nMul <= 1 and nMul >= 0) and nMul or 1)
  local nMar, nLim = stData["MAR"], stData["LIM"]
  local nDst = GetDistanceHit(pPly, vHit)
  local nRad = ((nDst ~= 0) and mathClamp((nMar / nDst) * nMul, 1, nLim) or 0)
  return nRad, nDst, nMar, nLim
end

function GetCacheTrace(pPly)
  local stSpot = GetPlayerSpot(pPly); if(not IsHere(stSpot)) then
    LogInstance("Spot missing"); return nil end
  local stData, plyTime = stSpot["TRACE"], Time()
  if(not IsHere(stData)) then -- Define trace delta margin
    LogInstance("Allocate <"..pPly:Nick()..">")
    stSpot["TRACE"] = {}; stData = stSpot["TRACE"]
    stData["NXT"] = plyTime + GetOpVar("TRACE_MARGIN") -- Define next trace pending
    stData["DAT"] = utilGetPlayerTrace(pPly)           -- Get output trace data
    stData["REZ"] = utilTraceLine(stData["DAT"]) -- Make a trace
  end -- Check the trace time margin interval
  if(plyTime >= stData["NXT"]) then
    stData["NXT"] = plyTime + GetOpVar("TRACE_MARGIN") -- Next trace margin
    stData["DAT"] = utilGetPlayerTrace(pPly)           -- Get output trace data
    stData["REZ"] = utilTraceLine(stData["DAT"]) -- Make a trace
  end; return stData["REZ"]
end

function Notify(pPly,sText,sNotifType)
  if(not IsPlayer(pPly)) then
    LogInstance("Player <"..tostring(pPly)"> invalid"); return false end
  if(SERVER) then -- Send notification to client that something happened
    pPly:SendLua(GetOpVar("FORM_NTFGAME"):format(sText, sNotifType))
    pPly:SendLua(GetOpVar("FORM_NTFPLAY"):format(mathRandom(1, 4)))
  end; return true
end

function UndoCrate(vMsg)
  SetOpVar("LABEL_UNDO",tostring(vMsg))
  undoCreate(GetOpVar("LABEL_UNDO")); return true
end

function UndoAddEntity(oEnt)
  if(not (oEnt and oEnt:IsValid())) then
    LogInstance("Entity invalid"); return false end
  undoAddEntity(oEnt); return true
end

function UndoFinish(pPly,vMsg)
  if(not IsPlayer(pPly)) then
    LogInstance("Player <"..tostring(pPly)"> invalid"); return false end
  pPly:EmitSound(GetOpVar("FORM_SNAPSND"):format(mathRandom(1, 3)))
  undoSetCustomUndoText(GetOpVar("LABEL_UNDO")..tostring(vMsg or ""))
  undoSetPlayer(pPly); undoFinish(); return true
end

-------------------------- BUILDSQL ------------------------------

local function CacheStmt(sHash,sStmt,...)
  if(not IsHere(sHash)) then LogInstance("Missing hash"); return nil end
  local sHash, tStore = tostring(sHash), GetOpVar("QUERY_STORE")
  if(not IsHere(tStore)) then LogInstance("Missing storage"); return nil end
  if(IsHere(sStmt)) then -- If the key is located return the query
    tStore[sHash] = tostring(sStmt); LogTable(tStore,"STMT") end
  local sBase = tStore[sHash]; if(not IsHere(sBase)) then
    LogInstance("STMT["..sHash.."] Mismatch"); return nil end
  return sBase:format(...)
end

function GetBuilderNick(sTable)
  if(not IsString(sTable)) then
    LogInstance("Key "..GetReport(sTable).." not string"); return nil end
  local makTab = libQTable[sTable]; if(not IsHere(makTab)) then
    LogInstance("Missing table builder for <"..sTable..">"); return nil end
  if(not makTab:IsValid()) then
    LogInstance("Builder object invalid <"..sTable..">"); return nil end
  return makTab -- Return the dedicated table builder object
end

function CreateTable(sTable,defTab,bDelete,bReload)
  if(not IsString(sTable)) then
    LogInstance("Table key "..GetReport(sTable).." not string"); return false end
  if(IsBlank(sTable)) then
    LogInstance("Table name must not be empty"); return false end
  if(not (type(defTab) == "table")) then
    LogInstance("Table definition missing for "..sTable); return false end
  defTab.Size = #defTab; if(defTab.Size <= 0) then
    LogInstance("Record definition missing for "..sTable); return false end
  for iCnt = 1, defTab.Size do
    local sN = tostring(defTab[iCnt][1] or ""); if(IsBlank(sN)) then
      LogInstance("Missing table "..sTable.." col ["..tostring(iCnt).."] name"); return false end
    local sT = tostring(defTab[iCnt][2] or ""); if(IsBlank(sT)) then
      LogInstance("Missing table "..sTable.." col ["..tostring(iCnt).."] type"); return false end
    defTab[iCnt][1], defTab[iCnt][2] = sN, sT
  end
  if(defTab.Size ~= tableMaxn(defTab)) then
    LogInstance("Record definition mismatch for "..sTable); return false end
  defTab.Nick = sTable:upper(); defTab.Name = GetOpVar("TOOLNAME_PU")..defTab.Nick
  local self, tabDef, tabCmd = {}, defTab, {}
  local symDis, sMoDB = GetOpVar("OPSYM_DISABLE"), GetOpVar("MODE_DATABASE")
  for iCnt = 1, defTab.Size do local defCol = defTab[iCnt]
    defCol[3] = GetTerm(tostring(defCol[3] or symDis), symDis)
    defCol[4] = GetTerm(tostring(defCol[4] or symDis), symDis)
  end; tableInsert(libQTable, defTab.Nick)
  libCache[defTab.Name] = {}; libQTable[defTab.Nick] = self
  -- Read table definition
  function self:GetDefinition(vK)
    if(vK) then return tabDef[vK] end; return tabDef
  end
  -- Reads the requested command or returns the whole list
  function self:GetCommand(vK)
    if(vK) then return tabCmd[vK] end; return tabCmd
  end
  -- Alias for reading the last created SQL statement
  function self:Get(vK)
    local qtCmd = self:GetCommand()
    local iK = (vK or qtCmd.STMT); return qtCmd[iK]
  end
  -- Returns ID of the found column
  function self:GetColumnID(sN)
    local sN, qtDef = tostring(sN or ""), self:GetDefinition()
    for iD = 1, qtDef.Size do if(qtDef[iD][1] == sN) then return iD end
    end; LogInstance("Mismatch <"..tostring(sN)..">"); return 0
  end
  -- Removes the object from the list
  function self:Remove(vRet)
    local qtDef = self:GetDefinition()
    libQTable[qtDef.Nick]  = nil
    collectgarbage(); return vRet
  end
  -- Generates a timer settings table and keeps the defaults
  function self:TimerSetup(vTim)
    local qtCmd = self:GetCommand()
    local qtDef = self:GetDefinition()
    local sTm = (vTim and tostring(vTim or "") or qtDef.Timer)
    local tTm = GetOpVar("OPSYM_REVISION"):Explode(sTm)
    tTm[1] =   tostring(tTm[1]  or "CQT")                     -- Timer mode
    tTm[2] =  (tonumber(tTm[2]) or 0)                         -- Record life
    tTm[3] = ((tonumber(tTm[3]) or 0) ~= 0) and true or false -- Kill command
    tTm[4] = ((tonumber(tTm[4]) or 0) ~= 0) and true or false -- Collect garbage call
    qtCmd.Timer = tTm; return self
  end
  -- Navigates the reference in the cache
  function self:GetNavigate(...)
    local tKey = {...}; if(not IsHere(tKey[1])) then
      LogInstance("Missing keys",tabDef.Nick); return nil end
    local oSpot, kKey, iCnt = libCache, tKey[1], 1
    while(tKey[iCnt]) do kKey = tKey[iCnt]; iCnt = iCnt + 1
      if(tKey[iCnt]) then oSpot = oSpot[kKey]; if(not IsHere(oSpot)) then
        LogTable(tKey,"Diverge("..tostring(kKey)..")",tabDef.Nick); return nil
    end; end; end; if(not oSpot[kKey]) then
      LogTable(tKey,"Missing",tabDef.Nick); return nil end
    return oSpot, kKey, tKey
  end
  -- Attaches timer to a record related in the table cache
  function self:TimerAttach(vMsg, ...)
    local sMoDB, oSpot, kKey, tKey = GetOpVar("MODE_DATABASE"), self:GetNavigate(...)
    if(not (IsHere(oSpot) and IsHere(kKey))) then
      LogInstance("Navigation failed",tabDef.Nick); return nil end
    LogInstance("Called by <"..tostring(vMsg).."> for ["..tostring(kKey).."]",tabDef.Nick)
    if(sMoDB == "SQL") then local qtCmd = self:GetCommand() -- Read the command and current time
      local nNow, tTim = Time(), qtCmd.Timer; if(not IsHere(tTim)) then
        LogInstance("Missing timer settings",tabDef.Nick); return oSpot[kKey] end
      oSpot[kKey].Used = nNow -- Make the first selected deletable to avoid phantom records
      local smTM, tmLif, tmDie, tmCol = tTim[1], tTim[2], tTim[3], tTim[4]; if(tmLif <= 0) then
        LogInstance("Timer attachment ignored",tabDef.Nick); return oSpot[kKey] end
      LogInstance("["..smTM.."] ("..tmLif..") "..tostring(tmDie)..", "..tostring(tmCol),tabDef.Nick)
      if(smTM == "CQT") then
        for k, v in pairs(oSpot) do
          if(IsHere(v.Used) and ((nNow - v.Used) > tmLif)) then
            LogInstance("("..tostring(mathRound(nNow - v.Used,2)).." > "..tmLif..") > Dead",tabDef.Nick)
            if(tmDie) then oSpot[k] = nil; LogInstance("Killed <"..tostring(k)..">",tabDef.Nick) end
          end
        end
        if(tmCol) then collectgarbage(); LogInstance("Garbage collected",tabDef.Nick) end
        LogInstance("["..tostring(kKey).."] @"..tostring(mathRound(nNow,2)),tabDef.Nick); return oSpot[kKey]
      elseif(smTM == "OBJ") then
        local tmID = GetOpVar("OPSYM_DIVIDER"):Implode(tKey)
        LogInstance("TimID <"..tmID..">",tabDef.Nick)
        if(timerExists(tmID)) then LogInstance("Timer exists",tabDef.Nick); return oSpot[kKey] end
        timerCreate(tmID, tmLif, 1, function()
          LogInstance("["..tmID.."]("..tmLif..") > Dead",tabDef.Nick)
          if(tmDie) then oSpot[kKey] = nil; LogInstance("Killed <"..kKey..">",tabDef.Nick) end
          timerStop(tmID); timerDestroy(tmID)
          if(tmCol) then collectgarbage(); LogInstance("Garbage collected",tabDef.Nick) end
        end); timerStart(tmID); return oSpot[kKey]
      else LogInstance("Mode mismatch <"..smTM..">",tabDef.Nick); return oSpot[kKey] end
    elseif(sMoDB == "LUA") then
      LogInstance("Memory manager impractical",tabDef.Nick); return oSpot[kKey]
    else LogInstance("Wrong database mode",tabDef.Nick); return nil end
  end
  -- Restarts timer to a record related in the table cache
  function self:TimerRestart(vMsg, ...)
    local sMoDB, oSpot, kKey, tKey = GetOpVar("MODE_DATABASE"), self:GetNavigate(...)
    if(not (IsHere(oSpot) and IsHere(kKey))) then
      LogInstance("Navigation failed",tabDef.Nick); return nil end
    LogInstance("Called by <"..tostring(vMsg).."> for ["..tostring(kKey).."]",tabDef.Nick)
    if(sMoDB == "SQL") then local qtCmd = self:GetCommand()
      local tTim = qtCmd.Timer; if(not IsHere(tTim)) then
        LogInstance("Missing timer settings",tabDef.Nick); return oSpot[kKey] end
      oSpot[kKey].Used = Time() -- Mark the current caching time stamp
      local smTM, tmLif = tTim[1], tTim[2]; if(tmLif <= 0) then
        LogInstance("Timer life ignored",tabDef.Nick); return oSpot[kKey] end
      if(smTM == "CQT") then smTM = "CQT"
      elseif(smTM == "OBJ") then -- Just for something to do here and to be known that this is mode CQT
        local kID = GetOpVar("OPSYM_DIVIDER"):Implode(tKeys); if(not timerExists(kID)) then
          LogInstance("Timer missing <"..kID..">",tabDef.Nick); return nil end
        timerStart(kID)
      else LogInstance("Mode mismatch <"..smTM..">",tabDef.Nick); return nil end
    elseif(sMoDB == "LUA") then oSpot[kKey].Used = Time()
    else LogInstance("Wrong database mode",tabDef.Nick); return nil end
    return oSpot[kKey]
  end
  -- Object internal data validation
  function self:IsValid() local bStat = true
    local qtCmd = self:GetCommand(); if(not qtCmd) then
      LogInstance("Missing commands <"..defTab.Nick..">",tabDef.Nick); bStat = false end
    local qtDef = self:GetDefinition(); if(not qtDef) then
      LogInstance("Missing definition",tabDef.Nick); bStat = false end
    if(qtDef.Size ~= #qtDef) then
      LogInstance("Mismatch count",tabDef.Nick); bStat = false end
    if(qtDef.Size ~= tableMaxn(qtDef)) then
      LogInstance("Mismatch maxN",tabDef.Nick); bStat = false end
    if(defTab.Nick:upper() ~= defTab.Nick) then
      LogInstance("Nick lower",tabDef.Nick); bStat = false end
    if(defTab.Name:upper() ~= defTab.Name) then
      LogInstance("Name lower <"..defTab.Name..">",tabDef.Nick); bStat = false end
    local nS, nE = defTab.Name:find(defTab.Nick); if(not (nS and nE and nS > 1 and nE == defTab.Name:len())) then
      LogInstance("Mismatch <"..defTab.Name..">",tabDef.Nick); bStat = false end
    for iD = 1, qtDef.Size do local tCol = qtDef[iD] if(type(tCol) ~= "table") then
        LogInstance("Mismatch type ["..iD.."]",tabDef.Nick); bStat = false end
      if(not IsString(tCol[1])) then
        LogInstance("Mismatch name ["..iD.."]",tabDef.Nick); bStat = false end
      if(not IsString(tCol[2])) then
        LogInstance("Mismatch type ["..iD.."]",tabDef.Nick); bStat = false end
      if(tCol[3] and not IsString(tCol[3])) then
        LogInstance("Mismatch ctrl ["..iD.."]",tabDef.Nick); bStat = false end
      if(tCol[4] and not IsString(tCol[4])) then
        LogInstance("Mismatch conv ["..iD.."]",tabDef.Nick); bStat = false end
    end; return bStat -- Succesfully validated the builder table
  end
  -- Creates table column list as string
  function self:GetColumnList(sD)
    if(not IsHere(sD)) then return "" end
    local qtDef, sRes, iCnt = self:GetDefinition(), "", 1
    local sD = tostring(sD or "\t"):sub(1,1); if(IsBlank(sD)) then
      LogInstance("Missing delimiter",tabDef.Nick); return "" end
    while(iCnt <= qtDef.Size) do
      sRes, iCnt = (sRes..qtDef[iCnt][1]), (iCnt + 1)
      if(qtDef[iCnt]) then sRes = sRes..sD end
    end; return sRes
  end
  -- Internal type matching
  function self:Match(snValue,ivID,bQuoted,sQuote,bNoRev,bNoNull)
    local qtDef, sNull = self:GetDefinition(), GetOpVar("MISS_NOSQL")
    local nvInd = tonumber(ivID); if(not IsHere(nvInd)) then
      LogInstance("Col NAN "..GetReport(ivID).." invalid",tabDef.Nick); return nil end
    local defCol = qtDef[nvInd]; if(not IsHere(defCol)) then
      LogInstance("Invalid col #"..tostring(nvInd),tabDef.Nick); return nil end
    local tipCol, sMoDB, snOut = tostring(defCol[2]), GetOpVar("MODE_DATABASE")
    if(tipCol == "TEXT") then snOut = tostring(snValue or "")
      if(not bNoNull and IsBlank(snOut)) then
        if    (sMoDB == "SQL") then snOut = sNull
        elseif(sMoDB == "LUA") then snOut = sNull
        else LogInstance("Wrong database empty mode <"..sMoDB..">",tabDef.Nick); return nil end
      end
      if    (defCol[3] == "LOW") then snOut = snOut:lower()
      elseif(defCol[3] == "CAP") then snOut = snOut:upper() end
      if(not bNoRev and sMoDB == "SQL" and defCol[4] == "QMK") then
        snOut = snOut:gsub("'","''") end
      if(bQuoted) then local sqChar
        if(sQuote) then
          sqChar = tostring(sQuote or ""):sub(1,1)
        else
          if    (sMoDB == "SQL") then sqChar = "'"
          elseif(sMoDB == "LUA") then sqChar = "\""
          else LogInstance("Wrong database quote mode <"..sMoDB..">",tabDef.Nick); return nil end
        end; snOut = sqChar..snOut..sqChar
      end
    elseif(tipCol == "REAL" or tipCol == "INTEGER") then
      snOut = tonumber(snValue)
      if(IsHere(snOut)) then
        if(tipCol == "INTEGER") then
          if    (defCol[3] == "FLR") then snOut = mathFloor(snOut)
          elseif(defCol[3] == "CEL") then snOut = mathCeil (snOut) end
        end
      else LogInstance("Failed converting "..GetReport(snValue).." to NUMBER col #"..nvInd,tabDef.Nick); return nil end
    else LogInstance("Invalid col type <"..tipCol..">",tabDef.Nick); return nil
    end; return snOut
  end
  -- Build drop statment
  function self:Drop()
    local qtDef = self:GetDefinition()
    local qtCmd = self:GetCommand(); qtCmd.STMT = "Drop"
    qtCmd.Drop  = "DROP TABLE "..qtDef.Name..";"; return self
  end
  -- Build delete statment
  function self:Delete()
    local qtDef = self:GetDefinition()
    local qtCmd = self:GetCommand(); qtCmd.STMT = "Delete"
    qtCmd.Delete = "DELETE FROM "..qtDef.Name..";"; return self
  end
  -- Bhttps://wiki.garrysmod.com/page/sql/Begin
  function self:Begin()
    local qtCmd = self:GetCommand()
    qtCmd.Begin = "BEGIN;"; return self
  end
  -- https://wiki.garrysmod.com/page/sql/Commit
  function self:Commit()
    local qtCmd = self:GetCommand()
    qtCmd.Commit = "COMMIT;"; return self
  end
  -- Build create/drop/delete statment table of statemenrts
  function self:Create()
    local qtDef = self:GetDefinition()
    local qtCmd, iInd = self:GetCommand(), 1; qtCmd.STMT = "Create"
    qtCmd.Create = "CREATE TABLE "..qtDef.Name.." ( "
    while(qtDef[iInd]) do local v = qtDef[iInd]
      if(not v[1]) then
        LogInstance("Missing col name #"..tostring(iInd),tabDef.Nick); return nil end
      if(not v[2]) then
        LogInstance("Missing col type #"..tostring(iInd),tabDef.Nick); return nil end
      qtCmd.Create = qtCmd.Create..(v[1]):upper().." "..(v[2]):upper()
      iInd = (iInd + 1); if(qtDef[iInd]) then qtCmd.Create = qtCmd.Create ..", " end
    end
    qtCmd.Create = qtCmd.Create.." );"; return self
  end
  -- Build SQL table indexes
  function self:Index(...) local tIndex = {...}
    local qtCmd, qtDef = self:GetCommand(), self:GetDefinition()
    if(not (IsTable(tIndex) and tIndex[1])) then
      tIndex = qtDef.Index end -- Empty stack use table definition
    if(IsTable(qtCmd.Index)) then tableEmpty(qtCmd.Index)
      else qtCmd.Index = {} end; local iCnt, iInd = 1, 1
    while(tIndex[iInd]) do -- Build index query and reload index commands
      local vI = tIndex[iInd]; if(type(vI) ~= "table") then
        LogInstance("Mismatch value ["..tostring(vI).."] not table for ID ["..tostring(iInd).."]",tabDef.Nick); return nil end
      local cU, cC = "", ""; qtCmd.Index[iInd], iCnt = "CREATE INDEX IND_"..qtDef.Name, 1
      while(vI[iCnt]) do local vF = tonumber(vI[iCnt]); if(not vF) then
          LogInstance("Mismatch value ["..tostring(vI[iCnt]).."] NaN for ID ["..tostring(iInd).."]["..tostring(iCnt).."]",tabDef.Nick); return nil end
        if(not qtDef[vF]) then
          LogInstance("Mismatch. The col ID #"..tostring(vF).." missing, max is #"..Table.Size,tabDef.Nick); return nil end
        cU, cC = (cU.."_" ..(qtDef[vF][1]):upper()), (cC..(qtDef[vF][1]):upper()); vI[iCnt] = vF
        iCnt = iCnt + 1; if(vI[iCnt]) then cC = cC ..", " end
      end
      qtCmd.Index[iInd] = qtCmd.Index[iInd]..cU.." ON "..qtDef.Name.." ( "..cC.." );"
      iInd = iInd + 1
    end; return self
  end
  -- Build SQL select statement
  function self:Select(...)
    local qtCmd = self:GetCommand()
    local qtDef = self:GetDefinition(); qtCmd.STMT = "Select"
    local sStmt, iCnt, tCols = "SELECT ", 1, {...}
    if(tCols[1]) then
      while(tCols[iCnt]) do
        local v = tonumber(tCols[iCnt]); if(not IsHere(v)) then
          LogInstance("Index NAN "..GetReport(tCols[iCnt]).." type mismatch",tabDef.Nick); return nil end
        if(not qtDef[v]) then
          LogInstance("Missing col by index #"..tostring(v),tabDef.Nick); return nil end
        if(qtDef[v][1]) then sStmt = sStmt..qtDef[v][1]
        else LogInstance("Missing col name by index #"..tostring(v),tabDef.Nick); return nil end
        iCnt = (iCnt + 1); if(tCols[iCnt]) then sStmt = sStmt ..", " end
      end
    else sStmt = sStmt.."*" end
    qtCmd.Select = sStmt .." FROM "..qtDef.Name..";"; return self
  end
  -- Add where clause to the select statement
  function self:Where(...) local tWhere = {...}
    if(not tWhere[1]) then return self end
    local iCnt, qtDef, qtCmd = 1, self:GetDefinition(), self:GetCommand()
    qtCmd.Select = qtCmd.Select:Trim("%s"):Trim(";")
    while(tWhere[iCnt]) do local k = tonumber(tWhere[iCnt][1])
      local v, t = tWhere[iCnt][2], qtDef[k][2]; if(not (k and v and t) ) then
        LogInstance("Where clause inconsistent col index, {"..tostring(k)..","..tostring(v)..","..tostring(t).."}",tabDef.Nick); return nil end
      if(not IsHere(v)) then
        LogInstance("Data matching failed index #"..tostring(iCnt).." value <"..tostring(v)..">",tabDef.Nick); return nil end
      if(iCnt == 1) then qtCmd.Select = qtCmd.Select.." WHERE "..qtDef[k][1].." = "..tostring(v)
      else               qtCmd.Select = qtCmd.Select.." AND "  ..qtDef[k][1].." = "..tostring(v) end
      iCnt = iCnt + 1
    end; qtCmd.Select = qtCmd.Select..";"; return self
  end
  -- Add order by clause to the select statement
  function self:Order(...) local tOrder = {...}
    if(not tOrder[1]) then return self end
    local qtCmd, qtDef = self:GetCommand(), self:GetDefinition()
    local sDir, sStmt, iCnt = "", " ORDER BY ", 1
    qtCmd.Select = qtCmd.Select:Trim("%s"):Trim(";")
    while(tOrder[iCnt]) do local v = tOrder[iCnt]
      if(v ~= 0) then if(v > 0) then sDir = " ASC"
        else sDir, tOrder[iCnt] = " DESC", -v; v = -v end
      else LogInstance("Mismatch col index #"..tostring(iCnt),tabDef.Nick); return nil end
      sStmt, iCnt = (sStmt..qtDef[v][1]..sDir), (iCnt + 1)
      if(tOrder[iCnt]) then sStmt = sStmt..", " end
    end; qtCmd.Select = qtCmd.Select..sStmt..";" return self
  end
  -- Build SQL insert statement
  function self:Insert(...)
    local qtCmd, iCnt, qIns = self:GetCommand(), 1, ""
    local tInsert, qtDef = {...}, self:GetDefinition(); qtCmd.STMT = "Insert"
    qtCmd.Insert = "INSERT INTO "..qtDef.Name.." ( "
    if(not tInsert[1]) then
      for iCnt = 1, qtDef.Size do qIns = qIns..qtDef[iCnt][1]
        if(iCnt < qtDef.Size) then qIns = qIns..", " else qIns = qIns.." ) " end end
    else
      while(tInsert[iCnt]) do local vInd = tInsert[iCnt]
        local iIns = tonumber(vInd); if(not IsHere(iIns)) then
          LogInstance("Column ID ["..tostring(vInd).."] NaN",tabDef.Nick); return nil end
        local cIns = qtDef[iIns]; if(not IsHere(cIns)) then
          LogInstance("Column ID ["..tostring(iIns).."] mismatch",tabDef.Nick); return nil end
        iCnt, qIns = (iCnt + 1), qIns..cIns[1]
        if(tInsert[iCnt]) then qIns = qIns..", " else qIns = qIns.." ) " end
      end
    end; qtCmd.Insert = qtCmd.Insert..qIns; return self
  end
  -- Build SQL values statement
  function self:Values(...)
    local qtDef, tValues = self:GetDefinition(), {...}
    local qtCmd, iCnt, qVal = self:GetCommand(), 1, ""
    qtCmd.Insert = qtCmd.Insert.." VALUES ( "
    while(tValues[iCnt]) do
      iCnt, qVal = (iCnt + 1), qVal..tostring(tValues[iCnt])
      if(tValues[iCnt]) then qVal = qVal..", " else qVal = qVal.." )" end
    end; qtCmd.Insert = qtCmd.Insert..qVal..";"; return self
  end
  -- Uses the given array to create a record in the table
  function self:Record(arLine)
    local qtDef, sMoDB, sFunc = self:GetDefinition(), GetOpVar("MODE_DATABASE"), "Record"
    if(not arLine) then LogInstance("Missing data table",tabDef.Nick); return false end
    if(not arLine[1]) then LogInstance("Missing PK",tabDef.Nick)
      for key, val in pairs(arLine) do
        LogInstance("PK data ["..tostring(key).."] = <"..tostring(val)..">",tabDef.Nick) end
      return false -- Print all other values when the model is missing
    end -- Read the log source format and reduce the number of concatenations
    local fsLog = GetOpVar("FORM_LOGSOURCE") -- The actual format value
    local ssLog = "*"..fsLog:format(qtDef.Nick,sFunc,"%s")
    -- Call the trigger when provided
    if(IsTable(qtDef.Trigs)) then local bS, sR = pcall(qtDef.Trigs[sFunc], arLine, ssLog:format("Trigs"))
      if(not bS) then LogInstance("Trigger manager "..sR,tabDef.Nick); return false end
      if(not sR) then LogInstance("Trigger routine fail",tabDef.Nick); return false end
    end -- Populate the data after the trigger does its thing
    if(sMoDB == "SQL") then local qsKey = GetOpVar("FORM_KEYSTMT")
      for iD = 1, qtDef.Size do arLine[iD] = self:Match(arLine[iD],iD,true) end
      local Q = CacheStmt(qsKey:format(sFunc, qtDef.Nick), nil, unpack(arLine))
      if(not Q) then local sStmt = self:Insert():Values(unpack(qtDef.Query[sFunc])):Get()
        if(not IsHere(sStmt)) then LogInstance("Build statement failed",tabDef.Nick); return nil end
        Q = CacheStmt(qsKey:format(sFunc, qtDef.Nick), sStmt, unpack(arLine))
      end -- The query is built based on table definition
      if(not IsHere(Q)) then
        LogInstance("Internal cache error",tabDef.Nick); return false end
      local qRez = sqlQuery(Q); if(not qRez and IsBool(qRez)) then
         LogInstance("Execution error <"..sqlLastError().."> Query ran <"..Q..">",tabDef.Nick); return false end
      return true -- The dynamic statement insertion was successful
    elseif(sMoDB == "LUA") then local snPK = self:Match(arLine[1],1)
      if(not IsHere(snPK)) then -- If primary key becomes a number
        LogInstance("Primary key mismatch <"..tostring(arLine[1]).."> to "..qtDef[1][1].." for "..tostring(snPK),tabDef.Nick); return nil end
      local tCache = libCache[qtDef.Name]; if(not IsHere(tCache)) then
        LogInstance("Cache missing",tabDef.Nick); return false end
      if(not IsTable(qtDef.Cache)) then
        LogInstance("Cache manager missing",tabDef.Nick); return false end
      local bS, sR = pcall(qtDef.Cache[sFunc], self, tCache, snPK, arLine, ssLog:format("Cache"))
      if(not bS) then LogInstance("Cache manager fail "..sR,tabDef.Nick); return false end
      if(not sR) then LogInstance("Cache routine fail",tabDef.Nick); return false end
    else LogInstance("Wrong database mode <"..sMoDB..">",tabDef.Nick); return false end
    return true -- The dynamic cache population was successful
  end
  -- When database mode is SQL create a table in sqlite
  if(sMoDB == "SQL") then local makTab
    makTab = self:Create(); if(not IsHere(makTab)) then
      LogInstance("Build create failed"); return self:Remove(false) end
    makTab = self:Index(); if(not IsHere(makTab)) then
      LogInstance("Build index failed"); return self:Remove(false) end
    makTab = self:Drop(); if(not IsHere(makTab)) then
      LogInstance("Build drop failed"); return self:Remove(false) end
    makTab = self:Delete(); if(not IsHere(makTab)) then
      LogInstance("Build delete failed"); return self:Remove(false) end
    makTab = self:Begin(); if(not IsHere(makTab)) then
      LogInstance("Build begin failed"); return self:Remove(false) end
    makTab = self:Commit(); if(not IsHere(makTab)) then
      LogInstance("Build commit failed"); return self:Remove(false) end
    makTab = self:TimerSetup(); if(not IsHere(makTab)) then
      LogInstance("Build timer failed"); return self:Remove(false) end
    local tQ = self:GetCommand(); if(not IsHere(tQ)) then
      LogInstance("Build statement failed"); return self:Remove(false) end
    -- When the table is present delete all records
    if(bDelete and sqlTableExists(defTab.Name)) then
      local qRez = sqlQuery(tQ.Delete); if(not qRez and IsBool(qRez)) then
        LogInstance("Table delete error <"..sqlLastError()..">",tabDef.Nick)
      else LogInstance("Table delete skipped",tabDef.Nick) end
    end
    -- When enabled forces a table drop
    if(bReload) then local qRez = sqlQuery(tQ.Drop)
      if(not qRez and IsBool(qRez)) then
        LogInstance("Table drop error <"..sqlLastError()..">",tabDef.Nick)
      else LogInstance("Table drop skipped",tabDef.Nick) end
    end
    if(sqlTableExists(defTab.Name)) then
      LogInstance("Table exists",tabDef.Nick); return self:IsValid()
    else local qRez = sqlQuery(tQ.Create); if(not qRez and IsBool(qRez)) then
        LogInstance("Table create fail because of "..sqlLastError(),tabDef.Nick); return self:Remove(false) end
      if(sqlTableExists(defTab.Name)) then
        for k, v in pairs(tQ.Index) do qRez = sqlQuery(v); if(not qRez and IsBool(qRez)) then
          LogInstance("Table index create fail ["..k.."] > "..v .." > because of "..sqlLastError(),tabDef.Nick); return self:Remove(false) end
        end; LogInstance("Indexed table created",tabDef.Nick); return self:IsValid()
      else LogInstance("Table create fail because of "..sqlLastError().." Query ran > "..tQ.Create,tabDef.Nick); return self:Remove(false) end
    end
  elseif(sMoDB == "LUA") then LogInstance("Created",tabDef.Nick); return self:IsValid()
  else LogInstance("Wrong database mode <"..sMoDB..">",tabDef.Nick); return self:Remove(false) end
end

--------------- TIMER MEMORY MANAGMENT ----------------------------

function CacheBoxLayout(oEnt,nRot,nCamX,nCamZ)
  if(not (oEnt and oEnt:IsValid())) then
    LogInstance("Entity invalid <"..tostring(oEnt)..">"); return nil end
  local sMod = oEnt:GetModel()
  local oRec = CacheQueryPiece(sMod); if(not IsHere(oRec)) then
    LogInstance("Piece record invalid <"..sMod..">"); return nil end
  local stBox = oRec.Layout; if(not IsHere(stBox)) then
    local vMin, vMax; oRec.Layout = {}; stBox = oRec.Layout
    if    (CLIENT) then vMin, vMax = oEnt:GetRenderBounds()
    elseif(SERVER) then vMin, vMax = oEnt:OBBMins(), oEnt:OBBMaxs()
    else LogInstance("Wrong instance"); return nil end
    stBox.Ang = Angle () -- Layout entity angle
    stBox.Cen = Vector() -- Layout entity center
    stBox.Cen:Set(vMax); stBox.Cen:Add(vMin); stBox.Cen:Mul(0.5)
    stBox.Eye = oEnt:LocalToWorld(stBox.Cen) -- Layout camera eye
    stBox.Len = (((vMax - stBox.Cen):Length() + (vMin - stBox.Cen):Length()) / 2)
    stBox.Cam = Vector(); stBox.Cam:Set(stBox.Eye)  -- Layout camera position
    AddVectorXYZ(stBox.Cam,stBox.Len*(tonumber(nCamX) or 0),0,stBox.Len*(tonumber(nCamZ) or 0))
    LogInstance("<"..tostring(stBox.Cen).."><"..tostring(stBox.Len)..">")
  end; stBox.Ang[caY] = (tonumber(nRot) or 0) * Time(); return stBox
end

--------------------------- PIECE QUERY -----------------------------

function CacheQueryPiece(sModel)
  if(not IsHere(sModel)) then
    LogInstance("Model does not exist"); return nil end
  if(not IsString(sModel)) then
    LogInstance("Model "..GetReport(sModel).." not string"); return nil end
  if(IsBlank(sModel)) then
    LogInstance("Model empty string"); return nil end
  if(not utilIsValidModel(sModel)) then
    LogInstance("Model invalid <"..sModel..">"); return nil end
  local makTab = libQTable["PIECES"]; if(not IsHere(makTab)) then
    LogInstance("Missing table builder"); return nil end
  local defTab = makTab:GetDefinition(); if(not IsHere(defTab)) then
    LogInstance("Missing table definition"); return nil end
  local tCache = libCache[defTab.Name]; if(not IsHere(tCache)) then
    LogInstance("Cache missing for <"..defTab.Name..">"); return nil end
  local sModel, qsKey = makTab:Match(sModel,1,false,"",true,true), GetOpVar("FORM_KEYSTMT")
  local stPiece, sFunc = tCache[sModel], "CacheQueryPiece"
  if(IsHere(stPiece) and IsHere(stPiece.Size)) then
    if(stPiece.Size <= 0) then stPiece = nil else
      stPiece = makTab:TimerRestart(sFunc, defTab.Name, sModel) end
    return stPiece
  else
    local sMoDB = GetOpVar("MODE_DATABASE")
    if(sMoDB == "SQL") then
      local qModel = makTab:Match(sModel,1,true)
      LogInstance("Model >> Pool <"..sModel:GetFileFromFilename()..">")
      tCache[sModel] = {}; stPiece = tCache[sModel]; stPiece.Size = 0
      local Q = CacheStmt(qsKey:format(sFunc, ""), nil, qModel)
      if(not Q) then
        local sStmt = makTab:Select():Where({1,"%s"}):Order(4):Get()
        if(not IsHere(sStmt)) then
          LogInstance("Build statement failed"); return nil end
        Q = CacheStmt(qsKey:format(sFunc, ""), sStmt, qModel)
      end
      local qData = sqlQuery(Q); if(not qData and IsBool(qData)) then
        LogInstance("SQL exec error <"..sqlLastError()..">"); return nil end
      if(not (qData and qData[1])) then
        LogInstance("No data found <"..Q..">"); return nil end
      local iCnt = 1 --- Nothing registered. Start from the beginning
      stPiece.Slot, stPiece.Size = sModel, 0
      stPiece.Type = qData[1][defTab[2][1]]
      stPiece.Name = qData[1][defTab[3][1]]
      stPiece.Rake = qData[1][defTab[4][1]]
      stPiece.Unit = qData[1][defTab[8][1]]
      while(qData[iCnt]) do local qRec = qData[iCnt]
        if(not IsHere(RegisterPOA(stPiece,iCnt,
          qRec[defTab[5][1]], qRec[defTab[6][1]], qRec[defTab[7][1]]))) then
          LogInstance("Cannot process offset #"..tostring(iCnt).." for <"..sModel..">"); return nil
        end; stPiece.Size, iCnt = iCnt, (iCnt + 1)
      end; stPiece = makTab:TimerAttach(sFunc, defTab.Name, sModel); return stPiece
    elseif(sMoDB == "LUA") then LogInstance("Record not located"); return nil
    else LogInstance("Wrong database mode <"..sMoDB..">"); return nil end
  end
end

function CacheQueryAdditions(sModel)
  if(not IsHere(sModel)) then
    LogInstance("Model does not exist"); return nil end
  if(not IsString(sModel)) then
    LogInstance("Model "..GetReport(sModel).." not string"); return nil end
  if(IsBlank(sModel)) then
    LogInstance("Model empty string"); return nil end
  if(not utilIsValidModel(sModel)) then
    LogInstance("Model invalid"); return nil end
  local makTab = libQTable["ADDITIONS"]; if(not IsHere(makTab)) then
    LogInstance("Missing table builder"); return nil end
  local defTab = makTab:GetDefinition(); if(not IsHere(defTab)) then
    LogInstance("Missing table definition"); return nil end
  local tCache = libCache[defTab.Name]; if(not IsHere(tCache)) then
    LogInstance("Cache missing for <"..defTab.Name..">"); return nil end
  local sModel, qsKey = makTab:Match(sModel,1,false,"",true,true), GetOpVar("FORM_KEYSTMT")
  local stAddit, sFunc = tCache[sModel], "CacheQueryAdditions"
  if(IsHere(stAddit) and IsHere(stAddit.Size)) then
    if(stAddit.Size <= 0) then stAddit = nil else
      stAddit = makTab:TimerRestart(sFunc, defTab.Name, sModel) end
    return stAddit
  else
    local sMoDB = GetOpVar("MODE_DATABASE")
    if(sMoDB == "SQL") then
      local qModel = makTab:Match(sModel,1,true)
      LogInstance("Model >> Pool <"..sModel:GetFileFromFilename()..">")
      tCache[sModel] = {}; stAddit = tCache[sModel]; stAddit.Size = 0
      local Q = CacheStmt(qsKey:format(sFunc, ""), nil, qModel)
      if(not Q) then
        local sStmt = makTab:Select(2,3,4,5,6,7,8,9,10,11,12):Where({1,"%s"}):Order(4):Get()
        if(not IsHere(sStmt)) then
          LogInstance("Build statement failed"); return nil end
        Q = CacheStmt(qsKey:format(sFunc, ""), sStmt, qModel)
      end
      local qData = sqlQuery(Q); if(not qData and IsBool(qData)) then
        LogInstance("SQL exec error <"..sqlLastError()..">"); return nil end
      if(not (qData and qData[1])) then
        LogInstance("No data found <"..Q..">"); return nil end
      local iCnt = 1; stAddit.Slot, stAddit.Size = sModel, 0
      while(qData[iCnt]) do
        local qRec = qData[iCnt]; stAddit[iCnt] = {}
        for col, val in pairs(qRec) do stAddit[iCnt][col] = val end
        stAddit.Size, iCnt = iCnt, (iCnt + 1)
      end; stAddit = makTab:TimerAttach(sFunc, defTab.Name, sModel); return stAddit
    elseif(sMoDB == "LUA") then LogInstance("Record not located"); return nil
    else LogInstance("Wrong database mode <"..sMoDB..">"); return nil end
  end
end

----------------------- PANEL QUERY -------------------------------

--[[
 * Caches the date needed to populate the CPanel tree
]]--
function CacheQueryPanel()
  local makTab = libQTable["PIECES"]; if(not IsHere(makTab)) then
    LogInstance("Missing table builder"); return nil end
  local defTab = makTab:GetDefinition(); if(not IsHere(defTab)) then
    LogInstance("Missing table definition"); return nil end
  if(not IsHere(libCache[defTab.Name])) then
    LogInstance("Missing cache allocated <"..defTab.Name..">"); return nil end
  local keyPan , sFunc = GetOpVar("HASH_USER_PANEL"), "CacheQueryPanel"
  local stPanel, qsKey = libCache[keyPan], GetOpVar("FORM_KEYSTMT")
  if(IsHere(stPanel) and IsHere(stPanel.Size)) then LogInstance("From Pool")
    if(stPanel.Size <= 0) then stPanel = nil else
      stPanel = makTab:TimerRestart(sFunc, keyPan) end
    return stPanel
  else
    libCache[keyPan] = {}; stPanel = libCache[keyPan]
    local sMoDB = GetOpVar("MODE_DATABASE")
    if(sMoDB == "SQL") then
      local Q = CacheStmt(qsKey:format(sFunc,""), nil, 1)
      if(not Q) then
        local sStmt = makTab:Select(1,2,3):Order(2,3):Get()
        if(not IsHere(sStmt)) then
          LogInstance("Build statement failed"); return nil end
        Q = CacheStmt(qsKey:format(sFunc,""), sStmt, 1)
      end
      local qData = sqlQuery(Q); if(not qData and IsBool(qData)) then
        LogInstance("SQL exec error <"..sqlLastError()..">"); return nil end
      if(not (qData and qData[1])) then
        LogInstance("No data found <"..Q..">"); return nil end
      local iCnt = 1; stPanel.Size = 1
      while(qData[iCnt]) do
        stPanel[iCnt] = qData[iCnt]; stPanel.Size, iCnt = iCnt, (iCnt + 1)
      end; stPanel = makTab:TimerAttach(sFunc, keyPan); return stPanel
    elseif(sMoDB == "LUA") then
      local tCache = libCache[defTab.Name]
      local tSort  = Sort(tCache,{"Type","Name"}); if(not tSort) then
        LogInstance("Cannot sort cache data"); return nil end; stPanel.Size = 0
      for iCnt = 1, tSort.Size do stPanel[iCnt] = {}
        local vSort, vPanel = tSort[iCnt], stPanel[iCnt]
        vPanel[defTab[1][1]] = vSort.Key
        vPanel[defTab[2][1]] = tCache[vSort.Key].Type
        vPanel[defTab[3][1]] = tCache[vSort.Key].Name; stPanel.Size = iCnt
      end; return stPanel
    else LogInstance("Wrong database mode <"..sMoDB..">"); return nil end
  end
end

---------------------- EXPORT --------------------------------

--[[
 * Save/Load the category generation
 * vEq    > Amount of intenal comment depth
 * tData  > The local data table to be exported ( if given )
 * sPref  > Prefix used on exporting ( if not uses instance prefix)
]]--
function ExportCategory(vEq, tData, sPref)
  if(SERVER) then LogInstance("Working on server"); return true end
  local nEq   = (tonumber(vEq) or 0); if(nEq <= 0) then
    LogInstance("Wrong equality <"..tostring(vEq)..">"); return false end
  local fPref = tostring(sPref or GetInstPref()); if(IsBlank(sPref)) then
    LogInstance("("..fPref..") Prefix empty"); return false end
  local fName, sFunc = GetOpVar("DIRPATH_BAS"), "ExportCategory"
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  fName = fName..GetOpVar("DIRPATH_DSV")
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  fName = fName..fPref..GetOpVar("TOOLNAME_PU").."CATEGORY.txt"
  local F = fileOpen(fName, "wb", "DATA")
  if(not F) then LogInstance("("..fPref..") fileOpen("..fName..") failed from"); return false end
  local sEq, nLen, sMoDB = ("="):rep(nEq), (nEq+2), GetOpVar("MODE_DATABASE")
  local tCat = (type(tData) == "table") and tData or GetOpVar("TABLE_CATEGORIES")
  F:Write("# "..sFunc..":("..tostring(nEq).."@"..fPref..") "..GetDate().." [ "..sMoDB.." ]\n")
  for cat, rec in pairs(tCat) do
    if(IsString(rec.Txt)) then
      local exp = "["..sEq.."["..cat..sEq..rec.Txt:Trim().."]"..sEq.."]"
      if(not rec.Txt:find("\n")) then F:Flush(); F:Close()
        LogInstance("("..fPref.."):("..fPref..") Category one-liner <"..cat..">"); return false end
      F:Write(exp.."\n")
    else F:Flush(); F:Close(); LogInstance("("..fPref..") Category <"..cat.."> code <"..tostring(rec.Txt).."> mismatch"); return false end
  end; F:Flush(); F:Close(); LogInstance("("..fPref..") Success"); return true
end

function ImportCategory(vEq, sPref)
  if(SERVER) then LogInstance("Working on server"); return true end
  local nEq = (tonumber(vEq) or 0); if(nEq <= 0) then
    LogInstance("Wrong equality <"..tostring(vEq)..">"); return false end
  local fName = GetOpVar("DIRPATH_BAS")..GetOpVar("DIRPATH_DSV")
        fName = fName..tostring(sPref or GetInstPref())
        fName = fName..GetOpVar("TOOLNAME_PU").."CATEGORY.txt"
  local F = fileOpen(fName, "rb", "DATA")
  if(not F) then LogInstance("fileOpen("..fName..") failed"); return false end
  local sEq, sLine, nLen = ("="):rep(nEq), "", (nEq+2)
  local cFr, cBk = "["..sEq.."[", "]"..sEq.."]"
  local tCat, symOff = GetOpVar("TABLE_CATEGORIES"), GetOpVar("OPSYM_DISABLE")
  local sPar, isPar, isEOF = "", false, false
  while(not isEOF) do sLine, isEOF = GetStringFile(F)
    if(not IsBlank(sLine)) then
      local sFr, sBk = sLine:sub(1,nLen), sLine:sub(-nLen,-1)
      if(sFr == cFr and sBk == cBk) then
        sLine, isPar, sPar = sLine:sub(nLen+1,-1), true, "" end
      if(sFr == cFr and not isPar) then
        sPar, isPar = sLine:sub(nLen+1,-1).."\n", true
      elseif(sBk == cBk and isPar) then
        sPar, isPar = sPar..sLine:sub(1,-nLen-1), false
        local tBoo = sEq:Explode(sPar)
        local key, txt = tBoo[1]:Trim(), tBoo[2]
        if(not IsBlank(key)) then
          if(txt:find("function")) then
            if(key:sub(1,1) ~= symOff) then
              tCat[key] = {}; tCat[key].Txt = txt:Trim()
              tCat[key].Cmp = CompileString("return ("..tCat[key].Txt..")",key)
              local suc, out = pcall(tCat[key].Cmp)
              if(suc) then tCat[key].Cmp = out else tCat[key].Cmp = nil
                LogInstance("Compilation fail <"..key..">")
              end
            else LogInstance("Key skipped <"..key..">") end
          else LogInstance("Function missing <"..key..">") end
        else LogInstance("Name missing <"..txt..">") end
      else sPar = sPar..sLine.."\n" end
    end
  end; F:Close(); LogInstance("Success"); return true
end

--[[
 * This function removes DSV associated with a given prefix
 * sTable > Extremal table nickname database to remove
 * sPref  > Prefix used on exporting ( if any ) else instance is used
]]--
function RemoveDSV(sTable, sPref)
  local sPref = tostring(sPref or GetInstPref()); if(IsBlank(sPref)) then
    LogInstance("("..sPref..") Prefix empty"); return false end
  if(not IsString(sTable)) then LogInstance("("..sPref..") Table "
    ..GetReport(sTable).." not string"); return false end
  local fName = GetOpVar("DIRPATH_BAS")..GetOpVar("DIRPATH_DSV")
        fName = fName..sPref..GetOpVar("TOOLNAME_PU").."%s"..".txt"
  local makTab, sName = GetBuilderNick(sTable); if(IsHere(makTab)) then
    local defTab = makTab:GetDefinition(); if(not IsHere(defTab)) then
      LogInstance("("..sPref..") Missing table definition",sTable); return false end
    sName = fName:format(defTab.Nick)
  else sName = fName:format(sTable:upper())
    LogInstance("("..sPref..") Missing table builder",sTable)
  end
  if(fileExists(sName,"DATA")) then fileDelete(sName)
    LogInstance("("..sPref..") File <"..sName.."> deleted",sTable)
  else LogInstance("("..sPref..") File <"..sName.."> skipped",sTable) end; return true
end

--[[
 * This function exports a given table to DSV file format
 * It is used by the player when he wants to export the
 * whole database to a delimiter separator format file
 * sTable > The table you want to export
 * sPref  > The external data prefix to be used
 * sDelim > What delimiter is the server using ( default tab )
]]--
function ExportDSV(sTable, sPref, sDelim)
  if(not IsString(sTable)) then
    LogInstance("Table "..GetReport(sTable).." not string"); return false end
  local makTab = GetBuilderNick(sTable); if(not IsHere(makTab)) then
    LogInstance("("..fPref..") Missing table builder",sTable); return false end
  local defTab = makTab:GetDefinition(); if(not IsHere(defTab)) then
    LogInstance("("..fPref..") Missing table definition",sTable); return nil end
  local fName, fPref = GetOpVar("DIRPATH_BAS"), tostring(sPref or GetInstPref())
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  fName = fName..GetOpVar("DIRPATH_DSV")
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  fName = fName..fPref..defTab.Name..".txt"
  local F = fileOpen(fName, "wb", "DATA"); if(not F) then
    LogInstance("("..fPref..") fileOpen("..fName..") failed",sTable); return false end
  local sDelim, sFunc = tostring(sDelim or "\t"):sub(1,1), "ExportDSV"
  local fsLog = GetOpVar("FORM_LOGSOURCE") -- read the log source format
  local ssLog = "*"..fsLog:format(defTab.Nick,sFunc,"%s")
  local sMoDB, symOff = GetOpVar("MODE_DATABASE"), GetOpVar("OPSYM_DISABLE")
  F:Write("# "..sFunc..":("..fPref.."@"..sTable..") "..GetDate().." [ "..sMoDB.." ]\n")
  F:Write("# Data settings:("..makTab:GetColumnList(sDelim)..")\n")
  if(sMoDB == "SQL") then
    local Q = makTab:Select():Order(unpack(defTab.Query[sFunc])):Get()
    if(not IsHere(Q)) then F:Flush(); F:Close()
      LogInstance("("..fPref..") Build statement failed",sTable); return false end
    F:Write("# Query ran: <"..Q..">\n")
    local qData = sqlQuery(Q); if(not qData and IsBool(qData)) then F:Flush(); F:Close()
      LogInstance("("..fPref..") SQL exec error <"..sqlLastError()..">",sTable); return nil end
    if(not (qData and qData[1])) then F:Flush(); F:Close()
      LogInstance("("..fPref..") No data found <"..Q..">",sTable); return false end
    local sData, sTab = "", defTab.Name
    for iCnt = 1, #qData do local qRec = qData[iCnt]; sData = sTab
      for iInd = 1, defTab.Size do local sHash = defTab[iInd][1]
        sData = sData..sDelim..makTab:Match(qRec[sHash],iInd,true,"\"",true)
      end; F:Write(sData.."\n"); sData = ""
    end -- Matching will not crash as it is matched during insertion
  elseif(sMoDB == "LUA") then
    local tCache = libCache[defTab.Name]
    if(not IsHere(tCache)) then F:Flush(); F:Close()
      LogInstance("("..fPref..") Cache missing",sTable); return false end
    local bS, sR = pcall(defTab.Cache[sFunc], F, makTab, tCache, fPref, sDelim, ssLog:format("Cache"))
    if(not bS) then LogInstance("("..fPref..") Cache manager fail for "..sR,sTable); return false end
    if(not sR) then LogInstance("("..fPref..") Cache routine fail",sTable); return false end
  else LogInstance("("..fPref..") Wrong database mode <"..sMoDB..">",sTable); return false end
  -- The dynamic cache population was successful then send a message
  F:Flush(); F:Close(); LogInstance("("..fPref..") Success",sTable); return true
end

--[[
 * Import table data from DSV database created earlier
 * sTable > Definition KEY to import
 * bComm  > Calls TABLE:Record(arLine) when set to true
 * sPref  > Prefix used on importing ( if any )
 * sDelim > Delimiter separating the values
]]--
function ImportDSV(sTable, bComm, sPref, sDelim)
  local fPref = tostring(sPref or GetInstPref()); if(not IsString(sTable)) then
    LogInstance("("..fPref..") Table "..GetReport(sTable).." not string"); return false end
  local makTab = GetBuilderNick(sTable); if(not IsHere(makTab)) then
    LogInstance("("..fPref..") Missing table builder",sTable); return nil end
  local defTab = makTab:GetDefinition(); if(not IsHere(defTab)) then
    LogInstance("("..fPref..") Missing table definition",sTable); return false end
  local cmdTab = makTab:GetCommand(); if(not IsHere(cmdTab)) then
    LogInstance("("..fPref..") Missing table command",sTable); return false end
  local fName, sMoDB = (GetOpVar("DIRPATH_BAS")..GetOpVar("DIRPATH_DSV")), GetOpVar("MODE_DATABASE")
        fName = fName..fPref..defTab.Name..".txt"
  local F = fileOpen(fName, "rb", "DATA"); if(not F) then
    LogInstance("("..fPref..") fileOpen("..fName..") failed",sTable); return false end
  local symOff, sDelim = GetOpVar("OPSYM_DISABLE"), tostring(sDelim or "\t"):sub(1,1)
  local sLine, isEOF, nLen = "", false, defTab.Name:len()
  if(sMoDB == "SQL") then sqlQuery(cmdTab.Begin)
    LogInstance("("..fPref..") Begin",sTable) end
  while(not isEOF) do sLine, isEOF = GetStringFile(F)
    if((not IsBlank(sLine)) and (sLine:sub(1,1) ~= symOff)) then
      if(sLine:sub(1,nLen) == defTab.Name) then
        local tData = sDelim:Explode(sLine:sub(nLen+2,-1))
        for iCnt = 1, defTab.Size do tData[iCnt] = GetStrip(tData[iCnt]) end
        if(bComm) then makTab:Record(tData) end
      end
    end
  end; F:Close()
  if(sMoDB == "SQL") then sqlQuery(cmdTab.Commit)
    LogInstance("("..fPref..") Commit",sTable)
  end; LogInstance("("..fPref..") Success",sTable); return true
end

--[[
 * This function synchronizes extended database records loaded by the server and client
 * It is used by addon creators when they want to add extra pieces
 * sTable > The table you want to sync
 * tData  > Data you want to add as extended records for the given table
 * bRepl  > If set to /true/ replaces persisting records with the addon
 * sPref  > The external data prefix to be used
 * sDelim > What delimiter is the server using
]]--
function SynchronizeDSV(sTable, tData, bRepl, sPref, sDelim)
  local fPref = tostring(sPref or GetInstPref()); if(not IsString(sTable)) then
    LogInstance("("..fPref..") Table "..GetReport(sTable).." not string"); return false end
  local makTab = GetBuilderNick(sTable); if(not IsHere(makTab)) then
    LogInstance("("..fPref.."@"..sTable..") Missing table builder"); return false end
  local defTab, iD = makTab:GetDefinition(), makTab:GetColumnID("LINEID")
  local fName, sDelim = GetOpVar("DIRPATH_BAS"), tostring(sDelim or "\t"):sub(1,1)
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  fName = fName..GetOpVar("DIRPATH_DSV")
  if(not fileExists(fName,"DATA")) then fileCreateDir(fName) end
  fName = fName..fPref..defTab.Name..".txt"
  local sFunc, sMoDB = "SynchronizeDSV", GetOpVar("MODE_DATABASE")
  local I, fData, symOff = fileOpen(fName, "rb", "DATA"), {}, GetOpVar("OPSYM_DISABLE")
  if(I) then local sLine, isEOF = "", false
    while(not isEOF) do sLine, isEOF = GetStringFile(I)
      if((not IsBlank(sLine)) and (sLine:sub(1,1) ~= symOff)) then
        local tLine = sDelim:Explode(sLine)
        if(tLine[1] == defTab.Name) then local nL = #tLine
          for iCnt = 2, nL do local vV, iL = tLine[iCnt], (iCnt-1); vV = GetStrip(vV)
            vM = makTab:Match(vV,iL,false,"",true,true); if(not IsHere(vV)) then
            O:Flush(); O:Close(); LogInstance("("..fPref.."@"..sTable
              ..") Read matching failed <"..tostring(vV).."> to <"
                ..tostring(iL).." # "..defTab[iL][1]..">"); return false end
            tLine[iCnt] = vM -- Register the matched value
          end -- Allocate table memory for the matched key
          local vK = tLine[2]; if(not fData[vK]) then fData[vK] = {Size = 0} end
          -- Where the line ID must be read from. Validate the value
          local fRec, vID, nID = fData[vK], tLine[iD+1]; nID = (tonumber(vID) or 0)
          if((fRec.Size < 0) or (nID <= fRec.Size) or ((nID - fRec.Size) ~= 1)) then
            I:Close(); LogInstance("("..fPref.."@"..sTable..") Read line ID #"..
              tostring(vID).." desynchronized <"..tostring(vK)..">"); return false end
          fRec.Size = nID; fRec[nID] = {}; local fRow = fRec[nID] -- Regster the new line
          for iCnt = 3, nL do fRow[iCnt-2] = tLine[iCnt] end -- Transfer the extracted data
        else I:Close()
          LogInstance("("..fPref.."@"..sTable..") Read table name mismatch"); return false end
      end
    end; I:Close()
  else LogInstance("("..fPref.."@"..sTable..") Creating file <"..fName..">") end
  for key, rec in pairs(tData) do -- Check the given table and match the key
    local vK = makTab:Match(key,1,false,"",true,true); if(not IsHere(vK)) then
      O:Flush(); O:Close(); LogInstance("("..fPref.."@"..sTable.."@"
        ..tostring(key)..") Sync matching PK failed"); return false end
    local sKey, sVK = tostring(key), tostring(vK); if(sKey ~= sVK) then
      LogInstance("("..fPref.."@"..sTable..") Sync key mismatch ["..sKey.."]["..sVK.."]");
      tData[vK] = tData[key]; tData[key] = nil -- Override the key casing after matching
    end local tRec = tData[vK] -- Create loval reference to the record of the matched key
    for iCnt = 1, #tRec do -- Where the line ID must be read from skip the key itself
      local tRow, vID, nID = tRec[iCnt]; vID = tRow[iD-1]
      nID = (tonumber(vID) or 0); if(iCnt ~= nID) then -- Validate the line ID
          LogInstance("("..fPref.."@"..sTable.."@"..tostring(key)..") Sync point ID #"..
            tostring(vID).." desynchronized <"..tostring(key)..">"); return false end
      for nCnt = 1, #tRow do -- Do a value matching without quotes
        local vM = makTab:Match(tRow[nCnt],nCnt+1,false,"",true,true); if(not IsHere(vM)) then
          LogInstance("("..fPref.."@"..sTable.."@"..tostring(key)..") Sync matching failed <"
            ..tostring(tRow[nCnt]).."> to <"..tostring(nCnt+1).." # "..defTab[nCnt+1][1]..">"); return false
        end; tRow[nCnt] = vM -- Store the matched value in the same place as the original
      end
    end -- Register the read line to the output file
    if(bRepl) then -- Replace the data when enabled overwrites the file data
      if(tData[vK]) then -- Update the file with the new data
        fData[vK] = tRec; fData[vK].Size = #tRec end
    else --[[ Do not modify fData ]] end
  end
  local tSort = Sort(tableGetKeys(fData)); if(not tSort) then
    LogInstance("("..fPref.."@"..sTable..") Sorting failed"); return false end
  local O = fileOpen(fName, "wb" ,"DATA"); if(not O) then
    LogInstance("("..fPref.."@"..sTable..") Write fileOpen("..fName..") failed"); return false end
  O:Write("# "..sFunc..":("..fPref.."@"..sTable..") "..GetDate().." [ "..sMoDB.." ]\n")
  O:Write("# Data settings:("..makTab:GetColumnList(sDelim)..")\n")
  for iKey = 1, tSort.Size do local key = tSort[iKey].Val
    local vK = makTab:Match(key,1,true,"\"",true); if(not IsHere(vK)) then
      O:Flush(); O:Close(); LogInstance("("..fPref.."@"..sTable.."@"..tostring(key)..") Write matching PK failed"); return false end
    local fRec, sCash, sData = fData[key], defTab.Name..sDelim..vK, ""
    for iCnt = 1, fRec.Size do local fRow = fRec[iCnt]
      for nCnt = 1, #fRow do
        local vM = makTab:Match(fRow[nCnt],nCnt+1,true,"\"",true); if(not IsHere(vM)) then
          O:Flush(); O:Close(); LogInstance("("..fPref.."@"..sTable.."@"..tostring(key)..") Write matching failed <"
            ..tostring(fRow[nCnt]).."> to <"..tostring(nCnt+1).." # "..defTab[nCnt+1][1]..">"); return false
        end; sData = sData..sDelim..tostring(vM)
      end; O:Write(sCash..sData.."\n"); sData = ""
    end
  end O:Flush(); O:Close()
  LogInstance("("..fPref.."@"..sTable..") Success"); return true
end

function TranslateDSV(sTable, sPref, sDelim)
  local fPref = tostring(sPref or GetInstPref()); if(not IsString(sTable)) then
    LogInstance("("..fPref..") Table "..GetReport(sTable).." not string"); return false end
  local makTab = GetBuilderNick(sTable); if(not IsHere(makTab)) then
    LogInstance("("..fPref..") Missing table builder",sTable); return false end
  local defTab, sFunc, sMoDB = makTab:GetDefinition(), "TranslateDSV", GetOpVar("MODE_DATABASE")
  local sNdsv, sNins = GetOpVar("DIRPATH_BAS"), GetOpVar("DIRPATH_BAS")
  if(not fileExists(sNins,"DATA")) then fileCreateDir(sNins) end
  sNdsv, sNins = sNdsv..GetOpVar("DIRPATH_DSV"), sNins..GetOpVar("DIRPATH_INS")
  if(not fileExists(sNins,"DATA")) then fileCreateDir(sNins) end
  sNdsv, sNins = sNdsv..fPref..defTab.Name..".txt", sNins..fPref..defTab.Name..".txt"
  local sDelim = tostring(sDelim or "\t"):sub(1,1)
  local D = fileOpen(sNdsv, "rb", "DATA"); if(not D) then
    LogInstance("("..fPref..") fileOpen("..sNdsv..") failed",sTable); return false end
  local I = fileOpen(sNins, "wb", "DATA"); if(not I) then
    LogInstance("("..fPref..") fileOpen("..sNins..") failed",sTable); return false end
  I:Write("# "..sFunc..":("..fPref.."@"..sTable..") "..GetDate().." [ "..sMoDB.." ]\n")
  I:Write("# Data settings:("..makTab:GetColumnList(sDelim)..")\n")
  local sLine, isEOF, symOff = "", false, GetOpVar("OPSYM_DISABLE")
  local sFr, sBk = sTable:upper()..":Record({", "})\n"
  while(not isEOF) do sLine, isEOF = GetStringFile(D)
    if((not IsBlank(sLine)) and (sLine:sub(1,1) ~= symOff)) then
      sLine = sLine:gsub(defTab.Name,""):Trim()
      local tBoo, sCat = sDelim:Explode(sLine), ""
      for nCnt = 1, #tBoo do
        local vMatch = makTab:Match(GetStrip(tBoo[nCnt]),nCnt,true,"\"",true)
        if(not IsHere(vMatch)) then D:Close(); I:Flush(); I:Close()
          LogInstance("("..fPref..") Given matching failed <"
            ..tostring(tBoo[nCnt]).."> to <"..tostring(nCnt).." # "
              ..defTab[nCnt][1]..">",sTable); return false end
        sCat = sCat..", "..tostring(vMatch)
      end; I:Write(sFr..sCat:sub(3,-1)..sBk)
    end
  end; D:Close(); I:Flush(); I:Close()
  LogInstance("("..fPref..") Success",sTable); return true
end

--[[
 * This function adds the desired database prefix to the auto-include list
 * It is used by addon creators when they want automatically include pieces
 * sProg  > The program which registered the DSV
 * sPref  > The external data prefix to be added
 * sDelim > The delimiter to be used for processing
 * bSkip  > Skip addition for the DSV prefix if exists
]]--
function RegisterDSV(sProg, sPref, sDelim, bSkip)
  local sPref = tostring(sPref or GetInstPref()); if(IsBlank(sPref)) then
    LogInstance("("..sPref..") Prefix empty"); return false end
  if(CLIENT and gameSinglePlayer()) then
    LogInstance("("..sPref..") Single client"); return true end
  local sBas = GetOpVar("DIRPATH_BAS")
  if(not fileExists(sBas,"DATA")) then fileCreateDir(sBas) end
  local lbNam = GetOpVar("NAME_LIBRARY")
  local fName = (sBas..lbNam.."_dsv.txt")
  local sMiss, sDelim = GetOpVar("MISS_NOAV"), tostring(sDelim or "\t"):sub(1,1)
  if(bSkip) then
    local symOff = GetOpVar("OPSYM_DISABLE")
    local fPool, isEOF, isAct = {}, false, true
    local F, sLine = fileOpen(fName, "rb" ,"DATA"), ""
    if(not F) then LogInstance("("..sPref..") fileOpen("..fName..") read failed"); return false end
    while(not isEOF) do sLine, isEOF = GetStringFile(F)
      if(not IsBlank(sLine)) then
        if(sLine:sub(1,1) == symOff) then
          isAct, sLine = false, sLine:sub(2,-1) else isAct = true end
        local tab = sDelim:Explode(sLine)
        local prf, src = tab[1]:Trim(), tab[2]:Trim()
        local inf = fPool[prf]; if(not inf) then
          fPool[prf] = {Cnt = 0}; inf = fPool[prf] end
        inf.Cnt = inf.Cnt + 1; inf[inf.Cnt] = {src, isAct}
      end
    end; F:Close()
    if(fPool[sPref]) then local inf = fPool[sPref]
      for ID = 1, inf.Cnt do local tab = inf[ID]
        LogInstance("("..sPref..") "..(tab[2] and "On " or "Off").." <"..tab[1]..">") end
      LogInstance("("..sPref..") Skip <"..sProg..">"); return true
    end
  end
  local F = fileOpen(fName, "ab" ,"DATA"); if(not F) then
    LogInstance("("..sPref..") fileOpen("..fName..") append failed"); return false end
  F:Write(sPref..sDelim..tostring(sProg or sMiss).."\n"); F:Flush(); F:Close()
  LogInstance("("..sPref..") Register"); return true
end

--[[
 * This function cycles all the lines made via @RegisterDSV(sPref, sDelim, sProg)
 * or manually added and loads all the content bound by the prefix line read
 * to the database. It is used by addon creators when they want automatically
 * include and auto-process their custom pieces. The addon creator must
 * check if the PIECES file is created before calling this function
 * sDelim > The delimiter to be used while processing the DSV list
]]--
function ProcessDSV(sDelim)
  local lbNam = GetOpVar("NAME_LIBRARY")
  local fName = GetOpVar("DIRPATH_BAS")..lbNam.."_dsv.txt"
  local F = fileOpen(fName, "rb" ,"DATA")
  if(not F) then LogInstance("fileOpen("..fName..") failed"); return false end
  local sLine, isEOF, symOff = "", false, GetOpVar("OPSYM_DISABLE")
  local sNt, tProc = GetOpVar("TOOLNAME_PU"), {}
  local sDelim = tostring(sDelim or "\t"):sub(1,1)
  local sDv = GetOpVar("DIRPATH_BAS")..GetOpVar("DIRPATH_DSV")
  while(not isEOF) do sLine, isEOF = GetStringFile(F)
    if(not IsBlank(sLine)) then
      if(sLine:sub(1,1) ~= symOff) then
        local tInf = sDelim:Explode(sLine)
        local fPrf = GetStrip(tostring(tInf[1] or ""):Trim())
        local fSrc = GetStrip(tostring(tInf[2] or ""):Trim())
        if(not IsBlank(fPrf)) then -- Is there something
          if(not tProc[fPrf]) then
            tProc[fPrf] = {Cnt = 1, [1] = {Prog = fSrc, File = (sDv..fPrf..sNt)}}
          else -- Prefix is processed already
            local tStore = tProc[fPrf]
            tStore.Cnt = tStore.Cnt + 1 -- Store the count of the repeated prefixes
            tStore[tStore.Cnt] = {Prog = fSrc, File = (sDv..fPrf..sNt)}
          end -- What user puts there is a problem of his own
        end -- If the line is disabled/comment
      else LogInstance("Skipped <"..sLine..">") end
    end
  end; F:Close()
  for prf, tab in pairs(tProc) do
    if(tab.Cnt > 1) then
      LogInstance("Prefix <"..prf.."> clones #"..tostring(tab.Cnt).." @"..fName)
      for i = 1, tab.Cnt do
        LogInstance("Prefix <"..prf.."> "..tab[i].Prog)
      end
    else local dir = tab[tab.Cnt].File
      if(CLIENT) then
        if(fileExists(dir.."CATEGORY.txt", "DATA")) then
          if(not ImportCategory(3, prf)) then
            LogInstance("("..prf..") Failed CATEGORY") end
        end
      end
      for iD = 1, #libQTable do local sNick = libQTable[iD]
        if(fileExists(dir..sNick..".txt", "DATA")) then
          if(not ImportDSV(sNick, true, prf)) then
            LogInstance("("..prf..") Failed "..sNick) end
        else LogInstance("("..prf..") Missing "..sNick) end
      end
    end
  end; LogInstance("Success"); return true
end

function ApplySpawnFlat(oEnt,stSpawn,vNorm)
  if(not (oEnt and oEnt:IsValid())) then
    LogInstance("Entity invalid <"..tostring(oEnt)..">"); return false end
  if(not (stSpawn and stSpawn.HRec)) then
    LogInstance("Holder missing"); return false end
  local hPOA = stSpawn.HRec.Offs
  if(hPOA) then
    if(hPOA.A[csD]) then SetAnglePYR(stSpawn.HAng) else SetAngle(stSpawn.HAng,hPOA.A) end
    local vOBB = oEnt:OBBMins()
          SubVector(vOBB,hPOA.O) -- Mass center
          vOBB:Rotate(stSpawn.HAng)
          DecomposeByAngle(vOBB,GetOpVar("ANG_ZERO"))
    local zOffs = mathAbs(vOBB[cvZ])
    SetVector(stSpawn.HOrg, hPOA.O) -- Apply negative rake to the angle to flatten it
    stSpawn.SAng:RotateAroundAxis(stSpawn.DAng:Right(), -stSpawn.HRec.Rake)
    stSpawn.SPos:Set(stSpawn.HOrg); NegVector(stSpawn.SPos)
    stSpawn.SPos:Rotate(stSpawn.SAng) -- Make world space mass-center vector
    stSpawn.HOrg:Set(stSpawn.OPos)    -- Calculate mass-center position vector
    stSpawn.HOrg:Add(vNorm * zOffs)
    stSpawn.HOrg:Add(stSpawn.F * stSpawn.PNxt[cvX])
    stSpawn.HOrg:Add(stSpawn.R * stSpawn.PNxt[cvY])
    stSpawn.HOrg:Add(stSpawn.U * stSpawn.PNxt[cvZ])
    stSpawn.SPos:Add(stSpawn.HOrg) -- Add mass-center position origin for spawn
  end; return true
end

----------------------------- SNAPPING ------------------------------

local function GetSurfaceAngle(oPly, vNorm)
  local vF = oPly:GetAimVector()
  local vR = vF:Cross(vNorm); vF:Set(vNorm:Cross(vR))
  return vF:AngleEx(vNorm)
end

--[[
 * This function calculates the cross product normal angle of
 * a player by a given trace. If the trace is missing it takes player trace
 * It has options for snap to surface and yaw snap
 * oPly > The player we need the normal angle from
 * soTr > A trace structure if nil, it takes oPly's
 * bSnp > Snap to the trace surface flag
 * nSnp > Yaw snap amount
]]--
function GetNormalAngle(oPly, soTr, bSnp, nSnp)
  local aAng, nAsn = Angle(), (tonumber(nSnp) or 0); if(not IsPlayer(oPly)) then
    LogInstance("No player <"..tostring(oPly)..">", aAng); return aAng end
  if(bSnp) then local stTr = soTr -- Snap to the trace surface
    if(not (stTr and stTr.Hit)) then stTr = GetCacheTrace(oPly)
      if(not (stTr and stTr.Hit)) then return aAng end
    end; aAng:Set(GetSurfaceAngle(oPly, stTr.HitNormal))
  else aAng[caY] = oPly:GetAimVector():Angle()[caY] end
  if(nAsn and (nAsn > 0) and (nAsn <= GetOpVar("MAX_ROTATION"))) then
    -- Snap player viewing rotation angle for using walls and ceiling
    aAng:SnapTo("pitch", nAsn):SnapTo("yaw", nAsn):SnapTo("roll", nAsn)
  end; return aAng
end

--[[
 * This function is the backbone of the tool for Trace.Normal
 * Calculates SPos, SAng based on the DB inserts and input parameters
 * oPly          --> The player who is making the spawn
 * ucsPos,ucsAng --> Origin position and angle of the snapping
 * hdModel       --> Holder's piece model
 * enOrAngTr     --> Position offset comes from trace origin angle F,R,U
 * ucsPos(X,Y,Z) --> Offset position
 * ucsAng(P,Y,R) --> Offset angle
]]--
function GetNormalSpawn(oPly,ucsPos,ucsAng,hdModel,hdPivot,enOrAngTr,ucsPosX,ucsPosY,ucsPosZ,ucsAngP,ucsAngY,ucsAngR)
  local hdRec = CacheQueryPiece(hdModel)
  if(not IsExistent(hdRec)) then
    LogInstance("Holder is not a piece <"..tostring(hdModel)..">"); return nil end
  if(not (IsExistent(hdRec.Kept) and (hdRec.Kept == 1))) then
    LogInstance("Line count <"..tostring(hdRec.Kept).."> mismatch for <"..tostring(hdModel)..">"); return nil end
  local hdPOA = hdRec.Offs; if(not IsExistent(hdPOA)) then
    LogInstance("Offsets missing <"..tostring(hdModel)..">"); return nil end
  local stSpawn = CacheSpawnPly(oPly); if(not IsExistent(stSpawn)) then
    LogInstance("Cannot obtain spawn data"); return nil end
        stSpawn.HRec = hdRec
  if(ucsPos) then SetVector(stSpawn.OPos,ucsPos); SetVector(stSpawn.TOrg, ucsPos) end
  if(ucsAng) then SetVector(stSpawn.OAng,ucsAng); SetVector(stSpawn.TAng, ucsAng) end
  SetAnglePYR (stSpawn.ANxt, (tonumber(ucsAngP) or 0), -(tonumber(ucsAngY) or 0), (tonumber(ucsAngR) or 0))
  SetVectorXYZ(stSpawn.PNxt, (tonumber(ucsPosX) or 0),  (tonumber(ucsPosY) or 0), (tonumber(ucsPosZ) or 0))
  -- Calculate origin directions
  stSpawn.U:Set(stSpawn.OAng:Up())
  stSpawn.R:Set(stSpawn.OAng:Right())
  stSpawn.OAng:RotateAroundAxis(stSpawn.R, stSpawn.ANxt[caP])
  stSpawn.OAng:RotateAroundAxis(stSpawn.U, stSpawn.ANxt[caY])
  stSpawn.F:Set(stSpawn.OAng:Forward())
  stSpawn.OAng:RotateAroundAxis(stSpawn.F, stSpawn.ANxt[caR])
  stSpawn.U:Set(stSpawn.OAng:Up())
  stSpawn.R:Set(stSpawn.OAng:Right())
  -- Read holder data
  SetVector(stSpawn.HPnt, hdPOA.P) -- Offset meshing point
  SetVector(stSpawn.HOrg, hdPOA.O) -- Mass center origin
  if(hdPOA.A[csD]) then SetAnglePYR(stSpawn.HAng) else SetAngle(stSpawn.HAng,hdPOA.A) end
  -- Local vector from the back meshing point to the mass-center
  stSpawn.DPos:Set(stSpawn.HPnt)
  NegVector(stSpawn.DPos, false, true, true)
  -- Local angle for the vector decomposition
  SetAngle(stSpawn.DAng, GetOpVar("ANG_ZERO"))
  stSpawn.DAng:RotateAroundAxis(stSpawn.DAng:Right(), -hdRec.Rake)
  DecomposeByAngle(stSpawn.DPos,stSpawn.DAng);
  -- Calculate domain angle to apply holder pivot and rotation
  stSpawn.DAng:Set(stSpawn.OAng)
  stSpawn.DAng:RotateAroundAxis(stSpawn.R,hdRec.Rake)
  stSpawn.DAng:RotateAroundAxis(stSpawn.DAng:Up(),(tonumber(hdPivot) or 0))
  -- Calculate spawn angle
  stSpawn.SAng:Set(stSpawn.DAng); NegAngle(stSpawn.HAng)
  stSpawn.SAng:RotateAroundAxis(stSpawn.DAng:Up(),stSpawn.HAng[caY] * hdPOA.A[csB])
  stSpawn.SAng:RotateAroundAxis(stSpawn.DAng:Right(),stSpawn.HAng[caP] * hdPOA.A[csA])
  stSpawn.SAng:RotateAroundAxis(stSpawn.DAng:Forward(),stSpawn.HAng[caR] * hdPOA.A[csC])
  -- Make sure saving the mass-center world offset vector in the spawn
  stSpawn.SPos:Set(stSpawn.HOrg) ; NegVector(stSpawn.SPos)
  stSpawn.SPos:Rotate(stSpawn.SAng) -- World space vector mass-center to position
  -- Calculate the location of the mass-center as a position vector
  stSpawn.HOrg:Set(stSpawn.OPos)
  -- Add the decomposed mass center origin
  stSpawn.HOrg:Add(stSpawn.DPos[cvX] * stSpawn.F)
  stSpawn.HOrg:Add(stSpawn.DPos[cvY] * stSpawn.R)
  stSpawn.HOrg:Add(stSpawn.DPos[cvZ] * stSpawn.U)
  if(enOrAngTr) then -- Take offsets in consideration
    stSpawn.F:Set(stSpawn.TAng:Forward())
    stSpawn.R:Set(stSpawn.TAng:Right())
    stSpawn.U:Set(stSpawn.TAng:Up())
  end -- Deviate the mass-center location according to the user offsets
  stSpawn.HOrg:Add(stSpawn.PNxt[cvX] * stSpawn.F)
  stSpawn.HOrg:Add(stSpawn.PNxt[cvY] * stSpawn.R)
  stSpawn.HOrg:Add(stSpawn.PNxt[cvZ] * stSpawn.U)
  -- Calculate the mass-center location as a position vector based on the database
  stSpawn.SPos:Add(stSpawn.HOrg) -- Add the mass-center
  return stSpawn
end

--[[
 * This function is the backbone of the tool for Trace.Entity
 * Calculates SPos, SAng based on the DB inserts and input parameters
 * From the position and angle of the entity, the mass-center is calculated
 * and used as an origin to build the spawn parameters,
 * oPly          --> The player who makes the spawn
 * trEnt         --> Trace.Entity
 * trPivot       --> Trace  pivot rotation
 * hdPivot       --> Holder pivot rotation
 * hdModel       --> The holder model
 * enIgnTyp      --> Ignores the gearbox type when enabled
 * enOrAngTr     --> Position offset comes from trace origin angle F,R,U
 * ucsPos(X,Y,Z) --> Offset position
 * ucsAng(P,Y,R) --> Offset angle
]]--
function GetEntitySpawn(oPly,trEnt,trPivot,hdPivot,hdModel,enIgnTyp,enOrAngTr,
                        ucsPosX,ucsPosY,ucsPosZ,ucsAngP,ucsAngY,ucsAngR)
  if(not (trEnt and trEnt:IsValid())) then
    LogInstance("Entity origin invalid"); return nil end
  local trRec, hdRec = CacheQueryPiece(trEnt:GetModel()), CacheQueryPiece(hdModel)
  if(not IsExistent(trRec)) then
    LogInstance("Trace not a piece <"..trEnt:GetModel()..">"); return nil end
  if(not IsExistent(hdRec)) then
    LogInstance("Holder not a piece <"..hdModel..">"); return nil end
  if(not (IsExistent(trRec.Type) and IsString(trRec.Type))) then
    LogInstance("Trace not grouped <"..tostring(trRec.Type)..">"); return nil end
  if(not (IsExistent(hdRec.Type) and IsString(hdRec.Type))) then
     LogInstance("Holder not grouped <"..tostring(hdRec.Type)..">"); return nil end
  if((not enIgnTyp) and trRec.Type ~= hdRec.Type ) then
    LogInstance("Types different <"..tostring(trRec.Type)..","..tostring(hdRec.Type)..">"); return nil end
  local trPOA = trRec.Offs; if(not IsExistent(trPOA)) then
    LogInstance("Offsets missing <"..trRec.Slot..">"); return nil end
  local trPos  , trAng    = trEnt:GetPos(), trEnt:GetAngles()
  local trPivot, hdPivot  = (tonumber(trPivot) or  0), (tonumber(hdPivot ) or 0)
  local hdModel, enIgnTyp =  tostring(hdModel  or ""), (tonumber(enIgnTyp) or 0)
  local stSpawn = CacheSpawnPly(oPly); if(not IsExistent(stSpawn)) then
    LogInstance("Cannot obtain spawn data"); return nil end
  stSpawn.HRec, stSpawn.TRec = hdRec, trRec  -- Save records
  SetVector(stSpawn.TPnt,trPOA.P)            -- Store data in objects
  SetVector(stSpawn.TOrg,trPOA.O)
  SetAngle (stSpawn.TAng,trPOA.A) -- Custom angle and trace position
  stSpawn.TOrg:Rotate(trAng); stSpawn.TOrg:Add(trPos)        -- Trace mass-center world
  stSpawn.TAng:Set(trEnt:LocalToWorldAngles(stSpawn.TAng))   -- Initial coordinate system
  stSpawn.TAng:RotateAroundAxis(stSpawn.TAng:Up(),-trPivot)  -- Apply the pivot rotation for trace
  stSpawn.TPnt:Rotate(stSpawn.TAng) -- Non-raked angle must be used for offset origin (yellow)
  -- Calculate the origin based on the center
  stSpawn.OPos:Set(stSpawn.TPnt); stSpawn.OPos:Add(stSpawn.TOrg)
  stSpawn.OAng:Set(stSpawn.TAng); stSpawn.OAng:RotateAroundAxis(stSpawn.TAng:Right(),trRec.Rake)
  return GetNormalSpawn(oPly,nil,nil,hdModel,hdPivot,enOrAngTr,ucsPosX,ucsPosY,ucsPosZ,ucsAngP,ucsAngY,ucsAngR)
end

function AttachAdditions(ePiece)
  if(not (ePiece and ePiece:IsValid())) then
    LogInstance("Piece invalid"); return false end
  local eAng, ePos, eMod = ePiece:GetAngles(), ePiece:GetPos(), ePiece:GetModel()
  local stAddit = CacheQueryAdditions(eMod); if(not IsHere(stAddit)) then
    LogInstance("Model <"..eMod.."> has no additions"); return true end
  LogInstance("Called for model <"..eMod..">")
  local makTab = libQTable["ADDITIONS"]; if(not IsHere(makTab)) then
    LogInstance("Missing table definition"); return nil end
  local defTab, iCnt = makTab:GetDefinition(), 1
  while(stAddit[iCnt]) do local arRec = stAddit[iCnt]; LogInstance("Addition ["..iCnt.."]")
    local eAddit = entsCreate(arRec[defTab[3][1]])
    if(eAddit and eAddit:IsValid()) then
      LogInstance("Class <"..arRec[defTab[3][1]]..">")
      local adMod = tostring(arRec[defTab[2][1]])
      if(not fileExists(adMod, "GAME")) then
        LogInstance("Missing attachment file "..adMod); return false end
      if(not utilIsValidModel(adMod)) then
        LogInstance("Invalid attachment model "..adMod); return false end
      eAddit:SetModel(adMod) LogInstance("SetModel("..adMod..")")
      local ofPos = arRec[defTab[5][1]]; if(not IsString(ofPos)) then
        LogInstance("Position "..GetReport(ofPos).." not string"); return false end
      if(ofPos and not (IsNull(ofPos) or IsBlank(ofPos))) then
        local vpAdd, arPOA = Vector(), DecodePOA(ofPos)
        SetVectorXYZ(vpAdd, arPOA[1], arPOA[2], arPOA[3])
        vpAdd:Set(ePiece:LocalToWorld(vpAdd)); eAddit:SetPos(vpAdd); LogInstance("SetPos(DB)")
      else eAddit:SetPos(ePos); LogInstance("SetPos(ePos)") end
      local ofAng = arRec[defTab[6][1]]; if(not IsString(ofAng)) then
        LogInstance("Angle "..GetReport(ofAng).." not string"); return false end
      if(ofAng and not (IsNull(ofAng) or IsBlank(ofAng))) then
        local apAdd, arPOA = Angle(), DecodePOA(ofAng)
        SetAnglePYR(apAdd, arPOA[1], arPOA[2], arPOA[3])
        apAdd:Set(ePiece:LocalToWorldAngles(apAdd))
        eAddit:SetAngles(apAdd); LogInstance("SetAngles(DB)")
      else eAddit:SetAngles(eAng); LogInstance("SetAngles(eAng)") end
      local mvTyp = (tonumber(arRec[defTab[7][1]]) or -1)
      if(mvTyp >= 0) then eAddit:SetMoveType(mvTyp)
        LogInstance("SetMoveType("..mvTyp..")") end
      local phInt = (tonumber(arRec[defTab[8][1]]) or -1)
      if(phInt >= 0) then eAddit:PhysicsInit(phInt)
        LogInstance("PhysicsInit("..phInt..")") end
      local drShd = (tonumber(arRec[defTab[9][1]]) or 0)
      if(drShd ~= 0) then drShd = (drShd > 0)
        eAddit:DrawShadow(drShd); LogInstance("DrawShadow("..tostring(drShd)..")") end
      eAddit:SetParent(ePiece); LogInstance("SetParent(ePiece)")
      eAddit:Spawn(); LogInstance("Spawn()")
      phAddit = eAddit:GetPhysicsObject()
      if(phAddit and phAddit:IsValid()) then
        local enMot = (tonumber(arRec[defTab[10][1]]) or 0)
        if(enMot ~= 0) then enMot = (enMot > 0); phAddit:EnableMotion(enMot)
          LogInstance("EnableMotion("..tostring(enMot)..")") end
        local nbSlp = (tonumber(arRec[defTab[11][1]]) or 0)
        if(nbSlp > 0) then phAddit:Sleep(); LogInstance("Sleep()") end
      end
      eAddit:Activate(); LogInstance("Activate()")
      ePiece:DeleteOnRemove(eAddit); LogInstance("DeleteOnRemove(eAddit)")
      local nbSld = (tonumber(arRec[defTab[12][1]]) or -1)
      if(nbSld >= 0) then eAddit:SetSolid(nbSld)
        LogInstance("SetSolid("..tostring(nbSld)..")") end
    else local sM, sT, sN = defTab[1][1], defTab[2][1], defTab[3][1]
      local sMsg = "\n "..sM.." "..stAddit[iCnt][sM]..
                   "\n "..sT.." "..stAddit[iCnt][sT]..
                   "\n "..sN.." "..stAddit[iCnt][sN]
      LogInstance(sMsg); return false
    end; iCnt = iCnt + 1
  end; LogInstance("Success"); return true
end

local function GetEntityOrTrace(oEnt)
  if(oEnt and oEnt:IsValid()) then return oEnt end
  local oPly = LocalPlayer(); if(not IsPlayer(oPly)) then
    LogInstance("Player "..GetReport(oPly).." missing"); return nil end
  local stTrace = GetCacheTrace(oPly); if(not IsHere(stTrace)) then
    LogInstance("Trace missing"); return nil end
  if(not stTrace.Hit) then -- Boolean
    LogInstance("Trace not hit"); return nil end
  if(stTrace.HitWorld) then -- Boolean
    LogInstance("Trace hit world"); return nil end
  local trEnt = stTrace.Entity; if(not (trEnt and trEnt:IsValid())) then
    LogInstance("Trace entity invalid"); return nil end
  LogInstance("Success "..tostring(trEnt)); return trEnt
end

function GetPropSkin(oEnt)
  local skEnt = GetEntityOrTrace(oEnt); if(not IsHere(skEnt)) then
    LogInstance("Failed to gather entity"); return "" end
  if(IsOther(skEnt)) then
    LogInstance("Entity other type"); return "" end
  local Skin = tonumber(skEnt:GetSkin()); if(not IsHere(Skin)) then
    LogInstance("Skin number mismatch"); return "" end
  LogInstance("Success "..tostring(skEn)); return tostring(Skin)
end

function GetPropBodyGroup(oEnt)
  local bgEnt = GetEntityOrTrace(oEnt); if(not IsHere(bgEnt)) then
    LogInstance("Failed to gather entity"); return "" end
  if(IsOther(bgEnt)) then
    LogInstance("Entity other type"); return "" end
  local BGs = bgEnt:GetBodyGroups(); if(not (BGs and BGs[1])) then
    LogInstance("Bodygroup table empty"); return "" end
  local sRez, iCnt, symSep = "", 1, GetOpVar("OPSYM_SEPARATOR")
  while(BGs[iCnt]) do local sD = bgEnt:GetBodygroup(BGs[iCnt].id)
    sRez = sRez..symSep..tostring(sD or 0); iCnt = iCnt + 1
  end; sRez = sRez:sub(2,-1); LogTable(BGs,"BodyGroup")
  LogInstance("Success <"..sRez..">"); return sRez
end

function AttachBodyGroups(ePiece,sBgID)
  if(not (ePiece and ePiece:IsValid())) then
    LogInstance("Base entity invalid"); return false end
  local sBgID = tostring(sBgID or ""); LogInstance("<"..sBgID..">")
  local iCnt, BGs = 1, ePiece:GetBodyGroups()
  local IDs = GetOpVar("OPSYM_SEPARATOR"):Explode(sBgID)
  while(BGs[iCnt] and IDs[iCnt]) do local itrBG = BGs[iCnt]
    local maxID = (ePiece:GetBodygroupCount(itrBG.id) - 1)
    local itrID = mathClamp(mathFloor(tonumber(IDs[iCnt]) or 0),0,maxID)
    LogInstance("SetBodygroup("..itrBG.id..","..itrID..") ["..maxID.."]")
    ePiece:SetBodygroup(itrBG.id,itrID); iCnt = iCnt + 1
  end; LogInstance("Success"); return true
end

function SetPosBound(ePiece,vPos,oPly,sMode)
  if(not (ePiece and ePiece:IsValid())) then
    LogInstance("Entity invalid"); return false end
  if(not IsHere(vPos)) then
    LogInstance("Position missing"); return false end
  if(not IsPlayer(oPly)) then
    LogInstance("Player <"..tostring(oPly)"> invalid"); return false end
  local sMode = tostring(sMode or "LOG") -- Error mode is "LOG" by default
  if(sMode == "OFF") then ePiece:SetPos(vPos)
    LogInstance("("..sMode..") Skip"); return true end
  if(utilIsInWorld(vPos)) then ePiece:SetPos(vPos) else ePiece:Remove()
    if(sMode == "HINT" or sMode == "GENERIC" or sMode == "ERROR") then
      Notify(oPly,"Position out of map bounds!",sMode) end
    LogInstance("("..sMode..") Position ["..tostring(vPos).."] out of map bounds"); return false
  end; LogInstance("("..sMode..") Success"); return true
end

function MakePiece(pPly,sModel,vPos,aAng,nMass,sBgSkIDs,clColor,sMode)
  if(CLIENT) then LogInstance("Working on client"); return nil end
  if(not IsPlayer(pPly)) then -- If not player we cannot register limit
    LogInstance("Player missing <"..tostring(pPly)..">"); return nil end
  local sLimit, sClass = GetOpVar("CVAR_LIMITNAME"), GetOpVar("ENTITY_DEFCLASS")
  if(not pPly:CheckLimit(sLimit)) then -- Check internal limit
    LogInstance("Track limit reached"); return nil end
  if(not pPly:CheckLimit("props")) then -- Check the props limit
    LogInstance("Prop limit reached"); return nil end
  local stPiece = CacheQueryPiece(sModel) if(not IsHere(stPiece)) then
    LogInstance("Record missing for <"..sModel..">"); return nil end
  local ePiece = entsCreate(GetTerm(stPiece.Unit, sClass, sClass))
  if(not (ePiece and ePiece:IsValid())) then -- Create the piece unit
    LogInstance("Piece invalid <"..tostring(ePiece)..">"); return nil end
  ePiece:SetCollisionGroup(COLLISION_GROUP_NONE)
  ePiece:SetSolid(SOLID_VPHYSICS)
  ePiece:SetMoveType(MOVETYPE_VPHYSICS)
  ePiece:SetNotSolid(false)
  ePiece:SetModel(sModel)
  if(not SetPosBound(ePiece,vPos or GetOpVar("VEC_ZERO"),pPly,sMode)) then
    LogInstance(pPly:Nick().." spawned <"..sModel.."> outside"); return nil end
  ePiece:SetAngles(aAng or GetOpVar("ANG_ZERO"))
  ePiece:Spawn()
  ePiece:Activate()
  ePiece:SetRenderMode(RENDERMODE_TRANSALPHA)
  ePiece:SetColor(clColor or GetColor(255,255,255,255))
  ePiece:DrawShadow(false)
  ePiece:PhysWake()
  local phPiece = ePiece:GetPhysicsObject()
  if(not (phPiece and phPiece:IsValid())) then ePiece:Remove()
    LogInstance("Entity phys object invalid"); return nil end
  phPiece:EnableMotion(false); ePiece.owner = pPly -- Some SPPs actually use this value
  local Mass = (tonumber(nMass) or 1); phPiece:SetMass((Mass >= 1) and Mass or 1)
  local BgSk = GetOpVar("OPSYM_DIRECTORY"):Explode(sBgSkIDs or "")
  ePiece:SetSkin(mathClamp(tonumber(BgSk[2]) or 0,0,ePiece:SkinCount()-1))
  if(not AttachBodyGroups(ePiece,BgSk[1])) then ePiece:Remove()
    LogInstance("Failed attaching bodygroups"); return nil end
  if(not AttachAdditions(ePiece)) then ePiece:Remove()
    LogInstance("Failed attaching additions"); return nil end
  pPly:AddCount(sLimit , ePiece); pPly:AddCleanup(sLimit , ePiece) -- This sets the ownership
  pPly:AddCount("props", ePiece); pPly:AddCleanup("props", ePiece) -- To be deleted with clearing props
  LogInstance("{"..tostring(ePiece).."}"..sModel); return ePiece
end

function ApplyPhysicalSettings(ePiece,bPi,bFr,bGr,sPh)
  if(CLIENT) then LogInstance("Working on client"); return true end
  local bPi, bFr = (tobool(bPi) or false), (tobool(bFr) or false)
  local bGr, sPh = (tobool(bGr) or false),  tostring(sPh or "")
  LogInstance("{"..tostring(bPi)..","..tostring(bFr)..","..tostring(bGr)..","..sPh.."}")
  if(not (ePiece and ePiece:IsValid())) then   -- Cannot manipulate invalid entities
    LogInstance("Piece entity invalid <"..tostring(ePiece)..">"); return false end
  local pyPiece = ePiece:GetPhysicsObject()    -- Get the physics object
  if(not (pyPiece and pyPiece:IsValid())) then -- Cannot manipulate invalid physics
    LogInstance("Piece physical object invalid <"..tostring(ePiece)..">"); return false end
  local arSettings = {bPi,bFr,bGr,sPh}  -- Initialize dupe settings using this array
  ePiece.PhysgunDisabled = bPi          -- If enabled stop the player from grabbing the track piece
  ePiece:SetUnFreezable(bPi)            -- If enabled stop the player from hitting reload to mess it all up
  ePiece:SetMoveType(MOVETYPE_VPHYSICS) -- Moves and behaves like a normal prop
  -- Delay the freeze by a tiny amount because on physgun snap the piece
  -- is unfrozen automatically after physgun drop hook call
  timerSimple(GetOpVar("DELAY_FREEZE"), function() -- If frozen motion is disabled
    LogInstance("Freeze", "*DELAY_FREEZE");  -- Make sure that the physics are valid
    if(pyPiece and pyPiece:IsValid()) then pyPiece:EnableMotion(not bFr) end end )
  constructSetPhysProp(nil,ePiece,0,pyPiece,{GravityToggle = bGr, Material = sPh})
  duplicatorStoreEntityModifier(ePiece,GetOpVar("TOOLNAME_PL").."dupe_phys_set",arSettings)
  LogInstance("Success"); return true
end

function HookOnRemove(oBas,oEnt,cnTab)
  if(not (oBas and oBas:IsValid())) then LogInstance("Base invalid"); return nil end
  if(not (oEnt and oEnt:IsValid())) then LogInstance("Prop invalid"); return nil end
  if(not (cnTab and cnTab[1])) then LogInstance("Constraint list empty"); return nil end
  local ID = 1 while(ID <= #cnTab) do
    if(not cnTab[ID]) then LogInstance("Empty constraint <"..tostring(ID)..">")
    else oEnt:DeleteOnRemove(cnTab[ID]); oBas:DeleteOnRemove(cnTab[ID]); ID = ID + 1 end
  end; LogInstance("Success")
end

function ApplyPhysicalAnchor(ePiece,eBase,vPos,vNorm,nCID,nNoC,nFoL,nToL,nFri)
  local CID, NoC = (tonumber(nCID) or 1), (tonumber(nNoC) or 0)
  local FrL, ToL = (tonumber(nFoL) or 0), (tonumber(nToL) or 0)
  local Fri, SID = (tonumber(nFri) or 0)
  local ConstrInfo = GetOpVar("CONTAIN_CONSTRAINT_TYPE"):Select(CID)
  if(not IsExistent(ConstrInfo)) then LogInstance("Constraint not available"); return false end
  LogInstance("["..ConstrInfo.Name.."] {"..CID..","..NoC..","..FrL..","..ToL..","..Fri.."}")
  if(not (ePiece and ePiece:IsValid())) then LogInstance("Piece not valid"); return false end
  if(IsOther(ePiece)) then LogInstance("Piece is other object"); return false  end
  if(not constraintCanConstrain(ePiece,0)) then LogInstance("Cannot constrain Piece"); return false  end
  local pyPiece = ePiece:GetPhysicsObject(); if(not (pyPiece and pyPiece:IsValid())) then
    LogInstance("Phys Piece not valid"); return false  end
  if(not SID and CID == 1) then SID = CID end
  if(not (eBase and eBase:IsValid())) then return LogInstance(0,"Base skipped") end
  if(not constraintCanConstrain(eBase,0)) then LogInstance("Cannot constrain Base"); return false  end
  if(IsOther(eBase)) then LogInstance("Base is other object"); return false  end
  if(not SID and CID == 2) then
    -- http://wiki.garrysmod.com/page/Entity/SetParent
    ePiece:SetParent(eBase); SID = CID
  elseif(not SID and CID == 3) then
    -- http://wiki.garrysmod.com/page/constraint/Weld
    local C = ConstrInfo.Make(ePiece,eBase,0,0,FrL,(NoC ~= 0),false)
    HookOnRemove(eBase,ePiece,{C},1); SID = CID
  end
  if(not SID and CID == 4 and vNorm) then
    -- http://wiki.garrysmod.com/page/constraint/Axis
    local LPos1 = pyPiece:GetMassCenter()
    local LPos2 = ePiece:LocalToWorld(LPos1); LPos2:Add(vNorm)
          LPos2:Set(eBase:WorldToLocal(LPos2))
    local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,ToL,Fri,NoC)
     HookOnRemove(eBase,ePiece,{C},1); SID = CID
  elseif(not SID and CID == 5) then
    -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( HD )
    local C = ConstrInfo.Make(eBase,ePiece,0,0,pyPiece:GetMassCenter(),FrL,ToL,NoC)
    HookOnRemove(eBase,ePiece,{C},1); SID = CID
  elseif(not SID and CID == 6 and vPos) then
    -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( TR )
    local vLPos2 = eBase:WorldToLocal(vPos)
    local C = ConstrInfo.Make(ePiece,eBase,0,0,vLPos2,FrL,ToL,NoC)
    HookOnRemove(eBase,ePiece,{C},1); SID = CID
  end
  -- http://wiki.garrysmod.com/page/constraint/AdvBallsocket
  local pyBase = eBase:GetPhysicsObject()
  if(not (pyBase and pyBase:IsValid())) then
    return LogInstance(false,"Phys Base not valid") end
  local Min, Max = 0.01, 180
  local LPos1 = pyBase:GetMassCenter()
  local LPos2 = pyPiece:GetMassCenter()
  if(not SID and CID == 7) then -- Lock X
    local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Min,-Max,-Max,Min,Max,Max,Fri,Fri,Fri,1,NoC)
    HookOnRemove(eBase,ePiece,{C},1); SID = CID
  elseif(not SID and CID == 8) then -- Lock Y
    local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Max,-Min,-Max,Max,Min,Max,Fri,Fri,Fri,1,NoC)
    HookOnRemove(eBase,ePiece,{C},1); SID = CID
  elseif(not SID and CID == 9) then -- Lock Z
    local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Max,-Max,-Min,Max,Max,Min,Fri,Fri,Fri,1,NoC)
    HookOnRemove(eBase,ePiece,{C},1); SID = CID
  elseif(not SID and CID == 10) then -- Spin X
    local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Max,-Min,-Min,Max, Min, Min,Fri,Fri,Fri,1,NoC)
    local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Max, Min, Min,Max,-Min,-Min,Fri,Fri,Fri,1,NoC)
    HookOnRemove(eBase,ePiece,{C1,C2},2); SID = CID
  elseif(not SID and CID == 11) then -- Spin Y
    local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Min,-Max,-Min, Min,Max, Min,Fri,Fri,Fri,1,NoC)
    local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0, Min,-Max, Min,-Min,Max,-Min,Fri,Fri,Fri,1,NoC)
    HookOnRemove(eBase,ePiece,{C1,C2},2); SID = CID
  elseif(not SID and CID == 12) then -- Spin Z
    local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0,-Min,-Min,-Max, Min, Min,Max,Fri,Fri,Fri,1,NoC)
    local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,FrL,0, Min, Min,-Max,-Min,-Min,Max,Fri,Fri,Fri,1,NoC)
    HookOnRemove(eBase,ePiece,{C1,C2},2); SID = CID
  end; LogInstance("Status <"..tostring(SID)..">"); return true
end

function MakeAsmConvar(sName, vVal, tBord, vFlg, vInf)
  if(not IsString(sName)) then
    LogInstance("CVar name "..GetReport(sName).." not string"); return nil end
  local sLow = (IsExact(sName) and sName:sub(2,-1):lower() or (GetOpVar("TOOLNAME_PL")..sName):lower())
  local cVal = (tonumber(vVal) or tostring(vVal)); LogInstance("("..sLow..")["..tostring(cVal).."]")
  local sInf, nFlg = tostring(vInf or ""), mathFloor(tonumber(vFlg) or 0)
  SetBorder(sLow, (tBord and tBord[1] or nil), (tBord and tBord[2] or nil))
  return CreateConVar(sLow, cVal, nFlg, sInf)
end

function GetAsmConvar(sName, sMode)
  if(not IsString(sName)) then
    LogInstance("Nsme "..GetReport(sName).." not string"); return nil end
  if(not IsString(sMode)) then
    LogInstance("Mode "..GetReport(sMode).." not string"); return nil end
  local sLow = (IsExact(sName) and sName:sub(2,-1):lower() or (GetOpVar("TOOLNAME_PL")..sName):lower())
  local CVar = GetConVar(sLow); if(not IsHere(CVar)) then
    LogInstance("("..sLow..", "..sMode..") Missing object"); return nil end
  if    (sMode == "INT") then return (tonumber(BorderValue(CVar:GetInt()   , sLow)) or 0)
  elseif(sMode == "FLT") then return (tonumber(BorderValue(CVar:GetFloat() , sLow)) or 0)
  elseif(sMode == "STR") then return (tostring(BorderValue(CVar:GetString(), sLow)) or "")
  elseif(sMode == "BUL") then return (CVar:GetBool() or false)
  elseif(sMode == "DEF") then return  CVar:GetDefault()
  elseif(sMode == "INF") then return  CVar:GetHelpText()
  elseif(sMode == "NAM") then return  CVar:GetName()
  elseif(sMode == "OBJ") then return  CVar
  end; LogInstance("("..sName..", "..sMode..") Missed mode"); return nil
end

function SetAsmConvar(pPly,sNam,snVal)
  if(not IsString(sNam)) then -- Make it like so the space will not be forgotten
    LogInstance("Convar "..GetReport(sNam).." not string"); return nil end
  if(IsPlayer(pPly)) then local sFmt = GetOpVar("FORM_CONCMD")
    return pPly:ConCommand(sFmt:format(sNam, tostring(snVal)))
  end; return RunConsoleCommand(GetOpVar("TOOLNAME_PL")..sNam, snVal)
end

function SetAsmCallback(sName, sType, sHash, fHand)
  local sFunc = "*SetAsmCallback"
  if(not (sName and IsString(sName))) then
    LogInstance("Key "..GetReport(sName).." not string",sFunc); return nil end
  if(not (sType and IsString(sType))) then
    LogInstance("Key "..GetReport(sType).." not string",sFunc); return nil end
  if(IsString(sHash)) then local sLong = GetAsmConvar(sName, "NAM")
    cvarsRemoveChangeCallback(sLong, sLong.."_call")
    cvarsAddChangeCallback(sLong, function(sVar, vOld, vNew)
      local aVal, bS = GetAsmConvar(sName, sType), true
      if(type(fHand) == "function") then bS, aVal = pcall(fHand, aVal)
        if(not bS) then LogInstance("Fail "..tostring(aVal),sFunc); return nil end
        LogInstance("("..sName..") Converted",sFunc)
      end; LogInstance("("..sName..") <"..tostring(aVal)..">",sFunc)
      SetOpVar(sHash, aVal) -- Make sure we write down the processed value in the hashes
    end, sLong.."_call")
  end
end

function GetPhrase(sKey)
  local sDef = GetOpVar("MISS_NOTR")
  local tSet = GetOpVar("LOCALIFY_TABLE")
  local sKey = tostring(sKey) if(not IsHere(tSet[sKey])) then
    LogInstance("Miss <"..sKey..">"); return GetOpVar("MISS_NOTR") end
  return (tSet[sKey] or GetOpVar("MISS_NOTR")) -- Translation fail safe
end

local function GetLocalify(sCode)
  local sCode = tostring(sCode or GetOpVar("MISS_NOAV"))
  if(not CLIENT) then LogInstance("("..sCode..") Not client"); return nil end
  local sTool, sLimit = GetOpVar("TOOLNAME_NL"), GetOpVar("CVAR_LIMITNAME")
  local sPath = GetOpVar("FORM_LANGPATH"):format("", sCode..".lua") -- Translation file path
  if(not fileExists("lua/"..sPath, "GAME")) then
    LogInstance("("..sCode..") Missing"); return nil end
  local fCode = CompileFile(sPath); if(not fCode) then
    LogInstance("("..sCode..") No function"); return nil end
  local bFunc, fFunc = pcall(fCode); if(not bFunc) then
    LogInstance("("..sCode..")[1] "..fFunc); return nil end
  local bCode, tCode = pcall(fFunc, sTool, sLimit); if(not bCode) then
    LogInstance("("..sCode..")[2] "..tCode); return nil end
  return tCode -- The successfully extracted translations
end

function InitLocalify(sCode)
  local cuCod = tostring(sCode or GetOpVar("MISS_NOAV"))
  if(not CLIENT) then LogInstance("("..cuCod..") Not client"); return nil end
  local thSet = GetOpVar("LOCALIFY_TABLE"); tableEmpty(thSet)
  local auCod = GetOpVar("LOCALIFY_AUTO") -- Automatic translation code
  local auSet = GetLocalify(auCod); if(not auSet) then
    LogInstance("Base mismatch <"..auCod..">"); return nil end
  if(cuCod ~= auCod) then local cuSet = GetLocalify(cuCod)
    if(cuSet) then -- When the language infornation is extracted apply on success
      for key, val in pairs(auSet) do auSet[key] = (cuSet[key] or auSet[key]) end
    else LogInstance("Custom skipped <"..cuCod..">") end -- Apply auto code
  end; for key, val in pairs(auSet) do thSet[key] = auSet[key]; languageAdd(key, val) end
end

--[[
 * Checks if the ghosts stack contains items
 * Ghosting is client side only
 * Could you do it for a Scooby snacks?
]]
function HasGhosts()
  if(SERVER) then return false end
  local tGho = GetOpVar("ARRAY_GHOST")
  local eGho, nSiz = tGho[1], tGho.Size
  return (eGho and eGho:IsValid() and nSiz and nSiz > 0)
end

--[[
 * Fades the ghosts stack and makes the elements invisible
 * bNoD > The state of the No-Draw flag
 * Wait a minute, ghosts can't leave fingerprints!
]]
function FadeGhosts(bNoD)
  if(SERVER) then return true end
  if(not HasGhosts()) then return true end
  local tGho = GetOpVar("ARRAY_GHOST")
  local cPal = GetOpVar("CONTAINER_PALETTE")
  for iD = 1, tGho.Size do local eGho = tGho[iD]
    if(eGho and eGho:IsValid()) then
      eGho:SetNoDraw(bNoD); eGho:DrawShadow(false)
      eGho:SetColor(cPal:Select("gh"))
    end
  end; return true
end

--[[
 * Clears the ghosts stack and deletes all the items
 * vSiz > The custom stack size. Nil makes it take the `tGho.Size`
 * bCol > When enabled calls the garbage collector
 * Well gang, I guess that wraps up the mystery.
]]
function ClearGhosts(vSiz, bCol)
  if(SERVER) then return true end
  local tGho = GetOpVar("ARRAY_GHOST")
  local iSiz = mathCeil(tonumber(vSiz) or tGho.Size)
  for iD = 1, iSiz do local eGho = tGho[iD]
    if(eGho and eGho:IsValid()) then
      eGho:SetNoDraw(true); eGho:Remove()
    end; eGho, tGho[iD] = nil, nil
  end; tGho.Size, tGho.Slot = 0, GetOpVar("MISS_NOMD")
  if(bCol) then collectgarbage() end; return true
end

--[[
 * Creates a single ghost entity for populating the stack
 * sModel > The model which the creation is requested for
 * vPos   > Position for the entity, otherwise zero is used
 * aAng   > Angles for the entity, otherwise zero is used
 * It must have been our imagination.
]]
local function MakeEntityGhost(sModel, vPos, aAng)
  local cPal = GetOpVar("CONTAINER_PALETTE")
  local eGho = entsCreateClientProp(sModel)
  if(not (eGho and eGho:IsValid())) then eGho = nil
    LogInstance("Ghost invalid "..sModel); return nil end
      eGho:SetModel(sModel)
  eGho:SetPos(vPos or GetOpVar("VEC_ZERO"))
  eGho:SetAngles(aAng or GetOpVar("ANG_ZERO"))
      eGho:Spawn()
      eGho:SetSolid(SOLID_NONE)
      eGho:SetMoveType(MOVETYPE_NONE)
      eGho:SetNotSolid(true)
      eGho:SetNoDraw(true)
      eGho:DrawShadow(false)
      eGho:SetRenderMode(RENDERMODE_TRANSALPHA)
      eGho:SetColor(cPal:Select("gh"))
  return eGho
end

--[[
 * Populates the ghost stack with the requested number of items
 * nCnt   > The ghost stack requested depth
 * sModel > The model which the creation is requested for
 * Not until we walk around the ghost town and see what we can find.
]]
function MakeGhosts(nCnt, sModel) -- Only he's not a shadow, he's a green ghost!
  if(SERVER) then return true end -- Ghosting is client side only
  local tGho = GetOpVar("ARRAY_GHOST") -- Read ghosts
  if(nCnt == 0 and tGho.Size == 0) then return true end -- Skip processing
  if(nCnt == 0 and tGho.Size ~= 0) then return ClearGhosts() end -- Disabled ghosting
  local iD = 1; FadeGhosts(true) -- Fade the current ghost stack
  while(iD <= nCnt) do local eGho = tGho[iD]
    if(eGho and eGho:IsValid() and eGho:GetModel() ~= sModel) then
      eGho:Remove(); tGho[iD] = nil; eGho = tGho[iD] end
    if(not (eGho and eGho:IsValid())) then
      tGho[iD] = MakeEntityGhost(sModel, vPos, vAng); eGho = tGho[iD]
      if(not (eGho and eGho:IsValid())) then ClearGhosts(iD)
        LogInstance("Invalid ["..iD.."]"..sModel); return false end
    end; iD = iD + 1 -- Fade all the ghosts and refresh these that must be drawn
  end -- Remove all others that must not be drawn to save memory
  for iK = iD, tGho.Size do -- Executes only when (nCnt <= tGho.Size)
    local eGho = tGho[iD]; if(eGho and eGho:IsValid()) then
      eGho:SetNoDraw(true); eGho:Remove(); eGho = nil end; tGho[iD] = nil
  end; tGho.Size, tGho.Slot = nCnt, sModel; return true
end

function GetHookInfo(tInfo, sW)
  if(SERVER) then return nil end
  local sMod = GetOpVar("TOOL_DEFMODE")
  local sWep = tostring(sW or sMod)
  local oPly = LocalPlayer(); if(not IsPlayer(oPly)) then
    LogInstance("Player invalid",tInfo); return nil end
  local actSwep = oPly:GetActiveWeapon(); if(not IsValid(actSwep)) then
    LogInstance("Swep invalid",tInfo); return nil end
  if(actSwep:GetClass() ~= sWep) then
    LogInstance("("..sWep..") Swep other",tInfo); return nil end
  if(sWep ~= sMod) then return oPly, actSwep end
  if(actSwep:GetMode()  ~= GetOpVar("TOOLNAME_NL")) then
    LogInstance("Tool different",tInfo); return nil end
  -- Here player is holding the track assembly tool
  local actTool = actSwep:GetToolObject(); if(not actTool) then
    LogInstance("Tool invalid",tInfo); return nil end
  return oPly, actSwep, actTool
end

function GetConvarList(tC)
  local sT = GetOpVar("TOOLNAME_PL")
  local tI = GetOpVar("TABLE_CONVARLIST")
  if(IsTable(tC)) then tableEmpty(tI)
    for key, val in pairs(tC) do tI[sT..key] = val end
  end; return tI
end
