Scorpio "AshToAsh.BlizzardSkin.Active" ""

HEALTHBAR           = (Scorpio.IsRetail or Scorpio.IsBCC or IsAddOnLoaded("LibHealComm-4.0") or pcall(_G.LibStub, "LibHealComm-4.0")) and "PredictionHealthBar" or "HealthBar"

-- 能量条高度
POWERBAR_HEIGHT     = 9

local shareColor    = ColorType(0, 0, 0, 1)
local shareSize     = Size(1, 1)

local function resizeOnUnitFrameChanged(size)
    return Wow.FromFrameSize(UnitFrame):Map(function(w, h)
        local componentScale = min(w / 72, h / 36)
        return (size or 10) * componentScale
    end)
end

local function resizeUnitFrameIconOnSizeChanged(size)
    return Wow.FromFrameSize(UnitFrame):Map(function(w, h)
        local componentScale = min(w / 72, h / 36)
        shareSize.width = (size or 15) * componentScale
        shareSize.height = (size or 15) * componentScale
        return shareSize
    end)
end

local shareAnchor1 = Anchor("TOP")
local shareAnchor2 = Anchor("TOP")
local shareLocation = {}

local function getAnchor(anchor, point, x, y, relativeTo, relativePoint)
    anchor.point            = point
    anchor.x                = x
    anchor.y                = y
    anchor.relativeTo       = relativeTo
    anchor.relativePoint    = relativePoint
    return anchor
end

local function getLocation(...)
    wipe(shareLocation)
    for i = 1, select("#", ...) do
        shareLocation[i] = select(i, ...)
    end
    return shareLocation
end

local relocationUnitFrameIconOnSizeChanged = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
    return getLocation(getAnchor(shareAnchor1, "BOTTOM", 0, h/3-4))
end)

local shareFont = {}

local function getDynamicHeightFont(frameHeight, fontObject, minScale, maxScale)
    local font, height = fontObject:GetFont()
    shareFont.font = font
    local scale = frameHeight / 48
    local minHeight = height * (minScale or 1)
    local maxHeight = height * (maxScale or 1)
    if minHeight > maxHeight then
        minHeight = maxHeight
    end
    height = height * scale
    if height > maxHeight then
        height = maxHeight
    elseif height < minHeight then
        height = minHeight
    end

    shareFont.height = height
    return shareFont
end

-------------------------------------------------
-- Dynamic Style
-------------------------------------------------

-------------------------------------------------
-- Health Label
-------------------------------------------------
SHARE_HEALTHLABEL_SKIN                                                                       = {
    location                                                                                 = {
        Anchor("CENTER"),
        Anchor("TOP", 0, -2, "NameLabel", "BOTTOM")
    },
    fontObject                                                                               = SystemFont_Small
}

local function formatHealth(health)
    if health and health > 0 then
        if DB().Appearance.HealthBar.HealthText.TextFormat == HealthTextFormat.TEN_THOUSAND then
            return health >= 10000 and ("%.1fW"):format(health/10000) or health
        elseif DB().Appearance.HealthBar.HealthText.TextFormat == HealthTextFormat.KILO then
            return health >= 1000 and ("%.1fK"):format(health/1000) or health
        else
            return BreakUpLargeNumbers(health)
        end
    end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.HealthLabelSkin()
    local font, height = SystemFont_Small:GetFont()
    local fontType = { font = font, height = height }
    local fontObserver   = Wow.FromFrameSize(UnitFrame):Map(function(w, h) return getDynamicHeightFont(h, SystemFont_Small, 0.6) end)

    return AshBlzSkinApi.OnConfigChanged():Map(function()
        local healthTextStyle = DB().Appearance.HealthBar.HealthText.Style
        if healthTextStyle == HealthTextStyle.HEALTH then
            SHARE_HEALTHLABEL_SKIN.text  = Wow.UnitHealthFrequent():Map(formatHealth)
        elseif healthTextStyle == HealthTextStyle.LOSTHEALTH then
            SHARE_HEALTHLABEL_SKIN.text  = Wow.UnitHealthLostFrequent():Map(formatHealth)
        elseif healthTextStyle == HealthTextStyle.PERCENT then
            SHARE_HEALTHLABEL_SKIN.text  = Wow.UnitHealthPercentFrequent():Map(function(percent)
                return percent.."%"
            end)
        else
            return nil
        end
    
        SHARE_HEALTHLABEL_SKIN.textColor = (healthTextStyle == HealthTextStyle.LOSTHEALTH and Color.RED or Color.WHITE)
        SHARE_HEALTHLABEL_SKIN.Font = DB().Appearance.HealthBar.HealthText.ScaleWithFrame and fontObserver or fontType

        return SHARE_HEALTHLABEL_SKIN
    end)
