class Model.Lipid extends Model.Module

	# Constructor for lipids
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of lipid, defaults to 1
	# @param food [String] the substrate converted to lipid, defaults to "s_int"
	# @option k [Integer] the subscription rate, defaults to 1
	# @option dna [String] the dna to use, defaults to "dna"
	# @option consume [String] the consume substrate, overides the food parameter, defaults to "s_int"
	# @option name [String] the name, defaults to "lipid"
	#
	constructor: ( params = {}, start = 1, food = "s_int" ) ->
	
		# Step function for lipids
		step = ( t, substrates ) ->
		
			results = {}
			
			# Only calculate vlipid if the components are available
			if ( @_test( substrates, @dna, @consume ) )
				vlipid = @k * substrates[@dna] * substrates[@consume]
			
			if ( vlipid? and vlipid > 0 )
				results[@name] = vlipid # todo mu
				results[@consume] = -vlipid	
			
			return results
		
		# Default parameters set here
		defaults = { 
			k : 1
			dna : 'dna'
			consume: food
			name : "lipid"
		}
		
		params = _( defaults ).extend( params )
		
		starts = {}
		starts[params.name] = start
		super params, step, starts

(exports ? this).Model.Lipid = Model.Lipid