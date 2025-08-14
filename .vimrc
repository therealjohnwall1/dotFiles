set number
set relativenumber
syntax on
filetype on
filetype plugin indent on
:set tabstop=4
:set shiftwidth=4
:set expandtab
:set showmode
:set laststatus=2

:set clipboard=unnamedplus

let mapleader=" "

call plug#begin()
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'preservim/nerdcommenter'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
call plug#end()

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
endfunction

" to auto complete ctrl-x + ctrl-o
augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" leader + cs/cc for mass comment, cu for uncomment
filetype plugin on 

highlight Cursor guifg=white guibg=white
set guicursor+=i:blinkwait10

" tab hopping
au TabLeave * let g:lasttab = tabpagenr()

" i like kids

nnoremap <silent> <Leader>l :tabnext<CR>
nnoremap <silent> <Leader>h :tabprevious<CR>

" For visual mode
 vnoremap <silent> <Leader>l :tabnext<CR>
 vnoremap <silent> <Leader>h :tabprevious<CR>

 nnoremap <silent> <Leader>e :LspDocumentDiagnostics<CR>