end

-------------------------------------------------
-- Panel Label
-------------------------------------------------
GROUP_PANEL_LABEL_SKIN                                                                       = {
    fontObject                                                                               = AshBlzSkinApi.UnitPanelOrientation():Map(function(orientation)
        if orientation == Orientation.HORIZONTAL then
            return GameFontNormalTiny
        else
            return GameFontNormalSmall
        end
    end),
    justifyH                                                                                 = "CENTER",
    text                                                                                     = AshBlzSkinApi.UnitPanelLabel(),
    visible                                                                                  = AshBlzSkinApi.UnitPanelLabelVisible(),
    location                                                                                 = AshBlzSkinApi.UnitPanelOrientation():Map(function(orientation)
        if orientation == Orientation.HORIZONTAL then
            return getLocation(getAnchor(shareAnchor1, "RIGHT", 0, 0, nil, "LEFT"))
        else
            return getLocation(getAnchor(shareAnchor1, "BOTTOM", 0, 3, nil, "TOP"))
        end
    end),
}

__Static__() __AutoCache__()
function AshBlzSkinApi.PanelLableSkin()
    return Wow.FromEvent("AshToAsh_Blizzard_Skin_Config_Changed", "ASHTOASH_CONFIG_CHANGED"):Map(function()
        return DB().Appearance.DisplayPanelLabel and GROUP_PANEL_LABEL_SKIN or nil
    end)
end

-- 宠物面板标题
GROUP_PET_PANEL_LABEL_SKIN                                                                  = {
    fontObject                                                                              = AshBlzSkinApi.UnitPanelOrientation():Map(function(orientation)
        if orientation == Orientation.HORIZONTAL then
            return GameFontNormalTiny
        else
            return GameFontNormalSmall
        end
    end),
    justifyH                                                                                = "CENTER",
    text                                                                                    = AshBlzSkinApi.UnitPetPanelLabel(),
    visible                                                                                 = AshBlzSkinApi.UnitPetPanelLabelVisible(),
    location                                                                                = AshBlzSkinApi.UnitPetPanelOrientation():Map(function(orientation)
        if orientation == Orientation.HORIZONTAL then
            return getLocation(getAnchor(shareAnchor1, "RIGHT", 0, 0, nil, "LEFT"))
        else
            return getLocation(getAnchor(shareAnchor1, "BOTTOM", 0, 3, nil, "TOP"))
        end
    end),
}

__Static__() __AutoCache__()
function AshBlzSkinApi.PetPanelLableSkin()
    return Wow.FromEvent("AshToAsh_Blizzard_Skin_Config_Changed", "ASHTOASH_CONFIG_CHANGED"):Map(function()
        return DB().Appearance.DisplayPetPanelLabel and GROUP_PET_PANEL_LABEL_SKIN or nil
    end)
end


-------------------------------------------------
-- Power Bar
-------------------------------------------------

SHARE_POWERBAR_SKIN                                                                         = {
    useParentLevel                                                                          = true,
    statusBarTexture                                                                        = {
        file                                                                                = "Interface\\RaidFrame\\Raid-Bar-Resource-Fill",
        drawLayer                                                                           = "BORDER"
    },
    location                                                                                = {
        Anchor("TOPLEFT", 0, 0, HEALTHBAR, "BOTTOMLEFT"),
        Anchor("BOTTOMRIGHT", -1, 1)
    },

    BackgroundTexture                                                                       = {
        file                                                                                = "Interface\\RaidFrame\\Raid-Bar-Resource-Background",
        setAllPoints                                                                        = true,
        subLevel                                                                            = 2,
        drawLayer                                                                           = "BACKGROUND"
    }
}


-- 玩家能量条
POWER_BAR_SKIN                                                                              = {
    SHARE_POWERBAR_SKIN,

    value                                                                                   = AshBlzSkinApi.UnitPower(),
    minMaxValues                                                                            = AshBlzSkinApi.UnitPowerMax(),
    statusBarColor                                                                          = AshBlzSkinApi.UnitPowerColor()
}

