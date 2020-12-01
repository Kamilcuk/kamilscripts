
" vim: nowrap

" From:
" https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
function! kc#xterm256colornames#load() abort
	hi! x016_Grey0             ctermfg=16  guifg=#000000 "rgb=0,0,0
	hi! x017_NavyBlue          ctermfg=17  guifg=#00005f "rgb=0,0,95
	hi! x018_DarkBlue          ctermfg=18  guifg=#000087 "rgb=0,0,135
	hi! x019_Blue3             ctermfg=19  guifg=#0000af "rgb=0,0,175
	hi! x020_Blue3             ctermfg=20  guifg=#0000d7 "rgb=0,0,215
	hi! x021_Blue1             ctermfg=21  guifg=#0000ff "rgb=0,0,255
	hi! x022_DarkGreen         ctermfg=22  guifg=#005f00 "rgb=0,95,0
	hi! x023_DeepSkyBlue4      ctermfg=23  guifg=#005f5f "rgb=0,95,95
	hi! x024_DeepSkyBlue4      ctermfg=24  guifg=#005f87 "rgb=0,95,135
	hi! x025_DeepSkyBlue4      ctermfg=25  guifg=#005faf "rgb=0,95,175
	hi! x026_DodgerBlue3       ctermfg=26  guifg=#005fd7 "rgb=0,95,215
	hi! x027_DodgerBlue2       ctermfg=27  guifg=#005fff "rgb=0,95,255
	hi! x028_Green4            ctermfg=28  guifg=#008700 "rgb=0,135,0
	hi! x029_SpringGreen4      ctermfg=29  guifg=#00875f "rgb=0,135,95
	hi! x030_Turquoise4        ctermfg=30  guifg=#008787 "rgb=0,135,135
	hi! x031_DeepSkyBlue3      ctermfg=31  guifg=#0087af "rgb=0,135,175
	hi! x032_DeepSkyBlue3      ctermfg=32  guifg=#0087d7 "rgb=0,135,215
	hi! x033_DodgerBlue1       ctermfg=33  guifg=#0087ff "rgb=0,135,255
	hi! x034_Green3            ctermfg=34  guifg=#00af00 "rgb=0,175,0
	hi! x035_SpringGreen3      ctermfg=35  guifg=#00af5f "rgb=0,175,95
	hi! x036_DarkCyan          ctermfg=36  guifg=#00af87 "rgb=0,175,135
	hi! x037_LightSeaGreen     ctermfg=37  guifg=#00afaf "rgb=0,175,175
	hi! x038_DeepSkyBlue2      ctermfg=38  guifg=#00afd7 "rgb=0,175,215
	hi! x039_DeepSkyBlue1      ctermfg=39  guifg=#00afff "rgb=0,175,255
	hi! x040_Green3            ctermfg=40  guifg=#00d700 "rgb=0,215,0
	hi! x041_SpringGreen3      ctermfg=41  guifg=#00d75f "rgb=0,215,95
	hi! x042_SpringGreen2      ctermfg=42  guifg=#00d787 "rgb=0,215,135
	hi! x043_Cyan3             ctermfg=43  guifg=#00d7af "rgb=0,215,175
	hi! x044_DarkTurquoise     ctermfg=44  guifg=#00d7d7 "rgb=0,215,215
	hi! x045_Turquoise2        ctermfg=45  guifg=#00d7ff "rgb=0,215,255
	hi! x046_Green1            ctermfg=46  guifg=#00ff00 "rgb=0,255,0
	hi! x047_SpringGreen2      ctermfg=47  guifg=#00ff5f "rgb=0,255,95
	hi! x048_SpringGreen1      ctermfg=48  guifg=#00ff87 "rgb=0,255,135
	hi! x049_MediumSpringGreen ctermfg=49  guifg=#00ffaf "rgb=0,255,175
	hi! x050_Cyan2             ctermfg=50  guifg=#00ffd7 "rgb=0,255,215
	hi! x051_Cyan1             ctermfg=51  guifg=#00ffff "rgb=0,255,255
	hi! x052_DarkRed           ctermfg=52  guifg=#5f0000 "rgb=95,0,0
	hi! x053_DeepPink4         ctermfg=53  guifg=#5f005f "rgb=95,0,95
	hi! x054_Purple4           ctermfg=54  guifg=#5f0087 "rgb=95,0,135
	hi! x055_Purple4           ctermfg=55  guifg=#5f00af "rgb=95,0,175
	hi! x056_Purple3           ctermfg=56  guifg=#5f00d7 "rgb=95,0,215
	hi! x057_BlueViolet        ctermfg=57  guifg=#5f00ff "rgb=95,0,255
	hi! x058_Orange4           ctermfg=58  guifg=#5f5f00 "rgb=95,95,0
	hi! x059_Grey37            ctermfg=59  guifg=#5f5f5f "rgb=95,95,95
	hi! x060_MediumPurple4     ctermfg=60  guifg=#5f5f87 "rgb=95,95,135
	hi! x061_SlateBlue3        ctermfg=61  guifg=#5f5faf "rgb=95,95,175
	hi! x062_SlateBlue3        ctermfg=62  guifg=#5f5fd7 "rgb=95,95,215
	hi! x063_RoyalBlue1        ctermfg=63  guifg=#5f5fff "rgb=95,95,255
	hi! x064_Chartreuse4       ctermfg=64  guifg=#5f8700 "rgb=95,135,0
	hi! x065_DarkSeaGreen4     ctermfg=65  guifg=#5f875f "rgb=95,135,95
	hi! x066_PaleTurquoise4    ctermfg=66  guifg=#5f8787 "rgb=95,135,135
	hi! x067_SteelBlue         ctermfg=67  guifg=#5f87af "rgb=95,135,175
	hi! x068_SteelBlue3        ctermfg=68  guifg=#5f87d7 "rgb=95,135,215
	hi! x069_CornflowerBlue    ctermfg=69  guifg=#5f87ff "rgb=95,135,255
	hi! x070_Chartreuse3       ctermfg=70  guifg=#5faf00 "rgb=95,175,0
	hi! x071_DarkSeaGreen4     ctermfg=71  guifg=#5faf5f "rgb=95,175,95
	hi! x072_CadetBlue         ctermfg=72  guifg=#5faf87 "rgb=95,175,135
	hi! x073_CadetBlue         ctermfg=73  guifg=#5fafaf "rgb=95,175,175
	hi! x074_SkyBlue3          ctermfg=74  guifg=#5fafd7 "rgb=95,175,215
	hi! x075_SteelBlue1        ctermfg=75  guifg=#5fafff "rgb=95,175,255
	hi! x076_Chartreuse3       ctermfg=76  guifg=#5fd700 "rgb=95,215,0
	hi! x077_PaleGreen3        ctermfg=77  guifg=#5fd75f "rgb=95,215,95
	hi! x078_SeaGreen3         ctermfg=78  guifg=#5fd787 "rgb=95,215,135
	hi! x079_Aquamarine3       ctermfg=79  guifg=#5fd7af "rgb=95,215,175
	hi! x080_MediumTurquoise   ctermfg=80  guifg=#5fd7d7 "rgb=95,215,215
	hi! x081_SteelBlue1        ctermfg=81  guifg=#5fd7ff "rgb=95,215,255
	hi! x082_Chartreuse2       ctermfg=82  guifg=#5fff00 "rgb=95,255,0
	hi! x083_SeaGreen2         ctermfg=83  guifg=#5fff5f "rgb=95,255,95
	hi! x084_SeaGreen1         ctermfg=84  guifg=#5fff87 "rgb=95,255,135
	hi! x085_SeaGreen1         ctermfg=85  guifg=#5fffaf "rgb=95,255,175
	hi! x086_Aquamarine1       ctermfg=86  guifg=#5fffd7 "rgb=95,255,215
	hi! x087_DarkSlateGray2    ctermfg=87  guifg=#5fffff "rgb=95,255,255
	hi! x088_DarkRed           ctermfg=88  guifg=#870000 "rgb=135,0,0
	hi! x089_DeepPink4         ctermfg=89  guifg=#87005f "rgb=135,0,95
	hi! x090_DarkMagenta       ctermfg=90  guifg=#870087 "rgb=135,0,135
	hi! x091_DarkMagenta       ctermfg=91  guifg=#8700af "rgb=135,0,175
	hi! x092_DarkViolet        ctermfg=92  guifg=#8700d7 "rgb=135,0,215
	hi! x093_Purple            ctermfg=93  guifg=#8700ff "rgb=135,0,255
	hi! x094_Orange4           ctermfg=94  guifg=#875f00 "rgb=135,95,0
	hi! x095_LightPink4        ctermfg=95  guifg=#875f5f "rgb=135,95,95
	hi! x096_Plum4             ctermfg=96  guifg=#875f87 "rgb=135,95,135
	hi! x097_MediumPurple3     ctermfg=97  guifg=#875faf "rgb=135,95,175
	hi! x098_MediumPurple3     ctermfg=98  guifg=#875fd7 "rgb=135,95,215
	hi! x099_SlateBlue1        ctermfg=99  guifg=#875fff "rgb=135,95,255
	hi! x100_Yellow4           ctermfg=100 guifg=#878700 "rgb=135,135,0
	hi! x101_Wheat4            ctermfg=101 guifg=#87875f "rgb=135,135,95
	hi! x102_Grey53            ctermfg=102 guifg=#878787 "rgb=135,135,135
	hi! x103_LightSlateGrey    ctermfg=103 guifg=#8787af "rgb=135,135,175
	hi! x104_MediumPurple      ctermfg=104 guifg=#8787d7 "rgb=135,135,215
	hi! x105_LightSlateBlue    ctermfg=105 guifg=#8787ff "rgb=135,135,255
	hi! x106_Yellow4           ctermfg=106 guifg=#87af00 "rgb=135,175,0
	hi! x107_DarkOliveGreen3   ctermfg=107 guifg=#87af5f "rgb=135,175,95
	hi! x108_DarkSeaGreen      ctermfg=108 guifg=#87af87 "rgb=135,175,135
	hi! x109_LightSkyBlue3     ctermfg=109 guifg=#87afaf "rgb=135,175,175
	hi! x110_LightSkyBlue3     ctermfg=110 guifg=#87afd7 "rgb=135,175,215
	hi! x111_SkyBlue2          ctermfg=111 guifg=#87afff "rgb=135,175,255
	hi! x112_Chartreuse2       ctermfg=112 guifg=#87d700 "rgb=135,215,0
	hi! x113_DarkOliveGreen3   ctermfg=113 guifg=#87d75f "rgb=135,215,95
	hi! x114_PaleGreen3        ctermfg=114 guifg=#87d787 "rgb=135,215,135
	hi! x115_DarkSeaGreen3     ctermfg=115 guifg=#87d7af "rgb=135,215,175
	hi! x116_DarkSlateGray3    ctermfg=116 guifg=#87d7d7 "rgb=135,215,215
	hi! x117_SkyBlue1          ctermfg=117 guifg=#87d7ff "rgb=135,215,255
	hi! x118_Chartreuse1       ctermfg=118 guifg=#87ff00 "rgb=135,255,0
	hi! x119_LightGreen        ctermfg=119 guifg=#87ff5f "rgb=135,255,95
	hi! x120_LightGreen        ctermfg=120 guifg=#87ff87 "rgb=135,255,135
	hi! x121_PaleGreen1        ctermfg=121 guifg=#87ffaf "rgb=135,255,175
	hi! x122_Aquamarine1       ctermfg=122 guifg=#87ffd7 "rgb=135,255,215
	hi! x123_DarkSlateGray1    ctermfg=123 guifg=#87ffff "rgb=135,255,255
	hi! x124_Red3              ctermfg=124 guifg=#af0000 "rgb=175,0,0
	hi! x125_DeepPink4         ctermfg=125 guifg=#af005f "rgb=175,0,95
	hi! x126_MediumVioletRed   ctermfg=126 guifg=#af0087 "rgb=175,0,135
	hi! x127_Magenta3          ctermfg=127 guifg=#af00af "rgb=175,0,175
	hi! x128_DarkViolet        ctermfg=128 guifg=#af00d7 "rgb=175,0,215
	hi! x129_Purple            ctermfg=129 guifg=#af00ff "rgb=175,0,255
	hi! x130_DarkOrange3       ctermfg=130 guifg=#af5f00 "rgb=175,95,0
	hi! x131_IndianRed         ctermfg=131 guifg=#af5f5f "rgb=175,95,95
	hi! x132_HotPink3          ctermfg=132 guifg=#af5f87 "rgb=175,95,135
	hi! x133_MediumOrchid3     ctermfg=133 guifg=#af5faf "rgb=175,95,175
	hi! x134_MediumOrchid      ctermfg=134 guifg=#af5fd7 "rgb=175,95,215
	hi! x135_MediumPurple2     ctermfg=135 guifg=#af5fff "rgb=175,95,255
	hi! x136_DarkGoldenrod     ctermfg=136 guifg=#af8700 "rgb=175,135,0
	hi! x137_LightSalmon3      ctermfg=137 guifg=#af875f "rgb=175,135,95
	hi! x138_RosyBrown         ctermfg=138 guifg=#af8787 "rgb=175,135,135
	hi! x139_Grey63            ctermfg=139 guifg=#af87af "rgb=175,135,175
	hi! x140_MediumPurple2     ctermfg=140 guifg=#af87d7 "rgb=175,135,215
	hi! x141_MediumPurple1     ctermfg=141 guifg=#af87ff "rgb=175,135,255
	hi! x142_Gold3             ctermfg=142 guifg=#afaf00 "rgb=175,175,0
	hi! x143_DarkKhaki         ctermfg=143 guifg=#afaf5f "rgb=175,175,95
	hi! x144_NavajoWhite3      ctermfg=144 guifg=#afaf87 "rgb=175,175,135
	hi! x145_Grey69            ctermfg=145 guifg=#afafaf "rgb=175,175,175
	hi! x146_LightSteelBlue3   ctermfg=146 guifg=#afafd7 "rgb=175,175,215
	hi! x147_LightSteelBlue    ctermfg=147 guifg=#afafff "rgb=175,175,255
	hi! x148_Yellow3           ctermfg=148 guifg=#afd700 "rgb=175,215,0
	hi! x149_DarkOliveGreen3   ctermfg=149 guifg=#afd75f "rgb=175,215,95
	hi! x150_DarkSeaGreen3     ctermfg=150 guifg=#afd787 "rgb=175,215,135
	hi! x151_DarkSeaGreen2     ctermfg=151 guifg=#afd7af "rgb=175,215,175
	hi! x152_LightCyan3        ctermfg=152 guifg=#afd7d7 "rgb=175,215,215
	hi! x153_LightSkyBlue1     ctermfg=153 guifg=#afd7ff "rgb=175,215,255
	hi! x154_GreenYellow       ctermfg=154 guifg=#afff00 "rgb=175,255,0
	hi! x155_DarkOliveGreen2   ctermfg=155 guifg=#afff5f "rgb=175,255,95
	hi! x156_PaleGreen1        ctermfg=156 guifg=#afff87 "rgb=175,255,135
	hi! x157_DarkSeaGreen2     ctermfg=157 guifg=#afffaf "rgb=175,255,175
	hi! x158_DarkSeaGreen1     ctermfg=158 guifg=#afffd7 "rgb=175,255,215
	hi! x159_PaleTurquoise1    ctermfg=159 guifg=#afffff "rgb=175,255,255
	hi! x160_Red3              ctermfg=160 guifg=#d70000 "rgb=215,0,0
	hi! x161_DeepPink3         ctermfg=161 guifg=#d7005f "rgb=215,0,95
	hi! x162_DeepPink3         ctermfg=162 guifg=#d70087 "rgb=215,0,135
	hi! x163_Magenta3          ctermfg=163 guifg=#d700af "rgb=215,0,175
	hi! x164_Magenta3          ctermfg=164 guifg=#d700d7 "rgb=215,0,215
	hi! x165_Magenta2          ctermfg=165 guifg=#d700ff "rgb=215,0,255
	hi! x166_DarkOrange3       ctermfg=166 guifg=#d75f00 "rgb=215,95,0
	hi! x167_IndianRed         ctermfg=167 guifg=#d75f5f "rgb=215,95,95
	hi! x168_HotPink3          ctermfg=168 guifg=#d75f87 "rgb=215,95,135
	hi! x169_HotPink2          ctermfg=169 guifg=#d75faf "rgb=215,95,175
	hi! x170_Orchid            ctermfg=170 guifg=#d75fd7 "rgb=215,95,215
	hi! x171_MediumOrchid1     ctermfg=171 guifg=#d75fff "rgb=215,95,255
	hi! x172_Orange3           ctermfg=172 guifg=#d78700 "rgb=215,135,0
	hi! x173_LightSalmon3      ctermfg=173 guifg=#d7875f "rgb=215,135,95
	hi! x174_LightPink3        ctermfg=174 guifg=#d78787 "rgb=215,135,135
	hi! x175_Pink3             ctermfg=175 guifg=#d787af "rgb=215,135,175
	hi! x176_Plum3             ctermfg=176 guifg=#d787d7 "rgb=215,135,215
	hi! x177_Violet            ctermfg=177 guifg=#d787ff "rgb=215,135,255
	hi! x178_Gold3             ctermfg=178 guifg=#d7af00 "rgb=215,175,0
	hi! x179_LightGoldenrod3   ctermfg=179 guifg=#d7af5f "rgb=215,175,95
	hi! x180_Tan               ctermfg=180 guifg=#d7af87 "rgb=215,175,135
	hi! x181_MistyRose3        ctermfg=181 guifg=#d7afaf "rgb=215,175,175
	hi! x182_Thistle3          ctermfg=182 guifg=#d7afd7 "rgb=215,175,215
	hi! x183_Plum2             ctermfg=183 guifg=#d7afff "rgb=215,175,255
	hi! x184_Yellow3           ctermfg=184 guifg=#d7d700 "rgb=215,215,0
	hi! x185_Khaki3            ctermfg=185 guifg=#d7d75f "rgb=215,215,95
	hi! x186_LightGoldenrod2   ctermfg=186 guifg=#d7d787 "rgb=215,215,135
	hi! x187_LightYellow3      ctermfg=187 guifg=#d7d7af "rgb=215,215,175
	hi! x188_Grey84            ctermfg=188 guifg=#d7d7d7 "rgb=215,215,215
	hi! x189_LightSteelBlue1   ctermfg=189 guifg=#d7d7ff "rgb=215,215,255
	hi! x190_Yellow2           ctermfg=190 guifg=#d7ff00 "rgb=215,255,0
	hi! x191_DarkOliveGreen1   ctermfg=191 guifg=#d7ff5f "rgb=215,255,95
	hi! x192_DarkOliveGreen1   ctermfg=192 guifg=#d7ff87 "rgb=215,255,135
	hi! x193_DarkSeaGreen1     ctermfg=193 guifg=#d7ffaf "rgb=215,255,175
	hi! x194_Honeydew2         ctermfg=194 guifg=#d7ffd7 "rgb=215,255,215
	hi! x195_LightCyan1        ctermfg=195 guifg=#d7ffff "rgb=215,255,255
	hi! x196_Red1              ctermfg=196 guifg=#ff0000 "rgb=255,0,0
	hi! x197_DeepPink2         ctermfg=197 guifg=#ff005f "rgb=255,0,95
	hi! x198_DeepPink1         ctermfg=198 guifg=#ff0087 "rgb=255,0,135
	hi! x199_DeepPink1         ctermfg=199 guifg=#ff00af "rgb=255,0,175
	hi! x200_Magenta2          ctermfg=200 guifg=#ff00d7 "rgb=255,0,215
	hi! x201_Magenta1          ctermfg=201 guifg=#ff00ff "rgb=255,0,255
	hi! x202_OrangeRed1        ctermfg=202 guifg=#ff5f00 "rgb=255,95,0
	hi! x203_IndianRed1        ctermfg=203 guifg=#ff5f5f "rgb=255,95,95
	hi! x204_IndianRed1        ctermfg=204 guifg=#ff5f87 "rgb=255,95,135
	hi! x205_HotPink           ctermfg=205 guifg=#ff5faf "rgb=255,95,175
	hi! x206_HotPink           ctermfg=206 guifg=#ff5fd7 "rgb=255,95,215
	hi! x207_MediumOrchid1     ctermfg=207 guifg=#ff5fff "rgb=255,95,255
	hi! x208_DarkOrange        ctermfg=208 guifg=#ff8700 "rgb=255,135,0
	hi! x209_Salmon1           ctermfg=209 guifg=#ff875f "rgb=255,135,95
	hi! x210_LightCoral        ctermfg=210 guifg=#ff8787 "rgb=255,135,135
	hi! x211_PaleVioletRed1    ctermfg=211 guifg=#ff87af "rgb=255,135,175
	hi! x212_Orchid2           ctermfg=212 guifg=#ff87d7 "rgb=255,135,215
	hi! x213_Orchid1           ctermfg=213 guifg=#ff87ff "rgb=255,135,255
	hi! x214_Orange1           ctermfg=214 guifg=#ffaf00 "rgb=255,175,0
	hi! x215_SandyBrown        ctermfg=215 guifg=#ffaf5f "rgb=255,175,95
	hi! x216_LightSalmon1      ctermfg=216 guifg=#ffaf87 "rgb=255,175,135
	hi! x217_LightPink1        ctermfg=217 guifg=#ffafaf "rgb=255,175,175
	hi! x218_Pink1             ctermfg=218 guifg=#ffafd7 "rgb=255,175,215
	hi! x219_Plum1             ctermfg=219 guifg=#ffafff "rgb=255,175,255
	hi! x220_Gold1             ctermfg=220 guifg=#ffd700 "rgb=255,215,0
	hi! x221_LightGoldenrod2   ctermfg=221 guifg=#ffd75f "rgb=255,215,95
	hi! x222_LightGoldenrod2   ctermfg=222 guifg=#ffd787 "rgb=255,215,135
	hi! x223_NavajoWhite1      ctermfg=223 guifg=#ffd7af "rgb=255,215,175
	hi! x224_MistyRose1        ctermfg=224 guifg=#ffd7d7 "rgb=255,215,215
	hi! x225_Thistle1          ctermfg=225 guifg=#ffd7ff "rgb=255,215,255
	hi! x226_Yellow1           ctermfg=226 guifg=#ffff00 "rgb=255,255,0
	hi! x227_LightGoldenrod1   ctermfg=227 guifg=#ffff5f "rgb=255,255,95
	hi! x228_Khaki1            ctermfg=228 guifg=#ffff87 "rgb=255,255,135
	hi! x229_Wheat1            ctermfg=229 guifg=#ffffaf "rgb=255,255,175
	hi! x230_Cornsilk1         ctermfg=230 guifg=#ffffd7 "rgb=255,255,215
	hi! x231_Grey100           ctermfg=231 guifg=#ffffff "rgb=255,255,255
	hi! x232_Grey3             ctermfg=232 guifg=#080808 "rgb=8,8,8
	hi! x233_Grey7             ctermfg=233 guifg=#121212 "rgb=18,18,18
	hi! x234_Grey11            ctermfg=234 guifg=#1c1c1c "rgb=28,28,28
	hi! x235_Grey15            ctermfg=235 guifg=#262626 "rgb=38,38,38
	hi! x236_Grey19            ctermfg=236 guifg=#303030 "rgb=48,48,48
	hi! x237_Grey23            ctermfg=237 guifg=#3a3a3a "rgb=58,58,58
	hi! x238_Grey27            ctermfg=238 guifg=#444444 "rgb=68,68,68
	hi! x239_Grey30            ctermfg=239 guifg=#4e4e4e "rgb=78,78,78
	hi! x240_Grey35            ctermfg=240 guifg=#585858 "rgb=88,88,88
	hi! x241_Grey39            ctermfg=241 guifg=#626262 "rgb=98,98,98
	hi! x242_Grey42            ctermfg=242 guifg=#6c6c6c "rgb=108,108,108
	hi! x243_Grey46            ctermfg=243 guifg=#767676 "rgb=118,118,118
	hi! x244_Grey50            ctermfg=244 guifg=#808080 "rgb=128,128,128
	hi! x245_Grey54            ctermfg=245 guifg=#8a8a8a "rgb=138,138,138
	hi! x246_Grey58            ctermfg=246 guifg=#949494 "rgb=148,148,148
	hi! x247_Grey62            ctermfg=247 guifg=#9e9e9e "rgb=158,158,158
	hi! x248_Grey66            ctermfg=248 guifg=#a8a8a8 "rgb=168,168,168
	hi! x249_Grey70            ctermfg=249 guifg=#b2b2b2 "rgb=178,178,178
	hi! x250_Grey74            ctermfg=250 guifg=#bcbcbc "rgb=188,188,188
	hi! x251_Grey78            ctermfg=251 guifg=#c6c6c6 "rgb=198,198,198
	hi! x252_Grey82            ctermfg=252 guifg=#d0d0d0 "rgb=208,208,208
	hi! x253_Grey85            ctermfg=253 guifg=#dadada "rgb=218,218,218
	hi! x254_Grey89            ctermfg=254 guifg=#e4e4e4 "rgb=228,228,228
	hi! x255_Grey93            ctermfg=255 guifg=#eeeeee "rgb=238,238,238
endfunction

function! kc#xterm256colornames#display() abort
	let num = 255
	while num >= 0
		exec 'hi col_'.num.' ctermbg='.num.' ctermfg=white'
		exec 'syn match col_'.num.' "ctermbg='.num.':...." containedIn=ALL'
		call append(0, 'ctermbg='.num.':....')
		let num = num - 1
	endwhile
endfunction

function kc#xterm256colornames#colorizer() abort
	" https://github.com/chrisbra/Colorizer/blob/master/autoload/Colorizer.vim#L1474
	"if !exists('g:colorizer_custom_colors')
	"	let g:colorizer_custom_colors = {}
	"endif
	" Doesn't work, dunno why
	let g:colorizer_custom_colors = {
	\ 'x016_Grey0':            '#000000',
	\ 'x017_NavyBlue':         '#00005f',
	\ 'x018_DarkBlue':         '#000087',
	\ 'x019_Blue3':            '#0000af',
	\ 'x020_Blue3':            '#0000d7',
	\ 'x021_Blue1':            '#0000ff',
	\ 'x022_DarkGreen':        '#005f00',
	\ 'x023_DeepSkyBlue4':     '#005f5f',
	\ 'x024_DeepSkyBlue4':     '#005f87',
	\ 'x025_DeepSkyBlue4':     '#005faf',
	\ 'x026_DodgerBlue3':      '#005fd7',
	\ 'x027_DodgerBlue2':      '#005fff',
	\ 'x028_Green4':           '#008700',
	\ 'x029_SpringGreen4':     '#00875f',
	\ 'x030_Turquoise4':       '#008787',
	\ 'x031_DeepSkyBlue3':     '#0087af',
	\ 'x032_DeepSkyBlue3':     '#0087d7',
	\ 'x033_DodgerBlue1':      '#0087ff',
	\ 'x034_Green3':           '#00af00',
	\ 'x035_SpringGreen3':     '#00af5f',
	\ 'x036_DarkCyan':         '#00af87',
	\ 'x037_LightSeaGreen':    '#00afaf',
	\ 'x038_DeepSkyBlue2':     '#00afd7',
	\ 'x039_DeepSkyBlue1':     '#00afff',
	\ 'x040_Green3':           '#00d700',
	\ 'x041_SpringGreen3':     '#00d75f',
	\ 'x042_SpringGreen2':     '#00d787',
	\ 'x043_Cyan3':            '#00d7af',
	\ 'x044_DarkTurquoise':    '#00d7d7',
	\ 'x045_Turquoise2':       '#00d7ff',
	\ 'x046_Green1':           '#00ff00',
	\ 'x047_SpringGreen2':     '#00ff5f',
	\ 'x048_SpringGreen1':     '#00ff87',
	\ 'x049_MediumSpringGreen':'#00ffaf',
	\ 'x050_Cyan2':            '#00ffd7',
	\ 'x051_Cyan1':            '#00ffff',
	\ 'x052_DarkRed':          '#5f0000',
	\ 'x053_DeepPink4':        '#5f005f',
	\ 'x054_Purple4':          '#5f0087',
	\ 'x055_Purple4':          '#5f00af',
	\ 'x056_Purple3':          '#5f00d7',
	\ 'x057_BlueViolet':       '#5f00ff',
	\ 'x058_Orange4':          '#5f5f00',
	\ 'x059_Grey37':           '#5f5f5f',
	\ 'x060_MediumPurple4':    '#5f5f87',
	\ 'x061_SlateBlue3':       '#5f5faf',
	\ 'x062_SlateBlue3':       '#5f5fd7',
	\ 'x063_RoyalBlue1':       '#5f5fff',
	\ 'x064_Chartreuse4':      '#5f8700',
	\ 'x065_DarkSeaGreen4':    '#5f875f',
	\ 'x066_PaleTurquoise4':   '#5f8787',
	\ 'x067_SteelBlue':        '#5f87af',
	\ 'x068_SteelBlue3':       '#5f87d7',
	\ 'x069_CornflowerBlue':   '#5f87ff',
	\ 'x070_Chartreuse3':      '#5faf00',
	\ 'x071_DarkSeaGreen4':    '#5faf5f',
	\ 'x072_CadetBlue':        '#5faf87',
	\ 'x073_CadetBlue':        '#5fafaf',
	\ 'x074_SkyBlue3':         '#5fafd7',
	\ 'x075_SteelBlue1':       '#5fafff',
	\ 'x076_Chartreuse3':      '#5fd700',
	\ 'x077_PaleGreen3':       '#5fd75f',
	\ 'x078_SeaGreen3':        '#5fd787',
	\ 'x079_Aquamarine3':      '#5fd7af',
	\ 'x080_MediumTurquoise':  '#5fd7d7',
	\ 'x081_SteelBlue1':       '#5fd7ff',
	\ 'x082_Chartreuse2':      '#5fff00',
	\ 'x083_SeaGreen2':        '#5fff5f',
	\ 'x084_SeaGreen1':        '#5fff87',
	\ 'x085_SeaGreen1':        '#5fffaf',
	\ 'x086_Aquamarine1':      '#5fffd7',
	\ 'x087_DarkSlateGray2':   '#5fffff',
	\ 'x088_DarkRed':          '#870000',
	\ 'x089_DeepPink4':        '#87005f',
	\ 'x090_DarkMagenta':      '#870087',
	\ 'x091_DarkMagenta':      '#8700af',
	\ 'x092_DarkViolet':       '#8700d7',
	\ 'x093_Purple':           '#8700ff',
	\ 'x094_Orange4':          '#875f00',
	\ 'x095_LightPink4':       '#875f5f',
	\ 'x096_Plum4':            '#875f87',
	\ 'x097_MediumPurple3':    '#875faf',
	\ 'x098_MediumPurple3':    '#875fd7',
	\ 'x099_SlateBlue1':       '#875fff',
	\ 'x100_Yellow4':          '#878700',
	\ 'x101_Wheat4':           '#87875f',
	\ 'x102_Grey53':           '#878787',
	\ 'x103_LightSlateGrey':   '#8787af',
	\ 'x104_MediumPurple':     '#8787d7',
	\ 'x105_LightSlateBlue':   '#8787ff',
	\ 'x106_Yellow4':          '#87af00',
	\ 'x107_DarkOliveGreen3':  '#87af5f',
	\ 'x108_DarkSeaGreen':     '#87af87',
	\ 'x109_LightSkyBlue3':    '#87afaf',
	\ 'x110_LightSkyBlue3':    '#87afd7',
	\ 'x111_SkyBlue2':         '#87afff',
	\ 'x112_Chartreuse2':      '#87d700',
	\ 'x113_DarkOliveGreen3':  '#87d75f',
	\ 'x114_PaleGreen3':       '#87d787',
	\ 'x115_DarkSeaGreen3':    '#87d7af',
	\ 'x116_DarkSlateGray3':   '#87d7d7',
	\ 'x117_SkyBlue1':         '#87d7ff',
	\ 'x118_Chartreuse1':      '#87ff00',
	\ 'x119_LightGreen':       '#87ff5f',
	\ 'x120_LightGreen':       '#87ff87',
	\ 'x121_PaleGreen1':       '#87ffaf',
	\ 'x122_Aquamarine1':      '#87ffd7',
	\ 'x123_DarkSlateGray1':   '#87ffff',
	\ 'x124_Red3':             '#af0000',
	\ 'x125_DeepPink4':        '#af005f',
	\ 'x126_MediumVioletRed':  '#af0087',
	\ 'x127_Magenta3':         '#af00af',
	\ 'x128_DarkViolet':       '#af00d7',
	\ 'x129_Purple':           '#af00ff',
	\ 'x130_DarkOrange3':      '#af5f00',
	\ 'x131_IndianRed':        '#af5f5f',
	\ 'x132_HotPink3':         '#af5f87',
	\ 'x133_MediumOrchid3':    '#af5faf',
	\ 'x134_MediumOrchid':     '#af5fd7',
	\ 'x135_MediumPurple2':    '#af5fff',
	\ 'x136_DarkGoldenrod':    '#af8700',
	\ 'x137_LightSalmon3':     '#af875f',
	\ 'x138_RosyBrown':        '#af8787',
	\ 'x139_Grey63':           '#af87af',
	\ 'x140_MediumPurple2':    '#af87d7',
	\ 'x141_MediumPurple1':    '#af87ff',
	\ 'x142_Gold3':            '#afaf00',
	\ 'x143_DarkKhaki':        '#afaf5f',
	\ 'x144_NavajoWhite3':     '#afaf87',
	\ 'x145_Grey69':           '#afafaf',
	\ 'x146_LightSteelBlue3':  '#afafd7',
	\ 'x147_LightSteelBlue':   '#afafff',
	\ 'x148_Yellow3':          '#afd700',
	\ 'x149_DarkOliveGreen3':  '#afd75f',
	\ 'x150_DarkSeaGreen3':    '#afd787',
	\ 'x151_DarkSeaGreen2':    '#afd7af',
	\ 'x152_LightCyan3':       '#afd7d7',
	\ 'x153_LightSkyBlue1':    '#afd7ff',
	\ 'x154_GreenYellow':      '#afff00',
	\ 'x155_DarkOliveGreen2':  '#afff5f',
	\ 'x156_PaleGreen1':       '#afff87',
	\ 'x157_DarkSeaGreen2':    '#afffaf',
	\ 'x158_DarkSeaGreen1':    '#afffd7',
	\ 'x159_PaleTurquoise1':   '#afffff',
	\ 'x160_Red3':             '#d70000',
	\ 'x161_DeepPink3':        '#d7005f',
	\ 'x162_DeepPink3':        '#d70087',
	\ 'x163_Magenta3':         '#d700af',
	\ 'x164_Magenta3':         '#d700d7',
	\ 'x165_Magenta2':         '#d700ff',
	\ 'x166_DarkOrange3':      '#d75f00',
	\ 'x167_IndianRed':        '#d75f5f',
	\ 'x168_HotPink3':         '#d75f87',
	\ 'x169_HotPink2':         '#d75faf',
	\ 'x170_Orchid':           '#d75fd7',
	\ 'x171_MediumOrchid1':    '#d75fff',
	\ 'x172_Orange3':          '#d78700',
	\ 'x173_LightSalmon3':     '#d7875f',
	\ 'x174_LightPink3':       '#d78787',
	\ 'x175_Pink3':            '#d787af',
	\ 'x176_Plum3':            '#d787d7',
	\ 'x177_Violet':           '#d787ff',
	\ 'x178_Gold3':            '#d7af00',
	\ 'x179_LightGoldenrod3':  '#d7af5f',
	\ 'x180_Tan':              '#d7af87',
	\ 'x181_MistyRose3':       '#d7afaf',
	\ 'x182_Thistle3':         '#d7afd7',
	\ 'x183_Plum2':            '#d7afff',
	\ 'x184_Yellow3':          '#d7d700',
	\ 'x185_Khaki3':           '#d7d75f',
	\ 'x186_LightGoldenrod2':  '#d7d787',
	\ 'x187_LightYellow3':     '#d7d7af',
	\ 'x188_Grey84':           '#d7d7d7',
	\ 'x189_LightSteelBlue1':  '#d7d7ff',
	\ 'x190_Yellow2':          '#d7ff00',
	\ 'x191_DarkOliveGreen1':  '#d7ff5f',
	\ 'x192_DarkOliveGreen1':  '#d7ff87',
	\ 'x193_DarkSeaGreen1':    '#d7ffaf',
	\ 'x194_Honeydew2':        '#d7ffd7',
	\ 'x195_LightCyan1':       '#d7ffff',
	\ 'x196_Red1':             '#ff0000',
	\ 'x197_DeepPink2':        '#ff005f',
	\ 'x198_DeepPink1':        '#ff0087',
	\ 'x199_DeepPink1':        '#ff00af',
	\ 'x200_Magenta2':         '#ff00d7',
	\ 'x201_Magenta1':         '#ff00ff',
	\ 'x202_OrangeRed1':       '#ff5f00',
	\ 'x203_IndianRed1':       '#ff5f5f',
	\ 'x204_IndianRed1':       '#ff5f87',
	\ 'x205_HotPink':          '#ff5faf',
	\ 'x206_HotPink':          '#ff5fd7',
	\ 'x207_MediumOrchid1':    '#ff5fff',
	\ 'x208_DarkOrange':       '#ff8700',
	\ 'x209_Salmon1':          '#ff875f',
	\ 'x210_LightCoral':       '#ff8787',
	\ 'x211_PaleVioletRed1':   '#ff87af',
	\ 'x212_Orchid2':          '#ff87d7',
	\ 'x213_Orchid1':          '#ff87ff',
	\ 'x214_Orange1':          '#ffaf00',
	\ 'x215_SandyBrown':       '#ffaf5f',
	\ 'x216_LightSalmon1':     '#ffaf87',
	\ 'x217_LightPink1':       '#ffafaf',
	\ 'x218_Pink1':            '#ffafd7',
	\ 'x219_Plum1':            '#ffafff',
	\ 'x220_Gold1':            '#ffd700',
	\ 'x221_LightGoldenrod2':  '#ffd75f',
	\ 'x222_LightGoldenrod2':  '#ffd787',
	\ 'x223_NavajoWhite1':     '#ffd7af',
	\ 'x224_MistyRose1':       '#ffd7d7',
	\ 'x225_Thistle1':         '#ffd7ff',
	\ 'x226_Yellow1':          '#ffff00',
	\ 'x227_LightGoldenrod1':  '#ffff5f',
	\ 'x228_Khaki1':           '#ffff87',
	\ 'x229_Wheat1':           '#ffffaf',
	\ 'x230_Cornsilk1':        '#ffffd7',
	\ 'x231_Grey100':          '#ffffff',
	\ 'x232_Grey3':            '#080808',
	\ 'x233_Grey7':            '#121212',
	\ 'x234_Grey11':           '#1c1c1c',
	\ 'x235_Grey15':           '#262626',
	\ 'x236_Grey19':           '#303030',
	\ 'x237_Grey23':           '#3a3a3a',
	\ 'x238_Grey27':           '#444444',
	\ 'x239_Grey30':           '#4e4e4e',
	\ 'x240_Grey35':           '#585858',
	\ 'x241_Grey39':           '#626262',
	\ 'x242_Grey42':           '#6c6c6c',
	\ 'x243_Grey46':           '#767676',
	\ 'x244_Grey50':           '#808080',
	\ 'x245_Grey54':           '#8a8a8a',
	\ 'x246_Grey58':           '#949494',
	\ 'x247_Grey62':           '#9e9e9e',
	\ 'x248_Grey66':           '#a8a8a8',
	\ 'x249_Grey70':           '#b2b2b2',
	\ 'x250_Grey74':           '#bcbcbc',
	\ 'x251_Grey78':           '#c6c6c6',
	\ 'x252_Grey82':           '#d0d0d0',
	\ 'x253_Grey85':           '#dadada',
	\ 'x254_Grey89':           '#e4e4e4',
	\ 'x255_Grey93':           '#eeeeee',
	\ }
endfunction

