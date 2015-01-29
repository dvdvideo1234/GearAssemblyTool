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
local csX = 4
-- Sign of the second component
local csY = 5
-- Sign of the third component
local csZ = 6
-- Flag for disabling the point
local csD = 7

---------------- Localizing instances ------------------

local SERVER = SERVER
local CLIENT = CLIENT

---------------- Localizing Player keys ----------------

local IN_USE       = IN_USE
local IN_ALT1      = IN_ALT1
local IN_LEFT      = IN_LEFT
local IN_ZOOM      = IN_ZOOM
local IN_JUMP      = IN_JUMP
local IN_BACK      = IN_BACK
local IN_DUCK      = IN_DUCK
local IN_ALT2      = IN_ALT2
local IN_WALK      = IN_WALK
local IN_SPEED     = IN_SPEED
local IN_SCORE     = IN_SCORE
local IN_RIGHT     = IN_RIGHT
local IN_RELOAD    = IN_RELOAD
local IN_ATTACK    = IN_ATTACK
local IN_FORWARD   = IN_FORWARD
local IN_ATTACK2   = IN_ATTACK2
local IN_MOVELEFT  = IN_MOVELEFT
local IN_MOVERIGHT = IN_MOVERIGHT

---------------- Localizing Libraries ----------------

local type           = type
local Angle          = Angle
local pairs          = pairs
local print          = print
local Vector         = Vector
local require        = require
local IsValid        = IsValid
local include        = include
local tonumber       = tonumber
local tostring       = tostring
local LocalPlayer    = LocalPlayer
local collectgarbage = collectgarbage
local os             = os
local sql            = sql
local math           = math
local ents           = ents
local util           = util
local undo           = undo
local file           = file
local timer          = timer
local string         = string

-- How is the tool called
local LibToolName = "gearassembly"

-- Library Debug Settings. The file is created in
-- the DATA folder :3 *.txt is appended
local LibDebugEn = 1
local LibLogFile = LibToolName .. "_log"
local LibMaxLogs = 10000
local LibCurLogs = 0

-- Library Syms
local LibSymDisable = "#"
local LibSymRevSign = "@"
local LibSymDevider = "_"

-- Operating paths
local LibBASPath = LibToolName .. "/"
local LibEXPPath = "export/"
local LibDSVPath = "dsvbase/"
local LibLOGPath = ""

-- Table prefix to avoid overlapping and conflicts
local LibTablePrefix = string.upper(LibToolName) .. "_"

-- Spawn Struct table Space
local LibSpawn = {
  ["ENT"] = {
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
    TRec = 0,
  },
  ["NOR"] = {
    F    = Vector(),
    R    = Vector(),
    U    = Vector(),
    SPos = Vector(),
    SAng = Angle (),
    CAng = Angle (),
    DAng = Angle (),
    HRec = 0
  }
}
---------------- CASHES SPACE --------------------

-- Used to cache stuff in a Pool
local LibCache = {}

-- Used to store the last SQL error message
local LibSQLBuildError = ""

---------------- TABLE DEFINITIONS SPACE----------------

local LibTables = {
  [LibTablePrefix.."PIECES"] = {
    Size = 7,
    Keep = 15,
    [1] = {"MODEL" , "TEXT", "L"},
    [2] = {"TYPE"  , "TEXT"},
    [3] = {"NAME"  , "TEXT"},
    [4] = {"AMESH" , "REAL"},
    [5] = {"ORIGN" , "TEXT"},
    [6] = {"ANGLE" , "TEXT"},
    [7] = {"MASSC" , "TEXT"}
  }
}

module( "gearasmlib" )

-------------- BEGIN SQL AssemblyLib -------------

---------------------------- AssemblyLib COMMON ----------------------------

--- Angle

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

--- Vector

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

function NegVector(vBase, nX, nY, nZ)
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

function GetDefaultString(sBase, sDefault)
  if(type(sBase) ~= "string") then return "" end
  if(type(sBase) ~= type(sDefault)) then return "" end
  if(string.len(sBase) > 0) then return sBase end
  return sDefault
end

function SetTableDefinition(sTable, tDefinition)
  if(not sTable or sTable ~= "string") then return false end
  if(not tDefinition or tDefinition ~= "table") then return false end
  if(not tDefinition.Size) then return false end
  if(not tDefinition[1]) then return false end
  for k,v in pairs(LibTables) do
    if(k == sTable) then return false end
  end
  LibTables[sTable] = tDefinition
  return true
end

function GetTableDefinition(sTable)
  if(sTable and type(sTable) == "string") then
    return LibTables[LibTablePrefix..sTable]
  end
  return nil
end

function GetSQLBuildError()
  return LibSQLBuildError
end

function BASPath(sPath)
  if(sPath and type(sPath) == "string") then
    LibBASPath = sPath .. "/"
  end
  return LibBASPath
end

function EXPPath(sPath)
  if(sPath and type(sPath) == "string") then
    LibEXPPath = sPath .. "/"
  end
  return LibEXPPath
end

function DSVPath(sPath)
  if(sPath and type(sPath) == "string") then
    LibDSVPath = sPath .. "/"
  end
  return LibDSVPath
end

function LOGPath(sPath)
  if(sPath and type(sPath) == "string") then
    LibLOGPath = sPath .. "/"
  end
  return LibLOGPath
