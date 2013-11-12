# jQuery.asides

Transform Markdown footnotes into superpowered sidenotes.

Visit the [project page](http://acdlite.github.io/jquery.sidenotes/) for full details.

## Installation

Upload `jquery.sidenotes.min.js` to a server and add it to your document's head:

```html
<script src="jquery.sidenotes.min.js"></script>
```

### With Bower

jQuery.sidenotes is available as a [Bower](http://bower.io) package.

```bash
bower install jquery.sidenotes
```

## Usage

With no configuration (use sensible defaults):

```javascript
// Apply to your post/document container(s).
$('.post').sidenotes();
```

With options:

```javascript
// Pass a options object
$('.post').sidenotes({
  'removeRefMarkRegex':     /-sn$/,
  'initiallyHidden':        true
});
```

## TODO

* Write some tests.

## License

Copyright 2013
[Andrew Clark](http://andrewphilipclark.com)

Licensed under the [MIT License](http://opensource.org/licenses/MIT)
