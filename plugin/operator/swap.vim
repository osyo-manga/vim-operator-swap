scriptencoding utf-8
if exists('g:loaded_operator_swap')
  finish
endif
let g:loaded_operator_swap = 1

let s:save_cpo = &cpo
set cpo&vim


call operator#user#define('swap', 'operator#swap#do')
call operator#user#define('swap-alternately', 'operator#swap#alternately')
call operator#user#define('swap-marking', 'operator#swap#marking')

nnoremap <silent> <Plug>(operator-swap-reset) :<C-u>call operator#swap#reset()<CR>

" call operator#user#define('swap-paste', 'operator#swap#paste')
" call operator#user#define('swap-yank-register', 'operator#swap#yank_register')
call operator#user#define('swap-last-yank', 'operator#swap#do', ":call operator#swap#last_yank()")


let &cpo = s:save_cpo
unlet s:save_cpo
