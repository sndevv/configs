" engspchk.vim: Vim syntax file
" Language:    English
" Author:      Dr. Charles E. Campbell, Jr. <Charles.Campbell.1@gsfc.nasa.gov>
" Last Change: Jan 22, 2004
" Version:     42
" License:     GPL (Gnu Public License)
"
" Environment Variables:
"
"  $CVIMSYN         : points to a directory holding the engspchk dictionaries
"                     ie., <engspchk.dict>, <engspchk.usr>, <engspchk.rare>
"
"  g:cvimsyn        : Vim variable, settable in your <.vimrc>, that points to
"                     a directory holding the user word database.
"
"  g:spchklang      : override name-of-file prefix with desired language
"                     prefix/filename (ie. gerspchk.vim ger frspchk.vim fr etc)
"
"  g:spchkautonext  : if this variable exists, then \es and \et will also
"                     automatically jump to the next spelling error (\en).
"                     \ea, if a word is selected, will also do a \en.
"
"  g:spchkdialect   : pick a dialect (no effect if spchklang not "eng")
"                     = "usa" : pick United States dialect
"                     = "uk"  : pick United Kingdom dialect
"                     = "can" : pick Canadian dialect
"
"  g:spchknonhl     : apply engspchk'ing to all non-syntax-highlighted text
"                     (done if variable exists)
"
"  g:spchkpunc =0   : default, no new behavior
"              =1   : check for some simple English punctuation problems
"                     non-capitalized word after ellipse (... a)
"                     non-capitalized word after sentence ending character
"                     ([.?!])
"  g:spchksilent= 0 : default
"               = 1 : usual Sourcing... and Loading messages suppressed
"
"  If you make a Dialect highlighting group, it will be used instead
"
" Finding Dictionaries:
"      If        g:cvimsyn exists, it is tried
"      Otherwise $CVIMSYN is tried
"      Otherwise each path on the runtimepath is tried
"      Otherwise quit with an error message
"
"      "Trying" involves checking if the spelling dictionary is
"      filereadable(); if not, then if filereadable(expand())
"      works.  If a combination works, that path is set into
"      g:cvimsyn.
"
"      Note that the "eng" prefix can be changed via setting
"      g:spchklang or renaming <engspchk.vim>.  Then engspchk
"      will load:  (elide the [])
"
"         [eng]spchk.dict  Main word dictionary
"         [eng]spchk.usr   User's personal word dictionary
"         [eng]spchk.rare  English only -- Webster's 1913 dictionary extra words
"                          and unusual words culled from previous
"                          <engspchk.dict> wordlists.
"
" Included Maps:  maps use <mapleader>, which by default is \
"  \ec : load engspchk
"  \et : add  word under cursor into database (temporarily - ie. just this file)
"  \es : save word under cursor into database (permanently)  (requires $CVIMSYN)
"  \en : move cursor to the next     spelling error
"  \ep : move cursor to the previous spelling error
"  \ea : look for alternative spellings of word under cursor
"  \ed : toggle Dialect highlighting (Warning/Error)
"  \ee : end engspchk
"  \eT : make word under cursor a BadWord (temporarily)
"        (opposite of \et)
"  \eS : make word under cursor a BadWord (permanently)  (requires $CVIMSYN)
"        (opposite of \es)
"        --removes words from user dictionary, not <*.dict>--
"
" Maps for Alternatives Window Only:
"  <cr> : on alternatives line, will put word under cursor in
"         searchword's stead
"  <tab>: like <cr>, but does a global substitute changing all such
"         mispelled words to the selected alternate word.
"  q    : will quit the alternate-word window
"  :q   : will quit the alternate-word window
"
" Usage:
"  Simply source the file in.  It does *not* do a "syntax clear", so that means
"  that you can usually just source it in on top of other highlighting.
"  NOTE: not all alphas of 6.0 support plugins, <silent>, etc.
"        engspchk can't check for them; all their versions are 600.
"        Besides, 6.1 is out nowadays.

" NON ENGLISH LANGUAGES:
"  There are versions of this script for languages other than English.
"  I've tried to make this script work for non-English languages by
"
"    (a) allowing one to rename the script with a different prefix
"    (b) using that prefix to load the non-English language dictionary
"
"  If you come up with a version for another language, please let me
"  know where on the web it is so that I can help make it known.
"
"    Dutch     : http://www.thomer.com/thomer/vi/nlspchk.vim.gz
"    German    : http://jeanluc-picard.de/vim/gerspchk/gerspchk.vim.gz
"    Hungarian : http://vim.sourceforge.net/scripts/script.php?script_id=22
"    Polish    : http://strony.wp.pl/wp/kostoo/download.htm#vim
"    Yiddish   : http://www.cs.uky.edu/~raphael/yiddish/vim.tar.gz

" Internal Functions: for vim versions 5.4 or later
"  SpchkSave(newword) : saves the word into <$CVIMSYN/engspchk.usr>
"  SpchkPrv()         : enables \ep map
"  SpchkNxt()         : enables \en map
"
"------------------------------------------------------------------------------

" what language am I -- based on name of this file
"                    -or- if it previously exists
"   ie. engspchk gerspchk nlspchk hngspchk yidspchk etc
"       eng      ger      nl      hng      yid
"
"  b:spchklang: dictionary language prefix
"  b:spchkfile: prefix based on name of this file
if exists("g:spchklang")
 let b:spchklang= substitute(g:spchklang,'spchk\.vim',"","e")
 let b:spchkfile= substitute(expand("<sfile>:t"),'spchk\.vim',"","e")
