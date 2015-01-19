-- INITIALIZE DB
gearasmlib.SQLCreateTable("PIECES",{{1},{2},{3},{1,4},{1,2},{2,4},{1,2,3}},true,true)

if(file.Exists(gearasmlib.BASPath()..gearasmlib.DSVPath().."db_"..gearasmlib.GetTablePrefix().."PIECES.txt", "DATA")) then
  gearasmlib.PrintInstance("GEARASSEMBLY: DB PIECES exported, populating from DSV.")
  gearasmlib.SQLImportFromDSV("db_","PIECES","\t",true)
else
  gearasmlib.PrintInstance("GEARASSEMBLY: DB PIECES not exported, populating from TOOL.")
  
  ------- DEV -------
  gearasmlib.SQLInsertRecord("PIECES",{"models/props_wasteland/wheel02b.mdl",   "Development", "#", 45, "65, 0, 0", "0, 0, -90", "0.29567885398865,0.3865530192852,-0.36239844560623"})

  ------ PIECES ------
  --- Gmod 10
  gearasmlib.SQLInsertRecord("PIECES",{"models/props_phx/mechanics/medgear.mdl", "Old Gmod 10", "#", 0, "24.173, 0, 0", "", "-0.015172731131315, 0.0090782083570957, 3.5684652328491"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/props_phx/mechanics/biggear.mdl", "Old Gmod 10", "#", 0, "33.811, 0, 0", "", "-0.00017268359079026, -0.0035230871289968, 3.5217847824097"})
  --- PHX Spur
  gearasmlib.SQLInsertRecord("PIECES",{"models/props_phx/gears/spur9.mdl" , "PHX Spotted Flat", "#", 0, " 7.467, 0, 0", "", "-0.0015837327810004, 0.00016171450261027, 2.8354094028473"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/props_phx/gears/spur12.mdl", "PHX Spotted Flat", "#", 0, " 9.703, 0, 0", "", "-0.0015269597060978, 0.00021413757349364, 2.8405227661133"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/props_phx/gears/spur24.mdl", "PHX Spotted Flat", "#", 0, "18.381, 0, 0", "", "-0.0011573693482205, 0.00018228564294986, 2.8103637695313"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/props_phx/gears/spur36.mdl", "PHX Spotted Flat", "#", 0, "27.119, 0, 0", "", "-0.0012206265237182, -8.6402214947157e-005, 2.7949125766754"})
  --- PHX Regular Small
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear12x6_small.mdl" , "PHX Regular Small", "#", 0, " 6.708, 0, 0", "", "2.5334677047795e-005, 0.007706293836236, 1.5820281505585"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear16x6_small.mdl" , "PHX Regular Small", "#", 0, " 9.600, 0, 0", "", "5.0195762923977e-007, -3.5567546774473e-007, 1.5833348035812"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear24x6_small.mdl" , "PHX Regular Small", "#", 0, "13.567, 0, 0", "", "0.00074489979306236, -0.00014938598906156, 1.5826840400696"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear12x12_small.mdl", "PHX Regular Small", "#", 0, " 6.708, 0, 0", "", "4.298805720282e-007, 2.1906590319531e-008, 3.0833337306976"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear16x12_small.mdl", "PHX Regular Small", "#", 0, " 9.600, 0, 0", "", "4.3190007659177e-007, -2.4458054781462e-007, 3.0833337306976"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear24x12_small.mdl", "PHX Regular Small", "#", 0, "13.567, 0, 0", "", "-0.0017898256191984, -0.0026770732365549, 2.998779296875"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear12x24_small.mdl", "PHX Regular Small", "#", 0, " 6.708, 0, 0", "", "0.0069478303194046, 0.0029040845111012, 6.0784306526184"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear16x24_small.mdl", "PHX Regular Small", "#", 0, " 9.600, 0, 0", "", "-0.00045375636545941, 0.0069514401257038, 6.061897277832"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear24x24_small.mdl", "PHX Regular Small", "#", 0, "13.567, 0, 0", "", "-0.013954215683043, 0.00091068528126925, 6.0729651451111"})
  --- PHX Regular Medium
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear12x6.mdl" , "PHX Regular Medium", "#", 0, "13.20, 0, 0", "", "3.818327627414e-007, 2.8411110974957e-007, 3.1666665077209"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear16x6.mdl" , "PHX Regular Medium", "#", 0, "19.10, 0, 0", "", "1.2454452189559e-006, -5.1244381893412e-007, 3.1666696071625"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear24x6.mdl" , "PHX Regular Medium", "#", 0, "26.96, 0, 0", "", "0.001489854301326, -0.00029889517463744, 3.1653680801392"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear12x12.mdl", "PHX Regular Medium", "#", 0, "13.20, 0, 0", "", "1.2779588587364e-006, 2.8910221772094e-007, 6.1666665077209"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear16x12.mdl", "PHX Regular Medium", "#", 0, "19.10, 0, 0", "", "1.308152150159e-006, -7.5695822943089e-007, 6.1666674613953"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear24x12.mdl", "PHX Regular Medium", "#", 0, "26.96, 0, 0", "", "0.0092438133433461, -0.0084008388221264, 5.9975576400757"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear12x24.mdl", "PHX Regular Medium", "#", 0, "13.20, 0, 0", "", "8.254278327513e-007, 8.7331630993503e-007, 12.166662216187"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear16x24.mdl", "PHX Regular Medium", "#", 0, "19.10, 0, 0", "", "8.6996135451045e-007, -2.8219722025824e-007, 12.166659355164"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear24x24.mdl", "PHX Regular Medium", "#", 0, "26.96, 0, 0", "", "-0.0094724241644144, -0.0066200322471559, 12.150183677673"})
  --- PHX Regular Big
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear12x24_large.mdl", "PHX Regular Big", "#", 0, "26.196, 0, 0", "", "1.6508556655026e-006, 1.7466326198701e-006, 24.333324432373"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear12x12_large.mdl", "PHX Regular Big", "#", 0, "26.196, 0, 0", "", "3.6818344142375e-006, 3.3693649470479e-007, 12.333333015442"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear12x6_large.mdl" , "PHX Regular Big", "#", 0, "26.196, 0, 0", "", "3.8200619201234e-007, 4.0919746879808e-007, 6.3333339691162"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear16x24_large.mdl", "PHX Regular Big", "#", 0, "37.480, 0, 0", "", "1.7399227090209e-006, -2.1441636022246e-007, 24.333318710327"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear16x12_large.mdl", "PHX Regular Big", "#", 0, "37.480, 0, 0", "", "1.6911637885642e-006, -1.7452016436437e-006, 12.333334922791"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear16x6_large.mdl" , "PHX Regular Big", "#", 0, "37.480, 0, 0", "", "2.9455352432706e-006, -9.6805695193325e-007, 6.333339214325"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear24x24_large.mdl", "PHX Regular Big", "#", 0, "53.600, 0, 0", "", "1.0641871313055e-006, -3.3355117921019e-006, 24.333333969116"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear24x12_large.mdl", "PHX Regular Big", "#", 0, "53.600, 0, 0", "", "-6.2653803922785e-008, -3.8585267247981e-006, 12"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears/gear24x6_large.mdl" , "PHX Regular Big", "#", 0, "53.600, 0, 0", "", "1.0842279607459e-006, -3.8418565964093e-006, 6.3333292007446"})
  --- PHX Regular Flat
  gearasmlib.SQLInsertRecord("PIECES",{"models/Mechanics/gears2/gear_12t1.mdl", "PHX Regular Flat", "#", 0, "14, 0, 0", "", " 0.024772670120001, -0.0039097801782191,  3.7019141529981e-008"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_12t3.mdl", "PHX Regular Flat", "#", 0, "14, 0, 0", "", "-0.00028943095821887,0.010859239846468,   0.0029602686408907"  })
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_12t2.mdl", "PHX Regular Flat", "#", 0, "14, 0, 0", "", "-0.017006939277053,  0.0030655609443784, -0.00057022727560252" })
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_18t1.mdl", "PHX Regular Flat", "#", 0, "20, 0, 0", "", " 0.0069116964004934, 0.0010486841201782, -0.00013630707690027" })
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_18t2.mdl", "PHX Regular Flat", "#", 0, "20, 0, 0", "", "-0.010480961762369, -0.00094905123114586,-0.00027210538974032" })
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_18t3.mdl", "PHX Regular Flat", "#", 0, "20, 0, 0", "", "-0.0040156506001949, 0.0044087348505855, -0.0016298928530887"  })
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_24t1.mdl", "PHX Regular Flat", "#", 0, "26, 0, 0", "", "0.0005555086536333,0.0018403908470646,7.969097350724e-005"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_24t2.mdl", "PHX Regular Flat", "#", 0, "26, 0, 0", "", "0.0001849096006481,-0.002116076881066,0.00092169753042981"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_24t3.mdl", "PHX Regular Flat", "#", 0, "26, 0, 0", "", "-0.0039519360288978,-0.00076565862400457,0.00095280521782115"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_36t1.mdl", "PHX Regular Flat", "#", 0, "38, 0, 0", "", "-0.013952384702861,-0.015051824972034,-3.6770456063095e-005"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_36t2.mdl", "PHX Regular Flat", "#", 0, "38, 0, 0", "", "-0.001660150825046,0.0067499200813472,7.3757772042882e-005"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_36t3.mdl", "PHX Regular Flat", "#", 0, "38, 0, 0", "", "-0.012223065830767,-0.0013654727954417,-0.00044102084939368"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_48t1.mdl", "PHX Regular Flat", "#", 0, "50, 0, 0", "", "0.0015389173058793,0.003474734723568,0.00028770981589332"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_48t2.mdl", "PHX Regular Flat", "#", 0, "50, 0, 0", "", "0.0030889171175659,-0.00082554836990312,-8.9276603830513e-005"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_48t3.mdl", "PHX Regular Flat", "#", 0, "50, 0, 0", "", "-0.00083220232045278,-0.00013183639384806,-0.0028226880822331"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_60t1.mdl", "PHX Regular Flat", "#", 0, "62, 0, 0", "", "0.017997905611992,-0.008360886014998,0.00023668861831538"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_60t2.mdl", "PHX Regular Flat", "#", 0, "62, 0, 0", "", "-0.0077802902087569,0.0077699818648398,-0.00011245282075834"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/gear_60t3.mdl", "PHX Regular Flat", "#", 0, "62, 0, 0", "", "-0.00085410091560334,0.0053461473435163,-0.00029574517975561"})
  --- PHX Vertical
  gearasmlib.SQLInsertRecord("PIECES",{"models/Mechanics/gears2/vert_18t1.mdl", "PHX Vertical", "#", 90, "19.78, 0, 5.6", "", "-9.3372744913722e-007,-1.4464712876361e-006,-1.4973667860031"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/vert_12t1.mdl", "PHX Vertical", "#", 90, "13.78, 0, 5.6", "", "-6.1126132777645e-007,4.6880626314305e-007,-1.4130713939667"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/vert_24t1.mdl", "PHX Vertical", "#", 90, "25.78, 0, 5.6", "", "-0.0046720593236387,-0.0090785603970289,-1.5481045246124"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/vert_36t1.mdl", "PHX Vertical", "#", 90, "37.78, 0, 5.6", "", "0.0043581933714449,-0.00018005351012107,-1.6056708097458"})
  --- PHX Teeth
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_20t1.mdl", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", " 0.000, -90.000,  0.000", "-0.031061116605997, 0.68289417028427, 0.00010814304550877"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_20t2.mdl", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", " 0.000, -90.000,  0.000", "-0.0308688133955, 0.68287181854248, 0.00033729249844328"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_20t3.mdl", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", "-0.000, -90.000, -0.000", "-0.03086843341589, 0.68287181854248, 0.00067511270754039"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_40.mdl  ", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", " 0.000, -90.000,  0.000", "0.51859414577484, 0.68797379732132, -0.00052835274254903"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_40t1.mdl", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", " 0.000, -90.000,  0.000", "-0.0045434008352458, 0.68366396427155, 0.0020906918216497"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_40t2.mdl", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", " 0.000, -90.000,  0.000", "-0.0043520531617105, 0.68364036083221, 0.004302385263145"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_40t3.mdl", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", " 0.000, -90.000,  0.000", "-0.0043467613868415, 0.68364137411118, 0.008606200106442"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_80t1.mdl", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", " 0.000, -90.000,  0.000", "-0.018019204959273, 0.68289333581924, 0.00052548095118254"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_80t2.mdl", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", " 0.000, -90.000,  0.000", "-0.017873015254736, 0.68288779258728, 0.0010742680169642"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/pinion_80t3.mdl", "PHX Teeth Flat", "#", 0, "2.55, 0, 0", " 0.000, -90.000,  0.000", "-0.018022054806352, 0.68289351463318, 0.0021022602450103"})
  --- PHX Spotter Rack
  
  --- PHX Bevel
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/bevel_12t1.mdl", "PHX Bevel", "#", 45, "12.2, 0, 1.3", "", "-0.0026455507613719,-0.0061479024589062,-0.87438750267029"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/Mechanics/gears2/bevel_18t1.mdl", "PHX Bevel", "#", 45, "17.3, 0, 1.3", "", "-0.033187858760357,0.0065126456320286,-1.0525280237198"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/bevel_24t1.mdl", "PHX Bevel", "#", 45, "23.3, 0, 1.3", "", "-0.0011872322065756,0.0026002936065197,-0.86795377731323"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/bevel_36t1.mdl", "PHX Bevel", "#", 45, "34.8, 0, 1.3", "", "0.00066847755806521,0.0034906349610537,-0.86690950393677"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/bevel_48t1.mdl", "PHX Bevel", "#", 45, "46.7, 0, 1.3", "", "-0.012435931712389,-0.012925148941576,-0.73237001895905"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/mechanics/gears2/bevel_60t1.mdl", "PHX Bevel", "#", 45, "58.6, 0, 1.3", "", "-9.5774739747867e-005,0.0057542459107935,-0.7312148809433"})
  --- Black Regular M
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m_12.mdl" , "Black Regular Medium", "#", 0, " 7.684, 0, 0", "", "-0.014979394152761, 0.0047998707741499, -0.00038224767195061"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m_18.mdl" , "Black Regular Medium", "#", 0, "11.576, 0, 0", "", "-0.0021063536405563, -0.0053282543085515, 0.00087571347830817"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m_24.mdl" , "Black Regular Medium", "#", 0, "15.663, 0, 0", "", "-0.0070638651959598, 0.009610753506422, -0.00015339285891969"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m_30.mdl" , "Black Regular Medium", "#", 0, "19.603, 0, 0", "", "-0.0077706538140774, -0.0071825389750302, 0.00097463151905686"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m_36.mdl" , "Black Regular Medium", "#", 0, "23.656, 0, 0", "", "-0.0044078547507524, 0.0050257132388651, -0.00015181547496468"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m2_12.mdl", "Black Regular Medium", "#", 0, " 7.684, 0, 0", "", "-0.00058068969519809, 0.013377501629293, -1.1378889297475e-007"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m2_18.mdl", "Black Regular Medium", "#", 0, "11.576, 0, 0", "", "6.8955853294028e-007, -7.7567614198415e-007, -1.3395394660165e-007"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m2_24.mdl", "Black Regular Medium", "#", 0, "15.663, 0, 0", "", "-0.0051188934594393, 0.0042025204747915, 3.5875429603038e-005"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m2_30.mdl", "Black Regular Medium", "#", 0, "19.603, 0, 0", "", "-0.010076130740345, 0.0034327011089772, 0.0018927120836452"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m2_36.mdl", "Black Regular Medium", "#", 0, "23.656, 0, 0", "", "0.0045576053671539, -0.0040306155569851, 0.00094956270186231"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m3_12.mdl", "Black Regular Medium", "#", 0, " 7.684, 0, 0", "", "0.0068129352293909, -0.010897922329605, -0.0019134525209665"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m3_18.mdl", "Black Regular Medium", "#", 0, "11.576, 0, 0", "", "-2.666999421308e-007, -3.7215826864667e-007, -5.6812831417119e-007"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m3_24.mdl", "Black Regular Medium", "#", 0, "15.663, 0, 0", "", "-0.0056810793466866, -0.0012888131896034, -0.0020044941920787"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m3_30.mdl", "Black Regular Medium", "#", 0, "19.603, 0, 0", "", "-0.0008564597228542, 0.0034411856904626, 0.0015924768522382"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_m3_36.mdl", "Black Regular Medium", "#", 0, "23.656, 0, 0", "", "0.007684207521379, 0.002827123273164, 0.0003438270650804"})
  --- Black Regular S
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s_12.mdl" , "Black Regular Small", "#", 0, " 3.913, 0, 0", "", "0.0038407891988754, 0.014333480969071, -5.8103839961632e-008"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s_18.mdl" , "Black Regular Small", "#", 0, " 5.886, 0, 0", "", "-0.0022506208624691, 0.0028510170523077, 0.00012522481847554"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s_24.mdl" , "Black Regular Small", "#", 0, " 7.917, 0, 0", "", "-0.013967990875244, -0.021645260974765, -0.00082508515333757"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s_30.mdl" , "Black Regular Small", "#", 0, " 9.849, 0, 0", "", "-0.005624498706311, -0.0024201874621212, 0.00024188664974645"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s_36.mdl" , "Black Regular Small", "#", 0, "11.848, 0, 0", "", "0.0077217095531523, -0.0055977017618716, -0.00015713422908448"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s2_12.mdl", "Black Regular Small", "#", 0, " 3.913, 0, 0", "", "0.0021100759040564, -0.0016733136726543, 0.0022850329987705"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s2_18.mdl", "Black Regular Small", "#", 0, " 5.886, 0, 0", "", "0.0039685778319836, -0.0085194045677781, -0.00055132457055151"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s2_24.mdl", "Black Regular Small", "#", 0, " 7.917, 0, 0", "", "-0.0048923366703093, -0.0077434764243662, -0.0015948973596096"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s2_30.mdl", "Black Regular Small", "#", 0, " 9.849, 0, 0", "", "-0.0064226854592562, 0.020160168409348, 0.0011082629207522"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s2_36.mdl", "Black Regular Small", "#", 0, "11.848, 0, 0", "", "0.009396655485034, 0.010528456419706, 0.0033775176852942"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s3_12.mdl", "Black Regular Small", "#", 0, " 3.913, 0, 0", "", "0.0018781825201586, -0.0014426524285227, -0.00095008197240531"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s3_18.mdl", "Black Regular Small", "#", 0, " 5.886, 0, 0", "", "0.0099822543561459, 0.00096216786187142, 0.0025063841603696"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s3_24.mdl", "Black Regular Small", "#", 0, " 7.917, 0, 0", "", "0.007310485932976, -0.004775257781148, 0.0017300172476098"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s3_30.mdl", "Black Regular Small", "#", 0, " 9.849, 0, 0", "", "0.0016155475750566, -0.010166599415243, -0.00065914361039177"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/gears/gear1_s3_36.mdl", "Black Regular Small", "#", 0, "11.848, 0, 0", "", "0.014523273333907, 0.012045037001371, 0.00054475461365655"})
  --- Sprops Flat S
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_10t_s.mdl", "SProps Flat Small", "#", 0, " 2.820, 0, 0", "", "0.0049172430299222, -0.0049177999608219, -1.5156917498871e-008"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_12t_s.mdl", "SProps Flat Small", "#", 0, " 3.100, 0, 0", "", "-0.001883051590994, 0.00050171936163679, -0.0005939711118117"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_14t_s.mdl", "SProps Flat Small", "#", 0, " 3.784, 0, 0", "", "0.002141302684322, -0.002729385625571, 0.013979037292302"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_16t_s.mdl", "SProps Flat Small", "#", 0, " 4.271, 0, 0", "", "0.0015306419227272, -0.00057447905419394, -0.00052806112216786"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_18t_s.mdl", "SProps Flat Small", "#", 0, " 4.761, 0, 0", "", "-0.0017241191817448, -0.0063244164921343, -0.00037708022864535"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_24t_s.mdl", "SProps Flat Small", "#", 0, " 6.237, 0, 0", "", "-2.9937275485281e-006, -1.4846134490654e-006, -1.7167849364341e-008"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_30t_s.mdl", "SProps Flat Small", "#", 0, " 7.722, 0, 0", "", "0.001925386604853, 0.00010160527017433, 0.00021312535682227"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_36t_s.mdl", "SProps Flat Small", "#", 0, " 9.211, 0, 0", "", "-0.00056221708655357, -7.6126736530568e-005, -1.2265476634354e-008"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_42t_s.mdl", "SProps Flat Small", "#", 0, "10.703, 0, 0", "", "-2.1004445898143e-006, -1.0246620831822e-006, 8.0583710371229e-008"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_48t_s.mdl", "SProps Flat Small", "#", 0, "12.197, 0, 0", "", "-0.0046847369521856, -0.0031020345631987, -0.00029869191348553"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_54t_s.mdl", "SProps Flat Small", "#", 0, "13.692, 0, 0", "", "0.001435556798242, -0.020333550870419, -0.0020731033291668"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_60t_s.mdl", "SProps Flat Small", "#", 0, "15.188, 0, 0", "", "0.020014140754938, 0.018639868125319, -0.00044363949564286"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_66t_s.mdl", "SProps Flat Small", "#", 0, "16.685, 0, 0", "", "-0.010388540104032, 0.016772596165538, -0.00034016091376543"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_72t_s.mdl", "SProps Flat Small", "#", 0, "18.182, 0, 0", "", "0.03625612705946, -0.0024083079770207, 9.4895163783804e-005"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_78t_s.mdl", "SProps Flat Small", "#", 0, "19.680, 0, 0", "", "0.0019805070478469, -0.0081495717167854, 0.0006504594348371"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_84t_s.mdl", "SProps Flat Small", "#", 0, "21.178, 0, 0", "", "0.030328331515193, -0.021101905032992, -0.00029180099954829"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_90t_s.mdl", "SProps Flat Small", "#", 0, "22.676, 0, 0", "", "-0.029588585719466, -0.014376631937921, -0.00069682777393609"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_96t_s.mdl", "SProps Flat Small", "#", 0, "24.174, 0, 0", "", "0.005857755895704, -0.01476801559329, -0.00028429020312615"})
  --- SProps Flat L
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_10t_l.mdl", "SProps Flat Large", "#", 0, " 5.394, 0, 0", "", "-0.0041495636105537, -0.0030151198152453, -0.0059148990549147"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_12t_l.mdl", "SProps Flat Large", "#", 0, " 6.358, 0, 0", "", "-0.0037653909530491, -0.006521004717797, -0.0023776774760336"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_14t_l.mdl", "SProps Flat Large", "#", 0, " 7.330, 0, 0", "", "4.0495933717466e-007, 3.3086558914874e-007, -3.283965099854e-008"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_16t_l.mdl", "SProps Flat Large", "#", 0, " 8.307, 0, 0", "", "-0.0028722907882184, 0.00086623401148245, -3.2330953469994e-009"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_18t_l.mdl", "SProps Flat Large", "#", 0, " 9.288, 0, 0", "", "0.0068863672204316, -0.0019885420333594, 0.00037651605089195"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_24t_l.mdl", "SProps Flat Large", "#", 0, "12.247, 0, 0", "", "-2.9040645586065e-006, -3.0396604415728e-006, -3.5156244582168e-009"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_30t_l.mdl", "SProps Flat Large", "#", 0, "15.221, 0, 0", "", "-0.0038472001906484, -0.005274873226881, 0.0015362998237833"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_36t_l.mdl", "SProps Flat Large", "#", 0, "18.203, 0, 0", "", "0.0037662063259631, 0.0026958135422319, -0.00089779059635475"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_42t_l.mdl", "SProps Flat Large", "#", 0, "21.189, 0, 0", "", "-2.4632468011987e-006, -2.1759717583336e-006, 1.3644348939579e-007"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_48t_l.mdl", "SProps Flat Large", "#", 0, "24.179, 0, 0", "", "-9.0362368609931e-007, -2.2698932298226e-006, 2.9944263957304e-008"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_54t_l.mdl", "SProps Flat Large", "#", 0, "27.171, 0, 0", "", "-0.00012703427637462, 0.0087271770462394, 0.00064932194072753"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_60t_l.mdl", "SProps Flat Large", "#", 0, "30.164, 0, 0", "", "0.0056863417848945, -0.0054859640076756, 0.00057526386808604"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_66t_l.mdl", "SProps Flat Large", "#", 0, "33.158, 0, 0", "", "0.00034787258482538, 0.01172979734838, 0.00039185225614347"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_72t_l.mdl", "SProps Flat Large", "#", 0, "36.154, 0, 0", "", "0.0059279436245561, -0.00014554298832081, 0.00043231318704784"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_78t_l.mdl", "SProps Flat Large", "#", 0, "39.150, 0, 0", "", "0.035279795527458, 0.0002772074949462, -0.0002848417207133"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_84t_l.mdl", "SProps Flat Large", "#", 0, "42.146, 0, 0", "", "-0.0063623366877437, -0.0040172939188778, 0.00028934032889083"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_90t_l.mdl", "SProps Flat Large", "#", 0, "45.143, 0, 0", "", "-3.0313363822643e-005, 0.0025897726882249, -8.3106489910278e-005"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/sgears/spur_96t_l.mdl", "SProps Flat Large", "#", 0, "48.141, 0, 0", "", "-0.020891901105642, -0.0010100682266057, 0.00014523084973916"})
  --- SProps Bevel
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_10t_l.mdl", "SProps Bevel Large", "#", 45, " 5.520, 0, 1.35", "", "-2.1634095901391e-005, 0.00061463302699849, -1.0174524784088"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_12t_l.mdl", "SProps Bevel Large", "#", 45, " 6.244, 0, 1.35", "", "-0.03066711127758, 0.013303384184837, -0.9567843079567"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_14t_l.mdl", "SProps Bevel Large", "#", 45, " 7.237, 0, 1.35", "", "0.0046781497076154, 0.0045431824401021, -0.91953921318054"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_16t_l.mdl", "SProps Bevel Large", "#", 45, " 8.230, 0, 1.35", "", "-0.0024151098914444, -0.0035203483421355, -0.88513052463531"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_18t_l.mdl", "SProps Bevel Large", "#", 45, " 9.280, 0, 1.35", "", "-3.7560730561381e-006, -3.2225407267106e-006, -0.85729819536209"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_24t_l.mdl", "SProps Bevel Large", "#", 45, "12.252, 0, 1.35", "", "-2.7985045107926e-006, -3.253147497162e-006, -0.80283242464066"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_30t_l.mdl", "SProps Bevel Large", "#", 45, "15.275, 0, 1.35", "", "0.0065972418524325, 0.012552709318697, -0.76705181598663"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_36t_l.mdl", "SProps Bevel Large", "#", 45, "18.257, 0, 1.35", "", "0.0032132093328983, 0.0069867530837655, -0.74561846256256"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_42t_l.mdl", "SProps Bevel Large", "#", 45, "21.244, 0, 1.35", "", "-2.1220994312898e-006, -1.2074082178515e-006, -0.72734010219574"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_48t_l.mdl", "SProps Bevel Large", "#", 45, "24.233, 0, 1.35", "", "0.0043564774096012, 0.0072778444737196, -0.7125990986824"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_54t_l.mdl", "SProps Bevel Large", "#", 45, "27.193, 0, 1.35", "", "-0.0012360077816993, -0.015729079023004, -0.70351052284241"})
  gearasmlib.SQLInsertRecord("PIECES",{"models/sprops/mechanics/bgears/bevel_60t_l.mdl", "SProps Bevel Large", "#", 45, "30.188, 0, 1.35", "", "0.0024155958089978, -0.0004843553469982, -0.69532954692841"})

end

---------------- Localizing Libraries ----------------

local type              = type
local pairs             = pairs
local Angle             = Angle
local print             = print
local Color             = Color
local ipairs            = ipairs
local Vector            = Vector
local IsValid           = IsValid
local tonumber          = tonumber
local tostring          = tostring
local LocalPlayer       = LocalPlayer
local GetConVarString   = GetConVarString
local RunConsoleCommand = RunConsoleCommand
local os                = os
local sql               = sql
local math              = math
local ents              = ents
local util              = util
local undo              = undo
local file              = file
local string            = string
local cleanup           = cleanup
local concommand        = concommand
local duplicator        = duplicator
local constraint        = constraint

----------------- TOOL Global Parameters ----------------

--- ZERO Objects
local VEC_ZERO = Vector(0,0,0)
local ANG_ZERO = Angle (0,0,0)

--- Toolgun Background texture ID reference
local txToolgunBackground

--- Render Base Colours
local stDrawDyes = {
  Red   = Color(255, 0 , 0 ,255),
  Green = Color( 0 ,255, 0 ,255),
  Blue  = Color( 0 , 0 ,255,255),
  Cyan  = Color( 0 ,255,255,255),
  Magen = Color(255, 0 ,255,255),
  Yello = Color(255,255, 0 ,255),
  White = Color(255,255,255,255),
  Black = Color( 0 , 0 , 0 ,255),
  Ghost = Color(255,255,255,150),
  Anchr = Color(180,255,150,255),
  Txtsk = Color(161,161,161,255)
}

local stSMode = {
  ["MAX"]  = 2,
  ["ACT"] = "Stack Mode",
  [1] = "Forward based",
  [2] = "Around pivot"
}

local stCType = {
  ["MAX"] = 13,
  ["ACT"] = "Constraint Type",
  [1]  = {Name = "Free Spawn"  , Make = nil},
  [2]  = {Name = "No PhysGun"  , Make = nil},
  [3]  = {Name = "Parent Piece", Make = nil},
  [4]  = {Name = "Weld Piece"  , Make = constraint.Weld},
  [5]  = {Name = "Axis Piece"  , Make = constraint.Axis},
  [6]  = {Name = "Ball-Sock HM", Make = constraint.Ballsocket},
  [7]  = {Name = "Ball-Sock TM", Make = constraint.Ballsocket},
  [8]  = {Name = "AdvBS Lock X", Make = constraint.AdvBallsocket},
  [9]  = {Name = "AdvBS Lock Y", Make = constraint.AdvBallsocket},
  [10] = {Name = "AdvBS Lock Z", Make = constraint.AdvBallsocket},
  [11] = {Name = "AdvBS Spin X", Make = constraint.AdvBallsocket},
  [12] = {Name = "AdvBS Spin Y", Make = constraint.AdvBallsocket},
  [13] = {Name = "AdvBS Spin Z", Make = constraint.AdvBallsocket}
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

------------- LOCAL FUNCTIONS AND STUFF ----------------

if(CLIENT)then
  language.Add("Tool.gearassembly.name", "Gear Assembly")
  language.Add("Tool.gearassembly.desc", "Assembles gears to mesh together")
  language.Add("Tool.gearassembly.0"   , "Left click to spawn/stack, Right to change mode, Reload to remove a piece")
  language.Add("Cleanup.gearassembly"  , "Gear Assembly")
  language.Add("Cleaned.gearassemblys" , "Cleaned up all Pieces")

  local function ResetOffsets(oPly,oCom,oArgs)
    -- Reset all of the offset options to zero
    oPly:ConCommand("gearassembly_nextx 0\n")
    oPly:ConCommand("gearassembly_nexty 0\n")
    oPly:ConCommand("gearassembly_nextz 0\n")
    oPly:ConCommand("gearassembly_rotpiv 0\n")
    oPly:ConCommand("gearassembly_nextpic 0\n")
    oPly:ConCommand("gearassembly_nextyaw 0\n")
    oPly:ConCommand("gearassembly_nextrol 0\n")
  end
  concommand.Add("gearassembly_resetoffs",ResetOffsets)
  txToolgunBackground = surface.GetTextureID("vgui/white")
end

TOOL.Category   = "Construction"            -- Name of the category
TOOL.Name       = "#Tool.gearassembly.name" -- Name to display
TOOL.Command    = nil                       -- Command on click ( nil )
TOOL.ConfigName = nil                       -- Config file name ( nil )
TOOL.AddToMenu  = true                      -- Yo add it to the Q menu or not ( true )

TOOL.ClientConVar = {
  [ "mass"      ] = "250",
  [ "model"     ] = "models/props_phx/trains/tracks/track_1x.mdl",
  [ "nextx"     ] = "0",
  [ "nexty"     ] = "0",
  [ "nextz"     ] = "0",
  [ "count"     ] = "1",
  [ "anchor"    ] = "",
  [ "contyp"    ] = "1",
  [ "stmode"    ] = "1",
  [ "freeze"    ] = "0",
  [ "advise"    ] = "1",
  [ "igntyp"    ] = "0",
  [ "rotpiv"    ] = "0",
  [ "nextpic"   ] = "0",
  [ "nextyaw"   ] = "0",
  [ "nextrol"   ] = "0",
  [ "enghost"   ] = "0",
  [ "addinfo"   ] = "0",
  [ "logsenb"   ] = "0",
  [ "orangtr"   ] = "0",
  [ "logsmax"   ] = "10000",
  [ "logfile"   ] = "gearasmlib_log",
  [ "bgskids"   ] = "",
  [ "spwnflat"  ] = "0",
  [ "exportdb"  ] = "0",
  [ "forcelim"  ] = "0",
  [ "deltarot"  ] = "360",
  [ "maxstatts" ] = "3",
  [ "engravity" ] = "1",
  [ "nocollide" ] = "0",
}

if(SERVER)then

  cleanup.Register("GEARASSEMBLYs")

  function LoadDupePieceNoPhysgun(Ply,oEnt,tData)
    if tData.NoPhysgun then
      oEnt:SetMoveType(MOVETYPE_NONE)
      oEnt:SetUnFreezable(true)
      oEnt.PhysgunDisabled = true
      duplicator.StoreEntityModifier(oEnt,"gearassembly_nophysgun",{NoPhysgun = true })
    end
  end

  function eMakePiece(sModel,vPos,aAng,nMass,sBgSkISs)
    -- You never know .. ^_^
    local stPiece = gearasmlib.CacheQueryPiece(sModel)
    if(not stPiece) then return nil end -- Not present in the DB
    local ePiece = ents.Create("prop_physics")
    if(ePiece and ePiece:IsValid()) then
      ePiece:SetCollisionGroup(COLLISION_GROUP_NONE );
      ePiece:SetSolid(SOLID_VPHYSICS);
      ePiece:SetMoveType(MOVETYPE_VPHYSICS)
      ePiece:SetNotSolid(false);
      ePiece:SetModel(sModel)
      ePiece:SetPos(vPos)
      ePiece:SetAngles(aAng)
      ePiece:Spawn()
      ePiece:Activate()
      ePiece:SetColor(stDrawDyes.White)
      ePiece:SetRenderMode(RENDERMODE_TRANSALPHA)
      ePiece:DrawShadow(true)
      ePiece:PhysWake()
      local phPiece = ePiece:GetPhysicsObject()
      if(phPiece and phPiece:IsValid()) then
        local IDs = gearasmlib.StringExplode(sBgSkISs,"/")
        phPiece:SetMass(nMass)
        phPiece:EnableMotion(false)
        gearasmlib.AttachBodyGroups(ePiece,IDs[1] or "")
        ePiece:SetSkin(math.Clamp(tonumber(IDs[2]) or 1,1,ePiece:SkinCount()))
        return ePiece
      end
      ePiece:Remove()
      return nil
    end
    return nil
  end

  -- Returns Error Trigger ( False = No Error)
  function ConstraintMaster(eBase,ePiece,vPos,vNorm,nID,nNoCollid,nForceLim,nFreeze,nGrav)
    local ConID    = tonumber(nID) or 1
    local Freeze   = nFreeze       or 0
    local Grav     = nGrav         or 0
    local NoCollid = nNoCollid     or 0
    local ForceLim = nForceLim     or 0
    local IsIn     = false
    if(not stCType[ConID]) then return true end
    gearasmlib.LogInstance("ConstraintMaster: Creating "..stCType[ConID].Name..".")
    local ConstrInfo = stCType[ConID]
    -- Check for "Free Spawn" ( No constraints ) , coz nothing to be done after it.
    if(not IsIn and ConID == 1) then IsIn = true end
    if(not (ePiece and ePiece:IsValid())) then return true end
    if(not constraint.CanConstrain(ePiece,0)) then return true end
    if(gearasmlib.IsOther(ePiece)) then return true end
    if(not IsIn and ConID == 2) then
      -- Weld Ground is my custom child ...
      ePiece:SetUnFreezable(true)
      ePiece.PhysgunDisabled = true
      duplicator.StoreEntityModifier(ePiece,"gearassembly_nophysgun",{NoPhysgun = true})
      IsIn = true
    end
    local pyPiece = ePiece:GetPhysicsObject()
    if(not (pyPiece and pyPiece:IsValid())) then return true end
    construct.SetPhysProp(nil,ePiece,0,pyPiece,{Material = "gmod_ice"})
    if(nFreeze and Freeze == 0) then
      pyPiece:EnableMotion(true)
    end
    if(not (Grav and nG ~= 0)) then
      construct.SetPhysProp(nil,ePiece,0,pyPiece,{GravityToggle = false})
    end
    if(not (eBase and eBase:IsValid())) then return true end
    if(not constraint.CanConstrain(eBase,0)) then return true end
    if(gearasmlib.IsOther(eBase)) then return true end
    if(not IsIn and ConID == 3) then
      -- http://wiki.garrysmod.com/page/Entity/SetParent
      ePiece:SetParent(eBase)
      IsIn = true
    elseif(not IsIn and ConID == 4) then
      -- http://wiki.garrysmod.com/page/constraint/Weld
      local C = ConstrInfo.Make(ePiece,eBase,0,0,ForceLim,(NoCollid ~= 0),false)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    end
    if(not IsIn and ConID == 5 and vNorm) then
      -- http://wiki.garrysmod.com/page/constraint/Axis
      local LPos1 = pyPiece:GetMassCenter()
      local LPos2 = ePiece:LocalToWorld(LPos1)
            LPos2:Add(vNorm)
            LPos2:Set(eBase:WorldToLocal(LPos2))
      local C = ConstrInfo.Make(ePiece,eBase,0,0,
                                LPos1,LPos2,
                                ForceLim,0,0,NoCollid)
       gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
       IsIn = true
    elseif(not IsIn and ConID == 6) then
      -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( HD )
      local C = ConstrInfo.Make(eBase,ePiece,0,0,pyPiece:GetMassCenter(),ForceLim,0,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    elseif(not IsIn and ConID == 7 and vPos) then
      -- http://wiki.garrysmod.com/page/constraint/Ballsocket ( TR )
      local vLPos2 = eBase:WorldToLocal(vPos)
      local C = ConstrInfo.Make(ePiece,eBase,0,0,vLPos2,ForceLim,0,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    end
    -- http://wiki.garrysmod.com/page/constraint/AdvBallsocket
    local pyBase = eBase:GetPhysicsObject()
    if(not (pyBase and pyBase:IsValid())) then return true end
    local Min,Max = 0.01,180
    local LPos1 = pyBase:GetMassCenter()
    local LPos2 = pyPiece:GetMassCenter()
    if(not IsIn and ConID == 8) then -- Lock X
      local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Min,-Max,-Max,Min,Max,Max,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    elseif(not IsIn and ConID == 9) then -- Lock Y
      local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max,-Min,-Max,Max,Min,Max,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    elseif(not IsIn and ConID == 10) then -- Lock Z
      local C = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max,-Max,-Min,Max,Max,Min,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C},1)
      IsIn = true
    elseif(not IsIn and ConID == 11) then -- Spin X
      local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max,-Min,-Min,Max, Min, Min,0,0,0,1,NoCollid)
      local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Max, Min, Min,Max,-Min,-Min,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C1,C2},2)
      IsIn = true
    elseif(not IsIn and ConID == 12) then -- Spin Y
      local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Min,-Max,-Min, Min,Max, Min,0,0,0,1,NoCollid)
      local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0, Min,-Max, Min,-Min,Max,-Min,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C1,C2},2)
      IsIn = true
    elseif(not IsIn and ConID == 13) then -- Spin Z
      local C1 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0,-Min,-Min,-Max, Min, Min,Max,0,0,0,1,NoCollid)
      local C2 = ConstrInfo.Make(ePiece,eBase,0,0,LPos1,LPos2,ForceLim,0, Min, Min,-Max,-Min,-Min,Max,0,0,0,1,NoCollid)
      gearasmlib.HookOnRemove(eBase,ePiece,{C1,C2},2)
      IsIn = true
    end
    return (not IsIn)
  end

  duplicator.RegisterEntityModifier("gearassembly_nophysgun",LoadDupePieceNoPhysgun)

end

function TOOL:LeftClick(Trace)
  if(CLIENT) then self:ClearObjects() return true end
  if(not Trace) then return false end
  if(not Trace.Hit) then return false end
  local trEnt     = Trace.Entity
  local eBase     = self:GetEnt(1)
  local ply       = self:GetOwner()
  local model     = self:GetClientInfo("model")
  local nextx     = self:GetClientNumber("nextx") or 0
  local nexty     = self:GetClientNumber("nexty") or 0
  local nextz     = self:GetClientNumber("nextz") or 0
  local freeze    = self:GetClientNumber("freeze") or 0
  local igntyp    = self:GetClientNumber("igntyp") or 0
  local bgskids   = self:GetClientInfo("bgskids") or ""
  local engravity = self:GetClientNumber("engravity") or 0
  local nocollide = self:GetClientNumber("nocollide") or 0
  local spwnflat  = self:GetClientNumber("spwnflat") or 0
  local orangtr   = self:GetClientNumber("orangtr")  or 0
  local count     = math.Clamp(self:GetClientNumber("count"),1,200)
  local mass      = math.Clamp(self:GetClientNumber("mass"),1,50000)
  local staatts   = math.Clamp(self:GetClientNumber("maxstaatts"),1,5)
  local rotpiv    = math.Clamp(self:GetClientNumber("rotpiv") or 0,-360,360)
  local nextpic   = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
  local nextyaw   = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
  local nextrol   = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
  local deltarot  = math.Clamp(self:GetClientNumber("deltarot") or 0,-360,360)
  local forcelim  = math.Clamp(self:GetClientNumber("forcelim") or 0,0,1000000)
  local stmode    = gearasmlib.GetCorrectID(self:GetClientInfo("stmode"),stSMode)
  local contyp    = gearasmlib.GetCorrectID(self:GetClientInfo("contyp"),stCType)
  gearasmlib.PlyLoadKey(ply)
  if(not gearasmlib.PlyLoadKey(ply,"SPEED") and
     not gearasmlib.PlyLoadKey(ply,"DUCK")) then
    -- Direct Snapping
    if(not (eBase and eBase:IsValid()) and (trEnt and trEnt:IsValid())) then eBase = trEnt end
    local ePiece = eMakePiece(model,Trace.HitPos,ANG_ZERO,mass,bgskids)
    if(not ePiece) then return false end
    local stSpawn = gearasmlib.GetNORSpawn(Trace,model,Vector(nextx,nexty,nextz),
                                           Angle(nextpic,nextyaw,nextrol))
    if(not stSpawn) then return false end
    stSpawn.SPos:Add(gearasmlib.GetCustomAngBBZ(ePiece,stSpawn.HRec.A,spwnflat) * Trace.HitNormal)
    ePiece:SetAngles(stSpawn.SAng)
    if(util.IsInWorld(stSpawn.SPos)) then
      gearasmlib.SetMCWorld(ePiece,stSpawn.HRec.M,stSpawn.SPos)
    else
      ePiece:Remove()
      gearasmlib.PrintNotify(ply,"Position out of map bounds!","ERROR")
      gearasmlib.LogInstance("GEARASSEMBLY: Additional Error INFO"
      .."\n   Event  : Spawning when HitNormal"
      .."\n   Player : "..ply:Nick()
      .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
      .."\n")
      return false
    end
    undo.Create("Last Gear Assembly")
    if(ConstraintMaster(eBase,ePiece,Trace.HitPos,Trace.HitNormal,contyp,nocollide,forcelim,freeze,engravity)) then
      gearasmlib.PrintNotify(ply,"Ignore constraint "..stCType[contyp].Name..".","UNDO")
    end
    gearasmlib.EmitSoundPly(ply)
    undo.AddEntity(ePiece)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText("Undone Assembly ( Normal Spawn )")
    undo.Finish()
    return true
  end
  -- Hit Prop
  if(not trEnt) then return false end
  if(not trEnt:IsValid()) then return false end
  if(not gearasmlib.IsPhysTrace(Trace)) then return false end
  if(gearasmlib.IsOther(trEnt)) then return false end

  local trPos   = trEnt:GetPos()
  local trAng   = trEnt:GetAngles()
  local trModel = trEnt:GetModel()
  local bsModel = "N/A"
  if(eBase and eBase:IsValid()) then bsModel = eBase:GetModel() end

  --No need stacking relative to non-persistent props or using them...
  local hdRec   = gearasmlib.CacheQueryPiece(model)
  local trRec   = gearasmlib.CacheQueryPiece(trModel)

  if(not trRec) then return false end

  if(gearasmlib.PlyLoadKey(ply,"DUCK")) then
    -- USE: Use the VALID Trace.Entity as a piece
    gearasmlib.PrintNotify(ply,"Model: "..gearasmlib.GetModelFileName(trModel).." selected !","GENERIC")
    ply:ConCommand("gearassembly_model "..trModel.."\n")
    return true
  end

  if(not hdRec) then return false end

  if(count > 1 and
     gearasmlib.PlyLoadKey(ply,"SPEED") and
     stmode >= 1 and
     stmode <= stSMode["MAX"]
  ) then
    local stSpawn = gearasmlib.GetENTSpawn(trPos,trAng,trModel,
                                           rotpiv,model,igntyp,orangtr,
                                           Vector(nextx,nexty,nextz),
                                           Angle(nextpic,nextyaw,nextrol))
    if(not stSpawn) then return false end
    undo.Create("Last Gear Assembly")
    local ePieceN, ePieceO = nil, trEnt
    local i     = count
    local nTrys = staatts
    local dRot  = deltarot / count
    while(i > 0) do
      ePieceN = eMakePiece(model,ePieceO:GetPos(),ANG_ZERO,mass,bgskids)
      if(ePieceN) then
        ePieceN:SetAngles(stSpawn.SAng)
        if(util.IsInWorld(stSpawn.SPos)) then
          gearasmlib.SetMCWorld(ePieceN,stSpawn.HRec.M,stSpawn.SPos)
        else
          ePieceN:Remove()
          gearasmlib.PrintNotify(ply,"Position out of map bounds!","ERROR")
          gearasmlib.LogInstance("GEARASSEMBLY: Additional Error INFO"
          .."\n   Event  : Stacking > Position out of map bounds"
          .."\n   StMode : "..stSMode[stmode]
          .."\n   Iterats: "..tostring(count-i)
          .."\n   StackTr: "..tostring(nTrys).." ?= "..tostring(staatts)
          .."\n   Player : "..ply:Nick()
          .."\n   DeltaRt: "..dRot
          .."\n   Anchor : "..gearasmlib.GetModelFileName(bsModel)
          .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
          .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
          .."\n")
          gearasmlib.EmitSoundPly(ply)
          undo.SetPlayer(ply)
          undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-i).." )")
          undo.Finish()
          return true
        end
        ConstraintMaster(eBase,ePieceN,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim,freeze,engravity)
        undo.AddEntity(ePieceN)
        if(stmode == 1) then
          stSpawn = gearasmlib.GetENTSpawn(ePieceN:GetPos(),ePieceN:GetAngles(),
                                           trModel,rotpiv,model,igntyp,
                                           orangtr,Vector(nextx,nexty,nextz),
                                           Angle(nextpic,nextyaw,nextrol))
          ePieceO = ePieceN
        elseif(stmode == 2) then
          trAng:RotateAroundAxis(stSpawn.TAng:Up(),-dRot)
          stSpawn = gearasmlib.GetENTSpawn(trPos,trAng,trModel,rotpiv,model,igntyp,
                                           orangtr,Vector(nextx,nexty,nextz),
                                           Angle(nextpic,nextyaw,nextrol))
        end
        if(not stSpawn) then
          gearasmlib.PrintNotify(ply,"Failed to obtain spawn data!","ERROR")
          gearasmlib.LogInstance("GEARASSEMBLY: Additional Error INFO"
          .."\n   Event  : Stacking > Failed to obtain spawn data"
          .."\n   StMode : "..stSMode[stmode]
          .."\n   Iterats: "..tostring(count-i)
          .."\n   StackTr: "..tostring(nTrys).." ?= "..tostring(staatts)
          .."\n   Player : "..ply:Nick()
          .."\n   DeltaRt: "..dRot
          .."\n   Anchor : "..gearasmlib.GetModelFileName(bsModel)
          .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
          .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
          .."\n")
          gearasmlib.EmitSoundPly(ply)
          undo.SetPlayer(ply)
          undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-i).." )")
          undo.Finish()
          return true
        end
        i = i - 1
        nTrys = staatts
      else
        nTrys = nTrys - 1
      end
      if(nTrys <= 0) then
        gearasmlib.PrintNotify(ply,"Make attempts ran off!","ERROR")
        gearasmlib.LogInstance("GEARASSEMBLY: Additional Error INFO"
        .."\n   Event  : Stacking > Failed to allocate memory for a piece"
        .."\n   StMode : "..stSMode[stmode]
        .."\n   Iterats: "..tostring(count-i)
        .."\n   StackTr: "..tostring(nTrys).." ?= "..tostring(staatts)
        .."\n   Player : "..ply:Nick()
        .."\n   DeltaRt: "..dRot
        .."\n   Anchor : "..gearasmlib.GetModelFileName(bsModel)
        .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
        .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
        .."\n")
        gearasmlib.EmitSoundPly(ply)
        undo.SetPlayer(ply)
        undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-i).." )")
        undo.Finish()
        return true
      end
    end
    gearasmlib.EmitSoundPly(ply)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText("Undone Assembly ( Stack #"..tostring(count-i).." )")
    undo.Finish()
    return true
  end

  local stSpawn = gearasmlib.GetENTSpawn(trPos,trAng,trModel,rotpiv,model,igntyp,
                                         orangtr,Vector(nextx,nexty,nextz),
                                         Angle(nextpic,nextyaw,nextrol))
  if(stSpawn) then
    local ePiece = eMakePiece(model,Trace.HitPos,ANG_ZERO,mass,bgskids)
    if(ePiece) then
      ePiece:SetAngles(stSpawn.SAng)
      if(util.IsInWorld(stSpawn.SPos)) then
        gearasmlib.SetMCWorld(ePiece,stSpawn.HRec.M,stSpawn.SPos)
      else
        ePiece:Remove()
        gearasmlib.PrintNotify(ply,"Position out of map bounds !","ERROR")
        gearasmlib.LogInstance("GEARASSEMBLY: Additional Error INFO"
        .."\n   Event  : Spawn one piece relative to another"
        .."\n   Player : "..ply:Nick()
        .."\n   Anchor : "..gearasmlib.GetModelFileName(bsModel)
        .."\n   trModel: "..gearasmlib.GetModelFileName(trModel)
        .."\n   hdModel: "..gearasmlib.GetModelFileName(model)
        .."\n")
        return true
      end
      undo.Create("Last Gear Assembly")
      if(ConstraintMaster(eBase,ePiece,stSpawn.SPos,stSpawn.DAng:Up(),contyp,nocollide,forcelim,freeze,engravity)) then
        gearasmlib.PrintNotify(ply,"Ignore constraint "..stCType[contyp].Name..".","UNDO")
      end
      gearasmlib.EmitSoundPly(ply)
      undo.AddEntity(ePiece)
      undo.SetPlayer(ply)
      undo.SetCustomUndoText("Undone Assembly ( Prop Relative )")
      undo.Finish()
      return true
    end
  end
  return false
