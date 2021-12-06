
call plug#begin('~/.config/nvim/autoload/plugged')

    " Better Syntax Support
    Plug 'sheerun/vim-polyglot'
    " File Explorer
    Plug 'scrooloose/NERDTree'
    " Auto pairs for '(' '[' '{'
    Plug 'jiangmiao/auto-pairs'
    
    " Vim homescreen
    Plug 'mhinz/vim-startify'
    
    " Make tabs beatuful
    Plug 'fweep/vim-tabber'
    
    " Forgot what the hell these plugins does
    Plug 'itchyny/lightline.vim'
    Plug 'vim-syntastic/syntastic'
    
    " File manager 
    Plug 'vifm/vifm.vim'
    
    " themes
    Plug 'dracula/vim' 
    
     " AutoCompletion "
    Plug 'vim-scripts/AutoComplPop'
    Plug 'nvim-lua/completion-nvim'
    Plug 'rantasub/vim-bash-completion' 

    " fish syntax "
    Plug 'dag/vim-fish'  

   "Org mode
   Plug 'axvr/org.vim' 
  
   "hex colors
   Plug 'chrisbra/Colorizer'

   call plug#end()

    
   " set your colorscheme
     colorscheme dracula

     hi Normal  ctermbg=NONE
