" vim: set sw=2 ts=2 et:
" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Load any materialize plugins
silent! source! $HOME/.materialize/artifacts/vim/*.vim

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" fix copy and paste
set clipboard=unnamed
if &term =~ "st.*"
  let &t_ti = &t_ti . "\e[?2004h"
  let &t_te = "\e[?2004l" . &t_te
  function XTermPasteBegin(ret)
    set pastetoggle=<Esc>[201~
    set paste
    return a:ret
  endfunction
  map <expr> <Esc>[200~ XTermPasteBegin("i")
  imap <expr> <Esc>[200~ XTermPasteBegin("")
  cmap <Esc>[200~ <nop>
  cmap <Esc>[201~ <nop>
endif

" set tabsize
set shiftwidth=4
set tabstop=4
set softtabstop=4
set noexpandtab

" use the :Man function
source $VIMRUNTIME/ftplugin/man.vim

" show whitespace
"set list listchars=tab:╺╴,eol:¬,trail:·,extends:→,precedes:←
set list listchars=tab:\ \ ,eol:\ ,trail:\ ,extends:→,precedes:←

" text width and don't wrap automatically, but display long lines wrapped
setlocal colorcolumn=0
set textwidth=80
set wrap  " display long lines wrapped
set fo-=t " do not automatically wrap

" always keep x lines visible above and below the cursor
set scrolloff=3

" set max tab count
set tabpagemax=25

" set diff options
set diffopt=filler,context:3,vertical,foldcolumn:1

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup  " do not keep a backup file, use versions instead
else
  set backup    " keep a backup file
endif
set history=1000        " keep x lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set smartcase           " auto detect if searching case insensitively
set ignorecase          " has to be enabled for smartcase to work
set hidden              " hide modified buffers on abandonment

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &diff
  syntax off
elseif &t_Co > 2 || has("gui_running")
  syntax enable
  set hlsearch
endif

set foldmethod=syntax
set foldnestmax=3
set nofoldenable

" command line completion
set wildmenu
set wildmode=longest:full,full
set wildignorecase
set wildignore+=*~
set wildignore+=*.swp

" use silver searcher instead of grep
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --literal\ --case-sensitive
endif


" ===========
" KEYBINDINGS
" ===========

" Use map leader to get a second keyboard
let mapleader="ß"

" convenience is king
map <leader>l <c-w><up>
map <leader>a <c-w><down>
map <leader>i <c-w><left>
map <leader>e <c-w><right>

" spell checking
nmap <silent> <leader>s :set spell!<cr>
nmap <silent> <leader>n :set spelllang=en<cr>
nmap <silent> <leader>d :set spelllang=de<cr>

" Don't use Ex mode, use Q for formatting
vmap Q gq
nmap Q gqap

" visually select the last edited/pasted text
nmap gV `[v`]
nmap gbV `[<c-v>`]

" make Y behave like other capitals
map Y y$

" Use k to open manpage
nmap k :Man <cword><CR>

" Don't need h for navigation so make it more useful
"noremap h :nohlsearch<CR>
nmap h :set hls!<CR>
noremap / :set hlsearch<CR>/
noremap ? :set hlsearch<CR>?
noremap * :set hlsearch<CR>*
noremap # :set hlsearch<CR>#

" toggle syntax highlighting
nmap j
        \ :if exists("g:syntax_on") <Bar>
        \   syntax off <Bar>
        \ else <Bar>
        \   syntax enable <Bar>
        \ endif<CR>

" easy buffer navigation
nmap l :b 
nmap L :ls<CR>
nmap _ <C-^>

" jump back and forth on the location stack
noremap + <C-o>
noremap ! <C-i>

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" better indentation
vnoremap < <gv
vnoremap > >gv

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee % >/dev/null

" line numbering
set relativenumber

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

augroup vimrcEx
  " clear group to avoid duplicates
  au!

  " highlight current word
  au CursorMoved * exe printf('match WordUnderCursor /\V\<%s\>/', escape(expand('<cword>'), '/\'))

  " options for readonly buffers
  au BufNewFile,BufRead,FilterReadPost *
        \ if &ro || &buftype ==# 'quickfix' |
        \       setlocal nolist |
        \       setlocal colorcolumn=0 |
        \       setlocal nonumber norelativenumber |
        \       nnoremap <buffer> q :q<CR> |
        \ else |
        \       setlocal list listchars=tab:\ \ ,eol:\ ,trail:\ ,extends:→,precedes:← |
        \       setlocal colorcolumn=81 |
        \       setlocal number relativenumber |
        \       silent! unmap <buffer> q |
        \ endif

  " auto reload vimrc after change.
  au BufWritePost ~/.vimrc source %

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  au BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif

  au QuickfixCmdPost make call setqflist(filter(getqflist(), 'v:val["bufnr"] != 0'))

  " =====================
  " FILETYPE autocommands
  " =====================

  " close quickfix window after navigation to another file
  au FileType qf nnoremap <silent> <buffer> <Enter> <CR>:cclose<CR>
  au FileType help setlocal bufhidden=unload

  au FileType man
        \ setlocal nomod nolist nonu noma |
        \ map <buffer> q :q<CR> |
        \ map <buffer> d <C-D> |
        \ map <buffer> u <C-U>

  au FileType python
        \ setl shiftwidth=2 |
        \ setl tabstop=2 |
        \ setl softtabstop=2 |
        \ setl expandtab

  au FileType go
        \ map <buffer> <F7> :make! \| if len(getqflist()) > 0 \| silent cfirst! \| endif<CR>

augroup END

" enable omnicomplete
set completeopt=longest,menuone
set ofu=syntaxcomplete#Complete

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

" set background
if has('gui_running')
  set background=light
else
  set background=dark
endif

" set colorscheme
set t_Co=16
colorscheme solarized
highlight WordUnderCursor cterm=bold ctermfg=7

" ===============
" PLUGIN Settings
" ===============

" Fix ToggleBG function from vim-colors-solarized
call togglebg#map("")

