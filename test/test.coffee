fs = require 'fs'
chai = require 'chai'
jsdom = require 'jsdom'
jQuery = require 'jQuery'

expect = chai.expect

window = jsdom.jsdom().createWindow()
document = window.document

global.jQuery = $ = jQuery.create(window)
global.window = window
global.document = document

require '../lib/jquery.sidenotes.js'

testHtml = fs.readFileSync 'test/test.html', 'utf8'

$postContainer = -> $('.post')
$footnoteContainer = -> $('.footnotes')
$sidenotes = -> $('.sidenote')
$footnotes = -> $('> ol > li', $footnoteContainer())
$groups = -> $('.sidenote-group')
$pivots = -> $('.pivot')

$footnote = (n) -> $footnotes().eq(n-1)
$sidenote = (n) -> $sidenotes().eq(n-1)
$group = (n) -> $groups().eq(n-1)
$pivot = (n) -> $pivots().eq(n-1)

setup = ->
  $('body').html testHtml
teardown = -> 
  $('body').html ''

footnotesAreHidden = ->
  containerIsHidden = $footnoteContainer().is(':hidden')
  notesAreHidden = true
  $footnotes().each ->
    notesAreHidden = $(this).is(':hidden')
  return containerIsHidden and notesAreHidden

sidenotesAreHidden = ->
  notesAreHidden = true
  $sidenotes().each ->
    notesAreHidden = $(this).is(':hidden')
  return notesAreHidden

placementAfterTest = ->
  expect($pivot(1).next().is($sidenote(1))).to.be.true
  expect($pivot(2).next().is($group(1))).to.be.true
  expect($pivot(3).next().is($sidenote(4))).to.be.true
  expect($pivot(4).next().is($group(2))).to.be.true

placementBeforeTest = ->
  expect($pivot(1).prev().is($sidenote(1))).to.be.true
  expect($pivot(2).prev().is($group(1))).to.be.true
  expect($pivot(3).prev().is($sidenote(4))).to.be.true
  expect($pivot(4).prev().is($group(2))).to.be.true

plugin = (args...) -> $postContainer().sidenotes(args...)

describe 'Plugin initialization:', ->

  describe 'Default constructor', ->

    beforeEach ->
      setup()
      plugin()    

    it 'should create the same number of sidenotes as footnotes', ->
      expect($sidenotes()).to.have.length 8
      plugin 'destroy'

    it 'should group adjacent sidenotes', ->
      expect($sidenote(2).parent().is($group(1))).to.be.true
      expect($sidenote(3).parent().is($group(1))).to.be.true
      expect($sidenote(5).parent().is($group(2))).to.be.true
      expect($sidenote(6).parent().is($group(2))).to.be.true
      expect($sidenote(7).parent().is($group(2))).to.be.true
      plugin 'destroy'

    it 'should insert sidenotes before the ancestor of its ref mark that is a direct child of the post container', ->
      placementBeforeTest()
      plugin 'destroy'

    it 'should hide the footnotes', ->
      expect(footnotesAreHidden()).to.be.true
      plugin 'destroy'

    it 'should correctly deal with nested footnotes', ->
      expect($sidenote(8).prev().is($sidenote(7))).to.be.true
      expect($sidenote(8).parent().is($group(2))).to.be.true

    it 'should be able to be destroyed', ->
      plugin 'destroy'

      expect($sidenotes()).to.have.length 0
      expect($groups()).to.have.length 0

      expect(footnotesAreHidden()).to.be.false

    afterEach ->
      teardown()

