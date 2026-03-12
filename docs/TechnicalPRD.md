# SARI-SARING KATHA
## Technical Product Requirements Document (PRD)

**Version:** 1.0  
**Date:** March 11, 2026  
**Author:** Technical Development Team  
**Classification:** Internal - Development

---

## 1. EXECUTIVE SUMMARY

### 1.1 Project Overview

**Sari-Saring Katha** is a cozy point-and-click store simulator game built on Godot Engine 4.6. The player inherits a sari-sari store in the fictional town of Karimlan, Philippines, where from supernatural beings Philippine mythology become customers. The core gameplay loop revolves around serving customers, managing store inventory, paying off debt to Queen Mayari, and uncovering the town's hidden history through character storylines.

### 1.2 Target Platform

| Platform | Priority | Rendering |
|----------|----------|-----------|
| Windows PC | P0 | Forward Plus (D3D12) |
| macOS | P1 | Vulkan |
| Linux | P2 | Vulkan |

### 1.3 Technical Stack

- **Engine:** Godot 4.6
- **Physics:** Jolt Physics (3D)
- **Language:** GDScript 2.0
- **Version Control:** Git
- **Build Target:** Desktop (primary)

---

## 2. SYSTEM ARCHITECTURE

### 2.1 Core Systems Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        MAIN GAME LOOP                          │
├─────────────────────────────────────────────────────────────────┤
│  Day Cycle System                                              │
│  ├── Morning Phase (Restocking)                                │
│  ├── Active Phase (Customer Service)                           │
│  └── Night Phase (Debt Collection)                              │
├─────────────────────────────────────────────────────────────────┤
│  Game State Manager                                            │
│  ├── Save/Load System                                          │
│  ├── Day Progression                                           │
│  └── Quest Progress                                            │
├─────────────────────────────────────────────────────────────────┤
│  Economy System                                                │
│  ├── Currency Management (Peso)                                │
│  ├── Debt Tracking (Queen Mayari)                             │
│  └── Price Customization                                       │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Module Dependencies

```
InputManager (Autoload)
    │
    ├── Keyboard Input → View Navigation (W/A/S/D)
    └── Global Input State

DragManager (Autoload)
    │
    ├── DraggableItem
    ├── TransactionTray
    └── Raycast System

GameStateManager
    │
    ├── CustomerQueue
    ├── InventorySystem
    └── DialogueSystem
```

---

## 3. PLAYER MOVEMENT & NAVIGATION

### 3.1 View Navigation System

The game uses a camera-based navigation system rather than character movement, as this is a point-and-click store simulator.

| Control | Action | Script |
|---------|--------|--------|
| W | Look Forward/Front View | InputManager.gd |
| S | Look Backward/Back View | InputManager.gd |
| A | Look Left View | InputManager.gd |
| D | Look Right View | InputManager.gd |
| R | Toggle Front/Back Store View | MainGame.gd |

### 3.2 Implementation Details

**InputManager.gd (Lines 5-15)**
```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_W:
                view_requested.emit("look_front")
            KEY_S:
                view_requested.emit("look_back")
            KEY_A:
                view_requested.emit("look_left")
            KEY_D:
                view_requested.emit("look_right")
```

**View States:**
- `look_front` - Storefront view (customer counter)
- `look_back` - Storage room view (fridge/freezer)
- `look_left` - Left shelf section
- `look_right` - Right shelf section

### 3.2 Character Movement Mode (FPS)

The game offers an optional First-Person Shooter (FPS) style character movement mode, allowing players to walk around the store environment instead of using fixed camera views. This mode provides a more immersive experience for exploring the store and interacting with the environment.

| Control | Action | Script |
|---------|--------|--------|
| W | Move Forward | PlayerController.gd |
| S | Move Backward | PlayerController.gd |
| A | Strafe Left | PlayerController.gd |
| D | Strafe Right | PlayerController.gd |
| Mouse Move | Look Around (Yaw/Pitch) | PlayerController.gd |
| Left Click | Interact / Pick up item | PlayerController.gd |
| Shift | Sprint (2x speed) | PlayerController.gd |
| Tab | Toggle Inventory | PlayerController.gd |
| ESC | Pause / Menu | PlayerController.gd |
| Tab | Toggle between Camera/FPS Mode | MainGame.gd |

