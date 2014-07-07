React = require('react')
l = require('lodash')

Person = require('../components/2-person')
Types = require('../utils/react_props')

React.renderComponent(
  (Types.fake Person, {key: 0}, []),
  document.getElementById('container')
)