end

function GetTablePrefix()
  return LibTablePrefix
end

function IsOther(oEnt)
  if(not oEnt)         then return true end
  if(oEnt:IsRagdoll()) then return true end
  if(oEnt:IsVehicle()) then return true end
  if(oEnt:IsPlayer())  then return true end
  if(oEnt:IsWeapon())  then return true end
  if(oEnt:IsWidget())  then return true end
  if(oEnt:IsNPC())     then return true end
  return false
end

function StringExplode(sStr,sDelim)
  if(type(sStr) ~= "string" and type(sDelim) ~= "string") then
    LogInstance("StringExplode: All parameters should be strings")
  end
  if(string.len(sDelim) <= 0) then
    LogInstance("StringExplode: Delimiter has to be a symbol")
  end
  local Len = string.len(sStr)
  local S = 1
  local E = 1
  local V = ""
  local Ind = 1
  local Data = {}
  if(string.sub(sStr,Len,Len) ~= sDelim) then
    sStr = sStr .. sDelim
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

function RoundValue(exact, frac)
    local q,f = math.modf(exact/frac)
    return frac * (q + (f > 0.5 and 1 or 0))
end

function GetViewRadius(plPly,vPos)
  if(not (vPos and plPly)) then return 0 end
  return math.Clamp(500 / (vPos - plPly:GetPos()):Length(),1,100)
end

function GetCorrectID(anyValue,stSettings)
  local Value = tonumber(anyValue)
  if(not Value) then return 1 end
  if(Value > stSettings["MAX"]) then Value = 1 end
  if(Value < 1) then Value = stSettings["MAX"] end
  return Value
end

function SnapValue(nVal, nSnap)
  local Rest
  local Snap
  local Rez
  local Val
  Val  = math.abs(nVal)
  Snap = math.abs(nSnap)
  Rest = Val % Snap
  if((Snap-Rest) < Rest) then
    Rez = Val+Snap-Rest
  else
    Rez = Val-Rest
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

function Model2Name(sModel)
  local Len = string.len(sModel)-4
  local Cnt = Len
  while(Cnt > 0) do
    Ch = string.sub(sModel,Cnt,Cnt)
    if(Ch == '/') then
      break
    end
    Cnt = Cnt - 1
  end
  local Sub = LibSymDevider..string.sub(sModel,Cnt+1,Len)
  local Rez = ""
  Len = string.len(Sub)
  Cnt = 1
  local Us = ""
  while(Cnt <= Len) do
    Us = string.sub(Sub,Cnt,Cnt)
    Ch = string.sub(Sub,Cnt+1,Cnt+1)
    if(Us == LibSymDevider) then
       Us = " "
       Ch = string.upper(Ch)
       Rez = Rez .. Us .. Ch
       Cnt = Cnt + 2
    else
      Rez = Rez .. Us
      Cnt = Cnt + 1
    end
  end
  return string.sub(Rez,2,Len)
end

function DecodeOffset(arData,sStr)
  if(not sStr) then return false end
  local DatInd = 1
  local ComCnt = 0
  local Len = string.len(sStr)
  local Ch = ""
  local S = 1
  local E = 1
  local Cnt = 1
  if(string.sub(sStr,Cnt,Cnt) == LibSymDisable) then
    arData[7] = true
    Cnt = Cnt + 1
    S   = S   + 1
  end
  while(Cnt <= Len) do
    Ch = string.sub(sStr,Cnt,Cnt)
    if(Ch == LibSymRevSign) then
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

function NumFormatLen(In,Frac,Sym)
  if(In and (type(In) == "number")) then
    local Mw = "0"
    local Mp = "0"
    if(Sym) then
      Mw = Sym[1] or Mw
      Mp = Sym[2] or Mp
    end
    local StrIn = tostring(In)
    local Ls = string.len(StrIn)
    local Pp = string.find(StrIn,"%.",1)
    if(not Pp) then
      local Lw = Ls
      if(Frac) then
        Lw = Frac[1] or Lw
      end
      local Sw  = ""
      local Dif = Lw - Ls
      if(Dif >= 0) then
        while(Dif > 0) do
          Sw = Sw..Mw
          Dif = Dif - 1
        end
        return Sw..StrIn
      end
      return string.sub(StrIn,Ls-Lw+1,Ls)
    else
      local Lw = (Pp - 1)
      local Lp = (Ls - Pp)
      if(Frac) then
        Lw = Frac[1] or Lw
        Lp = Frac[2] or Lp
      end
      local Sw, Sp
      local Dw = Lw - (Pp - 1)
      local Dp = Lp - (Ls - Pp)
      if(Dw > 0) then
        Sw = string.sub(StrIn,1,Pp-1)
        while(Dw > 0) do
          Sw = Mw..Sw
          Dw = Dw - 1
        end
      else
        Sw = string.sub(StrIn,1-Dw,Pp-1)
      end
      if(Dp > 0) then
        Sp = string.sub(StrIn,Pp+1,Ls)
        while(Dp > 0) do
          Sp = Sp..Mp
          Dp = Dp - 1
        end
      else
        Sp = string.sub(StrIn,Pp+1,Ls+Dp)
      end
      return Sw.."."..Sp
    end
  end
  return "NaN"
end

