------ LOCALIZNG FUNCTIONS ---
local tonumber                      = tonumber
local tostring                      = tostring
local Vector                        = Vector
local Angle                         = Angle
local IsValid                       = IsValid
local sqlBegin                      = sql and sql.Begin
local sqlCommit                     = sql and sql.Commit
local bitBor                        = bit and bit.bor
local mathFloor                     = math and math.floor
local vguiCreate                    = vgui and vgui.Create
local fileExists                    = file and file.Exists
local controlpanelGet               = controlpanel and controlpanel.Get
local surfaceCreateFont             = surface and surface.CreateFont
local surfaceScreenWidth            = surface and surface.ScreenWidth
local surfaceScreenHeight           = surface and surface.ScreenHeight
local languageGetPhrase             = language and language.GetPhrase
local cvarsAddChangeCallback        = cvars and cvars.AddChangeCallback
local cvarsRemoveChangeCallback     = cvars and cvars.RemoveChangeCallback
local duplicatorStoreEntityModifier = duplicator and duplicator.StoreEntityModifier

------ INCLUDE LIBRARY ------
if(SERVER) then
  AddCSLuaFile("gearassembly/gearasmlib.lua")
end
include("gearassembly/gearasmlib.lua")

------ MODULE POINTER -------
local asmlib = gearasmlib; if(not asmlib) then -- Module present
  ErrorNoHalt("INIT: Gear assembly tool module fail"); return end

------ CONFIGURE ASMLIB ------
asmlib.InitBase("gear","assembly")
asmlib.SetOpVar("TOOL_VERSION","5.229")
asmlib.SetIndexes("V",1,2,3)
asmlib.SetIndexes("A",1,2,3)
asmlib.SetIndexes("S",4,5,6,7)
asmlib.SetOpVar("CONTAIN_STACK_MODE",asmlib.GetContainer("Stack Mode"))
asmlib.SetOpVar("CONTAIN_CONSTRAINT_TYPE",asmlib.GetContainer("Constraint Type"))

------------ CONFIGURE GLOBAL INIT OPVARS ------------

local gtInitLogs  = asmlib.GetOpVar("LOG_INIT")
local gsLimitName = asmlib.GetOpVar("CVAR_LIMITNAME")
local gsToolPrefL = asmlib.GetOpVar("TOOLNAME_PL")
local gsToolNameL = asmlib.GetOpVar("TOOLNAME_NL")
local gsToolNameU = asmlib.GetOpVar("TOOLNAME_NU")
local gsFullDSV   = asmlib.GetOpVar("DIRPATH_BAS")..asmlib.GetOpVar("DIRPATH_DSV")..
                    asmlib.GetInstPref()..asmlib.GetOpVar("TOOLNAME_PU")

------ VARIABLE FLAGS ------

local varLanguage = GetConVar("gmod_language")
-- Client and server have independent value
local gnIndependentUsed = bitBor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_PRINTABLEONLY)
-- Server tells the client what value to use
local gnServerControled = bitBor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_PRINTABLEONLY)

------------ BORDERS ------------

asmlib.SetBorder("non-neg", 0)
asmlib.SetBorder("sbox_max"..gsLimitName , 0)
asmlib.SetBorder(gsToolPrefL.."devmode"  , 0, 1)
asmlib.SetBorder(gsToolPrefL.."maxtrmarg", 0, 1)
asmlib.SetBorder(gsToolPrefL.."endsvlock", 0, 1)
asmlib.SetBorder(gsToolPrefL.."incsnpang", 0, gnMaxRot)
asmlib.SetBorder(gsToolPrefL.."incsnplin", 0, 250)
asmlib.SetBorder(gsToolPrefL.."logfile"  , 0, 1)
asmlib.SetBorder(gsToolPrefL.."logsmax"  , 0, 100000)
asmlib.SetBorder(gsToolPrefL.."maxforce" , 0)
asmlib.SetBorder(gsToolPrefL.."maxfrict" , 0)
asmlib.SetBorder(gsToolPrefL.."maxtorque", 0)
asmlib.SetBorder(gsToolPrefL.."maxstcnt" , 1)
asmlib.SetBorder(gsToolPrefL.."maxfruse" , 1, 150)
asmlib.SetBorder(gsToolPrefL.."maxlinear", 0)
asmlib.SetBorder(gsToolPrefL.."maxmass"  , 1)

------ CONFIGURE LOGGING ------
asmlib.SetOpVar("LOG_DEBUGEN", false)
asmlib.MakeAsmConvar("logsmax"  , 0 , nil, gnIndependentUsed, "Maximum logging lines to be printed")
asmlib.MakeAsmConvar("logfile"  , 0 , nil, gnIndependentUsed, "Output the logs in a dedicated file")
asmlib.SetLogControl(asmlib.GetAsmConvar("logsmax","INT"),asmlib.GetAsmConvar("logfile","BUL"))
asmlib.SettingsLogs("SKIP"); asmlib.SettingsLogs("ONLY")

------ CONFIGURE NON-REPLICATED CVARS ----- Client's got a mind of its own
asmlib.MakeAsmConvar("modedb"   , "LUA", nil, gnIndependentUsed, "Database operating mode")
asmlib.MakeAsmConvar("devmode"  , 0    , nil, gnIndependentUsed, "Toggle developer mode on/off server side")
asmlib.MakeAsmConvar("maxtrmarg", 0.02 , nil, gnIndependentUsed, "Maximum time to avoid performing new traces")
asmlib.MakeAsmConvar("timermode", "CQT@1800@1@1", nil, gnIndependentUsed, "Cache management setting when DB mode is SQL")

------ CONFIGURE REPLICATED CVARS ----- Server tells the client what value to use
asmlib.MakeAsmConvar("endsvlock", 0     , nil, gnServerControled, "Toggle the DSV external database file update on/off")
asmlib.MakeAsmConvar("maxmass"  , 50000 , nil, gnServerControled, "Maximum mass to be applied on a piece")
asmlib.MakeAsmConvar("maxlinear", 250   , nil, gnServerControled, "Maximum linear offset of the piece")
asmlib.MakeAsmConvar("maxfrict" , 100000, nil, gnServerControled, "Maximum friction limit when creating constraints")
asmlib.MakeAsmConvar("maxforce" , 100000, nil, gnServerControled, "Maximum force limit when creating constraints")
asmlib.MakeAsmConvar("maxtorque", 100000, nil, gnServerControled, "Maximum torque limit when creating constraints")
asmlib.MakeAsmConvar("maxstcnt" , 200,    nil, gnServerControled, "Maximum pieces to spawn in stack mode")

asmlib.MakeAsmConvar("*sbox_max"..gsLimitName, 1500, nil, gnServerControled, "Maximum number of gears to be spawned")
asmlib.MakeAsmConvar("bnderrmod", "LOG", nil, gnServerControled, "Unreasonable position error handling mode")
asmlib.MakeAsmConvar("maxfruse" ,  50  , nil, gnServerControled, "Maximum frequent pieces to be listed")

------ CONFIGURE INTERNALS -----
asmlib.SetOpVar("MODE_DATABASE", asmlib.GetAsmConvar("modedb"   ,"STR"))
asmlib.SetOpVar("TRACE_MARGIN" , asmlib.GetAsmConvar("maxtrmarg","FLT"))

------ GLOBAL VARIABLES -------
local gsMoDB     = asmlib.GetOpVar("MODE_DATABASE")
local gaTimerSet = asmlib.GetOpVar("OPSYM_DIRECTORY"):Explode(asmlib.GetAsmConvar("timermode","STR"))
local conPalette = asmlib.GetContainer("COLORS_LIST")
      conPalette:Record("r" ,Color(255, 0 , 0 ,255))
      conPalette:Record("g" ,Color( 0 ,255, 0 ,255))
      conPalette:Record("b" ,Color( 0 , 0 ,255,255))
      conPalette:Record("c" ,Color( 0 ,255,255,255))
      conPalette:Record("m" ,Color(255, 0 ,255,255))
      conPalette:Record("y" ,Color(255,255, 0 ,255))
      conPalette:Record("w" ,Color(255,255,255,255))
      conPalette:Record("k" ,Color( 0 , 0 , 0 ,255))
      conPalette:Record("gh",Color(255,255,255,150)) -- self.GhostEntity
      conPalette:Record("an",Color(180,255,150,255)) -- Selected anchor
      conPalette:Record("tx",Color(161,161,161,255)) -- Panel names color
      conPalette:Record("db",Color(220,164, 52,255)) -- Database mode

------------ CALLBACKS ------------

