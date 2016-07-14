require './lex'

fs   = require 'fs'
path = require 'path'


class InCoffee
  loaded:  []   # array of loaded dirs. By default it is: [@root], but calling @pull(dir) may add to it or replace
  map:     {}   # {module_name: 'file'} style hashmap. modules will be replicated, as in: `str` and `helpers/str` will both appear for `helpers/str.coffee`
  root:    null # project root

  constructor: ->
    @nameFunction @include, 'incoffee'
    @pull @updateRoot()
    @bindings()

  bindings: =>
    module.exports = global.incoffee = @incoffee

    global.incoffee.loaded = @loaded
    global.incoffee.map    = @map
    global.incoffee.pull   = @pull
    global.incoffee.root   = @root
    return

  incoffee: (name) =>
    unless @map[name]
      throw new Error 'No such includable: ' + name

    if @map[name].length > 1
      throw new Error 'Ambiguous includable: ' + name + ':\n  ? ' + @map[name].join('\n  ? ')

    mod = require @map[name][0]

    # name the function (if unnamed) and return it
    @nameFunction mod, name.split('/').pop()

  nameFunction: (fn, name, overwrite = false) ->
    if typeof fn is 'function' and (overwrite or not fn.name)
      Object.defineProperty fn, 'name',
        configurable: true
        value:        name
    fn

  pull: (root, clear = false) =>
    unless root.substr(root.length - 1) is '/'
      root += '/'

    try stat = fs.lstatSync root
    unless stat?.isDirectory()
      throw new Error 'not a directory: ' + root

    if clear
      for own key of @map
        delete @map[key]
      while @loaded.length
        @loaded.pop()

    recursive_dir = (dir) =>
      for node in fs.readdirSync root + dir when not (node.substr(0, 1) in ['.', '~', '!'])
        full_path = root + (if dir then dir + '/' else '') + node
        pos = node.indexOf '.coffee'
        if pos > 0 and node.length - 7 is pos
          name = node.substr 0, pos
          parts = (if dir then dir + '/' + name else name).split '/'
          for part, i in parts
            id = parts[i ...].join '/'
            (@map[id] ?= []).push full_path
        if node isnt 'node_modules' and fs.lstatSync(full_path).isDirectory()
          recursive_dir (if dir then dir + '/' + node else node)
      return

    recursive_dir ''
    @loaded.push root
    return

  updateRoot: =>
    if path.basename(module.parent?.filename) is 'incoffee.js' and
    path.basename(module.parent.parent?.filename) is 'incoffee' and
    (not module.parent.parent.parent?) and
    path.basename(process.argv[0]) is 'nodejs' and
    path.basename(process.argv[1]) is 'incoffee' and
    process.argv.length > 2
      @root = path.dirname path.resolve process.cwd(), process.argv[2]
    else if local = module.parent?.parent?.filename
      @root = path.dirname local
    else
      @root = process.cwd()

    @root = path.resolve @root

    unless @root.substr(@root.length - 1) is '/'
      @root += '/'

    @root


new InCoffee
