# React Prop Schema

_Experiment:_ Create a utility to check a data structure and create fake content at the same time and that works with React.js.

[![Build Status](https://travis-ci.org/killercup/react-prop-schema.svg)](https://travis-ci.org/killercup/react-prop-schema)

## What's so cool about this?

Let's say you have a data structure, represented by the following JSON:

```json
{
  "name": "Pascal",
  "level": 42
}
```

Everything is fine, but you are a skeptic, so you want to validate this data. Let's assume you have a tool that does that using the following description:

```json
{
  "name": {"type": "string"},
  "level": {"type": "number", "max": 1337}
}
```

Great. There are tools for that. Nothing new. But then you want to write some tests. What data are you gonna use? Are you going write some fixtures yourself? Create a mock object using some other library?

That's what this experiment is all about. I wanted to create such a validation tool which can use the same structure to create random fake sample data (better known as samples of fake-random demo-data).

And: Good news, everyone! It works<sup>*</sup>!

<sup>*</sup> Sometimes.

## What does it have to do with React.js?

I'm so glad you asked. You see, React.js has this little, often overlooked feature called [Prop Validation]. It's used during development to validate the data in you props. By default, React has some nice helper methods that should get you started, e.g. `React.PropTypes.string.isRequired`.

But the best thing is, you can create your own prop validators -- they are just functions that get the props and output some warning to the console.

So, we take our library from above and use it to crate a new validation module. Let's call it `ReactProps` for now. Then we spice things up a bit and give each validator an additional method called `fake`.

You can access a React component's original `propTypes` using `component.originalSpec.propTypes` (at least in React 0.10, this is probably a private API). Using this, it is trivial to call each propType's `.fake()` method and generate a new data set for your test component.

[Prop Validation]: http://facebook.github.io/react/docs/reusable-components.html#prop-validation

## Getting this Experiment Started

Uses `gulp` and `browserify`, but you don't have to concern yourself with that. If you enjoy fiddling with that kind of stuff, though, I hope you enjoy reading it. I spend at least an hour to get it working (generating two JS files, one for my JS and one for external libraries).

```sh
$ npm install
$ npm run compile # or build to skip uglify and add sourcemaps
$ open build/index.html # works on os x at least
```

Now you should see a boring page that displays some random data on each reload using the not-so-boring idea described above.

You can use `npm run watch` to automatically recompile stuff when you change some files.

## Run the Tests

I write some tests to determine that the validator/faker works as expected.

Believe it or not, I wrote an amazing new test utility for this. I'll probably call it 'try-catch-foreach' or something.

Run the tests with:

```sh
$ npm test
```

## Code Style

Uses CoffeeScript and lodash, because then I can get stuff done wicked fast.

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
