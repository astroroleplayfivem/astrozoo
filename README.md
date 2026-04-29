# Astro Zoo

Astro Zoo updated for:
- **Frameworks:** QB-Core and ESX
- **Inventories:** qb-inventory, ox_inventory, tgiann-inventory, and default ESX inventory
- **Targets:** qb-target and ox_target

This build keeps your current zoo changes in place:
- elephant and croc exhibits removed
- ticket-only entry flow
- no shop ped
- static guards with rifles for visual security only
- lower music volume
- announcements every 3 hours
- broom and tray props on actions

## Setup

### 1) Pick your framework, inventory, and target in `shared/config.lua`

```lua
Config.Framework.Type = 'auto'   -- auto | qb | esx
Config.Inventory.Type = 'auto'   -- auto | qb | esx | ox | tgiann
Config.Target.Type = 'auto'      -- auto | qb | ox
```

Use `auto` if your server setup is clean. Set them manually if you want to force a specific combo.

### 2) Start order

For QB-Core:
- qb-core
- chosen inventory
- chosen target
- astro-zoo

For ESX:
- es_extended
- chosen inventory
- chosen target
- astro-zoo

### 3) SQL
Import:
- `sql/astro_zoo.sql`

## Notes on inventory compatibility

### qb-inventory
This build uses framework item checks/removals and server-side consumable handling.

### ox_inventory
This build supports ox item checks/removals server-side. For consumables, add the item definitions below with the provided `client.export` lines so ox can run the use effect properly. ox_inventory server item functions like `GetItemCount` and `RemoveItem`, and client item usage via `client.export`, are documented by Overextended. citeturn982117search0turn982117search13

### tgiann-inventory
This build supports tgiann item definitions in README format. TGIANN’s item docs show items can use `client.export`, `consume`, animations, props, and status effects in the item definition itself. TGIANN also notes many item features work similarly to ox_inventory. citeturn857777search0turn245752view0

## Notes on target compatibility

- `qb-target` uses box zones as before.
- `ox_target` support was added using `addBoxZone`, which officially accepts box zone parameters and target options. citeturn748769search5turn748769search1

## Items used by this script

### Required feed items
- `zoo_feed`
- `zoo_raw_meat`

### Optional visitor consumables
- `astrozoo_animal_crackers`
- `astrozoo_water`
- `astrozoo_soda`
- `astrozoo_burger`
- `astrozoo_hotdog`
- `astrozoo_cottoncandy`

### Optional membership item
- `zoo_membership`

No ticket item is required in this build.

---

# QB-Core / qb-inventory items

Put these in `qb-core/shared/items.lua`:

```lua
['zoo_feed'] = {
    ['name'] = 'zoo_feed',
    ['label'] = 'Zoo Feed',
    ['weight'] = 200,
    ['type'] = 'item',
    ['image'] = 'zoo_feed.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['description'] = 'Feed used for herbivore enclosures.'
},
['zoo_raw_meat'] = {
    ['name'] = 'zoo_raw_meat',
    ['label'] = 'Raw Meat',
    ['weight'] = 250,
    ['type'] = 'item',
    ['image'] = 'zoo_raw_meat.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['description'] = 'Raw meat used for predator enclosures.'
},
['zoo_membership'] = {
    ['name'] = 'zoo_membership',
    ['label'] = 'Zoo Membership',
    ['weight'] = 0,
    ['type'] = 'item',
    ['image'] = 'zoo_membership.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['description'] = 'Membership access for Astro Zoo.'
},
['astrozoo_animal_crackers'] = {
    ['name'] = 'astrozoo_animal_crackers',
    ['label'] = 'Animal Crackers',
    ['weight'] = 150,
    ['type'] = 'item',
    ['image'] = 'astrozoo_animal_crackers.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'A zoo snack.'
},
['astrozoo_water'] = {
    ['name'] = 'astrozoo_water',
    ['label'] = 'Water',
    ['weight'] = 150,
    ['type'] = 'item',
    ['image'] = 'astrozoo_water.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'A bottle of water.'
},
['astrozoo_soda'] = {
    ['name'] = 'astrozoo_soda',
    ['label'] = 'Soda',
    ['weight'] = 150,
    ['type'] = 'item',
    ['image'] = 'astrozoo_soda.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'A cold soda.'
},
['astrozoo_burger'] = {
    ['name'] = 'astrozoo_burger',
    ['label'] = 'Burger',
    ['weight'] = 200,
    ['type'] = 'item',
    ['image'] = 'astrozoo_burger.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'A burger from the zoo stand.'
},
['astrozoo_hotdog'] = {
    ['name'] = 'astrozoo_hotdog',
    ['label'] = 'Hotdog',
    ['weight'] = 180,
    ['type'] = 'item',
    ['image'] = 'astrozoo_hotdog.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'A hotdog from the zoo stand.'
},
['astrozoo_cottoncandy'] = {
    ['name'] = 'astrozoo_cottoncandy',
    ['label'] = 'Cotton Candy',
    ['weight'] = 120,
    ['type'] = 'item',
    ['image'] = 'astrozoo_cottoncandy.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'Sweet cotton candy.'
},
```

---

# ox_inventory items

Put these in `ox_inventory/data/items.lua`:

