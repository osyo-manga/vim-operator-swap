scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:V = vital#operator_swap#of()
let s:Buffer = s:V.import("Coaster.Buffer")
let s:Search = s:V.import("Coaster.Search")
let s:Highlight = s:V.import("Coaster.Highlight")


" a <= b
function! s:pos_less_equal(a, b)
	return a:a[0] == a:b[0] ? a:a[1] <= a:b[1] : a:a[0] <= a:b[0]
endfunction


function! s:as_wise_key(name)
	return a:name ==# "char"  ? "v"
\		 : a:name ==# "line"  ? "V"
\		 : a:name ==# "block" ? "\<C-v>"
\		 : a:name
endfunction


function! s:paste(textobj, ...)
	let register = get(a:, 1, v:register != "" ? v:register : '"')
	call s:Buffer.paste(a:textobj[0], a:textobj[1], a:textobj[2], register)
endfunction


function! s:yank(textobj)
	call s:Buffer.yank(a:textobj[0], a:textobj[1], a:textobj[2])
endfunction


function! s:swap(a, b)
	if a:a == a:b
		return
	endif

	" b <= a
	if s:pos_less_equal(a:b[1][1:], a:a[1][1:])
		return s:swap(a:b, a:a)
	endif

	let register = v:register != "" ? v:register : '"'
	let yank = getreg(register)

	try
		call s:yank(a:a)
		call s:paste(a:b)
		call s:paste(a:a)
	finally
		call setreg(register, yank)
	endtry
endfunction


function! s:swap_register(region, register)
	let old_selection = &selection
	let &selection = 'inclusive'
	try
		call s:paste(a:region, a:register)
	finally
		let &selection = old_selection
	endtry
endfunction


function! operator#swap#yank_register(wise, ...)
	return s:swap_register([s:as_wise_key(a:wise), getpos("'["), getpos("']")], v:register == "" ? '"' : v:register)
endfunction


function! operator#swap#latest_yank(wise, ...)
	return s:swap_register([s:as_wise_key(a:wise), getpos("'["), getpos("']")], v:register == "" ? '"' : v:register)
endfunction


function! operator#swap#marking(wise, ...)
	call s:Highlight.clear("mark")
	let b:operator_swap_mark = [s:as_wise_key(a:wise), getpos("'["), getpos("']")]
	let pattern = s:Search.pattern_by_range(a:wise, getpos("'[")[1:2], getpos("']")[1:2])
	
	if pattern == ""
		return
	endif
" 	call s:Highlight.highlight("mark", "Search", pattern)
endfunction


function! operator#swap#last_yank(...)
	let wise = get(a:, 1, getregtype())
	call operator#swap#marking(wise)
endfunction


function! operator#swap#do(wise, ...)
	if !exists("b:operator_swap_mark")
		return
	endif
	let target = b:operator_swap_mark
	call s:swap(target, [s:as_wise_key(a:wise), getpos("'["), getpos("']")])
endfunction


function! operator#swap#alternately(wise, ...)
	if !exists("b:operator_swap_alternately_flag")
		let b:operator_swap_alternately_flag = 1
		return operator#swap#marking(a:wise)
	endif
	unlet! b:operator_swap_alternately_flag
	return operator#swap#do(a:wise)
endfunction


function! operator#swap#reset()
	unlet! b:operator_swap_mark
	unlet! b:operator_swap_alternately_flag
	let s:Highlight.clear("mark")
endfunction


function! operator#swap#paste(wise, ...)
	if !exists("b:operator_swap_mark")
		return
	endif
	let mark = b:operator_swap_mark
	let target = [s:as_wise_key(a:wise), getpos("'["), getpos("']")]
	let old_pos = getpos(".")
	let old_selection = &selection
	let &selection = 'inclusive'
	let register = v:register != "" ? v:register : '"'
	let yank = getreg(register)
	try
		call s:yank(mark)
		call s:paste(target)
	finally
		call setpos(".", old_pos)
		let &selection = old_selection
		call setreg(register, yank)
	endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
