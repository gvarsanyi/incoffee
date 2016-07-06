require './lex'

fs   = require 'fs'
path = require 'path'

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

load_dir = (root) ->
  unless root.substr(root.length - 1) is '/'
    root += '/'

  unless fs.existsSync root
    throw new Error 'directory does not exist: ' + root
  unless fs.lstatSync(root).isDirectory()
    throw new Error 'not a directory: ' + root

  recursive_dir = (dir) ->
    for node in fs.readdirSync root + dir
      full_path = root + (if dir then dir + '/' else '') + node
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
  return

load_dir include_root

global.include = (name) ->
  unless coffee_map[name]
    throw new Error 'No such includable: ' + name
  if coffee_map[name].length > 1
    throw new Error 'Ambiguous includable: ' + name + ':\n  ? ' + coffee_map[name].join('\n  ? ')
  mod = require coffee_map[name][0]
  name_function mod, name.split('/').pop()

global.include.map = coffee_map

global.include.load_dir = load_dir

name_function global.include, 'include'
