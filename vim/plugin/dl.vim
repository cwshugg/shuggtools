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
    " let s:cco_out = trim(s:cco_out)
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


" ============================= Argumant Parsing ============================= "
" I'm utilizing Argonaut, my Vim argument parsing plugin, to build an argument
" parser for this script.
let s:arg_help = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('-', 'h'))
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('--', 'help'))
call argonaut#arg#set_description(s:arg_help,
    \ 'Shows this help menu.'
\ )

" Used to specify the message to place in the middle of the divider line.
let s:arg_msg = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_msg, argonaut#argid#new('-', 'm'))
call argonaut#arg#add_argid(s:arg_msg, argonaut#argid#new('--', 'message'))
call argonaut#arg#add_argid(s:arg_msg, argonaut#argid#new('--', 'msg'))
call argonaut#arg#set_description(s:arg_msg,
    \ 'Sets the message to place in the middle of the divider line.'
\ )
call argonaut#arg#set_value_required(s:arg_msg, 1)
call argonaut#arg#set_value_hint(s:arg_msg, 'MESSAGE')

" Used to specify the middle character to make up the divider line.
let s:arg_char = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_char, argonaut#argid#new('-', 'c'))
call argonaut#arg#add_argid(s:arg_char, argonaut#argid#new('--', 'character'))
call argonaut#arg#add_argid(s:arg_char, argonaut#argid#new('--', 'char'))
call argonaut#arg#set_description(s:arg_char,
    \ 'Sets the character that makes up the middle of the divider line.'
\ )
call argonaut#arg#set_value_required(s:arg_char, 1)
call argonaut#arg#set_value_hint(s:arg_char, 'CHARACTER')

" Used to specify the maximum column at which the divider line should end.
let s:arg_pfx = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_pfx, argonaut#argid#new('-', 'p'))
call argonaut#arg#add_argid(s:arg_pfx, argonaut#argid#new('--', 'prefix'))
call argonaut#arg#add_argid(s:arg_pfx, argonaut#argid#new('--', 'pfx'))
call argonaut#arg#set_description(s:arg_pfx,
    \ 'Sets the prefix string to begin the divier line with.'
\ )
call argonaut#arg#set_value_required(s:arg_pfx, 1)
call argonaut#arg#set_value_hint(s:arg_pfx, 'PREFIX')

" Used to specify the maximum column at which the divider line should end.
let s:arg_sfx = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_sfx, argonaut#argid#new('-', 's'))
call argonaut#arg#add_argid(s:arg_sfx, argonaut#argid#new('--', 'suffix'))
call argonaut#arg#add_argid(s:arg_sfx, argonaut#argid#new('--', 'sfx'))
call argonaut#arg#set_description(s:arg_sfx,
    \ 'Sets the suffix string to end the divier line with.'
\ )
call argonaut#arg#set_value_required(s:arg_sfx, 1)
call argonaut#arg#set_value_hint(s:arg_sfx, 'SUFFIX')

" Used to specify the maximum column at which the divider line should end.
let s:arg_col = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_col, argonaut#argid#new('-', 'C'))
call argonaut#arg#add_argid(s:arg_col, argonaut#argid#new('--', 'column'))
call argonaut#arg#add_argid(s:arg_col, argonaut#argid#new('--', 'col'))
call argonaut#arg#set_description(s:arg_col,
    \ 'Sets the maximum column at which the divider line should end.'
\ )
call argonaut#arg#set_value_required(s:arg_col, 1)
call argonaut#arg#set_value_hint(s:arg_col, 'COLUMN_NUMBER')

let s:argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_msg,
    \ s:arg_char,
    \ s:arg_pfx,
    \ s:arg_sfx,
    \ s:arg_col
\ ])

" Tab-completion function for the command.
function! DL_ArgumentCompletion(arg, line, pos) abort
    return argonaut#completion#complete(a:arg, a:line, a:pos, s:argset)
endfunction

" Uses the argument parser to process all arguments.
function! DL_ProcessArguments(parser) abort
    let l:extras = argonaut#argparser#get_extra_args(a:parser)

    if argonaut#argparser#has_arg(a:parser, '--message')
        let g:dl_msg = argonaut#argparser#get_arg(a:parser, '--message')[0]
    elseif len(l:extras) > 0
        let g:dl_msg = l:extras[0]
    endif

    if argonaut#argparser#has_arg(a:parser, '--character')
        let g:dl_line_mid = argonaut#argparser#get_arg(a:parser, '--character')[0]
    endif

    if argonaut#argparser#has_arg(a:parser, '--prefix')
        let g:dl_line_prefix = argonaut#argparser#get_arg(a:parser, '--prefix')[0]
    endif

    if argonaut#argparser#has_arg(a:parser, '--suffix')
        let g:dl_line_suffix = argonaut#argparser#get_arg(a:parser, '--suffix')[0]
    endif

    if argonaut#argparser#has_arg(a:parser, '--column')
        let g:dl_column_max = argonaut#argparser#get_arg(a:parser, '--column')[0]
    endif
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
    elseif a:ft ==? 'c' ||  a:ft ==? 'cpp' || a:ft ==? 'cc'
        call DL_SetLineCharacterGlobals('=', '//', '//')
    elseif a:ft ==? 'java' ||  a:ft ==? "javascript"
        call DL_SetLineCharacterGlobals('=', '//', '//')
    elseif a:ft ==? 'python' || a:ft ==? 'sh'
        call DL_SetLineCharacterGlobals('=', '#', '#')
    elseif a:ft ==? 'html'
        call DL_SetLineCharacterGlobals('-', '<!--', '-->')
    else
        " this is the default setting for anything non-detected
        if g:dl_line_mid ==? ''
            let g:dl_line_mid = '='
        endif
        call DL_SetLineCharacterGlobals(g:dl_line_mid, g:dl_line_prefix, g:dl_line_suffix)
    endif
endfunction

" Main function for this plugin. Arguments are as follows:
" Where all three are optional.
function! DL(input)
    " set local and global defaults
    let g:dl_msg = ''
    let g:dl_column_max = 80
    let g:dl_line_mid = '='
    "let g:dl_line_prefix = ''
    "let g:dl_line_suffix = ''

    " try to process the current file type
    let l:ft = DL_GetFileType()
    call DL_SetLineCharacters(l:ft)

    " build an argument parser and parse
    let l:parser = argonaut#argparser#new(s:argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
    catch
        echoerr v:exception
    endtry

    " show the help menu and return, if necessary
    if argonaut#argparser#has_arg(l:parser, '-h')
        call argonaut#argparser#show_help(l:parser)
        return
    endif

    " otherwise, process all argument values
    call DL_ProcessArguments(l:parser)
    
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
command!
    \ -nargs=*
    \ -complete=customlist,DL_ArgumentCompletion
    \ DL
    \ call DL(<q-args>)

