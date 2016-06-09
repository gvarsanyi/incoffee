include fn
< Test4

& path
require fs


> class Test < *Test2
  <- *Test3.yeah1
  <- *Test3::yeah2
  <- *Test3::yeah3
  <= *Test3::yeah4
  <= *Test3::yeah5
  <- Test4.yoyo1
  <- Test4::yoyo2

  b: 2
  path: path
  fs: fs
  fn: fn
  fn2: include 'fn2'
  obj: include 'rnd_name/obj'
