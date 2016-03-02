------ INCLUDE LIBRARY ------
if(SERVER) then
  AddCSLuaFile("gearassembly/gearasmlib.lua")
end
include("gearassembly/gearasmlib.lua")

------ LOCALIZNG FUNCTIONS ---
local tonumber             = tonumber
local tostring             = tostring
local Vector               = Vector
local Angle                = Angle
local IsValid              = IsValid
local bitBor               = bit and bit.bor
local vguiCreate           = vgui and vgui.Create
local fileExists           = file and file.Exists
local stringExplode        = string and string.Explode
local surfaceScreenWidth   = surface and surface.ScreenWidth
local surfaceScreenHeight  = surface and surface.ScreenHeight
local duplicatorStoreEntityModifier = duplicator and duplicator.StoreEntityModifier

------ MODULE POINTER -------
local asmlib = gearasmlib

------ CONFIGURE ASMLIB ------
asmlib.SetIndexes("V",1,2,3)
asmlib.SetIndexes("A",1,2,3)
asmlib.SetIndexes("S",4,5,6,7)
asmlib.InitAssembly("gear")
asmlib.SetOpVar("TOOL_VERSION","4.92")
asmlib.SetOpVar("DIRPATH_BAS",asmlib.GetOpVar("TOOLNAME_NL")..asmlib.GetOpVar("OPSYM_DIRECTORY"))
asmlib.SetOpVar("DIRPATH_EXP","exp"..asmlib.GetOpVar("OPSYM_DIRECTORY"))
asmlib.SetOpVar("DIRPATH_DSV","dsv"..asmlib.GetOpVar("OPSYM_DIRECTORY"))
asmlib.SetOpVar("DIRPATH_LOG","")
asmlib.SetOpVar("MAX_MASS",50000)
asmlib.SetOpVar("MAX_LINEAR",100)
asmlib.SetOpVar("MAX_ROTATION",360)
asmlib.SetOpVar("MAX_FOCELIMIT",1000000)
asmlib.SetOpVar("MAX_BNDERRMODE",4)
asmlib.SetOpVar("CONTAIN_STACK_MODE",asmlib.MakeContainer("Stack Mode"))
asmlib.SetOpVar("CONTAIN_CONSTRAINT_TYPE",asmlib.MakeContainer("Constraint Type"))
asmlib.SetLogControl(0,"gearasmlib_log")

------ CONFIGURE CVARS -----
asmlib.MakeCoVar("enwiremod", "1"  , {0,1  } ,bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_PRINTABLEONLY), "Maximum active radius to search for a point ID")
asmlib.MakeCoVar("devmode"  , "0"  , {0, 1 } ,bitBor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_PRINTABLEONLY), "Toggle the wire extension on/off server side")
asmlib.MakeCoVar("maxstcnt" , "200", {1,200} ,bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_PRINTABLEONLY), "Maximum pieces to spawn in stack mode")
if(SERVER) then
  asmlib.MakeCoVar("bnderrmod", "1" , {0,4}   ,bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_PRINTABLEONLY), "Unreasonable position error handling mode")
  asmlib.MakeCoVar("maxfruse" , "50", {1,100} ,bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_PRINTABLEONLY), "Maximum frequent pieces to be listed")
end
------ CONFIGURE NON-REPLICATED CVARS ----- Client's got a mind of its own
asmlib.MakeCoVar("modedb"   , "SQL", nil, bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_PRINTABLEONLY), "Database operating mode")
asmlib.MakeCoVar("enqstore" ,     1, nil, bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_PRINTABLEONLY), "Enable cache for built queries")
asmlib.MakeCoVar("timermode", "CQT@3600@1@1", nil, bit.bor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_PRINTABLEONLY), "Cache management setting when DB mode is SQL")

------ CONFIGURE MODES -----
asmlib.SetOpVar("MODE_DATABASE" , asmlib.GetCoVar("modedb","STR"))
asmlib.SetOpVar("EN_QUERY_STORE",(asmlib.GetCoVar("enqstore","INT") ~= 0) and true or false)

------ GLOBAL VARIABLES -------
local gsToolPrefL = asmlib.GetOpVar("TOOLNAME_PL")
local gsToolPrefU = asmlib.GetOpVar("TOOLNAME_PU")
local gsToolNameL = asmlib.GetOpVar("TOOLNAME_NL")
local gsToolNameU = asmlib.GetOpVar("TOOLNAME_NU")
local gsInstPrefx = asmlib.GetInstPref()
local gsPathBAS   = asmlib.GetOpVar("DIRPATH_BAS")
local gsPathDSV   = asmlib.GetOpVar("DIRPATH_DSV")
local gsFullDSV   = gsPathBAS..gsPathDSV..gsInstPrefx..gsToolPrefU
local gaTimerSet  = asmlib.StringExplode(asmlib.GetCoVar("timermode","STR"),asmlib.GetOpVar("OPSYM_DIRECTORY"))

------ CONFIGURE TOOL -----   
             
if(SERVER) then

  local SMode = asmlib.GetOpVar("CONTAIN_STACK_MODE")
        SMode:Insert(1,"Forward based")
        SMode:Insert(2,"Around pivot")

  local CType = asmlib.GetOpVar("CONTAIN_CONSTRAINT_TYPE")
        CType:Insert(1 ,{Name = "Free Spawn"  , Make = nil}                     )
        CType:Insert(2 ,{Name = "Parent Piece", Make = nil}                     )
        CType:Insert(3 ,{Name = "Weld Piece"  , Make = constraint.Weld}         )
        CType:Insert(4 ,{Name = "Axis Piece"  , Make = constraint.Axis}         )
        CType:Insert(5 ,{Name = "Ball-Sock HM", Make = constraint.Ballsocket}   )
        CType:Insert(6 ,{Name = "Ball-Sock TM", Make = constraint.Ballsocket}   )
        CType:Insert(7 ,{Name = "AdvBS Lock X", Make = constraint.AdvBallsocket})
        CType:Insert(8 ,{Name = "AdvBS Lock Y", Make = constraint.AdvBallsocket})
        CType:Insert(9 ,{Name = "AdvBS Lock Z", Make = constraint.AdvBallsocket})
        CType:Insert(10,{Name = "AdvBS Spin X", Make = constraint.AdvBallsocket})
        CType:Insert(11,{Name = "AdvBS Spin Y", Make = constraint.AdvBallsocket})
        CType:Insert(12,{Name = "AdvBS Spin Z", Make = constraint.AdvBallsocket})

  asmlib.SetAction("NO_PHYSGUN",
    function(oPly,oEnt,tData)
      if(tData[1]) then
        if(not (oEnt and oEnt:IsValid())) then return end
        oEnt:SetMoveType(MOVETYPE_NONE)
        oEnt:SetUnFreezable(true)
        oEnt.PhysgunDisabled = true
        duplicator.StoreEntityModifier(oEnt,gsToolPrefL.."nophysgun",{[1] = true})
      end
    end)

