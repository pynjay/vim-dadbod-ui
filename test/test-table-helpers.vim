let s:suite = themis#suite('Table helpers')
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
    sleep 150m
  endif
  if getline('.') =~# '^\s*▸'
    throw 'Expected node to be expanded but it is still collapsed' . "\n" . join(getline(1, '$'), "\n")
  endif
endfunction

function! s:suite.before() abort
  call SetupTestDbs()
  call SetOptionVariable('db_ui_table_helpers', {
        \ 'sqlite': { 'List': 'SELECT * FROM {table}', 'Count': 'select count(*) from {table}', 'Explain': 'EXPLAIN ANALYZE {last_query}' }
        \ })
endfunction

function! s:suite.after() abort
  call SetOptionVariable('db_ui_table_helpers', {'sqlite': {'List': g:db_ui_default_query }})
  call Cleanup()
endfunction

function! s:suite.should_open_table_list_query_changed() abort
  :DBUI
  /dadbod_ui_test
  normal o
  /Tables
  normal o
  /contacts
  normal o
  /List
  normal o
  call s:expect(&filetype).to_equal('sql')
  call s:expect(getline(1)).to_equal('SELECT * FROM contacts')
  call s:expect(b:dbui_table_name).to_equal('contacts')
endfunction

function! s:suite.should_open_custom_count_helper() abort
  :DBUI
  /dadbod_ui_test
  normal o
  /Tables
  normal o
  /Count
  normal o
  call s:expect(&filetype).to_equal('sql')
  call s:expect(getline(1)).to_equal('select count(*) from contacts')
  write
endfunction

function! s:suite.should_open_custom_explain_helper_with_last_query_injected() abort
  :DBUI
  if &filetype !=? 'dbui'
    exe bufwinnr('dbui').'wincmd w'
  endif
  call s:expect(&filetype).to_equal('dbui')
  sleep 50m
  call cursor(1, 1)
  call s:must_search('\Vdadbod_ui_test')
  call s:ensure_expanded_here()
  call s:must_search('\VTables')
  call s:ensure_expanded_here()
  call s:must_search('\V▸ contacts')
  call s:expect(getline('.')).to_match('contacts')
  call s:ensure_expanded_here()
  sleep 100m
  exe bufwinnr('dbui').'wincmd w'
  call s:expect(&filetype).to_equal('dbui')
  call s:must_search('\V~ Explain')
  normal o
  call s:expect(&filetype).to_equal('sql')
  call s:expect(getline(1)).to_equal('EXPLAIN ANALYZE select count(*) from contacts')
endfunction