__Static__() __AutoCache__()
function AshBlzSkinApi.PowerBarSkin()
    return AshBlzSkinApi.PowerBarVisible():Map(function()
        return DB().Appearance.PowerBar.Visibility == Visibility.SHOW_ALWAYS and POWER_BAR_SKIN or nil
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.PetPowerBarSkin()
    return AshBlzSkinApi.PowerBarVisible():Map(function()
        return DB().Appearance.PowerBar.Visibility == Visibility.SHOW_ALWAYS and SHARE_POWERBAR_SKIN or nil
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.CastBarVisibilityChanged()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return DB().Appearance.PowerBar.Visibility == Visibility.SHOW_ALWAYS and DB().Appearance.CastBar.Visibility or Visibility.HIDE
    end)
end

-------------------------------------------------
-- CastBar
-------------------------------------------------
SHARE_CASTBAR_SKIN                                                                          = {
    height                                                                                  = 8,
    location                                                                                = {
        Anchor("TOPLEFT", 0, 0, "PowerBar", "TOPLEFT"),
        Anchor("BOTTOMRIGHT", 0, 0, "PowerBar", "BOTTOMRIGHT") 
    },
    visibility                                                                              = AshBlzSkinApi.CastBarVisibilityChanged(),

    Spark                                                                                   = {
        size                                                                                = Size(24, 24),
    }
}

__Static__() __AutoCache__()
function AshBlzSkinApi.CastBarSkin()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return (DB().Appearance.PowerBar.Visibility == Visibility.SHOW_ALWAYS and DB().Appearance.CastBar.Visibility) and SHARE_CASTBAR_SKIN or nil
    end)
end

-------------------------------------------------
-- Aggro
-------------------------------------------------
AGGRO_SKIN                                                                                  = {
    drawLayer                                                                               = "ARTWORK",
    subLevel                                                                                = 3,
    file                                                                                    = "Interface\\RaidFrame\\Raid-FrameHighlights",
    texCoords                                                                               = RectType(0.00781250, 0.55468750, 0.00781250, 0.27343750),
    setAllPoints                                                                            = true,
    visible                                                                                 = Wow.UnitThreatLevel():Map("l=> l>0"),
    vertexColor                                                                             = Wow.UnitThreatLevel():Map(function(level)
        shareColor.r, shareColor.g, shareColor.b, shareColor.a = GetThreatStatusColor(level)
        return shareColor
    end)
}

-- 宠物仇恨指示器
PET_AGGRO_SKIN                                                                              = {
    AGGRO_SKIN,

    visible                                                                                 = AshBlzSkinApi.UnitPetThreatLevel():Map("l=> l>0"),
    vertexColor                                                                             = AshBlzSkinApi.UnitPetThreatLevel():Map(function(level)
        shareColor.r, shareColor.g, shareColor.b, shareColor.a = GetThreatStatusColor(level)
        return shareColor
    end)
}

