# # Frontend Build Process

gulp = require('gulp')
gutil = require('gulp-util')
plumber = require('gulp-plumber')
source = require('vinyl-source-stream')

# ## CONSTS

PATHS =
  app:
    src: './examples/profile'
    entry: './examples/profile/index.coffee'
    dest: './build'
    name: 'le-app.js'
  libs:
    entry: './examples/profile/vendor.js'
    name: 'vendor.js'
    dest: './build'

LIBS = require(PATHS.libs.entry)

# ## Helpers

ENV = name: process.env.NODE_ENV or 'development'
ENV.compress = ENV.name is 'production'
ENV.watch = ENV.name is 'development'
ENV.debug = ENV.name isnt 'production'

log = (task, level) ->
  return (_msg) ->
    if level is 'err'
      msg = gutil.colors.red(_msg)
    else
      msg = _msg

    gutil.log(gutil.colors.cyan("[#{task}]"), msg)

# ## Processes

###
# @method Compile Vendor Scripts
# @description Create a file with required js libraries
###
compileVendorScripts = ({name, dest, env, libs}) ->
  TASK = 'browserify:vendor'

  bundler = require('browserify')
    entries: libs.entry, extensions: ['.js', '.coffee']

  bundler.transform require('coffeeify')

  if env.compress
    bundler.transform {global: true}, 'envify'
    bundler.transform {global: true}, 'uglifyify'

  libs.forEach (lib) ->
    bundler.require(lib)

  bundler.bundle(debug: env.debug)
  .on 'error', log(TASK, 'err')
  .pipe source(name)
  .pipe gulp.dest(dest)
  .pipe plumber()
  .on 'end', -> log(TASK)("recompiled")

  ###
  # @method Compile Application Scripts
  # @description Bundle application files
  ###
compileScripts = ({src, name, dest, libs, env, watch}) ->
  TASK = "browserify:app#{if watch then ':watch' else ''}"

  action = if watch then require('watchify') else require('browserify')
  
  bundler = action
    entries: src,
    extensions: ['.js', '.json', '.coffee']

  bundler.transform require('coffeeify')

  if env.compress
    bundler.transform {global: true}, 'envify'
    bundler.transform {global: true}, 'uglifyify'

  libs.forEach (lib) ->
    bundler.external(lib)

  rebundle = ->
    bundler.bundle(debug: env.debug)
    .on 'error', log(TASK, 'err')
    .pipe source(name)
    .pipe plumber()
    .pipe gulp.dest(dest)
    .on 'end', -> log(TASK)("recompiled")

  bundler.on 'update', rebundle

  return rebundle()
  .on 'error', log(TASK, 'err')

# ## Tasks

gulp.task 'clean', ->
  gulp.src("#{PATHS.app.dest}/**/*", read: false)
  .pipe require('gulp-rimraf')()

gulp.task 'copy:assets', ->
  gulp.src("#{PATHS.app.src}/**/*.html")
  .pipe gulp.dest PATHS.app.dest

gulp.task 'copy:assets:watch', ['copy:assets'], ->
  gulp.watch("#{PATHS.app.src}/**/*.html", ['copy:assets'])

gulp.task 'scripts:vendor', ->
  compileVendorScripts
    env: ENV
    name: PATHS.libs.name
    dest: PATHS.libs.dest
    libs: LIBS

gulp.task 'scripts:app', ->
  compileScripts
    env: ENV
    src: PATHS.app.entry
    name: PATHS.app.name
    dest: PATHS.app.dest
    libs: LIBS
    watch: false

gulp.task 'scripts:app:watch', ->
  compileScripts
    env: ENV
    src: PATHS.app.entry
    name: PATHS.app.name
    dest: PATHS.app.dest
    libs: LIBS
    watch: true

gulp.task 'default', ['clean', 'copy:assets', 'scripts:vendor', 'scripts:app']

gulp.task 'watch', ['clean', 'copy:assets:watch', 'scripts:vendor', 'scripts:app:watch']
