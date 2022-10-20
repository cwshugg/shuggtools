" Connor's Vim Settings

" ============================ Vundle and Plugins ============================ "
set nocompatible                        " vundle requires VIM, not VI
filetype off                            " required by vundle
set rtp+=$HOME/.vim/bundle/Vundle.vim   " add vundle to vim's runtime path
call vundle#begin()

" ------------- Plugins -------------- "
Plugin 'VundleVim/Vundle.vim'           " required by vundle
Plugin 'https://github.com/lambdalisue/fern.vim'

call vundle#end()                       " finish vundle setup
filetype plugin indent on               " required by vundle


" ------------------------------ Fern Shortcuts ------------------------------ "
" FT - File Tree. Utilizes Fern to open a 'project-drawer'-style file tree next
" to the current editor window.
function! FT(...)
    let l:file_tree_dir = '~'

    " if one or more arguments was passed in, we'll parse the first one as the
    " directory path to open with fern
    if a:0 > 0
        let l:file_tree_dir = a:1
    endif

    " invoke fern with the selected directory
    execute 'Fern ' . l:file_tree_dir . ' -drawer'
endfunction
command! -nargs=* FT call FT(<f-args>)

" ============================= Helper Functions ============================= "
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


" ============================= General Settings ============================= "
syntax on                               " syntax highlighting
colorscheme dwarrowdelf                 " modifies color scheme
set tabstop=4 shiftwidth=4 expandtab    " tabs = 4 spaces
set softtabstop=4                       " enables backspace to clear out 4 spaces
set autoindent                          " forces vim to auto-indent
filetype indent on
set number                              " displays page numbers
au FileType * set formatoptions-=cro    " disable automatic comment insertion for all file types
set undolevels=1000                     " LOTS of undos available
set backspace=indent,eol,start          " make sure backspace works properly
set ruler                               " enable the bottom-right set of numbers


" ========================= Line/Column Highlighting ========================= "
set cursorline                          " highlight current line cursor is on
set cursorcolumn                        " highlight current column cursor is on


" ============================= Search Settings ============================== "
set hlsearch                            " highlight search results
set is                                  " highlight searches as you type


" =========================== Remaps and Shortcuts =========================== "
" the below shortcut allows you to press space to clear highlighted search terms
" thanks to: https://vim.fandom.com/wiki/Highlight_all_search_pattern_matches
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>


" ============================== gVim Settings =============================== "
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
        let s:desktop = s:homedir . '/Desktop'
        let s:cmd = 'cd ' . s:desktop
        execute s:cmd
    endif
endif

