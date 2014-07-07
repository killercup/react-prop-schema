assert = require('assert')
l = require('lodash')

{check, sample} = require('../../app/utils/prop_schema')

tests =
  number: ->
    es = check 42, {type: 'number'}
    assert (es.length is 0), "Should validate number. #{es}"
  numberMinMax: ->
    es = check 42, {type: 'number', min: 21, max: 42}
    assert (es.length is 0), "Should validate number range. #{es}"
  numberMinMaxInvalid1: ->
    es = check 0, {type: 'number', min: 21, max: 42}
    assert (es.length > 0), "Should notice when number is too small."
  numberMinMaxInvalid2: ->
    es = check 666, {type: 'number', min: 21, max: 42}
    assert (es.length > 0), "Should notice when number is too large."
  string: ->
    es = check "hi there", {type: 'string'}
    assert (es.length is 0), "Should validate strings. #{es}"
  stringMinMax: ->
    es = check "hi there", {type: 'string', min: 5, max: 10}
    assert (es.length is 0), "Should validate string length."
  stringMinMaxInvalid1: ->
    es = check "hi", {type: 'string', min: 5, max: 10}
    assert (es.length > 0), "Should notice when string is too short."
  stringMinMaxInvalid2: ->
    es = check "hi there my dear friend", {type: 'string', min: 5, max: 10}
    assert (es.length > 0), "Should notice when string is too long."
  invalidString: ->
    es = check 42, {type: "string"}
    assert (es.length > 0), "Should notice invalid string."
  array: ->
    schema = {type: 'array', min: 1, max: 5, schema: {a: {type: 'number'}}}
    es = check [{a: 1}, {a: 2}], schema
    assert (es.length is 0), "Should validate arrays. #{es}"
  arrayItemType: ->
    schema = {type: 'array', min: 1, max: 5, schema: {a: {type: 'text'}}}
    es = check [{a: 1}, {a: 2}], schema
    assert (es.length > 0), "Should notice invalid array items."
  arrayItemCount: ->
    schema = {type: 'array', min: 1, max: 2, schema: {a: {type: 'text'}}}
    es = check [{a: '1'}, {a: '2'}, {a: '2'}], schema
    assert (es.length > 0), "Should notice invalid number of array items."
  object: ->
    es = check {
      name: 'Pascal'
      level: 42
    }, {
      name: {type: 'string'}
      level: {type: 'number'}
    }

    assert (es.length is 0), "Should validate nested object."
  objectInvalid: ->
    es = check {
      name: 'Pascal'
      level: ['1337']
    }, {
      name: {type: 'string'}
      level: {type: 'number'}
    }

    assert (es.length > 0), "Should notice invalid object."
  objectObject: ->
    es = check {
      name:
        first: 'Pascal'
        last: 'Hertleif'
    }, {
      name:
        first: {type: 'string'}
        last: {type: 'string'}
    }

    assert (es.length is 0), "Should validate nested object. #{es}"
  objectObjectInvalid: ->
    es = check {
      name:
        first: 'Pascal'
        last: -1
    }, {
      name:
        first: {type: 'string'}
        last: {type: 'string'}
    }

    assert (es.length > 0), "Should notice invalid nested object"
  objectArray: ->
    es = check {
      name: 'Pascal'
      awards: [
        {name: 'a'}
        {name: 'b'}
      ]
    }, {
      name: {type: 'string'}
      awards:
        type: 'array'
        min: 1
        max: 5
        schema:
          name: {type: 'string'}
    }
    assert(es.length is 0, "Should validate nested array. #{es}")
  objectArrayInvalidCount: ->
    es = check {
      name: 'Pascal'
      awards: [
        {name: 'a'}
        {name: 'b'}
      ]
    }, {
      name: {type: 'string'}
      awards:
        type: 'array'
        min: 1
        max: 1
        schema:
          name: {type: 'string'}
    }
    assert(es.length > 0, "Should notice invalid nested array.")
  missingRequired: ->
    es = check {name: 'Pascal', level: 42}, {
      name: {type: 'string', required: true}
      level: {type: 'number'}
      job: {type: 'string', required: true}
    }
    assert(es.length > 0, "Should notice missing required field.")

l.each tests, (test, name) ->
  try
    test()
  catch e
    console.log "Test #{name} failed.", (e.message or e)
    throw e

console.log "Prop check: Successfully ran #{Object.keys(tests).length} tests."