end

function TOOL:RightClick(Trace)
  -- Change the tool mode
  if(CLIENT) then return true end
  if(not Trace) then return nil end
  local ply = self:GetOwner()
  gearasmlib.PlyLoadKey(ply)
  if(gearasmlib.PlyLoadKey(ply,"SPEED")) then
    local trEnt = Trace.Entity
    if(Trace.HitWorld) then
      local svEnt = self:GetEnt(1)
      if(svEnt and svEnt:IsValid()) then
        svEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
        svEnt:SetColor(stDrawDyes.White)
      end
      gearasmlib.PrintNotify(ply,"Anchor: Cleaned !","CLEANUP")
      ply:ConCommand("gearassembly_anchor N/A\n")
      self:ClearObjects()
      return true
    elseif(trEnt and trEnt:IsValid()) then
      local svEnt = self:GetEnt(1)
      if(svEnt and svEnt:IsValid()) then
        svEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
        svEnt:SetColor(stDrawDyes.White)
      end
      self:ClearObjects()
      pyEnt = trEnt:GetPhysicsObject()
      if(not (pyEnt and pyEnt:IsValid())) then return false end
      self:SetObject(1,trEnt,Trace.HitPos,pyEnt,Trace.PhysicsBone,Trace.HitNormal)
      trEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
      trEnt:SetColor(stDrawDyes.Anchr)
      local trModel = gearasmlib.GetModelFileName(trEnt:GetModel())
      ply:ConCommand("gearassembly_anchor ["..trEnt:EntIndex().."] "..trModel.."\n")
      gearasmlib.PrintNotify(ply,"Anchor: Set "..trModel.." !","UNDO")
      return true
    end
    return false
  else
    local stmode = gearasmlib.GetCorrectID(self:GetClientInfo("stmode"),stSMode)
          stmode = gearasmlib.GetCorrectID(stmode + 1,stSMode)
    ply:ConCommand("gearassembly_stmode "..stmode.."\n")
    gearasmlib.PrintNotify(ply,"Stack Mode: "..stSMode[stmode].." !","UNDO")
    return true
  end
  return false
end

function TOOL:Reload(Trace)
  if(CLIENT) then return true end
  if(not Trace) then return false end
  local ply       = self:GetOwner()
  gearasmlib.PlyLoadKey(ply)
  if(Trace.HitWorld and gearasmlib.PlyLoadKey(ply,"SPEED")) then
    local logsenb   = self:GetClientNumber("logsenb") or 0
    local exportdb  = self:GetClientNumber("exportdb") or 0
    if(logsenb ~= 0) then
      local logsmax = self:GetClientNumber("logsmax") or 0
      local logfile = self:GetClientInfo  ("logfile") or ""
      if(logsmax > 0) then
        gearasmlib.SetLogControl(logsenb,logsmax,logfile)
      end
    end
    if(exportdb ~= 0) then
      gearasmlib.PrintInstance("Reload + SPEED --> Exporting DB ...")
      gearasmlib.ExportSQL2Lua("PIECES")
      gearasmlib.ExportSQL2Inserts("PIECES")
      gearasmlib.SQLExportIntoDSV("db_","PIECES","\t")
    end
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

local function DrawLineColor(PosS,PosE,w,h,stColor)
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

local function DrawAdditionalInfo(stSpawn)
  if(not stSpawn) then return end
  local txPos = {x = 0, y = 0, w = 0, h = 0}
  txPos.x = surface.ScreenWidth() / 2 + 10
  txPos.y = surface.ScreenHeight()/ 2 + 10
  surface.SetFont("Trebuchet18")
  DrawTextRowColor(txPos,"Org POS: "..tostring(stSpawn.OPos),stDrawDyes.Black)
  DrawTextRowColor(txPos,"Dom ANG: "..tostring(stSpawn.DAng))
  DrawTextRowColor(txPos,"Mod POS: "..tostring(stSpawn.MPos))
  DrawTextRowColor(txPos,"Mod ANG: "..tostring(stSpawn.MAng))
  DrawTextRowColor(txPos,"Spn POS: "..tostring(stSpawn.SPos))
  DrawTextRowColor(txPos,"Spn ANG: "..tostring(stSpawn.SAng))
end

function TOOL:DrawHUD()
  if(SERVER) then return end
  local adv   = self:GetClientNumber("advise") or 0
  local ply   = LocalPlayer()
  local Trace = ply:GetEyeTrace()
  if(adv ~= 0) then
    if(not Trace) then return end
    local trEnt   = Trace.Entity
    local scrH    = surface.ScreenHeight()
    local scrW    = surface.ScreenWidth()
    local model   = self:GetClientInfo("model")
    local nextx   = self:GetClientNumber("nextx") or 0
    local nexty   = self:GetClientNumber("nexty") or 0
    local nextz   = self:GetClientNumber("nextz") or 0
    local addinfo = self:GetClientNumber("addinfo") or 0
    local nextpic = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
    local nextyaw = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
    local nextrol = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
    local RadScal = gearasmlib.GetViewRadius(ply,Trace.HitPos)
    gearasmlib.PlyLoadKey(ply)
    if(trEnt and trEnt:IsValid() and gearasmlib.PlyLoadKey(ply,"SPEED")) then
      if(gearasmlib.IsOther(trEnt)) then return end
      local igntyp  = self:GetClientNumber("igntyp") or 0
      local orangtr = self:GetClientNumber("orangtr") or 0
      local rotpiv  = math.Clamp(self:GetClientNumber("rotpiv") or 0,-360,360)
      local trPos   = trEnt:GetPos()
      local trAng   = trEnt:GetAngles()
      local trModel = trEnt:GetModel()
      local stSpawn = gearasmlib.GetENTSpawn(trPos,trAng,trModel,rotpiv,model,igntyp,
                                             orangtr,Vector(nextx,nexty,nextz),
                                             Angle(nextpic,nextyaw,nextrol))
      if(not stSpawn) then return end
      local Op =  stSpawn.OPos:ToScreen()
      local Xs = (stSpawn.OPos + 15 * stSpawn.F):ToScreen()
      local Ys = (stSpawn.OPos + 15 * stSpawn.R):ToScreen()
      local Zs = (stSpawn.OPos + 15 * stSpawn.U):ToScreen()
      local Sp =  stSpawn.SPos:ToScreen()
      local Df = (stSpawn.SPos + 15 * stSpawn.DAng:Forward()):ToScreen()
      local Du = (stSpawn.SPos + 15 * stSpawn.DAng:Up()):ToScreen()
      local Tp =  stSpawn.TPos:ToScreen()
      local Tu = (stSpawn.TPos + 15 * stSpawn.TAng:Up()):ToScreen()
      -- Draw UCS
      DrawLineColor(Op,Xs,scrW,scrH,stDrawDyes.Red)
      DrawLineColor(Op,Ys,scrW,scrH,stDrawDyes.Green)
      DrawLineColor(Op,Zs,scrW,scrH,stDrawDyes.Blue)
      DrawLineColor(Tp,Tu,scrW,scrH,stDrawDyes.Yello)
      DrawLineColor(Tp,Op,scrW,scrH,stDrawDyes.Green)
      surface.DrawCircle(Op.x,Op.y,RadScal,stDrawDyes.Yello)
      surface.DrawCircle(Tp.x,Tp.y,RadScal,stDrawDyes.Green)
      -- Draw Spawn
      DrawLineColor(Op,Sp,scrW,scrH,stDrawDyes.Magen)
      DrawLineColor(Sp,Du,scrW,scrH,stDrawDyes.Cyan)
      DrawLineColor(Sp,Df,scrW,scrH,stDrawDyes.Red)
      surface.DrawCircle(Sp.x,Sp.y,RadScal,stDrawDyes.Magen)
      if(addinfo ~= 0) then
        DrawAdditionalInfo(stSpawn)
      end
    else
      local stSpawn  = gearasmlib.GetNORSpawn(Trace,model,Vector(nextx,nexty,nextz),
                                              Angle(nextpic,nextyaw,nextrol))
      if(not stSpawn) then return false end
      local addinfo = self:GetClientNumber("addinfo") or 0
      local Os = stSpawn.SPos:ToScreen()
      local Xs = (stSpawn.SPos + 15 * stSpawn.F):ToScreen()
      local Ys = (stSpawn.SPos + 15 * stSpawn.R):ToScreen()
      local Zs = (stSpawn.SPos + 15 * stSpawn.U):ToScreen()
      DrawLineColor(Os,Xs,scrW,scrH,stDrawDyes.Red)
      DrawLineColor(Os,Ys,scrW,scrH,stDrawDyes.Green)
      DrawLineColor(Os,Zs,scrW,scrH,stDrawDyes.Blue)
      surface.DrawCircle(Os.x,Os.y,RadScal,stDrawDyes.Yello)
      if(addinfo ~= 0) then
        DrawAdditionalInfo(stSpawn)
      end
    end
  end