function Indent(nCnt,sStr,bFixed)
  if(not (nCnt and sStr)) then return "" end
  local Out = ""
  local Cnt = nCnt
  local Len = string.len(sStr)
  if(bFixed) then return " " .. sStr end
  if(Cnt == 0) then return sStr end
  if(Cnt  > 0) then
    while(Cnt > 0) do
      Out = Out .. "  "
      Cnt = Cnt - 1
    end
    return Out .. sStr
  else
    return string.sub(sStr,1-2*Cnt,Len)
  end
end

function Qsort(Data,Lo,Hi)
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
      CopyTable[Cct].Val = CopyTable[Cct].Val .. tostring(v[i])
      Cnt = Cnt + 1
    end
    Cct = Cct + 1
  end
  Cct = Cct - 1
  Qsort(CopyTable,1,Cct)
  return CopyTable
end

function DecomposeByAngle(V,A)
  if(not ( V and A ) ) then
    return Vector()
  end
  return Vector(V:DotProduct(A:Forward()),
                V:DotProduct(A:Right()),
                V:DotProduct(A:Up()))
end

------------------ AssemblyLib LOGS ------------------------

function PrintInstance(anyStuff)
  if(SERVER) then
    print("SERVER > "..tostring(anyStuff))
  elseif(CLIENT) then
    print("CLIENT > "..tostring(anyStuff))
  else
    print("NOINST > "..tostring(anyStuff))
  end
end

function SetLogControl(nEn,nLines,sFile)
  LibDebugEn = nEn
  LibLogFile = sFile
  LibMaxLogs = nLines
  if(not file.Exists(LibBASPath,"DATA") and (string.len(LibLogFile) > 0)) then
    file.CreateDir(LibBASPath)
  end
end

function Log(anyStuff)
  if(LibDebugEn ~= 0) then
    if(LibLogFile ~= "") then
      local fName = LibBASPath .. LibLOGPath .. LibLogFile..".txt"
      file.Append(fName,NumFormatLen(LibCurLogs,{string.len(tostring(LibMaxLogs))},{" "})
               .." >> "..tostring(anyStuff).."\n")
      LibCurLogs = LibCurLogs + 1
      if(LibCurLogs > LibMaxLogs) then
        file.Delete(fName)
        LibCurLogs = 0
      end
    else
      PrintInstance("GEARASSEMBLY LOG: "..tostring(anyStuff))
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

function Print(tT,sS)
  if(not tT)then
    LogInstance("Print: No Data: Print( table, string = \"Data\" )!")
    return
  end
  local S = type(sS)
  local T = type(tT)
  local Key  = ""
  if(S and (S == "string" or
            S == "number" )
       and S ~= ""
  ) then
    S = tostring(sS)
  else
    S = "Data"
  end
  if(T ~= "table") then
    LogInstance("{"..T.."}["..S.."] => "..tostring(tT))
    return
  end
  T = tT
  LogInstance(S)
  for k,v in pairs(T) do
    if(type(k) == "string") then
      Key = S.."[\""..k.."\"]"
    else
      Key = S.."["..k.."]"
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

PrintArrLine = function(aTable,sName)
  local Line = (sName or "Data").."{"
  local Cnt  = 1
  while(aTable[Cnt]) do
    Line = Line .. tostring(aTable[Cnt])
    if(aTable[Cnt + 1]) then
      Line = Line .. ", "
    end
    Cnt = Cnt + 1
  end
  LogInstance(Line.."}")
end

------------------------- AssemblyLib PLAYER -----------------------------------

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
      local sTyp = type(Cache[k])
      if(sTyp == "boolean") then
        Cache[k] = false
      elseif(sTyp == "number") then
        Cache[k] = 0
      elseif(sTyp == "string") then
        Cache[k] = ""
      end
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
  if(not type(sTable) == "string") then return false end
  if(not LibTables[sTable]) then
    LibSQLBuildError = "SQLBuildCreate: Missing Table definition for "..sTable
    return false
  end
  local defTable = LibTables[sTable]
  if(not defTable.Size) then
    LibSQLBuildError = "SQLBuildCreate: Missing Table definition SIZE for "..sTable
    return false
  end
  if(not defTable[1]) then
    LibSQLBuildError = "SQLBuildCreate: Missing Table definition is empty for "..sTable
    return false
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    LibSQLBuildError = "SQLBuildCreate: Missing: Table "..sTable.." field definitions"
    return false
  end
  local Ind = 1
  local Command  = {}
  Command.Drop   = "DROP TABLE "..sTable..";"
  Command.Delete = "DELETE FROM "..sTable..";"
  Command.Create = "CREATE TABLE "..sTable.." ( "
  while(defTable[Ind]) do
    local v = defTable[Ind]
    if(not v[1]) then
      return "SQLBuildCreate: Missing Table "..sTable
             .."'s field #"..tostring(Ind)
    end
    if(not v[2]) then
      LibSQLBuildError = "SQLBuildCreate: Missing Table "..sTable
                                  .."'s field type #"..tostring(Ind)
      return false
    end
    Command.Create = Command.Create .. string.upper(v[1]).." ".. string.upper(v[2])
    if(defTable[Ind+1]) then
      Command.Create = Command.Create ..", "
    end
    Ind = Ind + 1
  end
  Command.Create = Command.Create .. " );"
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
        LibSQLBuildError = "SQLBuildCreate: Index creator mismatch on "..sTable
                                   .." value "..vI.." is not a table for index ["..tostring(Ind).."]"
        return false
      end
      local FieldsU = ""
      local FieldsC = ""
      Command.Index[Ind] = "CREATE INDEX IND_"..sTable
      Cnt = 1
      while(vI[Cnt]) do
        local vF = vI[Cnt]
        if(type(vF) ~= "number") then
          LibSQLBuildError = "SQLBuildCreate: Index creator mismatch on "..sTable
                 .." value "..vF.." is not a number for index ["
                 ..tostring(Ind).."]["..tostring(Cnt).."]"
          return false
        end
        if(not defTable[vF]) then
          LibSQLBuildError = "SQLBuildCreate: Index creator mismatch on "..sTable
                 ..". The table does ot have field index #"
                 ..vF..", max is #"..Table.Size
          return false
        end
        FieldsU = FieldsU .. "_" ..string.upper(defTable[vF][1])
        FieldsC = FieldsC .. string.upper(defTable[vF][1])
        if(vI[Cnt+1]) then
          FieldsC = FieldsC ..", "
        end
        Cnt = Cnt + 1
      end
      Command.Index[Ind] = Command.Index[Ind]..FieldsU.." ON "..sTable.." ( "..FieldsC.." );"
      Ind = Ind + 1
    end
  end
  return Command
