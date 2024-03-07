let g:mapleader = " "

filetype indent plugin on
set autochdir
set background=dark
set encoding=UTF-8
set hlsearch
set ignorecase smartcase 
set incsearch
set linebreak
set list
set listchars=nbsp:~,tab:>\ ,trail:_,precedes:←,extends:→
set nocompatible
set number
set path+=.,,,
set scrolloff=999
set sidescrolloff=10
"set termguicolors
set textwidth=80
set wildmenu
syntax on

set statusline=
set statusline+=\ %F\ %M\ %Y\ %R
set statusline+=%=
set statusline+=\ WORDS:\ %{wordcount().words}
set statusline+=\ ascii:\ %b
set statusline+=\ hex:\ 0x%B
set statusline+=\ row:\ %l\ col:\ %c
set statusline+=\ percent:\ %p%%
set laststatus=2

" ###########
" Keybindings
" ###########
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-j> :tabprevious<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <C-Right> :tabnext<CR>
nnoremap <C-k> :tabnext<CR>
nnoremap <C-h> :nohlsearch<CR>

if !filereadable(expand("~/.vim/colors/onedark.vim")) || !filereadable(expand("~/.vim/autoload/onedark.vim"))
	echo "Downloading onedark.vim theme..."
	silent! execute '!curl --create-dirs --fail --location --output ~/.vim/colors/onedark.vim "https://github.com/joshdick/onedark.vim/raw/main/colors/onedark.vim"'
	echo "onedark.vim downloaded successfully!"
	echo "Downloading onedark.vim autoload script..."
	silent! execute '!curl --create-dirs --fail --location --output ~/.vim/autoload/onedark.vim "https://github.com/joshdick/onedark.vim/raw/main/autoload/onedark.vim"'
	echo "onedark.vim autoload script downloaded successfully!"
endif

if filereadable(expand("~/.vim/colors/onedark.vim")) && filereadable(expand("~/.vim/autoload/onedark.vim"))
	colorscheme onedark
endif
