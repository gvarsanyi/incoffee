#!/usr/bin/env node

require('./incoffee.js');

var T = include('Test');

var t = new T;

if (t.a !== 1) {
  throw new Error('unexpected result: a');
}

if (t.b !== 2) {
  throw new Error('unexpected result: b');
}

if (t.fn() !== 'fn') {
  throw new Error('unexpected result: fn');
}

if (t.fn2() !== 'fn2') {
  throw new Error('unexpected result: fn2');
}

if (t.obj.x !== 2) {
  throw new Error('unexpected result: obj');
}

if (t.fs !== require('fs')) {
  throw new Error('unexpected result: fs');
}

if (t.path !== require('path')) {
  throw new Error('unexpected result: path');
}

var shouldBeFalse = false;
try {
  include('obj');
  shouldBeFalse = true;
} catch (err) {
  // all right
}
if (shouldBeFalse) {
  throw new Error('unexpected result: obj2');
}

if (T.yeah1() !== 'classy') {
  throw new Error('unexpected result: yeah1');
}

if (t.yeah2() !== t) {
  throw new Error('unexpected result: yeah2');
}

var alt = {alt: true};
if (t.yeah3.call(alt) !== alt) {
  throw new Error('unexpected result: yeah3');
}

if (t.yeah4.call(alt) !== t) {
  throw new Error('unexpected result: yeah4');
}

if (t.yeah5.call(alt) !== t) {
  throw new Error('unexpected result: yeah5');
}

if (T.yoyo1 !== 'xoxo1') {
  throw new Error('unexpected result: yoyo1');
}

if (t.yoyo2 !== 'xoxo2') {
  throw new Error('unexpected result: yoyo2');
}
