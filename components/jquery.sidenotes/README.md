# jQuery.asides

Transform Markdown footnotes into superpowered sidenotes.

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

## License

Copyright 2013
[Andrew Clark](http://andrewphilipclark.com)

Licensed under the [MIT License](http://opensource.org/licenses/MIT)