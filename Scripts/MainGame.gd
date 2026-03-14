
extends Node3D
@onready var camera: Camera3D = $Camera3D
@onready var front_cam_pos: Marker3D = $FrontCamPos
@onready var back_cam_pos: Marker3D = $BackCamPos
@onready var tray: TransactionTray
@onready var money_label: Label = $CanvasLayer/MoneyLabel
@onready var held_item_label: Label = $CanvasLayer/HeldItemLabel
@onready var customer_spawn_pos: Marker3D = $CustomerSpawnPos
@onready var customer_target_pos: Marker3D = $CustomerTargetPos
@onready var dialogue_ui: DialogueUI = $DialogueUI
@onready var item_selection_ui: ItemSelectionUI = $"ItemSelectionUI"
@onready var confirmation_popup: ConfirmationPopup = $"ConfirmationPopup"
@onready var shelf: StaticBody3D = get_node_or_null("Shelf")

var current_view: String = "front"
var left_transform: Transform3D
var right_transform: Transform3D
var money: int = 0
var held_item: ItemData = null
var current_customer: Customer

const CUSTOMER_SCENE = preload("res://Scenes/Customer.tscn")
const TRAY_SCENE = preload("res://Scenes/TransactionTray.tscn")

# Dynamically scan Resources/items/ folder for ALL .tres files
# This allows new items to be added without modifying code
var ITEMS: Array[ItemData] = []

func _get_items_from_folder(folder_path: String) -> Array[ItemData]:
	var items: Array[ItemData] = []
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path = folder_path + "/" + file_name
				var item = load(full_path)
				if item is ItemData:
					items.append(item)
			file_name = dir.get_next()
		dir.list_dir_end()
	return items

func _load_all_items() -> void:
	# Scan all subdirectories in Resources/items/
	var base_path = "res://Resources/items"
	var base_dir = DirAccess.open(base_path)
	if base_dir:
		base_dir.list_dir_begin()
		var subdir = base_dir.get_next()
		while subdir != "":
			if base_dir.current_is_dir() and subdir != "." and subdir != "..":
				var subdir_path = base_path + "/" + subdir
				ITEMS.append_array(_get_items_from_folder(subdir_path))
			subdir = base_dir.get_next()
		base_dir.list_dir_end()
	
	# Fallback: if no items found, load the legacy Sardines.tres from items/food
	if ITEMS.is_empty():
		var sardines = load("res://Resources/items/food/Sardines.tres")
		if sardines is ItemData:
			ITEMS.append(sardines)
	print("Loaded ", ITEMS.size(), " items dynamically")

func _ready() -> void:
	# Load all items dynamically before anything else
	_load_all_items()

	# Configure ItemSelectionUI to always show 33 items from Assets folder
	if item_selection_ui:
		item_selection_ui.set_item_count(33)

	# Fix camera FOV - defer to ensure scene is fully loaded
	await get_tree().process_frame
	if camera and camera.fov != 75:
		camera.fov = 75.0

	var tray_node = get_node_or_null("FrontStore/TransactionTray")
	if tray_node:
		tray = tray_node
	else:
		tray = TRAY_SCENE.instantiate()
		var front_store = get_node_or_null("FrontStore")
		if front_store:
			front_store.add_child(tray)
		else:
			add_child(tray)
			tray.global_position = front_cam_pos.global_position + Vector3(0, -1, -2) # Guessing a good spot if missing
			
	InputManager.view_requested.connect(switch_view)
	tray.item_placed.connect(_on_item_placed)
	dialogue_ui.closed.connect(_on_dialogue_closed)
	
	# Connect shelf and UI signals for MVP flow
	shelf = get_node_or_null("Shelf")
	if shelf:
		shelf.pressed.connect(_on_shelf_pressed)
	else:
		# Try to auto-instance Shelf if it exists in Scenes folder
		var shelf_scene = load("res://Scenes/Shelf.tscn")
		if shelf_scene:
			var shelf_instance = shelf_scene.instantiate()
			shelf_instance.name = "Shelf"
			add_child(shelf_instance)
			shelf = shelf_instance
			if shelf.has_signal("pressed"):
				shelf.pressed.connect(_on_shelf_pressed)
			print("Auto-instanced Shelf scene")
	if item_selection_ui:
		item_selection_ui.item_selected.connect(_on_item_selected)
		print("ItemSelectionUI signal connected")
	else:
		print("ERROR: ItemSelectionUI is null!")
	
	# Use scene-based ConfirmationPopup
	confirmation_popup = get_node_or_null("ConfirmationPopup")
	print("ConfirmationPopup node:", confirmation_popup)
	
	if confirmation_popup:
		confirmation_popup.confirmed.connect(_on_confirmation_confirmed)
		print("ConfirmationPopup signal connected!")
	else:
		print("ERROR: ConfirmationPopup is null!")
	# Note: using programmatic popup, no signals needed
	
	# Calculate center pivot to dynamically create left and right transforms
	var center = (front_cam_pos.global_position + back_cam_pos.global_position) / 2.0
	
	# Left transform is front rotated 90 deg (PI/2) around Y at center
	var basis_left = front_cam_pos.global_transform.basis.rotated(Vector3.UP, PI / 2.0)
	var pos_left = center + (front_cam_pos.global_position - center).rotated(Vector3.UP, PI / 2.0)
	left_transform = Transform3D(basis_left, pos_left)
	
	# Right transform is front rotated -90 deg (-PI/2) around Y at center
	var basis_right = front_cam_pos.global_transform.basis.rotated(Vector3.UP, -PI / 2.0)
	var pos_right = center + (front_cam_pos.global_position - center).rotated(Vector3.UP, -PI / 2.0)
	right_transform = Transform3D(basis_right, pos_right)
	
	# Create programmatic shelf(Drawer) button as fallback UI
	var shelf_btn = Button.new()
	shelf_btn.text = "Drawer (I)"
	shelf_btn.position = Vector2(20, 120)
	shelf_btn.size = Vector2(120, 40)
	shelf_btn.pressed.connect(_on_shelf_button_pressed)
	
	# Try to add to CanvasLayer if it exists, otherwise add to root
	var canvas = get_node_or_null("CanvasLayer")
	if canvas:
		canvas.add_child(shelf_btn)
	else:
		add_child(shelf_btn)

	# After creating our shelf button, hide any existing ones
	await get_tree().process_frame
	for child in get_children():
		if child is Button and "shelf" in child.name.to_lower() and child.text != "Shelf (I)":
			child.visible = false
			child.process_mode = Node.PROCESS_MODE_DISABLED
	# Also check CanvasLayer children if it exists
	if canvas:
		for child in canvas.get_children():
			if child is Button and "shelf" in child.name.to_lower() and child.text != "Shelf (I)":
				child.visible = false
				child.process_mode = Node.PROCESS_MODE_DISABLED

	spawn_customer()