**PlayerController.gd Implementation Details:**
```gdscript
class_name PlayerController
extends CharacterBody3D

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 10.0
@export var mouse_sensitivity: float = 0.002
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8

@onready var camera: Camera3D = $Camera3D

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera.rotate_x(-event.relative.y * mouse_sensitivity)
        camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    var speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    
    move_and_slide()
```

**Mode Toggle System:**
- Players can switch between Camera Mode and FPS Mode using the Tab key
- Camera Mode: Fixed view navigation (original point-and-click style)
- FPS Mode: Free-roaming character movement with mouse look
- Visual indicator in UI shows current mode
- Interaction system works identically in both modes (click to interact)

**Collision Layer for Player (Layer 6):**
| Layer | Name | Purpose |
|-------|------|---------|
| 6 | Player | Character body collision for FPS mode |

---

## 4. BASIC MECHANICS

### 4.1 Drag-and-Drop System

**DragManager.gd** - Core drag-and-drop system handling item interactions

| Method | Purpose |
|--------|---------|
| `start_drag(item, texture)` | Initialize drag operation |
| `_process(delta)` | Update drag position, calculate velocity |
| `end_drag()` | Complete drag, raycast for drop target |
| `_cancel_drag()` | Cancel and return item to origin |

**DraggableItem.gd** - Item that can be picked up and moved

| Method | Purpose |
|--------|---------|
| `_input_event()` | Detect mouse click on item |
| `setup(data)` | Initialize item with data |
| `return_to_start()` | Tween animation back to original position |

### 4.2 Transaction System

**TransactionTray.gd** - Handles item deposits for customer orders

| Method | Purpose |
|--------|---------|
| `receive_item(item)` | Accept item from player |
| `validate_transaction()` | Check if item matches customer request |
| `complete_sale()` | Process payment, update economy |

### 4.3 Dialogue System

**DialogueUI.gd** - Manages customer conversations

| Method | Purpose |
|--------|---------|
| `show_dialogue(character_id)` | Display dialogue UI |
| `advance_dialogue()` | Progress through dialogue tree |
| `select_option(option_id)` | Handle player choice |
| `_input(event)` | Detect input for dialogue progression |

### 4.4 Day Cycle System

**MainGame.gd** - Controls daily progression

| Method | Purpose |
|--------|---------|
| `_ready()` | Initialize game state |
| `start_day()` | Begin new day, spawn customers |
| `end_day()` | Close shop, process debt |
| `calculate_daily_quota()` | Determine Queen Mayari's payment |

---

## 5. NPC/ENEMY BEHAVIORS

### 5.1 Customer NPC System

**Customer.gd** - Base customer behavior

| Property | Type | Description |
|----------|------|-------------|
| `customer_id` | String | Unique identifier |
| `character_name` | String | Display name |
| `wanted_item` | ItemData | Current purchase request |
| `dialogue_tree` | Array | Conversation nodes |
| `story_progress` | int | Quest progression (0-100) |
| `mood` | Enum | Current mood state |

| Method | Purpose |
|--------|---------|
| `_ready()` | Initialize customer state |
| `request_item()` | Generate purchase request |
| `receive_item(item)` | Accept delivered item |
| `trigger_dialogue()` | Start conversation |
| `update_story_progress(delta)` | Advance quest line |

### 5.2 Enemy/Obstacle Behaviors

**Duwende Trio System**
- Spawn randomly during day
- Replace stock items with fake duplicates
- Behavior: Hide, replace item, wait for player click
- Counter: Click on Duwende sprite to remove

**Kiwig System**
- Shapeshifts into customer appearance
- Behavior: Mimic dialogue, request item, run away without payment
- Detection: Uncharacteristic dialogue traits
- Counter: "Accuse" dialogue option after first discovery

**Queen Mayari (Boss)**
- No direct combat
- Debt collection mechanic
- Night-phase appearance
- Difficulty scaling based on payment compliance

---

## 6. ENVIRONMENTAL INTERACTIONS