__Static__() __AutoCache__()
function AshBlzSkinApi.AggroSkin()
    return  AshBlzSkinApi.OnConfigChanged():Map(function()
        return DB().Appearance.DisplayAggroHighlight and AGGRO_SKIN or nil
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.PetAggroSkin()
    return  AshBlzSkinApi.OnConfigChanged():Map(function()
        return DB().Appearance.DisplayAggroHighlight and PET_AGGRO_SKIN or nil
    end)
end

-------------------------------------------------
-- Name
-------------------------------------------------

SHARE_NAMELABEL_SKIN                                                                        = {
    drawLayer                                                                               = "ARTWORK",
    wordWrap                                                                                = false,
    justifyH                                                                                = "LEFT",
    textColor                                                                               = AshBlzSkinApi.UnitNameColor()
}

-- 名字指示器
NAMELABEL_SKIN                                                                              = {
    SHARE_NAMELABEL_SKIN,

    text                                                                                    = AshBlzSkinApi.UnitName(),
    location                                                                                = {
        Anchor("TOPLEFT", 0, -1, "RoleIcon", "TOPRIGHT"), 
        Anchor("TOPRIGHT", -3, -3) 
    }
}

__Static__() __AutoCache__()
function AshBlzSkinApi.NameSkin()
    local font, height = GameFontHighlightSmall:GetFont()
    local fontType = { font = font, height = height }
    local fontObserver   = Wow.FromFrameSize(UnitFrame):Map(function(w, h) return getDynamicHeightFont(h, GameFontHighlightSmall, 0.6) end)
    return AshBlzSkinApi.OnConfigChanged():Map(function()
            NAMELABEL_SKIN.Font = DB().Appearance.Name.ScaleWithFrame and fontObserver or fontType
        return NAMELABEL_SKIN
    end)
end

-------------------------------------------------
-- Share Skin
-------------------------------------------------

-- Enlarge debuff
SHARE_ENLARGEDEBUFFPANEL_SKIN                                                               = {
    topLevel                                                                                = true,
    elementType                                                                             = AshBlzSkinEnlargetDebuffIcon,
    rowCount                                                                                = 1,
    columnCount                                                                             = 2,
    elementWidth                                                                            = resizeOnUnitFrameChanged(15),
    elementHeight                                                                           = resizeOnUnitFrameChanged(15),
    marginLeft                                                                              = 0,
    marginTop                                                                               = 0,
    frameStrata                                                                             = "MEDIUM",
    leftToRight                                                                             = true,
    topToBottom                                                                             = false,
    location                                                                                = {
        Anchor("TOPLEFT", 3, -3, HEALTHBAR, "TOPLEFT")
    }
}

-- Dispell debuff
SHARE_DISPELLDEBUFFPANEL_SKIN                                                               = {
    elementType                                                                             = AshBlzSkinDispellIcon,
    leftToRight                                                                             = false,
    topToBottom                                                                             = false,
    rowCount                                                                                = 1,
    columnCount                                                                             = 4,
    hSpacing                                                                                = 1.5,
    vSpacing                                                                                = 1,
    marginRight                                                                             = 3,
    marginTop                                                                               = 4,
    elementWidth                                                                            = resizeOnUnitFrameChanged(9),
    elementHeight                                                                           = resizeOnUnitFrameChanged(9),
    location                                                                                = {
        Anchor("TOPRIGHT", 0, 0, HEALTHBAR, "TOPRIGHT")
    }
}

-- Boss debuff
SHARE_BOSSDEBUFFPANEL_SKIN                                                                  = {
    elementType                                                                             = AshBlzSkinBossDebuffIcon,
    orientation                                                                             = Orientation.HORIZONTAL,
    leftToRight                                                                             = true,
    topToBottom                                                                             = false,
    rowCount                                                                                = 1,
    columnCount                                                                             = 1,
    marginLeft                                                                              = 0,
    hSpacing                                                                                = 1.5,
    vSpacing                                                                                = 1,
    elementWidth                                                                            = resizeOnUnitFrameChanged(15),
    elementHeight                                                                           = resizeOnUnitFrameChanged(15),
    location                                                                                = {
        Anchor("BOTTOMLEFT", 3, 1.5, HEALTHBAR, "BOTTOMLEFT")
    },

    customFilter                                                                            = function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID)
        return not _EnlargeDebuffList[spellID]
    end
}

-- Debuff
SHARE_DEBUFFPANEL_SKIN                                                                      = {
    elementType                                                                             = AshBlzSkinDebuffIcon,
    orientation                                                                             = Orientation.HORIZONTAL,
    leftToRight                                                                             = true,
    topToBottom                                                                             = false,
    rowCount                                                                                = 1,
    columnCount                                                                             = AshBlzSkinApi.UnitBossAura():Map(function(val) return val and 1 or 3 end),
    marginLeft                                                                              = 1,
    hSpacing                                                                                = 0.5,
    vSpacing                                                                                = 1,
    elementWidth                                                                            = resizeOnUnitFrameChanged(11),
    elementHeight                                                                           = resizeOnUnitFrameChanged(11),
    location                                                                                = {
        Anchor("BOTTOMLEFT", 0, 0, "AshBlzSkinBossDebuffPanel", "BOTTOMRIGHT")      
    },
    displayOnlyDispellableDebuffs                                                           = AshBlzSkinApi.DisplayOnlyDispellableDebuffs(),

    customFilter                                                                            = function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID)
        return not (_AuraBlackList[spellID] or _EnlargeDebuffList[spellID]) 
    end,
}                                                                    

