fs = require 'fs'
chai = require 'chai'
jsdom = require 'jsdom'
jQuery = require 'jQuery'

expect = chai.expect

window = jsdom.jsdom().createWindow()
document = window.document

$ = global.jQuery = jQuery.create(window)

require '../lib/jquery.sidenotes.js'

testHtml = fs.readFileSync 'test/test.html', 'utf8'

setup = -> $('body').html testHtml
teardown = -> $('body').html ''

$postContainer = -> $('.post')
$sidenotes = -> $('.sidenote')
$footnotes = -> $('> ol > li', $footnoteContainer)
$groups = -> $('.sidenote-group')
$footnoteContainer = -> $('.footnotes')
$pivots = -> $('.pivot')

$footnote = (n) -> $footnotes().eq(n-1)
$sidenote = (n) -> $sidenotes().eq(n-1)
$group = (n) -> $groups().eq(n-1)
$pivot = (n) -> $pivots().eq(n-1)

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

plugin = (args...) -> $postContainer().sidenotes(args...)

describe 'Plugin initialization:', ->

  describe 'Default constructor', ->

    before ->
      setup()
      plugin()

    it 'should create the same number of sidenotes as footnotes', ->
      expect($sidenotes()).to.have.length 7

    it 'should group adjacent sidenotes', ->
      expect($sidenote(2).parent().is($group(1))).to.be.true
      expect($sidenote(3).parent().is($group(1))).to.be.true
      expect($sidenote(5).parent().is($group(2))).to.be.true
      expect($sidenote(6).parent().is($group(2))).to.be.true
      expect($sidenote(7).parent().is($group(2))).to.be.true

    it 'should insert sidenotes before the ancestor of its ref mark that is a direct child of the post container', ->
      expect($pivot(1).prev().is($sidenote(1))).to.be.true
      expect($pivot(2).prev().is($group(1))).to.be.true
      expect($pivot(3).prev().is($sidenote(4))).to.be.true
      expect($pivot(4).prev().is($group(2))).to.be.true

    it 'should hide the footnotes', ->
      expect(footnotesAreHidden()).to.be.true

    it 'should be able to be destroyed', ->
      plugin 'destroy'

      expect($sidenotes()).to.have.length 0
      expect($groups()).to.have.length 0

      expect(footnotesAreHidden()).to.be.false

    after ->
      teardown()

describe 'API:', ->

  describe "'hide'", ->

    before ->
      setup()
      plugin()
      plugin 'hide'

    it 'should hide the sidenotes', ->
      expect(sidenotesAreHidden()).to.be.true

    it 'should show the footnotes', ->
      expect(footnotesAreHidden()).to.be.false

    after ->
      teardown()

  describe "'show'", ->

    before ->
      setup()
      plugin()
      plugin 'show'

    it 'should show the sidenotes', ->
      expect(sidenotesAreHidden()).to.be.false

    it 'should hide the footnotes', ->
      expect(footnotesAreHidden()).to.be.true

    after ->
      teardown()


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

  describe "'sidenotePlacement'", ->

    before ->
      setup()
      plugin()

    it "'after' should place the sidenotes after their reference in the text", ->
      plugin 'sidenotePlacement', 'after'
      placementAfterTest()

    it "'before' should place the sidenotes before their reference in the text", ->
      plugin 'sidenotePlacement', 'before'
      placementBeforeTest()

    after ->
      teardown()

  describe "'placement'", ->

    before ->
      setup()
      plugin()

    it "'after' should be an alias for 'sidenotePlacement' 'after'", ->
      plugin 'placement', 'after'
      placementAfterTest()

    it "'before' should be an alias for 'sidenotePlacement' 'after'", ->
      plugin 'placement', 'before'
      placementBeforeTest()

    after ->
      teardown()