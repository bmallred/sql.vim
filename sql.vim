" SQL script
" Author: Bryan Allred
"
" History
" -------
" Modified from [sybase.vim](https://github.com/vim-scripts/sybase.vim)
" Author: Scott James
"
" Modified from [sqlplus.vim](http://vim.sourceforge.net/scripts/script.php?script_id=97)
" Author: Jamis Buck
"
" Notes
" -----
" Default values are given and may be overridden. To quickly switch database
" connection settings press <F8> in normal mode. By not entering a value in
" one of the input dialogs it retains the previous value.
"
" Dependencies
" ------------
" The command line tool `sqsh`. This could probably be easily swapped out with
" `isql` or something similar as well.
"

let g:sqshcom_path              = "sqsh -w1000 "
let g:sqshcom_common_commands   = ""
let g:sqshcom_style             = "vert"
let g:sqshcom_server            = "localhost"
let g:sqshcom_database          = "master"
let g:sqshcom_userid            = "sa"
let g:sqshcom_passwd            = ""

function! AE_setDatabase( server, database, userid, passwd )
    if a:server != ""
        let g:sqshcom_server = a:server
    endif
    if a:database != ""
        let g:sqshcom_database = a:database
    endif
    if a:userid != ""
        let g:sqshcom_userid = a:userid
    endif
    if a:passwd != ""
        let g:sqshcom_passwd = a:passwd
    endif

    if g:sqshcom_server == ""
        echo "[SQSH] Invalid server"
    endif
endfunction

function! AE_changeDatabase()
    let server = inputdialog("[SQSH] Server: ")
    let database = inputdialog("[SQSH] Database: ")
    let userid = inputdialog("[SQSH] User ID: ")
    let passwd = inputdialog("[SQSH] Password: ")

    call AE_setDatabase(server, database, userid, passwd)
endfunction

function! AE_configureOutputWindow()
    set ts=4 buftype=nofile nowrap sidescroll=5 listchars+=precedes:<,extends:>
    normal $G

    " Trim empty lines
    while getline(".") == ""
        normal dd
    endwhile

    normal 1G
    let l:newheight = line("$")
    if l:newheight < winheight(0)
        exe "resize " . l:newheight
    endif
endfunction

function! AE_execQuery( sql_query )
    new
    let l:tmpfile = tempname() . ".sql"
    let l:oldo = @o
    let @o="i" . g:sqshcom_common_commands . a:sql_query
    let l:pos = match( @o, ";$" )
    if l:pos < 0
        let @o=@o . ";"
    endif

    let @o=@o . "\n"
    normal @o
    let @o=l:oldo
    exe "silent write " . l:tmpfile
    close

    new
    let l:cmd = g:sqshcom_path . "-U " . g:sqshcom_userid . " -P " . g:sqshcom_passwd . " -S " . g:sqshcom_server . " -D " . g:sqshcom_database . " -m " . g:sqshcom_style
    let l:cmd = l:cmd . " -i" . l:tmpfile
    silent exe "1,$!" . l:cmd

    call AE_configureOutputWindow()
    call delete( l:tmpfile )
endfunction

function! AE_execLiteralQuery( sql_query )
    let l:query = a:sql_query
    let l:idx = stridx( l:query, "\n" )
    while l:idx >= 0
        let l:query = strpart( l:query, 0, l:idx ) . " " . strpart( l:query, l:idx+1 )
        let l:idx = stridx( l:query, "\n" )
    endwhile

    call AE_execQuery( l:query )
endfunction

function! AE_execQueryUnderCursor()
    exe "silent norm! ?\\c[^.]*\\<\\(select\\|update\\|delete\\)\\>\nv/;\nh\"zy"
    noh
    call AE_execLiteralQuery( @z )
endfunction

" Mappings
au FileType sql map <F8> :call AE_changeDatabase()<CR>
au FileType sql vmap <F8> "zy:call AE_execLiteralQuery( @z )<CR>

cabbrev select Select
cabbrev update Update
cabbrev db     DB
cabbrev sql    SQL
