import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_context/flutter_js_context.dart';

void main() {
  group('JsRef', () {
    test('define', () {
      final ctx = JsContext();
      final ref = JsRef.define(ctx, 'databases', "2");
      expect(ref.value, 2);
    });

    test('update', () {
      final ctx = JsContext();
      final ref = JsRef.generate(ctx, 'databases');
      expect(ref.toJsCode(updater: "2"),
          "${ctx.stateVarName}['databases']['${ref.key}'] = 2");
    });

    test('toJsCode()', () {
      final ctx = JsContext();
      final ref = JsRef.generate(ctx, 'database');
      expect(ref.toJsCode(), "${ctx.stateVarName}['database']['${ref.key}']");
    });
  });

  group('JsContext', () {
    test('initialise global variables', () {
      final ctx = JsContext();
      expect(ctx.isVarDefined('window'), true);
      expect(ctx.isVarDefined('global'), true);
      expect(ctx.isVarDefined(ctx.stateVarName), true);
    });

    test('isVarDefined', () {
      final ctx = JsContext();
      expect(ctx.isVarDefined('ranmdomvar'), false);
      expect(ctx.isVarDefined('vendor.test'), false);
    });

    test('evaluate()', () {
      final ctx = JsContext();
      expect(ctx.evaluate("true"), true);
      // decode string
      expect(ctx.evaluate("'hello'"), 'hello');
      // decode number
      expect(ctx.evaluate("1"), 1);
      // decode array
      expect(ctx.evaluate("[]"), []);
      // decode map
      expect(ctx.evaluate('[{"a":1}]'), [
        {'a': 1}
      ]);
    });

    test('evaluate()', () async {
      var ctx = JsContext();
      expect(await ctx.evaluateAsync("true"), true);
      // decode string
      expect(await ctx.evaluateAsync("'hello'"), 'hello');
      // decode number
      expect(await ctx.evaluateAsync("1"), 1);
      // decode array
      expect(await ctx.evaluateAsync("[]"), []);
      // decode map
      expect(await ctx.evaluateAsync('[{"a":1}]'), [
        {'a': 1}
      ]);
    });

    test('require()', () {
      var ctx = JsContext();
      var fname = './test/test.js';
      // test variable
      ctx.require(fname, ['vendor']);
      // test function
      expect(ctx.evaluate("fnInJsFile()"), 43);
      ctx.evaluate("vendor = 2");
      expect(ctx.evaluate("fnInJsFile()"), 44);
    });
  });
}
