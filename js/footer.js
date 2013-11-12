(function() {
  $(function() {
    var $postContainer, config;
    config = {
      breakpoints: {
        medium: 600,
        large: 1000
      }
    };
    $postContainer = $('.page__content');
    $postContainer.sidenotes({
      removeRefMarkRegex: /-sn$/,
      initiallyHidden: Response.band(0, config.breakpoints.medium),
      sidenotePlacement: Response.band(0, config.breakpoints.large) ? 'after' : 'before'
    });
    Response.create({
      prop: 'width',
      breakpoints: [0, config.breakpoints.medium, config.breakpoints.large]
    });
    Response.crossover(function() {
      console.log(Response.deviceW());
      switch (false) {
        case !Response.band(0, config.breakpoints.medium):
          $postContainer.sidenotes('hide');
          return console.log('Small');
        case !Response.band(config.breakpoints.medium, config.breakpoints.large):
          $postContainer.sidenotes('show');
          $postContainer.sidenotes('sidenotePlacement', 'after');
          return console.log('Medium');
        default:
          $postContainer.sidenotes('show');
          $postContainer.sidenotes('sidenotePlacement', 'before');
          return console.log('Large');
      }
    }, 'width');
    Mousetrap.bind('h', function() {
      return $postContainer.sidenotes('hide');
    });
    Mousetrap.bind('s', function() {
      return $postContainer.sidenotes('show');
    });
    Mousetrap.bind('b', function() {
      return $postContainer.sidenotes('sidenotePlacement', 'before');
    });
    return Mousetrap.bind('a', function() {
      return $postContainer.sidenotes('sidenotePlacement', 'after');
    });
  });

}).call(this);
