###
# # React.js With Fake Properties
#
# Create a Person component with specified prop types and render it with
# automatically generated fake data.
###

React = require('react')
{article, div, h1, p, ul, li, button} = React.DOM

# Load the magic
ReactProps = require('../../src/react_props')

# Create an example component
Person = React.createClass
  displayName: 'Person'

  # This is the important bit: Each prop key is described using ReactProps
  propTypes:
    name: ReactProps.require
      dr: {type: 'boolean'}
      first: {type: 'string', min: 1, max: 21, pattern: 'Name.firstName'}
      last: {type: 'string', min: 1, max: 42, pattern: 'Name.lastName'}
    bio: ReactProps.require
      type: 'string', min: 20, max: 140
    age: ReactProps.require
      type: 'number', min: 21, max: 42
    updates: ReactProps.require
      type: 'array', min: 1, max: 5,
      schema:
        body: {type: 'string', min: 1, max: 21}
        created: {type: 'date'}

  render: ->
    (article {key: 0, className: 'person panel panel-default'}, [
      (div {key: 0, className: 'name panel-heading'}, [
        (h1 {key: 0, className: 'panel-title'}, [
          (if @props.name.dr then "Dr. " else "")
          @props.name.first, " ", @props.name.last
        ])
      ])
      (div {key: 1, className: 'panel-body'}, [
        (p {key: 1, className: 'age'}, ["Age: ", @props.age])
        (p {key: 2, className: 'bio'}, [@props.bio])
      ])
      (ul {key: 3, className: 'updates list-group'}, @props.updates.map (update, index) ->
        (li {key: index, className: 'update list-group-item'}, [
          update.body
          " (#{update.created.toDateString()})"
        ])
      )
    ])

generatePeople = (n=3) ->
  [1..n].map (i) ->
    (div {key: i, className: 'col-sm-4'},
      ReactProps.fake(Person, {key: 0})
    )

# Show a few random people next to each other
People = React.createClass
  displayName: 'People'

  getDefaultProps: ->
    list: generatePeople()

  render: ->
    shuffle = =>
      @setProps list: generatePeople()

    (div {key: 0}, [
      (div {key: 0, className: 'row'}, [
        (h1 {key: 0}, [
          "People "
          (button {key: 1, className: 'btn btn-primary', onClick: shuffle},
            "Shuffle"
          )
        ])
      ])
      (div {key: 1, className: 'people row'}, @props.list)
    ])

# Render stuff to the DOM
React.renderComponent(
  (People {key: 0}, [])
  document.getElementById('container')
)
