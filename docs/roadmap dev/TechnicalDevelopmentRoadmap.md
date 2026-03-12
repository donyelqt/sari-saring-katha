# SARI-SARING KATHA
## Technical Development Roadmap

**Version:** 1.0  
**Last Updated:** March 11, 2026  
**Phase:** Pre-Production → Production → Post-Launch

---

## 1. ROADMAP OVERVIEW

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DEVELOPMENT TIMELINE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PRE-PRODUCTION    │    PRODUCTION           │    POST-LAUNCH             │
│  (Month 1-2)       │    (Month 3-8)          │    (Month 9+)              │
│                                                                             │
│  ┌─────────────┐   │  ┌──────────────────┐   │  ┌──────────────────┐       │
│  │ Foundation  │◄──┤  │ Core Features    │◄──┤  │ Polish & Release│       │
│  │ & Core Sys  │   │  │ Implementation   │   │  │                  │       │
│  └─────────────┘   │  └──────────────────┘   │  └──────────────────┘       │
│         │           │         │                │         │                  │
│         ▼           │         ▼                │         ▼                  │
│  ┌─────────────┐   │  ┌──────────────────┐   │  ┌──────────────────┐       │
│  │ Prototype   │◄──┤  │ Content           │◄──┤  │ Updates          │       │
│  │ MVP         │   │  │ Expansion        │   │  │ & Support        │       │
│  └─────────────┘   │  └──────────────────┘   │  └──────────────────┘       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. PHASE 1: PRE-PRODUCTION (Weeks 1-8)

### 2.1 Foundation & Core Systems

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 1 | Project Setup | Godot project initialized, Git repo configured | Dev |
| 1 | Engine Configuration | Input mapping, project settings, Jolt Physics | Dev |
| 2 | Scene Template | MainGame.tscn base scene with environment | Dev |
| 2 | Basic Camera System | Camera controller with view states | Dev |
| 3 | InputManager Implementation | Keyboard handling (WASD + R) | Dev |
| 3 | PlayerController Implementation | FPS character movement with mouse look | Dev |
| 3 | DragManager Core | Basic drag-drop foundation | Dev |
| 4 | Physics Setup | Collision layers, raycast system | Dev |
| 4 | Asset Pipeline | Blender → Godot import workflow | Art |
| 5 | Environment Blockout | Basic store geometry (placeholder) | Art |
| 5 | ItemData System | Resource-based item definitions | Dev |
| 6 | DraggableItem Implementation | Pick up/drop functionality | Dev |
| 6 | TransactionTray System | Basic sale completion | Dev |
| 7 | MVP Prototype Test | Playable core loop | QA |
| 8 | Polish & Bug Fix | Prototype refinement | Dev |

### 2.2 Pre-Production Milestones

- [ ] **M1.1:** Project builds and runs without errors
- [ ] **M1.2:** Camera navigation functional (4 views)
- [ ] **M1.3:** Character/FPS movement mode functional
- [ ] **M1.4:** Can pick up item and drop on tray
- [ ] **M1.5:** Basic transaction (item → money) works

---

## 3. PHASE 2: PRODUCTION - CORE (Weeks 9-16)

### 3.1 Core Gameplay Implementation

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 9 | Customer Base Class | Customer.gd with state machine | Dev |
| 9 | Customer Spawn System | Queue and spawning logic | Dev |
| 10 | DialogueUI Implementation | UI framework for conversations | Dev |
| 10 | Dialogue Tree System | Data-driven dialogue structure | Dev |
| 10 | Day Cycle System | Morning/Active/Night phases | Dev |
| 11 | Economy Manager | Currency and debt tracking | Dev |
| 11 | Inventory UI | Stock display and management | Dev |
| 12 | Fridge/Freezer System | Cold storage interaction | Dev |
| 12 | Shelf System | Product placement and retrieval | Dev |
| 13 | Phone Ordering System | Uncle Mario menu interface | Dev |
| 13 | Restocking Mechanics | Item delivery workflow | Dev |
| 14 | Story Flag System | Quest progression tracking | Dev |
| 14 | Customer Request Generation | Dynamic item requests | Dev |
| 15 | Save/Load System | Persistent game state | Dev |
| 16 | Core Feature Complete | Full MVP playable | QA |

### 3.2 Production Core Milestones

- [ ] **M2.1:** Can serve customers with correct items
- [ ] **M2.2:** Dialogue system functional with choices
- [ ] **M2.3:** Day cycle progresses correctly
- [ ] **M2.4:** Economy tracks money and debt
- [ ] **M2.5:** Save/Load functional

---

## 4. PHASE 3: PRODUCTION - CONTENT (Weeks 17-24)

### 4.1 NPC Characters

