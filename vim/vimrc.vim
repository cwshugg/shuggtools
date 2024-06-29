" Connor's Vim Settings


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

" Creates a safe command alias for commands that begin with ':'.
"
" * 'alias' represents the string that will become the new alias.
" * 'source' represents the existing command you wish to create an alias for.
"
" Credit to this StackOverflow post:
" https://stackoverflow.com/questions/3878692/how-to-create-an-alias-for-a-command-in-vim
function! CreateCommandAlias(source, alias)
      exec 'cnoreabbrev <expr> '.a:alias
         \ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:alias.'")'
         \ .'? ("'.a:source.'") : ("'.a:alias.'"))'
endfunction


" ============================ Vundle and Plugins ============================ "
set nocompatible                        " vundle requires VIM, not VI
filetype off                            " required by vundle
set rtp+=$HOME/.vim/bundle/Vundle.vim   " add vundle to vim's runtime path
call vundle#begin()

" Plugin installation
Plugin 'VundleVim/Vundle.vim'           " required by vundle
Plugin 'https://github.com/lambdalisue/fern.vim'
Plugin 'https://github.com/vim-airline/vim-airline'
Plugin 'https://github.com/vim-airline/vim-airline-themes'
Plugin 'https://github.com/gcmt/taboo.vim'
Plugin 'https://github.com/mhinz/vim-startify'

call vundle#end()                       " finish vundle setup
filetype plugin indent on               " required by vundle

" ---------------------------- Fern Configuration ---------------------------- "
" FT - File Tree. Utilizes Fern to open a 'project-drawer'-style file tree next
" to the current editor window.
function! FT(...)
    let l:file_tree_dir = './'

    " if one or more arguments was passed in, we'll parse the first one as the
    " directory path to open with fern
    if a:0 > 0
        let l:file_tree_dir = a:1
    endif

    " invoke fern with the selected directory
    execute 'Fern ' . l:file_tree_dir . ' -drawer'
endfunction
command! -nargs=* FT call FT(<f-args>)

let g:fern_disable_startup_warnings = 1


" -------------------------- Airline Configuration --------------------------- "
"let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='dwarrowdelf'


" --------------------------- Taboo Configuration ---------------------------- "
let g:taboo_tab_format=' %N %f%m '
let g:taboo_renamed_tab_format=' %N %l%m '
set sessionoptions+=tabpages,globals

" Alias a few tab commands
command! -nargs=* Tab tabe <args>
command! -nargs=* TabOpen TabooOpen <args>
command! -nargs=* TabRename TabooRename <args>
command! -nargs=* TabReset TabooReset <args>

" -------------------------- Startify Configuration -------------------------- "
" Persist sessions; re-save an existing session when Vim is quit.
let g:startify_session_persistence = 1

" Specify where to save session files to.
let g:startify_session_dir = '~/.vim/session'

" Enable the use of unicode box-drawing characters for the default cowsay
" start screen.
let g:startify_fortune_use_unicode = 1

" Enable the use of environment variables in file paths.
let g:startify_use_env = 1

" Set left-hand padding for home page text.
let g:startify_padding_left = 4

" Returns a list of Git-Modified files for Startify to include on the home
" page.
function! s:StartifyGitModified()
    let s:repo_root = system('git rev-parse --show-toplevel 2> /dev/null')
    let s:files = systemlist('git ls-files --modified ' . s:repo_root . ' 2> /dev/null')
    return map(s:files, "{'line': v:val, 'path': v:val}")
endfunction

" Returns a list of Git-Untracked files for Startify to include on the home
" page.
function! s:StartifyGitUntracked()
    let s:repo_root = system('git rev-parse --show-toplevel 2> /dev/null')
    let s:files = systemlist('git ls-files --others --exclude-standard ' . s:repo_root . ' 2> /dev/null')
    return map(s:files, "{'line': v:val, 'path': v:val}")
endfunction

" Define what lists to display on the home page.
let g:startify_lists = [
    \ { 'type': 'sessions',                         'header': ['    ────────────── Sessions ───────────────'] },
    \ { 'type': 'files',                            'header': ['    ────────────── MRU Files ──────────────'] },
    \ { 'type': function('s:StartifyGitModified'),  'header': ['    ──────── Git - Modified Files ─────────'] },
    \ { 'type': function('s:StartifyGitUntracked'), 'header': ['    ──────── Git - Untracked Files ────────'] },
    \ ]


