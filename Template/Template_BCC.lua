Scorpio "AshToAsh.BlizzardSkin.Template.BCC" ""

if not Scorpio.IsBCC then return end

-- 中间状态图标
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinCenterStatusIcon") 
class "CenterStatusIcon"(function()
    inherit "Button"

    property "Unit" { 
        type        = String,
        handler     = function(self, unit)
            self:Update()
        end
    }

    local function OnEnter(self, motion)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        else
            self:GetParent():OnEnter(motion)
        end
    end
    
    local function OnLeave(self, motion)
        if self.tooltip then
            GameTooltip:Hide()
        else
            self:GetParent():OnLeave(motion)
        end
    end

    function Update(self)
        local unit = self.Unit
        if not unit then return end
        local texture = self:GetChild("Texture")
        local border = self:GetChild("Border")
        if UnitInOtherParty(unit) then
            texture:SetTexture("Interface\\LFGFrame\\LFG-Eye")
            texture:SetTexCoord(0.125, 0.25, 0.25, 0.5)
            texture:Show()
            border:SetTexture("Interface\\Common\\RingBorder")
            border:Show()
            self.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE
        elseif UnitHasIncomingResurrection(unit) then
            texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            texture:SetTexCoord(0, 1, 0, 1)
            texture:Show()
            border:Hide()
            self.tooltip = nil
        elseif not UnitInPhase(unit) then
            texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
            texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
            texture:Show()
            border:Hide()
            self.tooltip = PARTY_PHASED_MESSAGE
        else
            texture:Hide()
            border:Hide()
            self.tooltip = nil
        end
    end

    local function OnShow(self)
        self:Update()
    end

    __Template__{
        Border      = Texture,
        Texture     = Texture
    }
    function __ctor(self)
        self.OnEnter = self.OnEnter + OnEnter
        self.OnLeave = self.OnLeave + OnLeave
        self.OnShow  = self.OnShow + OnShow
    end
end)

