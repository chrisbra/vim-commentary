" commentary.vim - Comment stuff out
" Version: 0.1

if exists("g:loaded_commentary_cb") || &cp || v:version < 704
  finish
endif
let g:loaded_commentary_cb = 1


xnoremap <silent> <Plug>Commentary        :<C-U>call commentary#go(line("'<"),line("'>"))<CR>
nnoremap <silent> <Plug>Commentary        :<C-U>set opfunc=commentary#go<CR>g@
nnoremap <silent> <Plug>CommentaryLine    :<C-U>set opfunc=commentary#go<Bar>exe 'norm! 'v:count1.'g@_'<CR>
onoremap <silent> <Plug>Commentary        :<C-U>call commentary#textobject(0)<CR>
nnoremap <silent> <Plug>ChangeCommentary c:<C-U>call commentary#textobject(1)<CR>
command! -range -bar Commentary call commentary#go(<line1>,<line2>)

if !hasmapto('<Plug>Commentary')
  for c in ['x','n','o'] | exe c."map gc  <Plug>Commentary" | endfor
  nmap gcc <Plug>CommentaryLine
  nmap cgc <Plug>ChangeCommentary
  nmap gcu gcgc
endif

" vim:set et sw=2:
