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
if s:os_linux
    set nocompatible                        " vundle requires VIM, not VI
    filetype off                            " required by vundle
    set rtp+=$HOME/.vim/bundle/Vundle.vim   " add vundle to vim's runtime path
    call vundle#begin()
    
    " Vim community plugins
    Plugin 'VundleVim/Vundle.vim'           " required by vundle
    Plugin 'lambdalisue/fern.vim'
    Plugin 'vim-airline/vim-airline'
    Plugin 'vim-airline/vim-airline-themes'
    Plugin 'gcmt/taboo.vim'
    Plugin 'mhinz/vim-startify'
    Plugin 'dense-analysis/ale'
    Plugin 'rust-lang/rust.vim'

    " My plugins
    Plugin 'cwshugg/argonaut.vim'
    Plugin 'cwshugg/fops.vim'
    Plugin 'file://' . expand('~/.vim/shuggtools')
    
    call vundle#end()                       " finish vundle setup
    filetype plugin indent on               " required by vundle
    
    " -------------------------- Fern Configuration -------------------------- "
    " FT - File Tree. Utilizes Fern to open a 'project-drawer'-style file tree
    " next to the current editor window.
    function! FT(...)
        let l:file_tree_dir = './'
    
        " if one or more arguments was passed in, we'll parse the first one as
        " the directory path to open with fern
        if a:0 > 0
            let l:file_tree_dir = a:1
        endif
    
        " invoke fern with the selected directory
        execute 'Fern ' . l:file_tree_dir . ' -drawer'
    endfunction
    command! -nargs=* FT call FT(<f-args>)
    
    let g:fern_disable_startup_warnings = 1
    
    
    " ------------------------ Airline Configuration ------------------------- "
    let g:airline_theme='dwarrowdelf'
    
    
    " ------------------------- Taboo Configuration -------------------------- "
    let g:taboo_tab_format=' %N %f%m '
    let g:taboo_renamed_tab_format=' %N %l%m '
    set sessionoptions+=tabpages,globals
    
    " Alias a few tab commands
    command! -nargs=* Tab tabe <args>
    command! -nargs=* TabOpen TabooOpen <args>
    command! -nargs=* TabRename TabooRename <args>
    command! -nargs=* TabReset TabooReset <args>
    
    " ------------------------ Startify Configuration ------------------------ "
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


    " -------------------------- ALE Configuration --------------------------- "
    " Thanks to Peter Malmgren's blog post:
    " https://petermalmgren.com/rc-batch-day-9/

    " Make the sign column always present, so it doesn't go away when all
    " linter issues are fixed. This will be visually nice, as the disappearing
    " of the column will no longer occur, thus not jumping all the characters
    " left and right whenever linting issues arise and are fixed.
    let g:ale_sign_column_always = 1

    " Enable color changing of the sign column
    let g:ale_change_sign_column_color = 1

    " Set up ALE linters
    let g:ale_linters = {
        \ 'rust': ['analyzer'],
    \ }

    " Set up ALE fixers
    let g:ale_fixers = {
        \ 'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'],
    \ }

    " Enable ALE completion, but set a delay of 1 second, so it's not opened
    " all the time; only once I've paused from typing.
    let g:ale_completion_enabled = 1
    let g:ale_completion_delay = 1000

    " Have ALE automatically import completion results from external modules.
    let g:ale_completion_autoimport = 1

    " Prevent ALE from linting when I'm doing things in the buffer,
    " such as leaving insert mode, or modifying a buffer. This creates lots of
    " awful lag while I'm editing.
    let g:ale_lint_on_insert_leave = 0
    let g:ale_lint_on_text_changed = 0

    " Only show virtual text warning messages for the current line.
    let g:ale_virtualtext_cursor = 1

    " Map Ctrl-LeftClick to invoke 'ALEGoToDefinition'
    nnoremap <C-LeftMouse> :ALEGoToDefinition<CR>
endif


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

" Show Vim commands as I type them
set showcmd

" Display page numbers, and make them relative to the current line the cursor
" is on. (I like this; I use the relative line numbers to know how many lines
" to jump/delete/yank/etc. from my current cursor position.)
set number
set relativenumber

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

" set the leader key to a comma
let mapleader = ","

" Disable automatic comment insertion for all file types. (This is when you
" are typing a comment, then press enter, and Vim inserts a comment prefix in
" the new line.)
" 
" Run `:help fo-table` to see a description of each of these settings.
"
" Also, rather than just writing `set formatoptions-=c`, etc.,, I am wrapping
" this in an `augroup`, to prevent *other* plugins from modifying these
" options.  See this StackOverflow post for the inspiration:
"
" https://stackoverflow.com/questions/62943758
augroup FORMATOPTIONS
    autocmd!
    autocmd filetype *
          \ set formatoptions-=c
          \ set formatoptions-=r
          \ set formatoptions-=o
augroup END

" Make Vim display the number of matches to my current search.
set shortmess-=S

" --------------------------- Remaps and Shortcuts --------------------------- "
" remap ':' to ';', so I can type commands with one less keystroke. (Normally
" you have to press Shift + Semicolon, but now, I only have to write Semicolon
" :))
nnoremap ; :
vnoremap ; :

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
        let s:homedir = $HOME

        " look for a desktop location to default to
        let s:desktop_paths = [
            \ s:homedir . '/Desktop',
            \ s:homedir . '/OneDrive - Microsoft/Desktop'
        \ ]
        for s:path in s:desktop_paths
            if isdirectory(s:path)
                " if we found a directory path that's valid, navigate vim into
                " the directory
                execute 'cd ' . s:path
                break
            endif
        endfor
    endif
endif

