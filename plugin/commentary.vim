" commentary.vim - Comment stuff out

if exists("g:loaded_commentary_cb") || &cp || v:version < 704
  finish
endif
let g:loaded_commentary_cb = 1

function! s:surroundings() abort
  return split(get(b:, 'commentary_format', substitute(&cms,
        \ '\S\@<=\%(\s*\)\%(%s\)\@=\|\%(%s\)\@<=\(\s*\)\S\@=',' ','g')), '%s', 1)
endfunction

function! s:StripWhiteSpace(l,r,line)
  " Strip whitespace from the comment,
  " if the line does not have any
  let [l, r] = [a:l, a:r]
  if stridx(a:line,l) == -1 && stridx(a:line,l[0:-2])==0 && a:line[strlen(a:line)-strlen(r[1:]):-1]==r[1:]
    return [l[0:-2], r[1:]]
  endif
  return [l,r]
endfunction

function! s:go(type,...) abort
  let [lnum1, lnum2] = (a:0 ? [a:type, a:1] : [line("'["), line("']")])

  let [l_, r_] = s:surroundings()
  let llist    = []
  for lnum in range(lnum1,lnum2)
    let uncomment = 2
    let line = matchstr(getline(lnum),'\S.*\s\@<!')
    let [l, r] = s:StripWhiteSpace(l_,r_,line)
    if line != '' && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
      let uncomment = 0
    endif
    let line = getline(lnum)
    if strlen(r) > 2 && l.r !~# '\\'
      let line = substitute(line,
          \'\M'.r[0:-2].'\zs\d\*\ze'.r[-1:-1].'\|'.l[0].'\zs\d\*\ze'.l[1:-1],
          \'\=substitute(submatch(0)+1-uncomment,"^0$\\|^-\\d*$","","")','g')
    endif
    let line = (uncomment ? substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','') :
          \ substitute(line,'^\%('.matchstr(getline(lnum1),'^\s*').'\|\s*\)\zs.*\S\@<=','\=l.submatch(0).r',''))
    call add(llist, line)
  endfor
  call setline(lnum1,llist)
  let modelines = &modelines
  try
    set modelines=0
    silent doautocmd User CommentaryPost
  finally
    let &modelines = modelines
  endtry
endfunction

function! s:textobject(inner) abort
  let [l_, r_] = s:surroundings()
  let lnums = [line('.')+1, line('.')-2]
  for [index, dir, bound, line] in [[0, -1, 1, ''], [1, 1, line('$'), '']]
    while lnums[index] != bound && line ==# '' || !(stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
      let lnums[index] += dir
      let line = matchstr(getline(lnums[index]+dir),'\S.*\s\@<!')
      let [l, r] = s:StripWhiteSpace(l_,r_,line)
    endwhile
  endfor
  while (a:inner || lnums[1] != line('$')) && empty(getline(lnums[0]))
    let lnums[0] += 1
  endwhile
  while a:inner && empty(getline(lnums[1]))
    let lnums[1] -= 1
  endwhile
  if lnums[0] <= lnums[1]
    execute 'norm! 'lnums[0].'GV'.lnums[1].'G'
  endif
endfunction

xnoremap <silent> <Plug>Commentary        :<C-U>call <SID>go(line("'<"),line("'>"))<CR>
nnoremap <silent> <Plug>Commentary        :<C-U>set opfunc=<SID>go<CR>g@
nnoremap <silent> <Plug>CommentaryLine    :<C-U>set opfunc=<SID>go<Bar>exe 'norm! 'v:count1.'g@_'<CR>
onoremap <silent> <Plug>Commentary        :<C-U>call <SID>textobject(0)<CR>
nnoremap <silent> <Plug>ChangeCommentary c:<C-U>call <SID>textobject(1)<CR>
command! -range -bar Commentary call s:go(<line1>,<line2>)

if !hasmapto('<Plug>Commentary')
  for c in ['x','n','o'] | exe c."map gc  <Plug>Commentary" | endfor
  nmap gcc <Plug>CommentaryLine
  nmap cgc <Plug>ChangeCommentary
  nmap gcu gcgc
endif

" vim:set et sw=2:
