let s:suite = themis#suite('Custom icons')
let s:expect = themis#helper('expect')

function! s:suite.before() abort
  call SetupTestDbs()
  call SetOptionVariable('db_ui_icons', { 'expanded': '[-]', 'collapsed': '[+]' })
endfunction

function! s:suite.after() abort
  call UnsetOptionVariable('db_ui_icons')
  call Cleanup()
endfunction

function! s:must_search_retry(pat) abort
  for _ in range(1, 10)
    call cursor(1, 1)
    let l:pos = search(a:pat, 'wc')
    if l:pos > 0
      return l:pos
    endif
    sleep 100m
  endfor
  throw 'Pattern not found: '.a:pat."\n".join(getline(1, '$'), "\n")
endfunction

function! s:suite.should_use_custom_icons() abort
  :DBUI
  if &filetype !=? 'dbui'
    exe bufwinnr('dbui').'wincmd w'
  endif
  call s:expect(&filetype).to_equal('dbui')
  sleep 500m
  call s:must_search_retry('\V[+] dadbod_ui_test')
  call s:must_search_retry('\V[+] dadbod_ui_testing')
endfunction
