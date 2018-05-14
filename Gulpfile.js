let gulp = require("gulp");
let sass = require("gulp-sass");
let imagemin = require("gulp-imagemin");
let elm = require("gulp-elm");
let plumber = require("gulp-plumber");
let uglify = require("gulp-uglify");
let path = require("path");

let paths = {
    elm: path.normalize("./src/*.elm"),
    builds: path.normalize("./dist/static/"),
    tmpl: path.normalize("./dist")
};


let onError = function(err) {
    console.log(err);
};
let debounce = function(fn) {
    let timer = null;
    return function () {
        let context = this, args = arguments;
        clearTimeout(timer);
        timer = setTimeout(function () {
            fn.apply(context, args);
        }, 3000);
    };
};

gulp.task("elm-init", function() { return elm.init({cwd: "src"}) });

gulp.task("frontend", ["elm-init"], function() {
    return gulp.src(paths.elm)
        .pipe(plumber({errorHandler: onError}))
        .pipe(elm.make({cwd: "src"}))
        .pipe(uglify())
        .pipe(gulp.dest(path.normalize(paths.builds + "js")));
});

gulp.task("images", function() {
    gulp.src("src/images/**/*")
        .pipe(plumber({errorHandler: onError}))
        .pipe(imagemin([
            imagemin.gifsicle({interlaced: true}),
            imagemin.jpegtran({progressive: true}),
            imagemin.optipng({optimizationLevel: 5}),
            imagemin.svgo({
                plugins: [
                    {removeViewBox: true},
                    {cleanupIDs: false}
                ]
            })
        ]))
        .pipe(gulp.dest("dist/static/images"));
})

gulp.task("styles", function() {
    gulp.src("src/sass/**/*.+(sass|scss)")
        .pipe(sass().on("error", sass.logError))
        .pipe(gulp.dest("./dist/static/css/"));
});

gulp.task("templates", function() {
    gulp.src("src/**/*.html")
        .pipe(gulp.dest("./dist"));
});

gulp.task("build", ["images", "styles", "frontend", "templates"]);

gulp.task("default", function() {
    gulp.watch("src/sass/**/*.+(sass|scss)", ["styles"]);
    gulp.watch("src/images/**/*", ["images"]);
    gulp.watch(paths.elm, ["elm-init"]).on("change", debounce(function(file) {
        return gulp.src(file.path)
            .pipe(plumber({errorHandler: onError}))
            .pipe(elm.make({cwd: "src"}))
            .pipe(uglify())
            .pipe(gulp.dest(path.normalize(paths.builds + "js")));
    }));
    gulp.watch("src/**/*.html", ["templates"]);
});