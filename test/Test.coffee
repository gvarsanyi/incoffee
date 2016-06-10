&: Test3, Test4
*: path fs


module.exports = class Test extends &Test2
  b: 2
  path: path
  fs: fs
  child_process: *child_process
  fn: &fn
  Test3: Test3
  fn2: include 'fn2'
  obj: include 'rnd_name/obj'
