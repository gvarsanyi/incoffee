&: Test3, Test4
*: path fs


module.exports = class Test extends &Test2
  b: 2
  path: path
  fs: fs
  child_process: *child_process
  fn: &fn
  Test3: Test3
  fn2: incoffee 'fn2'
  obj: incoffee 'rnd_name/obj'