else
 let b:spchklang= substitute(expand("<sfile>:t"),'spchk\.vim',"","e")
 let b:spchkfile= b:spchklang
endif
let s:spchkfile= b:spchkfile
let b:Spchklang=substitute(b:spchklang,'\(.\)\(.*\)$','\u\1\2','')

if exists("mapleader") && mapleader != ""
 let s:usermaplead= mapleader
else
 let s:usermaplead= "\\"
endif
let s:mapleadstring= escape(s:usermaplead,'\ ')

" Quick load:
if !exists("s:loaded_".s:spchkfile."spchk")
 let s:loaded_{b:spchkfile}spchk=  1
 let s:spchkversion             = 40
 let s:engspchk_loadcnt         =  0

 " ---------------------------------------------------------------------
 " Pre-Loading Interface:
 "       \ec invokes <Plug>LoadSpchk which invokes <SID>LoadSpchk()
 if !hasmapto('<Plug>LoadSpchk')
  nmap <unique> <Leader>ec <Plug>LoadSpchk
 endif

 " Global Maps
 nmap <silent> <script> <Plug>LoadSpchk :call <SID>LoadSpchk()<CR>

 " LoadSpchk: set up and actually load <engspchk.vim>
 silent! fu! <SID>LoadSpchk()
   " prevent unnecessary re-loading of engspchk
   if exists("b:engspchk_loaded")
    return
   endif
   let b:engspchk_loaded= 1
   let s:engspchk_loadcnt= s:engspchk_loadcnt + 1
   let b:hidden         = &hidden
   set hidden

   let b:ch = &ch
   if exists("g:spchklang")
    let b:spchklang= substitute(g:spchklang,'spchk\.vim',"","e")
    let b:spchkfile= s:spchkfile
   else
    let b:spchklang= s:spchkfile
    let b:spchkfile= s:spchkfile
   endif
   let b:Spchklang=substitute(b:spchklang,'\(.\)\(.*\)$','\u\1\2','')

   set ch=7
   exe 'runtime plugin/'.b:spchkfile.'spchk.vim'
   let &ch  = b:ch
   unlet b:ch
 endfunction

" ---------------------------------------------------------------------

 " Pre-Loading DrChip menu support:
 if exists("did_install_default_menus") && has("menu")
  if !exists("g:DrChipTopLvlMenu")
   let g:DrChipTopLvlMenu= "DrChip."
  endif
  exe 'menu '.g:DrChipTopLvlMenu.'Load\ Spelling\ Checker<tab>'.s:mapleadstring.'ec	<Leader>ec'
 endif

 finish  " end pre-load
endif

" ================================
" Begin Actual Loading of Engspchk
" ================================

if !exists("g:spchksilent") || !g:spchksilent
 echomsg "Sourcing <".b:spchklang."spchk.vim>  (version ".s:spchkversion.")"
endif

if exists("did_install_default_menus") && has("menu")
 " remove \ec from DrChip menu
 silent! exe 'unmenu '.g:DrChipTopLvlMenu.'Load\ Spelling\ Checker'
endif

" check if syntax highlighting is on and, if it isn't, enable it
if !exists("syntax_on")
 if !has("syntax")
  echomsg "Your version of vim doesn't have syntax highlighting support"
  finish
 endif
 echomsg "Enabling syntax highlighting"
 syn enable
endif

" check if user has specified a dialect
if b:spchklang == "eng" && !exists("g:spchkdialect")
 let g:spchkdialect= "usa"
endif

" ---------------------------------------------------------------------

" HLTEST: tests if a highlighting group has been set up
fun! s:HLTEST(hlname)
  let id_hlname= hlID(a:hlname)
  let fg_hlname= synIDattr(synIDtrans(hlID(a:hlname)),"fg")
  if id_hlname == 0 || fg_hlname == 0 || fg_hlname == -1
   return 0
  endif
  return 1
endfun

" ---------------------------------------------------------------------

" check if user has specified a Dialect highlighting group.
" If not, this script will highlight-link it to a Warning highlight group.
" If that hasn't been defined, then this script will define it.
if !s:HLTEST("Dialect")
 if !s:HLTEST("Warning")
  hi Warning term=NONE cterm=NONE gui=NONE ctermfg=black ctermbg=yellow guifg=black guibg=yellow
 endif
 hi link Dialect Warning
endif

" check if user has specified a RareWord highlighting group
" If not, this script will highlight-link it to a Warning highlight group.
" If that hasn't been defined, then this script will define it.
if  !<SID>HLTEST("RareWord")
 if !<SID>HLTEST("Warning")
  hi Notice term=NONE cterm=NONE gui=NONE ctermfg=black ctermbg=cyan guifg=black guibg=cyan
 endif
 hi link RareWord Notice
endif

" ---------------------------------------------------------------------

" SaveMap: this function sets up a buffer-variable (b:spchk_restoremap)
"          which will be used by StopDrawIt to restore user maps
"          mapchx: either <something>  which is handled as one map item
"                  or a string of single letters which are multiple maps
"                  ex.  mapchx="abc" and maplead='\': \a \b and \c are saved
fu! <SID>SaveMap(mapmode,maplead,mapchx)
  " save <Leader>map
  if maparg(a:maplead.a:mapchx,a:mapmode) != ""
    let b:spchk_restoremap= a:mapmode."map ".a:maplead.a:mapchx." ".maparg(a:maplead.a:mapchx,a:mapmode)."|".b:spchk_restoremap
    exe a:mapmode."unmap ".a:maplead.a:mapchx
   endif
