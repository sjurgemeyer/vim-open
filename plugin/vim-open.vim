if !exists('g:vim_open_map_keys')
    let g:vim_open_map_keys = 1
endif

if !exists('g:vim_open_shortcut')
    let g:vim_open_shortcut='<leader>y'
endif

if !exists('g:vim_open_test_shortcut')
    let g:vim_open_test_shortcut='<leader>x'
endif

if !exists('g:vim_open_uppercase_shortcut')
    let g:vim_open_uppercase_shortcut='<leader>u'
endif

if !exists('g:vim_open_split_shortcut')
    let g:vim_open_split_shortcut='<leader>s'
endif

if !exists('g:vim_open_vertical_split_shortcut')
    let g:vim_open_vertical_split_shortcut='<leader>v'
endif

if !exists('g:vim_open_test_suffixes')
    let g:vim_open_test_suffixes=['Spec', 'Test', 'Tests']
endif

"Open file under cursor
if (g:vim_open_map_keys)
    execute "nnoremap"  g:vim_open_shortcut ':call VimOpenOpenFile(expand("<cword>"))<CR>'
    execute "nnoremap"  g:vim_open_test_shortcut ':call VimOpenOpenTest()<CR>'
    execute "nnoremap"  g:vim_open_uppercase_shortcut ':call OpenFileUpperCase(expand("<cword>"))<CR>'
    execute "nnoremap"  g:vim_open_split_shortcut ':call SplitFileUpperCase(expand("<cword>"))<CR>'
    execute "nnoremap"  g:vim_open_vertical_split_shortcut ':call VerticalSplitFileUpperCase(expand("<cword>"))<CR>'
endif

function! VimOpenOpenFile(filename)
	call OperateOnFile("edit", a:filename, 0)
endfunction

function! OpenFileUpperCase(filename)
    call OperateOnFile("edit", a:filename, 1)
endfunction

function! VimOpenOpenTest()
    call OperateOnTest("edit")
endfunction

function! SplitFileUpperCase(filename)
    call OperateOnFile("sp", a:filename, 1)
endfunction

function! VerticalSplitFileUpperCase(filename)
    call OperateOnFile("vsp", a:filename, 1)
endfunction

function! VerticalSplitFileUpperCase(filename)
    call OperateOnFile("vsp", a:filename, 1)
endfunction

function! OperateOnFile(command, filename, uppercase)
	let paths = VimOpenGetPaths(a:filename, a:uppercase)
	call OperateOnFilePaths(a:command, paths, a:uppercase)
endfunction

function! VimOpenGetPaths(filename, uppercase)
	if (a:uppercase)
		let fname = toupper(strpart(a:filename, 0, 1)) . strpart(a:filename, 1, strlen(a:filename))
	else
		let fname = a:filename
	endif

    let searchString = '**/' .  fname . '.*'
    let paths = split(globpath('.', searchString), '\n')
	return paths
endfunction

function! OperateOnFilePaths(command, paths, uppercase)

	let paths = a:paths
    if len(paths) == 0
        echoe "No file found"
        return
    endif
    if len(paths) == 1
		let chosenIndex = 1
    else
        call inputsave()
        let originalCmdHeight = &cmdheight
        let &cmdheight = len(paths) + 1
        let index = 0
        let message = ""
        while index < len(paths)
            let message = message . "[" . (index + 1) . "] " . paths[index] . "\n"
            let index += 1
        endwhile
        let chosenIndex = input(message . 'Which file?: ')
        let &cmdheight = originalCmdHeight
        call inputrestore()
    endif
	if chosenIndex > 0 && chosenIndex <= len(paths)
		silent execute a:command . " " . paths[chosenIndex-1]
	endif

endfunction


function! GetTestSuffixIndex(filename)
	for suffix in g:vim_open_test_suffixes
		let is_test = strridx(a:filename, suffix)
		if is_test > 0
			return is_test
		endif
	endfor
	return 0
endfunction

function! OperateOnTest(command)
	let filename = expand("%:t:r")
	let test_suffix_start = GetTestSuffixIndex(filename)
	if test_suffix_start > 0
		let filename = strpart(filename, 0, test_suffix_start)
		call OperateOnFile(a:command, filename, 0)
	else
		let paths = []
		for suffix in g:vim_open_test_suffixes
			let filename = filename . suffix
			let newpaths = VimOpenGetPaths(filename, 0)
			let paths = paths + newpaths
		endfor
		call OperateOnFilePaths(a:command, paths, 0)
	endif
endfunction

