assert = require('assert')
l = require('lodash')

{check, sample} = require('../src/prop_schema')

testSample = (schema) -> ->
  s = sample(schema)
  es = check s, schema
  errs = l.flatten(es).map (e) -> e.message
  assert (es.length is 0), errs

tests =
  number: testSample {type: 'number'}
  numberMinMax: testSample {type: 'number', min: 21, max: 42}
  string: testSample {type: 'string'}
  array: testSample {type: 'array', min: 1, max: 1, schema: {a: {type: 'number'}}}
  object: testSample {
    name: {type: 'string'}
    awesomeness: {type: 'number'}
  }
  objectObject: testSample {
    name:
      first: {type: 'string'}
      last: {type: 'string'}
  }
  objectArray: testSample {
    name: {type: 'string'}
    awards:
      type: 'array'
      min: 1
      max: 5
      schema:
        name: {type: 'string'}
  }

l.each tests, (test, name) ->
  try
    test()
  catch e
    console.log "Test #{name} failed.", (e.message or e)
    throw e

console.log "Prop sample: Successfully ran #{Object.keys(tests).length} tests."