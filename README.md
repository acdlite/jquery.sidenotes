# jQuery.sidenotes

Transform Markdown footnotes into superpowered[^notes] sidenotes.

[^notes]: Wanna see something cool? Resize this page and watch how this note adapts to different screen sizes.

## Installation

Upload `jquery.sidenotes.min.js` to a server and add it to your document's head:
```html
<script src="jquery.sidenotes.min.js"></script>
```

### With Bower

jQuery.sidenotes is available as a [Bower](http://bower.io) package.

    bower install jquery.sidenotes

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