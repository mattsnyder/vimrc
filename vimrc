call pathogen#runtime_append_all_bundles()

" Turn on syntax hilighting
syntax on

" Whitespace stuff
set nowrap
set tabstop=2
set shiftwidth=2
set expandtab
set list listchars=tab:\ \ ,trail:·

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Tab completion
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc

" Status bar
set laststatus=2

" Insert a date log header
map <leader>d i------------------------------<ESC>:r ! date<CR>A<CR><CR><ESC>i

" Edit and Resource the vim rc files
map <leader>vr :e ~/.vim/vimrc<CR>
map <leader>gvr :e ~/.vim/gvimrc<CR>
nmap <leader>s :source $HOME/.vimrc<CR>:source $HOME/.gvimrc<CR>

" Turn of highlighting after search
map <C-l> :noh<CR>

set switchbuf=useopen           " Reuse open buffers when opening a file that's already open
set cmdheight=2                 " Set the command window height to be 2

" Turn off line numbers
set nonumber

" Key to toggle line numbers
map <leader>ln :set number!<CR>

" Status line setup
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set cursorline                " show a line at the row of the cursor
set cursorcolumn              " show a line at the column of the cursor
set directory=/tmp      " Where temporary files will go.
set splitright
set splitbelow

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Opens a tab edit command with the path of the currently edited file filled in
" Normal mode: <Leader>t
map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
" cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" Use modeline overrides
set modeline
set modelines=10

" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

" Keep more context when scrolling at the end or beginning of the buffer
set scrolloff=5

" Set ctrl-a and ctrl-e to jump to beginning and end of line respectively
imap <C-a> <C-o>^
imap <C-e> <C-o>$
nmap <C-a> ^
nmap <C-e> $

" Repeat the last colon command in normal mode
nnoremap ,. :<UP><CR>

" Setup quick keys for virtual editing
map <leader>ve :call VirtualEditToggle()<CR>
function! VirtualEditToggle()
  if &ve != ""
    set ve=
    echo "virtual edit off"
  else
    set ve=all
    echo "virtual edit on"
  endif
endfunction

" <leader><leader> switches to the last buffer used
map <leader><leader> <C-^>

" Make '<leader>r' (in normal mode) give a prompt for renaming files
" in the same dir as the current buffer's file.
map <leader>r :Rename <C-R>=expand("%:h/")<cr>/

"Vertical split then hop to new buffer
noremap <leader>v :vsp<CR>
noremap <leader>h :split<CR>
"
"Make current window the only one
noremap <leader>O :only<CR>:tabo<CR>
noremap <leader>o :only<CR>

" Show invisible characters
set list listchars=tab:\ \ ,trail:·,nbsp:%,extends:>,precedes:<
map <F6> :set nolist!<CR>:set nolist?<CR>
imap <F6> <ESC>:set nolist!<CR>:set nolist?<CR>a

" Clear all trailing spaces
map <leader>c :%s/\s\+$//<CR><c-o>

" visual shifting (builtin-repeat)
vnoremap < <gv
vnoremap > >gv

" Setup vimwiki to store in dropbox
let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki/'}]



" GreenBar test
"
if @% =~ '.m'
  nnoremap <leader>m :call RunTestsForFile('')<cr>:redraw<cr>:call JumpToError()<cr>
else
  nnoremap <leader>m :call RunTestsForFile('')<cr>:redraw<cr>:call JumpToError()<cr>
endif

function! RunTests(target, args)
    silent ! echo
    exec 'silent ! echo -e "\033[1;36mRunning tests in ' . a:target . '\033[0m"'
    set makeprg=spec\ --require\ rubygems\ --require\ spec/rspec_make_output_formatter.rb\ --format\ Spec::Runner::Formatter::MakeOutputFormatter
    silent w
    exec "make " . a:target . " " . a:args
endfunction

function! RunTestsObjC(target, args)
  silent ! echo
  silent w
  exec "make -s " . a:target . " " . a:args
endfunction

function! RunTestsForFile(args)
    if @% =~ '.m'
      call RunTestsObjC('test', a:args)
    elseif @% =~ '_spec'
        call RunTests('%', a:args)
    else
        let test_file_name = TestModuleForCurrentFile()
        call RunTests(test_file_name, a:args)
    endif
endfunction

function! JumpToError()
    if getqflist() != []
        for error in getqflist()
            if error['valid']
                break
            endif
        endfor
        let error_message = substitute(error['text'], '^ *', '', 'g')
        " silent cc!
        " how is sbuffer useful? - using set switchbuf=useopen, that's how
        " why is this necessary? it does this automatically?
        if @% !~ '.m'
          exec ":sbuffer " . error['bufnr']
        endif
        call RedBar()
        echo error_message
    else
        call GreenBar()
        echo "All tests passed"
    endif
endfunction

function! RedBarGreenBar()
  if getqflist() != []
    call RedBar()
    echo error_message
  else
    call GreenBar()
    echo "All tests passed"
  endif

endfunction

function! RedBar()
    hi RedBar ctermfg=white ctermbg=red guibg=red
    echohl RedBar
    echon repeat(" ",&columns - 1)
    echohl
endfunction

function! GreenBar()
    hi GreenBar ctermfg=white ctermbg=green guibg=green
    echohl GreenBar
    echon repeat(" ",&columns - 1)
    echohl
endfunction

function! ModuleTestPath()
    let file_path = @%
    let components = split(file_path, '/')
    let path_without_extension = substitute(file_path, '\.rb$', '', '')
    let test_path = 'spec/' . path_without_extension . '_spec.rb'
    return test_path
endfunction

function! TestModuleForCurrentFile()
    let test_path = ModuleTestPath()
    echo test_path
    let test_module = substitute(test_path, '/', '.', 'g')
    return test_path
endfunction


""""""""""""""""""""""""""""""""""""""""""""
" Filetype specific configs

" load the plugin and indent settings for the detected filetype
filetype plugin indent on

" make and python use real tabs
au FileType make                                     set noexpandtab
au FileType python                                   set noexpandtab

" Thorfile, Rakefile and Gemfile are Ruby
au BufRead,BufNewFile {Gemfile,Rakefile,Thorfile,config.ru}    set ft=ruby

" md, markdown, and mk are markdown and define buffer-local preview
au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn} call s:setupMarkup()

au BufRead,BufNewFile *.txt call s:setupWrapping()



""""""""""""""""""""""""""""""""""""""""""""
" vimwiki

" Turn on folding for vimwiki
map <leader>wf :call VimWikiFoldingToggle()<CR>
function! VimWikiFoldingToggle()
  if g:vimwiki_folding == 1
    let g:vimwiki_folding=0
  else
    let g:vimwiki_folding=1
  endif
endfunction

" Change key for toggling list items in vimwiki
map <C-S-Space> :VimwikiToggleListItem<CR>


""""""""""""""""""""""""""""""""""""""""""""
" NERDTree configuration

let NERDTreeIgnore=['\.rbc$', '\~$']
map <Leader>n :NERDTreeToggle<CR>


""""""""""""""""""""""""""""""""""""""""""""
" Command-T configuration

let g:CommandTMaxHeight=20

""""""""""""""""""""""""""""""""""""""""""""
" CTags

map <Leader>rt :!ctags --extra=+f -R *<CR><CR>


""""""""""""""""""""""""""""""""""""""""""""
" tabular

function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

