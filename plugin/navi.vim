if exists("g:loaded_navi")
    finish
endif
let g:loaded_navi = 1

let s:navi_deps_dir = expand("<sfile>:h:r") . "/../lua/navi/deps"
exe "lua package.path = package.path .. ';" . s:navi_deps_dir . "/lua-?/init.lua'"

command! -range -nargs=0 NaviOpenRange lua require("navi").openRange()
command! -nargs=0 NaviOpen lua require("navi").open()
