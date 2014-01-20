do ($ = jQuery, window, document) ->

  # Add plugin to jQuery prototype
  $.fn.extend sidenotes: (option, args...) ->
    @each ->
      $this = $(this)

      # Attach an instance of SidenotesPlugin to each selected element's jQuery object
      # Check if plugin object already exists
      # Otherwise, create it
      plugin = $this.data('sidenotes') ? $this.data('sidenotes', new SidenotesPlugin(this, option))

      # If first argument is a string, use as method call to plugin object
      if typeof option is 'string'
        plugin[option].apply(plugin, args)

        # If `destroy` method was called, remove plugin object from jQuery object
        $this.removeData('sidenotes') if option is 'destroy'

      # False-y returns in `each` stop iteration
      # Avoid by returning true
      true


  # Plugin class
  # An instance of SidenotesPlugin is created for each element of the jQuery object
  class SidenotesPlugin

    # Configuration settings
    # These can be overridden by passing a object to the constructor
    options:

      # Selector for footnote container
      footnoteContainerSelector:          '.footnotes'

      # Selector for footnotes (relative to footnote container)
      footnoteSelector:                   '> ol > li'

      # If true, sidenotes are hidden at start
      initiallyHidden:                    false

      # If footnote ID matches this regex, the resulting sidenote is numberless
      # Obviously, this only works with Markdown generators that preserve the source's reference names in the footnote ID
      # The default regex will never match
      removeRefMarkRegex:                 /(?!)/

      # Class to add to sidenote's reference mark/number
      refMarkClass:                       'ref-mark'

      # Class to add to sidenotes
      sidenoteClass:                      'sidenote'

      # Class to add to sidenote groups
      sidenoteGroupClass:                 'sidenote-group'

      # Sidenote DOM element type
      sidenoteElement:                    'aside'

      # Sidenote group DOM element type
      sidenoteGroupElement:               'div'

      # Placement of sidenotes before or after reference in text
      # `placement` is aliased to this option
      sidenotePlacement:                  'before'

      # Hide footnote container in addition to footnotes
      hideFootnoteContainer:              true

      # Function to format sidenote elements, given original footnote's HTML and a reference mark
      # Be sure to check for existence: if no reference value is passed, sidenote should not have a reference
      # Must return new sidenote jQuery object
      # It's a good idea to use `sidenoteElement` and `refMarkClass` options
      formatSidenote:                     (footnoteHtml, id, ref) ->
                                            $sidenote = $("<#{@sidenoteElement}/>", class: @sidenoteClass)
                                              .html(footnoteHtml)
                                              .attr('id', id)
                                            if ref?
                                              $sidenote.attr 'data-ref', ref
                                              $sidenote.prepend($('<span/>', class: @refMarkClass).html(ref))
                                            return $sidenote

      formatSidenoteID:                   (footnoteID) ->
                                            footnoteID.replace( /^f/, 's')

      # Function to hide sidenotes/footnotes/groups
      # It may be desirable to override the default behavior,
      # which uses jQuery's `hide` method
      # The recommended use case would be to add a 'hidden' class to the element
      # and style appropriately with CSS
      hide:                               ($el) ->
                                            $el.hide()

      # Function to show sidenotes/footnotes/groups
      # This method should return the DOM to its "resting state"
      # That is, as much as possible, the post's DOM (except for the sidenotes and groups)
      # should look like it did before the plugin was applied
      # In other words, this should reverse the effects of the `hide` method
      show:                               ($el) ->
                                            $el.show()


    constructor: (scope, options) ->
      
      @options = $.extend {}, @options, options

      # 'Placement' should be an alias for 'sidenotePlacement'
      # 'sidenotePlacement' is redundant given the new name of the plugin
      @options.sidenotePlacement = @options.placement or @options.sidenotePlacement 

      # Element that contains the footnotes
      # Only necessary if `hideFootnoteContainer` option is true
      @$footnoteContainer = $(@options.footnoteContainerSelector, scope) if @options.hideFootnoteContainer
      @$footnoteContainer = if @$footnoteContainer.size() isnt 0 then @$footnoteContainer else null

      # Element that contains all the post's content and footnotes
      # Direct parent element of Markdown-generated content
      # There should be only one post per container
      # Other jQuery selectors will be scoped to this object
      @$postContainer = @$footnoteContainer.parent()

      # The given footnote selector is relative to the footnote container, so combine them before passing to jQuery constructor
      @$footnotes = $(@options.footnoteContainerSelector + ' ' + @options.footnoteSelector, @$postContainer)

      # Set initial position of sidenotes
      @sidenotesAfterRef = @options.sidenotePlacement is 'after'

      # Start reference counter at zero
      refCounter = 1

      # Initialize arrays for the sidenotes and sidenote groups
      @sidenotes = []
      @groups = []

      # Create reference to this SidenotesPlugin instance so it can be used inside functions
      plugin = this

      # Iterate through footnote elements
      @$footnotes.each ->
        footnoteEl = this

        # Get footnote ID, to be used to find the note's corresponding reference in the post
        footnoteID = footnoteEl.id

        # Check if ID matches reference-less sidenote regex
        # If so, this sidenote should not have a reference mark
        noRef = plugin.options.removeRefMarkRegex.test(footnoteID)

        # Create new Sidenote object
        # Pass refCounter as reference mark value, then increment
        # Pass plugin as owner
        sidenote = new Sidenote(footnoteEl, (if noRef then null else refCounter++), plugin)
        plugin.sidenotes.push(sidenote)

        # The "pivot" is the element in the DOM before or after which the sidenote element is located
        # If there is more than one sidenote per pivot, they should be grouped in a SidenoteGroup
        previous = plugin.sidenotes[plugin.sidenotes.length - 2] ? null # Previous sidenote
        if previous?.$pivot.is(sidenote.$pivot)

          # The previous sidenote's pivot is the same as this sidenote's pivot
          # Check if the previous sidenote is already in a group
          if previous.hasGroup()

            # Group already exists
            # Add this sidenote to it
            previous.group.push(sidenote)
          else

            # Need to create new group
            # Pass plugin as owner
            group = new SidenoteGroup([previous, sidenote], plugin)

            # Add new group to the groups array
            plugin.groups.push(group)
      
      # Show the sidenotes, unless configuration says to keep them hidden initially
      # Pass `true` as the `show` method's force parameter, since elements have not yet been added to DOM
      @isHidden = @options.initiallyHidden
      if @isHidden then @hide(true) else @show(true)

    # Show the sidenotes and sidenote groups
    # If `force` is true, method body is run even if `isHidden` is false
    # A true `force` value will also place elements into DOM (if necessary)
    show: (force) ->
      if @isHidden or force

        # Show sidenotes
        for sidenote in @sidenotes    

          # Add to DOM only when force is true
          sidenote.$pivot[@sidenotePlacement()](sidenote.$sidenote) if (force and not sidenote.hasGroup())

          sidenote.show()

        # Show groups
        for group in @groups

          # Add to DOM only when force is true
          group.$pivot[@sidenotePlacement()](group.$group) if force

          group.show()

        # Hide footnote container (unless configuration says not to)
        @options.hide(@$footnoteContainer) if @$footnoteContainer? and @options.hideFootnoteContainer

        # Update object property
        @isHidden = false

    # Hide the sidenotes and sidenote groups
    # If `force` is true, method body will run even if `isHidden` is true
    hide: (force) ->
      if not @isHidden or force

        # Hide sidenotes
        for sidenote in @sidenotes

          # Add to DOM only when force is true
          sidenote.$pivot[@sidenotePlacement()](sidenote.$sidenote) if (force and not sidenote.hasGroup())

          sidenote.hide()

        # Hide groups
        for group in @groups

          # Add to DOM only when force is true
          group.$pivot[@sidenotePlacement()](group.$group) if force

          group.hide()

        # Show footnote container
        @options.show(@$footnoteContainer) if @$footnoteContainer?

        # Update object property
        @isHidden = true

    # The getter form of this method (no arguments) returns the current sidenote placement ('before' or 'after') relative to their pivots
    # The setter form sets the sidenote placement
    # If `force` is true, method body will run even if passed value is equal to current sidenote placement
    sidenotePlacement: (placement, force) ->
      if placement in ['before', 'after'] and (placement isnt @sidenotePlacement() or force)

        # Place sidenotes
        for sidenote in @sidenotes
          sidenote.$pivot[placement](sidenote.$sidenote) if not sidenote.hasGroup()

        # Place groups
        for group in @groups
          group.$pivot[placement](group.$group)

        # Update object property
        @sidenotesAfterRef = placement is 'after'

      else

        # Return current placement
        if @sidenotesAfterRef then 'after' else 'before'

    # Alias
    placement: (placement, force) -> @sidenotePlacement(placement, force)

    # Destroy the plugin by restoring the DOM to its original state
    destroy: ->

      # Hide then remove the sidenotes and groups from the DOM
      # Calling the `hide` method before removing the elements ensures that footnotes and references are restored to their original state
      @hide()

      # Remove the sidenote elements from the DOM
      for sidenote in @sidenotes
        sidenote.$sidenote.remove()

      # Remove the group element from the DOM
      for group in @groups
        group.$group.remove()


  # Sidenote class
  # Each footnote has a corresponding Sidenote instance
  # The `owner` parameter refers to the SidenotesPlugin instance that created it
  class Sidenote
    constructor: (footnoteEl, ref, owner) ->
      
      # Corresponding footnote object
      @$footnote = $(footnoteEl)

      # Plugin object
      @owner = owner

      # Save footnote ID
      # Use footnote ID to create sidenote ID
      @footnoteID = footnoteEl.id
      @sidenoteID = @owner.options.formatSidenoteID(@footnoteID)

      # If `ref` parameter is a number greater than 0, it is considered valid
      # Otherwise, this sidenote should be reference-less
      @ref = if ref > 0 then ref else null

      # Use footnote ID to select reference mark anchor (the link to the footnote in the text)
      # Note that this is an anchor element, but most generators wrap it in a superscript element
      # The superscript (if it exists) is the element that the footnote/sidenote actually points to, not the anchor
      @$refMarkAnchor = $("a[href='##{escapeExpression(@footnoteID)}']", @owner.$postContainer)

      # Find superscript element, if it exists
      @$refMarkSup = @$refMarkAnchor.parent('sup')
      @$refMarkSup = if @$refMarkSup.size() isnt 0 then @$refMarkSup else null

      # Check if footnote is nested (references another footnote)
      # If so, find the note that it references
      @isNested = $.contains @owner.$footnoteContainer.get(0), @refMark().get(0)
      if @isNested
        
        # Find the footnote that it references
        $referringFootnote = @refMark().closest(@owner.$footnotes)

        # Now get the corresponding sidenote object
        for sidenote in @owner.sidenotes
          if sidenote.$footnote.is($referringFootnote)
            @referringSidenote = sidenote
            break

      # Find the ID of the reference mark
      @refMarkID = @refMark().attr('id')

      # A post's sidenotes may be numbered differently than its footnotes, since we allow the option for reference-less notes
      # When the sidenotes are hidden, we'll need to update the references back to their original value
      # So, we save the value in an object property
      @originalRef = @$refMarkAnchor.html()

      # Use the configuration object to create a jQuery object for the sidenote
      @$sidenote = @owner.options.formatSidenote(@$footnote.html(), @sidenoteID, @ref)

      # The element (usually a paragraph) before or after which the sidenote is inserted in DOM
      # Normally, we choose the ancestor of the reference mark that is a first child of the post container
      # If the footnote is nested, we choose the pivot of the note that it refers to
      @$pivot = unless @isNested then @refMark().parentsUntil(@owner.$postContainer).last() else @referringSidenote.$pivot

      # If this sidenote is part of a group, this property refers to the SidenoteGroup
      # The object owner is responsible for assigning the group, if it has one
      @group = null

      # The "back arrow" at the end of the sidenote that links back to the reference mark
      # We will need hide to this for reference-less sidenotes (because it points to nothing)
      $backArrow = $("a[href='##{escapeExpression(@refMarkID)}']", @$sidenote)

      # If this is a reference-less sidenote, hide its back arrow
      @owner.options.hide($backArrow) if $backArrow? and @noMark()

      # Keep the sidenote hidden until the plugin object shows it
      @owner.options.hide(@$sidenote)
      @isHidden = true


    # Returns true if this sidenote is reference-less
    noMark: -> not @ref?

    # Returns true if this sidenote is part of a group
    hasGroup: -> @group?

    # Show the sidenote and hide its corresponding footnote
    show: (force) ->

      # Only run method body if sidenote isn't already shown, or if `force` parameter is true
      if @isHidden or force

        # Hide the reference mark if this is a reference-less sidenote
        if @noMark()
          @owner.options.hide(@refMark())

        # Otherwise, update the reference mark's value and point the link to the sidenote
        else
          @$refMarkAnchor.html(@ref)
          @$refMarkAnchor.attr('href', "##{@sidenoteID}")

        # Show sidenote element
        @owner.options.show(@$sidenote)

        # Hide corresponding footnote element
        @owner.options.hide(@$footnote)

        # Update object property
        @isHidden = false

    # Hide the sidenote and show its corresponding footnote
    hide: (force) ->

      # Only run method body if sidenote isn't already hidden, or if `force` parameter is true
      if not @isHidden or force

        # Restore original reference mark value and point the link to the footnote
        @$refMarkAnchor.html(@originalRef)
        @$refMarkAnchor.attr('href', "##{@footnoteID}")

        # Show reference mark
        @owner.options.show(@refMark())

        # Hide sidenote element
        @owner.options.hide(@$sidenote)

        # Show corresponding footnote
        @owner.options.show(@$footnote)

        # Update object property
        @isHidden = true


    # If the reference mark anchor is wrapped in a superscript element, that element is returned
    # Otherwise, the anchor element is returned
    # The returned element is the one whose ID matches the href of the sidenote's "back arrow"
    # It is the element that should be shown or hidden when appropriate
    refMark: ->
      @$refMarkSup ? @$refMarkAnchor

  # Sidenote group class
  # Each set of sidenotes that share a pivot assigned to a SidenoteGroup instance
  # The `owner` parameter refers to the SidenotesPlugin instance that created it
  class SidenoteGroup
    constructor: (sidenotes, owner) ->

      # Initialize array for the sidenotes
      @sidenotes = []

      # Plugin object
      @owner = owner

      # Create group element that will be added to DOM
      # Use configuration options to give the element a class
      @$group = $("<#{@owner.options.sidenoteGroupElement}/>", class: @owner.options.sidenoteGroupClass)
      
      # Populate the sidenotes array using passed sidenotes
      @push(sidenotes)

      # We can assume every sidenote in the group has the same pivot
      # Set the group's pivot by inspecting the first sidenote
      @$pivot = @sidenotes[0]?.$pivot

      # Keep the group hidden until the plugin object show it
      @owner.options.hide(@$group)
      @isHidden = true

    # Add a sidenote to the group
    # Input can be an array of sidenotes or a single sidenote
    push: (s) ->

      # If input is a single sidenote, add it to an array
      sidenotes = if s instanceof Array then s else [s]

      # Add new sidenotes to the sidenotes array
      @sidenotes.push(sidenotes...)

      # Add each of the new sidenotes to the group's DOM element
      for sidenote in sidenotes
        @$group.append(sidenote.$sidenote)

        # Update sidenote's `group` property to point to this group
        sidenote.group = this

      # If the sidenote group does not already have a pivot, set it by inspecting the first sidenote
      @$pivot ?= @sidenotes[0].pivot

    # Show the sidenote group
    show: ->

      # Only run method body if the group isn't already shown
      if @isHidden

        # Show the group element
        @owner.options.show(@$group)

        # Update object property
        @isHidden = false

    # Hide the sidenote group
    hide: ->

      # Only run method body if the group isn't already hidden
      unless @isHidden

        # Hide the group element
        @owner.options.hide(@$group)

        # Update object property
        @isHidden = true

  # Function to escape special characters in a string
  # Useful for constructing jQuery selectors
  escapeExpression = (str) -> str.replace(/([#;&,\.\+\*\~':"\!\^$\[\]\(\)=>\|])/g, '\\$1')