endfunction

" ---------------------------------------------------------------------
"  User Interface:
let b:spchk_restoremap= ""
call <SID>SaveMap("n",s:usermaplead,"ea")
call <SID>SaveMap("n",s:usermaplead,"ed")
call <SID>SaveMap("n",s:usermaplead,"ee")
call <SID>SaveMap("n",s:usermaplead,"en")
call <SID>SaveMap("n",s:usermaplead,"ep")
call <SID>SaveMap("n",s:usermaplead,"et")
call <SID>SaveMap("n",s:usermaplead,"eT")
call <SID>SaveMap("n",s:usermaplead,"es")
call <SID>SaveMap("n",s:usermaplead,"eS")

" Maps to facilitate entering new words
"  use  temporarily (\et)   remove temporarily (\eT)
"  save permanently (\es)   remove permanently (\eS)
nmap <silent> <Leader>et :syn case ignore<CR>:exe "syn keyword GoodWord transparent	" . expand("<cword>")<CR>:syn case match<CR>:if exists("g:spchkautonext")<BAR>call <SID>SpchkNxt()<BAR>endif<CR>
nmap <silent> <Leader>eT :syn case ignore<CR>:exe "syn keyword BadWord "	  . expand("<cword>")<CR>:syn case match<CR>

" \es: saves a new word to a user dictionary (g:cvimsyn/engspchk.usr).
"      Uses vim-only functions to do save, thereby avoiding external programs
nmap <silent> <Leader>es    :call <SID>SpchkSave(expand("<cword>"))<CR>
nmap <silent> <Leader>eS    :call <SID>SpchkRemove(expand("<cword>"))<CR>

" \ed: toggle between Dialect->Warning/Error
" \ee: end engspchk
nmap <silent> <Leader>ed	:call <SID>SpchkToggleDialect()<CR>
nmap <silent> <Leader>er	:call <SID>SpchkToggleRareWord()<CR>
nmap <silent> <Leader>ee	:call <SID>SpchkEnd()<CR><bar>:redraw!<CR>

" mouse stuff:
if exists("g:spchkmouse") && g:spchkmouse > 0 && &mouse =~ "[an]"
 call <SID>SaveMap("n","","<leftmouse>")
 call <SID>SaveMap("n","","<rightmouse>")
 nnoremap <silent> <leftmouse>   :call <SID>SpchkLeftMouseA()<CR>
 nnoremap <silent> <rightmouse>  <leftmouse>:call <SID>SpchkRightMouse()<CR>
endif

" DrChip Menu
if exists("did_install_default_menus") && has("menu")
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Alternative\ spellings<tab>'.s:mapleadstring.'ea		\ea'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Move\ to\ next\ spelling\ error<tab>'.s:mapleadstring.'en	\en'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Move\ to\ previous\ spelling\ error<tab>'.s:mapleadstring.'ep	\ep'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Save\ word\ to\ user\ dictionary\ (temporarily)<tab>'.s:mapleadstring.'et	\et'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Save\ word\ to\ user\ dictionary\ (permanently)<tab>'.s:mapleadstring.'es	\es'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Remove\ word\ from\ user\ dictionary\ (temporarily)<tab>'.s:mapleadstring.'eT	\eT'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Remove\ word\ from\ user\ dictionary\ (permanently)<tab>'.s:mapleadstring.'eS	\eS'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Dialect:\ toggle\ Warning/Error\ highlighting<tab>'.s:mapleadstring.'ed	\ed'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.RareWord:\ toggle\ Warning/Error\ highlighting<tab>'.s:mapleadstring.'er	\er'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Load\ '.b:Spchklang.'spchk<tab>'.s:mapleadstring.'ec		\ec'
 exe 'menu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.End\ '.b:Spchklang.'spchk<tab>'.s:mapleadstring.'ee		\ee'
endif

" ---------------------------------------------------------------------

" SpchkSave:
fu! <SID>SpchkSave(newword)
  silent 1sp
  exe "silent e ".g:cvimsyn."/".b:spchklang."spchk.usr"
  $put='syn keyword GoodWord transparent	'.a:newword
  silent wq
  syn case ignore
  exe "syn keyword GoodWord transparent ".a:newword
  syn case match
  if exists("g:spchkautonext")
   call s:SpchkNxt()
  endif
endfunction

" ---------------------------------------------------------------------

" SpchkRemove: implements \eS : depends on SpchkSave's putting one
"              user word per line in <*spchk.usr>.  This function
"              actually will delete the entire line containing the
"              new BadWord.
fu! <SID>SpchkRemove(killword)
  silent 1sp
  exe "silent e ".g:cvimsyn."/".b:spchklang."spchk.usr"
  exe "silent g/".a:killword."/d"
  silent wq
  syn case ignore
  exe "syn keyword BadWord ".a:killword
  syn case match
endfunction

" ---------------------------------------------------------------------

" IGNORE CASE
syn case ignore

" Language Specials
" Ignore upper/lower case
" For non-English, allow accented (8-bit) characters as keywords
if b:spchklang !=? "eng"
 setlocal isk+=-,',`,128-255

