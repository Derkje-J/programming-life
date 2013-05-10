# Simulates transporters in the cell.
#
# Parameters
# ------------------ ------------------ ------------------
# k
#	Synthesize rate
# k_m
#	For active transporters
# k_tr
#	The transport rate
# consume
#	All the metabolites required for Transporter creation
# type
#	Model.Transporter.Active or Model.Transporter.Passive
# 
# Properties
# ------------------ ------------------ ------------------
# vTransporterProd
#	k * this * consume
# dillution
#	mu * this
# vTransport [active transporter]
#	k_tr * this * ( transported_compound / ( transported_compound + k_m ) ) * cell
# vTransport [passive transporter]
#	k_tr * this * transported_compound * cell
#
# Equations
# ------------------ ------------------ ------------------
# this / dt
#	vTransporterProd - dillution
# consume / dt
#	- vTransporterProd
# orig / dt
#	- vTransport
# dest / dt
#	vTransport
#
class Model.Transporter extends Model.Module

	# Active Transporters actively move metabolites
	@Active:	1
	
	# Passive Transporters passily diffuse metabolites
	@Passive: 0
	
	# Inward transporters transport stuff into the cell
	@Inward: 1
	
	# Outward transporters transport stuff out of the cell
	@Outward: -1

	# Constructor for transporters
	#
	# @param params [Object] parameters for this module
	# @param transported [String] the metabolite to be transported
	# @param start [Integer] the initial value of transporters, defaults to 1
	# @param name [String] the name of the transport, defaults to "transporter_transported'"
	# @param consume [String, Array<String>] the metabolite to consume, defauls to "s"
	# @param direction [Integer] the direction of the transporter, defaults to Inward
	# @param type [Integer] the type of the transporter, defauts to Active
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [Integer] k_tr the transportation rate, defaults to 1
	# @option params [Integer] v the speed scaler (vmax), defaults to 1
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [String] transported the metabolite to be transported, overrides transported
	# @option params [String] name the name of the transporter, overrides name
	# @option params [String, Array<String>] consume the metabolite to be consumed, overides consume
	# @option params [Integer] direction the direction of the transporter
	# @option params [Integer] type the type of the transporter
	#
	constructor: ( params = {}, start = 1, transported, name, direction = Model.Transporter.Inward , type = Model.Transporter.Active, consume = "s#int" ) ->

		# Define differential equations here
		step = ( t, compounds, mu ) ->
		
			results = {}	
		
			# Only if the components are available [production]
			if ( @_test( compounds, @name, @dna, @consume ) )
			
				# Rate of synthesization 
				# - The DNA constant k_dna called k
				# - The DNA itself
				# - The required metabolites 
				#
				vtransporterprod = @k * compounds[ @dna ]
				for c in @consume
					vtransporterprod *= compounds[ c ]
					
				# Rate of dillution because of cell division
				# 
				dillution = mu * compounds[ @name ]
			
			# Only if the components are available [transport]
			
			[ orig, dest ] = @getTransportedNames( @transported )
			
			if ( @_test( compounds, @name, orig, dest, @cell ) and @_ensure( @validate_type, 'No valid type for transporter' ) and @_ensure( @validate_direction, 'No valid direction for transporter' ) )
										
				if @type is Model.Transporter.Active
					
					# Rate of ACTIVE Transporter 
					# - The Transport constant k_tr 
					# - The Transporter itself
					# - The Compound to transport
					# - The Mihaelis-Mentin kinetics with constant k_m
					#
					vtransport = @k_tr * compounds[ @name ] * ( compounds[ orig ] / ( compounds[ orig ] + @k_m ) )
					
				else if @type is Model.Transporter.Passive
				
					# Rate of PASSIVE Transporter 
					# - The Transport constant k_tr 
					# - The Transporter itself
					# - The Compound to transport
					# - The Diffussion kinetics
					#
					vtransport = @k_tr * compounds[ @name ] * compounds[ orig ]
					
				# The actual amount transported is influenced by the cell growth
				vtransport *= compounds[ @cell ]

				
			# If all components are available [production]
			if vtransporterprod?
			
				# The Transporter increase is the rate minus dillution
				#
				results[ @name ] = vtransporterprod - dillution
				
				# All the metabolites required for synthesisation
				# are hereby subtracted by the increase in Transporter
				#
				for c in @consume
					results[ c ] = -vtransporterprod	
			
			# If all components are available
			if vtransport?
				
				results[ @orig ] = -vtransport
				results[ @dest ] = vtransport
				
			return results
		
		# Default parameters set here
		defaults = { 
		
			# Parameters
			k: 1
			k_tr: 1
			k_m : 1
			transported: transported
			consume: if _( consume ).isArray() then consume else [ consume ]
			
			# Meta-Parameters
			direction: direction
			type: type
			cell: "cell"
			dna: "dna"
			
			# The start values
			starts: { name : start, dest : 0 }
			
			# The name
			name : name ? "transporter_#{transported}"
		}
				
		Object.defineProperty( @ , "orig",
			get: ->	return @getTransportedNames( @transported )[0]
			configurable: false
			enumerable: false
		)
		
		Object.defineProperty( @ , "dest",
			get: ->	return @getTransportedNames( @transported )[1]
			configurable: false
			enumerable: false
		)
				
		params = _( params ).defaults( defaults )
		super params, step
		
	
	#
	#
	validate_type: () -> 
		return ( @type is Model.Transporter.Active or @type is Model.Transporter.Passive )
	
	#
	#
	validate_direction: () ->
		return ( @direction is Model.Transporter.Inward or @direction is Model.Transporter.Outward )
	
	#
	#
	getTransportedNames: ( transported ) ->
		result = [ "#{transported}#int", "#{transported}#ext" ]
		
		return result.reverse() if @direction is Model.Transporter.Inward
		return result 
		
	# Generator for transporter to internal cell
	#
	# @param params [Object] parameters for this module
	# @param transported [String] the metabolite to be transported, defaults to "s"
	# @param start [Integer] the initial value of transporters, defaults to 1
	# @param type [Integer] the type of the transporter
	# @param consume [String, Array<String>] the metabolite to be consumed
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [Integer] k_tr the transportation rate, defaults to 1
	# @option params [Integer] k_m the mm constant, defaults to 1
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [String] transported the metabolite to be transported, overrides transported
	# @option params [String] name the name of the transporter, defaults to "transported_'substrate'_in"
	# @option params [String, Array<String>] consume the metabolite to be consumed, overides consume
	# @option params [Integer] direction the direction of the transporter
	# @option params [Integer] type the type of the transporter
	#
	@int : ( params = { }, start = 1, transported = "s", type = Model.Transporter.Active, consume = "s#int" ) ->
		return new Model.Transporter( params, start, "#{transported}", "transporter_#{transported}_in", Model.Transporter.Inward, type, consume )
	
	# Generator for transporter from internal cell
	#
	# @param params [Object] parameters for this module
	# @param transported [String] the metabolite to be transported, defaults to "p"
	# @param start [Integer] the initial value of transporters, defaults to 0
	# @param type [Integer] the type of the transporter
	# @param consume [String, Array<String>] the metabolite to be consumed
	# @option params [Integer] k the subscription rate, defaults to 1
	# @option params [Integer] k_tr the transportation rate, defaults to 0
	# @option params [Integer] k_m the mm constant, defaults to 0
	# @option params [String] dna the dna to use, defaults to "dna"
	# @option params [String] transported the metabolite to be transported, overrides transported
	# @option params [String] name the name of the transporter, defaults to "transporter_'substrate'_out"
	# @option params [String, Array<String>] consume the metabolite to be consumed, overides consume
	# @option params [Integer] direction the direction of the transporter
	# @option params [Integer] type the type of the transporter
	#
	@ext : ( params = { k_m: 0 }, start = 0, transported = "p", type = Model.Transporter.Passive, consume = "s#int" ) ->
		return new Model.Transporter( params, start, "#{transported}", "transporter_#{transported}_out", Model.Transporter.Outward, type, consume )
		
(exports ? this).Model.Transporter = Model.Transporter