" Goto
" A wrapper for ALEGoToDefinition that utilizes the FOPS file stack to make
" returning to the previous file easier. (Among other things.)


" ============================= Argument Parsing ============================= "
let s:arg_help = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('-', 'h'))
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('--', 'help'))
call argonaut#arg#set_description(s:arg_help,
    \ 'Shows this help menu.'
\ )

" Indicates that we need to invoke ALEGoToTypeDefinition, rather than
" ALEGoToDefinition.
let s:arg_help = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('-', 't'))
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('--', 'type'))
call argonaut#arg#set_description(s:arg_help,
    \ 'Invokes ALEGoToTypeDefinition'
\ )

" Indicates that we need to invoke ALEGoToImplementationDefinition, rather
" than ALEGoToDefinition.
let s:arg_help = argonaut#arg#new()
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('-', 'i'))
call argonaut#arg#add_argid(s:arg_help, argonaut#argid#new('--', 'implementation'))
call argonaut#arg#set_description(s:arg_help,
    \ 'Invokes ALEGoToImplementationDefinition'
\ )

let s:argset = argonaut#argset#new([
    \ s:arg_help,
\ ])

" Tab-completion function for the command.
function! goto#arg_completion(arg, line, pos) abort
    return argonaut#completion#complete(a:arg, a:line, a:pos, s:argset)
endfunction


" ============================== Main Interface ============================== "
" Shows the help menu.
function! goto#show_help(parser) abort
    echo 'Goto: jumps to the definition of whatever your cursor is pointing at.'
    echo '(Calls ALEGoToDefinition)'
    call argonaut#argparser#show_help(a:parser)
endfunction

" Invokes the proper ALE plugin function to jump to the definition of the
" cursor's current target.
function! goto#invoke_ale(parser) abort
    " before we invoke ALE, save the current file to the FOPS file stack for
    " this buffer, as long as the plugin is loaded
    if exists('g:fops_initialized')
        let l:buffer_id = fops#fstack#get_buffer_id()
        let l:entry = fops#fstack#get_buffer_entry(l:buffer_id)
        call fops#fstack#push(l:buffer_id, l:entry)
    endif
    
    " decide what command to execute based on the provided arguments
    if argonaut#argparser#has_arg(a:parser, '-t')
        execute 'ALEGoToTypeDefinition'
    elseif argonaut#argparser#has_arg(a:parser, '-i')
        execute 'ALEGoToImplementationDefinition'
    else
        execute 'ALEGoToDefinition'
    endif
endfunction

" The main function for the Goto command.
function! goto#main(input) abort
    " build an argument parser and parse
    let l:parser = argonaut#argparser#new(s:argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
    catch
        echoerr v:exception
    endtry

    " show the help menu and return, if necessary
    if argonaut#argparser#has_arg(l:parser, '-h')
        call goto#show_help(l:parser)
        return
    endif

    " if ale is not loaded, there's nothing we can do
    if !exists('g:loaded_ale')
        echo 'The ALE plugin is not loaded.'
        return
    endif

    " otherwise, invoke ALE
    call goto#invoke_ale(l:parser)
endfunction