-- Buff
SHARE_BUFFPANEL_SKIN                                                                        = {
    elementType                                                                             = AshBlzSkinBuffIcon,
    orientation                                                                             = Orientation.HORIZONTAL,
    elementWidth                                                                            = resizeOnUnitFrameChanged(11),
    elementHeight                                                                           = resizeOnUnitFrameChanged(11),
    marginRight                                                                             = 3,
    rowCount                                                                                = 1,
    columnCount                                                                             = 3,
    hSpacing                                                                                = 0,
    leftToRight                                                                             = false,
    topToBottom                                                                             = false,
    location                                                                                = {
        Anchor("BOTTOMRIGHT", 0, 1.5, HEALTHBAR, "BOTTOMRIGHT") 
    },
        
    customFilter                                                                            = function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID) 
        return not _AuraBlackList[spellID] and not (_ClassBuffList[name] or _ClassBuffList[spellID])
    end,
}

-- 标记
SHARE_RAIDTARGET_SKIN                                                                       = {
    drawLayer                                                                               = "OVERLAY",
    location                                                                                = {
        Anchor("TOPRIGHT", -3, -2)      
    },
    size                                                                                    = resizeUnitFrameIconOnSizeChanged(14)
}

-- 血条
SHARE_HEALTHBAR_SKIN                                                                        = {
    useParentLevel                                                                          = true,
    statusBarTexture                                                                        = {
        file                                                                                = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
        drawLayer                                                                           = "BORDER"
    },
    location                                                                                = AshBlzSkinApi.PowerBarVisible():Map(function(powerBarVisible)
        if powerBarVisible then
            return getLocation(getAnchor(shareAnchor1, "TOPLEFT", 1, -1), getAnchor(shareAnchor2, "BOTTOMRIGHT", -1, POWERBAR_HEIGHT))
        else
            return getLocation(getAnchor(shareAnchor1, "TOPLEFT", 1, -1), getAnchor(shareAnchor2, "BOTTOMRIGHT", -1, 1))
        end
    end),

    BackgroundFrame                                                                         = NIL,

    -- 拥有驱散debuff的能力
    IconTexture                                                                             = {
        drawLayer                                                                           = "BORDER",
        subLevel                                                                            = 2,
        location                                                                            = {
            Anchor("TOPLEFT", 0, 0, "$parent.statusBarTexture", "TOPLEFT"), 
            Anchor("BOTTOMRIGHT", 0, 0, "$parent.statusBarTexture", "BOTTOMRIGHT")
        },      
        ignoreParentAlpha                                                                   = true,
        file                                                                                = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
        vertexColor                                                                         = AshBlzSkinApi.UnitDebuffCanDispellColor(),
        visible                                                                             = AshBlzSkinApi.UnitDebuffCanDispell(),

        AnimationGroup                                                                      = {
            playing                                                                         = AshBlzSkinApi.UnitDebuffCanDispell(),
            looping                                                                         = "REPEAT",

            Alpha1                                                                          = {
                smoothing                                                                   = "OUT",
                order                                                                       = 1,
                duration                                                                    = 0.5,
                fromAlpha                                                                   = 0,
                toAlpha                                                                     = 1
            },
            Alpha2                                                                          = {
                smoothing                                                                   = "IN",
                order                                                                       = 2,
                duration                                                                    = 0.5,
                fromAlpha                                                                   = 1,
                toAlpha                                                                     = 0
            }
        }
    }
}

-------------------------------------------------
-- Skin
-------------------------------------------------

