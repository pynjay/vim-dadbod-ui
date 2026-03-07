let s:suite = themis#suite('Query history')
let s:expect = themis#helper('expect')

function! s:must_search(pat) abort
  let l:pos = search(a:pat, 'w')
  if l:pos <= 0
    throw 'Pattern not found: '.a:pat."\n".join(getline(1, '$'), "\n")
  endif
  return l:pos
endfunction

function! s:ensure_expanded_here() abort
  if getline('.') =~# '^\s*▸'
    normal o
    sleep 200m
  endif
  if getline('.') =~# '^\s*▸'
    throw 'Expected node to be expanded but it is still collapsed' . "\n" . join(getline(1, '$'), "\n")
  endif
endfunction

function! s:suite.before() abort
  call SetupTestDbs()
  " Sleep 1 sec to avoid overlapping temp names
  sleep 1
endfunction

function! s:suite.after() abort
  call Cleanup()
endfunction

function! s:suite.should_record_query_in_history() abort
  :DBUI
  if &filetype !=? 'dbui'
    exe bufwinnr('dbui').'wincmd w'
  endif
  call s:expect(&filetype).to_equal('dbui')
  sleep 200m
  call cursor(1, 1)
  call s:must_search('\Vdadbod_ui_test')
  call s:ensure_expanded_here()
  sleep 200m
  call s:must_search('\VNew query')
  normal o
  call s:expect(&filetype).to_equal('sql')
  call setline(1, ['select 1;'])
  write
  sleep 800m
  pclose

  :DBUI
  if &filetype !=? 'dbui'
    exe bufwinnr('dbui').'wincmd w'
  endif
  call s:expect(&filetype).to_equal('dbui')
  sleep 200m
  call cursor(1, 1)
  call s:must_search('\Vdadbod_ui_test')
  call s:ensure_expanded_here()
  sleep 200m
  call s:must_search('\VHistory (')
  call s:expect(getline('.')).to_match('History')
  call s:ensure_expanded_here()
  sleep 200m
  call s:must_search('\Vselect 1')
endfunction
