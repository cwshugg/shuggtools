" Connor's Vim Settings
" ----- helper function(s)
" CCO - Capture Command Output. Runs the given command and returns the output
function! CCO(cmd)
    let s:cco_out = ''
    redir =>> s:cco_out
    silent execute a:cmd
    redir END

    " trim off any whitespace and return
    let s:cco_out = trim(s:cco_out)
    return s:cco_out
endfunction

" ----- general settings
syntax on                               " syntax highlighting
colorscheme dwarrowdelf " modifies color scheme
set tabstop=4 shiftwidth=4 expandtab    " tabs = 4 spaces
set softtabstop=4                       " enables backspace to clear out 4 spaces
set autoindent                          " forces vim to auto-indent
set smartindent                         " smart indentation - helps with backspace
set number                              " displays page numbers
au FileType * set formatoptions-=cro    " disable automatic comment insertion for all file types
set undolevels=1000                     " LOTS of undos available
set backspace=indent,eol,start          " make sure backspace works properly

"----- line/column highlighting
set cursorline                          " highlight current line cursor is on
set cursorcolumn                        " highlight current column cursor is on

" ----- search settings
set hlsearch                            " highlight search results
set is                                  " highlight searches as you type

" ----- gvim settings
if has('gui_running')
    set guifont=Consolas:h11            " set gvim font
    set guioptions -=m                  " remove menu bar
    set guioptions -=T                  " remove toolbar

    " remap visual and normal mode yanks (copies) to the system clipboard
    nnoremap y "+y                      
    vnoremap y "+y
    
    " if we aren't editing a file, we'll 'cd' to the windows desktop:
    let s:filename = CCO('file')
    if stridx(s:filename, '[No Name]') > -1
        " get the home directory and append 'Desktop' onto it. Assuming
        " this is a windows machine, that means we'll save any new files
        " to the desktop, rather than our home directory
        let s:homedir = CCO('echo $HOME')
        let s:desktop = s:homedir . '/Desktop'
        let s:cmd = 'cd ' . s:desktop
        execute s:cmd
    endif
endif

" the below shortcut allows you to press space to clear highlighted search terms
" thanks to: https://vim.fandom.com/wiki/Highlight_all_search_pattern_matches
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

