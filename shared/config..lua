Config = {}

local vec3 = vec3
local vec4 = vec4

local function ShopItem(name, price, amount, slot)
    return {
        name = name,
        price = price,
        amount = amount,
        info = {},
        type = 'item',
        slot = slot
    }
end

local function MakePen(data)
    return {
        label = data.label,
        species = data.species,
        model = data.model,
        type = data.type,

        allowFeed = data.allowFeed,
        allowObserve = data.allowObserve,
        foodItem = data.foodItem,

        habitat = data.habitat,
        diet = data.diet,
        temperament = data.temperament,
        danger = data.danger,
        summary = data.summary,
        facts = data.facts,

        board = {
            coords = data.board.coords,
            zone = data.board.zone,
            length = data.board.length,
            width = data.board.width,
            heading = data.board.heading,
            minZ = data.board.minZ,
            maxZ = data.board.maxZ
        },

        center = data.center,
        radius = data.radius,
        pedCoords = data.pedCoords,
        escapePoints = data.escapePoints
    }
end

Config.Core = {
    Debug = false,
    ResourceName = 'astro-zoo',
    TargetDistance = 2.0
}

Config.Stats = {
    DefaultMood = 82,
    DefaultHunger = 76,
    DefaultHydration = 78,
    DefaultCleanliness = 84,
    DefaultStimulation = 80,
    Min = 0,
    Max = 100,
    DecayMinutes = 18
}

Config.Access = {
    AccessRequired = true,
    RewardMoneyType = 'cash'
}

Config.Tickets = {
    Price = 250,
    DurationMinutes = 120
}

Config.Cooldowns = {
    FeedSeconds = 75,
    ObserveSeconds = 30
}

Config.Features = {
    EnableBlip = true,
    EnableEscapes = false,
    EnableAmbientAnnouncements = true
}

Config.Environment = {
    AnnouncementIntervalMinutes = 180,
    AmbientMusic = {
        Enabled = true,
        Radius = 180.0,
        Volume = 3,
        SourceType = 'youtube', -- 'youtube' or 'direct'
        YouTubeId = 'Amh5NZMkf3I',
        DirectUrl = '',
        FadeMs = 2500
    }
}

Config.Escapes = {
    CheckMinutes = 7,
    ReturnSeconds = 90
}

Config.Props = {
    BoardProp = 'prop_tourist_map_01'
}

Config.Items = {
    MemberPass = 'zoo_membership',
    EntryReceipt = '',
    Feed = 'zoo_feed',
    RawMeat = 'zoo_raw_meat',

    AnimalSnack = 'astrozoo_animal_crackers',
    Water = 'astrozoo_water',
    Soda = 'astrozoo_soda',
    Burger = 'astrozoo_burger',
    Hotdog = 'astrozoo_hotdog',
    CottonCandy = 'astrozoo_cottoncandy'
}

Config.Peds = {
    Ticket = {
        model = 's_m_m_highsec_01',
        coords = vec4(1319.99, 1100.81, 105.88, 21.31)
    },
    Guards = {
        { model = 's_m_m_highsec_01', coords = vec4(1330.12, 1123.76, 108.46, 192.65) },
        { model = 's_m_m_highsec_01', coords = vec4(1332.74, 1123.11, 108.46, 192.65) }
    }
}

Config.Blip = {
    coords = vec3(1425.0, 1108.0, 114.33),
    sprite = 141,
    color = 2,
    scale = 0.85,
    label = 'Astro Zoo'
}


