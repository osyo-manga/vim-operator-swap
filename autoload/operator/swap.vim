scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


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


function! s:paste(textobj)
	call setpos("'[", a:textobj[1])
	call setpos("']", a:textobj[2])
	normal! `[v`]p
endfunction


function! s:yank(textobj)
	call setpos("'[", a:textobj[1])
	call setpos("']", a:textobj[2])
	normal! `[v`]y
endfunction


function! s:swap(a, b)
	" b <= a
	if s:pos_less_equal(a:b[1][1:], a:a[1][1:])
		return s:swap(a:b, a:a)
	endif

	let old_pos = getpos(".")
	let old_selection = &selection
	let &selection = 'inclusive'
	let register = v:register != "" ? v:register : '"'
	let yank = getreg(register)
	try
		call s:yank(a:a)
		call s:paste(a:b)
		call s:paste(a:a)
	finally
		call setpos(".", old_pos)
		let &selection = old_selection
		call setreg(register, yank)
	endtry
endfunction


unlet! s:target


function! operator#swap#do(wise, ...)
	if !exists("s:target")
\	|| [s:as_wise_key(a:wise), getpos("'["), getpos("']")] == s:target
		let s:target =[s:as_wise_key(a:wise), getpos("'["), getpos("']")]
		return
	endif
	call s:swap(s:target, [s:as_wise_key(a:wise), getpos("'["), getpos("']")])
	unlet s:target
endfunction


function! operator#swap#reset()
	unlet! s:target
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
