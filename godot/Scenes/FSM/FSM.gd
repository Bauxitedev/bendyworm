extends Spatial

export(String) var initial_state = null
var possible_states = {}
var pending_state = null #: String -> Strings can't be null?
var current_state_instance: Node = null

func get_fsm_holder() -> Node:
	return get_parent()

func get_state() -> String:
	return current_state_instance.name 

func _ready():
	
	# Setup states
	for state in get_children():
		remove_child(state) # Remove the child from the scene tree, but keep it in memory so we can instance it later
		var state_name = state.name
		possible_states[state_name] = state
		
	if initial_state == null:
		push_error("FSM initial state is null, please set it in the inspector")
		return
		
	pending_state = initial_state
	
	handle_pending_state()
	
func _exit_tree():
	# Free all states to avoid memory leak, right?
	for state_key in possible_states.keys():
		var state_template = possible_states[state_key]
		state_template.queue_free()
		
		
func _process(_delta):
	handle_pending_state()
	
func handle_pending_state():
	
	if pending_state != null:
		
		if !(pending_state in possible_states):
			push_error("error: invalid state %s" % pending_state)
			return
		
		if current_state_instance != null:
			current_state_instance.exit()
			current_state_instance.name = "[switched out]" # Important! Otherwise the get_state() method breaks if you switch from a state to itself (auto name change)
			current_state_instance.queue_free()
			
		var state_template: Node = possible_states[pending_state]
		var state_instance = state_template.duplicate() # TODO check duplicate flags
		
		add_child(state_instance)
		pending_state = null # Note: call this before state_instance.enter() (so in enter() we can switch state again)
		state_instance.enter()
		current_state_instance = state_instance
		
		
	
	
# Set a pending state change
func switch_to_state(state: String):
	pending_state = state

# Call a method on the current state
func call_on_state(method: String):
	current_state_instance.call(method)
