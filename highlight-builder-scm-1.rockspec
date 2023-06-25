rockspec_format = '3.0'
package = 'highlight-builder.nvim'
version = 'scm-1'

test_dependencies = {
  'lua >= 5.1',
}

source = {
    url = 'git://github.com/nenikitov/' .. package,
}

build = {
    type = 'builtin',
}