describe 'API:', ->

  describe '#hide', ->

    beforeEach ->
      setup()
      plugin()
      plugin 'hide'

    it 'should hide the sidenotes', ->
      expect(sidenotesAreHidden()).to.be.true

    it 'should show the footnotes', ->
      expect(footnotesAreHidden()).to.be.false

    afterEach ->
      plugin 'destroy'
      teardown()

  describe '#show', ->

    beforeEach ->
      setup()
      plugin()
      plugin 'show'

    it 'should show the sidenotes', ->
      expect(sidenotesAreHidden()).to.be.false

    it 'should hide the footnotes', ->
      expect(footnotesAreHidden()).to.be.true

    afterEach ->
      plugin 'destroy'
      teardown()

  describe '#sidenotePlacement', ->

    beforeEach ->
      setup()
      plugin()

    describe "'after'", ->
      it "'after' should place the sidenotes after their reference in the text", ->
        plugin 'sidenotePlacement', 'after'
        placementAfterTest()

    describe "'before'", ->
      it "'before' should place the sidenotes before their reference in the text", ->
        plugin 'sidenotePlacement', 'before'
        placementBeforeTest()

    afterEach ->
      plugin 'destroy'
      teardown()

  describe "#placement", ->

    beforeEach ->
      setup()
      plugin()
      
    describe "'after'", ->
      it "'after' should be an alias for sidenotePlacement 'after'", ->
        plugin 'placement', 'after'
        placementAfterTest()

    describe "'before'", ->
      it "'before' should be an alias for sidenotePlacement 'after'", ->
        plugin 'placement', 'before'
        placementBeforeTest()

    afterEach ->
      plugin 'destroy'
      teardown()

describe "Options:", ->
  beforeEach ->
    setup()

  describe "'initiallyHidden'", ->
    it "should keep the sidenotes hidden initially if true", ->
      plugin initiallyHidden: true
      expect(sidenotesAreHidden()).to.be.true

  describe "'sidenotePlacement':", ->

    it "'after' should initially place sidenotes after their reference in the text", ->
      plugin sidenotePlacement: 'after'
      placementAfterTest()

    it "'before' should initially place sidenotes before their reference in the text", ->
      plugin sidenotePlacement: 'before'
      placementBeforeTest()

  describe "'placement':", ->

    it "'after' should be an alias for 'sidenotePlacement': after", ->
      plugin placement: 'after'
      placementAfterTest()

    it "'before' should be an alias for 'sidenotePlacement': before", ->
      plugin placement: 'before'
      placementBeforeTest()

  describe "'removeRefMarkRegex'", ->

    it "should create reference-less sidenotes for matching footnote ids", ->
      plugin removeRefMarkRegex: /-sn$/
      expect($('.ref-mark', $sidenote(4))).to.have.length 0

  describe "'sidenoteElement'", ->

    it "should determine the element type of the sidenotes", ->
      plugin sidenoteElement: 'div'
      expect($sidenote(1).is('div')).to.be.true

  describe "'sidenoteGroupElement'", ->

    it "should determine the element type of the sidenote groups", ->
      plugin sidenoteGroupElement: 'aside'
      expect($group(1).is('aside')).to.be.true

  describe "'sidenoteClass'", ->

    it "should determine the class added to each sidenote", ->
      plugin sidenoteClass: 'sidenote foo'
      expect($sidenote(1).hasClass('foo')).to.be.true

  describe "'sidenoteGroupClass'", ->

    it "should determine the class added to each sidenote group", ->
      plugin sidenoteGroupClass: 'sidenote-group bar'
      expect($group(1).hasClass('bar')).to.be.true

  describe "'refMarkClass'", ->

    it "should determine the class added to each sidenote's reference mark", ->
      plugin refMarkClass: 'ref-mark baz'
      expect($('.ref-mark').eq(0).hasClass('baz')).to.be.true

  describe "'footnoteContainerSelector'", ->

    it "should determine the selector used to find the footnote container", ->
      $footnoteContainer().removeClass('.footnotes')
      plugin footnoteContainerSelector: '.footnote-container'
      expect($sidenotes()).to.have.length 8

  describe "'footnoteSelector'", ->

    it "should determine the selector used to find the footnotes, relative to the footnote container", ->
      plugin footnoteSelector: '.footnote-list li'
      expect($sidenotes()).to.have.length 8

  afterEach ->
    plugin 'destroy'
    teardown()

describe "Edge cases:", ->

  it 'should choose correct element as post container', ->
    setup()
    $('.post-wrapper').sidenotes()
    placementBeforeTest()
    $('.post-wrapper').sidenotes('destroy')