| Week | Character | Features | Owner |
|------|-----------|----------|-------|
| 17 | Kuya Kap | Model, dialogue, story triggers | Art/Dev |
| 18 | Manang Ana | Model, dialogue, loan mechanic | Art/Dev |
| 19 | T.K. (Travel Vlogger) | Model, location selection | Art/Dev |
| 20 | Supporting NPCs (3-4) | Background characters | Art/Dev |
| 21 | All Characters Complete | All 7+ NPCs implemented | QA |

### 4.2 Enemy/Obstacle Systems

| Week | Entity | Features | Owner |
|------|--------|----------|-------|
| 21 | Duwende Trio | Spawn, item replacement, click removal | Dev |
| 22 | Kiwig | Shapeshift, dialogue mimic, theft | Dev |
| 23 | Queen Mayari | Debt collection, night appearance | Dev |
| 24 | Enemy Systems Complete | All obstacles functional | QA |

### 4.3 Content Expansion Milestones

- [ ] **M3.1:** 5+ fully voiced NPCs
- [ ] **M3.2:** Duwende mechanic working
- [ ] **M3.3:** Kiwig detection system working
- [ ] **M3.4:** Queen Mayari debt system complete

---

## 5. PHASE 4: PRODUCTION - POLISH (Weeks 25-30)

### 5.1 Visual & Audio Polish

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 25 | Environment Art | Final store models, textures | Art |
| 25 | Character Art | Final character models, portraits | Art |
| 26 | VFX Implementation | Particle effects, animations | Dev |
| 26 | UI Polish | HUD, menus, transitions | Dev |
| 27 | Sound Design | SFX for interactions | Audio |
| 27 | Music Implementation | Background themes per phase | Audio |
| 28 | Localization Setup | Filipino/English text ready | Dev |

### 5.2 Performance & Optimization

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 28 | Performance Profiling | 60 FPS target verified | Dev |
| 28 | Memory Optimization | Asset streaming implemented | Dev |
| 29 | Bug Fixing | All critical/major bugs resolved | QA |
| 29 | Playtesting | External beta feedback | QA |
| 30 | Final QA Pass | Release candidate | QA |

### 5.3 Polish Milestones

- [ ] **M4.1:** All assets finalized
- [ ] **M4.2:** Performance targets met
- [ ] **M4.3:** No critical bugs
- [ ] **M4.4:** Beta feedback incorporated

---

## 6. PHASE 5: POST-LAUNCH (Ongoing)

### 6.1 Launch Preparation

| Task | Timeline | Owner |
|------|-----------|-------|
| Store Page Creation | Week 31 | Marketing |
| Trailer/Preview Release | Week 31 | Marketing |
| Launch Day Support | Week 32 | Dev |
| Hotfix Availability | Week 32 | Dev |

### 6.2 Post-Launch Content

| Content | ETA | Priority |
|---------|-----|----------|
| Bug Fixes | Immediate | P0 |
| Performance Updates | Month 3 | P1 |
| New Customer Stories | Month 4-6 | P2 |
| Seasonal Events | Month 6+ | P3 |

---

## 7. SCRIPT IMPLEMENTATION ROADMAP

### 7.1 Existing Scripts (Already Implemented)

| Script | Status | Lines | Priority |
|--------|--------|-------|----------|
| InputManager.gd | ✅ Complete | 15 | P0 |
| PlayerController.gd | ✅ Complete | ~170 | P0 |
| DragManager.gd | ✅ Complete | 106 | P0 |
| DraggableItem.gd | ✅ Complete | 52 | P0 |
| TransactionTray.gd | ✅ Complete | ~30 | P0 |
| DialogueUI.gd | ✅ Complete | ~40 | P0 |
| Customer.gd | ✅ Complete | ~80 | P0 |
| Fridge.gd | ✅ Complete | ~30 | P0 |
| MainGame.gd | ✅ Complete | ~200 | P0 |
| ItemData.gd | ✅ Complete | ~15 | P0 |

### 7.2 Scripts to Implement

| Script | Phase | Week | Dependencies |
|--------|-------|------|--------------|
| PlayerCamera.gd | Pre-Prod | 2 | InputManager |
| Shelf.gd | Pre-Prod | 5 | DraggableItem |
| EconomyManager.gd | Core | 11 | ItemData |
| DayCycleManager.gd | Core | 10 | MainGame |
| InventoryUI.gd | Core | 11 | ItemData |
| StoryManager.gd | Core | 14 | Customer |
| SaveSystem.gd | Core | 15 | All |
| PhoneOrderingSystem.gd | Core | 13 | UI |
| DuwendeEnemy.gd | Content | 21 | Customer |
| KiwigEnemy.gd | Content | 22 | Customer |
| QueenMayari.gd | Content | 23 | Economy |
| SoundManager.gd | Polish | 27 | - |
| SettingsManager.gd | Polish | 29 | - |

