function! s:is_script_local(str)
    return a:str =~# '^<SNR>\d\+'
endfunction

function! s:extract_function_name(str)
    return matchlist(a:str,'\v^function (.*)\(')[1]
endfunction

function! s:all_function_names()
    redir => out
    silent function
    redir END
    return map(split(copy(out), "\n"), "s:extract_function_name(v:val)")
endfunction

function! s:script_local_function_names()
    return filter(s:all_function_names(), "s:is_script_local(v:val)")
endfunction

function! s:extract_SNR(funcname)
    return matchstr(a:funcname, '<SNR>\d\+')
endfunction

function! s:get_funcname_for(funname, ...)
    let candidate = s:script_local_function_names()
    if a:0 > 0
        let snr = s:extract_SNR(s:get_funcname_for(a:1)[0])
        call filter(candidate, "v:val =~# snr")
    endif
    let result = filter(candidate, "v:val =~# a:funname")
    if len(result) > 2
        echoerr "function for '". a:funname ."' is not uniquely identified"
    endif
    return result
endfunction

function! s:chRoot()
    "test"
endfunction

" Usage:
"==================================================================
" Simple search
echo PP(s:get_funcname_for("chRoot"))
" =>  ['<SNR>175_chRoot', '<SNR>63_chRoot']

" Determine anchor
echo PP(s:get_funcname_for("initNerdTree$"))
" => ['<SNR>63_initNerdTree']

" User anchor to identify target function
echo PP(s:get_funcname_for("chRoot", 'initNerdTree$'))
" => ['<SNR>63_chRoot'] 

finish