-- Buff panel
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinBuffPanel")
class "BuffPanel"(function()
    inherit "BlzSkinAuraPanel"

    local shareCooldown         = { start = 0, duration = 0 }
    local buffs                 = {}
    local classBuffs            = {}

    -- 同一个职业会互相顶的Buff
    local classBuffList         = {
        PALADIN                 = {
            -- 强效王者祝福
            [25898]             = true,
            -- 王者祝福
            [20217]             = true,
            -- 强效庇护祝福
            [27169]             = true,
            -- 庇护祝福
            [27168]             = true,
            -- 强效力量祝福
            [27141]             = true,
            -- 力量祝福
            [27140]             = true,
            -- 强效智慧祝福
            [27143]             = true,
            -- 智慧祝福
            [27142]             = true,
            -- 强效光明祝福
            [27145]             = true,
            -- 光明祝福
            [27144]             = true,
            -- 强效拯救祝福
            [25895]             = true,
            -- 拯救祝福
            [1038]              = true
        },

        MAGE                    = {
            -- 奥术智慧
            [1459]              = true,
            [27126]             = true,
            -- 奥术光辉
            [27127]             = true
        },

        DRUID                   = {
            -- 野性赐福
            [26991]             = true,
            -- 野性印记
            [26990]             = true
        },

        PRIEST                  = {
            -- 坚韧祷言
            [25392]             = true,
            -- 真言术：韧
            [25389]             = true,
            -- 精神祷言
            [32999]             = true,
            -- 神圣之灵
            [25312]             = true,
            -- 暗影防护祷言
            [39374]             = true,
            -- 防护暗影
            [25433]             = true
        },

        SHAMAN                  = {
            -- 大地之盾
            [32594]             = true
        }
    }

    local function shouldShowClassBuff(self, spellId)
        local buffs = classBuffList[self.class]
        return buffs and buffs[spellId]
    end

    local function shouldDisplayBuff(self, unitCaster, spellId, canApplyAura)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

        local isClassBuff = shouldShowClassBuff(self, spellId)
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or isClassBuff or unitCaster == "pet" or unitCaster == "vehicle")), isClassBuff
        else
            return (unitCaster == "player" or isClassBuff or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId), isClassBuff
        end
    end

    local function refreshAura(self, unit, filter, eleIdx, auraIdx, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        if not name then return end

        if not self.CustomFilter or self.CustomFilter(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...) then
            local displayBuff, isClassBuff = shouldDisplayBuff(self, caster, spellID, canApplyAura)
            if displayBuff and not isBossAura then
                -- 区分职业buff和非职业buff
                if isClassBuff then
                    tinsert(classBuffs, auraIdx)
                elseif not isClassBuff then
                    tinsert(buffs, auraIdx)
                end
            end
        end
        
        auraIdx = auraIdx + 1
        return refreshAura(self, unit, filter, eleIdx, auraIdx, UnitAura(unit, auraIdx, filter))
    end

    local function showElements(self, unit, filter, auras, eleIdx)
        if eleIdx > self.MaxCount then return eleIdx end

        for _, auraIdx in ipairs(auras) do
            if auraIdx then
                local name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer =  UnitAura(unit, auraIdx, filter)

                self.Elements[eleIdx]:Show()

                shareCooldown.start             = expires - duration
                shareCooldown.duration          = duration

                self.AuraIndex[eleIdx]          = auraIdx
                self.AuraName[eleIdx]           = name
                self.AuraIcon[eleIdx]           = icon
                self.AuraCount[eleIdx]          = count
                self.AuraDebuff[eleIdx]         = dtype
                self.AuraCooldown[eleIdx]       = shareCooldown
                self.AuraStealable[eleIdx]      = isStealable and not UnitIsUnit(unit, "player")
                self.AuraCaster[eleIdx]         = caster
                self.AuraSpellID[eleIdx]        = spellID
                self.AuraBossDebuff[eleIdx]     = isBossDebuff
                self.AuraCastByPlayer[eleIdx]   = castByPlayer
                self.AuraFilter[eleIdx]         = filter

                eleIdx = eleIdx + 1
                
                if eleIdx > self.MaxCount then return eleIdx end
            end
        end
        return eleIdx
    end

    -- 添加职业buff，将职业buff显示在最前面
    local function fillClassBuffIntoBuffList(self)
        local buffSize = #buffs
        if buffSize < self.MaxCount then
            for i = 1, self.MaxCount - buffSize do
                local spellId = classBuffs[i]
                if spellId then
                    tinsert(buffs, i, spellId)
                end
            end
        end
    end

    property "Refresh"          {
        set                     = function(self, unit)
            self.Unit           = unit
            if not (unit and self:IsVisible()) then self.Count = 0 return end

            wipe(buffs)
            wipe(classBuffs)

            local filter        = "HELPFUL"
            refreshAura(self, unit, filter, 1, 1, UnitAura(unit, 1, filter))
            fillClassBuffIntoBuffList(self)

            local eleIdx = 1
            eleIdx = showElements(self, unit, filter, buffs, eleIdx)
            self.Count = eleIdx -1
        end
    }

    function __ctor(self)
        super(self)
        self.class = UnitClassBase("player")
    end

end)

