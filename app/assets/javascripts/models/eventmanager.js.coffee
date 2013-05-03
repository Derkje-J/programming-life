# This is the model of a cell. It holds modules and substrates and is capable
# of simulating the modules for a timespan. A cell comes with one default 
# module which is the Cell Growth.
#
class Model.EventManager
	
	# Gets the singleton instance
	#
	# @return [Model.EventManager] singleton instance
	#
	@getSingleton : () ->
		( 
			() -> 
				singleton = singleton ? new EventManager()
				return singleton
		)()
		
	# Creates a new Event Manager
	#
	constructor : () ->
		@_events = {}
	
	# Triggers an event
	#
	# @param event [String] event name
	# @param caller [Object] caller context (this)
	# @param args [Array<any>] arguments to pass
	# @return [self] chaining self
	#
	trigger : ( event, caller, args ) ->
		if @_events[ event ]?
			trigger = ( element, index, list ) ->
				element.apply( caller, args )
			_( @_events[ event ] ).each trigger
		return this
		
	# Binds an event (alias for bind)
	#
	# @param event [String] event name
	# @param func [Function] the event
	# @return [self] chaining self
	#
	on : ( event, func ) ->
		return @bind event, func
		
	# Unbinds an event (alias for unbind)
	#
	# @param event [String] event name
	# @param func [Function] the event
	# @return [self] chaining self
	#
	off : ( event, func ) ->
		return @unbind event, func
		
	# Binds an event
	#
	# @param event [String] event name
	# @param func [Function] the event
	# @return [self] chaining self
	#
	bind : ( event, func ) ->
		unless @_events[ event ]?
			@_events[ event ] = []
		@_events[ event ].push func
		return this
		
	# Unbinds an event
	#
	# @param event [String] event name
	# @param func [Function] the event
	# @return [self] chaining self
	#
	unbind : ( event, func ) ->
		if @_events[ event ]?
			@_events[ event ] = _( @_events[ event ] ).without func
		return this
	
	# Bindings for an event
	#
	# @param event [String] event name
	# @return [Array<Function>] the bindings
	#
	bindings : ( event ) ->
		return @_events[ event ] ? []

(exports ? this).Model.EventManager = Model.EventManager.getSingleton()