end

if(CLIENT) then

  local SMode = asmlib.GetOpVar("CONTAIN_STACK_MODE")
        SMode:Insert(1,"Forward based")
        SMode:Insert(2,"Around pivot")

  local CType = asmlib.GetOpVar("CONTAIN_CONSTRAINT_TYPE")
        CType:Insert(1 ,{Name = "Free Spawn"  })
        CType:Insert(2 ,{Name = "Parent Piece"})
        CType:Insert(3 ,{Name = "Weld Piece"  })
        CType:Insert(4 ,{Name = "Axis Piece"  })
        CType:Insert(5 ,{Name = "Ball-Sock HM"})
        CType:Insert(6 ,{Name = "Ball-Sock TM"})
        CType:Insert(7 ,{Name = "AdvBS Lock X"})
        CType:Insert(8 ,{Name = "AdvBS Lock Y"})
        CType:Insert(9 ,{Name = "AdvBS Lock Z"})
        CType:Insert(10,{Name = "AdvBS Spin X"})
        CType:Insert(11,{Name = "AdvBS Spin Y"})
        CType:Insert(12,{Name = "AdvBS Spin Z"})

  asmlib.SetAction("RESET_OFFSETS",
    function(oPly,oCom,oArgs)
      -- Reset all of the offset options to zero
      oPly:ConCommand(gsToolPrefL.."nextx 0\n")
      oPly:ConCommand(gsToolPrefL.."nexty 0\n")
      oPly:ConCommand(gsToolPrefL.."nextz 0\n")
      oPly:ConCommand(gsToolPrefL.."rotpiv 0\n")
      oPly:ConCommand(gsToolPrefL.."nextpic 0\n")
      oPly:ConCommand(gsToolPrefL.."nextyaw 0\n")
      oPly:ConCommand(gsToolPrefL.."nextrol 0\n")
    end)

  asmlib.SetAction("OPEN_FRAME",
    function(oPly,oCom,oArgs)
      local Ind = 1
      local frUsed = asmlib.GetFrequentModels(oArgs[1])
      if(not frUsed) then
        asmlib.StatusLog(false,"OPEN_FRAME: Failed to retrieve most frequent models")
      end
      local defTable = asmlib.GetOpVar("DEFTABLE_PIECES")
      if(not defTable) then return StatusLog(false,"Missing definition for table PIECES") end
      local pnFrame = vgui.Create("DFrame")
      if(not IsValid(pnFrame)) then
        pnFrame:Remove()
        return asmlib.StatusLog(false,"OPEN_FRAME: Failed to create elements frame")
      end
      local pnElements = asmlib.MakeContainer("FREQ_VGUI")
            pnElements:Insert(1,{Label = { "DButton"    ,"ExportDB"   }})
            pnElements:Insert(2,{Label = { "DListView"  ,"ItemRoutine"}})
            pnElements:Insert(3,{Label = { "DModelPanel","ItemScreen" }})
            pnElements:Insert(4,{Label = { "DTextEntry" ,"ItemSearch" }})
            pnElements:Insert(5,{Label = { "DComboBox"  ,"StatSearch" }})
      ------------ Manage the invalid panels -------------------
      local iNdex, iSize, vItem = 1, pnElements:GetSize(), nil
      while(iNdex <= iSize) do
        vItem = pnElements:Select(iNdex)
        asmlib.LogInstance("OPEN_FRAME: Create "..vItem.Label[1].." name "..vItem.Label[2].." ID #"..iNdex)
        vItem.Panel = vgui.Create(vItem.Label[1],pnFrame)
        if(not IsValid(vItem.Panel)) then
          asmlib.LogInstance("OPEN_FRAME: Failed to create "..vItem.Label[1].." name "..vItem.Label[2].." ID #"..iNdex)
          iNdex = iNdex - 1
          while(iNdex >= 1) do
            asmlib.LogInstance("OPEN_FRAME: Delete invalid #"..iNdex)
            pnElements:Select(iNdex):Remove()
          end
          pnFrame:Remove()
          pnElements:Empty() -- Be sure to wipe everything, with pairs
          return StatusLog(false,"OPEN_FRAME: Invalid panel found. Frame removed")
        end
        vItem.Panel:SetName(vItem.Label[2])
        iNdex = iNdex + 1
      end
      ------ Screen resolution and elements -------
      local scrW = surface.ScreenWidth()
      local scrH = surface.ScreenHeight()
      local pnButton     = pnElements:Select(1).Panel
      local pnListView   = pnElements:Select(2).Panel
      local pnModelPanel = pnElements:Select(3).Panel
      local pnTextEntry  = pnElements:Select(4).Panel
      local pnComboBox   = pnElements:Select(5).Panel
      ------------ Frame --------------
      pnFrame:SetTitle("Frequent pieces by "..oPly:GetName().." (Ver."..asmlib.GetOpVar("TOOL_VERSION")..")")
      pnFrame:SetVisible(false)
      pnFrame:SetDraggable(true)
      pnFrame:SetDeleteOnClose(true)
      pnFrame:SetPos(scrW/4, scrH/4)
      pnFrame:SetSize(750, 280)
      pnFrame.OnClose = function()
        pnFrame:SetVisible(false)
        local iNdex, iSize, vItem = 1, pnElements:GetSize(), nil
        while(iNdex <= iSize) do
          asmlib.LogInstance("OPEN_FRAME: Frame.OnClose: Delete #"..iNdex)
          vItem = pnElements:Select(iNdex)
          vItem.Panel:Remove()
          iNdex = iNdex + 1
        end
        pnFrame:Remove()
        pnElements:Empty() -- Be sure to wipe everything, with pairs
        asmlib.LogInstance("OPEN_FRAME: Frame.OnClose: Form removed")
      end
      ------------ ModelPanel --------------
      pnModelPanel:SetParent(pnFrame)
      pnModelPanel:SetPos(500,25)
      pnModelPanel:SetSize(250, 255)
      pnModelPanel:SetVisible(true)
      pnModelPanel.LayoutEntity = function(pnSelf, oEnt)
        if(pnSelf.bAnimated) then
          pnSelf:RunAnimation()
        end
        local uiRec = asmlib.CacheQueryPiece(oEnt:GetModel())
        if(not uiRec) then return end
        local Ang  = Angle(0, RealTime() * 5, 0)
        local uiP, uiY, uiR = asmlib.ExpAngle(uiRec.A)
              asmlib.RotateAngleDir(Ang,"RUF",uiP,uiY,uiR)
        local Pos = asmlib.ToVector(uiRec.M)
        local Rot = Vector()
              Rot:Set(Pos)
              Rot:Rotate(Ang)
              Rot:Mul(-1)
              Rot:Add(Pos)
        oEnt:SetAngles(Ang)
        oEnt:SetPos(Rot)
      end
      ------------ Button --------------
      pnButton:SetParent(pnFrame)
      pnButton:SetText("Export DB")
      pnButton:SetPos(15,30)
      pnButton:SetSize(55,30)
      pnButton:SetVisible(true)
      pnButton.DoClick = function()
        asmlib.LogInstance("OPEN_FRAME: Button.DoClick: <"..pnButton:GetText().."> clicked")
        asmlib.SetLogControl(asmlib.GetCoVar("logsmax", "INT"),
                             asmlib.GetCoVar("logfile", "STR"))
        local ExportDB     = asmlib.GetCoVar("exportdb","INT")
        if(ExportDB ~= 0) then
          asmlib.LogInstance("OPEN_FRAME: Button Exporting DB")
          asmlib.ExportIntoFile("PIECES",",","INS")
          asmlib.ExportIntoFile("PIECES","\t","DSV")
        end
      end
      ------------ ListView --------------
      pnListView:SetParent(pnFrame)
      pnListView:SetVisible(true)
      pnListView:SetMultiSelect(false)
      pnListView:Clear()
      pnListView:SetPos(10,65)
      pnListView:SetSize(480,205)
      pnListView:AddColumn("Used"):SetFixedWidth(55)
      pnListView:AddColumn("Mesh"):SetFixedWidth(35)
      pnListView:AddColumn("Type"):SetFixedWidth(100)
      pnListView:AddColumn("Model"):SetFixedWidth(290)
      pnListView.OnRowSelected = function(pnSelf, nRow, pnLine)
        local uiMod = pnLine:GetColumnText(4)
        pnModelPanel:SetModel(uiMod)
        local uiRec = asmlib.CacheQueryPiece(uiMod)
        if(not uiRec) then
          return asmlib.StatusLog(false,"OPEN_FRAME: Failed to retrieve model "..uiMod)
        end
        -- OBBCenter ModelPanel Configuration --
        local uiEnt = pnModelPanel.Entity
        local uiCen = asmlib.ToVector(uiRec.M)
        local uiEye = uiEnt:LocalToWorld(uiCen)
        asmlib.SubVector(uiCen,uiRec.O)
        local uiLen = uiCen:Length()
        local uiCam = Vector(uiLen, 0, 0.5 * uiLen)
        pnModelPanel:SetLookAt(uiEye)
        pnModelPanel:SetCamPos(2 * uiCam + uiEye)
        oPly:ConCommand(gsToolPrefL.."model "..uiMod.."\n")
      end
       if(not asmlib.UpdateListView(pnListView,frUsed,nCount)) then
        asmlib.StatusLog(false,"OPEN_FRAME: ListView.OnRowSelected: Populate the list view failed")
      end
      ------------- ComboBox ---------------
      pnComboBox:SetParent(pnFrame)
      pnComboBox:SetPos(75,30)
      pnComboBox:SetSize(95,30)
      pnComboBox:SetVisible(true)
      pnComboBox:SetValue("<Search BY>")
      pnComboBox:AddChoice("Model",defTable[1][1])
      pnComboBox:AddChoice("Type" ,defTable[2][1])
      pnComboBox:AddChoice("Name" ,defTable[3][1])
      pnComboBox:AddChoice("Mesh" ,defTable[4][1])
      pnComboBox.OnSelect = function(pnSelf, nInd, sVal, anyData)
        asmlib.LogInstance("OPEN_FRAME: ComboBox.OnSelect: ID #"..nInd.." >> "..sVal.." >> "..tostring(anyData))
        pnSelf:SetValue(sVal)
      end
      ------------ TextEntry --------------
      pnTextEntry:SetParent(pnFrame)
      pnTextEntry:SetPos(175,30)
      pnTextEntry:SetSize(300,30)
      pnTextEntry:SetVisible(true)
      pnTextEntry.OnEnter = function(pnSelf)
        local sName, sField = pnComboBox:GetSelected()
              sName    = tostring(sName  or "")
              sField   = tostring(sField or "")
        local sPattern = tostring(pnSelf:GetValue() or "")
        asmlib.LogInstance("OPEN_FRAME: TextEntry.OnEnter: "..sName.." >> "..sField.." >> "..sPattern)
        local bStatus  = asmlib.UpdateListView(pnListView,frUsed,nCount,sField,sPattern)
        asmlib.LogInstance("OPEN_FRAME: TextEntry.OnEnter: ["..tostring(bStatus).."]")
      end
      pnFrame:SetVisible(true)
      pnFrame:Center()
      pnFrame:MakePopup()
      return true
    end)