end

function SQLBuildSelect(sTable,tFields,tWhere,tOrderBy)
  if(not type(sTable) == "string") then return false end
  if(not LibTables[sTable]) then
    LibSQLBuildError = "SQLBuildSelect: Missing: Table definition "..sTable
    return false
  end
  local defTable = LibTables[sTable]
  if(not defTable.Size) then
    LibSQLBuildError = "SQLBuildSelect: Missing: Table definition SIZE in "..sTable
    return false
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    LibSQLBuildError = "SQLBuildSelect: Missing: Table "..sTable.." field definitions"
    return false
  end
  local Cnt = 1
  local Command = "SELECT "
  if(tFields) then
    while(tFields[Cnt]) do
      local v = tonumber(tFields[Cnt])
      if(not v) then
        LibSQLBuildError = "SQLBuildSelect: Index #" ..tostring(tFields[Cnt])
             .." type mismatch in "..sTable
        return false
      end
      if(defTable[v]) then
        if(defTable[v][1]) then
          Command = Command .. defTable[v][1]
        else
          LibSQLBuildError = "SQLBuildSelect: No such field name by index #"..v.." in the table "..sTable
          return false
        end
      end
      if(tFields[Cnt+1]) then
        Command = Command ..", "
      end
      Cnt = Cnt + 1
    end
  else
    Command = Command .. "*"
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
          LibSQLBuildError = "SQLBuildSelect: Cannot convert string \""..v
                 .."\" to a number for field index #"..Cnt
                 .." in table "..sTable
          return false
        end
        v = toNB
      end
      if(t == "TEXT") then
        v = "'"..v.."'"
      end
      Command = Command .. " WHERE "..defTable[k][1].." = "..v
      Cnt = Cnt + 1
      while(tWhere[Cnt]) do
        local k = tonumber(tWhere[Cnt][1])
        local v = tWhere[Cnt][2]
        local t = defTable[k][2]
        if(not (k and v and t) ) then
          LibSQLBuildError = "SQLBuildSelect: Missing eather "..sTable.." field index, "
                 .."value or type in the table definition"
          return false
        end
        if(t == "TEXT" and type(v) == "number") then
          v = tostring(v)
        elseif(t == "INTEGER" and type(v) == "string") then
          local toNB = tonumber(v)
          if(not toNB) then
            LibSQLBuildError = "SQLBuildSelect: Cannot convert string \""..v
                   .."\" to a number for field index #"..Cnt
                   .." in table "..sTable
            return false
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
      return Command .. ";"
    end
  end
  if(tOrderBy and (type(tOrderBy) == "table")) then
    local Dire = ""
    Command = Command .. " ORDER BY "
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
        LibSQLBuildError = "Wrong Table "..sTable.." field index #"..Cnt
        return false
      end
        Command = Command .. defTable[v][1] .. Dire
        if(tOrderBy[Cnt+1]) then
          Command = Command..", "
        end
      Cnt = Cnt + 1
    end
  end
  return Command .. ";"
end

function SQLBuildInsert(sTable,tInsert,tValues)
  if(not type(sTable) == "string") then return false end
  if(not (LibTables[sTable] and tInsert and tValues)) then
    LibSQLBuildError = "SQLBuildInsert: Missing Table definition and Chosen fields"
    return false
  end
  local defTable = LibTables[sTable]
  if(not (defTable[1] and tInsert[1])) then
    LibSQLBuildError = "SQLBuildInsert: The table and the chosen fields must not be empty"
    return false
  end
  if(not (defTable[1][1] and
          defTable[1][2])
  ) then
    LibSQLBuildError = "SQLBuildInsert: Missing: Table "..sTable.." field definition"
    return false
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
      LibSQLBuildError = "SQLBuildInsert: Cannot insert tables into the DB for index #"..Cnt
      return false
    end
    qIns = qIns .. defTable[k][1]
    qVal = qVal .. Val
    if(tInsert[Cnt+1]) then
      qIns = qIns ..", "
      qVal = qVal ..", "
    else
      qIns = qIns .." ) "
      qVal = qVal .." );"
    end
    Cnt = Cnt + 1
  end
  return qIns .. qVal
