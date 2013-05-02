class View.Main

	# Creates a new Main view
	#
	constructor: ( ) ->
		@_views = []		
		@_drawn = []

		@paper = Raphael('paper', 0, 0)
		@resize()
		
		$(window).on('resize', @resize)
		$(document).on('moduleInit', @moduleInit)

		@draw()

	# Resizes the cell to the window size
	#
	resize: ( ) =>
		@width = $(window).width() - 20
		@height = $(window).height() - 5 


		@paper.setSize(@width, @height)

		@draw()

	actions: ( number ) ->
		() => (
			switch number
				when 0
					@cell = new Model.Cell()
				when 1
					@cell.add( new Model.DNA() )
						.add( new Model.Lipid({}, .1) )
				when 2
					@cell.add_substrate( "s_ext", 1, false, false )
				when 3
					@cell.add( new Model.Transporter.int( {}, .1 ) )
						.add_substrate( "s_int", 0, true, false )
				when 4
					@cell.add( new Model.Protein({}) )
				when 5
					@cell.add( new Model.Transporter.ext() )
						.add_substrate( "p_ext", 0, false, true )
				when 6
					@cell.add( new Model.Metabolism({}) )
						.add_substrate( "p_int", 0, true, true )
				when 7
					container = $(".container")
					container.empty()
					@cell.visualize( 20, container, { dt: .5 } )
			@drawpane()
			)
	
	# Cowboy hacking a pane
	#
	drawpane: ( ) ->
		location = {
			x: @width * 0.75
			y: @height * 0.25
		}
		@pane = @paper.rect(location.x, location.y, 250, 400, 10)
		@pane.node.setAttribute('class', 'box')
		texts = ["Create initial cell","Add Infrastructure (DNA/Lipid)", "Add substrate outside cell", "Add transporter in", "Add Protein", "Add transporter out", "Add Metabolism", "Run" ]

		for i in [1 .. texts.length]
			rect = @paper.rect( location.x + 10 , location.y - 30 + 40 * i, 230, 30, 5 )
			rect.attr({
				'class': 'box'
				'fill': '#00eeeb'
			})

			text = @paper.text( location.x + 120, location.y - 15 + 40 * i, texts[i-1] )
			text.attr({'font-size': 15})

			if (i > 1 and (@cell is undefined))
				rect.attr({
					'fill' : 'grey'
				})
			else
				rect.click(@actions(i - 1))
				text.click(@actions(i - 1))

		
	# Draws the cell
	#
	draw: ( ) ->
		@drawpane()
		# First, determine the center and radius of our cell
		centerX = @width / 2
		centerY = @height / 2
		radius = Math.min(@width, @height) / 2 * .7

		radius = 400 if radius > 400
		radius = 200 if radius < 200
		
		scale = radius / 400

		unless @_shape
			@_shape = @paper.circle(@x, @y, @radius)
			@_shape.node.setAttribute('class', 'cell')

		else
			@_shape.attr
				cx: centerX
				cy: centerY
				r: radius
				
		inTransporters = 0
		outTransporters = 0
		counters = {}
		
		# Draw each module
		for view in @_views
		
			type = view.module.constructor.name
			direction = view.module.direction ? view.module.placement ? 0
			counter = counters[ "#{type}_#{direction}" ] ? 0
			
			# Send all the parameters through so the location
			# method becomes functional. Easier to test and debug.
			params = { 
				count: counter
				view: view
				type: type 
				placement: direction
				cx: centerX
				cy: centerY
				r: radius
				scale: scale
			}
			placement = @getLocationForModule( view.module, params )

			counters[ "#{type}_#{direction}" ] = ++counter
			view.draw( placement.x, placement.y, scale) 

	# On module initialization add it to the cell
	# 
	# @param event [Object] event raised
	# @param module [Model.Module] module added
	#
	moduleInit: ( event, module ) =>
		unless _(@_drawn).indexOf( module.name ) isnt -1
			@_drawn.push module.name
			view = new View.Module(module)
			@_views.push(view)
			@draw()

	# Returns the location for a module
	#
	# @param module [Model.Module] the module to get the location for
	# @returns [Object] the size as an object with x, y
	#
	getLocationForModule: ( module, params ) ->
		x = 0
		y = 0
		
		switch params.type
		
			when "CellGrowth"
				alpha = 3 * Math.PI / 4 + ( params.count * Math.PI / 12 )
				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )
			
			when "Lipid"
				alpha = -3 * Math.PI / 4 + ( params.count * Math.PI / 12 )
				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )

			when "Transporter"
				dx = 50 * params.count * params.scale
				
				if params.placement is 1					
					alpha = Math.PI - Math.asin( dx / params.r )
				else				
					alpha = 0 + Math.asin( dx / params.r )

				x = params.cx + params.r * Math.cos( alpha )
				y = params.cy + params.r * Math.sin( alpha )

			when "DNA"
				x = params.cx + ( params.count % 3 * 40 )
				y = params.cy - params.r / 2 + ( Math.round( params.count / 3 ) * 40 )

			when "Metabolism"
				x = params.cx + ( params.count % 3 * 40 )
				y = params.cy + params.r / 2 + ( Math.round( params.count / 3 ) * 40 )

			when "Protein"
				x = params.cx + params.r / 2 + ( params.count % 3 * 40 )
				y = params.cy - params.r / 2 + ( Math.round( params.count / 3 ) * 40 )
				
			when "Substrate"
				x = ( params.cx + params.placement * 200 )
				x = ( params.cx - params.r - 130 ) if params.placement is -1
				x = ( params.cx + params.r + 130 ) if params.placement is 1 
				y = params.cy + ( Math.round( params.count ) * 100 * params.scale )
				
		return { x: x, y: y }


(exports ? this).View.Main = View.Main
