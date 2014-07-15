var propSchema = require('./dist/prop_schema');
var reactProps = require('./dist/react_props');

module.exports = {
  // Validator
  check: propSchema.check,
  sample: propSchema.sample,

  // React.js PropTypes
  require: reactProps.require,
  optional: reactProps.optional,
  fakeProps: reactProps.fakeProps,
  fake: reactProps.fake
};