end

------------- SQL Handling --------------

function SQLInsertRecord(sTable,tData)
  if(not type(sTable) == "string") then return false end
  local TableKey = LibTablePrefix..sTable
  if(not LibTables[TableKey]) then
    LogInstance("SQLInsertRecord: Missing: Table definition for "..sTable)
    return false
  end
  local defTable = LibTables[TableKey]
  if(not defTable.Size) then
    LogInstance("SQLInsertRecord: Missing: Table definition SIZE for "..sTable)
    return false
  end
  if(not defTable[1])  then
    LogInstance("SQLInsertRecord: Missing: Table definition is empty for "..sTable)
    return false
  end
  if(not tData)      then
    LogInstance("SQLInsertRecord: Missing: Data table for "..sTable)
    return false
  end
  if(not tData[1])   then
    LogInstance("SQLInsertRecord: Missing: Data table is empty for "..sTable)
    return false
  end
  if(sTable == "PIECES") then
    --Used only in PecesDB !!!
    if(tData[3]) then
      if(type(tData[3]) == "string") then
        if(string.sub(tData[3],1,1) == LibSymDisable) then
          tData[3] = Model2Name(tData[1])
        end
      else
        tData[3] = "Some Gear Piece"
      end
    else
      tData[3] = "Some Gear Piece"
    end
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
              ..FieldTyp.." <> "..FieldDef[2]
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
        LogInstance("SQLInsertRecord: Failed to insert a record because of "..tostring(sql.LastError()))
        LogInstance("SQLInsertRecord: Query ran > "..Q)
      return false
    end
    return true
  end
  LogInstance("SQLInsertRecord: "..GetSQLBuildError())
  return false
end

function SQLCreateTable(sTable,tIndex,bDelete,bReload)
  if(not type(sTable) == "string") then return false end
  local TableKey = LibTablePrefix..sTable
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
        LogInstance("SQLCreateTable: Table "..sTable
          .." failed to create because of ".. tostring(sql.LastError()))
        return false
      end
      if(sql.TableExists(TableKey)) then
        for k, v in pairs(tQ.Index) do
          qRez = sql.Query(v)
          if(not qRez and type(qRez) == "boolean") then
            LogInstance("SQLCreateTable: Table "..sTable
              .." failed to create index ["..k.."] > " .. v .." > because of ".. tostring(sql.LastError()))
            return false
          end
        end
        LogInstance("SQLCreateTable: Indexed Table "..sTable.." created !")
        return true
      else
        LogInstance("SQLCreateTable: Table "..sTable
          .." failed to create because of "..tostring(sql.LastError()))
        LogInstance("SQLCreateTable: Query ran > "..tQ.Create)
        return false
      end
    end
  else
    LogInstance("SQLCreateTable: "..GetSQLBuildError())
    return false
  end
end

--------------------------- AssemblyLib PIECE QUERY -----------------------------

function AttachKillTimer(oLocation,tKeys,defTable,anyMessage)
  if(not (oLocation and tKeys)) then return false end
  if(not tKeys[1]) then return false end
  local Cnt = 1
  local Place, Key, Typ
  local TimerID = ""
  while(tKeys[Cnt]) do
    Key = tKeys[Cnt]
    Typ = type(Key)
    if(not (Typ == "string" or Typ == "number")) then return false end
    TimerID = TimerID..tostring(Key)
    if(tKeys[Cnt+1]) then
      TimerID = TimerID .. "_"
      if(Place) then
        Place = Place[Key] 
        if(not Place) then return false end
      else
        Place = oLocation[Key]
      end
    end
    Cnt = Cnt + 1
  end
  local Duration = 0
  if(defTable) then
    Duration = tonumber(defTable.Keep) or 0
  end
  if(not timer.Exists(TimerID) and Place and Duration > 0) then
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
  return false
end

function RestartTimer(tKeys,anyMessage)
  if(not tKeys) then return false end
  if(not tKeys[1]) then return false end
  local Cnt = 1
  local Key, Typ
  local TimerID = ""
  while(tKeys[Cnt]) do
    Key = tKeys[Cnt]
    Typ = type(Key)
    if(not (Typ == "string" or Typ == "number")) then return false end
    TimerID = TimerID..tostring(Key)
    if(tKeys[Cnt+1]) then
      TimerID = TimerID .. "_"
    end
    Cnt = Cnt + 1
  end
  if(not timer.Exists(TimerID)) then return false end
  return timer.Start(TimerID)
end

