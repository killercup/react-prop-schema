assert = require('assert')
l = require('lodash')
R = require('react')

Props = require('../src/react_props')

tests =
  validateRequiredProp: ->
    check = Props.require({type: 'boolean'})

    val = check({a: false, b: 42}, 'c', 'demo', '')
    assert (val instanceof Error), "Should notice missing required prop"

    val = check({a: false, b: 42}, 'b', 'demo', '')
    assert (val instanceof Error), "Should notice invalid required prop"

    val = check({a: false, b: 42}, 'a', 'demo', '')
    assert (val is undefined), "Should validate required prop"

  validateOptionalProp: ->
    check = Props.optional({type: 'boolean'})

    val = check({a: false, b: 42}, 'c', 'demo', '')
    assert (val is undefined), "Should ignore missing optional prop"

    val = check({a: false, b: 42}, 'b', 'demo', '')
    assert (val instanceof Error), "Should notice invalid optional prop"

    val = check({a: false, b: 42}, 'a', 'demo', '')
    assert (val is undefined), "Should validate optional prop"

l.each tests, (test, name) ->
  try
    test()
  catch e
    console.log "Test #{name} failed.", (e.message or e)
    throw e

console.log "Prop check: Successfully ran #{Object.keys(tests).length} tests."