SKIN_STYLE =                                                                                {
    -- 单位面板
    [AshGroupPanel]                                                                         = {

        Label                                                                               = AshBlzSkinApi.PanelLableSkin(),

        -- 解锁按钮
        AshBlzSkinUnlockButton                                                              = {
            size                                                                            = Size(24, 24),
            visible                                                                         = AshBlzSkinApi.UnitPanelVisible(),
            location                                                                        = {
                Anchor("BOTTOMLEFT", -2, -1, nil, "TOPLEFT")
            }
        }
    },

    -- 宠物面板
    [AshGroupPetPanel]                                                                      = {
        Label                                                                               = AshBlzSkinApi.PetPanelLableSkin()
    },

    [AshBlzSkinBuffIcon]                                                                    = {
        backdrop                                                                            = NIL,
        backdropBorderColor                                                                 = NIL,

        IconTexture                                                                         = {
            drawLayer                                                                       = "ARTWORK",
            setAllPoints                                                                    = true,
            file                                                                            = Wow.FromPanelProperty("AuraIcon"),
            texCoords                                                                       = NIL
        },

        Label                                                                               = {
            drawLayer                                                                       = "OVERLAY",
            fontObject                                                                      = NumberFontNormalSmall,
            location                                                                        = {
                Anchor("BOTTOMRIGHT", 0, 0)
            },
            text                                                                            = Wow.FromPanelProperty("AuraCount"):Map(function(val)
                if val >= 100 then
                    return BUFF_STACKS_OVERFLOW
                elseif val > 1 then
                    return val
                else
                    return ""
                end
            end),
        },

        Cooldown                                                                            = {
            setAllPoints                                                                    = true,
            enableMouse                                                                     = false,
            cooldown                                                                        = Wow.FromPanelProperty("AuraCooldown"),
            reverse                                                                         = true,
        },
    },

    [AshBlzSkinClassBuffIcon]                                                               = {
        enableMouse                                                                         = false
    },

    [AshBlzSkinDebuffIcon]                                                                  = {
        BackgroundTexture                                                                   = {
            drawLayer                                                                       = "OVERLAY",
            file                                                                            = "Interface\\Buttons\\UI-Debuff-Overlays",
            location                                                                        = {
                Anchor("TOPLEFT", -1, 1),
                Anchor("BOTTOMRIGHT", 1, -1)
            },
            texCoords                                                                       = RectType(0.296875, 0.5703125, 0, 0.515625),
            vertexColor                                                                     = Wow.FromPanelProperty("AuraDebuff"):Map(function(dtype) return DebuffTypeColor[dtype] or DebuffTypeColor["none"] end)
        },

        auraFilter                                                                          = Wow.FromPanelProperty("AuraFilter")
    },

    -- Dispell debuff Icon
    [AshBlzSkinDispellIcon]                                                                 = {
        IconTexture                                                                         = {
            drawLayer                                                                       = "ARTWORK",
            setAllPoints                                                                    = true,
            file                                                                            = Wow.FromPanelProperty("AuraDebuff"):Map(function(dtype)
                return "Interface\\RaidFrame\\Raid-Icon-Debuff"..dtype
            end),
            texCoords                                                                       = RectType(0.125, 0.875, 0.125, 0.875)
        }
    },

    [AshBlzSkinEnlargetDebuffIcon]                                                          = {
        PixelGlow                                                                           = {
            period                                                                          = 2,
            visible                                                                         = true
        }
    },

    [AshUnitFrame]                                                                          = {
        inherit                                                                             = "default",

        frameStrata                                                                         = "LOW",
        alpha                                                                               = AshBlzSkinApi.UnitInRange():Map('v=>v and 1 or 0.55'),

        -- 可驱散debuff高亮
        PixelGlow                                                                           = {
            visible                                                                         = AshBlzSkinApi.UnitDebuffCanDispell()
        },
        
        -- 去除默认皮肤的目标指示器
        Label2                                                                              = NIL,
        Label3                                                                              = NIL,

        BackgroundTexture                                                                   = {
            file                                                                            = "Interface\\RaidFrame\\Raid-Bar-Hp-Bg",
            texCoords                                                                       = RectType(0, 1, 0, 0.53125),
            setAllPoints                                                                    = true,
            ignoreParentAlpha                                                               = true,
            drawLayer                                                                       = "BACKGROUND"
        },

        -- 选中
        AshBlzSkinSelectionHighlightTexture                                                 = {},

        -- 仇恨指示器
        AshBlzSkinAggroHighlight                                                            = AshBlzSkinApi.AggroSkin(),

        -- 名字
        NameLabel                                                                           = AshBlzSkinApi.NameSkin(),

        -- 血量文本
        HealthLabel                                                                         = AshBlzSkinApi.HealthLabelSkin(),

        -- 死亡图标
        AshBlzSkinDeadIcon                                                                  = {
            size                                                                            = resizeUnitFrameIconOnSizeChanged(),
            location                                                                        = relocationUnitFrameIconOnSizeChanged,
        },

        -- 角色职责图标
        RoleIcon                                                                            = {
            location                                                                        = {
                Anchor("TOPLEFT", 3, -2)
            },
            size                                                                            = Wow.UnitRoleVisible():Map(function(val)
                if val then
                    shareSize.width, shareSize.height = 12, 12
                else
                    shareSize.width, shareSize.height = 1, 1
                end
                return shareSize
            end),
            visible                                                                         = true
        },

        -- 载具图标
        AshBlzSkinVehicleIcon                                                               = {
            location                                                                        = {
                Anchor("TOPLEFT", 0, -1, "RoleIcon", "BOTTOMLEFT")
            },
            size                                                                            = Size(12, 12),
            file                                                                            = "Interface\\Vehicles\\UI-Vehicles-Raid-Icon",
            texCoords                                                                       = RectType(0, 1, 0, 1),
            visible                                                                         = AshBlzSkinApi.UnitVehicleVisible()
        },

        -- 队长图标
        LeaderIcon                                                                          = {
            location                                                                        = {
                Anchor("TOPRIGHT", -3, -2)
            },
            file                                                                            = Wow.UnitIsLeader():Map(function(isLeader)
                return isLeader and [[Interface\GroupFrame\UI-Group-LeaderIcon]] or nil
            end),
            visible                                                                         = true,
            drawLayer                                                                       = "ARTWORK",
            subLevel                                                                        = 2,
            size                                                                            = Wow.UnitIsLeader():Map(function(isLeader)
                if isLeader then
                    shareSize.width, shareSize.height = 12, 12
                else
                    shareSize.width, shareSize.height = 1, 1
                end
                return shareSize
            end)
        },

        -- 主坦克、主助理
        RaidRosterIcon                                                                      = {
            location                                                                        = {
                Anchor("TOPRIGHT", -1, 0, "LeaderIcon", "TOPLEFT")
            },
            drawLayer                                                                       = "ARTWORK",
            subLevel                                                                        = 2,
            size                                                                            = Size(12, 12),
        },

        -- 复活图标，不需要了，用CenterStatusIcon
        ResurrectIcon                                                                       = NIL,

        -- 标记图标
        RaidTargetIcon                                                                      = SHARE_RAIDTARGET_SKIN,

        -- 离线图标
        DisconnectIcon                                                                      = {
            location                                                                        = relocationUnitFrameIconOnSizeChanged,
            size                                                                            = resizeUnitFrameIconOnSizeChanged()
        },

        -- 准备就绪
        ReadyCheckIcon                                                                      = {
            drawLayer                                                                       = "OVERLAY",
            location                                                                        = relocationUnitFrameIconOnSizeChanged,
            size                                                                            = resizeUnitFrameIconOnSizeChanged()
        },

        -- 中间状态图标
        AshBlzSkinCenterStatusIcon                                                          = {
            location                                                                        = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
                return getLocation(getAnchor(shareAnchor1, "CENTER", 0, h / 3 + 2, nil, "BOTTOM"))
            end),
            size                                                                            = resizeUnitFrameIconOnSizeChanged(22),
            visible                                                                         = AshBlzSkinApi.UnitCenterStatusIconVisible(),
            unit                                                                            = Wow.Unit()
        },

        -- 血条
        [HEALTHBAR]                                                                         = {
            SHARE_HEALTHBAR_SKIN,
            statusBarColor                                                                  = AshBlzSkinApi.UnitColor(),
        },

        -- 能量条
        PowerBar                                                                            = AshBlzSkinApi.PowerBarSkin(),

        -- 施法条
        AshBlzSkinCastBar                                                                   = AshBlzSkinApi.CastBarSkin(),

        BuffPanel                                                                           = NIL,

        -- Buff
        AshBlzSkinBuffPanel                                                                 = SHARE_BUFFPANEL_SKIN,

        DebuffPanel                                                                         = NIL,

        -- Debuff
        AshBlzSkinDebuffPanel                                                               = SHARE_DEBUFFPANEL_SKIN,

        -- Boss debuff
        AshBlzSkinBossDebuffPanel                                                           = SHARE_BOSSDEBUFFPANEL_SKIN,

        -- 职业buff
        ClassBuffPanel                                                                      = {
            topLevel                                                                        = true,
            elementType                                                                     = AshBlzSkinClassBuffIcon,
            location                                                                        = relocationUnitFrameIconOnSizeChanged,
            rowCount                                                                        = 1,
            columnCount                                                                     = 1,
            visible                                                                         = AshBlzSkinApi.UnitIsPlayer(),
            elementWidth                                                                    = resizeOnUnitFrameChanged(),
            elementHeight                                                                   = resizeOnUnitFrameChanged()
        },

        -- 可驱散debuff (是可驱散类型即可驱散debuff)
        AshBlzSkinDispellDebuffPanel                                                        = {
            SHARE_DISPELLDEBUFFPANEL_SKIN,

            visible                                                                         = AshBlzSkinApi.UnitIsPlayer(),
        },

        -- 重要Debuff
        EnlargeDebuffPanel                                                                  = SHARE_ENLARGEDEBUFFPANEL_SKIN
    },

    [AshPetUnitFrame]                                                                       = {
        frameStrata                                                                         = "LOW",
        alpha                                                                               = AshBlzSkinApi.UnitPetInRange():Map('v=> v and 1 or 0.55'), 

        BackgroundTexture                                                                   = {
            file                                                                            = "Interface\\RaidFrame\\Raid-Bar-Hp-Bg",
            texCoords                                                                       = RectType(0, 1, 0, 0.53125),
            setAllPoints                                                                    = true,
            ignoreParentAlpha                                                               = true,
            drawLayer                                                                       = "BACKGROUND"
        },

        -- 宠物名字
        NameLabel                                                                           = {
            SHARE_NAMELABEL_SKIN,
        
            fontObject                                                                      = GameFontWhiteSmall,
            text                                                                            = Wow.UnitName(),
            location                                                                        = {
                Anchor("TOPLEFT", 3, -3), 
                Anchor("TOPRIGHT", -3, -3)
            }
        },

        -- 主人名字
        Label                                                                               = {
            fontObject                                                                      = GameFontWhiteTiny,
            drawLayer                                                                       = "ARTWORK",
            wordWrap                                                                        = false,
            justifyH                                                                        = "LEFT",
            text                                                                            = AshBlzSkinApi.UnitPetOwnerName(),
            location                                                                        = {
                Anchor("TOPLEFT", 0, -select(2, GameFontWhiteSmall:GetFont()), "NameLabel", "TOPLEFT"),
                Anchor("TOPRIGHT", 0, -select(2, GameFontWhiteSmall:GetFont()), "NameLabel", "TOPRIGHT"),
            }
        },

        --死亡图标
        AshBlzSkinDeadIcon                                                                  = {
            size                                                                            = resizeUnitFrameIconOnSizeChanged(),
            location                                                                        = relocationUnitFrameIconOnSizeChanged,
        },

        -- 仇恨指示器
        AshBlzSkinAggroHighlight                                                            = AshBlzSkinApi.PetAggroSkin(),

        -- 选中
        AshBlzSkinSelectionHighlightTexture                                                 = {},
        
        -- 标记图标
        RaidTargetIcon                                                                      = SHARE_RAIDTARGET_SKIN,

        -- 血条
        [HEALTHBAR]                                                                         = {
            SHARE_HEALTHBAR_SKIN,
            statusBarColor                                                                  = AshBlzSkinApi.UnitPetColor(),
        },

        -- 能量条
        PowerBar                                                                            = AshBlzSkinApi.PetPowerBarSkin(),

        -- 施法条
        AshBlzSkinCastBar                                                                   = AshBlzSkinApi.CastBarSkin(),

        -- Buff
        AshBlzSkinBuffPanel                                                                 = SHARE_BUFFPANEL_SKIN,
        
        -- Debuff
        AshBlzSkinDebuffPanel                                                               = SHARE_DEBUFFPANEL_SKIN,

        --  Boss debuff
        AshBlzSkinBossDebuffPanel                                                           = SHARE_BOSSDEBUFFPANEL_SKIN,

        -- 可驱散debuff (是可驱散类型即可驱散debuff)
        AshBlzSkinDispellDebuffPanel                                                        = SHARE_DISPELLDEBUFFPANEL_SKIN,

        -- 重要Debuff
        EnlargeDebuffPanel                                                                  = SHARE_ENLARGEDEBUFFPANEL_SKIN
    },
}

Style.UpdateSkin(SKIN_NAME, SKIN_STYLE)
Style.ActiveSkin(SKIN_NAME)