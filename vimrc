" ================================= FUNCTIONS =================================
function MyDiff()  " For Windows
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction
function Maximize_Window()  " Used in GNOME
   silent !wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
endfunction
function SetStatusLine()
    let fix_part='%2*%m%5*\ %t\ %*%<%h%w%q%r%=\ %7*<%n>\ %l,\ %c\ :\ %p%%%*\|%6*0x%02B%*\|%6*%{&fileformat}%*\|%6*%{&fileencoding}%*'
    let insert_mode='%3*INSERT' | let other_mode='%4*------'
    exe 'set statusline=' . other_mode . fix_part
    exe 'au InsertEnter * set statusline=' . insert_mode . fix_part
    exe 'au InsertLeave * set statusline=' . other_mode . fix_part
    set laststatus=2
endfunction
function ShortTabLabel () " Only show filename on tabs
    let bufnrlist = tabpagebuflist (v:lnum)
    let label = bufname (bufnrlist[tabpagewinnr (v:lnum) -1])
    let filename = fnamemodify (label, ':t')
    return filename
endfunction
function DeleteCurBuf() " Delete the buffer and don't close the window
    let l:cBuf = bufnr("%")
    if 0 == buflisted(l:cBuf) | exec "echo \'This buffer can not be deleted.\'" | return | endif
    if buflisted(bufnr("#")) | exec "b#" | else | exec "bp" | endif
    let l:newBufNum = bufnr("%")
    if l:cBuf == l:newBufNum | exec "echo \'This is the last opened file.\'" | return | endif
    exec "bw " . l:cBuf
endfunction
function WasCommented(str)  " Judge is this line a comment (by //)
    let str_len = strlen(a:str) | let i = 0
    while i < str_len
        if a:str[i] != ' ' && a:str[i] != "\t" | break | endif | let i += 1
    endwhile
    if i < str_len - 1 && a:str[i] == a:str[i+1] && a:str[i] == "/" | return 1 | else | return 0 | endif
endfunction
function ToggleCommentLine()  " Toggle line with //
    let nr = line('.') | let str_line = getline(nr)
    if WasCommented(str_line) | let newstr = substitute(str_line, '//', '', '')
    else | let newstr = substitute(str_line, '^', '//', '') | endif
    :call setline(nr, newstr)
endfunction
function WhichOpened()  " Judge if Tagbar or NERDTree opened. 0 both are not, 1 only Tagbar, 2 only NERDTree, 3 both were opened.
    let retv = 0
    if bufwinnr('__Tagbar__') != -1 | let retv += 1 | endif
    if bufwinnr('NERD_tree_1') != -1 | let retv += 2 | endif
    return retv
endfunction
func ToggleTagbar()
    let wo = WhichOpened()
    if (wo == 1 || wo == 3) | exec "TagbarClose"
    else | exec "TagbarOpen" | endif
endf
func ToggleNERDTree()
    let wo = WhichOpened() | exec "NERDTreeClose"
    if (wo != 2 && wo != 3) | exec "NERDTreeToggle" | exec "normal! \<c-w>h" | endif
endf
function ToggleFull()  " Open or close Tagbar and NERDTree at the same time.
    let wo = WhichOpened() | exec "NERDTreeClose"
    if (wo == 0) | exec "NERDTreeToggle" | exec "normal! \<c-w>h" | exec "TagbarOpen"
    else | exec "TagbarClose" | endif
endfunction
function FindFilePath()  " Let NERDTree unfold to current file.
    exec 'NERDTreeFind' | exec "normal! \<c-w>h"
endfunction
function IsQuickfixLoaded() " This function works only on language is English.
    redir => bufoutput
    exe "silent! buffers!"
    " This echo clears a bug in printing that shows up when it is not present
    silent! echo ""
    redir END
    return match(bufoutput, "\"\\[Quickfix List\\]\"", 0, 0) != -1
endfunction
function ToggleQuickfix()
    if IsQuickfixLoaded() | :ccl
    else | :copen | :exec "normal! \<c-w>J" | endif
