if !exists('g:vim_open_map_keys')
    let g:vim_open_map_keys = 1
endif

if !exists('g:vim_open_shortcut')
    let g:vim_open_shortcut='<leader>y'
endif

if !exists('g:vim_open_uppercase_shortcut')
    let g:vim_open_uppercase_shortcut='<leader>u'
endif

"Open file under cursor
if (g:vim_open_map_keys)
    execute "nnoremap"  g:vim_open_shortcut ':call OpenFileUnderCursor(expand("<cword>"))<CR>'
    execute "nnoremap"  g:vim_open_uppercase_shortcut ':call OpenFileUnderCursorUpperCase(expand("<cword>"))<CR>'
endif

function! OpenFileUnderCursorUpperCase(filename)
    let fname = toupper(strpart(a:filename, 0, 1)) . strpart(a:filename, 1, strlen(a:filename))
    call OpenFileUnderCursor(fname)
endfunction

function! OpenFileUnderCursor(filename)
    let searchString = '**/' . a:filename . '.*'
    let paths = split(globpath('.', searchString), '\n')
    if len(paths) == 0
        echoe "No file file for search string " . searchString
        return
    endif
    if len(paths) == 1
		silent execute "edit " . paths[0]
    else
        call inputsave()
        let originalCmdHeight = &cmdheight
        let &cmdheight = len(paths) + 1
        let index = 0
        let message = ""
        while index < len(paths)
            let message = message . "[" . index . "] " . paths[index] . "\n"
            let index += 1
        endwhile
        let chosenIndex = input(message . 'Which file?: ')
        if chosenIndex > 0 && chosenIndex < len(paths)
            silent execute "edit " . paths[chosenIndex]
        endif
        let &cmdheight = originalCmdHeight
        call inputrestore()
    endif

endfunction