elseif exists("g:spchkpunc") && g:spchkpunc != 0
 " These patterns are thanks to Steve Hall
 " Flag as error a non-capitalized word after ellipses
 syn match GoodWord	"\.\.\. \{0,2}\l\@="
 " but not non-capitalized word after ellipses plus period
 syn match BadWord "\.\.\.\. \{0,2}\l"

 " non-lowercased end-of-word problems
 " required: period/question-mark/exclamation-mark
 " optional: double/single quote
 " required: return/return-linefeed/space/two spaces
 " required: lowercase letter
 syn match BadWord "[.?!][\"']\=[\r\n\t ]\+\l"
endif

" ---------------------------------------------------------------------
" Find Dictionary Path:

" Set up g:cvimsyn (a vim variable) to the path to the <...spchk.dict>
if !exists("g:cvimsyn")
 let g:cvimsyn= $CVIMSYN
endif

"call Decho("trying g:cvimsyn<".g:cvimsyn.">")
if !filereadable(g:cvimsyn."/".b:spchklang."spchk.dict")
 let g:cvimsyn= expand(g:cvimsyn)
" call Decho("trying g:cvimsyn<".g:cvimsyn.">")

 if !filereadable(g:cvimsyn."/".b:spchklang."spchk.dict")
  let rtp= &rtp

  " search runtimepath
  while rtp != ""
   " get leftmost path from rtp
   let g:cvimsyn= substitute(rtp,',.*$','','')."/CVIMSYN"
"   call Decho("trying g:cvimsyn<".g:cvimsyn.">")

   " remove leftmost path from rtp
   if stridx(rtp,',') == -1
    let rtp= ""
   else
    let rtp= substitute(rtp,'.\{-},','','e')
   endif

   " see if dictionary is readable
   if filereadable(g:cvimsyn."/".b:spchklang."spchk.dict")
    break
   else
    " attempt to expand and see if dictionary is readable then
    let g:cvimsyn= expand(g:cvimsyn)
"    call Decho("trying g:cvimsyn<".g:cvimsyn.">")
    if filereadable(g:cvimsyn."/".b:spchklang."spchk.dict")
     break
    endif
   endif
  endwhile
 endif
endif

" ---------------------------------------------------------------------

" Detect whether BadWords should be detected/highlighted inside comments.
" This can be done only for those syntax files' comment blocks that
" contains=@cluster.  The code below adds GoodWord and BadWord to various
" clusters.  If your favorite syntax comments are not included, send a note
let s:incomment= 0
if     &ft == "amiga"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "bib"
  syn cluster bibVarContents     	contains=GoodWord,BadWord
  syn cluster bibCommentContents 	contains=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "c" || &ft == "cpp"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "csh"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "dcl"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "fortran"
  syn cluster fortranCommentGroup	add=GoodWord,BadWord
  syn match   fortranGoodWord contained	"^[Cc]\>"
  syn cluster fortranCommentGroup	add=fortranGoodWord
  hi link fortranGoodWord fortranComment
  let s:incomment=1
elseif &ft == "sh" || &ft == "ksh" || &ft == "bash"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
elseif &ft == "tex"
  syn cluster Spell		add=GoodWord,BadWord
  syn cluster texMatchGroup		add=GoodWord,BadWord
  let s:incomment=2
elseif &ft == "vim"
  syn cluster Spell		add=GoodWord,BadWord
  let s:incomment=1
endif

" attempt to infer spellcheck use - is the Spell cluster included somewhere?
if s:incomment == 0
 let keep_rega= @a
 redir @a
 silent syn
 redir END
 if match(@a,"@Spell") != -1
  syn cluster Spell		add=GoodWord,BadWord
  syn cluster texMatchGroup		add=GoodWord,BadWord
  let s:incomment=1
 endif
 let @a= keep_rega
endif

" ======================
" Loading The Dictionary
" ======================
"let loadtime= localtime()		" DBG
if !filereadable(g:cvimsyn."/".b:spchklang."spchk.dict")
 echomsg b:Spchklang."spchk is unable to find <".b:spchklang."spchk.dict>!"
 finish
elseif !exists("g:spchksilent") || !g:spchksilent
 echomsg "Loading  <".g:cvimsyn."/".b:spchklang."spchk.dict".">"
 exe "so ".g:cvimsyn."/".b:spchklang."spchk.dict"
else
 exe "so ".g:cvimsyn."/".b:spchklang."spchk.dict"
endif
"let difftime= localtime() - loadtime	" DBG
"call Decho("dict    : ".difftime." sec")	" DBG

" ---------------------------------------------------------------------

" The Raison D'Etre! Highlight the BadWords
" I've allowed '`- in non-English words
"            
"    s:incomment
"        0       BadWords matched outside normally highlighted sections
"        1       BadWords matched inside @Spell, etc highlighting clusters
"        2       both #0 and #1
if s:incomment == 0 || s:incomment == 2 || exists("g:spchknonhl")
 if b:spchklang == "eng"
  syn match BadWord	"\<[^[:punct:][:space:][:digit:]]\{2,}\>"	 contains=RareWord,Dialect
 else
  syn match BadWord	"\<[^[!@#$%^&*()_+=[\]{};:",<>./?\\|[:space:][:digit:]]\{2,}\>" contains=RareWord,Dialect
 endif
endif
if s:incomment == 1 || s:incomment == 2
 if b:spchklang == "eng"
  syn match BadWord contained	"\<[^[:punct:][:space:][:digit:]]\{2,}\>"	 contains=RareWord,Dialect
  syn cluster Spell add=Dialect,RareWord
 else
  syn match BadWord contained	"\<[^[!@#$%^&*()_+=[\]{};:",<>./?\\|[:space:][:digit:]]\{2,}\>" contains=RareWord,Dialect
 endif
endif

