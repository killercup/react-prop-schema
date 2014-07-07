React = require 'react'
{article, a, h1, p} = React.DOM

ReactProps = require('../../utils/react_props')

module.exports = React.createClass
  displayName: 'Person'

  propTypes:
    name: ReactProps.require(type: 'string', min: 1, max: 66)
    bio: ReactProps.require(type: 'string', min: 20, max: 133)

  render: ->
    (article {key: 0, className: 'person'}, [
      (h1 {key: 0, className: 'person__name'}, [
        @props.name
      ])
      (p {key: 1, className: 'person__bio'}, [
        (p {key: 0}, @props.bio)
      ])
    ])
