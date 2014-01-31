$ 	 = jQuery
root = this
page = $ window

root.howl or= {}

$.fn.extend
	wolfe: ( opts ) ->

		# Default settings
		defaults =

			element 			: 'slide'
			notes				: false
			height				: -> page.height()
			width				: -> page.width()
			wrapper 			: 'wrapper'
			speed 				: 1000
			onLoad 				: ->
			onComplete 			: -> 

		set = $.extend defaults, opts

		# Simple logger.
		notes__ = ( note ) ->
			console?.log '====', note, '====' if set.notes

		# _Insert magic here._
		return @each () ->

			notes__ 'INIT', set.height, set.width

			itemDistance = 0

			howl.events  =
				loaded : false

			howl.isNumeric = ( n ) ->

 				return !isNaN( parseFloat( n ) ) and isFinite( n )

 			howl.debounce = ( fn, delay ) ->

 				# THANKS @REMY SHARP
 				delay or= 100
 				time 	= null

 				return ->

 					context 	= this
 					parameters	= arguments
 					start 		= -> fn.apply( context, parameters ) 

 					clearTimeout( timer )
 					timer = setTimeout( start, delay )

			howl.countItems = ->

				self 	= this
				items  	= $( ".#{set.element}" )
				count 	= items.length

				return count - 1

			howl.processItem = ( index, item ) ->

				# SET THE POSITION
				#-----------------

				if index is 0
					item.attr 'data-position', 0
					item.addClass 'in-viewport'
					item.attr 'id', 'item-first'

				if index >= 1
					itemDistance += set.height()
					item.attr 'data-position', itemDistance

				if index is howl.countItems()
					item.attr 'id', 'item-last'

				item.attr 'data-number', index

			howl.processItems = ->

				self 	 = this
				items  	 = $( ".#{set.element}" )
				_height  = set.height()
				_width 	 = set.width()

				notes__ items

				items.each ( index, item ) =>

					notes__ item

					item = $( item )

					# SET WIDTH AND HEIGHT
					#---------------------

					item
					.width( _width )
					.height( _height )

					howl.processItem( index, item )

			howl.setState= ->

				notes__ 'SET WRAP STATE'

				wrapp = $( ".#{set.wrapper}" )
				wrapp.attr 'data-animate', 'off'

			howl.wrapItems = ( callNext ) ->

				notes__ 'WRAP ITEMS'

				items = $( ".#{set.element}" )
				items.wrapAll "<div class='#{set.wrapper}'><div class='#{set.wrapper}-inner'></div></div>"

				callNext()

			howl.moveTo = ( location ) ->

				outer 	= $( ".#{set.wrapper}" )
				inner   = $( ".#{set.wrapper}-inner" )
				item    = $( ".#{set.element}" )
				current = outer.find ".#{set.element}.in-viewport"
				next 	= current.next()
				prev 	= current.prev()

				setEndState = ( complete ) ->

					# --> CLEAR TIMEOUT
					clearTimeout( ID )

					# --> GET CURRENT ELEMENT & TRACK
					inumber = $( ".#{set.element}.in-viewport" ).attr 'data-number'
					notes__ 'TRACK DOTS ' + inumber

					howl.trackDots( inumber )

					fn = ->
						complete.apply( this )
						outer.attr 'data-animate', 'off'

					# --> SETUP THE CALLBACK
					ID = window.setTimeout( fn, set.speed )		

				locations =
					next : ->

						notes__ 'NEXT LOCATION'

						if current.index() isnt howl.countItems()

							if outer.attr( 'data-animate' ) is 'off'

								outer.attr 'data-animate', 'on'

								inner.css 'transform', "translate3d( 0, -#{next.attr( 'data-position' )}px, 0 )"
								current.removeClass 'in-viewport'
								next.addClass 'in-viewport'

								setEndState( set.onComplete )

					prev : ->

						notes__ 'PREV LOCATION'

						if current.index() isnt 0

							if outer.attr( 'data-animate' ) is 'off'

								outer.attr 'data-animate', 'on'

								inner.css 'transform', "translate3d( 0, -#{prev.attr( 'data-position' )}px, 0 )"
								current.removeClass 'in-viewport'
								prev.addClass 'in-viewport'

								setEndState( set.onComplete )

					longHaul : ( index ) ->

						if outer.attr( 'data-animate' ) is 'off'

							fetch = item.eq( index )

							outer.attr 'data-animate', 'on'

							inner.css 'transform', "translate3d( 0, -#{fetch.attr( 'data-position' )}px, 0 )"
							current.removeClass 'in-viewport'
							fetch.addClass 'in-viewport'

							setEndState( set.onComplete )


				if location is 'next' then locations[ 'next' ]()
				if location is 'prev' then locations[ 'prev' ]()
				if howl.isNumeric( location ) then locations[ 'longHaul' ]( location )

			howl.scrollItems = ->

				self  = this
				body  = $( 'body' )
				wrapp = ".#{set.wrapper}"

				body.on 'DOMMouseScroll mousewheel', wrapp, ( e ) ->

					delta = e.originalEvent.wheelDelta / 120
					_this = $( this )

					notes__ delta

					if delta > 0

						notes__ 'SCROLL UP'
						howl.moveTo 'prev'

					if delta < 0

						notes__ 'SCROLL DOWN'
						howl.moveTo 'next'

			howl.createDots = ->

				self   	= this
				amount 	= howl.countItems()
				body 	= $( 'body' )
				dots 	= []

				# START
				dots.push '<div class="dots">'

				for i in [ 0..amount ] by 1

					dots.push "<span class='dot' data-match='#{i}'></span>"

				# END
				dots.push '</div>'

				body.prepend( dots.join( '' ) )

				$( 'div.dots' ).css 'margin-top', -( $( 'div.dots' ).height() / 2 )

				notes__ dots

			howl.trackDots = ( index ) ->

				self   	= this
				body 	= $( 'body' )
				dots 	= body.find '.dots'
				dot 	= dots.find '.dot'
				select  = index

				dot.removeClass 'is-selected'
				$( "*[data-match='#{select}']").addClass 'is-selected'

			howl.navDots = ->

				self   	= this
				body 	= $( 'body' )
				dots 	= body.find '.dots'
				dot 	= dots.find '.dot'

				dot.on 'click', ( e ) ->

					id = $( this ).data 'match'

					howl.moveTo( id )

			howl.onResize = ->

				notes__ 'WINDOW RESIZED'

				fn = ->
					# -- > RESET THE DISTANCE
					itemDistance = 0
					current 	 = $( ".#{set.element}" ).find '.in-viewport'
					currentId 	 = current.attr 'data-number'

					howl.moveTo( currentId )
					howl.processItems()

				debounce = howl.debounce( fn, 500 )

				page.on 'resize', debounce

			howl.commander = ->

				howl.processItems()
				howl.wrapItems( howl.setState )
				howl.scrollItems()
				howl.createDots()

				if howl.events.loaded is false then howl.trackDots( 0 )

				howl.navDots()

				howl.events.loaded = true

			howl.commander()
			howl.onResize()