### 6.1 Interactive Objects

**Fridge.gd** - Refrigerator interaction

```gdscript
func _input_event(_camera, event, _position, _normal, _shape_idx):
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            toggle_open()
```

| Method | Purpose |
|--------|---------|
| `_input_event()` | Detect click interaction |
| `toggle_open()` | Open/close fridge |
| `get_items()` | Return list of frozen items |

**Shelf.gd** - Product display shelf

| Method | Purpose |
|--------|---------|
| `add_item(item)` | Place item on shelf |
| `remove_item(slot)` | Take item from slot |
| `get_item_at_position(pos)` | Raycast detection |

### 6.2 Phone/Ordering System

- Keypad phone near refrigerator
- Access Uncle Mario's ordering menu
- Cooldown system (prevents spam)
- Delivery animation (tricycle arrival)

### 6.3 Storage/Pantry Area

- Back room with fridge and freezer
- R key navigation from front
- Frozen item handling
- Auto-return to front when dragging item down

---

## 7. COLLISION DETECTION

### 7.1 Physics Configuration

**project.godot (Line 34)**
```
[physics]
3d/physics_engine="Jolt Physics"
```

### 7.2 Collision Layers

| Layer | Name | Purpose |
|-------|------|---------|
| 1 | World | Store environment geometry |
| 2 | Items | Draggable products |
| 3 | Customers | NPC collision volumes |
| 4 | Interactables | Buttons, triggers |
| 5 | TransactionTray | Drop target zone |
| 6 | Player | Character body collision for FPS mode |

### 7.3 Raycast System

**DragManager.gd (Lines 70-87)** - Item drop validation

```gdscript
var ray_origin = camera.project_ray_origin(mouse_pos)
var ray_dir = camera.project_ray_normal(mouse_pos)
var ray_length = 50.0
var ray_end = ray_origin + ray_dir * ray_length

var space_state = camera.get_world_3d().direct_space_state
var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
query.collide_with_areas = true
query.collide_with_bodies = false

var result = space_state.intersect_ray(query)
```

### 7.4 Item Collision

**DraggableItem.gd** - Uses Area3D for interaction detection

```gdscript
class_name DraggableItem
extends Area3D

@onready var collider: CollisionShape3D = $CollisionShape3D
```

---

## 8. DATA STRUCTURES

### 8.1 ItemData.gd

```gdscript
class_name ItemData
extends Resource

@export var item_name: String
@export var item_id: String
@export var price: int
@export var category: Enum (FOOD, DRINK, FROZEN, SACHET, CANDY)
@export var texture: Texture2D
@export var stock_quantity: int
@export var is_frozen: bool
```

### 8.2 Customer Data Structure

```gdscript
# Character Story Progression
story_flags: Dictionary = {
    "met_kuya_kap": false,
    "helped_kap_quit_smoking": false,
    "discovered_kap_secret": false,
    # ... per character
}

# Dialogue State
dialogue_index: int = 0
dialogue_options_selected: Array = []
```

### 8.3 Game Save Structure

```gdscript
# SaveData.gd
var save_data: Dictionary = {
    "current_day": 1,
    "peso": 0,
    "debt_remaining": 100000,
    "inventory": {},
    "customer_progress": {},
    "unlocks": [],
    "settings": {}
}
```

---

## 9. ECONOMY SYSTEM

### 9.1 Currency

| Currency | Symbol | Purpose |
|----------|--------|---------|
| Peso | ₱ | Primary transaction currency |

### 9.2 Debt System

| Parameter | Value |
|-----------|-------|
| Initial Debt | 100,000 Peso |
| Daily Quota Start | 1,000 Peso |
| Quota Increase | +100/day |
| Underpayment Penalty | +10% deficit to next day |
| Overpayment Bonus | -5% next quota |

### 9.3 Item Pricing

- MSRP (Manufacturer Suggested Retail Price)
- Player customization: 50% - 200% of MSRP
- Customer purchase probability decreases with higher prices

---

## 10. SCRIPT INVENTORY

### 10.1 Implemented Scripts (14 Total)

