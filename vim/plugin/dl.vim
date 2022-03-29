" DL = Divider Line / Draw Line
" A tool for drawing language-specific divider lines while I program. I tend to
" use something like this when dividing bits of code:
"
"   // ========================== blah blah blah ========================== //
"
" So this aims to automate that process.
"
"   Connor Shugg

" Globals
let g:dl_msg = ''
let g:dl_column_max = 80    " default max-column length of the line
let g:dl_line_mid = ''      " middle-of-the-line character
let g:dl_line_prefix = ''   " prefix for the line
let g:dl_line_suffix = ''   " suffix for the line

" ============================= Helper Functions ============================= "
" DL_CCO - Capture Command Output. Runs the given command and returns the output
function! DL_CCO(cmd)
    let s:cco_out = ''
    redir =>> s:cco_out
    silent execute a:cmd
    redir END

    " trim off any whitespace and return
    let s:cco_out = trim(s:cco_out)
    return s:cco_out
endfunction

" Function to get the current cursor position.
function! DL_CursorPosition()
    let l:pos = getpos('.')
    return l:pos
endfunction

" Function to get the current file type as a string.
function! DL_GetFileType()
    " get the filetype that was detected by vim
    let l:ft = DL_CCO('set filetype?')
    if strlen(l:ft) == 0
        return ""
    endif

    " split across the '=' to get the actual filetype
    let l:pieces = split(l:ft, '=')
    if len(l:pieces) < 2
        return ""
    endif
    return l:pieces[1]
endfunction


" ============================== Script Options ============================== "
" Used to print the 'usage' for the command to the vim command line.
function! DL_Usage()
    echo 'Usage: DL [msg=MESSAGE] [col=MAX_COLUMN] [char=LINE_CHARACTER] [pfx=LINE_PREFIX] [sfx=LINE_SUFFIX]'
endfunction

" Function used to get a command-line option of the following format:
"   key=value
" This function splits the two and returns them as an array.
function! DL_GetOption(raw)
    return split(a:raw, '=')
endfunction

" Function that takes in a key and value for a named option and processes it
" as needed.
function! DL_ProcessOption(key, value)
    if a:key ==? 'msg'
        let g:dl_msg = a:value
    elseif a:key ==? 'col'
        let g:dl_column_max = a:value
    elseif a:key ==? 'char'
        let g:dl_line_mid = a:value
    elseif a:key ==? 'pfx'
        let g:dl_line_prefix = a:value
    elseif a:key ==? 'sfx'
        let g:dl_line_suffix = a:value
    else
        call DL_Usage()
        return 1
    endif
    return 0
endfunction


" ============================ Main Functionality ============================ "
" Helper function for DL_SetLineCharacters that simply sets all three globals.
function! DL_SetLineCharacterGlobals(mid, pfx, sfx)
    if strlen(g:dl_line_mid) == 0
        let g:dl_line_mid = a:mid
    endif
    if strlen(g:dl_line_prefix) == 0
        let g:dl_line_prefix = a:pfx
    endif
    if strlen(g:dl_line_suffix) == 0
        let g:dl_line_suffix = a:sfx
    endif
endfunction

" Function that takes in a string representation of the current file type and
" uses it to set the global variables (declared above) used to draw the line.
function! DL_SetLineCharacters(ft)
    if a:ft ==? 'vim'
        call DL_SetLineCharacterGlobals('=', '"', '"')
    elseif a:ft ==? 'c' || a:ft ==? 'cpp'
        call DL_SetLineCharacterGlobals('=', '//', '//')
    elseif a:ft ==? 'python'
        call DL_SetLineCharacterGlobals('=', '#', '#')
    elseif a:ft ==? 'sh'
        call DL_SetLineCharacterGlobals('=', '#', '#')
    else
        " this is the default setting for anything non-detected
        if g:dl_line_mid ==? ''
            let g:dl_line_mid = '='
        endif
        call DL_SetLineCharacterGlobals(g:dl_line_mid, g:dl_line_prefix, g:dl_line_suffix)
    endif
endfunction

" Main function for this plugin. Arguments are as follows:
"   DL [string_to_put_in_line] [mid_character] [columns]
" Where all three are optional.
function! DL(...)
    " set local and global defaults
    let g:dl_msg = ''
    let g:dl_column_max = 80
    "let g:dl_line_mid = ''
    "let g:dl_line_prefix = ''
    "let g:dl_line_suffix = ''

    " try to process the current file type
    let l:ft = DL_GetFileType()
    call DL_SetLineCharacters(l:ft)

    " iterate through the command-line options and check
    let l:count = 0
    for raw_arg in a:000
        " parse the option into a list and account for failures
        let l:opt = DL_GetOption(raw_arg)
        if len(l:opt) < 2
            call DL_Usage()
            return
        endif
        " process the argument, and return on failure
        let l:result = DL_ProcessOption(l:opt[0], l:opt[1])
        if l:result != 0
            return
        endif
    endfor
    
    " get the cursor position and extract the horizontal spacing. Print and
    " return on failure
    let l:cp = DL_CursorPosition()
    if len(l:cp) < 3
        echo 'Failed to get the cursor position. Cannot draw a divider line.'
        return
    endif
    let l:row = l:cp[1]
    let l:col = l:cp[2]
    
    " if the cursor is on the last column of a line in NORMAL mode, the cursor
    " sits on the second-to-last column. We'll check to see if we're on the
    " last column, and increase l:col by one if so. This makes life easier when
    " we want to start the divider line we're inserting on the last column in
    " the current line
    let l:current_line_len = strlen(getline('.'))
    if l:col < l:current_line_len || l:col == 1
        let l:col -= 1
    endif
    
    " compute the number of middle characters to print on either side
    let l:mid_room = g:dl_column_max - l:col
    let l:mid_room -= strlen(g:dl_line_prefix) + strlen(g:dl_line_suffix)
    if strlen(g:dl_line_prefix) > 0
        let l:mid_room -= 1
    endif
    if strlen(g:dl_msg) > 0
        let l:mid_room -= strlen(g:dl_msg) + 2
    endif
    if strlen(g:dl_line_suffix) > 0
        let l:mid_room -= 1
    endif
    let l:mid_left = l:mid_room / 2
    let l:mid_right = l:mid_room - l:mid_left
 
    " finally, we'll build the final string
    let l:count = 0
    let l:line = ''
    if strlen(g:dl_line_prefix) > 0
        let l:line = g:dl_line_prefix . ' '     " add prefix
    endif
    while l:count < l:mid_left
        let l:line .= g:dl_line_mid             " add left-portion of middle
        let l:count += 1
    endwhile
    if strlen(g:dl_msg) > 0
        let l:line .= ' ' . g:dl_msg . ' '      " add message
    endif
    let l:count = 0
    while l:count < l:mid_right
        let l:line .= g:dl_line_mid             " add right-portion of middle
        let l:count += 1
    endwhile
    if strlen(g:dl_line_suffix) > 0
        let l:line .= ' ' . g:dl_line_suffix    " add suffix
    endif
    
    " set up a string of spaces to append to the front
    let l:spaces = ''
    let l:count = 0
    while l:count < l:col
        let l:spaces .= ' '
        let l:count += 1
    endwhile
    
    " finally, invoke setline() to set the current line's value
    call setline(l:row, l:spaces . l:line)
endfunction

" Command - shortens the use in vim.
command! -nargs=* DL call DL(<f-args>)