local conCallBack = asmlib.GetContainer("CALLBAC_FUNC")
      conCallBack:Push({"maxtrmarg", function(sVar, vOld, vNew)
        local nM = (tonumber(vNew) or 0); nM = ((nM > 0) and nM or 0)
        asmlib.SetOpVar("TRACE_MARGIN", nM)
      end})
      conCallBack:Push({"logsmax", function(sVar, vOld, vNew)
        local nM = asmlib.BorderValue((tonumber(vNew) or 0), "non-neg")
        asmlib.SetOpVar("LOG_MAXLOGS", nM)
      end})
      conCallBack:Push({"logfile", function(sVar, vOld, vNew)
        asmlib.IsFlag("en_logging_file", tobool(vNew))
      end})
      conCallBack:Push({"endsvlock", function(sVar, vOld, vNew)
        asmlib.IsFlag("en_dsv_datalock", tobool(vNew))
      end})
      conCallBack:Push({"timermode", function(sVar, vOld, vNew)
        local arTim = gsSymDir:Explode(vNew)
        local mkTab, ID = asmlib.GetBuilderID(1), 1
        while(mkTab) do local sTim = arTim[ID]
          local defTab = mkTab:GetDefinition(); mkTab:TimerSetup(sTim)
          asmlib.LogInstance("Timer apply "..asmlib.GetReport2(defTab.Nick,sTim),gtInitLogs)
          ID = ID + 1; mkTab = asmlib.GetBuilderID(ID) -- Next table on the list
        end; asmlib.LogInstance("Timer update "..asmlib.GetReport(vNew),gtInitLogs)
      end})

for iD = 1, conCallBack:GetSize() do
  local set = conCallBack:Select(iD)
  local nam = asmlib.GetAsmConvar(set[1], "NAM")
  cvarsRemoveChangeCallback(nam, nam.."_init")
  cvarsAddChangeCallback(nam, set[2], nam.."_init")
end

------ CONFIGURE TOOL -----
local SMode = asmlib.GetOpVar("CONTAIN_STACK_MODE")
      SMode:Push("Forward direction")
      SMode:Push("Around trace pivot")

local CType = asmlib.GetOpVar("CONTAIN_CONSTRAINT_TYPE")
      CType:Push({Name = "Free Spawn"  , Make = nil                                    })
      CType:Push({Name = "Parent Piece", Make = nil                                    })
      CType:Push({Name = "Weld Piece"  , Make = constraint and constraint.Weld         })
      CType:Push({Name = "Axis Piece"  , Make = constraint and constraint.Axis         })
      CType:Push({Name = "Ball-Sock HM", Make = constraint and constraint.Ballsocket   })
      CType:Push({Name = "Ball-Sock TM", Make = constraint and constraint.Ballsocket   })
      CType:Push({Name = "AdvBS Lock X", Make = constraint and constraint.AdvBallsocket})
      CType:Push({Name = "AdvBS Lock Y", Make = constraint and constraint.AdvBallsocket})
      CType:Push({Name = "AdvBS Lock Z", Make = constraint and constraint.AdvBallsocket})
      CType:Push({Name = "AdvBS Spin X", Make = constraint and constraint.AdvBallsocket})
      CType:Push({Name = "AdvBS Spin Y", Make = constraint and constraint.AdvBallsocket})
      CType:Push({Name = "AdvBS Spin Z", Make = constraint and constraint.AdvBallsocket})

if(SERVER) then
  asmlib.SetAction("DUPE_PHYS_SETTINGS",
    function(oPly,oEnt,tData) -- Duplicator wrapper
      if(not asmlib.ApplyPhysicalSettings(oEnt,tData[1],tData[2],tData[3])) then
        return asmlib.StatusLog(nil,"DUPE_PHYS_SETTINGS: Failed to apply physical settings on "..tostring(oEnt)) end
      return asmlib.StatusLog(nil,"DUPE_PHYS_SETTINGS: Success")
    end)

  asmlib.SetAction("PLAYER_QUIT",
    function(oPly) -- Clear player cache when disconnects
      if(not asmlib.CacheClearPly(oPly)) then
        return asmlib.StatusLog(nil,"PLAYER_QUIT: Failed swiping stuff "..tostring(oPly)) end
      return asmlib.StatusLog(nil,"PLAYER_QUIT: Success")
    end)
end