Config.BehaviorProfiles = {
    friendly = {
        wanderMin = 10,
        wanderMax = 22,
        restMin = 10,
        restMax = 18,
        movement = 1.0,
        escapeEnabled = true,
        statePool = {
            'Resting',
            'Curious',
            'Playing',
            'Watching visitors'
        }
    },

    gentle = {
        wanderMin = 12,
        wanderMax = 26,
        restMin = 12,
        restMax = 20,
        movement = 1.0,
        escapeEnabled = true,
        statePool = {
            'Grazing',
            'Resting',
            'Calm',
            'Slowly roaming'
        }
    },

    watch = {
        wanderMin = 10,
        wanderMax = 20,
        restMin = 9,
        restMax = 16,
        movement = 1.1,
        escapeEnabled = false,
        statePool = {
            'Watching',
            'Pacing',
            'Sniffing the ground',
            'Settled'
        }
    },

    danger = {
        wanderMin = 12,
        wanderMax = 24,
        restMin = 8,
        restMax = 15,
        movement = 1.15,
        escapeEnabled = true,
        statePool = {
            'Alert',
            'Pacing',
            'Resting',
            'Watching the enclosure edge'
        }
    }
}

Config.AnimalPens = {
    cat = MakePen({
        label = 'Cat House',
        species = 'Cat',
        model = 'a_c_cat_01',
        type = 'friendly',
        allowFeed = true,
        allowObserve = true,
        foodItem = Config.Items.Feed,
        habitat = 'Sheltered comfort enclosure',
        diet = 'Soft feed and treats',
        temperament = 'Friendly',
        danger = 'Low',
        summary = 'A quiet cat enclosure focused on comfort, lounging, and soft visitor interaction.',
        facts = {
            'Cats spend much of the day resting between short periods of curiosity.',
            'Higher stimulation keeps them more active in the enclosure.',
            'This is one of the most visitor-friendly exhibits in the zoo.'
        },
        board = {
            coords = vec4(1429.65, 1108.78, 114.19, 266.97),
            zone = vec3(1429.65, 1108.78, 114.19),
            length = 1.0,
            width = 1.2,
            heading = 0.0,
            minZ = 113.4,
            maxZ = 116.4
        },
        center = vec3(1423.78, 1112.21, 114.46),
        radius = 4.0,
        pedCoords = {
            vec4(1424.87, 1114.25, 114.46, 220.86),
            vec4(1422.34, 1109.72, 114.47, 345.31),
            vec4(1423.78, 1112.21, 114.46, 112.40)
        },
        escapePoints = {
            vec4(1420.50, 1113.80, 114.46, 180.0),
            vec4(1419.90, 1111.50, 114.46, 90.0)
        }
    }),

    dog = MakePen({
        label = 'Dog Yard',
        species = 'Dog',
        model = 'a_c_retriever',
        type = 'friendly',
        allowFeed = true,
        allowObserve = true,
        foodItem = Config.Items.Feed,
        habitat = 'Open social enclosure',
        diet = 'General feed and treats',
        temperament = 'Playful',
        danger = 'Low',
        summary = 'A social dog yard with active movement and visitor-friendly behavior.',
        facts = {
            'Dogs are one of the easiest animals for visitors to enjoy from the board area.',
            'They become more active after feeding.',
            'Low cleanliness makes them settle down faster.'
        },
        board = {
            coords = vec4(1429.68, 1120.21, 114.22, 284.84),
            zone = vec3(1429.68, 1120.21, 114.22),
            length = 1.0,
            width = 1.2,
            heading = 0.0,
            minZ = 113.3,
            maxZ = 116.5
        },
        center = vec3(1426.25, 1119.51, 114.43),
        radius = 4.0,
        pedCoords = {
            vec4(1426.19, 1122.55, 114.39, 161.51),
            vec4(1426.25, 1119.51, 114.43, 232.14),
            vec4(1428.04, 1121.02, 114.40, 96.25)
        },
        escapePoints = {
            vec4(1429.30, 1120.20, 114.40, 160.0),
            vec4(1430.20, 1118.90, 114.40, 240.0)
        }
    }),

    deer = MakePen({
        label = 'Deer Meadow',
        species = 'Deer',
        model = 'a_c_deer',
        type = 'gentle',
        allowFeed = true,
        allowObserve = true,
        foodItem = Config.Items.Feed,
        habitat = 'Meadow enclosure',
        diet = 'Feed pellets and greens',
        temperament = 'Calm',
        danger = 'Low',
        summary = 'A wide meadow exhibit designed for grazing, slow roaming, and peaceful viewing.',
        facts = {
            'Deer become more active during daylight periods.',
            'They respond better to quiet viewing than crowding the fence.',
            'This enclosure looks best when mood and cleanliness stay high.'
        },
        board = {
            coords = vec4(1445.14, 1078.09, 114.33, 28.18),
            zone = vec3(1445.14, 1078.09, 114.33),
            length = 1.2,
            width = 1.2,
            heading = 322.0,
            minZ = 113.2,
            maxZ = 116.4
        },
        center = vec3(1445.0, 1070.3, 114.34),
        radius = 6.0,
        pedCoords = {
            vec4(1448.38, 1071.14, 114.33, 331.93),
            vec4(1443.64, 1070.75, 114.34, 98.45),
            vec4(1446.22, 1068.90, 114.34, 205.10)
        },
        escapePoints = {
            vec4(1450.30, 1075.20, 114.33, 20.0),
            vec4(1439.70, 1074.50, 114.34, 290.0)
        }
    }),

    

    lion = MakePen({
        label = 'Lion Habitat',
        species = 'Lion',
        model = 'Malelion',
        type = 'danger',
        allowFeed = true,
        allowObserve = true,
        foodItem = Config.Items.RawMeat,
        habitat = 'Rocky cat enclosure',
        diet = 'Raw meat',
        temperament = 'Territorial',
        danger = 'High',
        summary = 'A predator habitat built around pacing, resting, and high-alert viewing behavior.',
        facts = {
            'This exhibit uses the custom lion ped.',
            'Lions become restless when stimulation drops.',
            'Observation is the safest way to experience this enclosure.'
        },
        board = {
            coords = vec4(1424.65, 1081.75, 114.22, 272.91),
            zone = vec3(1424.65, 1081.75, 114.22),
            length = 1.2,
            width = 1.2,
            heading = 55.0,
            minZ = 113.2,
            maxZ = 116.4
        },
        center = vec3(1421.65, 1077.85, 114.33),
        radius = 4.5,
        pedCoords = {
            vec4(1421.70, 1076.81, 114.33, 322.55),
            vec4(1419.36, 1078.15, 114.33, 279.18),
            vec4(1423.88, 1078.61, 114.33, 6.50)
        },
        escapePoints = {
            vec4(1425.10, 1075.10, 114.33, 40.0),
            vec4(1417.80, 1080.80, 114.33, 240.0)
        }
    }),

    tiger = MakePen({
        label = 'Tiger Habitat',
        species = 'Big Cat Exhibit',
        model = 'a_c_mtlion',
        type = 'danger',
        allowFeed = true,
        allowObserve = true,
        foodItem = Config.Items.RawMeat,
        habitat = 'Predator ridge',
        diet = 'Raw meat',
        temperament = 'Alert',
        danger = 'High',
        summary = 'This enclosure is set up as a big-cat viewing area until a dedicated tiger model is added.',
        facts = {
            'The uploaded animal pack did not include a tiger model.',
            'This enclosure still behaves like a dangerous predator exhibit.',
            'The board shows full enclosure details without targeting the animals.'
        },
        board = {
            coords = vec4(1415.16, 1082.5, 114.33, 13.04),
            zone = vec3(1415.16, 1082.5, 114.33),
            length = 1.2,
            width = 1.2,
            heading = 40.0,
            minZ = 113.2,
            maxZ = 116.4
        },
        center = vec3(1414.5, 1081.0, 114.33),
        radius = 4.5,
        pedCoords = {
            vec4(1414.39, 1079.55, 114.33, 4.07),
            vec4(1416.18, 1081.26, 114.33, 41.77),
            vec4(1412.54, 1082.16, 114.33, 335.60)
        },
        escapePoints = {
            vec4(1410.60, 1084.80, 114.33, 320.0),
            vec4(1417.10, 1084.20, 114.33, 170.0)
        }
    }),

    boar = MakePen({
        label = 'Boar Ridge',
        species = 'Boar',
        model = 'a_c_boar',
        type = 'watch',
        allowFeed = true,
        allowObserve = true,
        foodItem = Config.Items.Feed,
        habitat = 'Rough ground enclosure',
        diet = 'Mixed feed',
        temperament = 'Guarded',
        danger = 'Medium',
        summary = 'A rough wildlife pen made for viewing and fence-side feeding.',
        facts = {
            'Boars spend a lot of time rooting around the ground.',
            'This enclosure is more active when stimulation stays high.',
            'Visitors should keep viewing calm and steady.'
        },
        board = {
            coords = vec4(1407.42, 1081.68, 114.33, 273.74),
            zone = vec3(1407.42, 1081.68, 114.33),
            length = 1.2,
            width = 1.2,
            heading = 25.0,
            minZ = 113.2,
            maxZ = 116.4
        },
        center = vec3(1403.4, 1082.0, 114.33),
        radius = 4.5,
        pedCoords = {
            vec4(1403.40, 1080.72, 114.33, 342.92),
            vec4(1401.66, 1082.94, 114.33, 74.14),
            vec4(1405.71, 1083.11, 114.33, 293.10)
        },
        escapePoints = {
            vec4(1398.90, 1085.60, 114.33, 280.0),
            vec4(1407.40, 1085.10, 114.33, 120.0)
        }
    }),

    

    redpanda = MakePen({
        label = 'Red Panda Grove',
        species = 'Red Panda',
        model = 'RedPanda',
        type = 'friendly',
        allowFeed = true,
        allowObserve = true,
        foodItem = Config.Items.Feed,
        habitat = 'Light wooded enclosure',
        diet = 'Treat feed and fruit mix',
        temperament = 'Shy',
        danger = 'Low',
        summary = 'A smaller custom enclosure focused on cute viewing, resting, and short movements between shaded spots.',
        facts = {
            'This enclosure uses the custom red panda model.',
            'Red pandas spend long stretches resting between short bursts of movement.',
            'Quiet viewing improves the exhibit feel the most.'
        },
        board = {
            coords = vec4(1425.01, 1098.49, 114.41, 283.05),
            zone = vec3(1425.01, 1098.49, 114.41),
            length = 1.1,
            width = 1.1,
            heading = 186.41,
            minZ = 113.2,
            maxZ = 116.5
        },
        center = vec3(1420.7, 1095.7, 114.36),
        radius = 4.0,
        pedCoords = {
            vec4(1420.68, 1095.85, 114.36, 186.41),
            vec4(1422.34, 1094.72, 114.36, 232.10),
            vec4(1418.91, 1094.46, 114.36, 118.55),
            vec4(1421.72, 1097.64, 114.36, 341.20)
        },
        escapePoints = {
            vec4(1418.10, 1098.90, 114.36, 340.0),
            vec4(1423.20, 1098.30, 114.36, 190.0)
        }
    }),

    wolf = MakePen({
        label = 'Wolf Run',
        species = 'Wolf',
        model = 'wolf',
        type = 'danger',
        allowFeed = true,
        allowObserve = true,
        foodItem = Config.Items.RawMeat,
        habitat = 'Pack enclosure',
        diet = 'Raw meat',
        temperament = 'Alert',
        danger = 'High',
        summary = 'A pack-style custom exhibit with active pacing, alert turning, and rare controlled escape events.',
        facts = {
            'This enclosure uses the custom wolf model.',
            'Wolves feel more alive when they have enough space and stimulation.',
            'Low mood makes this one of the most restless exhibits in the zoo.'
        },
        board = {
            coords = vec4(1405.87, 1086.59, 114.33, 185.92),
            zone = vec3(1405.87, 1086.59, 114.33),
            length = 1.2,
            width = 1.2,
            heading = 200.91,
            minZ = 113.2,
            maxZ = 116.5
        },
        center = vec3(1398.0, 1094.6, 114.33),
        radius = 5.5,
        pedCoords = {
            vec4(1398.2, 1094.23, 114.33, 200.91),
            vec4(1400.44, 1095.85, 114.33, 159.40),
            vec4(1395.76, 1096.18, 114.33, 248.15),
            vec4(1397.61, 1091.74, 114.33, 19.25)
        },
        escapePoints = {
            vec4(1392.80, 1098.60, 114.33, 270.0),
            vec4(1403.20, 1091.70, 114.33, 80.0)
        }
    })
}