```lua
['zoo_feed'] = {
    label = 'Zoo Feed',
    weight = 200,
    stack = true,
    close = true,
    description = 'Feed used for herbivore enclosures.'
},
['zoo_raw_meat'] = {
    label = 'Raw Meat',
    weight = 250,
    stack = true,
    close = true,
    description = 'Raw meat used for predator enclosures.'
},
['zoo_membership'] = {
    label = 'Zoo Membership',
    weight = 0,
    stack = true,
    close = true,
    description = 'Membership access for Astro Zoo.'
},
['astrozoo_animal_crackers'] = {
    label = 'Animal Crackers',
    weight = 150,
    stack = true,
    close = true,
    consume = 1,
    client = { export = 'astro-zoo.useAnimalCrackers' },
    description = 'A zoo snack.'
},
['astrozoo_water'] = {
    label = 'Water',
    weight = 150,
    stack = true,
    close = true,
    consume = 1,
    client = { export = 'astro-zoo.useWater' },
    description = 'A bottle of water.'
},
['astrozoo_soda'] = {
    label = 'Soda',
    weight = 150,
    stack = true,
    close = true,
    consume = 1,
    client = { export = 'astro-zoo.useSoda' },
    description = 'A cold soda.'
},
['astrozoo_burger'] = {
    label = 'Burger',
    weight = 200,
    stack = true,
    close = true,
    consume = 1,
    client = { export = 'astro-zoo.useBurger' },
    description = 'A burger from the zoo stand.'
},
['astrozoo_hotdog'] = {
    label = 'Hotdog',
    weight = 180,
    stack = true,
    close = true,
    consume = 1,
    client = { export = 'astro-zoo.useHotdog' },
    description = 'A hotdog from the zoo stand.'
},
['astrozoo_cottoncandy'] = {
    label = 'Cotton Candy',
    weight = 120,
    stack = true,
    close = true,
    consume = 1,
    client = { export = 'astro-zoo.useCottonCandy' },
    description = 'Sweet cotton candy.'
},
```

---

# tgiann-inventory items

Put these in your tgiann items file. TGIANN’s docs show item definitions can include `useable`, `consume`, `client.export`, status/animation/prop fields, and that many features work similarly to ox_inventory. citeturn857777search0turn245752view0

```lua
zoo_feed = {
    label = 'Zoo Feed',
    weight = 200,
    type = 'item',
    image = 'zoo_feed.png',
    hasMetadata = false,
    useable = false,
    shouldClose = true,
    description = 'Feed used for herbivore enclosures.'
},
zoo_raw_meat = {
    label = 'Raw Meat',
    weight = 250,
    type = 'item',
    image = 'zoo_raw_meat.png',
    hasMetadata = false,
    useable = false,
    shouldClose = true,
    description = 'Raw meat used for predator enclosures.'
},
zoo_membership = {
    label = 'Zoo Membership',
    weight = 0,
    type = 'item',
    image = 'zoo_membership.png',
    hasMetadata = false,
    useable = false,
    shouldClose = true,
    description = 'Membership access for Astro Zoo.'
},
astrozoo_animal_crackers = {
    label = 'Animal Crackers',
    weight = 150,
    type = 'item',
    image = 'astrozoo_animal_crackers.png',
    hasMetadata = false,
    useable = true,
    shouldClose = true,
    description = 'A zoo snack.',
    consume = 1,
    client = {
        export = 'astro-zoo.useAnimalCrackers',
        usetime = 2500,
        cancel = true
    }
},
astrozoo_water = {
    label = 'Water',
    weight = 150,
    type = 'item',
    image = 'astrozoo_water.png',
    hasMetadata = false,
    useable = true,
    shouldClose = true,
    description = 'A bottle of water.',
    consume = 1,
    client = {
        export = 'astro-zoo.useWater',
        usetime = 2500,
        cancel = true
    }
},
astrozoo_soda = {
    label = 'Soda',
    weight = 150,
    type = 'item',
    image = 'astrozoo_soda.png',
    hasMetadata = false,
    useable = true,
    shouldClose = true,
    description = 'A cold soda.',
    consume = 1,
    client = {
        export = 'astro-zoo.useSoda',
        usetime = 2500,
        cancel = true
    }
},
astrozoo_burger = {
    label = 'Burger',
    weight = 200,
    type = 'item',
    image = 'astrozoo_burger.png',
    hasMetadata = false,
    useable = true,
    shouldClose = true,
    description = 'A burger from the zoo stand.',
    consume = 1,
    client = {
        export = 'astro-zoo.useBurger',
        usetime = 2500,
        cancel = true
    }
},
astrozoo_hotdog = {
    label = 'Hotdog',
    weight = 180,
    type = 'item',
    image = 'astrozoo_hotdog.png',
    hasMetadata = false,
    useable = true,
    shouldClose = true,
    description = 'A hotdog from the zoo stand.',
    consume = 1,
    client = {
        export = 'astro-zoo.useHotdog',
        usetime = 2500,
        cancel = true
    }
},
astrozoo_cottoncandy = {
    label = 'Cotton Candy',
    weight = 120,
    type = 'item',
    image = 'astrozoo_cottoncandy.png',
    hasMetadata = false,
    useable = true,
    shouldClose = true,
    description = 'Sweet cotton candy.',
    consume = 1,
    client = {
        export = 'astro-zoo.useCottonCandy',
        usetime = 2500,
        cancel = true
    }
},
```

---

# ESX notes

For default ESX inventory, define the items in your item database or item config as usual. This resource handles ticket purchase, access checks, feed item checks/removals, and status updates server-side. For ESX usable consumables, the script updates `esx_status` hunger/thirst when the item use export/event is triggered. Official ESX docs cover the framework itself; usable item patterns and inventory details can vary by ESX install, so use your server’s normal item-registration method. citeturn748769search10turn748769search6

## What changed in this compatibility pass
- added QB-Core + ESX framework support
- added qb-inventory, ox_inventory, tgiann-inventory, and ESX inventory support paths
- added qb-target + ox_target support
- removed the separate item example files
- moved all item setup into this README
- kept the rest of your current zoo changes intact
