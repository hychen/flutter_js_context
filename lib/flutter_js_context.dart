/// Enhances the interoperability between Dart and flutter_js.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_js/flutter_js.dart';
import 'package:short_uuids/short_uuids.dart';

const uuid = ShortUuid();

/// A reference to deal with the updating and retrieving the valye of a
/// JavaScript object inside JavaScript runtime.
class JsRef {
  /// The context this reference bound.
  final JsContext context;

  /// The name of the space to storage actual value inside Js runtime.
  final String ns;

  /// The key of this reference.
  final String key;

  JsRef(this.context, this.ns, this.key);

  /// Creates a reference that the key is generated automatically.
  factory JsRef.generate(JsContext context, String ns) {
    return JsRef(context, ns, uuid.generate());
  }

  /// Defines a reference with a {updater} that change the value.
  /// the updater is a pure Javascript string.
  factory JsRef.define(JsContext context, String ns, String updater) {
    if(!context.isVarDefined(ns)) {
      context.evaluate("${context.stateVarName}['$ns'] = {}");
    }
    final ref = JsRef.generate(context, ns);
    ref.update(updater);
    return ref;
  }

  /// Returns the value of this reference in the context.
  get value => context.evaluate(toJsCode());

  /// Updates the value of this reference in the context.
  update(String updaterJs) {
    return context.evaluate(toJsCode(updater: updaterJs));
  }

  /// Same as [update] but executes asynchronously.
  updateAsync(String updaterJs) async {
    return context.evaluateAsync(toJsCode(updater: updaterJs));
  }

  /// Convert this reference to Javascript code. It is the code to update the
  /// value if the updater is specified, otherwise it is the code to retrieve
  /// the value.
  String toJsCode({String? updater}) {
    if (updater == null) {
      return "${context.stateVarName}['$ns']['$key']";
    } else {
      return "${context.stateVarName}['$ns']['$key'] = $updater";
    }
  }
}

/// Represents the state of a Javascript runtime.
///
/// - Tracks which variables are defined.
/// - Decodes evaluated results that the type are assumed as JSON always.
/// - Loads Js file properly.
class JsContext {
  /// The unique key.
  String key;

  /// The JavaScript runtime this context using.
  JavascriptRuntime runtime;

  JsContext()
      : key = uuid.generate(),
        runtime = getJavascriptRuntime(xhr: false) {
    final result = runtime.evaluate("""
    var window = global = globalThis;
    var $stateVarName = {};
    """);
    assert(!result.isError, result.toString());
  }

  String get stateVarName => "state$key";

  /// Returns true if the name is defined in JavaScript runtime.
  bool isVarDefined(String name) {
    String used = runtime.evaluate("""
    (typeof $name === 'undefined') ? 0 : 1;
    """).stringResult;
    return used == '0' ? false : true;
  }

  /// Evaluates the string in JavaScript engine and returns decoded
  /// result.
  ///
  /// Throws the result as a string.
  evaluate(String code) {
    var result = runtime.evaluate(code);
    assert(!result.isError, result.toString());
    return runtime.convertValue(result);
  }

  /// Same as [evaluate] but executes asynchronously.
  evaluateAsync(String code) async {
    var result = await runtime.evaluateAsync(code);
    assert(!result.isError, result.toString());
    return runtime.convertValue(result);
  }

  /// Requires a js file.
  void require(String fname, List namespaces) {
    if(!namespaces.every((element) => isVarDefined(element))) {
      JsEvalResult result = runtime.evaluate(File(fname).readAsStringSync());
      assert(
      !result.isError && namespaces.every((element) => isVarDefined(element)),
      "loading $fname failed");
    }
  }
}

List<String> toJsCode(List x) {
  return x.map((e) {
    if (e.runtimeType == JsRef) {
      return (e as JsRef).toJsCode();
    } else {
      return jsonEncode(e);
    }
  }).toList();
}
