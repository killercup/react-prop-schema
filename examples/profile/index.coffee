###
# # React.js With Fake Properties
#
# Create a Person component with specified prop types and render it with
# automatically generated fake data.
###

React = require('react')
{article, h1, p, ul, li} = React.DOM

# Load the magic
ReactProps = require('../../src/react_props')

# Create an example component
Person = React.createClass
  displayName: 'Person'

  # This is the important bit
  propTypes:
    name: ReactProps.require
      dr: {type: 'boolean'}
      first: {type: 'string', min: 1, max: 21, required: true}
      last: {type: 'string', min: 1, max: 42, required: true}
    bio: ReactProps.require
      type: 'string', min: 20, max: 140
    age: ReactProps.require
      type: 'number', min: 21, max: 42
    updates: ReactProps.require
      type: 'array', min: 5, max: 10,
      schema:
        body: {type: 'string', min: 1, max: 21}
        created: {type: 'date'}

  render: ->
    (article {key: 0, className: 'person'}, [
      (h1 {key: 0, className: 'name'}, [
        (if @props.name.dr then "Dr. " else "")
        @props.name.first
        @props.name.last
      ])
      (p {key: 1, className: 'age'}, ["Age: ", @props.age])
      (p {key: 2, className: 'bio'}, [@props.bio])
      (ul {key: 3, className: 'updates'}, @props.updates.map (update, index) ->
        (li {key: index, className: 'update'}, [
          update.body
          " (#{update.created.toDateString()})"
        ])
      )
    ])

# Render a fake component instance it to the browser DOM.
React.renderComponent(
  (ReactProps.fake Person, {key: 0}, []),
  document.getElementById('container')
)
