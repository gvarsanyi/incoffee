Lexer = require('coffee-script/lib/coffee-script/lexer').Lexer

orig_jstoken = Lexer::jsToken

Lexer::jsToken = ->
  INCLUDES = ['&', /^\&\:.*/]
  INCLUDE  = ['&', /^\&[\w\/\-]+/]
  REQUIRES = ['*', /^\*\:.*/]
  REQUIRE  = ['*', /^\*[\w\/\-\.]+/]

  condition = (first, rx) =>
    if @chunk.charAt(0) is first and match = rx.exec @chunk
      return match?[0]
    return

  proc = (word, js) =>
    @token 'JS', js, 0, word.length
    word.length

  sane_name = (str) ->
    str.split('/').pop().split('-').join('_').split('.')[0]

  if word = condition INCLUDES...
    mods = []
    for mod in word.substr(2).split(',').join(' ').split(' ') when mod = mod.trim()
      mods.push sane_name(mod) + ' = incoffee(\'' + mod + '\')'
    if mods.length
      return proc word, 'var ' + mods.join ', '

  if word = condition REQUIRES...
    mods = []
    for mod in word.substr(2).split(',').join(' ').split(' ') when mod = mod.trim()
      mods.push sane_name(mod) + ' = require(\'' + mod + '\')'
    if mods.length
      return proc word, 'var ' + mods.join ', '

  if word = condition INCLUDE...
    return proc word, 'incoffee(\'' + word.substr(1) + '\')'

  if word = condition REQUIRE...
    return proc word, 'require(\'' + word.substr(1) + '\')'

  orig_jstoken.call @