-- Backward-compatible flat keys used by the existing client/server code.
Config.Debug = Config.Core.Debug
Config.ResourceName = Config.Core.ResourceName
Config.TargetDistance = Config.Core.TargetDistance
Config.DefaultMood = Config.Stats.DefaultMood
Config.DefaultHunger = Config.Stats.DefaultHunger
Config.DefaultHydration = Config.Stats.DefaultHydration
Config.DefaultCleanliness = Config.Stats.DefaultCleanliness
Config.DefaultStimulation = Config.Stats.DefaultStimulation
Config.MinStat = Config.Stats.Min
Config.MaxStat = Config.Stats.Max
Config.DecayMinutes = Config.Stats.DecayMinutes
Config.AccessRequired = Config.Access.AccessRequired
Config.RewardMoneyType = Config.Access.RewardMoneyType
Config.TicketPrice = Config.Tickets.Price
Config.TicketDurationMinutes = Config.Tickets.DurationMinutes
Config.FeedCooldownSeconds = Config.Cooldowns.FeedSeconds
Config.ObserveCooldownSeconds = Config.Cooldowns.ObserveSeconds
Config.EnableBlip = Config.Features.EnableBlip
Config.EnableEscapes = Config.Features.EnableEscapes
Config.EnableAmbientAnnouncements = Config.Features.EnableAmbientAnnouncements
Config.AnnouncementIntervalMinutes = Config.Environment.AnnouncementIntervalMinutes
Config.AmbientMusic = Config.Environment.AmbientMusic
Config.EscapeCheckMinutes = Config.Escapes.CheckMinutes
Config.EscapeReturnSeconds = Config.Escapes.ReturnSeconds
Config.BoardProp = Config.Props.BoardProp
Config.BoardIcon = 'fas fa-circle-info'
Config.MemberPassItem = Config.Items.MemberPass
Config.EntryReceiptItem = Config.Items.EntryReceipt
Config.FeedItemName = Config.Items.Feed
Config.RawMeatItemName = Config.Items.RawMeat
Config.AnimalSnackItem = Config.Items.AnimalSnack
Config.WaterItem = Config.Items.Water
Config.SodaItem = Config.Items.Soda
Config.BurgerItem = Config.Items.Burger
Config.HotdogItem = Config.Items.Hotdog
Config.CottonCandyItem = Config.Items.CottonCandy
Config.TicketPed = Config.Peds.Ticket.model
Config.TicketPedCoords = Config.Peds.Ticket.coords
Config.GuardPeds = Config.Peds.Guards or {}

function Config.Clamp(val)
    if val < Config.Stats.Min then
        return Config.Stats.Min
    end

    if val > Config.Stats.Max then
        return Config.Stats.Max
    end

    return val
end

function Config.GetMoodLabel(value)
    if value >= 90 then
        return 'Thriving'
    end

    if value >= 75 then
        return 'Excellent'
    end

    if value >= 60 then
        return 'Stable'
    end

    if value >= 40 then
        return 'Needs attention'
    end

    return 'Critical'
end

Config.BroomProp = 'prop_tool_broom'
Config.FeedTrayProp = 'prop_food_bs_tray_03'


Config.Framework = {
    Type = 'auto', -- auto | qb | esx
    Resource = {
        qb = 'qb-core',
        esx = 'es_extended'
    }
}

Config.Inventory = {
    Type = 'auto', -- auto | qb | esx | ox | tgiann
    Resource = {
        ox = 'ox_inventory',
        tgiann = 'tgiann-inventory'
    }
}

Config.Target = {
    Type = 'auto', -- auto | qb | ox
    Resource = {
        qb = 'qb-target',
        ox = 'ox_target'
    }
}