endfunction
let g:isNoWrap = 1  " wrap lines or not
function ToggleWrap()
    if g:isNoWrap == 0 | exe "set nowrap" | let g:isNoWrap = 1
    else | exe "set wrap" | let g:isNoWrap = 0 | endif
endfunction
function ShowCurrentTag()  " about Tagbar
    let str = tagbar#currenttag('%s', '', 's') | echo str
endfunction
" about Ack.vim
function BuildIgnore()
    let dir_list = split(g:ack_ignore_dir, ',')
    let result = ' '
    for dirname in dir_list
        let result = result . '--ignore ' . dirname . ' '
    endfor
    return result
endfunction
let g:ack_root = ' '
function AckWithOptions(...)
    let ignores = BuildIgnore()
    if a:0 > 0 | exec 'Ack! -U' . ignores . a:1 . ' ' . g:ack_root
    else | exec 'Ack! -U' . ignores . expand('<cword>'). ' ' . g:ack_root | endif
endfunction
function AckSetSearchRoot()
    let newackroot = input("Enter a directory to set the root to: ", "d:\\", "dir")
    if empty(newackroot) | return | endif
    let g:ack_root = newackroot
endfunction
command! -nargs=? MyAck call AckWithOptions(<f-args>)
command! -nargs=0 MyAckSetRoot call AckSetSearchRoot()

" ============================ BASIC SETTINGS ==================================
set encoding=utf-8 
set langmenu=en_US   "set menu's language of gvim.
if !has("win32") | language en_US.utf8| endif
language messages en_US
set nocompatible
if has("win32")
    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim
    behave mswin
    set diffexpr=MyDiff()
    au GuiEnter * simalt ~x  " Auto maximize the window
endif

if has("gui_running")
    if has("win32") | set guifont=Consolas:h11 | else | set guifont=YaHei\ Consolas\ Hybrid\ Regular\ 11 | endif
    set guioptions-=T   " No tools bar
    set guioptions-=L   " No left scroll bar
    set guioptions-=r   " No right scroll bar
    set guioptions-=m   " No menus
    set guitablabel=%{ShortTabLabel()}
    set vb t_vb=        " No bell, the next is no flash
    au GuiEnter * set t_vb=
endif

set number
set hlsearch
set tabstop=4
set expandtab
set shiftwidth=4
set autoindent
set hidden        " 避免当前编辑文档未保存时，在新窗口打开文档
"set ignorecase
set cursorline 
set textwidth=0 " 超过后自动拆行
set colorcolumn=81
set mouse=a
set completeopt=menu     " 补全设置
call SetStatusLine()
set nobackup
set noundofile
set noswapfile
set nowrap  " 不拆行
set nofoldenable " 启动时关闭折叠
set cst  " tag有多个匹配项时可以提供选择的机会
" 设置自动补全的单词列表，如果没有set complete那么需要按<c-x><c-k>才会出现补全，
" 如果设置了set complete那么直接使用<c-n>或<c-p>就可以了。
set dictionary+=~/vim_autocomplete_dic.txt
set complete+=k
set fileformat=unix
set scrolloff=0 " 设置光标离屏幕顶底的距离

" ------------------------------ SET HOT KEYS --------------------------------
nmap Q :call DeleteCurBuf()<cr>
nmap <leader>b :ls<CR>
nmap <leader>w :update<CR>
nmap <leader>e :browse confirm e<CR>
if has("win32") | nmap <leader>s :e ~/_vimrc<CR>
else | nmap <leader>s :e ~/.vimrc<CR> | endif

nmap ;s <Plug>(easymotion-F)
nmap ;f <Plug>(easymotion-f)
nmap ;j <Plug>(easymotion-j)
nmap ;k <Plug>(easymotion-k)

