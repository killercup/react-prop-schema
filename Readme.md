# React Prop Schema

A library to validate a data structure and create fake content at the same time. Works great with React.js and can be used to replace `React.PropTypes`.

[![Build Status](https://travis-ci.org/killercup/react-prop-schema.svg)](https://travis-ci.org/killercup/react-prop-schema)

## Installation / Usage

This has been created to be used as a CommonJS module, using node, [browserify] or something similar. If you need a good starting point for using browserify, have a look at this project's `Gulpfile.coffee`.

Even though this library is written in CoffeeScript, a JS version can be created using `npm run precompile`. Versions uploaded to _npm_ will contain the JS files in `dist`.

Basically, you just need to run

```bash
$ npm install --save react-prop-schema
```

and then you should be able to `require('react-prop-schema')` in your code.

### Use in Production

If you use [browserify], you should compile your code with `envify` and `uglifyify` for production (so you can get rid of dead code).

Please note that if you set `NODE_ENV=production`, this:

- prevents loading and embedding [faker.js], saving you about 140kB of bandwidth
- mutes all validation warnings (but does not remove validation code)

[browserify]: http://browserify.org/

## What's so cool about this?

Let's say you have a data structure, represented by the following JSON:

```json
{
  "name": "Pascal",
  "level": 42
}
```

Everything is fine, but you are a skeptic, so you want to validate this data. Let's assume you have a tool that can validate this data using the following schema description:

```json
{
  "name": {"type": "string"},
  "level": {"type": "number", "max": 1337}
}
```

Great. There are tools for that. Nothing new. But then you want to write some tests. What data are you gonna use? Are you going write some fixtures yourself? Create a mock object using some other library?

That's what this experiment is all about. I wanted to create such a validation tool which can use the same structure to create random fake sample data (better known as samples of fake-random demo-data).

And: Good news, everyone! It works<sup>*</sup>! The source lives in `src/`.

```js
var ps = require('./prop_schema')
ps.sample({name: {type: "string"}, level: {type: "number", max: 1337}})
// => { name: 'lorem lor', level: 1278 }
```

<sup>*</sup> Sometimes, for some cases.

## What does it have to do with React.js?

I'm so glad you asked. You see, React.js has this little, often overlooked feature called [Prop Validation]. It's used during development to validate the data in your component's properties. By default, React has some nice helper methods that should get you started, e.g. `React.PropTypes.string.isRequired`.

[Prop Validation]: http://facebook.github.io/react/docs/reusable-components.html#prop-validation

But the thing is, you can easily create your own prop validators -- they are just functions that get the props and output some warning to the console.

So, of course I had to take the glorious library described above and use it to create a new validation module. I'll call it `ReactProps` for now. Then, to spice things up a bit, let's give each validator an additional method called `fake`.

You can access a React component's original `propTypes` using `component.originalSpec.propTypes` (at least in React 0.10, this is probably a private API). Using this, it is trivial to call each propType's `.fake()` method and generate a new data set for your test component.

### Complete Example

See also the CoffeeScript source of [the complete profile example](https://github.com/killercup/react-prop-schema/blob/master/examples/profile/index.coffee).

```js
var React = require('react');
var ReactProps = require('./src/react_props');

var Person = React.createClass({
  // This is the important bit
  propTypes: {
    name: ReactProps.require({
      first: {type: 'string', min: 1, max: 42, pattern: 'Name.firstName'},
      last: {type: 'string', min: 1, max: 42, pattern: 'Name.lastName'}
    }),
    age: ReactProps.require({type: 'number', min: 21, max: 42}),
  },

  render: function () {
    return React.DOM.article({key: 0, className: 'person'}, [
      React.DOM.h1({key: 0, className: 'name'}, [
        "Dr. ", this.props.name.first, " ", this.props.name.last
      ]),
      React.DOM.p({key: 1, className: 'age'}, ["Age: ", this.props.age])
    ]);
  }
});

var fakePerson = ReactProps.fake(Person, {key: 0}, []);
React.renderComponent(fakePerson, document.getElementById('container'));
```

Also note that elements with `type: string` support a special `pattern` property which can be set to a valid [faker.js] method (e.g. `'Internet.email'`), which will then be used to generate the fake data.

### Precise Validation Error

Imaging we use the example `Person` component from above with the following props:

```js
Person({key: 0, age: -1, name: {first: 42}}, []);
```

It is obvious, that neither `age` nor `name` are valid. But what exactly is wrong with them? Here is the console output you get in development mode:

> Invalid prop `age` supplied to `Person`: ["-1 should at least be 21"] [CheckError]

> Invalid prop `name` supplied to `Person`: ["42 is not a string.", "last is required but not in [object Object]"] [Array[1], CheckError]

(The arrays at the end of the lines contain the actual, nested JS Errors that can be inspected in developer tools like Chrome's inspector and that contain further information, like a reference to the value that failed to validate.)

## Getting this Experiment Started

Uses `gulp` and `browserify`, but you don't have to concern yourself with that. If you enjoy fiddling with that kind of stuff, though, I hope you enjoy reading it. I spend at least an hour to get it working (generating two JS files, one for my JS and one for external libraries).

```sh
$ npm install
$ npm run compile # or `build` to skip uglify and add sourcemaps
$ open build/index.html # works on os x at least
```

Now you should see a boring page that displays some random data on each reload using the not-so-boring idea described above.

You can use `npm run watch` to automatically recompile stuff when you change some files.

## Run the Tests

I wrote some tests to determine that the validator/faker works as expected.

Believe it or not, I even wrote an amazing new test utility for this. I'll probably call it 'try-catch-foreach' or something and will replace it with _mocha_ later on.

Run the tests with:

```sh
$ npm test
```

## Code Style

Uses _CoffeeScript_ and _lodash_, because then I can get stuff done wicked fast.

## Further Ideas

- Integrate more sophisticated random data using [faker.js] and a pattern attribute
- See all the TODOs in the code.

## Prior Art/Inspiration

- [faker.js]
- [genie]
- React's [Prop Validation]

[faker.js]: https://github.com/FotoVerite/Faker.js
[genie]: https://github.com/Trimeego/genie

## License

MIT
