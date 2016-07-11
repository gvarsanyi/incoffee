#!/usr/bin/env node

require('../incoffee.js');

var T = incoffee('Test');

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
  incoffee('obj');
  shouldBeFalse = true;
} catch (err) {
  // all right
}
if (shouldBeFalse) {
  throw new Error('unexpected result: obj2');
}

try {
  incoffee('ext');
  shouldBeFalse = true;
} catch (err) {
  // all right
}
if (shouldBeFalse) {
  throw new Error('unexpected result: ext');
}

incoffee.pull(__dirname + '/../test2');

ext = incoffee('ext');
if (ext() !== 'ext') {
  throw new Error('unexpected result: ext');
}