inoremap <c-l> <c-o><del>
nnoremap <s-Tab> :bn<CR>
vnoremap <s-Tab> <esc>:bn<CR>
inoremap <s-Tab> <esc>:bn<CR>
nnoremap <c-Tab> :b#<CR>
vnoremap <c-Tab> <esc>:b#<CR>
inoremap <c-Tab> <esc>:b#<CR>
nnoremap <c-s-tab> :bp<cr>
vnoremap <c-s-tab> <esc>:bp<cr>
inoremap <c-s-tab> <esc>:bp<cr>
inoremap <c-f> <pagedown>
inoremap <c-b> <pageup>
nmap <C-x><c-d> :pwd<CR>
nmap <c-x><c-s> :cd ..<CR>:pwd<CR>
nmap <c-x><c-x> :CtrlPBuffer<cr>
vnoremap <c-x><c-x> "+x
nnoremap <c-x><c-z> :nohl<cr>
vnoremap <c-x><c-z> <c-c>:nohl<cr>
inoremap <c-x><c-z> <c-o>:nohl<cr>
nnoremap <c-right> 3zl
nnoremap <c-s-right> zL
nnoremap <c-left> 3zh
nnoremap <c-s-left> zH
nmap <c-x><c-w> :call ToggleWrap()<cr>
imap <c-x><c-w> <c-o>:call ToggleWrap()<cr>
vmap <c-x><c-w> <c-c>:call ToggleWrap()<cr>
vnoremap <c-h> <esc>:promptrepl<cr>
nnoremap <c-h> <esc>:promptrepl<cr>

nmap <m-d> :echo "ack root: ". g:ack_root<cr>
nmap <m-s> :call ShowCurrentTag()<cr>
nmap <m-f3> :MyAck<cr>
imap <m-f3> <c-o>:MyAck<cr>
nmap <m-f> :MyAck 
nmap <m-e> :MyAckSetRoot<cr>
nmap <m-f1> :call ToggleTagbar()<cr>

nmap <f1>      :call ToggleFull()<cr>
imap <f1> <c-o>:call ToggleFull()<cr>
vmap <f1> <c-c>:call ToggleFull()<cr>
nmap <f2>      :call ToggleNERDTree()<cr>
vmap <f2> <c-c>:call ToggleNERDTree()<cr>
imap <f2> <c-o>:call ToggleNERDTree()<cr>
vmap <F3>  <C-C><ESC>/<C-R>+<CR><ESC>N
nmap <F3> /<C-R>=expand("<cword>")<CR><CR>N
imap <F3> <c-o>/<C-R>=expand("<cword>")<CR><CR><c-o>N
"nmap <F4> <ESC>:Grep 
"vmap <F4> <ESC>:Grep 
"imap <F4> <ESC>:Grep 
nmap <f5> <esc>:call FindFilePath()<cr>
vmap <f5> <esc>:call FindFilePath()<cr>
imap <f5> <esc>:call FindFilePath()<cr>
"nmap <F6> <ESC>:CtrlPFunky<cr>
"vmap <F6> <ESC>:CtrlPFunky<cr>
"imap <F6> <ESC>:CtrlPFunky<cr>
nnoremap <F7> <ESC>:CtrlP<CR>
vnoremap <F7> <ESC>:CtrlP<CR>
inoremap <F7> <ESC>:CtrlP<CR>
nmap <F8> <ESC>:CtrlPMRU<CR>
vmap <F8> <ESC>:CtrlPMRU<CR>
imap <F8> <ESC>:CtrlPMRU<CR>
nmap <F9> <ESC>:call ToggleQuickfix()<CR>
vmap <F9> <ESC>:call ToggleQuickfix()<CR>
imap <F9> <ESC>:call ToggleQuickfix()<CR>
nmap <f10>      :call ToggleCommentLine()<cr>
imap <f10> <c-o>:call ToggleCommentLine()<cr>
vmap <f10> <esc>:call ToggleCommentLine()<cr>
nnoremap <silent> <F11> <ESC>:<C-R>=line("'<")<CR>,<C-R>=line("'>")<CR>s/^/\/\/<CR>/^$x<CR>
vnoremap <silent> <F11> <ESC>:<C-R>=line("'<")<CR>,<C-R>=line("'>")<CR>s/^/\/\/<CR>/^$x<CR>
inoremap <silent> <F11> <ESC>:<C-R>=line("'<")<CR>,<C-R>=line("'>")<CR>s/^/\/\/<CR>/^$x<CR>
nnoremap <silent> <F12> <ESC>:<C-R>=line("'<")<CR>,<C-R>=line("'>")<CR>s/\/\//<CR>/^$x<CR>
vnoremap <silent> <F12> <ESC>:<C-R>=line("'<")<CR>,<C-R>=line("'>")<CR>s/\/\//<CR>/^$x<CR>
inoremap <silent> <F12> <ESC>:<C-R>=line("'<")<CR>,<C-R>=line("'>")<CR>s/\/\//<CR>/^$x<CR>

