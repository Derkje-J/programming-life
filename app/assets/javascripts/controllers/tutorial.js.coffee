'use strict'
# The controller for the Main action and view
#
class Controller.Tutorial extends Controller.Base

	# Contains all the possible steps for the tutorial. Each Key maps to an Step ID. 
	# This ID is saved in the database, which could be used to store what tutorials parts
	# were actually finished. Show a list. And so forth.
	#
	@Step:	
		Finished: -1
		
		Start: 0
		ResetAfterStart: 0.5
		
		# Inspecting modules
		OverviewHover: 1
		OverviewSelect: 2
		OverviewClose: 3
		OverviewEnd: 4
		
		# Adding Module
		CreateFromDummy: 5
		CreateSave: 6
		CreatedAutomagic: 7
		ModuleDeleted: 8
		
		# Automagic/Previews
		CreatePrecursors: 9
		SwitchTransporterToInward: 9.5
		CreatedPrecursors: 10
		MoreOptions: 11
		CreateFromOptions: 12
		SwitchTransporterToOutward: 12.5
		SwitchPreviews: 13
		SwitchedPreviews: 14
		AddedUneccesary: 15
		
		# Timemachine
		UndoThemPrecursor: 16
		RedoModule: 17
		ChangeAndUndoModule: 18
		ChangedAndUndoModule: 19
		ChangedAndUndoneModule: 20
		BranchModule: 21
		
		# Simulate 
		
		# Save
		
		
	# Groups of tutorial steps
	#
	@Group:
		Start: 		[ 'Start', 'ResetAfterStart' ]
		Finished: 	[ 'Finished' ]
		
		Inspecting:	[ 'OverviewHover', 'OverviewSelect', 'OverviewClose', 'OverviewEnd' ]
		Adding: 	[ 'CreateFromDummy', 'CreateSave', 'CreatedAutomagic', 'ModuleDeleted' ]
		Automagic:	[ 'CreatePrecursors', 'CreatedPrecursors', 'MoreOptions', 'CreateFromOptions', 'SwitchPreviews', 'SwitchedPreviews', 'AddedUneccesary' ]
		TimeMachine:[ 'UndoThemPrecursor',  'RedoModule', 'ChangeAndUndoModule', 'ChangedAndUndoModule', 'ChangedAndUndoneModule', 'BranchModule' ]
		
		# Special fallback group
		FallBack: [ 'SwitchTransporterToInward', 'SwitchTransporterToOutward' ]
		
	# Fallback steps
	#
	@FallBack:
		SwitchTransporterToInward: 'CreatedPrecursors'
		SwitchTransporterToOutward: 'SwitchPreviews'
		
	# Order of Group Processing
	#
	@Order: [
		'Start'
		'Inspecting'
		'Adding'
		'Automagic'
		'TimeMachine'
		'Finished'
		]
	
	# Group Titles
	#
	@Title:
		Inspecting: 'Inspecting modules'
		Adding: 'Adding modules'
		Automagic: 'Precursors and Previews'
		TimeMachine: 'The Virtual TimeMachine'
		FallBack: 'Woops! Almost, but not exactly...'

	# Creates a new instance of Tutorial
	#
	# @param parent [Controller.Main] the main controller
	# @param view [View.Tutorial] the view for this controller
	#
	constructor: ( @parent, view ) ->	
	
		@InverseStep = _( Tutorial.Step ).invert() 
	
		parent =
			getAbsolutePoint: ( location ) ->
				return [ $( window ).width() - 20, 20 ]
			
		@_canceled = locache.get( 'tutorial.cancelled' ) ? off
		@_step = locache.get( 'tutorial.at' ) ? Tutorial.Step.Start
		@_incurEventNextOnTestDebounce = _( @_incurEventNextOnTest ).debounce 300
		@_incurEventNextOnTestOrResetDebounce =  _( @_incurEventNextOnTestOrReset ).debounce 150
	
		super view ? ( new View.Tutorial parent )
		
		@_createBindings()
		
		unless ( @_canceled or @_step is Tutorial.Step.Finished )
			@_nextStep @_step, 'top', -10
			
	# Create default bindings for the view
	#
	_createBindings: () ->
		@_bind( 'view.tutorial.next', @, () => @_nextStep( @_getNextStep( @_step ), 'left', 10 ) )
		@_bind( 'view.tutorial.back', @, () => @_nextStep( @_getBackStep( @_step ), 'left', -10 ) )
		@_bind( 'view.tutorial.cancel', @, () => 
			@_unbindAll()
			@_createBindings() 
			@_canceled = on
		)
	
	# Goes to the next step
	#
	# @param step [Integer] the step to go to
	# @param animate [String] the animation css property
	# @param amount [Integer] the amount to animate for
	#
	_nextStep: ( step, animate = 'left', amount = 10 ) ->
		@_unbindFor @_step
		@_step = step
		locache.async.set( 'tutorial.at', @_step )
		title = @_getTitle @_step
		[ now, max ] = @_getProgress @_step
		message = @_getMessage @_step
		nextOnEvent = @_bindFor @_step
		title = "#{title} #{now}/#{max}" if max > 1 and ( not Tutorial.FallBack[ @InverseStep[ @_step ] ]? ) and title isnt 'Tutorial'
		@view.showMessage( title, message, nextOnEvent, animate, amount )

	# Gets the title for a step
	#
	# @param step [Integer] the step
	# @return [String] the title
	# 
	_getTitle: ( step ) ->
		name = @InverseStep[ step ]
		return Tutorial.Title[ @_getGroupKey name ] ? 'Tutorial'
			
	# Gets the progress for this step
	#
	# @return [Array<Integer>] the current step and maximum number of steps
	#
	_getProgress: ( step ) ->
		name = @InverseStep[ step ]
		group = Tutorial.Group[ @_getGroupKey name ]
		result = null
		if _( group ).find( ( _name, index ) -> 
			result = index
			return name is _name  )
			return [ result + 1, group.length ]
		return [ '?', 0 ]
		
	# Gets the messages for this step
	#
	# @param step [Integer] the step
	# @param [Array<String>] the messages
	#
	_getMessage: ( step ) ->
		switch step
			when Tutorial.Step.Start
				return [ 
					'<p>This is <strong>Gigabase</strong>. Your <i>virtual</i> cell.</p>'
					'<p>It seems like this is your first time here. Let me guide you through the process of creating your first cell.</p>'
					'<p class="alert alert-success">You can cancel the tutorial at any time by pressing the <span class="badge badge-inverse"><i class="icon-remove icon-white"></i> stop</span> button or the <span class="badge badge-inverse"><i class="icon-remove icon-white"></i></span> mark in the top right corner. To resume, simply press the <span class="badge badge-inverse"> <i class="icon-question-sign icon-white"></i></span>. You can also minimize the tutorial by pressing <span class="badge badge-inverse"><i class="icon-minus icon-white"></i></span>. Complete your task or press the <span class="badge badge-inverse"><i class="icon-question-sign icon-white"></i></span> to resume.</p>'
					'<p>Let' + "'" + 's start! Press the <span class="badge badge-inverse">Next <i class="icon-chevron-right icon-white"></i></span> button.</p>'
					'<p class="alert alert-danger">Because I want to start with a clean slate, I will <b>reset</b> the palette. If you have any pending changes, please <span class="badge badge-inverse"><i class="icon-upload icon-white"></i> Save</span> now.</p>'
				]
				
			when Tutorial.Step.ResetAfterStart
				return [
					'<p>There. A clean cell. Do you like what you are seeing?</p>'
					'<p>During this tutorial I will teach you how to <i>add</i> modules, all about precursors and auto<i>magic</i> actions, about the <i>timemachine</i>, where to change the <i>settings</i>, how to change the <i>simulation</i> to <i>generate reports</i> and more!</p>'
					'<p>But before all that, let me tell you all about what you are seeing. Press the <span class="badge badge-inverse">Next <i class="icon-chevron-right icon-white"></i></span> button to learn how to <b>Inspect Modules</b></p>'
				]
			
			when Tutorial.Step.OverviewHover
				return [
					'<p>I retracted that pane on the left for you. We don' + "'" + 't like distractions. Take a look at your palette right now, but <b>do not click</b> anything.</p>'
					'<p>In the center of your screen you can see your cell. I suppose that purple module feels very lonely.</p>'
					'<p class="alert alert-info"><b>Hover it</b>, to see what we are dealing with here.</p>'
				]
				
			when Tutorial.Step.OverviewSelect
				return [
					'<p>Ah, it seems to be the <i>Cell Growth</i> module. It keeps track of the <i>population size</i>. The Cell Growth module is always required in the cell, because without it we can not simulate a population. </p>'
					'<p>There is a lot of information here. Here you can see the <i>name</i> of the module, the <i>initial amount</i>, the metabolites used to calculate the <b>mu</b> and the required <i>infrastructure</i>. All modules have different properties and you can simply hover them to see those properties.</p>'
					'<p class="alert alert-info"><b>Click on the module</b>, to edit the module.</p>'
				]
				
			when Tutorial.Step.OverviewClose
				return [
					'<p>This is how we can edit the properties of a module. All the information has turned editable, except for the name.</p>'
					'<p class="alert alert-warning">Once a module is named, <b>its name is fixed</b>. Recreate the module if you want to change the name.</p>'
					'<p>Opening the properties popover of this module has hidden something on the palette. There is a button below the popover that I can not quite see.</p>'
					'<p class="alert alert-info"><b>Close the Cell Growth popover</b>, by clicking the <span class="badge badge-inverse"><i class="icon-remove icon-white"></i></span> button or clicking the module again.</p>'
				]
				
			when Tutorial.Step.OverviewEnd
				return [
					'<p>Good job! That is it for inspecting modules.</p>'
					'<p class="alert alert-success">You can close modules by clicking the <span class="badge badge-inverse"><i class="icon-remove icon-white"></i></span> button, clicking the module, or any other module, or pressing <span class="badge badge-inverse"><abbr title="escape">ESC</abbr></span> on your keyboard.</p>'
					'<p>No one likes solitude. So let me teach you about <b>Adding modules</b>. Press the <span class="badge badge-inverse">Next <i class="icon-chevron-right icon-white"></i></span> button.</p>'
				]
				
			when Tutorial.Step.CreateFromDummy
				lipidText = $("<span class='badge compounds'>lipid</span>")
				lipidText.css('background', Helper.Mixable.hashColor 'lipid' )
				
				return [
					'<p>For the cell to live, it will need some <i>infrastructure</i>. We have seen the infrastructure properties of the <i>Cell Growth</i> module. One of those items was ' + $( '<div></div>' ).append( lipidText ).html() + '. I still think some company is in order.</p>'
					'<p>Look! There is a template on the palette. Time to find that loner a friend.</p>'
					'<p class="alert alert-info"><b>Click <span class="badge badge-inverse">Add Lipid</span></b> to start adding the lipid.</p>'
				]
				
			when Tutorial.Step.CreateSave
				return [
					'<p class="alert alert-success">Clicking a <b>template module</b>, indicated by the transparent background and the dashed border, starts te creation process.</p>'
					'<p>Marvelous! You started the create-a-module process, or as I like to call it friend-for-cellgrowth process. We could change all these values, but let' + "'" + 's not do that. I will show you how to deal with that later.</p>'
					'<p class="alert alert-info"><b>Save the module</b>, by clicking the <span class="badge badge-inverse"><i class=" icon-ok icon-white"></i> Create</span> button.</p>'
				]
				
			when Tutorial.Step.CreatedAutomagic
				sintText = $("<span class='badge metabolites'>s</span>")
				sintText.css('background', Helper.Mixable.hashColor 's' )
				
				return [
					'<p>There. A friend for <i>Cell Growth</i>!</p>'
					'<p>Whoah! Where did that ' + $( '<div></div>' ).append( sintText ).html() + ' come from? I will explain that in a moment, but right now I want you to get rid of it. We don' + "'" + 't need no extra friends.</p>'
					'<p class="alert alert-info"><b>Delete</b> the module by selecting it - just click it, remember? - and then pressing the <span class="badge badge-inverse"><i class="icon-white icon-trash"></i></span> button.</p>'
				]
			
			when Tutorial.Step.ModuleDeleted
				return [
					'<p class="alert alert-success">A <b>module</b> can be removed from the cell simply by pressing the <span class="badge badge-inverse"><i class="icon-white icon-trash"></i></span> button. It is as easy as creating a module.</p>'
					'<p>That is much better. Did you already figure out where that component came from?</p>'
					'<p>Learn more about <b>Precursors and Previews</b>. Press the <span class="badge badge-inverse">Next <i class="icon-chevron-right icon-white"></i></span> button.</p>'
				]
				
			when Tutorial.Step.CreatePrecursors
				return [
					'<p>Most of these components simply do not like to be alone. A lot of them have prerequisites. If these are metabolites, a component will automatically, or as I call it auto<i>magic</i>ally try to add it to the cell.</p>'
					'<p>The cell will actually show you these precursors and I will show you too.</p>'
					'<p class="alert alert-info"><b>Click on the <span class="badge badge-inverse">Add Transporter</span></b> button to start adding a transporter.</p>'
				]
				
			when Tutorial.Step.SwitchTransporterToInward
				return [
					'<p>Jup! You selected a transporter, but this one exports product to the exterior of the cell. I would like you click on the other <b><span class="badge badge-inverse">Add Transporter</span></b> button to start creating an inward transporter.</p>'
					'<p class="alert alert-info"><b>Click on the <i>other</i> <span class="badge badge-inverse">Add Transporter</span></b> button to start adding an inward transporter.</p>'
				]
				
			when Tutorial.Step.CreatedPrecursors
				sintText = $("<span class='badge metabolites'>s</span>")
				sintText.css('background', Helper.Mixable.hashColor 's' )
				return [
					'<p>Look at that. This transporter wants to transport ' + $( '<div></div>' ).append( sintText ).html() + ' into the cell. But since we did not add a metabolite outside the cell, the transporter wants to create it. Similarly, because we did not add a metabolite inside the cell, the transporter wants to create that too.</p>'
					'<p>' + $( '<div></div>' ).append( sintText ).html() + ' is actually the default for an inward transporter. If you want to transporter something else, you would need to add something to transport. I will come to that in a minute.</p>'
					'<p>Have you noticed those dashed lines? These indicate the flow of the metabolites when you would create this transporter. It gives you an impression of what your action will incur.</p>'
					'<p class="alert alert-info"><b>Save the module</b>, by clicking the <span class="badge badge-inverse"><i class=" icon-ok icon-white"></i> Create</span> button.</p>'
				]
				
			when Tutorial.Step.MoreOptions
				vintText = $("<span class='badge metabolites'>v</span>")
				vintText.css('background', Helper.Mixable.hashColor 'v' )
				return [
					'<p>The dashed lines have turned into solid lines with moving mini metabolites. You correctly added a transporter with its transported counterparts.</p>'
					'<p class="alert alert-success">Adding a compound that misses metabolites will automatically add these missing metabolites. You can preview these additions. Once created, little metabolites show you the processing path.</p>'
					'<p>I would really like some more options when I am creating a transporter.</p>'
					'<p class="alert alert-info"><b>Add</b> a new metabolite ' + $( '<div></div>' ).append( vintText ).html() + ' <i>inside the cell</i>.</p>'
				]
				
			when Tutorial.Step.CreateFromOptions
				return [
					'<p>Perfect. Now start adding that outward transporter.</p>'
					'<p class="alert alert-info"><b>Click on the <span class="badge badge-inverse">Add Transporter</span></b> button to start adding a transporter.</p>'
					'<p class="alert alert-success">If the cell palette is blocked because of the tutorial, this would be a good moment to minimize the window by clicking the <span class="badge badge-inverse"><i class="icon-minus icon-white"></i></span> button. The tutorial will re-appear once you have completed your task.</p>'
				]
				
			when Tutorial.Step.SwitchTransporterToOutward
				return [
					'<p>Jup! You selected a transporter, but this one imports product to the interior of the cell. I would like you click on the other <b><span class="badge badge-inverse">Add Transporter</span></b> button to start creating an outward transporter.</p>'
					'<p class="alert alert-info"><b>Click on the <i>other</i> <span class="badge badge-inverse">Add Transporter</span></b> button to start adding an outward transporter.</p>'
					'<p class="alert alert-success">If the cell palette is blocked because of the tutorial, this would be a good moment to minimize the window by clicking the <span class="badge badge-inverse"><i class="icon-minus icon-white"></i></span> button. The tutorial will re-appear once you have completed your task.</p>'
				]
				
			when Tutorial.Step.SwitchPreviews
				pintText = $("<span class='badge metabolites'>p</span>")
				pintText.css('background', Helper.Mixable.hashColor 'p' )
				vintText = $("<span class='badge metabolites'>v</span>")
				vintText.css('background', Helper.Mixable.hashColor 'v' )
				return [ 
					'<p>Again, you can see a preview of what would happen if you would click the <span class="badge badge-inverse"><i class=" icon-ok icon-white"></i> Create</span> button.</p>'
					'<p class="alert alert-success">The default transported metabolite for an outward transporter is ' + $( '<div></div>' ).append( pintText ).html() + '. It will be available even if you have not added it inside or outside the cell.</p>'
					'<p>The default is selected, but let me show you how previews are updated when we have more options and pick another option.</p>'
					'<p class="alert alert-info"><b>Switch the transported metabolite</b> to your newly created ' + $( '<div></div>' ).append( vintText ).html() + ' and see the magic happen.</p>'
				]
				
			when Tutorial.Step.SwitchedPreviews
				return [
					'<p class="alert alert-success">Auto<i>magic</i>ally adding metabolites speeds up your modelling process. Don' + "'" + 't forget there are some defaults though.</p>'
					'<p>This looks about right. Please finalize the creation process.</p>'
					'<p class="alert alert-info"><b>Save the transporter</b>, by clicking the <span class="badge badge-inverse"><i class=" icon-ok icon-white"></i> Create</span> button.</p>'
				]
				
			when Tutorial.Step.AddedUneccesary
				pintText = $("<span class='badge metabolites'>p</span>")
				pintText.css('background', Helper.Mixable.hashColor 'p' )
				vintText = $("<span class='badge metabolites'>v</span>")
				vintText.css('background', Helper.Mixable.hashColor 'v' )
				return [
					'<p>On the other hand - do you really need that ' + $( '<div></div>' ).append( vintText ).html() + '? You could edit the transporter - change transported back to ' + $( '<div></div>' ).append( pintText ).html() + ' - but you would still be left with 2 loose ' + $( '<div></div>' ).append( vintText ).html() + ' metabolites. If there was only a way to undo your changes...</p>'
					'<p>Step into <b>The Vitual TimeMachine</b> by pressing the <span class="badge badge-inverse">Next <i class="icon-chevron-right icon-white"></i></span> button.</p>'
				]
				
			when Tutorial.Step.UndoThemPrecursor
				return [
					'<p>I extended that pane I closed earlier. Look at your history!</p>'
					'<p class="alert alert-success">The TimeMachine is available in the cell and its components. All your actions during one session are recorded and saved. It can be a handy tool to quickly try out different settings and to undo and redo certain actions.</p>'
					'<p>This would be perfect to undo our latest changes. Let' + "'" + 's try that.</p>'
					'<p class="alert alert-info"><b>Undo Added Metabolite v</b>, by clicking <b>above</b> the <span class="badge badge-inverse">Added Metabolite</span> action in the history pane.</p>'
				] 
			
			when Tutorial.Step.RedoModule
				return [
					'<p class="alert alert-success">You can undoing an action by moving the action cursor above the action you want to undo. You can also press <span class="badge badge-inverse"><abbr title="control">CTRL</abbr></span> + <span class="badge badge-inverse">Z</span> on your keyboard.</p>'
					'<p>You have just undone your add action. But perhaps that was not what you wanted to do. Luckily you can also redo your undone actions.</p>'
					'<p class="alert alert-info"><b>Redo Added Metabolite v</b>, by clicking <b>on</b> the <span class="badge badge-inverse">Added Metabolite</span> action in the history pane.</p>'
				] 
				
			when Tutorial.Step.ChangeAndUndoModule
				return [
					'<p class="alert alert-success">You can redo an undone action by moving the action cursor on the action you want to redo. You can also press <span class="badge badge-inverse"><abbr title="control">CTRL</abbr></span> + <span class="badge badge-inverse">Y</span> on your keyboard.</p>'
					'<p>I have shown you that this works for adding and removing modules, but I have also implemented this behaviour for module properties! Time to try that out.</p>'
					'<p class="alert alert-info">Open up the Transporter and change three - <b>exactly <i>three</i></b> - properties. When you are done, save your changes by pressing the <span class="badge badge-inverse"><i class="icon-ok icon-white"></i> Save</span> button.</p>'
				] 
				
			when Tutorial.Step.ChangedAndUndoModule
				return [
					'<p><b>Splendid!</b> Do you see the new actions in that History list? Those are the properties you have just changed.</p>'
					'<p class="alert alert-success">When you select a module, the <b>timemachine</b> for that module will be highlighted. This way, you can keep track of your changes.</p>'
					'<p>You can also batch undo or redo actions. You are going to try that now by undoing our last three changes, all at once. I will check if you are undoing exactly those three actions, so don' + "'" + 't try to be a cool kid.</p>'
					'<p class="alert alert-info"><b>Undo the last three actions</b>, by clicking <b>above</b> the <span class="badge badge-inverse">Change ... from ... to ...</span> actions in the history pane.</p>'
					
				]
			
			when Tutorial.Step.ChangedAndUndoneModule
				pintText = $("<span class='badge metabolites'>p</span>")
				pintText.css('background', Helper.Mixable.hashColor 'p' )
				vintText = $("<span class='badge metabolites'>v</span>")
				vintText.css('background', Helper.Mixable.hashColor 'v' )
				return [
					'<p>You are getting so good at this! Well done.</p>'
					'<p>I think we are ready to re-add that outward transporter, this time transporting the default ' + $( '<div></div>' ).append( pintText ).html() + ' instead of that obnoxious ' + $( '<div></div>' ).append( vintText ).html() + ' we still have.</p>'
					'<p class="alert alert-info"><b>Click on the <span class="badge badge-inverse">Add Transporter</span></b> button and save the transporter by clicking the <span class="badge badge-inverse"><i class=" icon-ok icon-white"></i> Create</span> button.</p>'
					'<p class="alert alert-success">If the cell palette is blocked because of the tutorial, this would be a good moment to minimize the window by clicking the <span class="badge badge-inverse"><i class="icon-minus icon-white"></i></span> button. The tutorial will re-appear once you have completed your task.</p>'
				]	
				
			when Tutorial.Step.BranchModule
				return [
					'<p class="alert alert-success">When your history cursor is not at the end of the list, and you invoke a new action, branching occurs. The action that held the cursor now has more options. It could resume the old action list or continue the new path.</p>'
					'<p>Cool! The history list automatically purged the items below the cursor. Or did it? Something changed. The previous action now reads 1 alternative actions.</p>'
					'<p class="alert">Branching can be useful, when used correctly, but one can easily lose track of all the branches. Additionally, the history is not saved, so you might be better off saving a clone than to rely on branching.</p>'
				]


			when Tutorial.Step.Finished
				return [ '<p>You have completed the tutorial!</p>', 
					'<p class="alert alert-info">Now start building your own cell.</p>' 
				]

			else
				return []
	
	# Incurs the next event
	#
	# @param next [Integer] the next step
	#
	_incurEventNext: ( next = @_getNextStep( @_step ) ) ->
		return if @_incurred
		@_incurred = on
		@view.hide( ( () => 
			@_nextStep next
			@_incurred = off
		), 'left', 10 )
		
	# Incurs the next event only if a test has passed
	#
	_incurEventNextOnTest: () ->
		return unless @_latestTest
		@_incurEventNext()
		
	# Incurs the next event only if a test has passed
	#
	_incurEventNextOnTestOrReset: () ->
		@_successes = 0
		return unless @_latestTest
		@_incurEventNext()
	
	# Tests if cell growth is being hovered
	#
	_CellGrowthHoverTest: ( view, event, state ) =>
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@_latestTest = state
			@_incurEventNextOnTestDebounce()
	
	# Tests if cell growth is selected
	#
	_CellGrowthSelectTest: ( view, event, state ) =>
		return unless state
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@_incurEventNext()
			
	# Tests if lipid is selected
	#
	_LipidSelectTest: ( view, event, state ) =>
		return unless state
		if view instanceof View.DummyModule and view.model instanceof Model.Lipid
			@_incurEventNext()
			
	# Test if transporter is selected
	#
	_TransporterSelectInwardTest: ( view, event, state ) =>
		return unless state
		if view instanceof View.DummyModule and view.model instanceof Model.Transporter
			if view.model.direction is Model.Transporter.Outward
				@_incurEventNext Tutorial.Step.SwitchTransporterToInward
			else
				@_incurEventNext()
				
	# Test if transporter is selected
	#
	_TransporterSelectOutwardTest: ( view, event, state ) =>
		return unless state
		if view instanceof View.DummyModule and view.model instanceof Model.Transporter
			if view.model.direction is Model.Transporter.Inward
				@_incurEventNext Tutorial.Step.SwitchTransporterToOutward
			else
				@_incurEventNext()
	
	# Test if cell growth is closed
	#
	_CellGrowthCloseTest: ( view, event, state ) =>
		return if state
		if view instanceof View.Module and view.model instanceof Model.CellGrowth
			@_incurEventNext()
			
	# Test if lipid is added
	#
	_LipidAddedTest: ( cell, module ) =>
		if module instanceof Model.Lipid
			@_incurEventNext()
			
	# Test if transpoter is added
	#
	_TransporterAddedTest: ( cell, module ) =>
		if module instanceof Model.Transporter
			@_incurEventNext()
			
	# Test if transpoter is added
	#
	_VIntAddedTest: ( cell, module ) =>
		if module instanceof Model.Metabolite and module.name is 'v#int'
			@_incurEventNext()
			
	# Test if transporter transported was changed to VInt
	#
	_TransporterChangedTransportedTest: ( view, changes, key, value, currents ) =>
		if key is 'transported' and value is 'v'
			@_incurEventNext()
			
	# Test is Sint is removed
	#
	_SIntRemovedTest: ( cell, module ) =>
		if module instanceof Model.Metabolite
			@_incurEventNext()
	
	#
	#
	_TransportedUndoneThreeTest: ( controller, nodes ) =>
		if nodes.reverse? and nodes.reverse.length is 3
			@_incurEventNext()
	
	#
	#
	_TransporterChangedThreeTest: ( view, changes ) =>
		if _( changes ).keys().length is 3
			@_incurEventNext()
	
	#
	#
	_VRedoneTest: ( html, action ) =>
		if action.object._description.indexOf( "Added Metabolite" ) > -1
			@_successes += 1
			@_latestTest = @_successes is 2
			@_incurEventNextOnTestOrResetDebounce()
			
	# Test if v is added
	#
	_VAddedTest: ( cell, module ) =>
		if module instanceof Model.Metabolite and module.name.split( '#' )[0] is 'v'
			@_successes += 1
			@_latestTest = @_successes is 2
			@_incurEventNextOnTestOrResetDebounce()
		
	#
	#
	_VUndoneTest: ( html, action ) =>
		if action.object._description.indexOf( "Added a Transporter" ) > -1
			@_successes += 1
			@_latestTest = @_successes is 2
			@_incurEventNextOnTestOrResetDebounce()
			
	# Test if v is removed
	#
	_VRemovedTest: ( cell, module ) =>
		if module instanceof Model.Metabolite and module.name.split( '#' )[0] is 'v'
			@_successes += 1
			@_latestTest = @_successes is 2
			@_incurEventNextOnTestOrResetDebounce()	
			
	# Test if transpoter is added
	#
	_TransporterOutwardAddedTest: ( cell, module ) =>
		if module instanceof Model.Transporter and module.direction is Model.Transporter.Outward
			@_incurEventNext()
			
	# Gets the next step
	#
	# @param step [Integer] the current step
	# @return [Integer] the next step
	#
	_getNextStep: ( step ) ->
		name = @InverseStep[ step ]
		if ( Tutorial.FallBack[ name ]? )
			return Tutorial.Step[ Tutorial.FallBack[ name ] ]
		group_key = @_getGroupKey name
		group = Tutorial.Group[ group_key ]
		result = null
		if _( group ).find( ( _name, index ) -> 
			result = index
			return name is _name  )
			if group.length > result + 1
				return Tutorial.Step[ group[ result + 1] ]
			return Tutorial.Step[ _( @_getNextGroup( group_key ) ).first() ]
			
		return step
		
	# Gets the next group
	#
	# @param group_key [String] the current group key
	# @return [Array<String>] the next group 
	#
	_getNextGroup: ( group_key ) ->
		result = null
		if _( Tutorial.Order ).find( ( _group, index ) -> 
			result = index
			return group_key is _group  )
			if Tutorial.Order.length > result + 1
				return Tutorial.Group[ Tutorial.Order[ result + 1 ] ]
			return Tutorial.Group[ _( Tutorial.Order ).first() ]
		return Tutorial.Group[ group_key ]
		
	# Gets the previous step
	#
	# @param step [Integer] the current step
	# @return [Integer] the previous step
	#
	_getBackStep: ( step ) ->
		name = @InverseStep[ step ]
		if ( Tutorial.FallBack[ name ]? )
			return @_getBackStep( Tutorial.Step[ Tutorial.FallBack[ name ] ] )
		group_key = @_getGroupKey name
		group = Tutorial.Group[ group_key ]
		result = null
		if _( group ).find( ( _name, index ) -> 
			result = index
			return name is _name  )
			if result > 0
				return Tutorial.Step[ group[ result - 1 ] ]
			return Tutorial.Step[ _( @_getBackGroup( group_key ) ).last() ]
			
		return step
		
	# Gets the previous group
	#
	# @param group_key [String] the current group key
	# @return [Array<String>] the previous group 
	#
	_getBackGroup: ( group_key ) ->
		result = null
		if _( Tutorial.Order ).find( ( _group, index ) -> 
			result = index
			return group_key is _group  )
			if result > 0
				return Tutorial.Group[ Tutorial.Order[ result - 1 ] ]
			return Tutorial.Group[ _( Tutorial.Order ).last() ]
		return Tutorial.Group[ group_key ]

	# Gets the group key for a step name
	#
	# @param name [String] the step name/key
	# @return [String] the group name/key
	#
	_getGroupKey: ( name ) ->
		result = null
		if _( Tutorial.Group ).find( ( group, key ) -> 
			result = key
			return name in group  )
			return result
		return null
		
	# Binds events for the step
	#
	# @param step [Integer] the step id
	# @return [Boolean] true if something was bound
	#
	_bindFor: ( step ) =>
		switch step
			when Tutorial.Step.ResetAfterStart
				@parent.controller( 'cell' ).model = new Model.Cell()
				return off
			when Tutorial.Step.OverviewHover
				@parent.view.hidePanes()
				@_bind( 'view.module.hovered', @, @_CellGrowthHoverTest )
				return on
			when Tutorial.Step.OverviewSelect
				@_bind( 'view.module.select', @, @_CellGrowthSelectTest )
				return on
			when Tutorial.Step.OverviewClose
				@_bind( 'view.module.selected', @, @_CellGrowthCloseTest )
				return on
			when Tutorial.Step.CreateFromDummy
				@_bind( 'view.module.select', @, @_LipidSelectTest )
				return on
			when Tutorial.Step.CreateSave
				@_bind( 'cell.module.added', @, @_LipidAddedTest )
				return on
			when Tutorial.Step.CreatedAutomagic
				@_bind( 'cell.metabolite.removed', @, @_SIntRemovedTest )
				return on
			when Tutorial.Step.CreatePrecursors
				@_bind( 'view.module.select', @, @_TransporterSelectInwardTest )
				return on
			when Tutorial.Step.SwitchTransporterToInward
				@_bind( 'view.module.select', @, @_TransporterSelectInwardTest )
				return on
			when Tutorial.Step.CreatedPrecursors
				@_bind( 'cell.module.added', @, @_TransporterAddedTest )
				return on
			when Tutorial.Step.MoreOptions
				@_bind( 'cell.metabolite.added', @, @_VIntAddedTest )
				return on
			when Tutorial.Step.CreateFromOptions
				@_bind( 'view.module.select', @, @_TransporterSelectOutwardTest ) 
				return on
			when Tutorial.Step.SwitchTransporterToOutward
				@_bind( 'view.module.select', @, @_TransporterSelectOutwardTest )
				return on
			when Tutorial.Step.SwitchPreviews
				@_bind( 'view.module.changed', @, @_TransporterChangedTransportedTest )
				return on
			when Tutorial.Step.SwitchedPreviews
				@_bind( 'cell.module.added', @, @_TransporterAddedTest )
				return on
			when Tutorial.Step.UndoThemPrecursor
				@parent.view.showPanes()
				@_successes = 0
				@_bind( 'view.undo.node.selected', @, @_VUndoneTest )
				@_bind( 'cell.metabolite.removed', @, @_VRemovedTest )
				return on
			when Tutorial.Step.RedoModule
				@_successes = 0
				@_bind( 'view.undo.node.selected', @, @_VRedoneTest )
				@_bind( 'cell.metabolite.added', @, @_VAddedTest )
				return on
			when Tutorial.Step.ChangeAndUndoModule
				@_bind( 'view.module.saved', @, @_TransporterChangedThreeTest )
				return on
			when Tutorial.Step.ChangedAndUndoModule
				@_bind( 'controller.undo.jump.finished', @, @_TransportedUndoneThreeTest )
				return on
			when Tutorial.Step.ChangedAndUndoneModule
				@_bind( 'cell.module.added', @, @_TransporterOutwardAddedTest )
				return on
			else
				return off
		
	# Unbinds events for the step
	#
	# @param step [Integer] the step id
	# @return [Boolean] true if something was unbound
	#
	_unbindFor: ( step ) =>
		switch step
			when Tutorial.Step.OverviewHover
				@_unbind( 'view.module.hovered', @, @_CellGrowthHoverTest )
				return on
			when Tutorial.Step.OverviewSelect
				@_unbind( 'view.module.select', @, @_CellGrowthSelectTest )
				return on
			when Tutorial.Step.OverviewClose
				@_unbind( 'view.module.selected', @, @_CellGrowthCloseTest )
				return on
			when Tutorial.Step.CreateFromDummy
				@_unbind( 'view.module.select', @, @_LipidSelectTest )
				return on
			when Tutorial.Step.CreateSave
				@_unbind( 'cell.module.added', @, @_LipidAddedTest )
				return on
			when Tutorial.Step.CreatedAutomagic
				@_unbind( 'cell.metabolite.removed', @, @_SIntRemovedTest )
				return on
			when Tutorial.Step.CreatePrecursors
				@_unbind( 'view.module.select', @, @_TransporterSelectInwardTest )
				return on
			when Tutorial.Step.SwitchTransporterToInward
				@_unbind( 'view.module.select', @, @_TransporterSelectInwardTest )
				return on
			when Tutorial.Step.CreatedPrecursors
				@_unbind( 'cell.module.added', @, @_TransporterAddedTest )
				return on
			when Tutorial.Step.MoreOptions
				@_unbind( 'cell.metabolite.added', @, @_VIntAddedTest )
				return on
			when Tutorial.Step.CreateFromOptions
				@_unbind( 'view.module.select', @, @_TransporterSelectOutwardTest ) 
				return on
			when Tutorial.Step.SwitchTransporterToOutward
				@_unbind( 'view.module.select', @, @_TransporterSelectOutwardTest )
				return on
			when Tutorial.Step.SwitchPreviews
				@_unbind( 'view.module.changed', @, @_TransporterChangedTransportedTest )
				return on
			when Tutorial.Step.SwitchedPreviews
				@_unbind( 'cell.module.added', @, @_TransporterAddedTest )
				return on
			when Tutorial.Step.UndoThemPrecursor
				@_unbind( 'view.undo.node.selected', @, @_VUndoneTest )
				@_unbind( 'cell.metabolite.removed', @, @_VRemovedTest )
				return on
			when Tutorial.Step.RedoModule
				@_unbind( 'view.undo.node.selected', @, @_VRedoneTest )
				@_unbind( 'cell.metabolite.added', @, @_VAddedTest )
				return on
			when Tutorial.Step.ChangeAndUndoModule
				@_unbind( 'view.module.saved', @, @_TransporterChangedThreeTest )
				return on
			when Tutorial.Step.ChangedAndUndoModule
				@_unbind( 'controller.undo.jump.finished', @, @_TransportedUndoneThreeTest )
				return on
			when Tutorial.Step.ChangedAndUndoneModule
				@_unbind( 'cell.module.added', @, @_TransporterOutwardAddedTest )
				return on
			else 
				return off
		
	# Shows the view
	#
	show: ( ) ->
		return unless @_canceled or not @view.visible
		@_canceled = off
		@_step = Tutorial.Step.Start if @_step is Tutorial.Step.Finished
		@_nextStep @_step, 'top', -10
		
	# On unload, stores the cell
	#
	onUnload: () =>
		locache.set( 'tutorial.at', @_step )
		locache.set( 'tutorial.cancelled', @_canceled )
		super()
