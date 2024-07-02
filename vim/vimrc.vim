" Connor's Vim Settings


" =============================== OS Detection =============================== "
let s:os_linux = has('unix')
let s:os_windows = has('win32')
let s:is_gui = has('gui_running')


" ============================= Helper Functions ============================= "
" CaptureCommandOutput - Capture Command Output. Runs the given command and returns the output
function! CaptureCommandOutput(cmd)
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

" Create a shortcut to bring up Startify on the current buffer via Ctrl-N
nnoremap <silent> <C-n> :Startify<CR>


" ============================= General Settings ============================= "
" Enable syntax highlighting and configure my theme.
syntax on
colorscheme dwarrowdelf

" Configure Vim to recognize a tab as exactly 4 spaces, and configure the Tab
" and Backspace key to delete 4 spaces at a time when deleting/inserting tabs.
set tabstop=4 shiftwidth=4 expandtab
set softtabstop=4

" Force Vim to auto-indent
set autoindent
filetype indent on

" Display page numbers, and make them relative to the current line the cursor
" is on. (I like this; I use the relative line numbers to know how many lines
" to jump/delete/yank/etc. from my current cursor position.)
set number
set relativenumber

" Disable automatic comment insertion for all file types. (This is when you
" are typing a comment, then press enter, and Vim inserts a comment prefix in
" the new line.)
au FileType * set formatoptions-=cro

" Give me LOTS of undos!
set undolevels=1000

" Configure backspace to delete automatically-inserted indentation, line
" breaks, etc.
set backspace=indent,eol,start

" Turn on the ruler, which shows the line and column number of the cursor in
" the bottom-right
set ruler

" Save globals and tag names when Vim sessions are saved
set sessionoptions+=tabpages,globals

" Highlight the current line AND column the cursor is on:
set cursorline
set cursorcolumn

" Highlight search results, and highlight/search as you type
set hlsearch
set is

" Enable the mouse everywhere in Vim
set mouse=a

" --------------------------- Remaps and Shortcuts --------------------------- "
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


" ============================== GVim Settings =============================== "
if s:is_gui
    set guioptions-=m                   " remove menu bar
    set guioptions-=T                   " remove toolbar
    set guioptions-=e                   " remove GUI tabs and use terminal tabs

    " remap visual and normal mode yanks (copies) to the system clipboard
    nnoremap y "+y                      
    vnoremap y "+y
    
    " If we're on Windows, set the font to Consolas
    if s:os_windows
        set guifont=Consolas:h11
    endif

    " If we're on Windows, and we just opened a new buffer that's not attached
    " to a file, we'll `cd` vim to the Windows desktop. This is where I want
    " new files to be saved on Windows.
    let s:filename = CaptureCommandOutput('file')
    if stridx(s:filename, '[No Name]') > -1 && s:os_windows
        let s:homedir = '$HOME'
        let s:desktop = s:homedir . '/Desktop'
        let s:cmd = 'cd ' . s:desktop
        execute s:cmd
    endif
endif