| # | Script Name | Lines | Category |
|---|-------------|-------|----------|
| 1 | InputManager.gd | 15 | Player Movement |
| 2 | PlayerController.gd | ~170 | Player Movement |
| 3 | DragManager.gd | 106 | Basic Mechanics |
| 3 | DraggableItem.gd | 52 | Environmental Interactions |
| 4 | TransactionTray.gd | - | Basic Mechanics |
| 5 | DialogueUI.gd | - | NPC Behaviors |
| 6 | Customer.gd | - | NPC Behaviors |
| 7 | Fridge.gd | - | Environmental Interactions |
| 8 | Shelf.gd | - | Environmental Interactions |
| 9 | MainGame.gd | - | Core Game Loop |
| 10 | ItemData.gd | - | Data Resource |
| 11 | GameStateManager.gd | TBD | State Management |
| 12 | EconomyManager.gd | TBD | Economy System |
| 13 | SaveSystem.gd | TBD | Persistence |

### 10.2 Required Additional Scripts

| # | Script Name | Purpose |
|---|-------------|---------|
| 1 | PlayerCamera.gd | Camera controller |
| 2 | DuwendeEnemy.gd | Enemy behavior |
| 3 | KiwigEnemy.gd | Enemy behavior |
| 4 | QueenMayari.gd | Boss behavior |
| 5 | PhoneOrderingSystem.gd | Ordering menu |
| 6 | InventoryUI.gd | Display management |
| 7 | DayNightCycle.gd | Time progression |
| 8 | StoryManager.gd | Quest tracking |
| 9 | SoundManager.gd | Audio control |
| 10 | SettingsManager.gd | Options menu |

---

## 11. RISKS & MITIGATION

| Risk | Probability | Impact | Mitigation |
|------|--------------|--------|-------------|
| Jolt Physics compatibility | Medium | High | Use Godot built-in physics fallback |
| Performance on low-end | Medium | Medium | Optimize 3D models, LOD system |
| Scope creep (story content) | High | Medium | Prioritize MVP features first |
| Save system complexity | Low | High | Implement incremental saves |
| Asset pipeline bottlenecks | Medium | Medium | Establish clear naming conventions |

---

## 12. SUCCESS CRITERIA

### 12.1 MVP (Minimum Viable Product)

- [ ] Core gameplay loop functional
- [ ] 3 customers implemented with dialogue
- [ ] Drag-and-drop item system working
- [ ] Basic economy (buy/sell) functional
- [ ] Day cycle with debt payment

### 12.2 Launch Requirements

- [ ] All customer storylines complete
- [ ] Duwende/Kiwig mechanics implemented
- [ ] Save/Load system functional
- [ ] Performance: 60 FPS on mid-range hardware
- [ ] Localization ready (Filipino/English)

---

## 13. APPENDIX

### A. GDD Reference
See [`GDD.txt`](GDD.txt) for complete game design document.

### B. Scene Hierarchy
```
MainGame.tscn
├── WorldEnvironment
├── DirectionalLight3D
├── Camera3D (Main)
├── StoreEnvironment
│   ├── Shelves
│   ├── Fridge
│   ├── Freezer
│   ├── TransactionCounter
│   └── TransactionTray
├── CustomerSpawnPoint
├── UI
│   ├── DialoguePanel
│   ├── InventoryHUD
│   └── PhoneMenu
└── Scripts attached
```

### C. Input Mapping
```
=== CAMERA MODE (Default) ===
W → look_front
S → look_back
A → look_left
D → look_right
R → toggle_store_view
Mouse Left Click → interact
Mouse Drag → pick up / move item
Mouse Release → drop item

=== FPS MODE (Character Movement) ===
W → move_forward
S → move_backward
A → strafe_left
D → strafe_right
Mouse Move → look_around
Left Click → interact / pick_up
Shift → sprint
Tab → toggle_inventory
ESC → pause_menu
Tab → toggle_camera_fps_mode

=== SHARED ===
F5 → Save Game
F9 → Load Game
```

---

**Document Approval:**
- Technical Lead: _________________
- Game Designer: _________________
- Producer: _________________

**Version History:**
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | March 11, 2026 | Dev Team | Initial PRD |
