var gulp = require('gulp');
var foreman = require('gulp-foreman');

gulp.task('default', function (argument) {
  foreman({
    procfile: 'Procfile.hot'
  });
});