" Function used to generate a header for Startify.
function StartifyMakeHeader(...)
    let s:text = [
        \ ' ___      ___ ___  _____ _______',
        \ '|\  \    /  /|\  \|\   _ \  _   \',
        \ '\ \  \  /  / | \  \ \  \\\__\ \  \',
        \ ' \ \  \/  / / \ \  \ \  \\|__| \  \',
        \ '  \ \    / /   \ \  \ \  \    \ \  \',
        \ '   \ \__/ /     \ \__\ \__\    \ \__\',
        \ '    \|__|/       \|__|\|__|     \|__|',
        \ ]

    " Grab some machine-local information
    let s:machine_name = system('hostname 2> /dev/null | tr -d "\n"')
    let s:machine_date = system('date "+%Y-%m-%d %H:%M %p" 2> /dev/null | tr -d "\n"')
    let s:pwd = getcwd()

    let s:text = s:text + [
        \ '',
        \ 'Machine Name:        ' . s:machine_name . '',
        \ 'Machine Datetime:    ' . s:machine_date . '',
        \ 'Working Directory:   ' . s:pwd . '',
        \ ]
    return startify#pad(s:text)
endfunction

" Define a custom header. By encompassing the function call in a string,
" Startify will execute it every time the :Startify command is executed
" (rather than just a single time when Vim is launched).
let g:startify_custom_header = 'StartifyMakeHeader()'


" ============================= General Settings ============================= "
syntax on                               " syntax highlighting
colorscheme dwarrowdelf                 " modifies color scheme
set tabstop=4 shiftwidth=4 expandtab    " tabs = 4 spaces
set softtabstop=4                       " enables backspace to clear out 4 spaces
set autoindent                          " forces vim to auto-indent
filetype indent on
set number                              " displays page numbers
set relativenumber                      " displays page numbers relative to current line
au FileType * set formatoptions-=cro    " disable automatic comment insertion for all file types
set undolevels=1000                     " LOTS of undos available
set backspace=indent,eol,start          " make sure backspace works properly
set ruler                               " enable the bottom-right set of numbers
set sessionoptions+=tabpages,globals    " additional information to save to sessions
set scrolloff=16                        " number of lines to keep above/below cursor when scrolling


" ========================= Line/Column Highlighting ========================= "
set cursorline                          " highlight current line cursor is on
set cursorcolumn                        " highlight current column cursor is on


" ============================= Search Settings ============================== "
set hlsearch                            " highlight search results
set is                                  " highlight searches as you type


" ============================== Mouse Settings ============================== "
set mouse=a                             " enable mouse everywhere


" =========================== Remaps and Shortcuts =========================== "
" the below shortcut allows you to press space to clear highlighted search terms
" thanks to: https://vim.fandom.com/wiki/Highlight_all_search_pattern_matches
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" Set Ctrl-N to invoking `:Startify`, which populates the current buffer with
" the Startify home screen.
nnoremap <C-n> :Startify<cr>

" YF - Yank File. Stores the full path of the current file we are editing in
" the unnamed register.
function! YF()
    let @" = expand("%:p")
endfunction
command! -nargs=* YF call YF(<f-args>)

" Make a few common commands work the same if I accidentally capitalize them.
call CreateCommandAlias("w", "W")
call CreateCommandAlias("q", "Q")


" ============================== gVim Settings =============================== "
if has('gui_running')
    set guifont=Consolas:h11            " set gvim font
    set guioptions-=m                   " remove menu bar
    set guioptions-=T                   " remove toolbar
    set guioptions-=e                   " remove GUI tabs and use terminal tabs

    " remap visual and normal mode yanks (copies) to the system clipboard
    nnoremap y "+y                      
    vnoremap y "+y
    
    " if we aren't editing a file, we'll 'cd' to the windows desktop:
    let s:filename = CCO('file')
    if stridx(s:filename, '[No Name]') > -1
        " get the home directory and append 'Desktop' onto it. Assuming
        " this is a windows machine, that means we'll save any new files
        " to the desktop, rather than to our user home directory
        let s:desktop = s:homedir . '/Desktop'
        let s:cmd = 'cd ' . s:desktop
        execute s:cmd
    endif
endif