end

function TOOL:DrawToolScreen(w, h)
  if(SERVER) then return end
  surface.SetTexture(txToolgunBackground)
  surface.SetDrawColor(stDrawDyes.Black)
  surface.DrawTexturedRect(0,0,w,h)
  surface.SetFont("Trebuchet24")
  local Trace = LocalPlayer():GetEyeTrace()
  local txPos = {x = 0, y = 0, w = 0, h = 0}
  if(not Trace) then
    DrawTextRowColor(txPos,"Trace status: Invalid",stDrawDyes.White)
    return
  end
  DrawTextRowColor(txPos,"Trace status: Valid",stDrawDyes.White)
  local model = self:GetClientInfo("model") or ""
  local hdRec = gearasmlib.CacheQueryPiece(model)  
  if(not hdRec) then
    DrawTextRowColor(txPos,"Holds Model: Invalid")
    return
  end
  DrawTextRowColor(txPos,"Holds Model: Valid")
  local NoAV  = "N/A"
  local stmode  = gearasmlib.GetCorrectID(self:GetClientInfo("stmode"),stSMode)
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
      gearasmlib.SetVector(trOrig,trRec.O)
      trRad = gearasmlib.RoundValue(trOrig:Length(),0.1)
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
        gearasmlib.SetVector(hdOrig,hdRec.O)
  local hdRad = gearasmlib.RoundValue(hdOrig:Length(),0.1)
  local Ratio = (trRad or 0) / hdRad
        X = hdOrig[cvX]
        X = gearasmlib.RoundValue(X,0.1)
        Y = hdOrig[cvY]
        Y = gearasmlib.RoundValue(Y,0.1)
        Z = hdOrig[cvZ]
        Z = gearasmlib.RoundValue(Z,0.1)
        hdOrig = "["..tostring(X) ..",".. tostring(Y)..","..tostring(Z).."]"
  DrawTextRowColor(txPos,"TM: "..(trModel or NoAV),stDrawDyes.Green)
  DrawTextRowColor(txPos,"TS: "..(trOrig or NoAV) .. ">" .. (trMesh or NoAV))
  DrawTextRowColor(txPos,"HM: "..(gearasmlib.GetModelFileName(model) or NoAV),stDrawDyes.Magen)
  DrawTextRowColor(txPos,"HS: "..(hdOrig or NoAV) .. ">" .. tostring(gearasmlib.RoundValue(hdRec.Mesh,0.01) or NoAV))
  DrawTextRowColor(txPos,"Ratio: "..gearasmlib.RoundValue(Ratio,0.01).." > "..(trRad or NoAV).."/"..hdRad,stDrawDyes.Yello)
  DrawTextRowColor(txPos,"Anc: "..self:GetClientInfo("anchor"),stDrawDyes.Anchr)
  DrawTextRowColor(txPos,"StackMod: "..stSMode[stmode],stDrawDyes.Red)
  DrawTextRowColor(txPos,tostring(os.date()),stDrawDyes.White)
