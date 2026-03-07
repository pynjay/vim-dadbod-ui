let s:suite = themis#suite('Save query to file')
let s:expect = themis#helper('expect')

function! s:suite.before() abort
  call SetupTestDbs()
endfunction

function s:suite.after() abort
  call delete(g:db_ui_save_location.'/dadbod_ui_test', 'rf')
  call Cleanup()
endfunction

function! s:suite.should_save_query_to_file()
  runtime autoload/db_ui/utils.vim
  function! db_ui#utils#input(name, val)
    if a:name ==? 'Save as: '
      return 'test-saved-query'
    endif
  endfunction

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
  call s:expect(getline(1)).to_equal('SELECT * from "contacts" LIMIT 200;')
  normal ,W
  sleep 300m
  :DBUI
  /Saved queries
  norm oj
  call s:expect(getline('.')).to_equal('    '.g:db_ui_icons.saved_query.' test-saved-query')
  let s:paths = glob(g:db_ui_save_location.'/**/test-saved-query', 0, 1)
  if empty(s:paths)
    sleep 200m
    let s:paths = glob(g:db_ui_save_location.'/**/test-saved-query', 0, 1)
  endif
  call s:expect(empty(s:paths)).to_be_false()
endfunction

function! s:suite.should_delete_saved_query() abort
  call s:expect(search('test-saved-query', 'w')).to_be_greater_than(0)
  norm d
  call s:expect(search('test-saved-query', 'w')).to_equal(0)
  call s:expect(filereadable(printf('%s/%s/%s', g:db_ui_save_location, 'dadbod_ui_test', 'test-saved-query'))).to_be_false()
endfunction