" Contractions and other language special handling
if b:spchklang ==? "eng"
 " Note: *matches* need to follow the BadWord so that they take priority!
 " Abbreviations, Possessives, Etc.  For these to be recognized properly,
 " these contractions' word prior to the "'" has been removed from the
 " keyword dictionaries above and moved here.
 syn case ignore
 syn match GoodWord	"\<\(shouldn't've\|couldn't've\|mightn't've\|wouldn't've\|mustn't've\|needn't've\|hadn't've\|mayn't've\|shan't've\|she'll've\|should've\|shouldn't\|they'd've\|can't've\|could've\|couldn't\|he'll've\|might've\|mightn't\|ought've\|oughtn't\|shall've\|she'd've\|there'll\|there've\|where'er\|won't've\|would've\|wouldn't\|you'd've\|daren't\|doesn't\|haven't\|he'd've\|howe'er\|it'd've\|must've\|mustn't\|needn't\|there'd\|they'll\|they're\|they've\|we'd've\|weren't\|what'll\|what've\|aren't\|ch'ing\|didn't\|hadn't\|hasn't\|i'd've\|may've\|mayn't\|shan't\|she'll\|should\|they'd\|wasn't\|who've\|you'll\|you're\|you've\|ain't\|can't\|cap'n\|could\|don't\|haven\|he'll\|isn't\|might\|ne'er\|ought\|shall\|she'd\|there\|we'll\|we're\|we've\|where\|won't\|would\|you'd\|e'er\|he'd\|howe\|i'll\|i've\|must\|need\|o'er\|shan\|they\|we'd\|what\|are\|can\|cap\|don\|i'd\|i'm\|may\|she\|who\|won\|you\|he\|it\|ne\|we\|a\|i\|o\)\>"
 syn match GoodWord	"\(et al\|ph\.d\|e\.g\|i\.e\|mrs\|dr\|ex\|jr\|mr\|ms\|mba\|pm\)\."
 syn match GoodWord	"ex-"
 syn match GoodWord	"'s\>"
 let g:spchkacronym= 1

 " these are proper English words but vim has assigned special meaning to them,
 " so they may not be used in keyword lists
 syn match GoodWord	"\<\(transparent\|contained\|contains\|conceal\|display\|extend\|fold\|skip\)\>"
 syn case match
endif

if exists("g:spchkacronym")
 " Pan Shizhu suggested that two or more capitalized letters
 " should be treated as an abbreviation and accepted
 syn match GoodWord	"\<\u\{2,}\>"
endif

" allows <engspchk.vim> to work better with LaTeX
if &ft == "tex"
  syn match GoodWord	"{[a-zA-Z|@]\+}"lc=1,me=e-1
  syn match GoodWord	"\[[a-zA-Z]\+]"lc=1,me=e-1
  syn match texGoodWord	"\\[a-zA-Z]\+"lc=1,me=e-1	contained
  hi link texGoodWord texComment
  syn cluster texCommentGroup	add=texGoodWord
endif

" ignore web addresses and \n for newlines
syn match GoodWord transparent	"\<http://www\.\S\+"
syn match GoodWord transparent	"\\n"

" load user's personal dictionary
"let loadtime= localtime()		" DBG
if filereadable(g:cvimsyn."/".b:spchklang."spchk.usr") > 0
 if !exists("g:spchksilent") || !g:spchksilent
  echomsg "Loading  <".b:spchklang."spchk.usr>"
 endif
 exe "so ".g:cvimsyn."/".b:spchklang."spchk.usr"
 if !filewritable(g:cvimsyn."/".b:spchklang."spchk.usr")
  echomsg "***warning*** ".g:cvimsyn."/".b:spchklang."spchk.usr isn't writable"
 endif
else
 if !filewritable(g:cvimsyn)
  echomsg "***warning*** ".g:cvimsyn."/ directory is not writable"
 endif
endif
"let difftime= localtime() - loadtime	" DBG
"call Decho("personal: ".difftime." sec")	" DBG

" load in dialect dictionary
"let loadtime= localtime()		" DBG
if b:spchklang ==? "eng" && filereadable(g:cvimsyn."/engspchk.dialect") > 0
 if !exists("g:spchksilent") || !g:spchksilent
  echomsg "Loading  <engspchk.dialect> - ".g:spchkdialect." selected"
 endif
 exe "so ".g:cvimsyn."/engspchk.dialect"
endif
"let difftime= localtime() - loadtime	" DBG
"call Decho("dialect : ".difftime." sec")	" DBG

" load in proper words dictionary
"let loadtime= localtime()		" DBG
if b:spchklang ==? "eng" && filereadable(g:cvimsyn."/engspchk.proper") > 0
 if !exists("g:spchksilent") || !g:spchksilent
  echomsg "Loading  <engspchk.proper>"
 endif
 exe "so ".g:cvimsyn."/engspchk.proper"
endif
"let difftime= localtime() - loadtime 	" DBG
"call Decho("proper  : ".difftime." sec")	" DBG

" load in rare/unusual words dictionary
"let loadtime= localtime()		" DBG
if b:spchklang ==? "eng" && filereadable(g:cvimsyn."/engspchk.rare") > 0
 if !exists("g:spchksilent") || !g:spchksilent
  echomsg "Loading  <engspchk.rare>"
 endif
 exe "so ".g:cvimsyn."/engspchk.rare"
endif
"let difftime= localtime() - loadtime	" DBG
"call Decho("rare    : ".difftime." sec")	" DBG

" RESUME CASE SENSITIVITY
syn case match

