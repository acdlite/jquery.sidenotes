# jQuery.sidenotes

[![Build Status](https://travis-ci.org/acdlite/jquery.sidenotes.png?branch=master)](https://travis-ci.org/acdlite/jquery.sidenotes)

Transform [Markdown](http://daringfireball.net/projects/markdown/) footnotes into superpowered sidenotes.

Visit the [project page](http://acdlite.github.io/jquery.sidenotes/) for full details.

## Installation

Grab `jquery.sidenotes.min.js` from the [GitHub repo](https://github.com/acdlite/jquery.sidenotes), upload it to a server, and add it to your document's head:

```html
<script src="jquery.sidenotes.min.js"></script>
```

### With Bower

jQuery.sidenotes is available as a [Bower](http://bower.io) package.

```bash
bower install jquery.sidenotes --save
```

## Usage

Apply the plugin to a jQuery object consisting of each post/document container on the page. There can only be one post per container, and each container must contain both the content of the post and its footnotes.

With no configuration (use sensible defaults):

```javascript
$('.post').sidenotes();
```

Or, pass an options object:

```javascript
$('.post').sidenotes({
  'removeRefMarkRegex':     /-sn$/,
  'initiallyHidden':        true
});
```

## TODO

- Improve the docs
- Write tests for the rest of the spec.
- Set-up browser based test page with key-bindings (like project page)

## License

Copyright 2013
[Andrew Clark](http://andrewphilipclark.com)

Licensed under the [MIT License](http://opensource.org/licenses/MIT)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/acdlite/jquery.sidenotes/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