if(CLIENT) then

  surfaceCreateFont("DebugSpawnGA",{
    font = "Courier New", size = 14,
    weight = 600
  })

  -- Listen for changes to the localify language and reload the tool's menu to update the localizations
  cvarsRemoveChangeCallback(varLanguage:GetName(), gsToolPrefL.."lang")
  cvarsAddChangeCallback(varLanguage:GetName(), function(sNam, vO, vN)
    local sLog, bS, vOut, fUser, fAdmn = "*UPDATE_CONTROL_PANEL("..vO.."/"..vN..")"
    local oTool = asmlib.GetOpVar("STORE_TOOLOBJ"); if(not asmlib.IsHere(oTool)) then
      asmlib.LogInstance("Tool object missing", sLog); return end
    -- Retrieve the control panel from the tool main tab
    local fCont = oTool.BuildCPanel -- Function is the tool populator
    local pCont = controlpanelGet(gsToolNameL); if(not IsValid(pCont)) then
      asmlib.LogInstance("Control invalid", sLog); return end
    -- Wipe the panel so it is clear of contents sliders buttons and stuff
    pCont:ClearControls()
    -- Panels are cleared and we change the language utilizing localify
    bS, vOut = pcall(fCont, pCont) if(not bS) then
      asmlib.LogInstance("Control fail: "..vOut, sLog); return
    else asmlib.LogInstance("Control: "..asmlib.GetReport(pCont.Name), sLog) end
  end, gsToolPrefL.."lang")


  asmlib.SetAction("RESET_VARIABLES",
    function(oPly,oCom,oArgs)
      local devmode = asmlib.GetAsmConvar("devmode" ,"BUL")
      local bgskids = asmlib.GetAsmConvar("bgskids", "STR")
      asmlib.LogInstance("RESET_VARIABLES: {"..tostring(devmode)..asmlib.GetOpVar("OPSYM_DISABLE")..tostring(bgskids).."}")
      asmlib.ConCommandPly(oPly,"nextx"    , 0)
      asmlib.ConCommandPly(oPly,"nexty"    , 0)
      asmlib.ConCommandPly(oPly,"nextz"    , 0)
      asmlib.ConCommandPly(oPly,"nextpic"  , 0)
      asmlib.ConCommandPly(oPly,"nextyaw"  , 0)
      asmlib.ConCommandPly(oPly,"nextrol"  , 0)
      asmlib.ConCommandPly(oPly,"rotpivt"  , 0)
      asmlib.ConCommandPly(oPly,"rotpivh"  , 0)
      asmlib.ConCommandPly(oPly,"deltarot" , 360)
      if(not devmode) then
        return asmlib.StatusLog(nil,"RESET_VARIABLES: Developer mode disabled") end
      asmlib.SetLogControl(asmlib.GetAsmConvar("logsmax" , "INT"), asmlib.GetAsmConvar("logfile" , "BUL"))
      if(bgskids == "reset cvars") then -- Reset also the maximum spawned pieces
        oPly:ConCommand("sbox_max"..asmlib.GetOpVar("CVAR_LIMITNAME").." 1500\n")
        local anchor = asmlib.GetOpVar("MISS_NOID")..
                       asmlib.GetOpVar("OPSYM_REVSIGN")..
                       asmlib.GetOpVar("MISS_NOMD")
        asmlib.ConCommandPly(oPly, "mass"     , "250")
        asmlib.ConCommandPly(oPly, "model"    , "models/props_phx/gears/spur9.mdl")
        asmlib.ConCommandPly(oPly, "nextx"    , "0")
        asmlib.ConCommandPly(oPly, "nexty"    , "0")
        asmlib.ConCommandPly(oPly, "nextz"    , "0")
        asmlib.ConCommandPly(oPly, "count"    , "1")
        asmlib.ConCommandPly(oPly, "anchor"   , anchor)
        asmlib.ConCommandPly(oPly, "contyp"   , "1")
        asmlib.ConCommandPly(oPly, "stmode"   , "1")
        asmlib.ConCommandPly(oPly, "freeze"   , "0")
        asmlib.ConCommandPly(oPly, "adviser"  , "1")
        asmlib.ConCommandPly(oPly, "igntyp"   , "0")
        asmlib.ConCommandPly(oPly, "angsnap"  , "0")
        asmlib.ConCommandPly(oPly, "rotpivt"  , "0")
        asmlib.ConCommandPly(oPly, "rotpivh"  , "0")
        asmlib.ConCommandPly(oPly, "gravity"  , "1")
        asmlib.ConCommandPly(oPly, "nextpic"  , "0")
        asmlib.ConCommandPly(oPly, "nextyaw"  , "0")
        asmlib.ConCommandPly(oPly, "nextrol"  , "0")
        asmlib.ConCommandPly(oPly, "trorang"  , "0")
        asmlib.ConCommandPly(oPly, "bgskids"  , "")
        asmlib.ConCommandPly(oPly, "spnflat"  , "0")
        asmlib.ConCommandPly(oPly, "exportdb" , "0")
        asmlib.ConCommandPly(oPly, "friction" , "0")
        asmlib.ConCommandPly(oPly, "forcelim" , "0")
        asmlib.ConCommandPly(oPly, "torquelim", "0")
        asmlib.ConCommandPly(oPly, "deltarot" , "360")
        asmlib.ConCommandPly(oPly, "maxstatts", "3")
        asmlib.ConCommandPly(oPly, "nocollide", "0")
        asmlib.ConCommandPly(oPly, "nophysgun", "0")
        asmlib.ConCommandPly(oPly, "ghosthold", "0")
        asmlib.ConCommandPly(oPly, "modedb"   , "LUA")
        asmlib.ConCommandPly(oPly, "timermode", "CQT@1800@1@1")
        asmlib.PrintInstance("RESET_VARIABLES: Variables reset complete")
      elseif(bgskids:sub(1,7) == "delete ") then
        local tPref = (" "):Explode(bgskids:sub(8,-1))
        for iCnt = 1, #tPref do local vPr = tPref[iCnt]
         asmlib.RemoveDSV("PIECES",vPr)
         asmlib.LogInstance("RESET_VARIABLES: Match <"..vPr..">")
        end
      else return asmlib.StatusLog(nil,"RESET_VARIABLES: Command <"..bgskids.."> skipped") end
      return asmlib.StatusLog(nil,"RESET_VARIABLES: Success")
    end)

  asmlib.SetAction("OPEN_FRAME",
    function(oPly,oCom,oArgs)
      local frUsed, nCount = asmlib.GetFrequentModels(oArgs[1])
      if(not asmlib.IsHere(frUsed)) then
        return asmlib.StatusLog(nil,"OPEN_FRAME: Retrieving most frequent models failed ["..tostring(oArgs[1]).."]") end
      local defTable = asmlib.GetOpVar("DEFTABLE_PIECES"); if(not defTable) then
        return StatusLog(nil,"OPEN_FRAME: Missing definition for table PIECES") end
      local pnFrame = vguiCreate("DFrame"); if(not IsValid(pnFrame)) then
        pnFrame:Remove(); return asmlib.StatusLog(nil,"OPEN_FRAME: Failed to create base frame") end
      local pnElements = asmlib.GetContainer("FREQ_VGUI")
            pnElements:Push({Label = { "DButton"    ,languageGetPhrase("tool."..gsToolNameL..".pn_export_lb") , languageGetPhrase("tool."..gsToolNameL..".pn_export")}})
            pnElements:Push({Label = { "DListView"  ,languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb"), languageGetPhrase("tool."..gsToolNameL..".pn_routine")}})
            pnElements:Push({Label = { "DModelPanel",languageGetPhrase("tool."..gsToolNameL..".pn_display_lb"), languageGetPhrase("tool."..gsToolNameL..".pn_display")}})
            pnElements:Push({Label = { "DTextEntry" ,languageGetPhrase("tool."..gsToolNameL..".pn_pattern_lb"), languageGetPhrase("tool."..gsToolNameL..".pn_pattern")}})
            pnElements:Push({Label = { "DComboBox"  ,languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb"), languageGetPhrase("tool."..gsToolNameL..".pn_srchcol")}})
      ------------ Manage the invalid panels -------------------
      local iNdex, iSize, sItem, vItem = 1, pnElements:GetSize(), "", nil
      while(iNdex <= iSize) do
        vItem = pnElements:Select(iNdex)
        vItem.Panel = vguiCreate(vItem.Label[1],pnFrame)
        if(not IsValid(vItem.Panel)) then
          asmlib.LogInstance("OPEN_FRAME: Failed to create ID #"..tonumber(iNdex))
          iNdex, vItem = 1, nil
          while(iNdex <= iSize) do vItem, sItem = pnElements:Select(iNdex), ""
            if(IsValid(vItem.Panel)) then vItem.Panel:Remove(); sItem = "and panel " end
            pnElements:Delete(iNdex)
            asmlib.LogInstance("OPEN_FRAME: Deleted entry "..sItem.."ID #"..tonumber(iNdex))
            iNdex = iNdex + 1
          end; pnFrame:Remove()
          return StatusLog(nil,"OPEN_FRAME: Invalid panel created. Frame removed")
        end
        vItem.Panel:SetName(vItem.Label[2])
        vItem.Panel:SetTooltip(vItem.Label[3])
        iNdex = iNdex + 1
      end
      ------ Screen resolution and elements -------
      local scrW         = surfaceScreenWidth()
      local scrH         = surfaceScreenHeight()
      local pnButton     = pnElements:Select(1).Panel
      local pnListView   = pnElements:Select(2).Panel
      local pnModelPanel = pnElements:Select(3).Panel
      local pnTextEntry  = pnElements:Select(4).Panel
      local pnComboBox   = pnElements:Select(5).Panel
      local nRatio       = asmlib.GetOpVar("GOLDEN_RATIO")
      local xyZero       = {x =  0, y = 20} -- The start location of left-top
      local xyDelta      = {x = 10, y = 10} -- Distance between panels
      local xySiz        = {x =  0, y =  0} -- Current panel size
      local xyPos        = {x =  0, y =  0} -- Current panel position
      local xyTmp        = {x =  0, y =  0} -- Temporary coordinate
      ------------ Frame --------------
      xyPos.x = (scrW / 4)
      xyPos.y = (scrH / 4)
      xySiz.x = 750
      xySiz.y = mathFloor(xySiz.x / (1 + nRatio))
      pnFrame:SetTitle(languageGetPhrase("tool."..gsToolNameL..".pn_routine_hd")..oPly:GetName().." {"..asmlib.GetOpVar("TOOL_VERSION").."}")
      pnFrame:SetVisible(true)
      pnFrame:SetDraggable(true)
      pnFrame:SetDeleteOnClose(true)
      pnFrame:SetPos(xyPos.x, xyPos.y)
      pnFrame:SetSize(xySiz.x, xySiz.y)
      pnFrame.OnClose = function()
        pnFrame:SetVisible(false)
        local iNdex, iSize = 1, pnElements:GetSize()
        while(iNdex <= iSize) do -- All panels are valid
          asmlib.LogInstance("OPEN_FRAME: Frame.OnClose: Delete #"..iNdex)
          pnElements:Select(iNdex).Panel:Remove()
          pnElements:Delete(iNdex); iNdex = iNdex + 1
        end; pnFrame:Remove()
        asmlib.SetOpVar("PANEL_FREQUENT_MODELS",nil)
        asmlib.LogInstance("OPEN_FRAME: Frame.OnClose: Form removed")
      end; asmlib.SetOpVar("PANEL_FREQUENT_MODELS",pnFrame)
      ------------ Button --------------
      xyPos.x = xyZero.x + xyDelta.x
      xyPos.y = xyZero.y + xyDelta.y
      xySiz.x = 55 -- Display properly the name
      xySiz.y = 25 -- Used by combo-box and text-box
      pnButton:SetParent(pnFrame)
      pnButton:SetText(pnElements:Select(1).Label[2])
      pnButton:SetPos(xyPos.x, xyPos.y)
      pnButton:SetSize(xySiz.x, xySiz.y)
      pnButton:SetVisible(true)
      pnButton.DoClick = function()
        asmlib.LogInstance("OPEN_FRAME: Button.DoClick: <"..pnButton:GetText().."> clicked")
        if(asmlib.GetAsmConvar("exportdb", "BUL")) then
          asmlib.LogInstance("OPEN_FRAME: Button Exporting DB")
          asmlib.ExportCategory(3)
          asmlib.ExportDSV("PIECES")
          asmlib.ConCommandPly(oPly, "exportdb", 0)
        end
      end
      ------------- ComboBox ---------------
      xyPos.x, xyPos.y = pnButton:GetPos()
      xyTmp.x, xyTmp.y = pnButton:GetSize()
      xyPos.x = xyPos.x + xyTmp.x + xyDelta.x
      xySiz.x = nRatio * xyTmp.x
      xySiz.y = xyTmp.y
      pnComboBox:SetParent(pnFrame)
      pnComboBox:SetPos(xyPos.x,xyPos.y)
      pnComboBox:SetSize(xySiz.x,xySiz.y)
      pnComboBox:SetVisible(true)
      pnComboBox:SetValue(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb"))
      pnComboBox:AddChoice(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb1"),defTable[1][1])
      pnComboBox:AddChoice(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb2"),defTable[2][1])
      pnComboBox:AddChoice(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb3"),defTable[3][1])
      pnComboBox:AddChoice(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb4"),defTable[4][1])
      pnComboBox.OnSelect = function(pnSelf, nInd, sVal, anyData)
        asmlib.LogInstance("OPEN_FRAME: ComboBox.OnSelect: ID #"..nInd.."<"..sVal..">"..tostring(anyData))
        pnSelf:SetValue(sVal)
      end
      ------------ ModelPanel --------------
      xySiz.x = 250 -- Display model properly
      xyTmp.x, xyTmp.y = pnFrame:GetSize()
      xyPos.x, xyPos.y = pnComboBox:GetPos()
      xyPos.x = xyTmp.x - xySiz.x - xyDelta.x
      xySiz.y = xyTmp.y - xyPos.y - xyDelta.y
      --------------------------------------
      pnModelPanel:SetParent(pnFrame)
      pnModelPanel:SetPos(xyPos.x,xyPos.y)
      pnModelPanel:SetSize(xySiz.x,xySiz.y)
      pnModelPanel:SetVisible(true)
      pnModelPanel.LayoutEntity = function(pnSelf, oEnt)
        if(pnSelf.bAnimated) then pnSelf:RunAnimation() end
        local uiBox = asmlib.CacheBoxLayout(oEnt,40)
        if(not asmlib.IsHere(uiBox)) then
          return asmlib.StatusLog(nil,"OPEN_FRAME: pnModelPanel.LayoutEntity: Box invalid") end
        local stSpawn = asmlib.GetNormalSpawn(oPly,asmlib.GetOpVar("VEC_ZERO"),uiBox.Ang,oEnt:GetModel())
        if(not stSpawn) then
          return asmlib.StatusLog(nil,"OPEN_FRAME: pnModelPanel.LayoutEntity: Spawn data fail") end
        asmlib.ApplySpawnFlat(oEnt, stSpawn, asmlib.GetOpVar("VEC_UP"))
              stSpawn.SPos:Set(uiBox.Cen)
              stSpawn.SPos:Rotate(stSpawn.SAng)
              stSpawn.SPos:Mul(-1)
              stSpawn.SPos:Add(uiBox.Cen)
        oEnt:SetAngles(stSpawn.SAng)
        oEnt:SetPos(stSpawn.SPos)
      end
      ------------ TextEntry --------------
      xyPos.x, xyPos.y = pnComboBox:GetPos()
      xyTmp.x, xyTmp.y = pnComboBox:GetSize()
      xyPos.x = xyPos.x + xyTmp.x + xyDelta.x
      xySiz.y = xyTmp.y
      -------------------------------------
      xyTmp.x, xyTmp.y = pnModelPanel:GetPos()
      xySiz.x = xyTmp.x - xyPos.x - xyDelta.x
      -------------------------------------
      pnTextEntry:SetParent(pnFrame)
      pnTextEntry:SetPos(xyPos.x,xyPos.y)
      pnTextEntry:SetSize(xySiz.x,xySiz.y)
      pnTextEntry:SetVisible(true)
      pnTextEntry.OnEnter = function(pnSelf)
        local sName, sField = pnComboBox:GetSelected()
              sName    = tostring(sName  or "")
              sField   = tostring(sField or "")
        local sPattern = tostring(pnSelf:GetValue() or "")
        if(not asmlib.UpdateListView(pnListView,frUsed,nCount,sField,sPattern)) then
          return asmlib.StatusLog(nil,"OPEN_FRAME: TextEntry.OnEnter: Failed to update ListView {"..sName.."#"..sField.."#"..sPattern.."}")
        end
      end
      ------------ ListView --------------
      xyPos.x, xyPos.y = pnButton:GetPos()
      xyTmp.x, xyTmp.y = pnButton:GetSize()
      xyPos.y = xyPos.y + xyTmp.y + xyDelta.y
      ------------------------------------
      xyTmp.x, xyTmp.y = pnTextEntry:GetPos()
      xySiz.x, xySiz.y = pnTextEntry:GetSize()
      xySiz.x = xyTmp.x + xySiz.x - xyDelta.x
      ------------------------------------
      xyTmp.x, xyTmp.y = pnFrame:GetSize()
      xySiz.y = xyTmp.y - xyPos.y - xyDelta.y
      ------------------------------------
      local wUse = mathFloor(0.150 * xySiz.x)
      local wRak = mathFloor(0.065 * xySiz.x)
      local wTyp = mathFloor(0.214 * xySiz.x)
      local wNam = xySiz.x - wUse - wRak - wTyp
      pnListView:SetParent(pnFrame)
      pnListView:SetVisible(false)
      pnListView:SetSortable(true)
      pnListView:SetMultiSelect(false)
      pnListView:SetPos(xyPos.x,xyPos.y)
      pnListView:SetSize(xySiz.x,xySiz.y)
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb1")):SetFixedWidth(wUse) -- (1)
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb2")):SetFixedWidth(wRak) -- (2)
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb3")):SetFixedWidth(wTyp) -- (3)
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb4")):SetFixedWidth(wNam) -- (4)
      pnListView.OnRowSelected = function(pnSelf, nIndex, pnLine)
        local uiMod = pnLine:GetColumnText(5) -- Forth index is actually the model in the table
                      pnModelPanel:SetModel(uiMod)
        local uiEnt = pnModelPanel:GetEntity()
        local uiBox = asmlib.CacheBoxLayout(uiEnt,0,nRatio,nRatio-1)
        if(not asmlib.IsHere(uiBox)) then
          return asmlib.StatusLog(nil,"OPEN_FRAME: ListView.OnRowSelected: Box invalid for <"..uiMod..">") end
        pnModelPanel:SetLookAt(uiBox.Eye); pnModelPanel:SetCamPos(uiBox.Cam)
        asmlib.ConCommandPly(oPly, "model" ,uiMod)
      end -- Copy the line model to the clipboard so it can be pasted with Ctrl+V
      pnListView.OnRowRightClick = function(pnSelf, nIndex, pnLine) SetClipboardText(pnLine:GetColumnText(5)) end
      if(not asmlib.UpdateListView(pnListView,frUsed,nCount)) then
        return asmlib.StatusLog(nil,"OPEN_FRAME: ListView.OnRowSelected: Populate the list view failed") end
      ------------ Show the completed panel --------------
      pnFrame:SetVisible(true); pnFrame:Center(); pnFrame:MakePopup()
      return asmlib.StatusLog(nil,"OPEN_FRAME: Success")
    end)
end

asmlib.CreateTable("PIECES",{
    Timer = asmlib.TimerSetting(gaTimerSet[1]),
    Index = {{1},{2},{3},{1,4},{1,2},{2,4},{1,2,3}},
    [1] = {"MODEL" , "TEXT", "LOW", "QMK"},
    [2] = {"TYPE"  , "TEXT",  nil , "QMK"},
    [3] = {"NAME"  , "TEXT",  nil , "QMK"},
    [4] = {"AMESH" , "REAL",  nil ,  nil },
    [5] = {"POINT" , "TEXT",  nil ,  nil },
    [6] = {"ORIGN" , "TEXT",  nil ,  nil },
    [7] = {"ANGLE" , "TEXT",  nil ,  nil },
    [8] = {"CLASS" , "TEXT",  nil ,  nil }
},true,true)

--[[ Categories are only needed client side ]]--
if(CLIENT) then
  if(fileExists(gsFullDSV.."CATEGORY.txt", "DATA")) then
    asmlib.LogInstance("Init: DB CATEGORY from DSV")
    asmlib.ImportCategory(3)
  else asmlib.LogInstance("Init: DB CATEGORY from LUA") end
end

if(fileExists(gsFullDSV.."PIECES.txt", "DATA")) then
  asmlib.LogInstance("Init: DB PIECES from DSV")
  asmlib.ImportDSV("PIECES",true)
else
  if(gsMoDB == "SQL") then sqlBegin() end
  asmlib.LogInstance("Init: DB PIECES from LUA")
  if(asmlib.GetAsmConvar("devmode" ,"BUL")) then
    asmlib.Categorize("Develop random")
    asmlib.InsertRecord({"models/props_wasteland/wheel02b.mdl",   "Development", "Dev1", 45, "65, 0, 0", "0.29567885398865,0.3865530192852,-0.36239844560623", "@-90, 90, 180"})
  end
  asmlib.DefaultTable("PIECES")
  asmlib.Categorize("Old Gmod 10")
  asmlib.InsertRecord({"models/props_phx/mechanics/medgear.mdl", "#", "#", 0, "24.173, 0, 0", "-0.01517273113131500,  0.0090782083570957, 3.5684652328491", ""})
  asmlib.InsertRecord({"models/props_phx/mechanics/biggear.mdl", "#", "#", 0, "33.811, 0, 0", "-0.00017268359079026, -0.0035230871289968, 3.5217847824097", ""})
  asmlib.InsertRecord({"models/props_phx/mechanics/slider1.mdl", "#", "#", 0, " 3.000, 0, 0", " 0.17126856744289000, -0.1066822558641400, 3.5165667533875", "@90,-90,180"})
  asmlib.InsertRecord({"models/props_phx/mechanics/slider2.mdl", "#", "#", 0, " 3.000, 0, 0", " 0.17126856744289000, -0.1066822558641400, 3.5165667533875", "@90,-90,180"})
  asmlib.Categorize("PHX Spotted Flat")
  asmlib.InsertRecord({"models/props_phx/gears/spur9.mdl" , "#", "#", 0, " 7.467, 0, 0", "-0.0015837327810004,  0.000161714502610270, 2.8354094028473", ""})
  asmlib.InsertRecord({"models/props_phx/gears/spur12.mdl", "#", "#", 0, " 9.703, 0, 0", "-0.0015269597060978,  0.000214137573493640, 2.8405227661133", ""})
  asmlib.InsertRecord({"models/props_phx/gears/spur24.mdl", "#", "#", 0, "18.381, 0, 0", "-0.0011573693482205,  0.000182285642949860, 2.8103637695313", ""})
  asmlib.InsertRecord({"models/props_phx/gears/spur36.mdl", "#", "#", 0, "27.119, 0, 0", "-0.0012206265237182, -8.6402214947157e-005, 2.7949125766754", ""})
  asmlib.Categorize("PHX Regular Small")
  asmlib.InsertRecord({"models/mechanics/gears/gear12x6_small.mdl" , "#", "#", 0, " 6.708, 0, 0", " 2.5334677047795e-005,  0.007706293836236000, 1.5820281505585", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x6_small.mdl" , "#", "#", 0, " 9.600, 0, 0", " 5.0195762923977e-007, -3.5567546774473e-007, 1.5833348035812", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x6_small.mdl" , "#", "#", 0, "13.567, 0, 0", " 0.000744899793062360, -0.000149385989061560, 1.5826840400696", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x12_small.mdl", "#", "#", 0, " 6.708, 0, 0", " 4.2988057202820e-007,  2.1906590319531e-008, 3.0833337306976", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x12_small.mdl", "#", "#", 0, " 9.600, 0, 0", " 4.3190007659177e-007, -2.4458054781462e-007, 3.0833337306976", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x12_small.mdl", "#", "#", 0, "13.567, 0, 0", "-0.001789825619198400, -0.002677073236554900, 2.9987792968750", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x24_small.mdl", "#", "#", 0, " 6.708, 0, 0", " 0.006947830319404600,  0.002904084511101200, 6.0784306526184", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x24_small.mdl", "#", "#", 0, " 9.600, 0, 0", "-0.000453756365459410,  0.006951440125703800, 6.0618972778320", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x24_small.mdl", "#", "#", 0, "13.567, 0, 0", "-0.013954215683043000,  0.000910685281269250, 6.0729651451111", ""})
  asmlib.Categorize("PHX Regular Medium")
  asmlib.InsertRecord({"models/mechanics/gears/gear12x6.mdl" , "#", "#", 0, "13.20, 0, 0", " 3.8183276274140e-007,  2.8411110974957e-007, 03.1666665077209", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x6.mdl" , "#", "#", 0, "19.10, 0, 0", " 1.2454452189559e-006, -5.1244381893412e-007, 03.1666696071625", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x6.mdl" , "#", "#", 0, "26.96, 0, 0", " 0.001489854301326000, -0.000298895174637440, 03.1653680801392", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x12.mdl", "#", "#", 0, "13.20, 0, 0", " 1.2779588587364e-006,  2.8910221772094e-007, 06.1666665077209", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x12.mdl", "#", "#", 0, "19.10, 0, 0", " 1.3081521501590e-006, -7.5695822943089e-007, 06.1666674613953", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x12.mdl", "#", "#", 0, "26.96, 0, 0", " 0.009243813343346100, -0.008400838822126400, 05.9975576400757", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x24.mdl", "#", "#", 0, "13.20, 0, 0", " 8.2542783275130e-007,  8.7331630993503e-007, 12.1666622161870", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x24.mdl", "#", "#", 0, "19.10, 0, 0", " 8.6996135451045e-007, -2.8219722025824e-007, 12.1666593551640", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x24.mdl", "#", "#", 0, "26.96, 0, 0", "-0.009472424164414400, -0.006620032247155900, 12.1501836776730", ""})
  asmlib.Categorize("PHX Regular Big")
  asmlib.InsertRecord({"models/mechanics/gears/gear12x24_large.mdl", "#", "#", 0, "26.196, 0, 0", " 1.6508556655026e-006,  1.7466326198701e-006, 24.333324432373", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x12_large.mdl", "#", "#", 0, "26.196, 0, 0", " 3.6818344142375e-006,  3.3693649470479e-007, 12.333333015442", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear12x6_large.mdl" , "#", "#", 0, "26.196, 0, 0", " 3.8200619201234e-007,  4.0919746879808e-007, 6.3333339691162", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x24_large.mdl", "#", "#", 0, "37.480, 0, 0", " 1.7399227090209e-006, -2.1441636022246e-007, 24.333318710327", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x12_large.mdl", "#", "#", 0, "37.480, 0, 0", " 1.6911637885642e-006, -1.7452016436437e-006, 12.333334922791", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear16x6_large.mdl" , "#", "#", 0, "37.480, 0, 0", " 2.9455352432706e-006, -9.6805695193325e-007, 6.3333392143250", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x24_large.mdl", "#", "#", 0, "53.600, 0, 0", " 1.0641871313055e-006, -3.3355117921019e-006, 24.333333969116", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x12_large.mdl", "#", "#", 0, "53.600, 0, 0", "-6.2653803922785e-008, -3.8585267247981e-006, 12.000000000000", ""})
  asmlib.InsertRecord({"models/mechanics/gears/gear24x6_large.mdl" , "#", "#", 0, "53.600, 0, 0", " 1.0842279607459e-006, -3.8418565964093e-006, 6.3333292007446", ""})
  asmlib.Categorize("PHX Regular Flat")
  asmlib.InsertRecord({"models/Mechanics/gears2/gear_12t1.mdl", "#", "#", 0, "14, 0, 0", " 0.02477267012000100, -0.00390978017821910,  3.7019141529981e-008", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_12t3.mdl", "#", "#", 0, "14, 0, 0", "-0.00028943095821887,  0.01085923984646800,  0.002960268640890700", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_12t2.mdl", "#", "#", 0, "14, 0, 0", "-0.01700693927705300,  0.00306556094437840, -0.000570227275602520", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_18t1.mdl", "#", "#", 0, "20, 0, 0", " 0.00691169640049340,  0.00104868412017820, -0.000136307076900270", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_18t2.mdl", "#", "#", 0, "20, 0, 0", "-0.01048096176236900, -0.00094905123114586, -0.000272105389740320", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_18t3.mdl", "#", "#", 0, "20, 0, 0", "-0.00401565060019490,  0.00440873485058550, -0.001629892853088700", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_24t1.mdl", "#", "#", 0, "26, 0, 0", " 0.00055550865363330,  0.00184039084706460,  7.969097350724e-0050", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_24t2.mdl", "#", "#", 0, "26, 0, 0", " 0.00018490960064810, -0.00211607688106600,  0.000921697530429810", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_24t3.mdl", "#", "#", 0, "26, 0, 0", "-0.00395193602889780, -0.00076565862400457,  0.000952805217821150", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_36t1.mdl", "#", "#", 0, "38, 0, 0", "-0.01395238470286100, -0.01505182497203400, -3.6770456063095e-005", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_36t2.mdl", "#", "#", 0, "38, 0, 0", "-0.00166015082504600,  0.00674992008134720,  7.3757772042882e-005", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_36t3.mdl", "#", "#", 0, "38, 0, 0", "-0.01222306583076700, -0.00136547279544170, -0.000441020849393680", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_48t1.mdl", "#", "#", 0, "50, 0, 0", " 0.00153891730587930,  0.00347473472356800,  0.000287709815893320", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_48t2.mdl", "#", "#", 0, "50, 0, 0", " 0.00308891711756590, -0.00082554836990312, -8.9276603830513e-005", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_48t3.mdl", "#", "#", 0, "50, 0, 0", "-0.00083220232045278, -0.00013183639384806, -0.002822688082233100", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_60t1.mdl", "#", "#", 0, "62, 0, 0", " 0.01799790561199200, -0.00836088601499800,  0.000236688618315380", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_60t2.mdl", "#", "#", 0, "62, 0, 0", "-0.00778029020875690,  0.00776998186483980, -0.000112452820758340", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/gear_60t3.mdl", "#", "#", 0, "62, 0, 0", "-0.00085410091560334,  0.00534614734351630, -0.000295745179755610", ""})
  asmlib.Categorize("PHX Vertical")
  asmlib.InsertRecord({"models/Mechanics/gears2/vert_18t1.mdl", "#", "#", 90, "19.78, 0, 5.6", "-9.3372744913722e-007, -1.4464712876361e-006, -1.4973667860031", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/vert_12t1.mdl", "#", "#", 90, "13.78, 0, 5.6", "-6.1126132777645e-007,  4.6880626314305e-007, -1.4130713939667", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/vert_24t1.mdl", "#", "#", 90, "25.78, 0, 5.6", "-0.004672059323638700, -0.009078560397028900, -1.5481045246124", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/vert_36t1.mdl", "#", "#", 90, "37.78, 0, 5.6", " 0.004358193371444900, -0.000180053510121070, -1.6056708097458", ""})
  asmlib.Categorize("PHX Teeth Flat")
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_20t1.mdl", "#", "#", 0, "2.55, 0, 0", "-0.0310611166059970, 0.68289417028427, 0.00010814304550877", "0,90,0"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_20t2.mdl", "#", "#", 0, "2.55, 0, 0", "-0.0308688133955000, 0.68287181854248, 0.00033729249844328", "0,90,0"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_20t3.mdl", "#", "#", 0, "2.55, 0, 0", "-0.0308684334158900, 0.68287181854248, 0.00067511270754039", "0,90,0"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_40t1.mdl", "#", "#", 0, "2.55, 0, 0", "-0.0045434008352458, 0.68366396427155, 0.00209069182164970", "0,90,0"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_40t2.mdl", "#", "#", 0, "2.55, 0, 0", "-0.0043520531617105, 0.68364036083221, 0.00430238526314500", "0,90,0"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_40t3.mdl", "#", "#", 0, "2.55, 0, 0", "-0.0043467613868415, 0.68364137411118, 0.00860620010644200", "0,90,0"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_80t1.mdl", "#", "#", 0, "2.55, 0, 0", "-0.0180192049592730, 0.68289333581924, 0.00052548095118254", "0,90,0"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_80t2.mdl", "#", "#", 0, "2.55, 0, 0", "-0.0178730152547360, 0.68288779258728, 0.00107426801696420", "0,90,0"})
  asmlib.InsertRecord({"models/mechanics/gears2/pinion_80t3.mdl", "#", "#", 0, "2.55, 0, 0", "-0.0180220548063520, 0.68289351463318, 0.00210226024501030", "0,90,0"})
  asmlib.Categorize("PHX Spotted Rack")
  asmlib.InsertRecord({"models/props_phx/gears/rack9.mdl" , "#", "#", 0, " 2.7, 0, 0", "-0.00016037904424593, -0.137806907296180, 2.3622412681580", "@90,180,180"})
  asmlib.InsertRecord({"models/props_phx/gears/rack18.mdl", "#", "#", 0, " 2.7, 0, 0", " 0.02291502803564100,  2.260936260223400, 2.3429780006409", "@90,180,180"})
  asmlib.InsertRecord({"models/props_phx/gears/rack36.mdl", "#", "#", 0, " 2.7, 0, 0", " 0.01365591119974900, -0.019220048561692, 2.3991346359253", "@90,180,180"})
  asmlib.InsertRecord({"models/props_phx/gears/rack70.mdl", "#", "#", 0, " 2.7, 0, 0", "-0.01785501651465900,  0.201563835144040, 2.3644349575043", "@90,180,180"})
  asmlib.Categorize("PHX Bevel")
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_12t1.mdl", "#", "#", 45, "12.2, 0, 1.3", "-0.002645550761371900, -0.0061479024589062, -0.87438750267029", ""})
  asmlib.InsertRecord({"models/Mechanics/gears2/bevel_18t1.mdl", "#", "#", 45, "17.3, 0, 1.3", "-0.033187858760357000,  0.0065126456320286, -1.05252802371980", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_24t1.mdl", "#", "#", 45, "23.3, 0, 1.3", "-0.001187232206575600,  0.0026002936065197, -0.86795377731323", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_36t1.mdl", "#", "#", 45, "34.8, 0, 1.3", " 0.000668477558065210,  0.0034906349610537, -0.86690950393677", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_48t1.mdl", "#", "#", 45, "46.7, 0, 1.3", "-0.012435931712389000, -0.0129251489415760, -0.73237001895905", ""})
  asmlib.InsertRecord({"models/mechanics/gears2/bevel_60t1.mdl", "#", "#", 45, "58.6, 0, 1.3", "-9.5774739747867e-005,  0.0057542459107935, -0.73121488094330", ""})
  asmlib.Categorize("Black Regular Medium")
  asmlib.InsertRecord({"models/gears/gear1_m_12.mdl" , "#", "#", 0, " 7.684, 0, 0", "-0.014979394152761000,  0.004799870774149900, -0.000382247671950610", ""})
  asmlib.InsertRecord({"models/gears/gear1_m_18.mdl" , "#", "#", 0, "11.576, 0, 0", "-0.002106353640556300, -0.005328254308551500,  0.000875713478308170", ""})
  asmlib.InsertRecord({"models/gears/gear1_m_24.mdl" , "#", "#", 0, "15.663, 0, 0", "-0.007063865195959800,  0.009610753506422000, -0.000153392858919690", ""})
  asmlib.InsertRecord({"models/gears/gear1_m_30.mdl" , "#", "#", 0, "19.603, 0, 0", "-0.007770653814077400, -0.007182538975030200,  0.000974631519056860", ""})
  asmlib.InsertRecord({"models/gears/gear1_m_36.mdl" , "#", "#", 0, "23.656, 0, 0", "-0.004407854750752400,  0.005025713238865100, -0.000151815474964680", ""})
  asmlib.InsertRecord({"models/gears/gear1_m2_12.mdl", "#", "#", 0, " 7.684, 0, 0", "-0.000580689695198090,  0.013377501629293000, -1.1378889297475e-007", ""})
  asmlib.InsertRecord({"models/gears/gear1_m2_18.mdl", "#", "#", 0, "11.576, 0, 0", " 6.8955853294028e-007, -7.7567614198415e-007, -1.3395394660165e-007", ""})
  asmlib.InsertRecord({"models/gears/gear1_m2_24.mdl", "#", "#", 0, "15.663, 0, 0", "-0.005118893459439300,  0.004202520474791500,  3.5875429603038e-005", ""})
  asmlib.InsertRecord({"models/gears/gear1_m2_30.mdl", "#", "#", 0, "19.603, 0, 0", "-0.010076130740345000,  0.003432701108977200,  0.001892712083645200", ""})
  asmlib.InsertRecord({"models/gears/gear1_m2_36.mdl", "#", "#", 0, "23.656, 0, 0", " 0.004557605367153900, -0.004030615556985100,  0.000949562701862310", ""})
  asmlib.InsertRecord({"models/gears/gear1_m3_12.mdl", "#", "#", 0, " 7.684, 0, 0", " 0.006812935229390900, -0.010897922329605000, -0.001913452520966500", ""})
  asmlib.InsertRecord({"models/gears/gear1_m3_18.mdl", "#", "#", 0, "11.576, 0, 0", "-2.666999421308e-0070, -3.7215826864667e-007, -5.6812831417119e-007", ""})
  asmlib.InsertRecord({"models/gears/gear1_m3_24.mdl", "#", "#", 0, "15.663, 0, 0", "-0.005681079346686600, -0.001288813189603400, -0.002004494192078700", ""})
  asmlib.InsertRecord({"models/gears/gear1_m3_30.mdl", "#", "#", 0, "19.603, 0, 0", "-0.000856459722854200,  0.003441185690462600,  0.001592476852238200", ""})
  asmlib.InsertRecord({"models/gears/gear1_m3_36.mdl", "#", "#", 0, "23.656, 0, 0", " 0.007684207521379000,  0.002827123273164000,  0.000343827065080400", ""})
  asmlib.Categorize("Black Regular Small")
  asmlib.InsertRecord({"models/gears/gear1_s_12.mdl" , "#", "#", 0, " 3.913, 0, 0", " 0.0038407891988754,  0.01433348096907100, -5.8103839961632e-008", ""})
  asmlib.InsertRecord({"models/gears/gear1_s_18.mdl" , "#", "#", 0, " 5.886, 0, 0", "-0.0022506208624691,  0.00285101705230770,  0.000125224818475540", ""})
  asmlib.InsertRecord({"models/gears/gear1_s_24.mdl" , "#", "#", 0, " 7.917, 0, 0", "-0.0139679908752440, -0.02164526097476500, -0.000825085153337570", ""})
  asmlib.InsertRecord({"models/gears/gear1_s_30.mdl" , "#", "#", 0, " 9.849, 0, 0", "-0.0056244987063110, -0.00242018746212120,  0.000241886649746450", ""})
  asmlib.InsertRecord({"models/gears/gear1_s_36.mdl" , "#", "#", 0, "11.848, 0, 0", " 0.0077217095531523, -0.00559770176187160, -0.000157134229084480", ""})
  asmlib.InsertRecord({"models/gears/gear1_s2_12.mdl", "#", "#", 0, " 3.913, 0, 0", " 0.0021100759040564, -0.00167331367265430,  0.002285032998770500", ""})
  asmlib.InsertRecord({"models/gears/gear1_s2_18.mdl", "#", "#", 0, " 5.886, 0, 0", " 0.0039685778319836, -0.00851940456777810, -0.000551324570551510", ""})
  asmlib.InsertRecord({"models/gears/gear1_s2_24.mdl", "#", "#", 0, " 7.917, 0, 0", "-0.0048923366703093, -0.00774347642436620, -0.001594897359609600", ""})
  asmlib.InsertRecord({"models/gears/gear1_s2_30.mdl", "#", "#", 0, " 9.849, 0, 0", "-0.0064226854592562,  0.02016016840934800,  0.001108262920752200", ""})
  asmlib.InsertRecord({"models/gears/gear1_s2_36.mdl", "#", "#", 0, "11.848, 0, 0", " 0.0093966554850340,  0.01052845641970600,  0.003377517685294200", ""})
  asmlib.InsertRecord({"models/gears/gear1_s3_12.mdl", "#", "#", 0, " 3.913, 0, 0", " 0.0018781825201586, -0.00144265242852270, -0.000950081972405310", ""})
  asmlib.InsertRecord({"models/gears/gear1_s3_18.mdl", "#", "#", 0, " 5.886, 0, 0", " 0.0099822543561459,  0.00096216786187142,  0.002506384160369600", ""})
  asmlib.InsertRecord({"models/gears/gear1_s3_24.mdl", "#", "#", 0, " 7.917, 0, 0", " 0.0073104859329760, -0.00477525778114800,  0.001730017247609800", ""})
  asmlib.InsertRecord({"models/gears/gear1_s3_30.mdl", "#", "#", 0, " 9.849, 0, 0", " 0.0016155475750566, -0.01016659941524300, -0.000659143610391770", ""})
  asmlib.InsertRecord({"models/gears/gear1_s3_36.mdl", "#", "#", 0, "11.848, 0, 0", " 0.0145232733339070,  0.01204503700137100,  0.000544754613656550", ""})
  asmlib.Categorize("SProps",[[function(m)
    local function conv(x) return " "..x:sub(2,2):upper() end
    local r = m:gsub("models/sprops/mechanics/","")
    local s = r:find("/")
    local o = s and {r:sub(1,s-1)} or nil
    for i = 1, #o do o[i] = ("_"..o[i]):gsub("_%w", conv):sub(2,-1) end; return o end]])
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_10t_s.mdl", "#", "#", 0, " 2.820, 0, 0", " 0.004917243029922200, -0.004917799960821900, -1.5156917498871e-008", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_12t_s.mdl", "#", "#", 0, " 3.100, 0, 0", "-0.001883051590994000,  0.000501719361636790, -0.000593971111811700", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_14t_s.mdl", "#", "#", 0, " 3.784, 0, 0", " 0.002141302684322000, -0.002729385625571000,  0.013979037292302000", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_16t_s.mdl", "#", "#", 0, " 4.271, 0, 0", " 0.001530641922727200, -0.000574479054193940, -0.000528061122167860", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_18t_s.mdl", "#", "#", 0, " 4.761, 0, 0", "-0.001724119181744800, -0.006324416492134300, -0.000377080228645350", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_24t_s.mdl", "#", "#", 0, " 6.237, 0, 0", "-2.9937275485281e-006, -1.4846134490654e-006, -1.7167849364341e-008", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_30t_s.mdl", "#", "#", 0, " 7.722, 0, 0", " 0.001925386604853000,  0.000101605270174330,  0.000213125356822270", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_36t_s.mdl", "#", "#", 0, " 9.211, 0, 0", "-0.000562217086553570, -7.6126736530568e-005, -1.2265476634354e-008", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_42t_s.mdl", "#", "#", 0, "10.703, 0, 0", "-2.1004445898143e-006, -1.0246620831822e-006,  8.0583710371229e-008", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_48t_s.mdl", "#", "#", 0, "12.197, 0, 0", "-0.004684736952185600, -0.003102034563198700, -0.000298691913485530", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_54t_s.mdl", "#", "#", 0, "13.692, 0, 0", " 0.001435556798242000, -0.020333550870419000, -0.002073103329166800", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_60t_s.mdl", "#", "#", 0, "15.188, 0, 0", " 0.020014140754938000,  0.018639868125319000, -0.000443639495642860", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_66t_s.mdl", "#", "#", 0, "16.685, 0, 0", "-0.010388540104032000,  0.016772596165538000, -0.000340160913765430", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_72t_s.mdl", "#", "#", 0, "18.182, 0, 0", " 0.036256127059460000, -0.002408307977020700,  9.4895163783804e-005", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_78t_s.mdl", "#", "#", 0, "19.680, 0, 0", " 0.001980507047846900, -0.008149571716785400,  0.000650459434837100", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_84t_s.mdl", "#", "#", 0, "21.178, 0, 0", " 0.030328331515193000, -0.021101905032992000, -0.000291800999548290", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_90t_s.mdl", "#", "#", 0, "22.676, 0, 0", "-0.029588585719466000, -0.014376631937921000, -0.000696827773936090", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_96t_s.mdl", "#", "#", 0, "24.174, 0, 0", " 0.005857755895704000, -0.014768015593290000, -0.000284290203126150", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_10t_l.mdl", "#", "#", 0, " 5.394, 0, 0", "-0.004149563610553700, -0.003015119815245300, -0.005914899054914700", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_12t_l.mdl", "#", "#", 0, " 6.358, 0, 0", "-0.003765390953049100, -0.006521004717797000, -0.002377677476033600", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_14t_l.mdl", "#", "#", 0, " 7.330, 0, 0", " 4.0495933717466e-007,  3.3086558914874e-007, -3.2839650998540e-008", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_16t_l.mdl", "#", "#", 0, " 8.307, 0, 0", "-0.002872290788218400,  0.000866234011482450, -3.2330953469994e-009", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_18t_l.mdl", "#", "#", 0, " 9.288, 0, 0", " 0.006886367220431600, -0.001988542033359400,  0.000376516050891950", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_24t_l.mdl", "#", "#", 0, "12.247, 0, 0", "-2.9040645586065e-006, -3.0396604415728e-006, -3.5156244582168e-009", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_30t_l.mdl", "#", "#", 0, "15.221, 0, 0", "-0.003847200190648400, -0.005274873226881000,  0.001536299823783300", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_36t_l.mdl", "#", "#", 0, "18.203, 0, 0", " 0.003766206325963100,  0.002695813542231900, -0.000897790596354750", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_42t_l.mdl", "#", "#", 0, "21.189, 0, 0", "-2.4632468011987e-006, -2.1759717583336e-006,  1.3644348939579e-007", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_48t_l.mdl", "#", "#", 0, "24.179, 0, 0", "-9.0362368609931e-007, -2.2698932298226e-006,  2.9944263957304e-008", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_54t_l.mdl", "#", "#", 0, "27.171, 0, 0", "-0.000127034276374620,  0.008727177046239400,  0.000649321940727530", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_60t_l.mdl", "#", "#", 0, "30.164, 0, 0", " 0.005686341784894500, -0.005485964007675600,  0.000575263868086040", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_66t_l.mdl", "#", "#", 0, "33.158, 0, 0", " 0.000347872584825380,  0.011729797348380000,  0.000391852256143470", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_72t_l.mdl", "#", "#", 0, "36.154, 0, 0", " 0.005927943624556100, -0.000145542988320810,  0.000432313187047840", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_78t_l.mdl", "#", "#", 0, "39.150, 0, 0", " 0.035279795527458000,  0.000277207494946200, -0.000284841720713300", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_84t_l.mdl", "#", "#", 0, "42.146, 0, 0", "-0.006362336687743700, -0.004017293918877800,  0.000289340328890830", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_90t_l.mdl", "#", "#", 0, "45.143, 0, 0", "-3.0313363822643e-005,  0.002589772688224900, -8.3106489910278e-005", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/sgears/spur_96t_l.mdl", "#", "#", 0, "48.141, 0, 0", "-0.020891901105642000, -0.001010068226605700,  0.000145230849739160", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_10t_s.mdl", "#", "#", 45, " 2.793, 0, 0.7", "-1.1249650924583e-005,  0.000307279406115410, -0.50872629880905", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_12t_s.mdl", "#", "#", 45, " 3.289, 0, 0.7", " 0.021812098100781000,  0.034060511738062000, -0.48147577047348", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_14t_s.mdl", "#", "#", 45, " 3.784, 0, 0.7", " 0.012455121614039000,  0.008836550638079600, -0.46449995040894", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_16t_s.mdl", "#", "#", 45, " 4.279, 0, 0.7", " 0.000572145159821960,  0.000847371702548120, -0.44488653540611", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_18t_s.mdl", "#", "#", 45, " 4.775, 0, 0.7", "-0.015875330194831000, -0.006157481577247400, -0.42753458023071", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_24t_s.mdl", "#", "#", 45, " 6.264, 0, 0.7", "-2.9411880859698e-006, -1.5586849713145e-006, -0.40141621232033", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_30t_s.mdl", "#", "#", 45, " 7.755, 0, 0.7", " 0.011199345812202000, -0.002341645769774900, -0.38323742151260", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_36t_s.mdl", "#", "#", 45, " 9.249, 0, 0.7", "-2.1506830307771e-005, -0.008262155577540400, -0.37152001261711", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_42t_s.mdl", "#", "#", 45, "10.744, 0, 0.7", "-1.2801006050722e-006,  1.4830366978913e-007, -0.36367011070251", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_48t_s.mdl", "#", "#", 45, "12.240, 0, 0.7", "-0.026493191719055000,  0.041309744119644000, -0.35398504137993", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_54t_s.mdl", "#", "#", 45, "13.737, 0, 0.7", " 0.011715604923666000, -0.006210407242178900, -0.35115513205528", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_60t_s.mdl", "#", "#", 45, "15.234, 0, 0.7", " 0.002376772928983000, -0.009667715057730700, -0.34716984629631", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_10t_l.mdl", "#", "#", 45, " 5.520, 0, 1.35", "-2.1634095901391e-005,  0.000614633026998490, -1.01745247840880", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_12t_l.mdl", "#", "#", 45, " 6.244, 0, 1.35", "-0.030667111277580000,  0.013303384184837000, -0.95678430795670", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_14t_l.mdl", "#", "#", 45, " 7.237, 0, 1.35", " 0.004678149707615400,  0.004543182440102100, -0.91953921318054", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_16t_l.mdl", "#", "#", 45, " 8.230, 0, 1.35", "-0.002415109891444400, -0.003520348342135500, -0.88513052463531", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_18t_l.mdl", "#", "#", 45, " 9.280, 0, 1.35", "-3.7560730561381e-006, -3.2225407267106e-006, -0.85729819536209", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_24t_l.mdl", "#", "#", 45, "12.252, 0, 1.35", "-2.7985045107926e-006, -3.2531474971620e-006, -0.80283242464066", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_30t_l.mdl", "#", "#", 45, "15.275, 0, 1.35", " 0.006597241852432500,  0.012552709318697000, -0.76705181598663", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_36t_l.mdl", "#", "#", 45, "18.257, 0, 1.35", " 0.003213209332898300,  0.006986753083765500, -0.74561846256256", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_42t_l.mdl", "#", "#", 45, "21.244, 0, 1.35", "-2.1220994312898e-006, -1.2074082178515e-006, -0.72734010219574", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_48t_l.mdl", "#", "#", 45, "24.233, 0, 1.35", " 0.004356477409601200,  0.007277844473719600, -0.71259909868240", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_54t_l.mdl", "#", "#", 45, "27.193, 0, 1.35", "-0.001236007781699300, -0.015729079023004000, -0.70351052284241", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/bgears/bevel_60t_l.mdl", "#", "#", 45, "30.188, 0, 1.35", " 0.002415595808997800, -0.000484355346998200, -0.69532954692841", ""})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_12t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-8.9563911842561e-007,  7.6235728556640e-006, -0.33236381411552", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_24t_s.mdl", "#", "#", 0, " 1.050, 0, 0", " 7.8051094476450e-008,  5.1519514272513e-006, -0.33522164821625", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_36t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-3.1340739781172e-008,  3.3068738503061e-006, -0.33615264296532", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_48t_s.mdl", "#", "#", 0, " 1.050, 0, 0", " 3.8751231841161e-006,  7.3969954428321e-006, -0.33661276102066", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_60t_s.mdl", "#", "#", 0, " 1.050, 0, 0", " 6.0092202325279e-009,  2.8254335120437e-005, -0.33688813447952", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_72t_s.mdl", "#", "#", 0, " 1.050, 0, 0", " 3.8311595744744e-006,  2.3214635803015e-005, -0.33707144856453", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_84t_s.mdl", "#", "#", 0, " 1.050, 0, 0", " 4.1014533991302e-008,  2.9928796720924e-005, -0.33720290660858", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_96t_s.mdl", "#", "#", 0, " 1.050, 0, 0", "-7.6562746471609e-006,  2.0776307792403e-005, -0.33730128407478", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_12t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-7.0960714992907e-007,  9.5314753707498e-006, -0.66472762823105", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_24t_l.mdl", "#", "#", 0, " 2.100, 0, 0", " 2.0629582309084e-007,  9.6307467174483e-006, -0.67044341564178", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_36t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-3.4605172061219e-008, -4.9788040996646e-006, -0.67230480909348", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_48t_l.mdl", "#", "#", 0, " 2.100, 0, 0", " 3.8946841414145e-006,  4.0884210648073e-006, -0.67322540283203", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_60t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-4.1661261107606e-009,  4.5187160139903e-005, -0.67377626895905", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_72t_l.mdl", "#", "#", 0, " 2.100, 0, 0", " 3.8322218642861e-006,  5.0654783990467e-005, -0.67414307594299", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_84t_l.mdl", "#", "#", 0, " 2.100, 0, 0", " 3.9428311282563e-008,  6.2194543716032e-005, -0.67440587282181", "@90,180,180"})
  asmlib.InsertRecord({"models/sprops/mechanics/racks/rack_96t_l.mdl", "#", "#", 0, " 2.100, 0, 0", "-7.7476306614699e-006,  3.5831995774060e-005, -0.67460036277771", "@90,180,180"})
  asmlib.Categorize("Propeller")
  asmlib.InsertRecord({"models/gears/helical_6.mdl"    , "#", "#", 0  , "4.200, 0, 0", "2.4844780455169e-07,-9.5801503618986e-08,4.0000004768372" , ""})
  asmlib.InsertRecord({"models/gears/helical_6r.mdl"   , "#", "#", 0  , "4.200, 0, 0", "-2.8797717277484e-07,-1.3904138995713e-07,4.0000004768372" , ""})
  asmlib.InsertRecord({"models/gears/helical_6_16.mdl" , "#", "#", 0  , "4.200, 0, 0", "7.5279736222456e-08,-2.9573199000765e-08,8" , ""})
  asmlib.InsertRecord({"models/gears/helical_6r_16.mdl", "#", "#", 0  , "4.200, 0, 0", "2.3595329423642e-07,-1.3354592098835e-08,8.0000009536743" , ""})
  asmlib.InsertRecord({"models/gears/gear_s_8.mdl"     , "#", "#", 0  , "2.653, 0, 0", "3.5367751394233e-08,8.1306321675356e-09,1.9999996423721" , ""})
  asmlib.InsertRecord({"models/gears/gear_s_9.mdl"     , "#", "#", 0  , "2.970, 0, 0", "-0.0017608144553378,0.0031441354658455,1.9984290599823" , ""})
  asmlib.InsertRecord({"models/gears/gear_s_10.mdl"    , "#", "#", 0  , "3.295, 0, 0", "2.1292475338441e-08,-1.7916628181069e-08,2" , ""})
  asmlib.InsertRecord({"models/gears/planet_s_26.mdl"  , "#", "#", 180, "8.820, 0, 1.254", "2.1619855488098e-06,-6.0512252275657e-06,2.2488708496094" , ""})
  asmlib.InsertRecord({"models/gears/planet_s_27.mdl"  , "#", "#", 180, "9.200, 0, 1.450", "0.0086102271452546,0.00077429559314623,2.0545327663422" , ""})
  asmlib.InsertRecord({"models/gears/gear_3.mdl"       , "#", "#", 0  , "1.903, 0, 0", "-8.8830764966019e-009,  1.7266756913159e-005, 4.0000004768372" , ""})
  asmlib.InsertRecord({"models/gears/gear_6.mdl"       , "#", "#", 0  , "3.098, 0, 0", " 6.2004239964608e-008,  7.2985351096122e-009, 3.9999983310699" , ""})
  asmlib.InsertRecord({"models/gears/gear_12.mdl"      , "#", "#", 0  , "5.234, 0, 0", " 2.1442920328241e-008,  2.5950571469480e-008, 4.0000009536743" , ""})
  asmlib.InsertRecord({"models/gears/gear_24.mdl"      , "#", "#", 0  , "9.470, 0, 0", "-2.3349744537882e-007, -1.7496104192105e-006, 3.9999997615814" , ""})
  asmlib.InsertRecord({"models/gears/planet_16.mdl"    , "#", "#", 180, "9.310, 0, -1.615", " 2.1667046894436e-006, -1.2715023558485e-006, 5.6510457992554" , ""})
  if(gsMoDB == "SQL") then sqlCommit() end
end

asmlib.PrintInstance("Ver."..asmlib.GetOpVar("TOOL_VERSION"))
collectgarbage()
