< Test2
include fn

& path
require fs


> class Test < Test2
  b: 2
  path: path
  fs: fs
  fn: fn
  fn2: include 'fn2'
  obj: include 'rnd_name/obj'
