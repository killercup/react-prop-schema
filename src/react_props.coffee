###!
# # React.js Compatible Data Structure Validation
#
# @author Pascal Hertleif
# @license MIT
###

l = require('lodash')
PropSchema = require('./prop_schema')


warn = ->
if process.env.NODE_ENV isnt 'production' and console?.warn?
  warn = (args...) ->
    console.warn.apply(console, args)

###
# @method Create Prop Checks
#
# The resulting validator function will be called with these arguments
# (cf. [1]): props, propName, componentName, location.
#
# [1]: https://github.com/facebook/react/blob/e10d10e31e0a1dfba16880f8f065de8329c896dc/src/core/ReactPropTypes.js#L262
###
createPropChecks = (required, schema) ->
  _schema = schema
  validator = (val) -> PropSchema.check(val, schema)

  checker = (props, propName, componentName, location) ->
    value = props[propName]
    if required and not value
      warn new Error(
        "Required prop `#{propName}` was not specified in " +
        "`#{componentName or 'anonymous component'}`."
      )
    else
      errors = validator(value)
      if errors.length
        warn(
          "Invalid prop `#{propName}` supplied to " +
          "`#{componentName or 'anonymous component'}` at #{location}:",
          (l.flatten(errors).map (e) -> e.message?.join(' ') or e),
          errors
        )

  checker.fake = -> PropSchema.sample(schema)

  return checker

###
# @method Create Fake Props for a Component
###
fakeProps = (_component) ->
  component = _component.originalSpec or _component
  props = component?.propTypes

  if not props
    warn new Error "Can't retrieve prop types for component " +
      "#{component.displayName or component}."
    return

  l.mapValues props, (type) ->
    type?.fake?()

module.exports =
  require: createPropChecks.bind(null, true)
  optional: createPropChecks.bind(null, false)
  fakeProps: fakeProps
  fake: (component, props={}, childs=[]) ->
    component l.extend({}, props, fakeProps(component)), childs