" BadWords are highlighted with Error highlighting (by default)
hi link BadWord	Error

" ---------------------------------------------------------------------
" Functions: Support for moving to next/previous spelling error
nmap <silent> <Leader>en	:call <SID>SpchkNxt()<CR>
nmap <silent> <Leader>ep	:call <SID>SpchkPrv()<CR>

" ignores people's middle-name initials
syn match   GoodWord	"\<[A-Z]\."

" -------------------------------------------------------------------
" SpchkNxt: calls this function to search for next spelling error (\en)
fu! <SID>SpchkNxt()
  let errid   = synIDtrans(hlID("Error"))
  let lastline= line("$")
  let curcol  = 0
  let fenkeep= &fen
  set nofen

  norm! w

  " skip words until we find next error
  while synIDtrans(synID(line("."),col("."),1)) != errid
    norm! w
    if line(".") == lastline
      let prvcol=curcol
      let curcol=col(".")
      if curcol == prvcol
        break
      endif
    endif
  endwhile

  " cleanup
  let &fen= fenkeep
  if foldlevel(".") > 0
   norm! zO
  endif
  unlet curcol
  unlet errid
  unlet lastline
  if exists("prvcol")
    unlet prvcol
  endif
endfunction

" -------------------------------------------------------------------
" SpchkPrv: calls this function to search for previous spelling error (\ep)
fu! <SID>SpchkPrv()
  let errid = synIDtrans(hlID("Error"))
  let curcol= 0
  let fenkeep= &fen
  set nofen

  norm! b

  " skip words until we find previous error
  while synIDtrans(synID(line("."),col("."),1)) != errid
"   call Decho("SpchkPrv: word<".expand("<cword>")."> hl=".synIDtrans(synID(line("."),col("."),1))." errid=".errid)
    norm! b
    if line(".") == 1
      let prvcol=curcol
      let curcol=col(".")
      if curcol == prvcol
        break
      endif
    endif
  endwhile
"  call Decho("SpchkPrv: word<".expand("<cword>")."> hl=".synIDtrans(synID(line("."),col("."),1))." errid=".errid)

  " cleanup
  let &fen= fenkeep
  if foldlevel(".") > 0
   norm! zO
  endif
  unlet curcol
  unlet errid
  if exists("prvcol")
    unlet prvcol
  endif
endfunction

map <silent> <Leader>ea :call <SID>SpchkAlternate(expand("<cword>"))<CR>

" Use Chase Tingley patch: prevents Error highlighting
" of words while one is typing them.  \%# is a new magic
" atom that matches zero-length if that is where the cursor
" currently is.
syn match GoodWord "\<\k\+\%#\>"
syn match GoodWord "\<\k\+'\%#"

" -----------------------------------------------------------------

