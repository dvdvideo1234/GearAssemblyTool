------ LOCALIZNG FUNCTIONS ---
local tonumber                      = tonumber
local tostring                      = tostring
local Vector                        = Vector
local Angle                         = Angle
local IsValid                       = IsValid
local Time                          = CurTime
local sqlBegin                      = sql and sql.Begin
local sqlCommit                     = sql and sql.Commit
local bitBor                        = bit and bit.bor
local mathFloor                     = math and math.floor
local mathNormalizeAngle            = math and math.NormalizeAngle
local vguiCreate                    = vgui and vgui.Create
local guiOpenURL                    = gui and gui.OpenURL
local guiMouseX                     = gui and gui.MouseX
local guiMouseY                     = gui and gui.MouseY
local fileExists                    = file and file.Exists
local fileFind                      = file and file.Find
local fileRead                      = file and file.Read
local fileWrite                     = file and file.Write
local fileDelete                    = file and file.Delete
local fileTime                      = file and file.Time
local fileSize                      = file and file.Size
local fileOpen                      = file and file.Open
local inputIsKeyDown                = input and input.IsKeyDown
local inputIsMouseDown              = input and input.IsMouseDown
local inputGetCursorPos             = input and input.GetCursorPos
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
asmlib.SetOpVar("TOOL_VERSION","5.241")
asmlib.SetIndexes("V",1,2,3)
asmlib.SetIndexes("A",1,2,3)
asmlib.SetIndexes("S",4,5,6,7)
asmlib.SetOpVar("CONTAIN_STACK_MODE",asmlib.GetContainer("Stack Mode"))
asmlib.SetOpVar("CONTAIN_CONSTRAINT_TYPE",asmlib.GetContainer("Constraint Type"))

------------ CONFIGURE GLOBAL INIT OPVARS ------------