-- Debuff panel
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinDebuffPanel")
class "DebuffPanel"(function()
    inherit "BlzSkinAuraPanel"

    local shareCooldown         = { start = 0, duration = 0 }
    local priorityDebuffs       = {}
    local nonBossDebuffs        = {}

    local isPriorityDebuff
    local _, classFileName = UnitClass("player")
    if ( classFileName == "PALADIN" ) then
		isPriorityDebuff = function(spellID)
			return spellID == 25771
		end
	elseif (classFileName == "PRIEST") then
		isPriorityDebuff = function(spellID)
            return spellID == 6788
		end
    else
        isPriorityDebuff = function()
            return false
        end
	end

    local function shouldDisplayDebuff(unitCaster, spellID)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") )
        else
            return true
        end
    end

    local function refreshAura(self, unit, filter, eleIdx, auraIdx, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, ...)
        if not name then return end

        if not self.CustomFilter or self.CustomFilter(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, ...) then
            if not isBossDebuff then
                if isPriorityDebuff(spellID) then
                    tinsert(priorityDebuffs, auraIdx)
                elseif shouldDisplayDebuff(caster, spellID) then
                    tinsert(nonBossDebuffs, auraIdx)
                end
            end
        end

        auraIdx                 = auraIdx + 1
        return refreshAura(self, unit, filter, eleIdx, auraIdx, UnitAura(unit, auraIdx, filter))
    end

    local function refreshPriorityAura(self, unit, filter, eleIdx, auraIdx, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, ...)
        if not name then return end

        if not self.CustomFilter or self.CustomFilter(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, ...) then
            if not isBossDebuff and isPriorityDebuff(spellID) then
                tinsert(priorityDebuffs, auraIdx)
            end
        end

        auraIdx                 = auraIdx + 1
        return refreshPriorityAura(self, unit, filter, eleIdx, auraIdx, UnitAura(unit, auraIdx, filter))
    end

    local function refreshRaidAura(self, unit, filter, eleIdx, auraIdx, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, ...)
        if not name then return end

        if not self.CustomFilter or self.CustomFilter(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, ...) then
            if not isBossDebuff and not isPriorityDebuff(spellID) and shouldDisplayDebuff(caster, spellID) then
                tinsert(nonBossDebuffs, auraIdx)
            end
        end

        auraIdx                 = auraIdx + 1
        return refreshRaidAura(self, unit, filter, eleIdx, auraIdx, UnitAura(unit, auraIdx, filter))
    end

    local function showElements(self, unit, filter, auras, eleIdx)
        if eleIdx > self.MaxCount then return eleIdx end

        for _, auraIdx in ipairs(auras) do
            if auraIdx then
                local name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer = UnitAura(unit, auraIdx, filter)

                self.Elements[eleIdx]:Show()

                shareCooldown.start             = expires - duration
                shareCooldown.duration          = duration

                self.AuraIndex[eleIdx]          = auraIdx
                self.AuraName[eleIdx]           = name
                self.AuraIcon[eleIdx]           = icon
                self.AuraCount[eleIdx]          = count
                self.AuraDebuff[eleIdx]         = dtype
                self.AuraCooldown[eleIdx]       = shareCooldown
                self.AuraStealable[eleIdx]      = isStealable and not UnitIsUnit(unit, "player")
                self.AuraCaster[eleIdx]         = caster
                self.AuraSpellID[eleIdx]        = spellID
                self.AuraBossDebuff[eleIdx]     = isBossDebuff
                self.AuraCastByPlayer[eleIdx]   = castByPlayer
                self.AuraFilter[eleIdx]         = filter

                eleIdx = eleIdx + 1
                
                if eleIdx > self.MaxCount then return eleIdx end
            end
        end
        return eleIdx
    end

    property "Refresh"          {
        set                     = function(self, unit)
            self.Unit           = unit
            if not (unit and self:IsVisible()) then self.Count = 0 return end

            wipe(priorityDebuffs)
            wipe(nonBossDebuffs)

            local displayOnlyDispellableDebuffs = self.DisplayOnlyDispellableDebuffs

            if UnitCanAttack("player", unit) then
                local filter = "PLAYER|HARMFUL"
                refreshAura(self, unit, filter, 1, 1, UnitAura(unit, 1, filter))

                local eleIdx = 1
                eleIdx = showElements(self, unit, filter, priorityDebuffs, eleIdx)
                eleIdx = showElements(self, unit, filter, nonBossDebuffs, eleIdx)
                self.Count = eleIdx -1
            elseif not displayOnlyDispellableDebuffs then
                local filter = "HARMFUL"
                refreshAura(self, unit, filter, 1, 1, UnitAura(unit, 1, filter))

                local eleIdx = 1
                eleIdx = showElements(self, unit, filter, priorityDebuffs, eleIdx)
                eleIdx = showElements(self, unit, filter, nonBossDebuffs, eleIdx)
                self.Count = eleIdx -1
            else
                local filterHarmful = "HARMFUL"
                local filterRaid = "HARMFUL|RAID"
                refreshPriorityAura(self, unit, filterHarmful, 1, 1, UnitAura(unit, 1, filterHarmful))
                refreshRaidAura(self, unit, filterRaid, 1, 1, UnitAura(unit, 1, filterRaid))

                local eleIdx = 1
                eleIdx = showElements(self, unit, filterHarmful, priorityDebuffs, eleIdx)
                eleIdx = showElements(self, unit, filterRaid, nonBossDebuffs, eleIdx)
                self.Count = eleIdx -1
            end
        end
    }


    property "DisplayOnlyDispellableDebuffs" {
        type                    = Boolean,
        default                 = false
    }

end)