" SpchkAlternate: extract words that are close in spelling
fu! <SID>SpchkAlternate(wrd)

  " can't provide alternative spellings without agrep
  if !executable("agrep")
   echoerr "For alternative spellings, agrep needs to be available"
   return
  endif

  let spchklang= b:spchklang
  let s:iskkeep= &isk
  silent! set isk-=#

  if exists("s:spchkaltwin")
    let s:winnr= winnr()
    " re-use wordlist in bottom window
    exe "norm! \<c-w>bG0DAAlternate<".a:wrd.">: \<Esc>"

  elseif filereadable(g:cvimsyn."/".spchklang."spchk.wordlist")
    " utilize previously generated <engspchk.wordlist>

    " Create a one line window to hold dictionaries during conversion
    let s:winnr= winnr()
    bo 1new
    let s:spchkaltwin= bufnr("%")
    nnoremap <silent> <leftmouse>   <leftmouse>:call <SID>SpchkLeftMouseB()<CR>
    setlocal lz
    setlocal winheight=1
    setlocal bt=nofile
    setlocal noswapfile
    setlocal nobl
    silent exe "norm! GoAlternate<".a:wrd.">: \<Esc>"

  else
    " generate <engspchk.wordlist> from <engspchk.vim>
    echo "Building <".spchklang."spchk.wordlist>"
    echo "This may take awhile, but it is a one-time only operation."
    echo "Please be patient..."

    " following avoids a problem on Macs with ffs="mac,unix,dos"
    let ffskeep= &ffs
    set ffs="unix,dos"

    " Create a one line window to hold dictionaries during conversion
    let s:winnr= winnr()
    bo 1new
    let s:spchkaltwin= bufnr("%")
    nnoremap <silent> <leftmouse>   <leftmouse>:call <SID>SpchkLeftMouseB()<CR>
    setlocal lz
    setlocal winheight=1
    setlocal bt=nofile
    setlocal noswapfile
    setlocal nobl

    " for quicker operation
    "   turn off undo
    "   turn on lazy-update
    "   make a temporary one-line window
    let ulkeep= &ul
    let gdkeep= &gd
    set ul=-1 nogd

    " Read in Webster's 1913-additional-word <[eng]spchk.usr> dictionary
    if spchklang ==? "eng" && filereadable(g:cvimsyn."/engspchk.rare") > 0
     exe "silent 0r ".g:cvimsyn."/engspchk.rare"
    endif
    put!='syn keyword GoodWord transparent	__START_RARE_DICTIONARY__'

    " load in dialect dictionary -- only keep one copy of both GoodWords and Dialect
    if spchklang ==? "eng" && filereadable(g:cvimsyn."/engspchk.dialect") > 0
     exe "silent 0r ".g:cvimsyn."/engspchk.dialect"
     1
     /START_WB_DICTIONARY__$/
     let lastline= line(".")-1
     1
     exe "/^elseif/,".lastline."d"
     1,.s/^ syn/syn/
     1,.s/Dialect/GoodWord/
     1,.-1v/^syn/d
    endif
    put!='syn keyword GoodWord transparent	__START_DIALECT_DICTIONARY__'

    " Read in main <[eng]spchk.dict> dictionary
    if filereadable(g:cvimsyn."/".spchklang."spchk.dict") > 0
     exe "silent 0r ".g:cvimsyn."/".spchklang."spchk.dict"
    else
     let &ul = ulkeep
     let &ffs= ffskeep
     let &gd = gdkeep
     echoerr "cannot seem to read <".g:cvimsyn."/".spchklang."spchk.dict>!"
     return
    endif
    put!='syn keyword GoodWord transparent	__START_DICT_DICTIONARY__'

    " Read in user's <[eng]spchk.usr> dictionary
    if filereadable(g:cvimsyn."/".spchklang."spchk.usr") > 0
     exe "silent 0r ".g:cvimsyn."/".spchklang."spchk.usr"
    endif
    put!='syn keyword GoodWord transparent	__START_USR_DICTIONARY__'

    " Remove non-dictionary lines and make it one word per line
    echo "Doing conversion..."
    silent v/^syn keyword GoodWord transparent/d
    %s/^syn keyword GoodWord transparent\t//
    silent! exe "%s/\\s\\+/\<CR>/g"
    echo "Writing ".g:cvimsyn."/".spchklang."spchk.wordlist"
    exe "w! ".g:cvimsyn."/".spchklang."spchk.wordlist"
    silent %d
    silent exe "norm! $oAlternate<".a:wrd.">: \<Esc>"
    let &ul = ulkeep
    let &ffs= ffskeep
    let &gd = gdkeep
  endif

  " set up local-to-alternate-window-only maps for <CR> and <tab> to invoke SpchkChgWord
  nnoremap <buffer> <silent> <CR>  :call <SID>SpchkChgWord(0)<CR>
  nnoremap <buffer> <silent> <tab> :call <SID>SpchkChgWord(1)<CR>

  " keep initial settings
  let s:keep_mod = &mod
  let s:keep_wrap= &wrap
  let s:keep_ic  = &ic
  let s:keep_lz  = &lz
  cnoremap  <silent> <buffer> q :call <SID>SpchkExitChgWord()<CR>
  nmap      <silent> <buffer> q :call <SID>SpchkExitChgWord()<CR>
  setlocal nomod nowrap ic nolz

  " let's add a wee bit of color...
  set lz
  syn match altLeader	"^Alternate"
  syn match altAngle	"[<>]"
  hi def link altLeader	Statement
  hi def link altAngle	Delimiter

  " set up path+wordlist
  let wordlist= g:cvimsyn."/".spchklang."spchk.wordlist"
  if &term == "win32" && !filereadable(wordlist)
   let wordlist= substitute(wordlist,'/','\\','g')
  else
   let wordlist= substitute(wordlist,'\\','/','g')
  endif

  " Build patterns based on permutations of up to 3 letters
  exe "silent norm! \<c-w>b"
  if &term == "win32"
   let agrep_opt="-V0 "
  else
   let agrep_opt= " "
  endif
  if strlen(a:wrd) > 2
   " agrep options:  -2  max qty of errors permitted in finding approx match
   "                 -i  case insensitive search enabled
   "                 -w  search for pattern as a word (surrounded by non-alpha)
   "                 -S2 set cost of a substitution to 2
    exe "silent r! agrep -2 -i -w -S2 ".agrep_opt.a:wrd." \"".wordlist."\""
  else
   " handle two-letter words
   exe "silent r! agrep -1 -i -w ".agrep_opt.a:wrd." \"".wordlist."\""
  endif
  silent %j
  silent norm! 04w
  setlocal nomod
  set nolz
endfunction

" ---------------------------------------------------------------------

" SpchkChgWord:
fu! <SID>SpchkChgWord(allfix)
  let reg0keep= @0
  norm! yiw
  let goodword= @0
  exe s:winnr."wincmd w"
  norm! yiw
  let badword=@0
  if col(".") == 1
   exe "norm! ea#\<Esc>b"
  else
   exe "norm! hea#\<Esc>b"
  endif
  norm! yl
  if match(@@,'\u') == -1
   " first letter not capitalized
   exe "norm! de\<c-w>blbye".s:winnr."\<c-w>wPlxb"
  else
   " first letter *is* capitalized
   exe "norm! de\<c-w>blbye".s:winnr."\<c-w>wPlxb~h"
  endif
  exe "norm! \<c-w>b:q!\<CR>".s:winnr."\<c-w>w"
  if a:allfix == 1
   let gdkeep= &gd
   set nogd
   let g:keep="bad<".badword."> good<".goodword.">"
   exe "silent! %s/".badword."/".goodword."/ge"
   norm! ``
   let &gd= gdkeep
  endif
  unlet s:spchkaltwin
  let &mod  = s:keep_mod
  let &wrap = s:keep_wrap
  let &ic   = s:keep_ic
  let &lz   = s:keep_lz
  let @0    = reg0keep
  let &isk  = s:iskkeep
  unlet s:keep_mod s:keep_wrap s:keep_ic s:keep_lz s:iskkeep
  if exists("g:spchkautonext")
   call s:SpchkNxt()
  endif
endfunction