local gnRatio     = asmlib.GetOpVar("GOLDEN_RATIO")
local gvVecZero   = asmlib.GetOpVar("VEC_ZERO")
local gvVecUp     = asmlib.GetOpVar("VEC_UP")
local gtInitLogs  = asmlib.GetOpVar("LOG_INIT")
local gsLimitName = asmlib.GetOpVar("CVAR_LIMITNAME")
local gsToolNameL = asmlib.GetOpVar("TOOLNAME_NL")
local gsToolPrefL = asmlib.GetOpVar("TOOLNAME_PL")
local gsToolPrefU = asmlib.GetOpVar("TOOLNAME_PU")
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
local gsMoDB      = asmlib.GetOpVar("MODE_DATABASE")
local gaTimerSet  = asmlib.GetOpVar("OPSYM_DIRECTORY"):Explode(asmlib.GetAsmConvar("timermode","STR"))
local conElements = asmlib.GetContainer("LIST_VGUI")
local conPalette  = asmlib.GetContainer("COLORS_LIST")
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
        asmlib.LogInstance("DUPE_PHYS_SETTINGS: Failed to apply physical settings on "..tostring(oEnt)); return nil end
      asmlib.LogInstance("DUPE_PHYS_SETTINGS: Success"); return nil
    end)

  asmlib.SetAction("PLAYER_QUIT",
    function(oPly) -- Clear player cache when disconnects
      if(not asmlib.CacheClearPly(oPly)) then
        asmlib.LogInstance("PLAYER_QUIT: Failed swiping stuff "..tostring(oPly)); return nil end
      asmlib.LogInstance("PLAYER_QUIT: Success"); return nil
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

  -- http://www.famfamfam.com/lab/icons/silk/preview.php
  asmlib.ToIcon(gsToolPrefU.."PIECES"        , "database_connect")
  asmlib.ToIcon(gsToolPrefL.."context_menu"  , "database_gear"   )
  asmlib.ToIcon("subfolder_item"   , "folder"          )
  asmlib.ToIcon("pn_externdb_bt1"  , "database"        )
  asmlib.ToIcon("pn_externdb_bt2"  , "folder_database" )
  asmlib.ToIcon("pn_externdb_bt3"  , "database_table"  )
  asmlib.ToIcon("pn_externdb_bt4"  , "database_link"   )
  asmlib.ToIcon("pn_externdb_bt5"  , "time_go"         )
  asmlib.ToIcon("pn_externdb_bt6"  , "compress"        )
  asmlib.ToIcon("pn_externdb_bt7"  , "database_edit"   )
  asmlib.ToIcon("pn_externdb_bt8"  , "database_delete" )
  asmlib.ToIcon("pn_externdb_cm1"  , "database_key"    )
  asmlib.ToIcon("pn_externdb_cm2"  , "database_go"     )
  asmlib.ToIcon("pn_externdb_cm3"  , "database_connect")
  asmlib.ToIcon("pn_externdb_cm4"  , "database_edit"   )
  asmlib.ToIcon("pn_externdb_cm5"  , "database_add"    )
  asmlib.ToIcon("pn_externdb_cm6"  , "database_delete" )
  asmlib.ToIcon("pn_srchcol_lb1"   , "brick"           )
  asmlib.ToIcon("pn_srchcol_lb2"   , "package"         )
  asmlib.ToIcon("pn_srchcol_lb3"   , "tag_green"       )
  asmlib.ToIcon("pn_srchcol_lb4"   , "arrow_refresh"   )
  asmlib.ToIcon("model"            , "brick"           )
  asmlib.ToIcon("mass"             , "basket_put"      )
  asmlib.ToIcon("bgskids"          , "layers"          )
  asmlib.ToIcon("phyname"          , "wand"            )
  asmlib.ToIcon("ignphysgn"        , "lightning_go"    )
  asmlib.ToIcon("freeze"           , "lock"            )
  asmlib.ToIcon("gravity"          , "ruby_put"        )
  asmlib.ToIcon("weld"             , "wrench"          )
  asmlib.ToIcon("nocollide"        , "shape_group"     )
  asmlib.ToIcon("nocollidew"       , "world_go"        )
  asmlib.ToIcon("dsvlist_extdb"    , "database_go"     )
  asmlib.ToIcon("workmode_snap"    , "plugin"          ) -- General spawning and snapping mode
  asmlib.ToIcon("workmode_cross"   , "chart_line"      ) -- Ray cross intersect interpolation
  asmlib.ToIcon("workmode_curve"   , "vector"          ) -- Catmull-Rom curve line segment fitting
  asmlib.ToIcon("workmode_over"    , "shape_move_back" ) -- Trace normal ray location piece flip-spawn
  asmlib.ToIcon("workmode_turn"    , "arrow_turn_right") -- Produces smoother turns with Bezier curve
  asmlib.ToIcon("property_type"    , "package_green"     )
  asmlib.ToIcon("property_name"    , "note"              )
  asmlib.ToIcon("modedb_lua"       , "database_lightning")
  asmlib.ToIcon("modedb_sql"       , "database_link"     )
  asmlib.ToIcon("timermode_cqt"    , "time_go"           )
  asmlib.ToIcon("timermode_obj"    , "clock_go"          )
  asmlib.ToIcon("bnderrmod_off"    , "shape_square"      )
  asmlib.ToIcon("bnderrmod_log"    , "shape_square_edit" )
  asmlib.ToIcon("bnderrmod_hint"   , "shape_square_go"   )
  asmlib.ToIcon("bnderrmod_generic", "shape_square_link" )
  asmlib.ToIcon("bnderrmod_error"  , "shape_square_error")

  asmlib.SetAction("RESET_VARIABLES",
    function(oPly,oCom,oArgs)
      local devmode = asmlib.GetAsmConvar("devmode" ,"BUL")
      local bgskids = asmlib.GetAsmConvar("bgskids", "STR")
      asmlib.LogInstance("RESET_VARIABLES: {"..tostring(devmode)..asmlib.GetOpVar("OPSYM_DISABLE")..tostring(bgskids).."}")
      asmlib.SetAsmConvar(oPly,"nextx"    , 0)
      asmlib.SetAsmConvar(oPly,"nexty"    , 0)
      asmlib.SetAsmConvar(oPly,"nextz"    , 0)
      asmlib.SetAsmConvar(oPly,"nextpic"  , 0)
      asmlib.SetAsmConvar(oPly,"nextyaw"  , 0)
      asmlib.SetAsmConvar(oPly,"nextrol"  , 0)
      asmlib.SetAsmConvar(oPly,"rotpivt"  , 0)
      asmlib.SetAsmConvar(oPly,"rotpivh"  , 0)
      asmlib.SetAsmConvar(oPly,"deltarot" , 360)
      if(not devmode) then
        asmlib.LogInstance("RESET_VARIABLES: Developer mode disabled"); return nil end
      asmlib.SetLogControl(asmlib.GetAsmConvar("logsmax" , "INT"), asmlib.GetAsmConvar("logfile" , "BUL"))
      if(bgskids == "reset cvars") then -- Reset also the maximum spawned pieces
        oPly:ConCommand("sbox_max"..asmlib.GetOpVar("CVAR_LIMITNAME").." 1500\n")
        local anchor = asmlib.GetOpVar("MISS_NOID")..
                       asmlib.GetOpVar("OPSYM_REVSIGN")..
                       asmlib.GetOpVar("MISS_NOMD")
        asmlib.SetAsmConvar(oPly, "mass"     , "250")
        asmlib.SetAsmConvar(oPly, "model"    , "models/props_phx/gears/spur9.mdl")
        asmlib.SetAsmConvar(oPly, "nextx"    , "0")
        asmlib.SetAsmConvar(oPly, "nexty"    , "0")
        asmlib.SetAsmConvar(oPly, "nextz"    , "0")
        asmlib.SetAsmConvar(oPly, "count"    , "1")
        asmlib.SetAsmConvar(oPly, "anchor"   , anchor)
        asmlib.SetAsmConvar(oPly, "contyp"   , "1")
        asmlib.SetAsmConvar(oPly, "stmode"   , "1")
        asmlib.SetAsmConvar(oPly, "freeze"   , "0")
        asmlib.SetAsmConvar(oPly, "adviser"  , "1")
        asmlib.SetAsmConvar(oPly, "igntyp"   , "0")
        asmlib.SetAsmConvar(oPly, "angsnap"  , "0")
        asmlib.SetAsmConvar(oPly, "rotpivt"  , "0")
        asmlib.SetAsmConvar(oPly, "rotpivh"  , "0")
        asmlib.SetAsmConvar(oPly, "gravity"  , "1")
        asmlib.SetAsmConvar(oPly, "nextpic"  , "0")
        asmlib.SetAsmConvar(oPly, "nextyaw"  , "0")
        asmlib.SetAsmConvar(oPly, "nextrol"  , "0")
        asmlib.SetAsmConvar(oPly, "trorang"  , "0")
        asmlib.SetAsmConvar(oPly, "bgskids"  , "")
        asmlib.SetAsmConvar(oPly, "spnflat"  , "0")
        asmlib.SetAsmConvar(oPly, "exportdb" , "0")
        asmlib.SetAsmConvar(oPly, "friction" , "0")
        asmlib.SetAsmConvar(oPly, "forcelim" , "0")
        asmlib.SetAsmConvar(oPly, "torquelim", "0")
        asmlib.SetAsmConvar(oPly, "deltarot" , "360")
        asmlib.SetAsmConvar(oPly, "maxstatts", "3")
        asmlib.SetAsmConvar(oPly, "nocollide", "0")
        asmlib.SetAsmConvar(oPly, "nophysgun", "0")
        asmlib.SetAsmConvar(oPly, "ghosthold", "0")
        asmlib.SetAsmConvar(oPly, "modedb"   , "LUA")
        asmlib.SetAsmConvar(oPly, "timermode", "CQT@1800@1@1")
        asmlib.PrintInstance("RESET_VARIABLES: Variables reset complete")
      elseif(bgskids:sub(1,7) == "delete ") then
        local tPref = (" "):Explode(bgskids:sub(8,-1))
        for iCnt = 1, #tPref do local vPr = tPref[iCnt]
         asmlib.RemoveDSV("PIECES",vPr)
         asmlib.LogInstance("RESET_VARIABLES: Match <"..vPr..">")
        end
      else asmlib.LogInstance("RESET_VARIABLES: Command <"..bgskids.."> skipped"); return nil end
      asmlib.LogInstance("RESET_VARIABLES: Success"); return nil
    end)

  asmlib.SetAction("OPEN_EXTERNDB", -- Must have the same parameters as the hook
    function(oPly,oCom,oArgs)
      local sLog = "*OPEN_EXTERNDB"
      local scrW = surfaceScreenWidth()
      local scrH = surfaceScreenHeight()
      local sVer = asmlib.GetOpVar("TOOL_VERSION")
      local xyPos, nAut  = {x=scrW/4, y=scrH/4}, (gnRatio - 1)
      local xyDsz, xyTmp = {x=5, y=5}, {x=0, y=0}
      local xySiz = {x=nAut * scrW, y=nAut * scrH}
      local pnFrame = vguiCreate("DFrame"); if(not IsValid(pnFrame)) then
        asmlib.LogInstance("Frame invalid",sLog); return nil end
      pnFrame:SetPos(xyPos.x, xyPos.y)
      pnFrame:SetSize(xySiz.x, xySiz.y)
      pnFrame:SetTitle(languageGetPhrase("tool."..gsToolNameL..".pn_externdb_hd").." "..oPly:Nick().." {"..sVer.."}")
      pnFrame:SetDraggable(true)
      pnFrame:SetDeleteOnClose(false)
      pnFrame.OnClose = function(pnSelf)
        local iK = conElements:Find(pnSelf) -- Find panel key index
        if(IsValid(pnSelf)) then pnSelf:Remove() end -- Delete the valid panel
        if(asmlib.IsHere(iK)) then conElements:Pull(iK) end -- Pull the key out
      end
      local pnSheet = vguiCreate("DPropertySheet")
      if(not IsValid(pnSheet)) then pnFrame:Close()
        asmlib.LogInstance("Sheet invalid",sLog); return nil end
      pnSheet:SetParent(pnFrame)
      pnSheet:Dock(FILL)
      local sOff = asmlib.GetOpVar("OPSYM_DISABLE")
      local sMis = asmlib.GetOpVar("MISS_NOAV")
      local sLib = asmlib.GetOpVar("NAME_LIBRARY")
      local sBas = asmlib.GetOpVar("DIRPATH_BAS")
      local sSet = asmlib.GetOpVar("DIRPATH_SET")
      local sPrU = asmlib.GetOpVar("TOOLNAME_PU")
      local sRev = asmlib.GetOpVar("OPSYM_REVISION")
      local sDsv = sBas..asmlib.GetOpVar("DIRPATH_DSV")
      local fDSV = sDsv..("%s"..sPrU.."%s.txt")
      local sNam = (sBas..sSet..sLib.."_dsv.txt")
      local pnDSV = vguiCreate("DPanel")
      if(not IsValid(pnDSV)) then pnFrame:Close()
        asmlib.LogInstance("DSV list invalid",sLog); return nil end
      pnDSV:SetParent(pnSheet)
      pnDSV:DockMargin(xyDsz.x, xyDsz.y, xyDsz.x, xyDsz.y)
      pnDSV:DockPadding(xyDsz.x, xyDsz.y, xyDsz.x, xyDsz.y)
      pnDSV:Dock(FILL)
      local tInfo = pnSheet:AddSheet("DSV", pnDSV, asmlib.ToIcon("dsvlist_extdb"))
      tInfo.Tab:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_externdb").." DSV")
      local sDel, nB, nW, nH = "\t", 22, pnFrame:GetSize()
      xyPos.x, xyPos.y = xyDsz.x, xyDsz.y
      xySiz.x = (nW - 6 * xyDsz.x)
      xySiz.y = ((nH - 6 * xyDsz.y) - 52)
      local wAct = mathFloor(((gnRatio - 1) / 10) * xySiz.x)
      local wUse, wSrc = mathFloor(xySiz.x - wAct), (xySiz.x * nAut)
      local pnListView = vguiCreate("DListView")
      if(not IsValid(pnListView)) then pnFrame:Close()
        asmlib.LogInstance("List view invalid",sLog); return nil end
      xySiz.y = xySiz.y - 3*xyDsz.y - 2*nB
      pnListView:SetParent(pnDSV)
      pnListView:SetVisible(true)
      pnListView:SetSortable(false)
      pnListView:SetMultiSelect(false)
      pnListView:SetPos(xyPos.x, xyPos.y)
      pnListView:SetSize(xySiz.x, xySiz.y)
      pnListView:SetName(languageGetPhrase("tool."..gsToolNameL..".pn_ext_dsv_lb"))
      pnListView:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_ext_dsv_hd"))
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_ext_dsv_1")):SetFixedWidth(wAct)
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_ext_dsv_2")):SetFixedWidth(wUse - wSrc)
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_ext_dsv_3")):SetFixedWidth(wSrc)
      -- Rext entry to inport/export to list view
      xyPos.y = xyPos.y + xySiz.y + xyDsz.y
      xySiz.y = nB -- Genral Y-size of elements
      local tpText = {Size = #pnListView.Columns}
      for iC = 1, tpText.Size do
        local pC = pnListView.Columns[iC]
        local cW = math.min(pC:GetMinWidth(), pC:GetMaxWidth())
        if(iC == 1 or iC == tpText.Size) then
          xySiz.x = cW - (xyDsz.x / 2)
        else xySiz.x = cW - xyDsz.x end; pC:SetWide(cW)
        local pnText = vguiCreate("DTextEntry")
        if(not IsValid(pnText)) then pnFrame:Close()
          asmlib.LogInstance("Text entry active invalid", sLog); return nil end
        pnText:SetParent(pnDSV)
        pnText:SetEditable(true)
        pnText:SetPos(xyPos.x, xyPos.y)
        pnText:SetSize(xySiz.x, xySiz.y)
        pnText:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_externdb_ttt").." "
                        ..languageGetPhrase("tool."..gsToolNameL..".pn_ext_dsv_"..iC))
        xyPos.x = xyPos.x + xySiz.x + xyDsz.x; tpText[iC] = pnText
        pnText.OnEnter = function(pnSelf)
          local nID, pnRow = pnListView:GetSelectedLine()
          local tDat, sMis = {}, asmlib.GetOpVar("MISS_NOAV")
          for iV = 1, tpText.Size do tDat[iV] = tpText[iV]:GetValue() end
          -- Active line. Contains X/V
          tDat[1] = tostring(tDat[1] or "X")
          tDat[1] = (tDat[1]:Trim():upper():sub(1,1))
          tDat[1] = ((tDat[1] == "V") and "V" or "X")
          -- Database unique prefix. Contains non-spaces
          tDat[2] = tostring(tDat[2] or "")
          tDat[2] = tDat[2]:Trim():gsub("[^%w]","_")
          -- Additional information. It can be anything
          tDat[3] = tostring(tDat[3] or ""):Trim()
          tDat[3] = (asmlib.IsBlank(tDat[3]) and sMis or tDat[3])
          if(not asmlib.IsBlank(tDat[1]) and not asmlib.IsBlank(tDat[2])) then
          if(nID and nID > 0 and pnRow and not tpText[1].m_NewDSV) then local iU = 1
            while(pnRow.Columns[iU]) do pnRow:SetColumnText(iU, tDat[iU]); iU = iU + 1 end
          else pnListView:AddLine(tDat[1], tDat[2], tDat[3]):SetTooltip(tDat[3])
          end; end; for iV = 1, tpText.Size do tpText[iV]:SetValue(""); tpText[iV]:SetText("") end
        end
      end
      -- Import button. when clicked loads file into the panel
      local pnImport = vguiCreate("DButton")
      if(not IsValid(pnImport)) then pnFrame:Close()
        asmlib.LogInstance("Import button invalid", sLog); return nil end
      xyPos.x = pnListView:GetPos()
      xyPos.y = xyPos.y + xySiz.y + xyDsz.y
      xySiz.x = ((pnListView:GetWide() - xyDsz.x) / 2)
      pnImport:SetPos(xyPos.x, xyPos.y)
      pnImport:SetSize(xySiz.x, xySiz.y)
      pnImport:SetParent(pnDSV)
      pnImport:SetFont("Trebuchet24")
      pnImport:SetText(languageGetPhrase("tool."..gsToolNameL..".pn_externdb_bti"))
      pnImport:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_externdb_bti_tp"))
      pnImport.DoRightClick = function() end
      pnImport.DoClick = function(pnSelf)
        if(not fileExists(sNam, "DATA")) then fileWrite(sNam, "") end
        local oDSV = fileOpen(sNam, "rb", "DATA"); if(not oDSV) then pnFrame:Close()
          asmlib.LogInstance("DSV list missing",sLog); return nil end; pnListView:Clear()
        local sLine, bEOF, bAct = "", false, true
        while(not bEOF) do
          sLine, bEOF = asmlib.GetStringFile(oDSV)
          if(not asmlib.IsBlank(sLine)) then local sKey, sPrg
            if(sLine:sub(1,1) ~= sOff) then bAct = true else
              bAct, sLine = false, sLine:sub(2,-1):Trim() end
            local nS, nE = sLine:find("%s+")
            if(nS and nE) then
              sKey = sLine:sub(1, nS-1)
              sPrg = sLine:sub(nE+1,-1)
            else sKey, sPrg = sLine, sMis end
            pnListView:AddLine((bAct and "V" or "X"), sKey, sPrg):SetTooltip(sPrg)
          end
        end; oDSV:Close()
      end; pnImport:DoClick()
      -- Expot button. When clicked loads contents into the file
      local pnExport = vguiCreate("DButton")
      if(not IsValid(pnExport)) then pnFrame:Close()
        asmlib.LogInstance("Export button invalid", sLog); return nil end
      xyPos.x = xyPos.x + xySiz.x + xyDsz.x
      pnExport:SetPos(xyPos.x, xyPos.y)
      pnExport:SetSize(xySiz.x, xySiz.y)
      pnExport:SetParent(pnDSV)
      pnExport:SetFont("Trebuchet24")
      pnExport:SetText(languageGetPhrase("tool."..gsToolNameL..".pn_externdb_bte"))
      pnExport:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_externdb_bte_tp"))
      pnExport.DoRightClick = function() end
      pnExport.DoClick = function(pnSelf)
        local oDSV = fileOpen(sNam, "wb", "DATA")
        if(not oDSV) then pnFrame:Close()
          asmlib.LogInstance("DSV list missing",sLog..".ListView"); return nil end
        local tLine = pnListView:GetLines()
        for iK, pnCur in pairs(tLine) do
          local sAct = ((pnCur:GetColumnText(1) == "V") and "" or sOff)
          local sPrf = pnCur:GetColumnText(2)
          local sPth = pnCur:GetColumnText(3)
          if(not asmlib.IsBlank(sPth)) then sPth = sDel..sPth end
          oDSV:Write(sAct..sPrf..sPth.."\n")
        end; oDSV:Flush(); oDSV:Close()
      end
      local function convRow(pnRow)
        local sSep = asmlib.GetOpVar("OPSYM_VERTDIV")
        local sAct = pnRow:GetColumnText(1) -- Active
        local sPrf = pnRow:GetColumnText(2) -- PK
        local sPth = pnRow:GetColumnText(3) -- Path
        if(not asmlib.IsBlank(sPth)) then sPth = sSep..sPth end
        return (sAct..sSep..sPrf..sPth) -- Divided
      end
      local function excgRow(pnRow)
        for iV = 1, tpText.Size do
          local ptx = tpText[iV] -- Pick a panel
          local str = pnRow:GetColumnText(iV)
          ptx:SetValue(str); ptx:SetText(str)
        end -- Exchange data with list view and text
      end
      pnListView.OnRowRightClick = function(pnSelf, nIndex, pnLine)
        if(inputIsMouseDown(MOUSE_RIGHT)) then
          local pnMenu = vguiCreate("DMenu")
          if(not IsValid(pnMenu)) then pnFrame:Close()
            asmlib.LogInstance("Menu invalid",sLog..".ListView"); return nil end
          local mX, mY = inputGetCursorPos()
          local iO, tOptions = 1, {
            function()
              local cC, cX, cY = 0, pnSelf:ScreenToLocal(mX, mY)
              while(cX > 0) do cC = (cC + 1); cX = (cX - pnSelf:ColumnWidth(cC))
              end; local nID, pnRow = pnSelf:GetSelectedLine()
              if(nID and nID > 0 and pnRow) then SetClipboardText(pnRow:GetColumnText(cC)) end
            end,
            function() SetClipboardText(convRow(pnLine)) end,
            function() pnLine:SetColumnText(1, ((pnLine:GetColumnText(1) == "V") and "X" or "V")) end,
            function() excgRow(pnLine); tpText[1].m_NewDSV = false end,
            function() excgRow(pnLine); tpText[1].m_NewDSV = true  end,
            function() pnSelf:RemoveLine(nIndex) end
          }
          while(tOptions[iO]) do local sO = tostring(iO)
            local sDescr = languageGetPhrase("tool."..gsToolNameL..".pn_externdb_cm"..sO)
            pnMenu:AddOption(sDescr, tOptions[iO]):SetIcon(asmlib.ToIcon("pn_externdb_cm"..sO))
            iO = iO + 1 -- Loop trough the functions list and add to the menu
          end; pnMenu:Open()
        end -- Process only the right mouse button
      end -- Populate the tables for every database
      local pnTable = vguiCreate("DPanel")
      if(not IsValid(pnTable)) then pnFrame:Close()
        asmlib.LogInstance("Category invalid",sLog); return nil end
      local defTab = asmlib.GetOpVar("DEFTABLE_PIECES")
      pnTable:SetParent(pnSheet)
      pnTable:DockMargin(xyDsz.x, xyDsz.y, xyDsz.x, xyDsz.y)
      pnTable:DockPadding(xyDsz.x, xyDsz.y, xyDsz.x, xyDsz.y)
      pnTable:Dock(FILL)
      local tInfo = pnSheet:AddSheet(defTab.Nick, pnTable, asmlib.ToIcon(defTab.Name))
      tInfo.Tab:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_externdb").." "..defTab.Nick)
      local tFile = fileFind(fDSV:format("*", defTab.Nick), "DATA")
      if(asmlib.IsTable(tFile) and tFile[1]) then
        local nF, nW, nH = #tFile, pnFrame:GetSize()
        xySiz.x, xyPos.x, xyPos.y = (nW - 6 * xyDsz.x), xyDsz.x, xyDsz.y
        xySiz.y = (((nH - 6 * xyDsz.y) - ((nF -1) * xyDsz.y) - 52) / nF)
        for iP = 1, nF do local sCur = tFile[iP]
          local pnManage = vguiCreate("DButton")
          if(not IsValid(pnSheet)) then pnFrame:Close()
              asmlib.LogInstance("Button invalid ["..tostring(iP).."]",sLog); return nil end
          local nS, nE = sCur:upper():find(sPrU..defTab.Nick);
          if(nS and nE) then
            local sPref = sCur:sub(1, nS - 1)
            local sFile = fDSV:format(sPref, defTab.Nick)
            pnManage:SetParent(pnTable)
            pnManage:SetPos(xyPos.x, xyPos.y)
            pnManage:SetSize(xySiz.x, xySiz.y)
            pnManage:SetFont("Trebuchet24")
            pnManage:SetText(sPref)
            pnManage:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_externdb_lb").." "..sFile)
            pnManage.DoRightClick = function(pnSelf)
              local pnMenu = vguiCreate("DMenu")
              if(not IsValid(pnMenu)) then pnFrame:Close()
                  asmlib.LogInstance("Menu invalid",sLog..".Button"); return nil end
              local iO, tOptions = 1, {
                function() SetClipboardText(pnSelf:GetText()) end,
                function() SetClipboardText(sDsv) end,
                function() SetClipboardText(defTab.Nick) end,
                function() SetClipboardText(sFile) end,
                function() SetClipboardText(asmlib.GetDateTime(fileTime(sFile, "DATA"))) end,
                function() SetClipboardText(tostring(fileSize(sFile, "DATA")).."B") end,
                function()
                  if(luapad) then
                      asmlib.LogInstance("Edit "..asmlib.GetReport1(sFile), sLog..".Button")
                    if(luapad.Frame) then luapad.Frame:SetVisible(true)
                    else asmlib.SetAsmConvar(oPly, "*luapad", gsToolNameL) end
                    luapad.AddTab("["..defTab.Nick.."]"..pnSelf:GetText(), fileRead(sFile, "DATA"), sDsv);
                    if(defTab.Nick == "PIECES") then local sCat = fDSV:format(sPref, "CATEGORY")
                      if(fileExists(sCat,"DATA")) then
                        luapad.AddTab("[CATEGORY]"..pnSelf:GetText(), fileRead(sCat, "DATA"), sDsv);
                      end
                    end
                    luapad.Frame:SetVisible(true); luapad.Frame:Center()
                    luapad.Frame:MakePopup(); conElements:Push({luapad.Frame})
                  end
                end,
                function() fileDelete(sFile)
                    asmlib.LogInstance("Delete "..asmlib.GetReport1(sFile), sLog..".Button")
                  if(defTab.Nick == "PIECES") then local sCat = fDSV:format(sPref,"CATEGORY")
                    if(fileExists(sCat,"DATA")) then fileDelete(sCat)
                        asmlib.LogInstance("Deleted "..asmlib.GetReport1(sCat), sLog..".Button") end
                  end; pnManage:Remove()
                end
              }
              while(tOptions[iO]) do local sO = tostring(iO)
                local sDescr = languageGetPhrase("tool."..gsToolNameL..".pn_externdb_bt"..sO)
                pnMenu:AddOption(sDescr, tOptions[iO]):SetIcon(asmlib.ToIcon("pn_externdb_bt"..sO))
                iO = iO + 1 -- Loop trough the functions list and add to the menu
              end; pnMenu:Open()
            end
            else asmlib.LogInstance("File missing ["..tostring(iP).."]",sLog..".Button") end
          xyPos.y = xyPos.y + xySiz.y + xyDsz.y
        end
      else
        asmlib.LogInstance("Missing <"..defTab.Nick..">",sLog)
      end; pnFrame:SetVisible(true); pnFrame:Center(); pnFrame:MakePopup()
      conElements:Push(pnFrame); asmlib.LogInstance("Success",sLog); return nil
    end) -- Read client configuration

  asmlib.SetAction("OPEN_FRAME",
    function(oPly,oCom,oArgs) local sLog = "*OPEN_FRAME"
      local frUsed, nCount = asmlib.GetFrequentModels(oArgs[1]); if(not asmlib.IsHere(frUsed)) then
        asmlib.LogInstance("Retrieving most frequent models failed ["..tostring(oArgs[1]).."]",sLog); return nil end
      local defTab = asmlib.GetOpVar("DEFTABLE_PIECES"); if(not defTab) then
        asmlib.LogInstance("Missing definition for table PIECES",sLog); return nil end
      local pnFrame = vguiCreate("DFrame"); if(not IsValid(pnFrame)) then
        asmlib.LogInstance("Frame invalid",sLog); return nil end
      ------------ Screen resolution and configuration ------------
      local scrW     = surfaceScreenWidth()
      local scrH     = surfaceScreenHeight()
      local sVersion = asmlib.GetOpVar("TOOL_VERSION")
      local xyZero   = {x =  0, y = 20} -- The start location of left-top
      local xyDelta  = {x = 10, y = 10} -- Distance between panels
      local xySiz    = {x =  0, y =  0} -- Current panel size
      local xyPos    = {x =  0, y =  0} -- Current panel position
      local xyTmp    = {x =  0, y =  0} -- Temporary coordinate
      ------------ Frame ------------
      xySiz.x = (scrW / gnRatio) -- This defines the size of the frame
      xyPos.x, xyPos.y = (scrW / 4), (scrH / 4)
      xySiz.y = mathFloor(xySiz.x / (1 + gnRatio))
      pnFrame:SetTitle(languageGetPhrase("tool."..gsToolNameL..".pn_routine_hd").." "..oPly:Nick().." {"..sVersion.."}")
      pnFrame:SetVisible(true)
      pnFrame:SetDraggable(true)
      pnFrame:SetDeleteOnClose(false)
      pnFrame:SetPos(xyPos.x, xyPos.y)
      pnFrame:SetSize(xySiz.x, xySiz.y)
      pnFrame.OnClose = function(pnSelf)
        local iK = conElements:Find(pnSelf) -- Find panel key index
        if(IsValid(pnSelf)) then pnSelf:Remove() end -- Delete the valid panel
        if(asmlib.IsHere(iK)) then conElements:Pull(iK) end -- Pull the key out
      end
      ------------ Button ------------
      xyTmp.x, xyTmp.y = pnFrame:GetSize()
      xySiz.x = (xyTmp.x / (8.5 * gnRatio)) -- Display properly the name
      xySiz.y = (xySiz.x / (1.5 * gnRatio)) -- Used by combo-box and text-box
      xyPos.x = xyZero.x + xyDelta.x
      xyPos.y = xyZero.y + xyDelta.y
      local pnButton = vguiCreate("DButton")
      if(not IsValid(pnButton)) then pnFrame:Close()
        asmlib.LogInstance("Button invalid",sLog); return nil end
      pnButton:SetParent(pnFrame)
      pnButton:SetPos(xyPos.x, xyPos.y)
      pnButton:SetSize(xySiz.x, xySiz.y)
      pnButton:SetVisible(true)
      pnButton:SetName(languageGetPhrase("tool."..gsToolNameL..".pn_export_lb"))
      pnButton:SetText(languageGetPhrase("tool."..gsToolNameL..".pn_export_lb"))
      pnButton:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_export"))
      ------------ ComboBox ------------
      xyPos.x, xyPos.y = pnButton:GetPos()
      xyTmp.x, xyTmp.y = pnButton:GetSize()
      xyPos.x = xyPos.x + xyTmp.x + xyDelta.x
      xySiz.x, xySiz.y = (gnRatio * xyTmp.x), xyTmp.y
      local pnComboBox = vguiCreate("DComboBox")
      if(not IsValid(pnComboBox)) then pnFrame:Close()
        asmlib.LogInstance("Combo invalid",sLog); return nil end
      pnComboBox:SetParent(pnFrame)
      pnComboBox:SetPos(xyPos.x,xyPos.y)
      pnComboBox:SetSize(xySiz.x,xySiz.y)
      pnComboBox:SetVisible(true)
      pnComboBox:SetSortItems(false)
      pnComboBox:SetName(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb"))
      pnComboBox:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol"))
      pnComboBox:SetValue(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb"))
      pnComboBox:AddChoice(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb1"),defTab[1][1], false, asmlib.ToIcon("pn_srchcol_lb1"))
      pnComboBox:AddChoice(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb2"),defTab[2][1], false, asmlib.ToIcon("pn_srchcol_lb2"))
      pnComboBox:AddChoice(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb3"),defTab[3][1], false, asmlib.ToIcon("pn_srchcol_lb3"))
      pnComboBox:AddChoice(languageGetPhrase("tool."..gsToolNameL..".pn_srchcol_lb4"),defTab[4][1], false, asmlib.ToIcon("pn_srchcol_lb4"))
      pnComboBox.OnSelect = function(pnSelf, nInd, sVal, anyData)
        asmlib.LogInstance("Selected "..asmlib.GetReport3(nInd,sVal,anyData),sLog..".ComboBox")
        pnSelf:SetValue(sVal)
      end
      ------------ ModelPanel ------------
      xyTmp.x, xyTmp.y = pnFrame:GetSize()
      xyPos.x, xyPos.y = pnComboBox:GetPos()
      xySiz.x = (xyTmp.x / (1.9 * gnRatio)) -- Display the model properly
      xyPos.x = xyTmp.x - xySiz.x - xyDelta.x
      xySiz.y = xyTmp.y - xyPos.y - xyDelta.y
      ------------------------------------------------
      local pnModelPanel = vguiCreate("DModelPanel")
      if(not IsValid(pnModelPanel)) then pnFrame:Close()
        asmlib.LogInstance("Model display invalid",sLog); return nil end
      pnModelPanel:SetParent(pnFrame)
      pnModelPanel:SetPos(xyPos.x,xyPos.y)
      pnModelPanel:SetSize(xySiz.x,xySiz.y)
      pnModelPanel:SetVisible(true)
      pnModelPanel:SetMouseInputEnabled(true)
      pnModelPanel:SetName(languageGetPhrase("tool."..gsToolNameL..".pn_display_lb"))
      pnModelPanel:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_display"))
      pnModelPanel.LayoutEntity = function(pnSelf, oEnt)
        if(pnSelf.bAnimated) then pnSelf:RunAnimation() end
        local uiBox = asmlib.CacheBoxLayout(oEnt); if(not asmlib.IsHere(uiBox)) then
          asmlib.LogInstance("Box invalid",sLog..".ModelPanel"); return nil end
        if(inputIsMouseDown(MOUSE_RIGHT) and pnSelf:IsHovered()) then
          if(pnSelf.pcX and pnSelf.pcY) then
            local nX, nY = guiMouseX(), guiMouseY()
            local aP, aY, aR = uiBox.Ang:Unpack()
            aP = mathNormalizeAngle(nY - pnSelf.pcY)
            aR = mathNormalizeAngle(pnSelf.pcX - nX)
            uiBox.Ang:SetUnpacked(aP, aY, aR)
          else pnSelf.pcX, pnSelf.pcY = guiMouseX(), guiMouseY() end
        else pnSelf.pcX, pnSelf.pcY = nil, nil end
        local stSpawn = asmlib.GetNormalSpawn(oPly, gvVecZero, uiBox.Ang, oEnt:GetModel())
        if(not stSpawn) then asmlib.LogInstance("Spawn data fail",sLog..".LayoutEntity"); return nil end
        stSpawn.SAng:RotateAroundAxis(stSpawn.SAng:Up(), mathNormalizeAngle(40 * Time()))
        asmlib.ApplySpawnFlat(oEnt, stSpawn, gvVecUp)
        stSpawn.SPos:Set(uiBox.Cen); stSpawn.SPos:Rotate(stSpawn.SAng)
        stSpawn.SPos:Mul(-1); stSpawn.SPos:Add(uiBox.Cen)
        oEnt:SetAngles(stSpawn.SAng); oEnt:SetPos(stSpawn.SPos)
      end
      ------------ TextEntry ------------
      xyPos.x, xyPos.y = pnComboBox:GetPos()
      xyTmp.x, xyTmp.y = pnComboBox:GetSize()
      xyPos.x = xyPos.x + xyTmp.x + xyDelta.x
      xySiz.y = xyTmp.y
      ------------------------------------------------
      xyTmp.x, xyTmp.y = pnModelPanel:GetPos()
      xySiz.x = xyTmp.x - xyPos.x - xyDelta.x
      ------------------------------------------------
      local pnTextEntry = vguiCreate("DTextEntry")
      if(not IsValid(pnTextEntry)) then pnFrame:Close()
        asmlib.LogInstance("Textbox invalid",sLog); return nil end
      pnTextEntry:SetParent(pnFrame)
      pnTextEntry:SetPos(xyPos.x,xyPos.y)
      pnTextEntry:SetSize(xySiz.x,xySiz.y)
      pnTextEntry:SetVisible(true)
      pnTextEntry:SetName(languageGetPhrase("tool."..gsToolNameL..".pn_pattern_lb"))
      pnTextEntry:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_pattern"))
      ------------ ListView ------------
      xyPos.x, xyPos.y = pnButton:GetPos()
      xyTmp.x, xyTmp.y = pnButton:GetSize()
      xyPos.y = xyPos.y + xyTmp.y + xyDelta.y
      ------------------------------------------------
      xyTmp.x, xyTmp.y = pnTextEntry:GetPos()
      xySiz.x, xySiz.y = pnTextEntry:GetSize()
      xySiz.x = xyTmp.x + xySiz.x - xyDelta.x
      ------------------------------------------------
      xyTmp.x, xyTmp.y = pnFrame:GetSize()
      xySiz.y = xyTmp.y - xyPos.y - xyDelta.y
      ------------------------------------------------
      local wUse = mathFloor(0.120377559 * xySiz.x)
      local wRak = mathFloor(0.065393857 * xySiz.x)
      local wTyp = mathFloor(0.314127559 * xySiz.x)
      local wNam = xySiz.x - wUse - wRak - wTyp
      local pnListView = vguiCreate("DListView")
      if(not IsValid(pnListView)) then pnFrame:Close()
        asmlib.LogInstance("List view invalid",sLog); return nil end
      pnListView:SetParent(pnFrame)
      pnListView:SetVisible(false)
      pnListView:SetSortable(true)
      pnListView:SetMultiSelect(false)
      pnListView:SetPos(xyPos.x,xyPos.y)
      pnListView:SetSize(xySiz.x,xySiz.y)
      pnListView:SetName(languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb"))
      pnListView:SetTooltip(languageGetPhrase("tool."..gsToolNameL..".pn_routine"))
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb1")):SetFixedWidth(wUse) -- (1)
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb2")):SetFixedWidth(wRak) -- (2)
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb3")):SetFixedWidth(wTyp) -- (3)
      pnListView:AddColumn(languageGetPhrase("tool."..gsToolNameL..".pn_routine_lb4")):SetFixedWidth(wNam) -- (4)
      pnListView:AddColumn(""):SetFixedWidth(0) -- (5) This is actually the hidden model of the piece used.
      pnListView.OnRowSelected = function(pnSelf, nIndex, pnLine)
        local uiMod = tostring(pnLine:GetColumnText(5)  or asmlib.GetOpVar("MISS_NOMD")); pnModelPanel:SetModel(uiMod)
        local uiEnt = pnModelPanel:GetEntity(); if(not (uiEnt and uiEnt:IsValid())) then -- Makes sure the entity is validated first
          asmlib.LogInstance("Model entity invalid "..asmlib.GetReport(uiMod), sLog..".ListView"); return nil end
        uiEnt:SetModel(uiMod); uiEnt:SetModelName(uiMod) -- Apply the model on the model panel even for changed compiled model paths
        local uiBox = asmlib.CacheBoxLayout(uiEnt,gnRatio,gnRatio-1); if(not asmlib.IsHere(uiBox)) then
          asmlib.LogInstance("Box invalid for <"..uiMod..">",sLog..".ListView"); return nil end
        pnModelPanel:SetLookAt(uiBox.Eye); pnModelPanel:SetCamPos(uiBox.Cam)
        asmlib.SetAsmConvar(oPly, "model" ,uiMod); SetClipboardText(uiMod)
      end -- Copy the line model to the clipboard so it can be pasted with Ctrl+V
      pnListView.OnRowRightClick = function(pnSelf, nIndex, pnLine)
        local cC, cX, cY = 0, inputGetCursorPos(); cX, cY = pnSelf:ScreenToLocal(cX, cY)
        while(cX > 0) do cC = (cC + 1); cX = (cX - pnSelf:ColumnWidth(cC)) end
        SetClipboardText(pnLine:GetColumnText(cC))
      end
      if(not asmlib.UpdateListView(pnListView,frUsed,nCount)) then
        asmlib.LogInstance("Populate the list view failed",sLog); return nil end
      -- The button dababase export by type uses the current active type in the ListView line
      pnButton.DoClick = function(pnSelf)
        asmlib.LogInstance("Click "..asmlib.GetReport(pnSelf:GetText()), sLog..".Button")
        if(asmlib.GetAsmConvar("exportdb", "BUL")) then
          asmlib.ExportCategory(3)
          asmlib.ExportDSV("PIECES")
          asmlib.SetAsmConvar(oPly, "exportdb", 0)
          asmlib.LogInstance("Export instance", sLog..".Button")
        else
          if(inputIsKeyDown(KEY_LSHIFT)) then
            local fW = asmlib.GetOpVar("FORM_GITWIKI")
            guiOpenURL(fW:format("Additional-features"))
          end
        end
      end
      -- Leave the TextEntry here so it can access and update the local ListView reference
      pnTextEntry.OnEnter = function(pnSelf)
        local sPat = tostring(pnSelf:GetValue() or "")
        local sAbr, sCol = pnComboBox:GetSelected() -- Returns two values
              sAbr, sCol = tostring(sAbr or ""), tostring(sCol or "")
        if(not asmlib.UpdateListView(pnListView,frUsed,nCount,sCol,sPat)) then
          asmlib.LogInstance("Update ListView fail"..asmlib.GetReport3(sAbr,sCol,sPat,sLog..".TextEntry")); return nil
        end
      end
      pnFrame:SetVisible(true); pnFrame:Center(); pnFrame:MakePopup()
      conElements:Push(pnFrame); asmlib.LogInstance("Success",sLog); return nil
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
