fs   = require 'fs'
path = require 'path'

CoffeeScript = require 'coffee-script'


name_function = (fn, name, overwrite = false) ->
  if typeof fn is 'function' and (overwrite or not fn.name)
    Object.defineProperty fn, 'name',
      configurable: true
      value:        name
  fn


global.include_root ?= path.dirname(module.parent?.parent?.filename or __filename)

unless include_root.substr(include_root.length - 1) is '/'
  global.include_root += '/'

coffee_map = {}
recursive_dir = (dir) ->
  for node in fs.readdirSync include_root + dir
    full_path = include_root + (if dir then dir + '/' else '') + node
    pos = node.indexOf '.coffee'
    if pos > 0 and node.length - 7 is pos
      name = node.substr 0, pos
      parts = (if dir then dir + '/' + name else name).split '/'
      for part, i in parts
        id = parts[i ...].join '/'
        (coffee_map[id] ?= []).push full_path
    if node isnt 'node_modules' and fs.lstatSync(full_path).isDirectory()
      recursive_dir (if dir then dir + '/' + node else node)
  return

recursive_dir ''


CoffeeScript._compileFile = (filename, sourceMap) ->
  unless fs.existsSync filename
    throw 'include not found: ' + filename

  original = fs.readFileSync filename, 'utf8'
  lines = original.split '\n'
  changed_lines = {}
  replace = (symbol, type) ->
    for line, i in lines
      if line.trim() and not (
        changed_lines[i] or line.trim().substr(0, 1) is '#' or
        line.split(' ')[0] in ['&', '<', 'require', 'include']
      )
        return
      if !~line.indexOf('=') and !~line.indexOf('\'') and !~line.indexOf('"')
        vals = []
        if line.trim().substr(0, symbol.length + 1) is symbol + ' '
          vals = line.trim().substr(symbol.length + 1).trim().split(',').join(' ').split(' ')
        if line.trim().substr(0, type.length + 1) is type + ' '
          vals = line.trim().substr(type.length + 1).trim().split(',').join(' ').split(' ')
        mods = []
        for val in vals when mod = val.trim()
          mods.push mod.split('/').pop().split('-').join('_') + ' = ' + type + '(\'' + mod + '\')'
        if mods.length
          lines[i] = mods.join '; '
          changed_lines[i] = true
    return

  replace '&', 'require'
  replace '<', 'include'

  for line, i in lines
    words = line.split ' '
    if words.length >= 4
      last_words = words[words.length - 4 ...]
      if last_words.length is 4 and last_words[0] is 'class' and last_words[2] is '<'
        lines[i] = words[0 ... words.length - 2].join(' ') + ' extends include(\'' + last_words[3] + '\')' 

  for line, i in lines
    if line.substr(0, 7) is 'export ' or line is 'export'
      lines[i] = 'module.exports = ' + line.substr 7
    else if line.substr(0, 2) is '> ' or line is '>'
      lines[i] = 'module.exports = ' + line.substr 2

  literate = CoffeeScript.helpers.isLiterate filename
  CoffeeScript.compile lines.join('\n'), {filename, sourceMap, literate}


global.include = (name) ->
  unless coffee_map[name]
    throw new Error 'No such includable: ' + name
  if coffee_map[name].length > 1
    throw new Error 'Ambiguous includable: ' + name + ':\n  ? ' + coffee_map[name].join('\n  ? ')
  mod = require coffee_map[name][0]
  name_function mod, name.split('/').pop()

global.include.map = coffee_map


name_function global.include, 'include'
