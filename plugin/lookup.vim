if !has('nvim-0.5')
    echoerr 'Rest.nvim requires at least nvim-0.5. Please update or uninstall'
    finish
endif

" prevent loading file twice
if exists('g:loaded_lookup') | finish | endif 


command! Lookup lua require'lookup'.lookup()

let s:save_cpo = &cpo
set cpo&vim

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_lookup = 1

