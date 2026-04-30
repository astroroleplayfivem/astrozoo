# Astro Zoo

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
``

Download : https://github.com/elajnabe/flight-animals.  These have the stream files so the animals spawn. If any animals have texture issues, just replace them with animals that dont have then and edit html/config files.

