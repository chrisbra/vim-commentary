function! s:surroundings() abort "{{{2
  if empty(&cms)
      return ['# ', '']
  else
    return split(get(b:, 'commentary_format', substitute(&cms,
        \ '\S\@<=\%(\s*\)\%(%s\)\@=\|\%(%s\)\@<=\(\s*\)\S\@=',' ','g')), '%s', 1)
  endif
endfunction

function! s:StripWhiteSpace(l,r,line) "{{{2
  " Strip whitespace from the comment,
  " if the line does not have any
  let [l, r] = [a:l, a:r]
  if stridx(a:line,l) == -1 && stridx(a:line,l[0:-2])==0 && a:line[strlen(a:line)-strlen(r[1:]):-1]==r[1:]
    return [l[0:-2], r[1:]]
  endif
  return [l,r]
endfunction

function! commentary#go(type,...) abort "{{{2
  let [lnum1, lnum2] = (a:0 ? [a:type, a:1] : [line("'["), line("']")])

  let [l_, r_] = s:surroundings()
  let llist    = []
  for lnum in range(lnum1,lnum2)
    let l    = getline(lnum)
    let uncomment = 2
    let line = matchstr(l,'\S.*\s\@<!')
    let [l, r] = s:StripWhiteSpace(l_,r_,line)
    if line != '' && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
      let uncomment = 0
    endif
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
endfunction

function! commentary#textobject(inner) abort "{{{2
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
