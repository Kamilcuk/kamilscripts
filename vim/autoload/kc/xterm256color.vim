
" vim: nowrap

" Based on:
" https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
" https://jonasjacek.github.io/colors/

let s:xterm256colordict = {
			\              'x_Black_0': [ '#000000',   '0'],
			\             'x_Maroon_1': [ '#800000',   '1'],
			\              'x_Green_2': [ '#008000',   '2'],
			\              'x_Olive_3': [ '#808000',   '3'],
			\               'x_Navy_4': [ '#000080',   '4'],
			\             'x_Purple_5': [ '#800080',   '5'],
			\               'x_Teal_6': [ '#008080',   '6'],
			\             'x_Silver_7': [ '#c0c0c0',   '7'],
			\               'x_Grey_8': [ '#808080',   '8'],
			\                'x_Red_9': [ '#ff0000',   '9'],
			\              'x_Lime_10': [ '#00ff00',  '10'],
			\            'x_Yellow_11': [ '#ffff00',  '11'],
			\              'x_Blue_12': [ '#0000ff',  '12'],
			\           'x_Fuchsia_13': [ '#ff00ff',  '13'],
			\              'x_Aqua_14': [ '#00ffff',  '14'],
			\             'x_White_15': [ '#ffffff',  '15'],
			\             'x_Grey0_16': [ '#000000',  '16'],
			\          'x_NavyBlue_17': [ '#00005f',  '17'],
			\          'x_DarkBlue_18': [ '#000087',  '18'],
			\             'x_Blue3_19': [ '#0000af',  '19'],
			\             'x_Blue3_20': [ '#0000d7',  '20'],
			\             'x_Blue1_21': [ '#0000ff',  '21'],
			\         'x_DarkGreen_22': [ '#005f00',  '22'],
			\      'x_DeepSkyBlue4_23': [ '#005f5f',  '23'],
			\      'x_DeepSkyBlue4_24': [ '#005f87',  '24'],
			\      'x_DeepSkyBlue4_25': [ '#005faf',  '25'],
			\       'x_DodgerBlue3_26': [ '#005fd7',  '26'],
			\       'x_DodgerBlue2_27': [ '#005fff',  '27'],
			\            'x_Green4_28': [ '#008700',  '28'],
			\      'x_SpringGreen4_29': [ '#00875f',  '29'],
			\        'x_Turquoise4_30': [ '#008787',  '30'],
			\      'x_DeepSkyBlue3_31': [ '#0087af',  '31'],
			\      'x_DeepSkyBlue3_32': [ '#0087d7',  '32'],
			\       'x_DodgerBlue1_33': [ '#0087ff',  '33'],
			\            'x_Green3_34': [ '#00af00',  '34'],
			\      'x_SpringGreen3_35': [ '#00af5f',  '35'],
			\          'x_DarkCyan_36': [ '#00af87',  '36'],
			\     'x_LightSeaGreen_37': [ '#00afaf',  '37'],
			\      'x_DeepSkyBlue2_38': [ '#00afd7',  '38'],
			\      'x_DeepSkyBlue1_39': [ '#00afff',  '39'],
			\            'x_Green3_40': [ '#00d700',  '40'],
			\      'x_SpringGreen3_41': [ '#00d75f',  '41'],
			\      'x_SpringGreen2_42': [ '#00d787',  '42'],
			\             'x_Cyan3_43': [ '#00d7af',  '43'],
			\     'x_DarkTurquoise_44': [ '#00d7d7',  '44'],
			\        'x_Turquoise2_45': [ '#00d7ff',  '45'],
			\            'x_Green1_46': [ '#00ff00',  '46'],
			\      'x_SpringGreen2_47': [ '#00ff5f',  '47'],
			\      'x_SpringGreen1_48': [ '#00ff87',  '48'],
			\ 'x_MediumSpringGreen_49': [ '#00ffaf',  '49'],
			\             'x_Cyan2_50': [ '#00ffd7',  '50'],
			\             'x_Cyan1_51': [ '#00ffff',  '51'],
			\           'x_DarkRed_52': [ '#5f0000',  '52'],
			\         'x_DeepPink4_53': [ '#5f005f',  '53'],
			\           'x_Purple4_54': [ '#5f0087',  '54'],
			\           'x_Purple4_55': [ '#5f00af',  '55'],
			\           'x_Purple3_56': [ '#5f00d7',  '56'],
			\        'x_BlueViolet_57': [ '#5f00ff',  '57'],
			\           'x_Orange4_58': [ '#5f5f00',  '58'],
			\            'x_Grey37_59': [ '#5f5f5f',  '59'],
			\     'x_MediumPurple4_60': [ '#5f5f87',  '60'],
			\        'x_SlateBlue3_61': [ '#5f5faf',  '61'],
			\        'x_SlateBlue3_62': [ '#5f5fd7',  '62'],
			\        'x_RoyalBlue1_63': [ '#5f5fff',  '63'],
			\       'x_Chartreuse4_64': [ '#5f8700',  '64'],
			\     'x_DarkSeaGreen4_65': [ '#5f875f',  '65'],
			\    'x_PaleTurquoise4_66': [ '#5f8787',  '66'],
			\         'x_SteelBlue_67': [ '#5f87af',  '67'],
			\        'x_SteelBlue3_68': [ '#5f87d7',  '68'],
			\    'x_CornflowerBlue_69': [ '#5f87ff',  '69'],
			\       'x_Chartreuse3_70': [ '#5faf00',  '70'],
			\     'x_DarkSeaGreen4_71': [ '#5faf5f',  '71'],
			\         'x_CadetBlue_72': [ '#5faf87',  '72'],
			\         'x_CadetBlue_73': [ '#5fafaf',  '73'],
			\          'x_SkyBlue3_74': [ '#5fafd7',  '74'],
			\        'x_SteelBlue1_75': [ '#5fafff',  '75'],
			\       'x_Chartreuse3_76': [ '#5fd700',  '76'],
			\        'x_PaleGreen3_77': [ '#5fd75f',  '77'],
			\         'x_SeaGreen3_78': [ '#5fd787',  '78'],
			\       'x_Aquamarine3_79': [ '#5fd7af',  '79'],
			\   'x_MediumTurquoise_80': [ '#5fd7d7',  '80'],
			\        'x_SteelBlue1_81': [ '#5fd7ff',  '81'],
			\       'x_Chartreuse2_82': [ '#5fff00',  '82'],
			\         'x_SeaGreen2_83': [ '#5fff5f',  '83'],
			\         'x_SeaGreen1_84': [ '#5fff87',  '84'],
			\         'x_SeaGreen1_85': [ '#5fffaf',  '85'],
			\       'x_Aquamarine1_86': [ '#5fffd7',  '86'],
			\    'x_DarkSlateGray2_87': [ '#5fffff',  '87'],
			\           'x_DarkRed_88': [ '#870000',  '88'],
			\         'x_DeepPink4_89': [ '#87005f',  '89'],
			\       'x_DarkMagenta_90': [ '#870087',  '90'],
			\       'x_DarkMagenta_91': [ '#8700af',  '91'],
			\        'x_DarkViolet_92': [ '#8700d7',  '92'],
			\            'x_Purple_93': [ '#8700ff',  '93'],
			\           'x_Orange4_94': [ '#875f00',  '94'],
			\        'x_LightPink4_95': [ '#875f5f',  '95'],
			\             'x_Plum4_96': [ '#875f87',  '96'],
			\     'x_MediumPurple3_97': [ '#875faf',  '97'],
			\     'x_MediumPurple3_98': [ '#875fd7',  '98'],
			\        'x_SlateBlue1_99': [ '#875fff',  '99'],
			\          'x_Yellow4_100': [ '#878700', '100'],
			\           'x_Wheat4_101': [ '#87875f', '101'],
			\           'x_Grey53_102': [ '#878787', '102'],
			\   'x_LightSlateGrey_103': [ '#8787af', '103'],
			\     'x_MediumPurple_104': [ '#8787d7', '104'],
			\   'x_LightSlateBlue_105': [ '#8787ff', '105'],
			\          'x_Yellow4_106': [ '#87af00', '106'],
			\  'x_DarkOliveGreen3_107': [ '#87af5f', '107'],
			\     'x_DarkSeaGreen_108': [ '#87af87', '108'],
			\    'x_LightSkyBlue3_109': [ '#87afaf', '109'],
			\    'x_LightSkyBlue3_110': [ '#87afd7', '110'],
			\         'x_SkyBlue2_111': [ '#87afff', '111'],
			\      'x_Chartreuse2_112': [ '#87d700', '112'],
			\  'x_DarkOliveGreen3_113': [ '#87d75f', '113'],
			\       'x_PaleGreen3_114': [ '#87d787', '114'],
			\    'x_DarkSeaGreen3_115': [ '#87d7af', '115'],
			\   'x_DarkSlateGray3_116': [ '#87d7d7', '116'],
			\         'x_SkyBlue1_117': [ '#87d7ff', '117'],
			\      'x_Chartreuse1_118': [ '#87ff00', '118'],
			\       'x_LightGreen_119': [ '#87ff5f', '119'],
			\       'x_LightGreen_120': [ '#87ff87', '120'],
			\       'x_PaleGreen1_121': [ '#87ffaf', '121'],
			\      'x_Aquamarine1_122': [ '#87ffd7', '122'],
			\   'x_DarkSlateGray1_123': [ '#87ffff', '123'],
			\             'x_Red3_124': [ '#af0000', '124'],
			\        'x_DeepPink4_125': [ '#af005f', '125'],
			\  'x_MediumVioletRed_126': [ '#af0087', '126'],
			\         'x_Magenta3_127': [ '#af00af', '127'],
			\       'x_DarkViolet_128': [ '#af00d7', '128'],
			\           'x_Purple_129': [ '#af00ff', '129'],
			\      'x_DarkOrange3_130': [ '#af5f00', '130'],
			\        'x_IndianRed_131': [ '#af5f5f', '131'],
			\         'x_HotPink3_132': [ '#af5f87', '132'],
			\    'x_MediumOrchid3_133': [ '#af5faf', '133'],
			\     'x_MediumOrchid_134': [ '#af5fd7', '134'],
			\    'x_MediumPurple2_135': [ '#af5fff', '135'],
			\    'x_DarkGoldenrod_136': [ '#af8700', '136'],
			\     'x_LightSalmon3_137': [ '#af875f', '137'],
			\        'x_RosyBrown_138': [ '#af8787', '138'],
			\           'x_Grey63_139': [ '#af87af', '139'],
			\    'x_MediumPurple2_140': [ '#af87d7', '140'],
			\    'x_MediumPurple1_141': [ '#af87ff', '141'],
			\            'x_Gold3_142': [ '#afaf00', '142'],
			\        'x_DarkKhaki_143': [ '#afaf5f', '143'],
			\     'x_NavajoWhite3_144': [ '#afaf87', '144'],
			\           'x_Grey69_145': [ '#afafaf', '145'],
			\  'x_LightSteelBlue3_146': [ '#afafd7', '146'],
			\   'x_LightSteelBlue_147': [ '#afafff', '147'],
			\          'x_Yellow3_148': [ '#afd700', '148'],
			\  'x_DarkOliveGreen3_149': [ '#afd75f', '149'],
			\    'x_DarkSeaGreen3_150': [ '#afd787', '150'],
			\    'x_DarkSeaGreen2_151': [ '#afd7af', '151'],
			\       'x_LightCyan3_152': [ '#afd7d7', '152'],
			\    'x_LightSkyBlue1_153': [ '#afd7ff', '153'],
			\      'x_GreenYellow_154': [ '#afff00', '154'],
			\  'x_DarkOliveGreen2_155': [ '#afff5f', '155'],
			\       'x_PaleGreen1_156': [ '#afff87', '156'],
			\    'x_DarkSeaGreen2_157': [ '#afffaf', '157'],
			\    'x_DarkSeaGreen1_158': [ '#afffd7', '158'],
			\   'x_PaleTurquoise1_159': [ '#afffff', '159'],
			\             'x_Red3_160': [ '#d70000', '160'],
			\        'x_DeepPink3_161': [ '#d7005f', '161'],
			\        'x_DeepPink3_162': [ '#d70087', '162'],
			\         'x_Magenta3_163': [ '#d700af', '163'],
			\         'x_Magenta3_164': [ '#d700d7', '164'],
			\         'x_Magenta2_165': [ '#d700ff', '165'],
			\      'x_DarkOrange3_166': [ '#d75f00', '166'],
			\        'x_IndianRed_167': [ '#d75f5f', '167'],
			\         'x_HotPink3_168': [ '#d75f87', '168'],
			\         'x_HotPink2_169': [ '#d75faf', '169'],
			\           'x_Orchid_170': [ '#d75fd7', '170'],
			\    'x_MediumOrchid1_171': [ '#d75fff', '171'],
			\          'x_Orange3_172': [ '#d78700', '172'],
			\     'x_LightSalmon3_173': [ '#d7875f', '173'],
			\       'x_LightPink3_174': [ '#d78787', '174'],
			\            'x_Pink3_175': [ '#d787af', '175'],
			\            'x_Plum3_176': [ '#d787d7', '176'],
			\           'x_Violet_177': [ '#d787ff', '177'],
			\            'x_Gold3_178': [ '#d7af00', '178'],
			\  'x_LightGoldenrod3_179': [ '#d7af5f', '179'],
			\              'x_Tan_180': [ '#d7af87', '180'],
			\       'x_MistyRose3_181': [ '#d7afaf', '181'],
			\         'x_Thistle3_182': [ '#d7afd7', '182'],
			\            'x_Plum2_183': [ '#d7afff', '183'],
			\          'x_Yellow3_184': [ '#d7d700', '184'],
			\           'x_Khaki3_185': [ '#d7d75f', '185'],
			\  'x_LightGoldenrod2_186': [ '#d7d787', '186'],
			\     'x_LightYellow3_187': [ '#d7d7af', '187'],
			\           'x_Grey84_188': [ '#d7d7d7', '188'],
			\  'x_LightSteelBlue1_189': [ '#d7d7ff', '189'],
			\          'x_Yellow2_190': [ '#d7ff00', '190'],
			\  'x_DarkOliveGreen1_191': [ '#d7ff5f', '191'],
			\  'x_DarkOliveGreen1_192': [ '#d7ff87', '192'],
			\    'x_DarkSeaGreen1_193': [ '#d7ffaf', '193'],
			\        'x_Honeydew2_194': [ '#d7ffd7', '194'],
			\       'x_LightCyan1_195': [ '#d7ffff', '195'],
			\             'x_Red1_196': [ '#ff0000', '196'],
			\        'x_DeepPink2_197': [ '#ff005f', '197'],
			\        'x_DeepPink1_198': [ '#ff0087', '198'],
			\        'x_DeepPink1_199': [ '#ff00af', '199'],
			\         'x_Magenta2_200': [ '#ff00d7', '200'],
			\         'x_Magenta1_201': [ '#ff00ff', '201'],
			\       'x_OrangeRed1_202': [ '#ff5f00', '202'],
			\       'x_IndianRed1_203': [ '#ff5f5f', '203'],
			\       'x_IndianRed1_204': [ '#ff5f87', '204'],
			\          'x_HotPink_205': [ '#ff5faf', '205'],
			\          'x_HotPink_206': [ '#ff5fd7', '206'],
			\    'x_MediumOrchid1_207': [ '#ff5fff', '207'],
			\       'x_DarkOrange_208': [ '#ff8700', '208'],
			\          'x_Salmon1_209': [ '#ff875f', '209'],
			\       'x_LightCoral_210': [ '#ff8787', '210'],
			\   'x_PaleVioletRed1_211': [ '#ff87af', '211'],
			\          'x_Orchid2_212': [ '#ff87d7', '212'],
			\          'x_Orchid1_213': [ '#ff87ff', '213'],
			\          'x_Orange1_214': [ '#ffaf00', '214'],
			\       'x_SandyBrown_215': [ '#ffaf5f', '215'],
			\     'x_LightSalmon1_216': [ '#ffaf87', '216'],
			\       'x_LightPink1_217': [ '#ffafaf', '217'],
			\            'x_Pink1_218': [ '#ffafd7', '218'],
			\            'x_Plum1_219': [ '#ffafff', '219'],
			\            'x_Gold1_220': [ '#ffd700', '220'],
			\  'x_LightGoldenrod2_221': [ '#ffd75f', '221'],
			\  'x_LightGoldenrod2_222': [ '#ffd787', '222'],
			\     'x_NavajoWhite1_223': [ '#ffd7af', '223'],
			\       'x_MistyRose1_224': [ '#ffd7d7', '224'],
			\         'x_Thistle1_225': [ '#ffd7ff', '225'],
			\          'x_Yellow1_226': [ '#ffff00', '226'],
			\  'x_LightGoldenrod1_227': [ '#ffff5f', '227'],
			\           'x_Khaki1_228': [ '#ffff87', '228'],
			\           'x_Wheat1_229': [ '#ffffaf', '229'],
			\        'x_Cornsilk1_230': [ '#ffffd7', '230'],
			\          'x_Grey100_231': [ '#ffffff', '231'],
			\            'x_Grey3_232': [ '#080808', '232'],
			\            'x_Grey7_233': [ '#121212', '233'],
			\           'x_Grey11_234': [ '#1c1c1c', '234'],
			\           'x_Grey15_235': [ '#262626', '235'],
			\           'x_Grey19_236': [ '#303030', '236'],
			\           'x_Grey23_237': [ '#3a3a3a', '237'],
			\           'x_Grey27_238': [ '#444444', '238'],
			\           'x_Grey30_239': [ '#4e4e4e', '239'],
			\           'x_Grey35_240': [ '#585858', '240'],
			\           'x_Grey39_241': [ '#626262', '241'],
			\           'x_Grey42_242': [ '#6c6c6c', '242'],
			\           'x_Grey46_243': [ '#767676', '243'],
			\           'x_Grey50_244': [ '#808080', '244'],
			\           'x_Grey54_245': [ '#8a8a8a', '245'],
			\           'x_Grey58_246': [ '#949494', '246'],
			\           'x_Grey62_247': [ '#9e9e9e', '247'],
			\           'x_Grey66_248': [ '#a8a8a8', '248'],
			\           'x_Grey70_249': [ '#b2b2b2', '249'],
			\           'x_Grey74_250': [ '#bcbcbc', '250'],
			\           'x_Grey78_251': [ '#c6c6c6', '251'],
			\           'x_Grey82_252': [ '#d0d0d0', '252'],
			\           'x_Grey85_253': [ '#dadada', '253'],
			\           'x_Grey89_254': [ '#e4e4e4', '254'],
			\           'x_Grey93_255': [ '#eeeeee', '255'],
			\ }

