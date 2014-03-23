scriptencoding utf-8
if exists('g:loaded_operator_swap')
  finish
endif
let g:loaded_operator_swap = 1

let s:save_cpo = &cpo
set cpo&vim


call operator#user#define('swap', 'operator#swap#do')

nnoremap <Plug>(operator-swap-reset) :<C-u>call operator#swap#reset()<CR>


let &cpo = s:save_cpo
unlet s:save_cpo