func switch_view(action: String) -> void:
	var target_view: String = current_view
	
	match action:
		"look_front":
			target_view = "front" 
		"look_left":
			match current_view:
				"front": target_view = "left"
				"left": target_view = "back"
				"back": target_view = "right"
				"right": target_view = "front"
		"look_right":
			match current_view:
				"front": target_view = "right"
				"right": target_view = "back"
				"back": target_view = "left"
				"left": target_view = "front"
		"look_back":
			match current_view:
				"front": target_view = "back"
				"back": target_view = "front"
				"left": target_view = "right"
				"right": target_view = "left"
				
	if current_view == target_view: return
	current_view = target_view
	
	var target_transform: Transform3D
	match target_view:
		"front": target_transform = front_cam_pos.global_transform
		"back": target_transform = back_cam_pos.global_transform
		"left": target_transform = left_transform
		"right": target_transform = right_transform
		
	var tween = create_tween()
	tween.set_parallel(true)
	
	# To avoid euler angle wrap-around (spinning the long way), we tween position and quaternion locally.
	var local_target: Transform3D = camera.get_parent().global_transform.affine_inverse() * target_transform
	var target_pos: Vector3 = local_target.origin
	var target_quat: Quaternion = local_target.basis.get_rotation_quaternion()
	
	tween.tween_property(camera, "position", target_pos, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "quaternion", target_quat, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func spawn_customer() -> void:
	if current_customer: return
	
	await get_tree().create_timer(2.0).timeout
	
	var customer: Customer = CUSTOMER_SCENE.instantiate()
	add_child(customer)
	customer.global_position = customer_spawn_pos.global_position
	
	# Pick random item
	var desired_item = ITEMS.pick_random()
	customer.setup(desired_item, customer_target_pos.global_position)
	
	current_customer = customer
	current_customer.satisfied.connect(_on_customer_satisfied)
	
	# Connect new 'arrived' signal to show dialogue
	if not customer.is_connected("arrived", _on_customer_arrived):
		customer.arrived.connect(_on_customer_arrived)

func _on_customer_arrived(customer: Customer) -> void:
	var dialogue_text = "*Neigh* Pahingi ako %s!" % customer.desire.item_name
	# We use the body sprite texture for the portrait
	dialogue_ui.show_dialogue(customer.body_sprite.texture, dialogue_text)

func _on_item_placed(item: DraggableItem) -> void:
	# Note: Money is now added via click-to-customer delivery
	# This function handles tray placement but doesn't add money
	if current_customer and current_customer.is_waiting:
		if current_customer.check_item(item.item_data):
			# Success - just remove the item
			item.queue_free() # Remove sold item
		else:
			# Wrong item logic
			print("Customer rejected item")
			item.return_to_start()
	else:
		# No customer or not ready
		item.return_to_start()

var _waiting_for_next_customer: bool = false

func _on_customer_satisfied() -> void:
	# Customer texture might still be valid before queue_free if we act fast, 
	# but safer to grab it from our reference or assume DialogueUI still has it if we pass null?
	# DialogueUI.show_dialogue replaces texture. 
	# current_customer is about to be freed.
	var tex = current_customer.body_sprite.texture
	dialogue_ui.show_dialogue(tex, "Salamat bossing!")
	_waiting_for_next_customer = true

func _on_dialogue_closed() -> void:
	if _waiting_for_next_customer:
		_waiting_for_next_customer = false
		current_customer = null
		spawn_customer()

func add_money(amount: int) -> void:
	money += amount
	money_label.text = "Peso: " + str(money)

# New MVP flow functions
func _on_shelf_pressed() -> void:
	"""Show item selection when shelf is clicked."""
	item_selection_ui.show_selection()

func _on_shelf_button_pressed() -> void:
	"""Show item selection when programmatic shelf button is pressed."""
	if item_selection_ui:
		item_selection_ui.show_selection()

func _on_item_selected(index: int) -> void:
	"""Show confirmation popup when item is selected."""
	if not confirmation_popup:
		print("ERROR: confirmation_popup is null in _on_item_selected!")
		return
	# Load texture directly from PNG files like ItemSelectionUI does
	var texture = load("res://Assets/items/%d.png" % (index + 1))
	confirmation_popup.show_confirmation(index, texture)
	print("Showing confirmation for item:", index)

func _on_confirmation_confirmed(item_index: int) -> void:
	"""Hold the item and deliver to customer automatically."""
	print("DEBUG: _on_confirmation_confirmed called with item_index:", item_index)
	
	# For MVP: use fixed price of 20 pesos regardless of item
	# This simplifies the flow since ITEMS array may not match UI items
	var price: int = 20  # Fixed price for MVP
	
	held_item_label.text = "Holding Item #" + str(item_index + 1)
	held_item_label.visible = true
	
	# Auto-deliver to customer immediately
	_deliver_item_to_customer_with_price(price)

func _on_confirmation_cancelled() -> void:
	"""Go back to item selection."""
	item_selection_ui.show_selection()

func _unhandled_input(event: InputEvent) -> void:
	# Handle keyboard shortcut for shelf (press S to open item selection)
	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		if item_selection_ui:
			item_selection_ui.show_selection()
	
	# Handle clicking on customer to deliver item
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if held_item != null and current_customer != null and camera:
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * 100
			
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if result and result.collider == current_customer:
				_deliver_item_to_customer()

func _deliver_item_to_customer() -> void:
	"""Deliver held item to customer and get money."""
	if current_customer == null or held_item == null:
		return
	
	# Check if item is correct
	var is_correct = current_customer.check_item(held_item)
	
	# Get actual item price
	var price = held_item.price
	
	# Add money with actual price
	add_money(price)
	
	# Show item on customer's bubble
	if current_customer.item_icon and held_item.texture:
		current_customer.item_icon.texture = held_item.texture
	
	# Show dialogue with actual price
	if dialogue_ui:
		# Get customer texture for dialogue
		var customer_tex = current_customer.body_sprite.texture if current_customer and current_customer.body_sprite else null
		if is_correct:
			dialogue_ui.show_dialogue(customer_tex, "Salamat bossing! +" + str(price) + " pesos")
		else:
			dialogue_ui.show_dialogue(customer_tex, "Hindi ako naghihintay nito... +" + str(price) + " pesos")
	
	# Clear the held item
	held_item = null
	held_item_label.visible = false

func _deliver_item_to_customer_with_price(price: int) -> void:
	"""Deliver item to customer with fixed price (for MVP)."""
	if current_customer == null:
		return
	
	# For MVP: always give money regardless of correct/wrong item
	add_money(price)
	
	# Show item texture on customer's bubble (if available)
	if current_customer.item_icon:
		current_customer.item_icon.visible = true
		# Load the texture based on the held item index
		var item_index = 0  # Default
		if held_item_label.text.begins_with("Holding Item #"):
			var parts = held_item_label.text.split("#")
			if parts.size() > 1:
				item_index = parts[1].to_int() - 1
		var texture = load("res://Assets/items/%d.png" % (item_index + 1))
		if texture:
			current_customer.item_icon.texture = texture
	
	# Show dialogue
	if dialogue_ui:
		var customer_tex = current_customer.body_sprite.texture if current_customer and current_customer.body_sprite else null
		dialogue_ui.show_dialogue(customer_tex, "Salamat bossing! +" + str(price) + " pesos")
	
	# Clear the held item label
	held_item = null
	held_item_label.visible = false