end

------ INITIALIZE DB ------
asmlib.CreateTable("PIECES",
{   
    Timer = asmlib.TimerSettingMode(gaTimerSet[1]),
    Index = {{1},{2},{3},{1,4},{1,2},{2,4},{1,2,3}},
    [1] = {"MODEL" , "TEXT", "LOW", "QMK"},
    [2] = {"TYPE"  , "TEXT",  nil , "QMK"},
    [3] = {"NAME"  , "TEXT",  nil , "QMK"},
    [4] = {"AMESH" , "REAL"},
    [5] = {"ORIGN" , "TEXT"},
    [6] = {"ANGLE" , "TEXT"},
    [7] = {"MASSC" , "TEXT"}
},true,true)


if(fileExists(gsFullDSV.."PIECES.txt", "DATA")
) then
  asmlib.PrintInstance(gsToolNameU..": DB PIECES from DSV")
  asmlib.ImportFromDSV("PIECES","\t",true)
else
  asmlib.PrintInstance(gsToolNameU..": DB PIECES from LUA")
  -- asmlib.DefaultType("DEV")
  -- asmlib.InsertRecord("PIECES",{"models/props_wasteland/wheel02b.mdl",   "Development", "Dev1", 45, "65, 0, 0", "-90, 90, 180", "0.29567885398865,0.3865530192852,-0.36239844560623"})
  ------ PIECES ------
  asmlib.DefaultTable("PIECES")
  asmlib.DefaultType("Old Gmod 10")
  asmlib.InsertRecord({"models/props_phx/mechanics/medgear.mdl", "#", "#", 0, "24.173, 0, 0", "", "-0.015172731131315, 0.0090782083570957, 3.5684652328491"})
  asmlib.InsertRecord({"models/props_phx/mechanics/biggear.mdl", "#", "#", 0, "33.811, 0, 0", "", "-0.00017268359079026, -0.0035230871289968, 3.5217847824097"})
  asmlib.InsertRecord({"models/props_phx/mechanics/slider1.mdl", "#", "#", 0, " 3.000, 0, 0", "-90.000, 90.000, 180.000", "0.17126856744289, -0.10668225586414, 3.5165667533875"})
  asmlib.DefaultType("PHX Spotted Flat")
  asmlib.InsertRecord({"models/props_phx/gears/spur9.mdl" , "#", "#", 0, " 7.467, 0, 0", "", "-0.0015837327810004, 0.00016171450261027, 2.8354094028473"})
  asmlib.InsertRecord({"models/props_phx/gears/spur12.mdl", "#", "#", 0, " 9.703, 0, 0", "", "-0.0015269597060978, 0.00021413757349364, 2.8405227661133"})
  asmlib.InsertRecord({"models/props_phx/gears/spur24.mdl", "#", "#", 0, "18.381, 0, 0", "", "-0.0011573693482205, 0.00018228564294986, 2.8103637695313"})
  asmlib.InsertRecord({"models/props_phx/gears/spur36.mdl", "#", "#", 0, "27.119, 0, 0", "", "-0.0012206265237182, -8.6402214947157e-005, 2.7949125766754"})
  asmlib.DefaultType("PHX Regular Small")
  asmlib.InsertRecord({"models/mechanics/gears/gear12x6_small.mdl" , "#", "#", 0, " 6.708, 0, 0", "", "2.5334677047795e-005, 0.007706293836236, 1.5820281505585"})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x6_small.mdl" , "#", "#", 0, " 9.600, 0, 0", "", "5.0195762923977e-007, -3.5567546774473e-007, 1.5833348035812"})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x6_small.mdl" , "#", "#", 0, "13.567, 0, 0", "", "0.00074489979306236, -0.00014938598906156, 1.5826840400696"})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x12_small.mdl", "#", "#", 0, " 6.708, 0, 0", "", "4.298805720282e-007, 2.1906590319531e-008, 3.0833337306976"})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x12_small.mdl", "#", "#", 0, " 9.600, 0, 0", "", "4.3190007659177e-007, -2.4458054781462e-007, 3.0833337306976"})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x12_small.mdl", "#", "#", 0, "13.567, 0, 0", "", "-0.0017898256191984, -0.0026770732365549, 2.998779296875"})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x24_small.mdl", "#", "#", 0, " 6.708, 0, 0", "", "0.0069478303194046, 0.0029040845111012, 6.0784306526184"})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x24_small.mdl", "#", "#", 0, " 9.600, 0, 0", "", "-0.00045375636545941, 0.0069514401257038, 6.061897277832"})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x24_small.mdl", "#", "#", 0, "13.567, 0, 0", "", "-0.013954215683043, 0.00091068528126925, 6.0729651451111"})
  asmlib.DefaultType("PHX Regular Medium")
  asmlib.InsertRecord({"models/mechanics/gears/gear12x6.mdl" , "#", "#", 0, "13.20, 0, 0", "", "3.818327627414e-007, 2.8411110974957e-007, 3.1666665077209"})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x6.mdl" , "#", "#", 0, "19.10, 0, 0", "", "1.2454452189559e-006, -5.1244381893412e-007, 3.1666696071625"})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x6.mdl" , "#", "#", 0, "26.96, 0, 0", "", "0.001489854301326, -0.00029889517463744, 3.1653680801392"})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x12.mdl", "#", "#", 0, "13.20, 0, 0", "", "1.2779588587364e-006, 2.8910221772094e-007, 6.1666665077209"})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x12.mdl", "#", "#", 0, "19.10, 0, 0", "", "1.308152150159e-006, -7.5695822943089e-007, 6.1666674613953"})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x12.mdl", "#", "#", 0, "26.96, 0, 0", "", "0.0092438133433461, -0.0084008388221264, 5.9975576400757"})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x24.mdl", "#", "#", 0, "13.20, 0, 0", "", "8.254278327513e-007, 8.7331630993503e-007, 12.166662216187"})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x24.mdl", "#", "#", 0, "19.10, 0, 0", "", "8.6996135451045e-007, -2.8219722025824e-007, 12.166659355164"})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x24.mdl", "#", "#", 0, "26.96, 0, 0", "", "-0.0094724241644144, -0.0066200322471559, 12.150183677673"})
  asmlib.DefaultType("PHX Regular Big")
  asmlib.InsertRecord({"models/mechanics/gears/gear12x24_large.mdl", "#", "#", 0, "26.196, 0, 0", "", "1.6508556655026e-006, 1.7466326198701e-006, 24.333324432373"})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x12_large.mdl", "#", "#", 0, "26.196, 0, 0", "", "3.6818344142375e-006, 3.3693649470479e-007, 12.333333015442"})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x6_large.mdl" , "#", "#", 0, "26.196, 0, 0", "", "3.8200619201234e-007, 4.0919746879808e-007, 6.3333339691162"})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x24_large.mdl", "#", "#", 0, "37.480, 0, 0", "", "1.7399227090209e-006, -2.1441636022246e-007, 24.333318710327"})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x12_large.mdl", "#", "#", 0, "37.480, 0, 0", "", "1.6911637885642e-006, -1.7452016436437e-006, 12.333334922791"})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x6_large.mdl" , "#", "#", 0, "37.480, 0, 0", "", "2.9455352432706e-006, -9.6805695193325e-007, 6.333339214325"})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x24_large.mdl", "#", "#", 0, "53.600, 0, 0", "", "1.0641871313055e-006, -3.3355117921019e-006, 24.333333969116"})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x12_large.mdl", "#", "#", 0, "53.600, 0, 0", "", "-6.2653803922785e-008, -3.8585267247981e-006, 12"})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x6_large.mdl" , "#", "#", 0, "53.600, 0, 0", "", "1.0842279607459e-006, -3.8418565964093e-006, 6.3333292007446"})
  asmlib.DefaultType("PHX Regular Flat")
  asmlib.InsertRecord({"models/Mechanics/gears2/gear_12t1.mdl", "#", "#", 0, "14, 0, 0", "", " 0.024772670120001, -0.0039097801782191,  3.7019141529981e-008"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_12t3.mdl", "#", "#", 0, "14, 0, 0", "", "-0.00028943095821887,0.010859239846468,   0.0029602686408907"  })
  asmlib.InsertRecord({"models/mechanics/gears2/gear_12t2.mdl", "#", "#", 0, "14, 0, 0", "", "-0.017006939277053,  0.0030655609443784, -0.00057022727560252" })
  asmlib.InsertRecord({"models/mechanics/gears2/gear_18t1.mdl", "#", "#", 0, "20, 0, 0", "", " 0.0069116964004934, 0.0010486841201782, -0.00013630707690027" })
  asmlib.InsertRecord({"models/mechanics/gears2/gear_18t2.mdl", "#", "#", 0, "20, 0, 0", "", "-0.010480961762369, -0.00094905123114586,-0.00027210538974032" })
  asmlib.InsertRecord({"models/mechanics/gears2/gear_18t3.mdl", "#", "#", 0, "20, 0, 0", "", "-0.0040156506001949, 0.0044087348505855, -0.0016298928530887"  })
  asmlib.InsertRecord({"models/mechanics/gears2/gear_24t1.mdl", "#", "#", 0, "26, 0, 0", "", "0.0005555086536333,0.0018403908470646,7.969097350724e-005"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_24t2.mdl", "#", "#", 0, "26, 0, 0", "", "0.0001849096006481,-0.002116076881066,0.00092169753042981"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_24t3.mdl", "#", "#", 0, "26, 0, 0", "", "-0.0039519360288978,-0.00076565862400457,0.00095280521782115"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_36t1.mdl", "#", "#", 0, "38, 0, 0", "", "-0.013952384702861,-0.015051824972034,-3.6770456063095e-005"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_36t2.mdl", "#", "#", 0, "38, 0, 0", "", "-0.001660150825046,0.0067499200813472,7.3757772042882e-005"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_36t3.mdl", "#", "#", 0, "38, 0, 0", "", "-0.012223065830767,-0.0013654727954417,-0.00044102084939368"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_48t1.mdl", "#", "#", 0, "50, 0, 0", "", "0.0015389173058793,0.003474734723568,0.00028770981589332"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_48t2.mdl", "#", "#", 0, "50, 0, 0", "", "0.0030889171175659,-0.00082554836990312,-8.9276603830513e-005"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_48t3.mdl", "#", "#", 0, "50, 0, 0", "", "-0.00083220232045278,-0.00013183639384806,-0.0028226880822331"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_60t1.mdl", "#", "#", 0, "62, 0, 0", "", "0.017997905611992,-0.008360886014998,0.00023668861831538"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_60t2.mdl", "#", "#", 0, "62, 0, 0", "", "-0.0077802902087569,0.0077699818648398,-0.00011245282075834"})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_60t3.mdl", "#", "#", 0, "62, 0, 0", "", "-0.00085410091560334,0.0053461473435163,-0.00029574517975561"})
  asmlib.DefaultType("PHX Vertical")
  asmlib.InsertRecord({"models/Mechanics/gears2/vert_18t1.mdl", "#", "#", 90, "19.78, 0, 5.6", "", "-9.3372744913722e-007,-1.4464712876361e-006,-1.4973667860031"})
  asmlib.InsertRecord({"models/mechanics/gears2/vert_12t1.mdl", "#", "#", 90, "13.78, 0, 5.6", "", "-6.1126132777645e-007,4.6880626314305e-007,-1.4130713939667"})
  asmlib.InsertRecord({"models/mechanics/gears2/vert_24t1.mdl", "#", "#", 90, "25.78, 0, 5.6", "", "-0.0046720593236387,-0.0090785603970289,-1.5481045246124"})
  asmlib.InsertRecord({"models/mechanics/gears2/vert_36t1.mdl", "#", "#", 90, "37.78, 0, 5.6", "", "0.0043581933714449,-0.00018005351012107,-1.6056708097458"})
  asmlib.DefaultType("PHX Teeth Flat")
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_20t1.mdl", "#", "#", 0, "2.55, 0, 0", "0, -90, 0", "-0.031061116605997, 0.68289417028427, 0.00010814304550877"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_20t2.mdl", "#", "#", 0, "2.55, 0, 0", "0, -90, 0", "-0.0308688133955, 0.68287181854248, 0.00033729249844328"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_20t3.mdl", "#", "#", 0, "2.55, 0, 0", "0, -90, 0", "-0.03086843341589, 0.68287181854248, 0.00067511270754039"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_40t1.mdl", "#", "#", 0, "2.55, 0, 0", "0, -90, 0", "-0.0045434008352458, 0.68366396427155, 0.0020906918216497"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_40t2.mdl", "#", "#", 0, "2.55, 0, 0", "0, -90, 0", "-0.0043520531617105, 0.68364036083221, 0.004302385263145"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_40t3.mdl", "#", "#", 0, "2.55, 0, 0", "0, -90, 0", "-0.0043467613868415, 0.68364137411118, 0.008606200106442"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_80t1.mdl", "#", "#", 0, "2.55, 0, 0", "0, -90, 0", "-0.018019204959273, 0.68289333581924, 0.00052548095118254"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_80t2.mdl", "#", "#", 0, "2.55, 0, 0", "0, -90, 0", "-0.017873015254736, 0.68288779258728, 0.0010742680169642"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_80t3.mdl", "#", "#", 0, "2.55, 0, 0", "0, -90, 0", "-0.018022054806352, 0.68289351463318, 0.0021022602450103"})
  asmlib.DefaultType("PHX Spotted Rack")
  asmlib.InsertRecord({"models/props_phx/gears/rack9.mdl" , "#", "#", 0, " 2.7, 0, 0", "-90, 0, 180", "-0.00016037904424593, -0.13780690729618, 2.362241268158"})
  asmlib.InsertRecord({"models/props_phx/gears/rack18.mdl", "#", "#", 0, " 2.7, 0, 0", "-90, 0, 180", "0.022915028035641, 2.2609362602234, 2.3429780006409"})
  asmlib.InsertRecord({"models/props_phx/gears/rack36.mdl", "#", "#", 0, " 2.7, 0, 0", "-90, 0, 180", "0.013655911199749, -0.019220048561692, 2.3991346359253"})
  asmlib.InsertRecord({"models/props_phx/gears/rack70.mdl", "#", "#", 0, " 2.7, 0, 0", "-90, 0, 180", "-0.017855016514659, 0.20156383514404, 2.3644349575043"})
  asmlib.DefaultType("PHX Bevel")
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_12t1.mdl", "#", "#", 45, "12.2, 0, 1.3", "", "-0.0026455507613719,-0.0061479024589062,-0.87438750267029"})
  asmlib.InsertRecord({"models/Mechanics/gears2/bevel_18t1.mdl", "#", "#", 45, "17.3, 0, 1.3", "", "-0.033187858760357,0.0065126456320286,-1.0525280237198"})
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_24t1.mdl", "#", "#", 45, "23.3, 0, 1.3", "", "-0.0011872322065756,0.0026002936065197,-0.86795377731323"})
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_36t1.mdl", "#", "#", 45, "34.8, 0, 1.3", "", "0.00066847755806521,0.0034906349610537,-0.86690950393677"})
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_48t1.mdl", "#", "#", 45, "46.7, 0, 1.3", "", "-0.012435931712389,-0.012925148941576,-0.73237001895905"})
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_60t1.mdl", "#", "#", 45, "58.6, 0, 1.3", "", "-9.5774739747867e-005,0.0057542459107935,-0.7312148809433"})
  asmlib.DefaultType("Black Regular Medium")
  asmlib.InsertRecord({"models/gears/gear1_m_12.mdl" , "#", "#", 0, " 7.684, 0, 0", "", "-0.014979394152761, 0.0047998707741499, -0.00038224767195061"})
  asmlib.InsertRecord({"models/gears/gear1_m_18.mdl" , "#", "#", 0, "11.576, 0, 0", "", "-0.0021063536405563, -0.0053282543085515, 0.00087571347830817"})
  asmlib.InsertRecord({"models/gears/gear1_m_24.mdl" , "#", "#", 0, "15.663, 0, 0", "", "-0.0070638651959598, 0.009610753506422, -0.00015339285891969"})
  asmlib.InsertRecord({"models/gears/gear1_m_30.mdl" , "#", "#", 0, "19.603, 0, 0", "", "-0.0077706538140774, -0.0071825389750302, 0.00097463151905686"})
  asmlib.InsertRecord({"models/gears/gear1_m_36.mdl" , "#", "#", 0, "23.656, 0, 0", "", "-0.0044078547507524, 0.0050257132388651, -0.00015181547496468"})
  asmlib.InsertRecord({"models/gears/gear1_m2_12.mdl", "#", "#", 0, " 7.684, 0, 0", "", "-0.00058068969519809, 0.013377501629293, -1.1378889297475e-007"})
  asmlib.InsertRecord({"models/gears/gear1_m2_18.mdl", "#", "#", 0, "11.576, 0, 0", "", "6.8955853294028e-007, -7.7567614198415e-007, -1.3395394660165e-007"})
  asmlib.InsertRecord({"models/gears/gear1_m2_24.mdl", "#", "#", 0, "15.663, 0, 0", "", "-0.0051188934594393, 0.0042025204747915, 3.5875429603038e-005"})
  asmlib.InsertRecord({"models/gears/gear1_m2_30.mdl", "#", "#", 0, "19.603, 0, 0", "", "-0.010076130740345, 0.0034327011089772, 0.0018927120836452"})
  asmlib.InsertRecord({"models/gears/gear1_m2_36.mdl", "#", "#", 0, "23.656, 0, 0", "", "0.0045576053671539, -0.0040306155569851, 0.00094956270186231"})
  asmlib.InsertRecord({"models/gears/gear1_m3_12.mdl", "#", "#", 0, " 7.684, 0, 0", "", "0.0068129352293909, -0.010897922329605, -0.0019134525209665"})
  asmlib.InsertRecord({"models/gears/gear1_m3_18.mdl", "#", "#", 0, "11.576, 0, 0", "", "-2.666999421308e-007, -3.7215826864667e-007, -5.6812831417119e-007"})
  asmlib.InsertRecord({"models/gears/gear1_m3_24.mdl", "#", "#", 0, "15.663, 0, 0", "", "-0.0056810793466866, -0.0012888131896034, -0.0020044941920787"})
  asmlib.InsertRecord({"models/gears/gear1_m3_30.mdl", "#", "#", 0, "19.603, 0, 0", "", "-0.0008564597228542, 0.0034411856904626, 0.0015924768522382"})
  asmlib.InsertRecord({"models/gears/gear1_m3_36.mdl", "#", "#", 0, "23.656, 0, 0", "", "0.007684207521379, 0.002827123273164, 0.0003438270650804"})
  asmlib.DefaultType("Black Regular Small")
  asmlib.InsertRecord({"models/gears/gear1_s_12.mdl" , "#", "#", 0, " 3.913, 0, 0", "", "0.0038407891988754, 0.014333480969071, -5.8103839961632e-008"})
  asmlib.InsertRecord({"models/gears/gear1_s_18.mdl" , "#", "#", 0, " 5.886, 0, 0", "", "-0.0022506208624691, 0.0028510170523077, 0.00012522481847554"})
  asmlib.InsertRecord({"models/gears/gear1_s_24.mdl" , "#", "#", 0, " 7.917, 0, 0", "", "-0.013967990875244, -0.021645260974765, -0.00082508515333757"})
  asmlib.InsertRecord({"models/gears/gear1_s_30.mdl" , "#", "#", 0, " 9.849, 0, 0", "", "-0.005624498706311, -0.0024201874621212, 0.00024188664974645"})
  asmlib.InsertRecord({"models/gears/gear1_s_36.mdl" , "#", "#", 0, "11.848, 0, 0", "", "0.0077217095531523, -0.0055977017618716, -0.00015713422908448"})
  asmlib.InsertRecord({"models/gears/gear1_s2_12.mdl", "#", "#", 0, " 3.913, 0, 0", "", "0.0021100759040564, -0.0016733136726543, 0.0022850329987705"})
  asmlib.InsertRecord({"models/gears/gear1_s2_18.mdl", "#", "#", 0, " 5.886, 0, 0", "", "0.0039685778319836, -0.0085194045677781, -0.00055132457055151"})
  asmlib.InsertRecord({"models/gears/gear1_s2_24.mdl", "#", "#", 0, " 7.917, 0, 0", "", "-0.0048923366703093, -0.0077434764243662, -0.0015948973596096"})
  asmlib.InsertRecord({"models/gears/gear1_s2_30.mdl", "#", "#", 0, " 9.849, 0, 0", "", "-0.0064226854592562, 0.020160168409348, 0.0011082629207522"})
  asmlib.InsertRecord({"models/gears/gear1_s2_36.mdl", "#", "#", 0, "11.848, 0, 0", "", "0.009396655485034, 0.010528456419706, 0.0033775176852942"})
  asmlib.InsertRecord({"models/gears/gear1_s3_12.mdl", "#", "#", 0, " 3.913, 0, 0", "", "0.0018781825201586, -0.0014426524285227, -0.00095008197240531"})
  asmlib.InsertRecord({"models/gears/gear1_s3_18.mdl", "#", "#", 0, " 5.886, 0, 0", "", "0.0099822543561459, 0.00096216786187142, 0.0025063841603696"})
  asmlib.InsertRecord({"models/gears/gear1_s3_24.mdl", "#", "#", 0, " 7.917, 0, 0", "", "0.007310485932976, -0.004775257781148, 0.0017300172476098"})
  asmlib.InsertRecord({"models/gears/gear1_s3_30.mdl", "#", "#", 0, " 9.849, 0, 0", "", "0.0016155475750566, -0.010166599415243, -0.00065914361039177"})
  asmlib.InsertRecord({"models/gears/gear1_s3_36.mdl", "#", "#", 0, "11.848, 0, 0", "", "0.014523273333907, 0.012045037001371, 0.00054475461365655"})
  asmlib.DefaultType("SProps Flat Small")
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_10t_s.mdl", "#", "#", 0, " 2.820, 0, 0", "", "0.0049172430299222, -0.0049177999608219, -1.5156917498871e-008"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_12t_s.mdl", "#", "#", 0, " 3.100, 0, 0", "", "-0.001883051590994, 0.00050171936163679, -0.0005939711118117"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_14t_s.mdl", "#", "#", 0, " 3.784, 0, 0", "", "0.002141302684322, -0.002729385625571, 0.013979037292302"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_16t_s.mdl", "#", "#", 0, " 4.271, 0, 0", "", "0.0015306419227272, -0.00057447905419394, -0.00052806112216786"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_18t_s.mdl", "#", "#", 0, " 4.761, 0, 0", "", "-0.0017241191817448, -0.0063244164921343, -0.00037708022864535"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_24t_s.mdl", "#", "#", 0, " 6.237, 0, 0", "", "-2.9937275485281e-006, -1.4846134490654e-006, -1.7167849364341e-008"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_30t_s.mdl", "#", "#", 0, " 7.722, 0, 0", "", "0.001925386604853, 0.00010160527017433, 0.00021312535682227"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_36t_s.mdl", "#", "#", 0, " 9.211, 0, 0", "", "-0.00056221708655357, -7.6126736530568e-005, -1.2265476634354e-008"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_42t_s.mdl", "#", "#", 0, "10.703, 0, 0", "", "-2.1004445898143e-006, -1.0246620831822e-006, 8.0583710371229e-008"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_48t_s.mdl", "#", "#", 0, "12.197, 0, 0", "", "-0.0046847369521856, -0.0031020345631987, -0.00029869191348553"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_54t_s.mdl", "#", "#", 0, "13.692, 0, 0", "", "0.001435556798242, -0.020333550870419, -0.0020731033291668"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_60t_s.mdl", "#", "#", 0, "15.188, 0, 0", "", "0.020014140754938, 0.018639868125319, -0.00044363949564286"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_66t_s.mdl", "#", "#", 0, "16.685, 0, 0", "", "-0.010388540104032, 0.016772596165538, -0.00034016091376543"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_72t_s.mdl", "#", "#", 0, "18.182, 0, 0", "", "0.03625612705946, -0.0024083079770207, 9.4895163783804e-005"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_78t_s.mdl", "#", "#", 0, "19.680, 0, 0", "", "0.0019805070478469, -0.0081495717167854, 0.0006504594348371"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_84t_s.mdl", "#", "#", 0, "21.178, 0, 0", "", "0.030328331515193, -0.021101905032992, -0.00029180099954829"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_90t_s.mdl", "#", "#", 0, "22.676, 0, 0", "", "-0.029588585719466, -0.014376631937921, -0.00069682777393609"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_96t_s.mdl", "#", "#", 0, "24.174, 0, 0", "", "0.005857755895704, -0.01476801559329, -0.00028429020312615"})
  asmlib.DefaultType("SProps Flat Large")
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_10t_l.mdl", "#", "#", 0, " 5.394, 0, 0", "", "-0.0041495636105537, -0.0030151198152453, -0.0059148990549147"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_12t_l.mdl", "#", "#", 0, " 6.358, 0, 0", "", "-0.0037653909530491, -0.006521004717797, -0.0023776774760336"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_14t_l.mdl", "#", "#", 0, " 7.330, 0, 0", "", "4.0495933717466e-007, 3.3086558914874e-007, -3.283965099854e-008"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_16t_l.mdl", "#", "#", 0, " 8.307, 0, 0", "", "-0.0028722907882184, 0.00086623401148245, -3.2330953469994e-009"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_18t_l.mdl", "#", "#", 0, " 9.288, 0, 0", "", "0.0068863672204316, -0.0019885420333594, 0.00037651605089195"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_24t_l.mdl", "#", "#", 0, "12.247, 0, 0", "", "-2.9040645586065e-006, -3.0396604415728e-006, -3.5156244582168e-009"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_30t_l.mdl", "#", "#", 0, "15.221, 0, 0", "", "-0.0038472001906484, -0.005274873226881, 0.0015362998237833"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_36t_l.mdl", "#", "#", 0, "18.203, 0, 0", "", "0.0037662063259631, 0.0026958135422319, -0.00089779059635475"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_42t_l.mdl", "#", "#", 0, "21.189, 0, 0", "", "-2.4632468011987e-006, -2.1759717583336e-006, 1.3644348939579e-007"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_48t_l.mdl", "#", "#", 0, "24.179, 0, 0", "", "-9.0362368609931e-007, -2.2698932298226e-006, 2.9944263957304e-008"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_54t_l.mdl", "#", "#", 0, "27.171, 0, 0", "", "-0.00012703427637462, 0.0087271770462394, 0.00064932194072753"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_60t_l.mdl", "#", "#", 0, "30.164, 0, 0", "", "0.0056863417848945, -0.0054859640076756, 0.00057526386808604"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_66t_l.mdl", "#", "#", 0, "33.158, 0, 0", "", "0.00034787258482538, 0.01172979734838, 0.00039185225614347"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_72t_l.mdl", "#", "#", 0, "36.154, 0, 0", "", "0.0059279436245561, -0.00014554298832081, 0.00043231318704784"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_78t_l.mdl", "#", "#", 0, "39.150, 0, 0", "", "0.035279795527458, 0.0002772074949462, -0.0002848417207133"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_84t_l.mdl", "#", "#", 0, "42.146, 0, 0", "", "-0.0063623366877437, -0.0040172939188778, 0.00028934032889083"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_90t_l.mdl", "#", "#", 0, "45.143, 0, 0", "", "-3.0313363822643e-005, 0.0025897726882249, -8.3106489910278e-005"})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_96t_l.mdl", "#", "#", 0, "48.141, 0, 0", "", "-0.020891901105642, -0.0010100682266057, 0.00014523084973916"})
  asmlib.DefaultType("SProps Bevel Large")
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_10t_l.mdl", "#", "#", 45, " 5.520, 0, 1.35", "", "-2.1634095901391e-005, 0.00061463302699849, -1.0174524784088"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_12t_l.mdl", "#", "#", 45, " 6.244, 0, 1.35", "", "-0.03066711127758, 0.013303384184837, -0.9567843079567"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_14t_l.mdl", "#", "#", 45, " 7.237, 0, 1.35", "", "0.0046781497076154, 0.0045431824401021, -0.91953921318054"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_16t_l.mdl", "#", "#", 45, " 8.230, 0, 1.35", "", "-0.0024151098914444, -0.0035203483421355, -0.88513052463531"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_18t_l.mdl", "#", "#", 45, " 9.280, 0, 1.35", "", "-3.7560730561381e-006, -3.2225407267106e-006, -0.85729819536209"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_24t_l.mdl", "#", "#", 45, "12.252, 0, 1.35", "", "-2.7985045107926e-006, -3.253147497162e-006, -0.80283242464066"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_30t_l.mdl", "#", "#", 45, "15.275, 0, 1.35", "", "0.0065972418524325, 0.012552709318697, -0.76705181598663"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_36t_l.mdl", "#", "#", 45, "18.257, 0, 1.35", "", "0.0032132093328983, 0.0069867530837655, -0.74561846256256"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_42t_l.mdl", "#", "#", 45, "21.244, 0, 1.35", "", "-2.1220994312898e-006, -1.2074082178515e-006, -0.72734010219574"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_48t_l.mdl", "#", "#", 45, "24.233, 0, 1.35", "", "0.0043564774096012, 0.0072778444737196, -0.7125990986824"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_54t_l.mdl", "#", "#", 45, "27.193, 0, 1.35", "", "-0.0012360077816993, -0.015729079023004, -0.70351052284241"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_60t_l.mdl", "#", "#", 45, "30.188, 0, 1.35", "", "0.0024155958089978, -0.0004843553469982, -0.69532954692841"})
  asmlib.DefaultType("SProps Bevel Small")
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_10t_s.mdl", "#", "#", 45, " 2.793, 0, 0.7", "", "-1.1249650924583e-005, 0.00030727940611541, -0.50872629880905"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_12t_s.mdl", "#", "#", 45, " 3.289, 0, 0.7", "", "0.021812098100781, 0.034060511738062, -0.48147577047348"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_14t_s.mdl", "#", "#", 45, " 3.784, 0, 0.7", "", "0.012455121614039, 0.0088365506380796, -0.46449995040894"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_16t_s.mdl", "#", "#", 45, " 4.279, 0, 0.7", "", "0.00057214515982196, 0.00084737170254812, -0.44488653540611"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_18t_s.mdl", "#", "#", 45, " 4.775, 0, 0.7", "", "-0.015875330194831, -0.0061574815772474, -0.42753458023071"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_24t_s.mdl", "#", "#", 45, " 6.264, 0, 0.7", "", "-2.9411880859698e-006, -1.5586849713145e-006, -0.40141621232033"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_30t_s.mdl", "#", "#", 45, " 7.755, 0, 0.7", "", "0.011199345812202, -0.0023416457697749, -0.3832374215126"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_36t_s.mdl", "#", "#", 45, " 9.249, 0, 0.7", "", "-2.1506830307771e-005, -0.0082621555775404, -0.37152001261711"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_42t_s.mdl", "#", "#", 45, "10.744, 0, 0.7", "", "-1.2801006050722e-006, 1.4830366978913e-007, -0.36367011070251"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_48t_s.mdl", "#", "#", 45, "12.240, 0, 0.7", "", "-0.026493191719055, 0.041309744119644, -0.35398504137993"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_54t_s.mdl", "#", "#", 45, "13.737, 0, 0.7", "", "0.011715604923666, -0.0062104072421789, -0.35115513205528"})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_60t_s.mdl", "#", "#", 45, "15.234, 0, 0.7", "", "0.002376772928983, -0.0096677150577307, -0.34716984629631"})
  asmlib.DefaultType("SProps Rack Large")
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_12t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-90, 0, 180", "-7.0960714992907e-007, 9.5314753707498e-006, -0.66472762823105"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_24t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-90, 0, 180", "2.0629582309084e-007, 9.6307467174483e-006, -0.67044341564178"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_36t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-90, 0, 180", "-3.4605172061219e-008, -4.9788040996646e-006, -0.67230480909348"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_48t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-90, 0, 180", "3.8946841414145e-006, 4.0884210648073e-006, -0.67322540283203"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_60t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-90, 0, 180", "-4.1661261107606e-009, 4.5187160139903e-005, -0.67377626895905"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_72t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-90, 0, 180", "3.8322218642861e-006, 5.0654783990467e-005, -0.67414307594299"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_84t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-90, 0, 180", "3.9428311282563e-008, 6.2194543716032e-005, -0.67440587282181"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_96t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-90, 0, 180", "-7.7476306614699e-006, 3.583199577406e-005, -0.67460036277771"})
  asmlib.DefaultType("SProps Rack Small")
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_12t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-90, 0, 180", "-8.9563911842561e-007, 7.623572855664e-006, -0.33236381411552"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_24t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-90, 0, 180", "7.805109447645e-008, 5.1519514272513e-006, -0.33522164821625"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_36t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-90, 0, 180", "-3.1340739781172e-008, 3.3068738503061e-006, -0.33615264296532"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_48t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-90, 0, 180", "3.8751231841161e-006, 7.3969954428321e-006, -0.33661276102066"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_60t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-90, 0, 180", "6.0092202325279e-009, 2.8254335120437e-005, -0.33688813447952"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_72t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-90, 0, 180", "3.8311595744744e-006, 2.3214635803015e-005, -0.33707144856453"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_84t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-90, 0, 180", "4.1014533991302e-008, 2.9928796720924e-005, -0.33720290660858"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_96t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-90, 0, 180", "-7.6562746471609e-006, 2.0776307792403e-005, -0.33730128407478"})
  asmlib.DefaultType("Propeller")
  asmlib.InsertRecord({"models/gears/gear_3.mdl"   , "#", "#", 0  , " 1.903, 0, 0", "", "-8.8830764966019e-009, 1.7266756913159e-005, 4.0000004768372"})
  asmlib.InsertRecord({"models/gears/gear_6.mdl"   , "#", "#", 0  , " 3.098, 0, 0", "", "6.2004239964608e-008, 7.2985351096122e-009, 3.9999983310699"})
  asmlib.InsertRecord({"models/gears/gear_12.mdl"  , "#", "#", 0  , " 5.234, 0, 0", "", "2.1442920328241e-008, 2.595057146948e-008, 4.0000009536743"})
  asmlib.InsertRecord({"models/gears/gear_24.mdl"  , "#", "#", 0  , " 9.470, 0, 0", "", "-2.3349744537882e-007, -1.7496104192105e-006, 3.9999997615814"})
  asmlib.InsertRecord({"models/gears/planet_16.mdl", "#", "#", 180, " 9.523, 0, 0", "", "2.1667046894436e-006, -1.2715023558485e-006, 5.6510457992554"})

end

-------- CACHE PANEL STUFF ---------
asmlib.CacheQueryPanel()
asmlib.PrintInstance(asmlib.GetToolNameU().." Loaded successfully [ master ] Rev.199")