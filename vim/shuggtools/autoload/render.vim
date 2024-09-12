" Render
" A general-purpose command that utilizes other tools to pretty-print certain
" file types. I originally created this to make markdown previewing easy with
" charm.sh's `glow` program.


" ============================= Argument Parsing ============================= "
let s:arg_help = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('-', 'h'))
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('--', 'help'))
call argonaut#arg#set_description(s:arg_help,
    \ 'Shows this help menu.'
\ )

let s:argset = argonaut#argset#new([
    \ s:arg_help,
\ ])

" Tab-completion function for the command.
function! render#arg_completion(arg, line, pos) abort
    return argonaut#completion#complete(a:arg, a:line, a:pos, s:argset)
endfunction


" ================================= Markdown ================================= "
function render#handle_markdown(parser, file) abort
    " make sure `glow` is installed
    if !executable('glow')
        echo 'Markdown cannot render; `glow` is not installed.'
        return
    endif

    " otherwise, invoke the shell command
    execute '!glow --pager --width 80 ' . a:file
endfunction


" ============================== Main Interface ============================== "
" Shows the help menu.
function! render#show_help(parser) abort
    echo 'Render: pretty-prints certain file types.'
    call argonaut#argparser#show_help(a:parser)
endfunction

" Retrieves the file path to operate on.
function! render#get_file_path(parser) abort
    " by default, the current buffer's file path is used
    let l:result = expand('%:p')

    " get the argparser's extra arguments. If one was provided, we'll use the
    " first one
    let l:eargs = argonaut#argparser#get_extra_args(a:parser)
    if len(l:eargs) > 0
        let l:result = expand(l:eargs[0])
    endif
    
    return l:result
endfunction

" Returns the given file path's vim-detected file type.
function! render#get_file_type(parser, file) abort
    " save current buffer number
    let l:old_buffer = bufnr('%')

    " open the given file in a new buffer (so Vim will examine it and
    " determine the file type)
    execute 'badd ' . a:file
    let l:new_buffer = bufnr(a:file)
    execute 'buffer ' . l:new_buffer

    " retrieve the file type of the new buffer  
    let l:ftype = getbufvar(l:new_buffer, '&filetype')

    " delete the new buffer and restore the old one
    execute 'bdelete ' . l:new_buffer
    execute 'buffer ' . l:old_buffer

    return l:ftype
endfunction

" The main function for the Render command.
function! render#main(input) abort
    " build an argument parser and parse
    let l:parser = argonaut#argparser#new(s:argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
    catch
        echoerr v:exception
    endtry

    " show the help menu and return, if necessary
    if argonaut#argparser#has_arg(l:parser, '-h')
        call render#show_help(l:parser)
        return
    endif

    " get the source file, and its type
    let l:fpath = render#get_file_path(l:parser)
    let l:ftype = render#get_file_type(l:parser, l:fpath)

    " check the file type and determine if it's supported, and invoke the
    " proper handler function
    if l:ftype == 'markdown'
        call render#handle_markdown(l:parser, l:fpath)
        return
    endif

    " otherwise, let the user know the file is not supported
    echo 'This file type ("' . l:ftype . '") is not supported.'
endfunction