-- Cashing the selected Piece Result
function CacheQueryPiece(sModel)
  if(not sModel) then return nil end
  if(type(sModel) ~= "string") then return nil end
  if(sModel == "") then return nil end
  if(not util.IsValidModel(sModel)) then return nil end
  local TableKey = LibTablePrefix.."PIECES"
  if(not LibCache[TableKey]) then
    LibCache[TableKey] = {}
  end
  local defTable = LibTables[TableKey]
  local stPiece  = LibCache[TableKey][sModel]
  if(stPiece) then
    if(stPiece.Here) then
      RestartTimer({TableKey,sModel},"CacheQueryPiece")
      return LibCache[TableKey][sModel]
    end
  end
  LogInstance("CacheQueryPiece: Model >> Pool: "..GetModelFileName(sModel))
  LibCache[TableKey][sModel] = {}
  stPiece = LibCache[TableKey][sModel]
  AttachKillTimer(LibCache,{TableKey,sModel},defTable,"CacheQueryPiece")
  local Q = SQLBuildSelect(TableKey,nil,{{1,sModel}})
  if(Q) then
    local qData = sql.Query(Q)
    if(qData and qData[1]) then
      local qRec   = qData[1]
      stPiece.Type = qRec[defTable[2][1]]
      stPiece.Name = qRec[defTable[3][1]]
      stPiece.Mesh = qRec[defTable[4][1]]
      stPiece.Here = true
      stPiece.O = {[cvX] = 0, [cvY] = 0,[cvZ] = 0, [csX] = 1, [csY] = 1, [csZ] = 1, [csD] = false}
      stPiece.M = {[cvX] = 0, [cvY] = 0,[cvZ] = 0, [csX] = 1, [csY] = 1, [csZ] = 1, [csD] = false}
      stPiece.A = {[caP] = 0, [caY] = 0,[caR] = 0, [csX] = 1, [csY] = 1, [csZ] = 1, [csD] = false}
      -- Origin
      if((qRec[defTable[5][1]] ~= "") and
         (qRec[defTable[5][1]] ~= "NULL")
      ) then
        DecodeOffset(stPiece.O,qRec[defTable[5][1]])
      end
      -- Angle
      if((qRec[defTable[6][1]] ~= "") and
         (qRec[defTable[6][1]] ~= "NULL")
      ) then
        DecodeOffset(stPiece.A,qRec[defTable[6][1]])
      end
      -- MassCentre
      if((qRec[defTable[7][1]] ~= "") and
         (qRec[defTable[7][1]] ~= "NULL")
      ) then
        DecodeOffset(stPiece.M,qRec[defTable[7][1]])
      end
      return stPiece
    else
      stPiece.Here = false
    end
  else
    LogInstance("CacheQueryPiece: "..GetSQLBuildError())
    return nil
  end
  return nil
end

----------------------- AssemblyLib PPANEL QUERY -------------------------------

--- Used to Populate the CPanel Tree
function PanelQueryPieces()
  local Q = SQLBuildSelect(LibTablePrefix.."PIECES",{1,2,3},nil,{2,3})
  if(Q) then
    local qData = sql.Query(Q)
    if(qData and qData[1]) then
      return qData
    end
    LogInstance("PanelQueryPieces: No data found >"..Q.."<")
    return nil
  end
  LogInstance("PanelQueryPieces: "..GetSQLBuildError())
  return nil
end

---------------------- AssemblyLib EXPORT --------------------------------

-- Used to define DB as a Lua table
function ExportSQL2Lua(sTable)
  if(type(sTable) ~= "string") then return end
  local TableKey = LibTablePrefix..sTable
  if(not LibTables[TableKey]) then return end
  local defTable = LibTables[TableKey]
  if(not file.Exists(LibBASPath,"DATA")) then
    file.CreateDir(LibBASPath)
  end
  if(not file.Exists(LibBASPath..LibEXPPath,"DATA")) then
    file.CreateDir(LibBASPath..LibEXPPath)
  end
  local F = file.Open(LibBASPath..LibEXPPath..
                      "sql2lua_"..TableKey..".txt", "w", "DATA" )
  if(not F) then
    LogInstance("ExportSQL2Lua: file.Open("..LibBASPath..LibEXPPath
                                           .."sql2lua_"..TableKey..".txt) Failed")
    return
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
      F:Write("Function ExportSQL2Lua: \n\n")
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
       F:Write("ExportSQL2Lua: No data found >"..Q.."<")
    end
  else
     F:Write("ExportSQL2Lua: "..GetSQLBuildError())
  end
  F:Flush()
  F:Close()
end

-- Used to generate inserts based on the DB itself
function ExportSQL2Inserts(sTable)
  if(type(sTable) ~= "string") then return end
  local TableKey = LibTablePrefix..sTable
  if(not LibTables[TableKey]) then return end
  local defTable = LibTables[TableKey]
  if(not file.Exists(LibBASPath,"DATA")) then
    file.CreateDir(LibBASPath)
  end
  if(not file.Exists(LibBASPath..LibEXPPath,"DATA")) then
    file.CreateDir(LibBASPath..LibEXPPath)
  end
  local F = file.Open(LibBASPath..LibEXPPath..
                      "sql2inserts_"..TableKey..".txt", "w", "DATA" )
  if(not F) then
    LogInstance("ExportSQL2Inserts: file.Open("..LibBASPath..LibEXPPath
                                               .."sql2inserts_"..TableKey..".txt) Failed")
    return
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
      F:Write("Function ExportSQL2Inserts: \n\n")
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
     F:Write("ExportSQL2Inserts: "..GetSQLBuildError() .. "\n")
  end
  F:Flush()
  F:Close()
end

