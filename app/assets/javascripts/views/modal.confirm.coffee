# Provides an HTML Modal
#
# @concern Mixin.EventBindings
#
class View.ConfirmModal extends View.HTMLModal

	@concern Mixin.EventBindings

	#  Create the modal footer
	#
	#
	_createFooter: () ->
		footer = $ '<div class="modal-footer"></div>'
		cancel = $ '<button class="btn" data-action="cancel" data-dismiss="modal" aria-hidden="true">Cancel</button>'
		confirm = $ '<button class="btn btn-primary" data-action="confirm" data-dismiss="modal" aria-hidden="true">Confirm</button>'
		footer.append cancel
		footer.append confirm
		return [ footer, cancel, confirm ]
		
	
	