function! kc#xterm256color#get(name) abort
	return s:xterm256colordict[name]
endfunction

function! kc#xterm256color#highlight(name, xtermcolor, ...)
	let val = s:xterm256colordict[xtermcolor]
	execute 'highlight! '.name.' guifg='.val[0].' ctermfg='.val[1].' '.join(a:000, ' ')
endfunction

function! kc#xterm256color#load()
	for [name, val] in items(s:xterm256colordict)
		execute 'highlight! '.name.' guifg='.val[0].' ctermfg='.val[1]
	endfor
endfunction

function! kc#xterm256color#_command_handler(bang, name, ...)
	" Translate:
	"   x_something into guifg=something ctermfg=number
	"   fg=x_something into same as above
	"   bg=x_somethign into guibg and ctermbg
	let l:args = []
	for i in a:000
		if i =~# "^fg=x_"
			let i = split(i, '=')[1]
		endif
		if i =~# "^x_"
			if !has_key(s:xterm256colordict, i)
				echoe "kchi: Invalid xterm256 color name: ".i
				return
			endif
			let val = s:xterm256colordict[i]
			let l:args += ["guifg=".val[0], "ctermfg=".val[1]]
		elseif i =~# "bg=x_"
			let i = split(i, '=')[1]
			if !has_key(s:xterm256colordict, i)
				echoe "kchi: Invalid xterm256 color name: ".i
				return
			endif
			let val = s:xterm256colordict[i]
			let l:args += ["guibg=".val[0], "ctermbg=".val[1]]
		else
			let l:args += [i]
		endif
	endfor
	if a:bang
		let l:bang="!"
	else
		let l:bang=""
	endif
	execute 'highlight'.l:bang.' '.a:name.' '.join(l:args, ' ')
endfunction

function! kc#xterm256color#KcHi()
	command! -bang -nargs=+ KcHi call kc#xterm256color#_command_handler(<bang>0,<f-args>)
endfunction

