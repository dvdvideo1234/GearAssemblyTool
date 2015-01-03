-- INITIALIZE DB
gearasmlib.SQLCreateTable("GEARASSEMBLY_PIECES",{{1},{2},{3},{1,4},{1,2},{2,4},{1,2,3}},true)

------ PIECES ------
--- PHX Gear
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/Mechanics/gears2/gear_12t1.mdl", "PHX Regular", "#", 0, "14, 0, 0", "", " 0.024772670120001, -0.0039097801782191,  3.7019141529981e-008"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_12t3.mdl", "PHX Regular", "#", 0, "14, 0, 0", "", "-0.00028943095821887,0.010859239846468,   0.0029602686408907"  })
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_12t2.mdl", "PHX Regular", "#", 0, "14, 0, 0", "", "-0.017006939277053,  0.0030655609443784, -0.00057022727560252" })
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_18t1.mdl", "PHX Regular", "#", 0, "20, 0, 0", "", " 0.0069116964004934, 0.0010486841201782, -0.00013630707690027" })
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_18t2.mdl", "PHX Regular", "#", 0, "20, 0, 0", "", "-0.010480961762369, -0.00094905123114586,-0.00027210538974032" })
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_18t3.mdl", "PHX Regular", "#", 0, "20, 0, 0", "", "-0.0040156506001949, 0.0044087348505855, -0.0016298928530887"  })
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_24t1.mdl", "PHX Regular", "#", 0, "26, 0, 0", "", "0.0005555086536333,0.0018403908470646,7.969097350724e-005"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_24t2.mdl", "PHX Regular", "#", 0, "26, 0, 0", "", "0.0001849096006481,-0.002116076881066,0.00092169753042981"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_24t3.mdl", "PHX Regular", "#", 0, "26, 0, 0", "", "-0.0039519360288978,-0.00076565862400457,0.00095280521782115"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_36t1.mdl", "PHX Regular", "#", 0, "38, 0, 0", "", "-0.013952384702861,-0.015051824972034,-3.6770456063095e-005"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_36t2.mdl", "PHX Regular", "#", 0, "38, 0, 0", "", "-0.001660150825046,0.0067499200813472,7.3757772042882e-005"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_36t3.mdl", "PHX Regular", "#", 0, "38, 0, 0", "", "-0.012223065830767,-0.0013654727954417,-0.00044102084939368"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_48t1.mdl", "PHX Regular", "#", 0, "50, 0, 0", "", "0.0015389173058793,0.003474734723568,0.00028770981589332"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_48t2.mdl", "PHX Regular", "#", 0, "50, 0, 0", "", "0.0030889171175659,-0.00082554836990312,-8.9276603830513e-005"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_48t3.mdl", "PHX Regular", "#", 0, "50, 0, 0", "", "-0.00083220232045278,-0.00013183639384806,-0.0028226880822331"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_60t1.mdl", "PHX Regular", "#", 0, "62, 0, 0", "", "0.017997905611992,-0.008360886014998,0.00023668861831538"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_60t2.mdl", "PHX Regular", "#", 0, "62, 0, 0", "", "-0.0077802902087569,0.0077699818648398,-0.00011245282075834"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/gear_60t3.mdl", "PHX Regular", "#", 0, "62, 0, 0", "", "-0.00085410091560334,0.0053461473435163,-0.00029574517975561"})
--- PHX Vertical
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/Mechanics/gears2/vert_18t1.mdl", "PHX Vertical", "#", 90, "19.78, 0, 5.6", "", "-9.3372744913722e-007,-1.4464712876361e-006,-1.4973667860031"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/vert_12t1.mdl", "PHX Vertical", "#", 90, "13.78, 0, 5.6", "", "-6.1126132777645e-007,4.6880626314305e-007,-1.4130713939667"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/vert_24t1.mdl", "PHX Vertical", "#", 90, "25.78, 0, 5.6", "", "-0.0046720593236387,-0.0090785603970289,-1.5481045246124"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/vert_36t1.mdl", "PHX Vertical", "#", 90, "37.78, 0, 5.6", "", "0.0043581933714449,-0.00018005351012107,-1.6056708097458"})
--- PHX Bevel
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/bevel_12t1.mdl", "PHX Bevel", "#", 45, "12.2, 0, 1.3", "", "-0.0026455507613719,-0.0061479024589062,-0.87438750267029"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/Mechanics/gears2/bevel_18t1.mdl", "PHX Bevel", "#", 45, "17.3, 0, 1.3", "", "-0.033187858760357,0.0065126456320286,-1.0525280237198"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/bevel_24t1.mdl", "PHX Bevel", "#", 45, "23.3, 0, 1.3", "", "-0.0011872322065756,0.0026002936065197,-0.86795377731323"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/bevel_36t1.mdl", "PHX Bevel", "#", 45, "34.8, 0, 1.3", "", "0.00066847755806521,0.0034906349610537,-0.86690950393677"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/bevel_48t1.mdl", "PHX Bevel", "#", 45, "46.7, 0, 1.3", "", "-0.012435931712389,-0.012925148941576,-0.73237001895905"})
gearasmlib.SQLInsertRecord("GEARASSEMBLY_PIECES",{"models/mechanics/gears2/bevel_60t1.mdl", "PHX Bevel", "#", 45, "58.6, 0, 1.3", "", "-9.5774739747867e-005,0.0057542459107935,-0.7312148809433"})



TOOL.Category   = "Construction"   -- Name of the category
TOOL.Name       = "#Gear Assembly" -- Name to display
TOOL.Command    = nil              -- Command on click (nil for default)
TOOL.ConfigName = ""               -- Config file name (nil for default)