---

## 8. TECHNICAL REQUIREMENTS MATRIX

### 8.1 University Assignment Requirements

| Category | Requirement | Script(s) | Status |
|----------|--------------|-----------|--------|
| **Player Movement** | Camera navigation (W/A/S/D) | InputManager.gd | ✅ |
| | View switching (R key) | MainGame.gd | ✅ |
| | Character/FPS movement mode | PlayerController.gd | ✅ |
| **Basic Mechanics** | Item dragging | DragManager.gd | ✅ |
| | Transaction system | TransactionTray.gd | ✅ |
| | Dialogue system | DialogueUI.gd | ✅ |
| | Day progression | MainGame.gd | ✅ |
| **NPC/Enemy Behaviors** | Customer spawning | Customer.gd | ✅ |
| | Customer requests | Customer.gd | ✅ |
| | Dialogue interaction | DialogueUI.gd | ✅ |
| | Enemy (Duwende) - future | DuwendeEnemy.gd | ⏳ |
| | Enemy (Kiwig) - future | KiwigEnemy.gd | ⏳ |
| **Environmental Interactions** | Item pickup | DraggableItem.gd | ✅ |
| | Fridge interaction | Fridge.gd | ✅ |
| | Shelf placement | Shelf.gd | ⏳ |
| **Collision Detection** | Raycast dropping | DragManager.gd | ✅ |
| | Area detection | DraggableItem.gd | ✅ |
| | Physics layers | project.godot | ✅ |

### 8.2 Script Count Summary

| Category | Current | Required | Status |
|----------|---------|----------|--------|
| Player Movement | 2 | 1 | ✅ Complete |
| Basic Mechanics | 4 | 3+ | ✅ Complete |
| NPC/Enemy Behaviors | 2 | 2+ | ✅ Complete |
| Environmental Interactions | 2 | 2+ | ✅ Complete |
| Collision Detection | 2 | 1+ | ✅ Complete |
| **TOTAL** | **12** | **9+** | **✅** |

---

## 9. RESOURCE ALLOCATION

### 9.1 Team Structure (Recommended)

| Role | FTE | Responsibilities |
|------|-----|-------------------|
| Lead Developer | 1.0 | Architecture, core systems |
| Gameplay Developer | 1.0 | Mechanics, UI |
| 3D Artist | 1.0 | Environment, props |
| 2D Artist | 0.5 | UI, portraits |
| Audio | 0.25 | SFX, music |
| QA | 0.5 | Testing |

### 9.2 Asset Requirements

| Category | Current | Needed |
|----------|---------|--------|
| 3D Models (Store) | 1 | 15+ |
| 3D Models (Items) | 33 | 100+ |
| Character Models | 0 | 7+ |
| Character Portraits | 0 | 50+ |
| Sound Effects | 0 | 100+ |
| Music Tracks | 0 | 5+ |

---

## 10. RISK MITIGATION STRATEGY

| Risk | Mitigation | Contingency |
|------|------------|-------------|
| Jolt Physics crashes | Test frequently, keep fallback | Use Godot physics |
| Scope creep | Stick to MVP, defer features | Cut scope |
| Art delays | Prioritize gameplay-critical | Use placeholders |
| Bug overload | Daily builds, early QA | Extend timeline |
| Performance issues | Profile early, optimize | Reduce fidelity |

---

## 11. MILESTONE CHECKLIST

### Pre-Production (Week 8)
- [ ] Project builds without errors
- [ ] Camera navigation works
- [ ] Drag-drop core functional
- [ ] Basic prototype playable

### Production Core (Week 16)
- [ ] Customer system works
- [ ] Dialogue functional
- [ ] Economy running
- [ ] Save/Load works

### Production Content (Week 24)
- [ ] All NPCs implemented
- [ ] Enemy systems work
- [ ] Story complete

### Polish (Week 30)
- [ ] All assets in
- [ ] 60 FPS performance
- [ ] Zero critical bugs
- [ ] Release candidate ready

---

## 12. APPENDIX

### A. Key Dependencies
- Godot 4.6+
- Jolt Physics (Godot 4.6 compatible)
- Git LFS for large assets

### B. Reference Documents
- [`GDD.txt`](../../GDD.txt) - Game Design Document
- [`TechnicalPRD.md`](../TechnicalPRD.md) - Technical PRD
- [`project.godot`](../../project.godot) - Project configuration

### C. Contact
For technical questions, refer to the Technical Lead.

---

**Document Control:**
- Created: March 11, 2026
- Status: Active
- Review: Bi-weekly

**Next Review Date:** [To be scheduled]
