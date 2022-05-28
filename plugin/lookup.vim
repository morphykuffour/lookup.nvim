" prevent loading file twice
if exists('g:loaded_lookup') | finish | endif 

let s:save_cpo = &cpo
set cpo&vim

command! Lookup lua require'lookup'.lookup_word()
command! ShowStuff lua require'lookup'.show_stuff()
command! GetCurrentWord call Get_current_word()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_lookup = 1

" Source: https://github.com/bfredl/nvim-luadev/blob/master/plugin/luadev.vim
function! Get_current_word()
    let isk_save = &isk
    let &isk = '@,48-57,_,192-255,.'
    let word = expand("<cword>")
    let &isk = isk_save
    return word
endfunction


