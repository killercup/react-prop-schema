###
# # React.js With Fake Properties
#
# Create a Person component with specified prop types and render it with
# automatically generated fake data.
###

React = require('react')
{article, div, h1, p} = React.DOM

# Load the magic
ReactProps = require('../utils/react_props')

# Create an example component
Person = React.createClass
  displayName: 'Person'

  # This is the important bit
  propTypes:
    name: ReactProps.require(type: 'string', min: 1, max: 66)
    bio: ReactProps.require(type: 'string', min: 20, max: 140)
    age: ReactProps.require(type: 'number', min: 21, max: 42)

  render: ->
    (article {key: 0, className: 'person'}, [
      (h1 {key: 0, className: 'name'}, ["Dr. ", @props.name])
      (p {key: 1, className: 'age'}, ["Age: ", @props.age])
      (p {key: 2, className: 'bio'}, [@props.bio])
    ])

# Render a fake component instance it to the browser DOM.
React.renderComponent(
  (ReactProps.fake Person, {key: 0}, []),
  document.getElementById('container')
)