-- CastBar 修改自Scorpio.UI.CooldownStatusBar
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinCastBar")
class "CastBar" (function(_ENV)
    inherit "CooldownStatusBar"

    property "Visibility"           {
        type                = Visibility,
        default             = Visibility.SHOW_ONLY_PARTY
    }

    local function OnUpdate(self, elapsed)
        self.value = self.value + elapsed
        if self.value >= self.maxValue then
            self:Hide()
        else
            local value = self.Reverse and (self.maxValue - self.value) or self.value
            self:SetValue(value)
        end
    end

    function SetStatusBarTexture(self, texture)
        super.SetStatusBarTexture(self, texture)
        self.spark:SetPoint("CENTER", texture, "RIGHT", 0, 0)
    end

    function SetCooldown(self, start, duration)
        local visibility = self.Visibility
        if visibility == Visibility.HIDE then
            return
        elseif visibility == Visibility.SHOW_ONLY_PARTY and IsInRaid() then
            return
        end

        if duration <= 0 then
            self:Hide()
            return
        end
        self.maxValue  = duration
        self.value = start - GetTime()
        self:SetMinMaxValues(0, duration)
        self:Show()
    end

    __Template__{
        Spark           = Texture
    }
    function __ctor(self)
        self.value = 0
        self.maxValue = 0
        self.spark = self:GetChild("Spark")
        self.OnUpdate = self.OnUpdate + OnUpdate
    end
end)

Style.UpdateSkin(SKIN_NAME,{
    [CenterStatusIcon]                                                                  = {
        enableMouseMotion                                                               = true,
        enableMouseClicks                                                               = false,

        Texture                                                                         = {
            drawLayer                                                                   = "ARTWORK",
            setAllPoints                                                                = true
        },

        Border                                                                          = {
            drawLayer                                                                   = "BORDER",
            setAllPoints                                                                = true
        }
    },

    -- 施法条
    [CastBar]                                                                           = {
        frameLevel                                                                      = 1,
        statusBarTexture                                                                = {
            file                                                                        = AshBlzSkinApi.CastBarTexture()
        },
        statusBarColor                                                                  = AshBlzSkinApi.UnitCastBarColor(),
        cooldown                                                                        = Wow.UnitCastCooldown(),
        reverse                                                                         = Wow.UnitCastChannel(),

        Spark                                                                           = {
            drawLayer                                                                   = "OVERLAY",
            file                                                                        = "Interface\\CastingBar\\UI-CastingBar-Spark",
            alphaMode                                                                   = "ADD"
        },

        Label                                                                           = {
            justifyH                                                                    = "CENTER",
            drawLayer                                                                   = "OVERLAY",
            textColor                                                                   = Color.WHITE,
            text                                                                        = Wow.UnitCastName(),
            setAllPoints                                                                = true
        }
    },
})