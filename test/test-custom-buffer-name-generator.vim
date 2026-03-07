let s:suite = themis#suite('Custom icons')
let s:expect = themis#helper('expect')

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

function! s:ensure_expanded_here() abort
  if getline('.') =~# '^\s*▸'
    normal o
    sleep 200m
  endif
  if getline('.') =~# '^\s*▸'
    throw 'Expected node to be expanded but it is still collapsed' . "\n" . join(getline(1, '$'), "\n")
  endif
endfunction

function! s:focus_query_window() abort
  for w in range(1, winnr('$'))
    let b = winbufnr(w)
    if getwinvar(w, '&filetype') !=? 'dbui' && !empty(getbufvar(b, 'dbui_db_key_name', ''))
      execute w.'wincmd w'
      return
    endif
  endfor

  throw 'Expected query window to be opened but none was found' . "\n" . join(getline(1, '$'), "\n")
endfunction

function! s:open_new_query_for(db_name) abort
  let drawer = db_ui#drawer#get()
  let db = get(filter(copy(drawer.dbui.dbs_list), 'v:val.name ==? a:db_name'), 0, {})
  if empty(db)
    throw 'DB not found: '.a:db_name
  endif

  " Ensure DB is connected and populated so drawer sections (e.g. Tables)
  " are available for assertions.
  let db_entry = drawer.dbui.dbs[db.key_name]
  call drawer.dbui.connect(db_entry)
  let drawer.dbui.dbs[db.key_name] = drawer.populate(db_entry)
  call drawer.render({ 'db_key_name': db.key_name, 'queries': 1 })

  call drawer.get_query().open({
        \ 'type': 'query',
        \ 'dbui_db_key_name': db.key_name,
        \ 'label': '',
        \ 'table': '',
        \ 'schema': '',
        \ }, 'edit')
endfunction

function! s:suite.before() abort
  call SetupTestDbs()
endfunction

function! s:suite.after() abort
  call UnsetOptionVariable('Db_ui_buffer_name_generator')
  call Cleanup()
endfunction

function! s:name_generator(opts)
  if empty(a:opts.table)
    return 'query-from-test-suite-'.localtime().'.'.a:opts.filetype
  endif

  return 'query-from-test-suite-'.a:opts.table.'-'.localtime().'.'.a:opts.filetype
endfunction

function! s:suite.should_use_custom_icons() abort
  :DBUI
  if &filetype !=? 'dbui'
    exe bufwinnr('dbui').'wincmd w'
  endif
  call s:expect(&filetype).to_equal('dbui')
  sleep 200m
  call cursor(1, 1)
  call s:must_search_retry('\Vdadbod_ui_test')
  call s:ensure_expanded_here()
  call s:open_new_query_for('dadbod_ui_test')
  call s:focus_query_window()
  :DBUIFindBuffer
  if &filetype !=? 'dbui'
    exe bufwinnr('dbui').'wincmd w'
  endif
  call s:expect(&filetype).to_equal('dbui')
  sleep 200m
  call cursor(1, 1)
  call s:must_search_retry('\Vdadbod_ui_test')
  call s:ensure_expanded_here()
  call s:must_search_retry('\VBuffers (')
  call s:ensure_expanded_here()
  call s:must_search_retry('\Vquery-')
  call SetOptionVariable('Db_ui_buffer_name_generator', function('s:name_generator'))
  norm! gg
  call s:open_new_query_for('dadbod_ui_test')
  call s:focus_query_window()
  :DBUIFindBuffer
  if &filetype !=? 'dbui'
    exe bufwinnr('dbui').'wincmd w'
  endif
  call s:expect(&filetype).to_equal('dbui')
  sleep 200m
  call cursor(1, 1)
  call s:must_search_retry('\Vdadbod_ui_test')
  call s:ensure_expanded_here()
  call s:must_search_retry('\VBuffers (')
  call s:ensure_expanded_here()
  call s:must_search_retry('query-from-test-suite-\d\+\.sql')
  norm! gg
  call s:must_search_retry('\Vdadbod_ui_test')
  call s:ensure_expanded_here()
  call s:must_search_retry('\VTables')
  call s:ensure_expanded_here()
  call s:must_search_retry('\V▸ contacts')
  call s:ensure_expanded_here()
  call s:must_search_retry('\V~ List')
  normal o
  :DBUI
  if &filetype !=? 'dbui'
    exe bufwinnr('dbui').'wincmd w'
  endif
  call s:expect(&filetype).to_equal('dbui')
  sleep 200m
  call cursor(1, 1)
  call s:must_search_retry('\Vdadbod_ui_test')
  call s:ensure_expanded_here()
  call s:must_search_retry('\VBuffers (')
  call s:ensure_expanded_here()
  call s:must_search_retry('query-from-test-suite-contacts-\d\+\.sql')
endfunction
