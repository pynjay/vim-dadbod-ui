let s:suite = themis#suite('Jump to sibling/node')
let s:expect = themis#helper('expect')

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

function! s:suite.should_jump_to_first_last_sibling() abort
  :DBUI
  call s:expect(&filetype).to_equal('dbui')
  call cursor(1, 1)
  call s:expect(search('dadbod_ui_test', 'w')).to_be_greater_than(0)
  call s:expect(getline('.')).to_match('dadbod_ui_test')
  norm o
  norm j
  call s:expect(getline('.')).to_match('New query')
  let lnum = line('.')
  exe "norm \<C-j>"
  call s:expect(&filetype).to_equal('dbui')
  call s:expect(line('.')).not.to_equal(lnum)
  exe "norm \<C-k>"
  call s:expect(&filetype).to_equal('dbui')
endfunction

function! s:suite.should_jump_to_parent_child_node()
  :DBUI
  call s:expect(&filetype).to_equal('dbui')
  call cursor(1, 1)
  call s:expect(search('dadbod_ui_test', 'w')).to_be_greater_than(0)
  norm o
  norm j
  exe "norm \<C-j>"
  call s:expect(&filetype).to_equal('dbui')
  exe "norm \<C-n>"
  call s:expect(&filetype).to_equal('dbui')
  exe "norm \<C-p>"
  call s:expect(&filetype).to_equal('dbui')
endfunction

function! s:suite.should_jump_to_prev_next_sibling()
  :DBUI
  call s:expect(&filetype).to_equal('dbui')
  call cursor(1, 1)
  call s:expect(search('dadbod_ui_test', 'w')).to_be_greater_than(0)
  norm o
  norm j
  call s:expect(getline('.')).to_match('New query')
  let lnum = line('.')
  norm J
  call s:expect(&filetype).to_equal('dbui')
  call s:expect(line('.')).not.to_equal(lnum)
  norm K
  call s:expect(&filetype).to_equal('dbui')
endfunction

function! s:suite.should_jump_to_last_line()
  norm! gg
  norm J
  call s:expect(line('.')).to_be_greater_than(0)
  norm oj
  call s:expect(line('.')).to_be_greater_than(0)
  exe "norm \<C-j>"
  call s:expect(line('.')).to_be_greater_than(0)
  exe "norm \<C-k>"
  call s:expect(line('.')).to_be_greater_than(0)
  exe "norm \<C-j>"
  call s:expect(line('.')).to_be_greater_than(0)
endfunction
