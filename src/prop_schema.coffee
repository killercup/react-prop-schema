###!
# # Schema-based Porperty Validation
#
# @author Pascal Hertleif
# @license MIT
###

l = require('lodash')

if process.env.NODE_ENV is 'production'
  f = Lorem: sentence: -> "Lorem ipsum dolor sit amet."
else
  f = require('faker')

class CheckError extends Error
  constructor: (vals) ->
    @message = vals
    @stack = super.stack
    super

TYPES =
  'object':
    check: (val, schema) ->
      unless l.isObject(val)
        return [new CheckError [val, "is not an object"]]

      errs = []

      Object.keys(schema).forEach (key) ->
        subschema = schema[key]
        subval = val[key]

        if subval
          es = check(val[key], schema[key])
          errs.push(es) if es.length
        else
          if subschema.required
            errs.push new CheckError [key, "is required but not in", val]
          return

      return errs
    sample: (schema) ->
      # TODO add support for `required` (omit optional fields randomly)
      l.mapValues schema, (val) -> sample(val)

  'array':
    check: (val, {min, max, schema}) ->
      return [new CheckError [val, "is not an array."]] unless l.isArray(val)

      errs = []
      if l.isNumber(min) and val.length < min
        errs.push new CheckError [val, "of length", val.length, \
          "should at least have", min, "entries"]
      if l.isNumber(max) and val.length > max
        errs.push new CheckError [val, "of length", val.length, \
          "should at most have", max, "entries"]

      if schema
        entriesErrs = l.compact l.map val, (entry) ->
          es = check(entry, schema)
          return es if es.length

        if entriesErrs.length
          errs.push entriesErrs

      return errs

    sample: ({min, max, schema}) ->
      _min = min or 0
      _max = max or 5
      length = l.sample([_min.._max])
      return [1..length].map ->
        sample(schema)

  'boolean':
    check: (val) ->
      if l.isBoolean(val)
        []
      else
        [new Error [val, "is not a boolean"]]
    sample: -> l.sample [true, false]

  'date':
    check: (val, {min, max}) ->
      return [new CheckError [val, "is not a date."]] unless l.isDate(val)
      errs = []
      # TODO: add min/max
      return errs

    sample: ({min, max, pattern}) ->
      rightNow = new Date()

      if min or max
        f.Date.between(min or 0, max or +rightNow)
      else
        return new Date Math.random() * +rightNow

  'function':
    check: (val) ->
      if l.isFunction(val)
        []
      else
        [new Error [val, "is not a function"]]
    sample: -> ->

  'null':
    check: (val) ->
      if l.isNull(val)
        []
      else
        [new Error [val, "is not null"]]
    sample: -> null

  'number':
    check: (val, {min, max}) ->
      unless l.isNumber(val)
        return [new CheckError("#{val} is not a number.")]

      errs = []
      if l.isNumber(min) and val < min
        errs.push new CheckError [val, "should at least be", min]
      if l.isNumber(max) and val > max
        errs.push new CheckError [val, "should at most be", max]

      return errs

    sample: ({min, max, float}) ->
      n = Math.max (min or 0), (Math.random() * (max or 100))
      if not float
        Math.ceil n
      else
        n

  'regexp':
    check: (val) ->
      if l.isRegExp(val)
        []
      else
        [new Error [val, "is not a RegExp"]]
    sample: -> /^42$/

  'string':
    check: (val, {min, max}) ->
      unless l.isString(val)
        return [new CheckError [val, "is not a string."]]
      errs = []
      _len = val.length
      if l.isNumber(min) and l.isNumber(max) and min >= max
        errs.push new CheckError ["Prop min is larger than prop max"]
      if l.isNumber(min) and _len < min
        errs.push new CheckError [val, "should at least be", min, "characters"]
      if l.isNumber(max) and _len > max
        errs.push new CheckError [val, "should at most be", max, "characters"]
      return errs

    sample: ({pattern, max, min}) ->
      # Expect `pattern` to be something like `address.zipCode` or
      # `internet.domainName`.
      if l.isString(pattern) and pattern.split('.').length is 2
        contentType = pattern.split('.')
        fakeCategory = f[contentType[0]]
        contentFaker = fakeCategory?[contentType[1]]

        if l.isFunction(contentFaker)
          # Faker.js uses `this.otherFaker` a lot.
          contentFaker = contentFaker.bind(fakeCategory)
        else
          error = new Error("Can't fake string pattern #{pattern}")
          console?.warn?(error.stack or error)

      # If Faker.js does not offer this content type, fall back to Lorem Ipsum.
      unless l.isFunction(contentFaker)
        contentFaker = f.lorem.sentence.bind(f.lorem)

      lorem = contentFaker()

      if l.isNumber(min)
        while min > lorem.length
          lorem += contentFaker()

      min = if l.isNumber(min) then min else 0
      if l.isNumber(max) and max >= min
        length = l.sample l.range(min, max)
        return lorem[0..length]
      else
        return lorem

  'undefined':
    check: (val) ->
      []
      # TODO: add stuff if necessary
      # return [] if l.isUndefined(val)
      # return [new Error [val, "is not undefined"]]
    sample: ->

###
# @method Validate Data Structure
# @param {Any}    val    The value to validate
# @param {Object} schema The validation schema
# @return {Array} A list of errors, possible empty.
###
check = (val, schema) ->
  if l.isUndefined(val)
    return [new CheckError ["Value is undefined", JSON.stringify schema]]

  unless l.isObject(schema)
    return [new CheckError [schema, "is not a valid schema"]]

  if schema.type?
    _type = schema.type.toLowerCase()
  else
    # assume this is a (sub-)schema
    _type = 'object'

  type = TYPES[_type]
  unless type?
    return [new CheckError ["Can't check unknown type", type]]

  checker = type['check']
  unless l.isFunction(checker)
    return [new CheckError ["No check method for type", type]]

  errs = checker(val, schema)
  # console.log "checking", val, "using checker", "for", _type
  unless l.isArray(errs)
    return [new CheckError [errs, "is not an array result checking", _type]]

  return errs

###
# @method Generate Sample Data Structure
# @param {Object} schema The data struture
# @return {Any}   Sample/fake/mock data
###
sample = (schema) ->
  _type = schema.type or 'object'

  type = TYPES[_type]
  unless type?
    throw new CheckError(["Can't create a sample for unknown type", _type])

  sampler = type['sample']
  unless l.isFunction(sampler)
    return [new CheckError ["No sample method for type", _type]]

  # console.log "sampling", schema, "using sampler for", _type

  return sampler(schema)

module.exports =
  check: check
  sample: sample