function ExportLua2Inserts(tTable,sName)
  if(not tTable) then return end
  if(not file.Exists(LibBASPath,"DATA")) then
    file.CreateDir(LibBASPath)
  end
  if(not file.Exists(LibBASPath..LibEXPPath,"DATA")) then
    file.CreateDir(LibBASPath..LibEXPPath)
  end
  local F = file.Open(LibBASPath..
                      LibEXPPath..
                      "lua2inserts_"..(sName or "Data")..".txt", "w", "DATA" )
  if(not F) then
    LogInstance("ExportLua2Inserts: file.Open("..LibBASPath..LibEXPPath
              .."lua2inserts_"..(sName or "Data")..".txt) Failed")
    return
  end
  if(tTable) then
    F:Write("Exported on: "..os.date().."\n")
    F:Write("Function ExportLua2Inserts: \n\n")
    local Sorted = LibSort(tTable,{1,3,4,2})
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
 * sSuffix = Something that separates exported table from the rest ( e.g. db_)
 * sTable  = Definition KEY to export to
 * sDelim  = Delimiter CHAR data separator
 * bCommit = true to insert the read values
]]
function SQLImportFromDSV(sSuffix,sTable,sDelim,bCommit)
  if(type(sTable) ~= "string") then return end
  local TableKey = LibTablePrefix..sTable
  if(not LibTables[TableKey]) then
    LogInstance("SQLImportFromDSV: Missing: Table definition for "..sTable)
    return
  end
  local F = file.Open(LibBASPath..LibDSVPath..(sSuffix or "")..TableKey..".txt", "r", "DATA" )
  if(not F) then
    LogInstance("SQLImportFromDSV: file.Open("..LibBASPath..LibDSVPath..
               (sSuffix or "")..TableKey..".txt) Failed")
    return
  end
  local Line = ""
  local TabLen = string.len(TableKey)
  local LinLen = 0
  local ComCnt = 0
  local Ch = LibSymDisable
  while(Ch) do
    Ch = F:Read(1)
    if(not Ch) then return end
    if(Ch == "\n") then
      LinLen = string.len(Line)
      if(string.sub(Line,LinLen,LinLen) == "\r") then
        Line = string.sub(Line,1,LinLen-1)
        LinLen = LinLen - 1
      end
      if(not (string.sub(Line,1,1) == LibSymDisable)) then
        if(string.sub(Line,1,TabLen) == TableKey) then
          local Data = StringExplode(string.sub(Line,TabLen+2,LinLen),sDelim)
          for k,v in pairs(Data) do
            local VLen = string.len(v)
            if(string.sub(v,1,1) == "\"" and string.sub(v,VLen,VLen) == "\"") then
              Data[k] = string.sub(v,2,VLen-1)
            end
          end
          if(bCommit) then
            SQLInsertRecord(sTable,Data)
          end
        end
      end
      Line = ""
    else
      Line = Line .. Ch
    end
  end
  F:Close()
end

function SQLExportIntoDSV(sSuffix,sTable,sDelim)
  if(type(sTable) ~= "string") then return end
  local TableKey = LibTablePrefix..sTable
  if(not LibTables[TableKey]) then
    LogInstance("SQLExportIntoDSV: Missing: Table definition for "..tostring(sTable))
    return
  end
  local defTable = LibTables[TableKey]
  if(not file.Exists(LibBASPath,"DATA")) then
    file.CreateDir(LibBASPath)
  end
  if(not file.Exists(LibBASPath..LibDSVPath,"DATA")) then
    file.CreateDir(LibBASPath..LibDSVPath)
  end
  local F = file.Open(LibBASPath..LibDSVPath..(sSuffix or "")..TableKey..".txt", "w", "DATA" )
  if(not F) then
    LogInstance("SQLExportIntoDSV: file.Open("..LibBASPath..LibDSVPath..
               (sSuffix or "")..TableKey..".txt) Failed")
    return
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
          Line = Line .. sDelim
        end
        Cnt = Cnt + 1
      end
      F:Write(Line .. "\n")
      Cnt = 1
      while(qData[Cnt]) do
        Line = TableKey .. sDelim
        local qRec = qData[Cnt]
        local Ind  = 1
        while(defTable[Ind]) do
          local f = defTable[Ind][1]
          if(not f) then
            LogInstance("SQLExportIntoDSV: Missing field name in table "..sTable.." index #"..Ind)
            return
          end
          local v = tostring(qRec[f]) or ""
          Line = Line .. v
          if(defTable[Ind+1]) then
            Line = Line .. sDelim
          end
          Ind = Ind + 1
          v = qRec[defTable[Ind]]
        end
        F:Write(Line .. "\n")
        Cnt = Cnt + 1
      end
    end
  else
    LogInstance("SQLExportIntoDSV: Failed to assemble query >> "
                  ..GetSQLBuildError())
    return
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
  if(Mode ~= 0 and oRec) then
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
 * sModel        = Piece model
 * ucsPos(X,Y,Z) = Offset position
 * ucsAng(P,Y,R) = Offset angle
]]--

