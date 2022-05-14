" prevent loading file twice
if exists('g:loaded_lookup') | finish | endif 

let s:save_cpo = &cpo
set cpo&vim

command! Lookup lua require'lookup'.lookup_word()
command! ShowStuff lua require'lookup'.show_stuff()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_lookup = 1