end

function TOOL.BuildCPanel(CPanel)
  Header = CPanel:AddControl("Header", { Text        = "#Tool.gearassembly.Name",
                                         Description = "#Tool.gearassembly.desc" })
  local CurY = Header:GetTall() + 2

  local Combo         = {}
  Combo["Label"]      = "#Presets"
  Combo["MenuButton"] = "1"
  Combo["Folder"]     = "gearassembly"
  Combo["CVars"]      = {}
  Combo["CVars"][ 1]  = "gearassembly_mass"
  Combo["CVars"][ 2]  = "gearassembly_stmode"
  Combo["CVars"][ 3]  = "gearassembly_model"
  Combo["CVars"][ 4]  = "gearassembly_count"
  Combo["CVars"][ 4]  = "gearassembly_contyp"
  Combo["CVars"][ 5]  = "gearassembly_freeze"
  Combo["CVars"][ 6]  = "gearassembly_advise"
  Combo["CVars"][ 7]  = "gearassembly_igntyp"
  Combo["CVars"][ 8]  = "gearassembly_nextpic"
  Combo["CVars"][ 9]  = "gearassembly_nextyaw"
  Combo["CVars"][10]  = "gearassembly_nextrol"
  Combo["CVars"][11]  = "gearassembly_nextx"
  Combo["CVars"][12]  = "gearassembly_nexty"
  Combo["CVars"][13]  = "gearassembly_nextz"
  Combo["CVars"][14]  = "gearassembly_enghost"
  Combo["CVars"][15]  = "gearassembly_engravity"
  Combo["CVars"][14]  = "gearassembly_nocollide"
  Combo["CVars"][15]  = "gearassembly_forcelim"

  CPanel:AddControl("ComboBox",Combo)
  CurY = CurY + 25
  local Sorted  = gearasmlib.PanelQueryPieces()
  local stTable = gearasmlib.GetTableDefinition("PIECES")
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
          return self:SetTextStyleColor(stDrawDyes.Txtsk)
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
      gearasmlib.PrintInstance("GEARASSEMBLY: Model "
             .. Model
             .. " is not available in"
             .. " your system .. SKIPPING !")
    end
    Cnt = Cnt + 1
  end
  CPanel:AddItem(pTree)
  CurY = CurY + pTree:GetTall() + 2
  gearasmlib.PrintInstance("GEARASSEMBLY: Found #"..tostring(Cnt-1).." piece items.")

  -- http://wiki.garrysmod.com/page/Category:DComboBox
  local ConID = gearasmlib.GetCorrectID(GetConVarString("gearassembly_contyp"),stCType)
  local pConsType = vgui.Create("DComboBox")
        pConsType:SetPos(2, CurY)
        pConsType:SetTall(18)
        pConsType:SetValue("<"..stCType["ACT"]..">")
        CurY = CurY + pConsType:GetTall() + 2
  local Cnt = 1
  while(stCType[Cnt]) do
    local Val = stCType[Cnt]
    pConsType:AddChoice(Val.Name)
    pConsType.OnSelect = function(panel,index,value)
      RunConsoleCommand("gearassembly_contyp",index)
    end
    Cnt = Cnt + 1
  end
  pConsType:ChooseOptionID(ConID)
  CPanel:AddItem(pConsType)

  -- http://wiki.garrysmod.com/page/Category:DTextEntry
  local pText = vgui.Create("DTextEntry")
        pText:SetPos(2,300)
        pText:SetTall(18)
        pText:SetText(GetConVarString("gearassembly_bgskids") or
                      "Bodygroup IDs separated with commas > ENTER")
        pText.OnEnter = function(self)
          local sTX = self:GetValue() or ""
          RunConsoleCommand("gearassembly_bgskids",sTX)
        end
        CurY = CurY + pText:GetTall() + 2

  -- http://wiki.garrysmod.com/page/Category:DButton
  local pButton = vgui.Create("DButton")
        pButton:SetParent(CPanel)
        pButton:SetText("V Click to AUTOFILL Bgrp/Skin IDs from Trace V")
        pButton:SetPos(2,CurY)
        pButton:SetTall(18)
        pButton.DoClick = function()
          local sBG = gearasmlib.GetBodygroupTrace().."/"..gearasmlib.GetSkinTrace()
          pText:SetValue(sBG)
          RunConsoleCommand("gearassembly_bgskids",sBG)
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

  CPanel:AddControl("Button", {
            Label   = "V Reset Offset Values V",
            Command = "gearassembly_resetoffs",
            Text    = "Reset All Offsets" })

  CPanel:AddControl("Slider", {
            Label   = "Pivot rotation: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = "gearassembly_rotpiv"})

  CPanel:AddControl("Slider", {
            Label   = "End angle pivot: ",
            Type    = "Float",
            Min     = -360,
            Max     =  360,
            Command = "gearassembly_deltarot"})

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

  CPanel:AddControl("Slider", {
            Label   = "Force Limit: ",
            Type    = "Float",
            Min     = 0,
            Max     = 1000000,
            Command = "gearassembly_forcelim"})

  CPanel:AddControl("Checkbox", {
            Label   = "NoCollide new pieces to the anchor",
            Command = "gearassembly_nocollide"})

  CPanel:AddControl("Checkbox", {
            Label   = "Freeze pieces",
            Command = "gearassembly_freeze"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable pieces gravity",
            Command = "gearassembly_engravity"})

  CPanel:AddControl("Checkbox", {
            Label   = "Use origin angle from trace",
            Command = "gearassembly_orangtr"})

  CPanel:AddControl("Checkbox", {
            Label   = "Ignore gear type",
            Command = "gearassembly_igntyp"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable flat gear spawn",
            Command = "gearassembly_spwnflat"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable advisor",
            Command = "gearassembly_advise"})

  CPanel:AddControl("Checkbox", {
            Label   = "Enable ghosting",
            Command = "gearassembly_enghost"})
end

function TOOL:MakeGhostEntity(sModel,vPos,aAngle)
  -- Check for invalid model
  if(not util.IsValidModel(sModel)) then return end
  util.PrecacheModel(sModel)
  -- We do ghosting serverside in single player
  -- It's done clientside in multiplayer
  if(SERVER and not game.SinglePlayer()) then return end
  if(CLIENT and     game.SinglePlayer()) then return end
  -- Release the old ghost entity
  self:ReleaseGhostEntity()
  if(CLIENT) then
    self.GhostEntity = ents.CreateClientProp(sModel)
  else
    if(util.IsValidRagdoll(sModel)) then
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
  self.GhostEntity:SetModel(sModel)
  self.GhostEntity:SetPos(vPos)
  self.GhostEntity:SetAngles(aAngle)
  self.GhostEntity:Spawn()
  self.GhostEntity:SetSolid(SOLID_VPHYSICS);
  self.GhostEntity:SetMoveType(MOVETYPE_NONE)
  self.GhostEntity:SetNotSolid(true);
  self.GhostEntity:SetRenderMode(RENDERMODE_TRANSALPHA)
  self.GhostEntity:SetColor(stDrawDyes.Ghost)
end

function TOOL:UpdateGhost(oEnt, oPly)
  if not oEnt then return end
  if not oEnt:IsValid() then return end
  local Trace = util.TraceLine(util.GetPlayerTrace(oPly))
  if(not Trace) then return end
  local trEnt = Trace.Entity
  oEnt:SetNoDraw(true)
  gearasmlib.PlyLoadKey(oPly)
  if(trEnt and trEnt:IsValid() and gearasmlib.PlyLoadKey(oPly,"SPEED")) then
    if(gearasmlib.IsOther(trEnt)) then return end
    local trRec = gearasmlib.CacheQueryPiece(trEnt:GetModel())
    if(trRec) then
      local nextx   = self:GetClientNumber("nextx") or 0
      local nexty   = self:GetClientNumber("nexty") or 0
      local nextz   = self:GetClientNumber("nextz") or 0
      local model   = self:GetClientInfo("model") or ""
      local igntyp  = self:GetClientNumber("igntyp") or 0
      local orangtr = self:GetClientNumber("orangtr") or 0
      local rotpiv  = math.Clamp(self:GetClientNumber("rotpiv") or 0,-360,360)
      local nextpic = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
      local nextyaw = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
      local nextrol = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
      local trPos   = trEnt:GetPos()
      local trAng   = trEnt:GetAngles()
      local trModel = trEnt:GetModel()
      local stSpawn = gearasmlib.GetENTSpawn(trPos,trAng,trModel,rotpiv,model,igntyp,
                                             orangtr,Vector(nextx,nexty,nextz),
                                             Angle(nextpic,nextyaw,nextrol))
      if(not stSpawn) then return end
      oEnt:SetNoDraw(false)
      oEnt:SetAngles(stSpawn.SAng)
      gearasmlib.SetMCWorld(oEnt,stSpawn.HRec.M,stSpawn.SPos)
    end
  else
    local model   = self:GetClientInfo("model") or ""
    local nextx   = self:GetClientNumber("nextx") or 0
    local nexty   = self:GetClientNumber("nexty") or 0
    local nextz   = self:GetClientNumber("nextz") or 0
    local nextpic = math.Clamp(self:GetClientNumber("nextpic") or 0,-360,360)
    local nextyaw = math.Clamp(self:GetClientNumber("nextyaw") or 0,-360,360)
    local nextrol = math.Clamp(self:GetClientNumber("nextrol") or 0,-360,360)
    local stSpawn = gearasmlib.GetNORSpawn(Trace,model,Vector(nextx,nexty,nextz),
                                           Angle(nextpic,nextyaw,nextrol))
    if(not stSpawn) then return end
    local spwnflat  = self:GetClientNumber("spwnflat") or 0
    oEnt:SetNoDraw(false)
    oEnt:SetAngles(stSpawn.SAng)
    stSpawn.SPos:Add(gearasmlib.GetCustomAngBBZ(oEnt,stSpawn.HRec.A,spwnflat) * Trace.HitNormal)
    gearasmlib.SetMCWorld(oEnt,stSpawn.HRec.M,stSpawn.SPos)
    return
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
      self:MakeGhostEntity(model, VEC_ZERO, ANG_ZERO)
    end
    self:UpdateGhost(self.GhostEntity, self:GetOwner())
  else
    self:ReleaseGhostEntity()
    if(self.GhostEntity and self.GhostEntity:IsValid()) then
      self.GhostEntity:Remove()
    end
  end
end
