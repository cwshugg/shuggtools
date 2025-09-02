" Whitespace helpers
"
" These are small helper functions I've found/written to trim whitespace and
" convert tabs to spaces.
"
" Thanks to this StackExchange post:
" https://vi.stackexchange.com/questions/454/whats-the-simplest-way-to-strip-trailing-whitespace-from-all-lines-in-a-file
"
"   Connor Shugg

" Trims trailing whitespace from the contents of the current buffer.
function! TrimTrailingWhitespace()
    let l:save = winsaveview()  " save window state
    keeppatterns %s/\s\+$//e    " remove all extra whitespace at the end of each line
    call winrestview(l:save)    " restore the old window state
endfunction

command! TrimTrailingWhitespace call TrimTrailingWhitespace()

" Converts tab characters ('\t') to spaces.
function! TabsToSpaces()
    " get the current shiftwidth value and use it to create a string
    " representing the number of spaces to replace each tab with
    let l:shift_width = &shiftwidth
    let l:space_str= repeat(' ', l:shift_width)

    let l:save = winsaveview()          " save window state
    keeppatterns %s/\t/\=space_str/ge   " convert all tabs to spaces
    call winrestview(l:save)            " restore the old window state
endfunction

command! TabsToSpaces call TabsToSpaces()

" Function that runs *all* of the above functions.
function! WhitespaceCleanup()
    call TrimTrailingWhitespace()
    call TabsToSpaces()
endfunction

command! WhitespaceCleanup call WhitespaceCleanup()