TOOL.ClientConVar = {
  [ "mass"      ] = "25000",
  [ "mode"      ] = "asdf",
  [ "model"     ] = "models/props_phx/trains/tracks/track_1x.mdl",
  [ "nextx"     ] = "0",
  [ "nexty"     ] = "0",
  [ "nextz"     ] = "0",
  [ "count"     ] = "1",
  [ "freeze"    ] = "0",
  [ "advise"    ] = "1",
  [ "igntyp"    ] = "0",
  [ "rotbase"   ] = "0",
  [ "nextpic"   ] = "0",
  [ "nextyaw"   ] = "0",
  [ "nextrol"   ] = "0",
  [ "enghost"   ] = "0",
  [ "addinfo"   ] = "0",
  [ "debugen"   ] = "0",
  [ "maxlogs"   ] = "10000",
  [ "logfile"   ] = "gearasmlib_log",
  [ "bgrpids"   ] = "",
  [ "exportdb"  ] = "0",
  [ "maxstatts" ] = "3",
  [ "engravity" ] = "1"
}

----------------- TOOL Parameters ----------------

--- Toolgun Background texture ID reference
local txToolgunBackground

--- Render Base Colors
local stDrawColors = {
  Red   = Color(255, 0 , 0 ,255),
  Green = Color( 0 ,255, 0 ,255),
  Blue  = Color( 0 , 0 ,255,255),
  Cyan  = Color( 0 ,255,255,255),
  Magen = Color(255, 0 ,255,255),
  Yello = Color(255,255, 0 ,255),
  White = Color(255,255,255,255),
  Black = Color( 0 , 0 , 0 ,255)
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

---------------- Localizing Libraries ----------------

local Vector            = Vector
local Angle             = Angle
local Color             = Color
local pairs             = pairs
local ipairs            = ipairs
local print             = print
local tostring          = tostring
local tonumber          = tonumber
local type              = type
local LocalPlayer       = LocalPlayer
local IsValid           = IsValid
local RunConsoleCommand = RunConsoleCommand
local GetConVarString   = GetConVarString
local math              = math
local string            = string
local ents              = ents
local util              = util
local concommand        = concommand
local cleanup           = cleanup
local undo              = undo
local duplicator        = duplicator
local constraint        = constraint
local sql               = sql
local os                = os
local file              = file

------------- LOCAL FUNCTIONS AND STUFF ----------------

if CLIENT then
  language.Add( "Tool.gearassembly.name", "Gear Assembly" )
  language.Add( "Tool.gearassembly.desc", "Assembles gears to mesh together" )
  language.Add( "Tool.gearassembly.0", "Left Click to continue the track, Right to change active position, Reload to remove a piece" )
  language.Add( "Cleanup.gearassembly", "Track Assembly" )
  language.Add( "Cleaned.gearassemblys", "Cleaned up all Pieces" )

  local function ResetOffsets( ply, command, arguments )
    -- Reset all of the offset options to zero
    ply:ConCommand( "gearassembly_rotbase 0\n" )
    ply:ConCommand( "gearassembly_nextpic 0\n" )
    ply:ConCommand( "gearassembly_nextyaw 0\n" )
    ply:ConCommand( "gearassembly_nextrol 0\n" )
    ply:ConCommand( "gearassembly_nextx 0\n" )
    ply:ConCommand( "gearassembly_nexty 0\n" )
    ply:ConCommand( "gearassembly_nextz 0\n" )
  end
  concommand.Add( "gearassembly_resetoffs", ResetOffsets )
  txToolgunBackground = surface.GetTextureID( "vgui/white" )
end

if SERVER then
  cleanup.Register("GEARASSEMBLYs")
end

local function SnapAngleYaw(aAng, nYSnap)
  if(aAng and nYSnap and (nYSnap > 0)) then
    aAng[caY] = gearasmlib.SnapValue(aAng[caY],nYSnap)
  end
end

local function eMakePiece(sModel,vPos,aAng,nMass,sBgrpIDs)
  -- You never know .. ^_^
  if(not util.IsValidModel(sModel)) then return nil end
  local stPiece = gearasmlib.CacheQueryPiece(sModel)
  if(not stPiece) then return nil end -- Not present in the DB
  local ePiece = ents.Create("prop_physics")
  if(ePiece and ePiece:IsValid()) then
    ePiece:SetCollisionGroup(COLLISION_GROUP_NONE );
    ePiece:SetSolid( SOLID_VPHYSICS );
    ePiece:SetMoveType( MOVETYPE_VPHYSICS )
    ePiece:SetNotSolid( false );
    ePiece:SetModel( sModel )
    ePiece:SetPos( vPos )
    ePiece:SetAngles( aAng )
    ePiece:Spawn()
    ePiece:Activate()
    ePiece:SetColor( Color( 255, 255, 255, 255 ) )
    ePiece:SetRenderMode( RENDERMODE_TRANSALPHA )
    ePiece:DrawShadow( true )
    ePiece:PhysWake()
    local phPiece = ePiece:GetPhysicsObject()
    if(phPiece and phPiece:IsValid()) then
      phPiece:SetMass(nMass)
      phPiece:EnableMotion(false)
      gearasmlib.AttachBodyGroups(ePiece,sBgrpIDs)
      return ePiece
    end
    ePiece:Remove()
    return nil
  end
  return nil
end

local function SetupPiece(ePiece,nFr,nG)
  --- Bordered with UNDO functions !!!
  if(ePiece and ePiece:IsValid()) then
    local pyPiece = ePiece:GetPhysicsObject()
    if(pyPiece and pyPiece:IsValid()) then
      if(nFr and nFr == 0) then
        pyPiece:EnableMotion(true)
      end
      if(not (nG and nG ~= 0)) then
        construct.SetPhysProp(nil,ePiece,0,pyPiece,{GravityToggle = false})
      end
      construct.SetPhysProp(nil,ePiece,0,pyPiece,{Material = "gmod_ice"})
    end
  end
end

local function EmitSoundPly(pPly)
  if(not pPly) then return end
  pPly:EmitSound("physics/metal/metal_canister_impact_hard"..math.floor(math.random(3))..".wav")
end

local function PrintNotify(pPly,sText,sNotifType)
  if(not pPly) then return end
  if(SERVER) then
    pPly:SendLua("GAMEMODE:AddNotify(\""..sText.."\", NOTIFY_"..sNotifType..", 6)")
    pPly:SendLua("surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
  end
end

function PrintModifOffsetMC(ePiece,stSpawn)
  if(not ePiece) then print("N/A") end
  local MC = gearasmlib.GetMCWorld(ePiece,stSpawn.HRec.M.U)
  local OffW = stSpawn.OPos - MC
  local BasS = Angle()
        BasS:Set(stSpawn.SAng)
        BasS:RotateAroundAxis(stSpawn.SAng:Up(),180)
        OffW:Set(gearasmlib.DecomposeByAngle(OffW,BasS))
        print(OffW)
end

function TOOL:LeftClick( Trace )
  if(CLIENT) then return true end
  if(not Trace) then return false end
  if(not Trace.Hit) then return false end
  local trEnt     = Trace.Entity
  local model     = self:GetClientInfo("model")
  local freeze    = self:GetClientNumber("freeze") or 0
  local igntyp    = self:GetClientNumber("igntyp") or 0
  local mass      = math.Clamp(self:GetClientNumber("mass"),1,50000)
  local nextpic   = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
  local nextyaw   = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
  local nextrol   = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
  local rotbase   = math.Clamp(self:GetClientNumber("rotbase") or 0,-360,360)
  local nextx     = self:GetClientNumber("nextx") or 0
  local nexty     = self:GetClientNumber("nexty") or 0
  local nextz     = self:GetClientNumber("nextz") or 0
  local count     = math.Clamp(self:GetClientNumber("count"),1,200)
  local staatts   = math.Clamp(self:GetClientNumber("maxstaatts"),1,5)
  local bgrpids   = self:GetClientInfo("bgrpids") or ""
  local engravity = self:GetClientNumber("engravity") or 0
  local ply       = self:GetOwner()
  gearasmlib.PlyLoadKey(ply)
  if(Trace.HitWorld) then
  -- Spawn it on the map ...
    local ePiece = eMakePiece(model,Trace.HitPos,Angle(),mass,bgrpids)
    if(ePiece) then
    local aAng = ply:GetAimVector():Angle()
          aAng[caP] = 0
          aAng[caR] = 0
      local stSpawn = gearasmlib.GetMAPSpawn(model,Trace.HitPos,aAng,
                                             Vector(nextx,nexty,nextz),
                                             Angle(nextpic,nextyaw,nextrol))
      if(not stSpawn) then return false end
      local vBBMin = ePiece:OBBMins()
      ePiece:SetAngles(stSpawn.SAng)
      stSpawn.SPos:Add(gearasmlib.GetMCWorldOffset(ePiece))
      stSpawn.SPos:Add(-vBBMin[cvZ] * Trace.HitNormal)
      if(util.IsInWorld(stSpawn.SPos)) then
        ePiece:SetPos(stSpawn.SPos)
      else
        ePiece:Remove()
        PrintNotify(ply,"Position out of map bounds!","ERROR")
        gearasmlib.Log("GEARASSEMBLY: Additioal Error INFO"
        .."\n   Event  : Spawning when Trace.HitWorld"
        .."\n   MCspawn: "..mcspawn
        .."\n   Player : "..ply:Nick()
        .."\n   hdModel: "..gearasmlib.GetModelFileName(model).."\n")
        return true
      end
      undo.Create("Last Track Assembly")
      SetupPiece(ePiece,freeze,engravity)
      EmitSoundPly(ply)
      undo.AddEntity(ePiece)
      undo.SetPlayer(ply)
      undo.SetCustomUndoText( "Undone Assembly ( World Spawn )" )
      undo.Finish()
      return true
    end
    return false
  end
  -- Hit Prop
  if(not util.IsValidModel(model)) then return false end
  if(not trEnt) then return false end
  if(not trEnt:IsValid()) then return false end
  if(not gearasmlib.IsPhysTrace(Trace)) then return false end
  if(gearasmlib.IsOther(trEnt)) then return false end

  local trModel = trEnt:GetModel()
  local trAngle = trEnt:GetAngles()

  --No need stacking relative to non-persistent props or using them...
  local trRec   = gearasmlib.CacheQueryPiece(trModel)
  local hdRec   = gearasmlib.CacheQueryPiece(model)
  
  if(not trRec) then return false end

  if(gearasmlib.PlyLoadKey(ply,"USE")) then
    -- IN_Use: Use the VALID Trace.Entity as a piece
    PrintNotify(ply,"Model: "..gearasmlib.GetModelFileName(trModel).." selected !","GENERIC")
    ply:ConCommand("gearassembly_model "..trModel.."\n")
    return true
  end
  
  if(not hdRec) then return false end

  if(count > 1 and
     gearasmlib.PlyLoadKey(ply,"SPEED")
  ) then
     -- IN_Speed: Switch the tool mode
    local stSpawn = gearasmlib.GetENTSpawn(trEnt,rotbase,model,igntyp,
                                           Vector(nextx,nexty,nextz),
                                           Angle(nextpic,nextyaw,nextrol))
    if(not stSpawn) then return false end
    if(stSpawn.HRec.MaxCN > 1) then
      local ePieceN, ePieceO
      local i       = count
      local nTrys   = staatts
      undo.Create("Last Track Assembly")
      ePieceO = trEnt
      while(i > 0) do
        ePieceN = eMakePiece(model,ePieceO:GetPos(),Angle(),mass,bgrpids)
        if(ePieceN) then
          if(util.IsInWorld(stSpawn.SPos)) then
            ePieceN:SetPos(stSpawn.SPos)
          else
            ePieceN:Remove()
            PrintNotify(ply,"Position out of map bounds!","ERROR")
            gearasmlib.Log("GEARASSEMBLY: Additioal Error INFO"
            .."\n   Event  : Stacking when available"
            .."\n   Iterats: "..tostring(count-i)
            .."\n   StackTr: "..tostring( nTrys ).." ?= "..tostring(staatts)
            .."\n   pointID: "..tostring(pointid).." >> "..tostring(pnextid)
            .."\n   Player : "..ply:Nick()
            .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
            .."\n   hdModel: "..gearasmlib.GetModelFileName(model).. "\n")
            EmitSoundPly(ply)
            undo.SetPlayer(ply)
            undo.SetCustomUndoText( "Undone Assembly ( Stack #"..tostring(count-i).." )" )
            undo.Finish()
            return true
          end
          ePieceN:SetAngles(stSpawn.SAng)
          SetupPiece(ePieceN,freeze,engravity)
          undo.AddEntity(ePieceN)
          local stSpawn = gearasmlib.GetENTSpawn(trEnt,rotbase,model,igntyp,
                                                 Vector(nextx,nexty,nextz),
                                                 Angle(nextpic,nextyaw,nextrol))
          if(not stSpawn) then
            PrintNotify(ply,"Cannot obtain spawn data!","ERROR")
            gearasmlib.Log("GEARASSEMBLY: Additioal Error INFO"
            .."\n   Event  : Invalid User data"
            .."\n   Iterats: "..tostring(count-i)
            .."\n   StackTr: "..tostring( nTrys ).." ?= "..tostring(staatts)
            .."\n   pointID: "..tostring(pointid).." >> "..tostring(pnextid)
            .."\n   Player : "..ply:Nick()
            .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
            .."\n   hdModel: "..gearasmlib.GetModelFileName(model).. "\n")
            EmitSoundPly(ply)
            undo.SetPlayer(ply)
            undo.SetCustomUndoText( "Undone Assembly ( Stack #"..tostring(count-i).." )" )
            undo.Finish()
            return true
          end
          ePieceO = ePieceN
          i = i - 1
          nTrys = staatts
        else
          nTrys = nTrys - 1
        end
        if(nTrys <= 0) then
          PrintNotify(ply,"Spawn attemts ran off!","ERROR")
          gearasmlib.Log("GEARASSEMBLY: Additioal Error INFO"
          .."\n   Event   : Failed to allocate memory for a piece"
          .."\n   Iterats: "..tostring(count-i)
          .."\n   StackTr: "..tostring( nTrys ).." ?= "..tostring(staatts)
          .."\n   pointID: "..tostring(pointid).." >> "..tostring(pnextid)
          .."\n   Player : "..ply:Nick()
          .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
          .."\n   hdModel: "..gearasmlib.GetModelFileName(model).. "\n")
          EmitSoundPly(ply)
          undo.SetPlayer(ply)
          undo.SetCustomUndoText( "Undone Assembly ( Stack #"..tostring(count-i).." )" )
          undo.Finish()
          return true
        end
      end
      EmitSoundPly(ply)
      undo.SetPlayer(ply)
      undo.SetCustomUndoText( "Undone Assembly ( Stack #"..tostring(count-i).." )" )
      undo.Finish()
      return true
    elseif(stSpawn.HRec.MaxCN == 1) then
      gearasmlib.Log("GEARASSEMBLY: Model "..model.." is non-stackable, spawning instead !!")
      ePiece = eMakePiece(model,Trace.HitPos,Angle(),mass,bgrpids)
      if(ePiece) then
        if(util.IsInWorld(stSpawn.SPos)) then
          ePiece:SetPos(stSpawn.SPos)
        else
          ePiece:Remove()
          PrintNotify(ply,"Position out of map bounds !","ERROR")
          gearasmlib.Log("GEARASSEMBLY: Additioal Error INFO"
          .."\n   Event  : Stacking when non available ( spawning instead )"
          .."\n   Player : "..ply:Nick()
          .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
          .."\n   hdModel: "..gearasmlib.GetModelFileName(model).. "\n")
          return true
        end
        ePiece:SetAngles(stSpawn.SAng)
        undo.Create("Last Track Assembly")
        SetupPiece(ePiece,freeze,engravity)
        EmitSoundPly(ply)
        undo.AddEntity(ePiece)
        undo.SetPlayer(ply)
        undo.SetCustomUndoText( "Undone Assembly ( Spawn Instead )" )
        undo.Finish()
        return true
      end
    end
    return false
  end
  
  local stSpawn = gearasmlib.GetENTSpawn(trEnt,rotbase,model,igntyp,
                                         Vector(nextx,nexty,nextz),
                                         Angle(nextpic,nextyaw,nextrol))
  if(stSpawn) then
    local ePiece = eMakePiece(model,Trace.HitPos,Angle(),mass,bgrpids)
    if(ePiece) then
      ePiece:SetAngles(stSpawn.SAng)
      if(util.IsInWorld(stSpawn.SPos)) then
        gearasmlib.SetMCWorld(ePiece,stSpawn.HRec.M.U,stSpawn.SPos)
      else
        ePiece:Remove()
        PrintNotify(ply,"Position out of map bounds !","ERROR")
        gearasmlib.Log("GEARASSEMBLY: Additioal Error INFO"
        .."\n   Event  : Spawn one piece relative to another"
        .."\n   Player : "..ply:Nick()
        .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
        .."\n   hdModel: "..gearasmlib.GetModelFileName(model).."\n")
        return true
      end
      PrintModifOffsetMC(ePiece,stSpawn)
      undo.Create("Last Track Assembly")
      SetupPiece(ePiece,freeze,engravity)
      EmitSoundPly(ply)
      undo.AddEntity(ePiece)
      undo.SetPlayer(ply)
      undo.SetCustomUndoText( "Undone Assembly ( Prop Relative )" )
      undo.Finish()
      return true
    end
  end
  return false
end

function TOOL:RightClick( Trace )
  -- Change the active point
  if(CLIENT) then return true end
  local model   = self:GetClientInfo("model")
  if(not util.IsValidModel(model)) then return false end
  local hdRec = gearasmlib.CacheQueryPiece(model)
  if(not hdRec) then return false end
end

function TOOL:Reload(Trace)
  if(CLIENT) then return true end
  if(not Trace) then return false end
  local ply       = self:GetOwner()
  local debugen   = self:GetClientNumber("debugen") or 0
  local exportdb  = self:GetClientNumber("exportdb") or 0
  if(debugen ~= 0 and Trace.HitWorld) then
    local maxlogs = self:GetClientNumber("maxlogs") or 0
    local logfile = self:GetClientInfo  ("logfile") or ""
    if(maxlogs > 0) then
      gearasmlib.SetLogControl(debugen,maxlogs,logfile)
    end
  end
  gearasmlib.PlyLoadKey(ply)
  if(Trace.HitWorld and gearasmlib.PlyLoadKey(ply,"SPEED") and exportdb ~= 0) then
    gearasmlib.Log("function TOOL:Reload(Trace) --> Exporting DB ...")
    gearasmlib.ExportSQL2Lua("GEARASSEMBLY_PIECES")
    gearasmlib.ExportSQL2Inserts("GEARASSEMBLY_PIECES")
    gearasmlib.SQLExportIntoDSV("db_","GEARASSEMBLY_PIECES","\t")
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

local function DrawTextRowColor(PosXY,TxT,stColor)
  -- Always Set the font before usage:
  -- e.g. surface.SetFont("Trebuchet18")
  if(not PosXY) then return end
  if(not (PosXY.x and PosXY.y)) then return end
  surface.SetTextPos(PosXY.x,PosXY.y)
  if(stColor) then
    surface.SetTextColor(stColor.r, stColor.g, stColor.b, stColor.a)
  end
  surface.DrawText(TxT)
  PosXY.w, PosXY.h = surface.GetTextSize(TxT)
  PosXY.y = PosXY.y + PosXY.h
end

local function DrawLineColor(PosS,PosE,stColor,w,h)
  if(not (PosS and PosE)) then return end
  if(not (PosS.x and PosS.y and PosE.x and PosE.y)) then return end
  if(stColor) then
    surface.SetDrawColor(stColor.r, stColor.g, stColor.b, stColor.a)
  end
  if(PosS.x < 0 or PosS.x > w) then return end
  if(PosS.y < 0 or PosS.y > h) then return end
  if(PosE.x < 0 or PosE.x > w) then return end
  if(PosE.y < 0 or PosE.y > h) then return end
  surface.DrawLine(PosS.x,PosS.y,PosE.x,PosE.y)
end

function TOOL:DrawHUD()
  if(SERVER) then return end
  local adv   = self:GetClientNumber("advise") or 0
  local ply   = LocalPlayer()
  local Trace = ply:GetEyeTrace()
  if(adv ~= 0) then
    local scrH = surface.ScreenHeight()
    local scrW = surface.ScreenWidth()
    if(not Trace) then return end
    local trEnt   = Trace.Entity
    local model   = self:GetClientInfo("model")
    local nextx   = self:GetClientNumber("nextx") or 0
    local nexty   = self:GetClientNumber("nexty") or 0
    local nextz   = self:GetClientNumber("nextz") or 0
    local nextpic   = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
    local nextyaw   = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
    local nextrol   = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
    local rotbase   = math.Clamp(self:GetClientNumber("rotbase") or 0,-360,360)
    if(trEnt and trEnt:IsValid()) then
      if(gearasmlib.IsOther(trEnt)) then return end
      local actrad  = math.Clamp(self:GetClientNumber("activrad") or 1,1,150)
      local igntyp  = self:GetClientNumber("igntyp") or 0
      local stSpawn = gearasmlib.GetENTSpawn(trEnt,rotbase,model,igntyp,
                                             Vector(nextx,nexty,nextz),
                                             Angle(nextpic,nextyaw,nextrol))
      if(not stSpawn) then return end
      local addinfo = self:GetClientNumber("addinfo") or 0
      stSpawn.F:Mul(15)
      stSpawn.F:Add(stSpawn.OPos)
      stSpawn.R:Mul(15)
      stSpawn.R:Add(stSpawn.OPos)
      stSpawn.U:Mul(15)
      stSpawn.U:Add(stSpawn.OPos)
      local RadScale = math.Clamp(800 / (Trace.HitPos - ply:GetPos()):Length(),1,100)
      local Os = stSpawn.OPos:ToScreen()
      local Ss = stSpawn.SPos:ToScreen()
      local Sa = (stSpawn.SPos + 15 * stSpawn.SAng:Up()):ToScreen()
      local Tp = stSpawn.TPos:ToScreen()
      local Tu = (stSpawn.TPos + 15 * stSpawn.TAng:Up()):ToScreen()
      local Xs = stSpawn.F:ToScreen()
      local Ys = stSpawn.R:ToScreen()
      local Zs = stSpawn.U:ToScreen()
      -- Draw UCS
      DrawLineColor(Os,Xs,stDrawColors.Red  ,scrW,scrH)
      DrawLineColor(Os,Ys,stDrawColors.Green,scrW,scrH)
      DrawLineColor(Os,Zs,stDrawColors.Blue ,scrW,scrH)
      DrawLineColor(Tp,Tu,stDrawColors.Yello,scrW,scrH)
      DrawLineColor(Tp,Os,stDrawColors.Green,scrW,scrH)
      surface.DrawCircle( Os.x, Os.y, RadScale, stDrawColors.Yello)
      surface.DrawCircle( Tp.x, Tp.y, RadScale, stDrawColors.Green)
      -- Draw Spawn
      DrawLineColor(Os,Ss,stDrawColors.Magen,scrW,scrH)
      DrawLineColor(Ss,Sa,stDrawColors.Cyan,scrW,scrH)
      surface.DrawCircle( Ss.x, Ss.y, RadScale, stDrawColors.Magen)
      if(addinfo ~= 0) then
        local txPos = {x = 0, y = 0, w = 0, h = 0}
        txPos.x = surface.ScreenWidth() / 2 + 10
        txPos.y = surface.ScreenHeight()/ 2 + 10
        surface.SetFont("Trebuchet18")
        DrawTextRowColor(txPos,"Mod POS: "..tostring(stSpawn.MPos),stDrawColors.Black)
        DrawTextRowColor(txPos,"Mod ANG: "..tostring(stSpawn.MAng))
        DrawTextRowColor(txPos,"Spn POS: "..tostring(stSpawn.SPos))
        DrawTextRowColor(txPos,"Spn ANG: "..tostring(stSpawn.SAng))
      end
    elseif(Trace.HitWorld) then
      local mcspawn  = self:GetClientNumber("mcspawn") or 0
      local autoffsz = self:GetClientNumber("autoffsz") or 0
      local ydegsnp  = math.Clamp(self:GetClientNumber("ydegsnp"),0,180)
      local addinfo = self:GetClientNumber("addinfo") or 0
      local RadScale = math.Clamp(800 / (Trace.HitPos - ply:GetPos()):Length(),1,100)
      local aAng = ply:GetAimVector():Angle()
            aAng[caP] = 0
            aAng[caR] = 0
      local stSpawn = gearasmlib.GetMAPSpawn(model,Trace.HitPos,aAng,
                                             Vector(nextx,nexty,nextz),
                                             Angle(nextpic,nextyaw,nextrol))
      if(stSpawn) then
        stSpawn.F:Mul(15)
        stSpawn.F:Add(stSpawn.OPos)
        stSpawn.R:Mul(15)
        stSpawn.R:Add(stSpawn.OPos)
        stSpawn.U:Mul(15)
        stSpawn.U:Add(stSpawn.OPos)
        local Os = stSpawn.OPos:ToScreen()
        local Ss = stSpawn.SPos:ToScreen()
        local Xs = stSpawn.F:ToScreen()
        local Ys = stSpawn.R:ToScreen()
        local Zs = stSpawn.U:ToScreen()
        -- Draw UCS
        DrawLineColor(Os,Xs,stDrawColors.Red  ,scrW,scrH)
        DrawLineColor(Os,Ys,stDrawColors.Green,scrW,scrH)
        DrawLineColor(Os,Zs,stDrawColors.Blue ,scrW,scrH)
        surface.DrawCircle( Os.x, Os.y, RadScale, stDrawColors.Yello)
        -- Draw Spawn
        DrawLineColor(Os,Ss,stDrawColors.Magen,scrW,scrH)
        DrawLineColor(Os,Pp,stDrawColors.Red  ,scrW,scrH)
        surface.DrawCircle( Ss.x, Ss.y, RadScale, stDrawColors.Cyan)
        if(addinfo ~= 0) then
          local txPos = {x = 0, y = 0, w = 0, h = 0}
          txPos.x = surface.ScreenWidth() / 2 + 10
          txPos.y = surface.ScreenHeight()/ 2 + 10
          surface.SetFont("Trebuchet18")
          DrawTextRowColor(txPos,"Origin : " ..tostring(stSpawn.OPos),stDrawColors.Black)
          DrawTextRowColor(txPos,"Mod POS: " ..tostring(stSpawn.MPos))
          DrawTextRowColor(txPos,"Mod ANG: " ..tostring(stSpawn.MAng))
          DrawTextRowColor(txPos,"Spn POS: " ..tostring(stSpawn.SPos))
          DrawTextRowColor(txPos,"Spn ANG: " ..tostring(stSpawn.SAng))
        end
      end
    end
  end
end

function TOOL:DrawToolScreen(w, h)
  if(SERVER) then return end
  surface.SetTexture( txToolgunBackground )
  surface.SetDrawColor( stDrawColors.Black )
  surface.DrawTexturedRect( 0, 0, w, h )
  surface.SetFont("Trebuchet24")
  local Trace = LocalPlayer():GetEyeTrace()
  local txPos = {x = 0, y = 0, w = 0, h = 0}
  if(not Trace) then
    DrawTextRowColor(txPos,"Trace status: Invalid",stDrawColors.White)
    return
  end
  DrawTextRowColor(txPos,"Trace status: Valid",stDrawColors.White)
  local model = self:GetClientInfo("model")
  if(not util.IsValidModel(model)) then
    DrawTextRowColor(txPos,"Holds Model: Invalid")
    return
  end
  local hdRec = gearasmlib.CacheQueryPiece(model)
  if(not hdRec) then
    DrawTextRowColor(txPos,"Holds Model: Invalid")
    return
  end
  DrawTextRowColor(txPos,"Holds Model: Valid")
  local NoAV  = "N/A"
  local mode  = self:GetClientInfo("mode") or "Sugoi !"
  local trEnt = Trace.Entity
  local trOrig, trModel, trMesh, trRad
  local X = 0
  local Y = 0
  local Z = 0
  if(trEnt and trEnt:IsValid()) then
    if(gearasmlib.IsOther(trEnt)) then return end
          trModel = trEnt:GetModel()
    local trRec   = gearasmlib.CacheQueryPiece(trModel)
          trModel = gearasmlib.GetModelFileName(trModel)
    if(trRec) then
      trMesh = tostring(gearasmlib.RoundValue(trRec.Mesh,0.01)) or NoAV
      trOrig = Vector()
      trOrig:Set(trRec.O.U)
      trRad = gearasmlib.RoundValue(trRec.O.U:Length(),0.1)
      X = trOrig[cvX]
      X = gearasmlib.RoundValue(X,0.1)
      Y = trOrig[cvY]
      Y = gearasmlib.RoundValue(Y,0.1)
      Z = trOrig[cvZ]
      Z = gearasmlib.RoundValue(Z,0.1)
      trOrig = "["..tostring(X)..","..tostring(Y)..","..tostring(Z).."]"
    end
  end
  local hdOrig = Vector()
        hdOrig:Set(hdRec.O.U)
        X = hdOrig[cvX]
        X = gearasmlib.RoundValue(X,0.1)
        Y = hdOrig[cvY]
        Y = gearasmlib.RoundValue(Y,0.1)
        Z = hdOrig[cvZ]
        Z = gearasmlib.RoundValue(Z,0.1)
        hdOrig = "["..tostring(X) ..",".. tostring(Y)..","..tostring(Z).."]"
  local hdRad = gearasmlib.RoundValue(hdRec.O.U:Length(),0.1)
  local Ratio = (trRad or 0) / hdRad
  DrawTextRowColor(txPos,"TM: " .. (trModel or NoAV),stDrawColors.Green)
  DrawTextRowColor(txPos,"TS: " .. (trOrig or NoAV) .. ">" .. (trMesh or NoAV))
  DrawTextRowColor(txPos,"HM: " .. (gearasmlib.GetModelFileName(model) or NoAV),stDrawColors.Magen)
  DrawTextRowColor(txPos,"HS: " .. (hdOrig or NoAV) .. ">" .. tostring(gearasmlib.RoundValue(hdRec.Mesh,0.01) or NoAV))
  DrawTextRowColor(txPos,"Ratio: " .. gearasmlib.RoundValue(Ratio,0.01)..">"..(trRad or NoAV).."/"..hdRad,stDrawColors.Yello)
  DrawTextRowColor(txPos,"Stack mode: "..mode,stDrawColors.Red)
  local sTime = tostring(os.date())
  DrawTextRowColor(txPos,string.sub(sTime,1,8),stDrawColors.White)
  DrawTextRowColor(txPos,string.sub(sTime,10,17))
end

function TOOL.BuildCPanel( CPanel )
  Header = CPanel:AddControl( "Header", { Text        = "#Tool.gearassembly.Name",
                                          Description = "#Tool.gearassembly.desc" }  )
  local CurY = Header:GetTall() + 2

  local Combo         = {}
  Combo["Label"]      = "#Presets"
  Combo["MenuButton"] = "1"
  Combo["Folder"]     = "gearassembly"
  Combo["CVars"]      = {}
  Combo["CVars"][ 1]  = "gearassembly_mass"
  Combo["CVars"][ 2]  = "gearassembly_model"
  Combo["CVars"][ 6]  = "gearassembly_count"
  Combo["CVars"][ 7]  = "gearassembly_freeze"
  Combo["CVars"][ 8]  = "gearassembly_advise"
  Combo["CVars"][ 9]  = "gearassembly_igntyp"
  Combo["CVars"][17]  = "gearassembly_nextpic"
  Combo["CVars"][17]  = "gearassembly_nextyaw"
  Combo["CVars"][17]  = "gearassembly_nextrol"
  Combo["CVars"][18]  = "gearassembly_enghost"
  Combo["CVars"][23]  = "gearassembly_engravity"
  Combo["CVars"][24]  = "gearassembly_physmater"
  Combo["CVars"][ 3]  = "gearassembly_nextx"
  Combo["CVars"][ 4]  = "gearassembly_nexty"
  Combo["CVars"][ 5]  = "gearassembly_nextz"

  CPanel:AddControl("ComboBox",Combo)
  CurY = CurY + 25
  local Sorted  = gearasmlib.PanelQueryPieces()
  local stTable = gearasmlib.GetTableDefinition("GEARASSEMBLY_PIECES")
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
          return self:SetTextStyleColor(Color(161, 161, 161))
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
        RunConsoleCommand("gearassembly_model"  , Model)
      end
    else
      print("GEARASSEMBLY: Model "
             .. Model
             .. " is not available in"
             .. " your system .. SKIPPING !")
    end
    Cnt = Cnt + 1
  end
  CPanel:AddItem(pTree)
  CurY = CurY + pTree:GetTall() + 2
  print("GEARASSEMBLY: Found #"..tostring(Cnt-1).." piece items.")

  -- http://wiki.garrysmod.com/page/Category:DTextEntry
  local pText = vgui.Create("DTextEntry")
        pText:SetPos( 2, 300 )
        pText:SetTall(18)
        pText:SetText(GetConVarString("gearassembly_bgrpids") or
                      "Bodygroup IDs separated with commas > ENTER")
        pText.OnEnter = function( self )
          local sTX = self:GetValue() or ""
          RunConsoleCommand("gearassembly_bgrpids",sTX)
        end
        CurY = CurY + pText:GetTall() + 2

  -- http://wiki.garrysmod.com/page/Category:DButton
  local pButton = vgui.Create("DButton")
        pButton:SetParent(CPanel)
        pButton:SetText("V Click to AUTOFILL Bodygroup IDs list from Trace V")
        pButton:SetPos(2,CurY)
        pButton:SetTall(18)
        pButton.DoClick = function()
          local sBG = gearasmlib.GetBodygroupString()
          pText:SetValue(sBG)
          RunConsoleCommand("gearassembly_bgrpids",sBG)
        end
        CurY = CurY + pButton:GetTall() + 2
  CPanel:AddItem(pButton)
  CPanel:AddItem(pText)

  CPanel:AddControl("Slider", {
            Label   = "Piece mass: ",
            Type    = "Integer",
            Min     = 1,
            Max     = 50000,
            Command = "gearassembly_mass"})

  CPanel:AddControl("Slider", {
            Label   = "Pieces count: ",
            Type    = "Integer",
            Min     = 1,
            Max     = 200,
            Command = "gearassembly_count"})

  CPanel:AddControl( "Button", {
            Label   = "V Reset Offset Values V",
            Command = "gearassembly_resetoffs",
            Text    = "Reset All Offsets" } )
            
  CPanel:AddControl("Slider", {
            Label   = "Pivot rotation: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = "gearassembly_rotbase"})
            
  CPanel:AddControl("Slider", {
            Label   = "Piece rotation: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = "gearassembly_nextyaw"})
          
  CPanel:AddControl("Slider", {
            Label   = "UCS pitch: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = "gearassembly_nextpic"})
            
  CPanel:AddControl("Slider", {
            Label   = "UCS roll: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = "gearassembly_nextrol"})
            
  CPanel:AddControl("Slider", {
            Label   = "Offset X: ",
            Type    = "Float",
            Min     = -100,
            Max     =  100,
            Command = "gearassembly_nextx"})

  CPanel:AddControl("Slider", {
            Label = "Offset Y: ",
            Type  = "Float",
            Min   = -100,
            Max   =  100,
            Command = "gearassembly_nexty"})

  CPanel:AddControl("Slider", {
            Label   = "Offset Z: ",
            Type    = "Float",
            Min     = -100,
            Max     =  100,
            Command = "gearassembly_nextz"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable pieces gravity",
            Command = "gearassembly_engravity"})

  CPanel:AddControl("Checkbox", {
            Label   = "NoCollide new pieces",
            Command = "gearassembly_nocollide"})

  CPanel:AddControl("Checkbox", {
            Label   = "Freeze pieces",
            Command = "gearassembly_freeze"})

  CPanel:AddControl("Checkbox", {
            Label   = "Ignore gear type",
            Command = "gearassembly_igntyp"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable advisor",
            Command = "gearassembly_advise"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable ghosting",
            Command = "gearassembly_enghost"})
end

function TOOL:MakeGhostEntity( sModel, vPos, aAngle )
  -- Check for invalid model
  if(not util.IsValidModel( sModel )) then return end
  util.PrecacheModel( sModel )
  -- We do ghosting serverside in single player
  -- It's done clientside in multiplayer
  if(SERVER and not game.SinglePlayer()) then return end
  if(CLIENT and     game.SinglePlayer()) then return end
  -- Release the old ghost entity
  self:ReleaseGhostEntity()
  if(CLIENT) then
    self.GhostEntity = ents.CreateClientProp(sModel)
  else
    if (util.IsValidRagdoll(sModel)) then
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
  self.GhostEntity:SetModel( sModel )
  self.GhostEntity:SetPos( vPos )
  self.GhostEntity:SetAngles( aAngle )
  self.GhostEntity:Spawn()
  self.GhostEntity:SetSolid( SOLID_VPHYSICS );
  self.GhostEntity:SetMoveType( MOVETYPE_NONE )
  self.GhostEntity:SetNotSolid( true );
  self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
  self.GhostEntity:SetColor( Color( 255, 255, 255, 150 ) )
end

function TOOL:UpdateGhost(oEnt, Ply)
  if not oEnt then return end
  if not oEnt:IsValid() then return end
  local Trace = util.TraceLine(util.GetPlayerTrace(Ply))
  if(not Trace) then return end
  local trEnt = Trace.Entity
  oEnt:SetNoDraw(true)
  if(Trace.HitWorld) then
    local model     = self:GetClientInfo("model")
    local nextpic   = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
    local nextyaw   = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
    local nextrol   = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
    local nextx     = self:GetClientNumber("nextx") or 0
    local nexty     = self:GetClientNumber("nexty") or 0
    local nextz     = self:GetClientNumber("nextz") or 0
    local aAng      = Ply:GetAimVector():Angle()
          aAng[caP] = 0
          aAng[caR] = 0
    local stSpawn = gearasmlib.GetMAPSpawn(model,Trace.HitPos,aAng,
                                           Vector(nextx,nexty,nextz),
                                           Angle(nextpic,nextyaw,nextrol))
    if(not stSpawn) then return end
    local vBBMin = oEnt:OBBMins()
    oEnt:SetAngles(stSpawn.SAng)
    stSpawn.SPos:Add(gearasmlib.GetMCWorldOffset(oEnt))
    stSpawn.SPos:Add(-vBBMin[cvZ] * Trace.HitNormal)
    oEnt:SetPos(stSpawn.SPos)
    oEnt:SetNoDraw(false)
    oEnt:SetRenderMode( RENDERMODE_TRANSALPHA )
    oEnt:SetColor( Color( 255, 255, 255, 150 ) )
  elseif(trEnt and trEnt:IsValid()) then
    if(gearasmlib.IsOther(trEnt)) then return end
    local trRec = gearasmlib.CacheQueryPiece(trEnt:GetModel())
    if(trRec) then
      local model   = self:GetClientInfo("model")
      local igntyp  = self:GetClientNumber("igntyp") or 0
      local nextpic = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
      local nextyaw = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
      local nextrol = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
      local rotbase = math.Clamp(self:GetClientNumber("rotbase") or 0,-360,360)
      local nextx   = self:GetClientNumber("nextx") or 0
      local nexty   = self:GetClientNumber("nexty") or 0
      local nextz   = self:GetClientNumber("nextz") or 0
      local stSpawn = gearasmlib.GetENTSpawn(trEnt,rotbase,model,igntyp,
                                             Vector(nextx,nexty,nextz),
                                             Angle(nextpic,nextyaw,nextrol))
      if(not stSpawn) then return end
      oEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
      oEnt:SetColor(Color(255, 255, 255, 150 ))
      gearasmlib.SetMCWorld(oEnt,stSpawn.HRec.M.U,stSpawn.SPos)
      oEnt:SetAngles(stSpawn.SAng)
      oEnt:SetNoDraw(false)
    end
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
      self:MakeGhostEntity(model, Vector(), Angle())
    end
    self:UpdateGhost(self.GhostEntity, self:GetOwner())
  else
    self:ReleaseGhostEntity()
    if(self.GhostEntity and self.GhostEntity:IsValid()) then
      self.GhostEntity:Remove()
    end
  end
end
