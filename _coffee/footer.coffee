hljs.initHighlightingOnLoad()

$ ->
  config =
    breakpoints:
      medium:                 600
      large:                  1000

  $postContainer = $('.page__content')

  $postContainer.sidenotes
    removeRefMarkRegex:       /-sn$/
    initiallyHidden:          Response.band 0, config.breakpoints.medium
    sidenotePlacement:        if Response.band 0, config.breakpoints.large then 'after' else 'before'


  Response.create
    prop:                     'width'
    breakpoints:              [0, config.breakpoints.medium, config.breakpoints.large]

  Response.crossover ->
    console.log Response.deviceW()
    switch
      # Small
      when Response.band 0, config.breakpoints.medium
        $postContainer.sidenotes('hide')
        console.log 'Small'
      # Medium
      when Response.band config.breakpoints.medium, config.breakpoints.large
        $postContainer.sidenotes('show')
        $postContainer.sidenotes('sidenotePlacement', 'after')
        console.log 'Medium'
      # Large
      else
        $postContainer.sidenotes('show')
        $postContainer.sidenotes('sidenotePlacement', 'before')
        console.log 'Large'
  , 'width'

  Mousetrap.bind 'h', -> $postContainer.sidenotes('hide')
  Mousetrap.bind 's', -> $postContainer.sidenotes('show')
  Mousetrap.bind 'b', -> $postContainer.sidenotes('sidenotePlacement', 'before')
  Mousetrap.bind 'a', -> $postContainer.sidenotes('sidenotePlacement', 'after')