if !has("win32")   " Some hot keys like windows
    vnoremap <C-C> "+y
    map <C-V>		"+gP
    imap <C-V>      <c-o>"+gP
    cmap <C-V>		<C-R>+
    noremap <C-S>		:update<CR>
    vnoremap <C-S>		<C-C>:update<CR>
    inoremap <C-S>		<C-O>:update<CR>
    noremap <C-A> gggH<C-O>G
    inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
    cnoremap <C-A> <C-C>gggH<C-O>G
    onoremap <C-A> <C-C>gggH<C-O>G
    snoremap <C-A> <C-C>gggH<C-O>G
    xnoremap <C-A> <C-C>ggVG
endif

" -------------------------------- SET PLUGIN ----------------------------------
filetype off            " required
if has("win32")
    set rtp+=$VIM/vimfiles/bundle/Vundle.vim
    call vundle#begin('$VIM/vimfiles/bundle')
else
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin('~/.vim/bundle')
endif
Plugin 'VundleVim/Vundle.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdtree'
Plugin 'mileszs/ack.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'ctrlpvim/ctrlp.vim'
"Plugin 'tacahiroy/ctrlp-funky'
Plugin 'drmingdrmer/xptemplate'
Plugin 'ap/vim-buftabline'
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

" =================================== plugin settings ==========================
" Tagbar
let g:tagbar_left=1
let g:tagbar_width=30
let g:tagbar_autoclose=0
let g:tagbar_compact = 1
if has("win32") | let g:tagbar_iconchars=['>', 'v'] | endif

" NERDTree
let NERDTreeWinPos='right'
let NERDTreeShowLineNumbers=0
let NERDTreeWinSize=30
let NERDTreeMinimalUI=1

" ctrlp
let g:ctrlp_cmd='CtrlPBuffer'
let g:ctrlp_by_filename = 1
let g:ctrlp_regexp = 1
let g:ctrlp_working_path_mode = 'rw'
let g:ctrlp_max_height = 30
let g:ctrlp_max_files = 100000
let g:ctrlp_use_caching = 1
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_bufpath_mod = '' " 让Buffer mode不显示路径
let g:ctrlp_cache_dir = '~/.ctrlp'
let g:ctrlp_root_markers = ['pom.xml', '.root']
set wildignore=*\\tmp\\*,*.swp,*.zip,*.exe
let g:ctrlp_custom_ignore = {
    \ 'dir': '\v[\/](build|bin|target)$',
    \ 'file': '\v\.(jar|yang|properties|class|xml|MF|sh|bat|xlsx|files|proto|conf|md|txt|xsd|png|gif|svg|json|gz|less|css|scss)$',
    \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',}
" ctrlp_funky
let g:ctrlp_extensions = ['funky']
let g:ctrlp_funky_syntax_highlight = 1

" ack
let g:ackprg = 'ag --vimgrep'
let g:ack_ignore_dir='target,*.class,*.jar,tags,tags.files'

let g:solarized_termcolors = 256
colorscheme solarized
set bg=dark

