fs        = require 'fs'
chai      = require 'chai'
jsdom     = require 'jsdom'
jQuery    = require 'jQuery'

should    = chai.should()

window    = jsdom.jsdom().createWindow()
document  = window.document

$ = global.jQuery = jQuery.create(window)

require '../lib/jquery.sidenotes.js'

testHtml = fs.readFileSync 'test/test.html', 'utf8'

setup = -> $('body').html testHtml
teardown = -> $('body').html ''

constructor = (args...) -> $('.post').sidenotes(args)

footnote = (n) -> $('.footnote').eq(n-1)
sidenote = (n) -> $('.sidenote').eq(n-1)
group = (n) -> $('.sidenote-group').eq(n-1)
pivot = (n) -> $(".pivot-#{n}").eq(0)

describe 'Plugin initialization', ->

  describe 'Default constructor', ->

    setup()
    constructor()

    it 'should create the same number of sidenotes as footnotes', ->
      $('.sidenote').should.have.length 7

    it 'should group sidenotes that would otherwise be inserted adjacently', ->
      sidenote(2).parent().is(group(1)).should.be.true
      sidenote(3).parent().is(group(1)).should.be.true
      sidenote(5).parent().is(group(2)).should.be.true
      sidenote(6).parent().is(group(2)).should.be.true
      sidenote(7).parent().is(group(2)).should.be.true

    it 'should insert sidenotes before the ancestor of its ref mark that is a direct child of the post container', ->
      pivot(1).prev().is(sidenote(1)).should.be.true
      pivot(2).prev().is(group(1)).should.be.true
      pivot(3).prev().is(sidenote(4)).should.be.true
      pivot(4).prev().is(group(2)).should.be.true