function GetNORSpawn(stTrace, sModel, ucsPosX, ucsPosY, ucsPosZ,
                     ucsAngP, ucsAngY, ucsAngR)
  if(not stTrace) then return nil end
  if(not stTrace.Hit) then return nil end
  local hdRec = CacheQueryPiece(sModel)
  if(not hdRec) then return nil end
  local stSpawn = LibSpawn["NOR"]
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
  AddAngle(stSpawn.SAng,hdRec.A)
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
 * nRotAng       = Start pifor angle to rotate trAng to
 * hdModel       = Node:Model()
 * enIgnTyp      = Ignore Gear Type
 * enOrAngTr     = F,R,U Come from trace's angles
 * ucsPos(X,Y,Z) = Offset position
 * ucsAng(P,Y,R) = Offset angle
]]--
function GetENTSpawn(trEnt,nRotPivot,hdModel,enIgnTyp,enOrAngTr,
                     ucsPosX,ucsPosY,ucsPosZ,
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
  local stSpawn = LibSpawn["ENT"]

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
  stSpawn.SAng:RotateAroundAxis(stSpawn.SAng:Right(),trRec.Mesh + ucsAngP)
  stSpawn.SAng:RotateAroundAxis(stSpawn.SAng:Forward(),ucsAngR)
  stSpawn.F:Set(stSpawn.SAng:Forward())
  stSpawn.R:Set(stSpawn.SAng:Right())
  stSpawn.U:Set(stSpawn.SAng:Up())
  -- Save our records
  stSpawn.HRec = hdRec
  stSpawn.TRec = trRec
  -- Get the new Domain
  stSpawn.DAng:Set(stSpawn.SAng)
  stSpawn.DAng:RotateAroundAxis(stSpawn.DAng:Right(),hdRec.Mesh)
  stSpawn.DAng:RotateAroundAxis(stSpawn.DAng:Up(),ucsAngY + 180)
  -- Get Hold model stuff

  SetAngle(stSpawn.MAng, hdRec.A)
  NegAngle(stSpawn.MAng)
  
  SetVector(stSpawn.MPos, hdRec.O)
  stSpawn.MPos:Rotate(stSpawn.MAng)
  
  NegAngle(stSpawn.MAng)
  
  stSpawn.MAng:RotateAroundAxis(stSpawn.MAng:Up(),180)
  stSpawn.MAng:RotateAroundAxis(stSpawn.MAng:Right(),hdRec.Mesh)
  NegVector(stSpawn.MPos)
  stSpawn.MPos:Set(DecomposeByAngle(stSpawn.MPos,stSpawn.MAng))

  SetAngle(stSpawn.MAng,hdRec.A)
  NegAngle(stSpawn.MAng)
  
  stSpawn.SAng:Set(stSpawn.DAng)
  stSpawn.SAng:RotateAroundAxis(stSpawn.DAng:Right()  ,stSpawn.MAng[caP] * hdRec.A[csX])
  stSpawn.SAng:RotateAroundAxis(stSpawn.DAng:Forward(),stSpawn.MAng[caY] * hdRec.A[csY])
  stSpawn.SAng:RotateAroundAxis(stSpawn.DAng:Up()     ,stSpawn.MAng[caR] * hdRec.A[csZ])

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

function GetBodygroupTrace()
  local Ply = LocalPlayer()
  if(not Ply) then return "" end
  local tr  = Ply:GetEyeTrace()
  if(not tr) then return "" end
  if(tr.HitWorld) then return "" end
  local trEnt = tr.Entity
  if(trEnt and trEnt:IsValid()) then
    LogInstance("GetBodygroupTrace: ")
    if(IsOther(trEnt)) then return "" end
    local BG = trEnt:GetBodyGroups()
    if(not (BG and BG[1])) then return "" end
    Print(BG,"GetBodygroupTrace: BG")
    local Result = ""
    local Cnt = 1
    while(BG[Cnt]) do
      Result = Result .. "," .. (trEnt:GetBodygroup(BG[Cnt].id) or 0)
      Cnt = Cnt + 1
    end
    return string.sub(Result,2,string.len(Result))
  end
  return ""
end

function AttachBodyGroups(ePiece,sBgrpIDs)
  LogInstance("AttachBodyGroups: ")
  local NumBG     = ePiece:GetNumBodyGroups()
  LogInstance("BG: "..sBgrpIDs)
  LogInstance("NU: "..NumBG)
  local IDs = Str2BGID(sBgrpIDs,NumBG)
  if(not IDs) then return end
  local BG = ePiece:GetBodyGroups()
  Print(IDs,"IDs")
  Print(BG,"BodyGroups")
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

function GetSkinTrace()
  local Ply = LocalPlayer()
  if(not Ply) then return "" end
  local tr  = Ply:GetEyeTrace()
  if(not tr) then return "" end
  if(tr.HitWorld) then return "" end
  local trEnt = tr.Entity
  if(trEnt and trEnt:IsValid()) then
    LogInstance("GetSkinTrace: ")
    if(IsOther(trEnt)) then return "" end
    local Skin = trEnt:GetSkin()
    if(not Skin) then return "" end
    Print(BG,"GetSkinTrace: Skin")
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
      LogInstance("GEARASSEMBLY: HookOnRemove > Nil value on index "..Ind..", ignored !")
      return
    end
    oEnt:DeleteOnRemove(arCTable[Ind])
    oBas:DeleteOnRemove(arCTable[Ind])
    Ind = Ind + 1
  end
  LogInstance("GEARASSEMBLY: HookOnRemove > Done "..(Ind-1).." of "..nMax..".")
  return
end

PrintInstance("GEARASSEMBLY: Library loaded successfully !")