" ---------------------------------------------------------------------

" SpchkExitChgWord: restore options and exit from change-word window
fu! <SID>SpchkExitChgWord()
  unlet s:spchkaltwin
  let &mod  = s:keep_mod
  let &wrap = s:keep_wrap
  let &ic   = s:keep_ic
  let &lz   = s:keep_lz
  unlet s:keep_mod s:keep_wrap s:keep_ic s:keep_lz
  q!
  let &isk  = s:iskkeep
  unlet s:iskkeep
endfunction

" ---------------------------------------------------------------------

" SpchkLeftMouseA: allows one to move to the current/next spelling error
fu! <SID>SpchkLeftMouseA()
  " call Decho("SpchkLeftMouseA()")
  " cursor in non-alternate-words window
  let errid= synIDtrans(hlID("Error"))
  norm! "_yiw
  if synIDtrans(synID(line("."),col("."),1)) != errid
   call s:SpchkNxt()
  endif
  if synIDtrans(synID(line("."),col("."),1)) == errid
   call s:SpchkAlternate(expand("<cword>"))
  endif
endfunction

" ---------------------------------------------------------------------

" SpchkLeftMouseB: automatically brings up alternates
fu! <SID>SpchkLeftMouseB()
  " call Decho("SpchkLeftMouseB()")
  if exists("s:spchkaltwin") && bufnr("%") == s:spchkaltwin
   " cursor must be in alternate-words window
   call s:SpchkChgWord(0)
  endif
  nnoremap <silent> <leftmouse>   :call <SID>SpchkLeftMouseA()<CR>
endfunction

" ---------------------------------------------------------------------

" SpchkRightMouse: click with rightmouse and all similarly misspelled words
"                  will be replaced with the selected alternate word
fu! <SID>SpchkRightMouse()
  if exists("s:spchkaltwin") && bufnr("%") == s:spchkaltwin
   " cursor must be in alternate-words window
   call s:SpchkChgWord(1)
  endif
  nnoremap <silent> <leftmouse>   :call <SID>SpchkLeftMouseA()<CR>
endfunction

" ---------------------------------------------------------------------

" SpchkToggleDialect: toggles Dialect being mapped to Warning/Error
fu! <SID>SpchkToggleDialect()
  let errid    = synIDtrans(hlID("Error"))
  let dialectid= synIDtrans(hlID("Dialect"))
  if dialectid == errid
   hi link Dialect Warning
  else
   hi link Dialect Error
  endif
endfunction

" ---------------------------------------------------------------------

" SpchkToggleRareWord: toggles RareWord being mapped to Warning/Error
fu! <SID>SpchkToggleRareWord()
  let errid      = synIDtrans(hlID("Error"))
  let rarewordid = synIDtrans(hlID("RareWord"))
  if rarewordid == errid
   hi link RareWord Notice
  else
   hi link RareWord Error
  endif
endfunction

" ---------------------------------------------------------------------

" SpchkEnd: end engspchk highlighting for the current buffer
fu! <SID>SpchkEnd()
  " prevent \ee from "unloading" a buffer where \ec wasn't run
  if !exists("b:engspchk_loaded")
   return
  endif

  " restore normal highlighting for the current buffer
  " Thanks to Gary Johnson: filetype detect occurs prior
  " to "unlet'ing" b:engspchk_loaded so that any filetype
  " plugins that attempt to load engspchk see that it
  " is still loaded at this point.
  syn clear
  filetype detect

  let &hidden            = b:hidden
  let s:engspchk_loadcnt = s:engspchk_loadcnt - 1
  unlet b:engspchk_loaded b:hidden

  " remove engspchk maps
  if s:engspchk_loadcnt <= 0
   let s:engspchk_loadcnt= 0

   nunmap <Leader>ee
   nunmap <Leader>et
   nunmap <Leader>eT
   nunmap <Leader>es
   nunmap <Leader>eS
  
   " restore user map(s), if any
   if b:spchk_restoremap != ""
    exe b:spchk_restoremap
    unlet b:spchk_restoremap
   endif
  
   " remove menu entries
   if has("gui_running") && has("menu")
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Alternative\ spellings<tab>'.s:mapleadstring.'ea'
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Move\ to\ next\ spelling\ error<tab>'.s:mapleadstring.'en'
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Move\ to\ previous\ spelling\ error<tab>'.s:mapleadstring.'ep'
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Save\ word\ to\ user\ dictionary\ (temporarily)<tab>'.s:mapleadstring.'et'
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Save\ word\ to\ user\ dictionary\ (permanently)<tab>'.s:mapleadstring.'es'
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Remove\ word\ from\ user\ dictionary\ (temporarily)<tab>'.s:mapleadstring.'eT'
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Remove\ word\ from\ user\ dictionary\ (permanently)<tab>'.s:mapleadstring.'eS'
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Dialect:\ toggle\ Warning/Error\ highlighting<tab>\ed'
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.Load\ '.b:Spchklang.'spchk<tab>'.s:mapleadstring.'ec'
    exe 'unmenu '.g:DrChipTopLvlMenu.b:Spchklang.'spchk.End\ '.b:Spchklang.'spchk<tab>'.s:mapleadstring.'ee'
   endif

   " enable subsequent re-loading of engspchk
   let s:loaded_{b:spchkfile}spchk= 1
  endif
endfunction

" ---------------------------------------------------------------------
if !exists("g:spchksilent") || !g:spchksilent
 echo "Done Loading <".b:spchklang."spchk.vim>"
endif

" vim: ts=4
