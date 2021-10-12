Scorpio "AshToAsh.BlizzardSkin.Localization.zhCN" ""

local L = _Locale("zhCN")

if not L then return end

L["menu_title"] = "暴雪皮肤"
L["default"] = "默认"
L["panel_mask_tips"] = "只有面板序号大于另一面板才会自动依附！"
L["panel_moving_tips"] = "按住Alt键移动面板"
L["tips"] = "提示"
L["appearance"] = "外观"
L["block_blizzard_unitframe"] = "屏蔽暴雪团队框架"
L["block_blizzard_unitframe_tips"] = "不管怎样，同时运行ATA和暴雪团队框架总是没什么好处的。\n打开/关闭此选项将会重载界面"
L["adjust_auto_attach_margin"] = "调整面板(%d)间距"
L["adjust_auto_attach_margin_tips"] = "当面板自动依附后，你可以使用此选项调整间距。"
L["adjust_auto_attach_margin_input_title"] = "输入间距值(-100~100)"

L["visibility"] = "可见性"
L["visibility_hide"] = "隐藏"
L["visibility_show_only_party"] = "仅小队显示"
L["visibility_show_always"] = "一直显示"
L["visibility_show"] = "显示"

L["texture"] = "材质"
L["background_texture"] = "背景材质"
L["unitframe_background"] = "框体背景材质"

L["font"] = "字体"
L["font_outline"] = "轮廓"
L["font_outline_none"] = "无"
L["font_outline_normal"] = "轮廓"
L["font_outline_thick"] = "细轮廓"
L["font_size"] = "字体大小"
L["font_monochrome"] = "单色"

L["aura"] = "光环"
L["aura_size"]  = "光环大小"
L["aura_size_tips"] = "调整光环的基础大小，只影响Buff和Debuff，职业增益、重要减益等不受影响\n|cffffffff光环仍然会随框体缩放|r"
L["aura_disable_tooltip"] = "禁用鼠标提示"
L["aura_disable_tooltip_tips"] = "禁用鼠标提示允许你能够悬浮在光环上进行点击施法。"
L["aura_show_countdown_numbers_tips"] = "启用此选项只是表明遵循暴雪设置，如果你没有使用OmniCC, 你仍然需要打开“界面-动作条”内的\"" .. COUNTDOWN_FOR_COOLDOWNS_TEXT .. "\"选项。"

L["cast_bar"] = "施法条"
L["power_bar"] = "能量条"
L["health_bar"] = "生命条"
L["power_bar_visibility_tips"] = "隐藏能量条会同时隐藏施法条！"
L["health_text_format"] = "生命值格式"
L["health_text_format_normal"] = "普通"
L["health_text_format_kilo"] = "xx.xK"
L["health_text_format_ten_thousand"] = "xx.xW"
L["health_text_scale_with_frame"] = "生命值大小随框体缩放"
L["name_format"] = "名字格式"
L["name_format_noserver"] = "仅显示玩家名字"
L["name_format_server_shorthand"] = "用(*)代替服务器"
L["name_format_withserver"] = "显示服务器"
L["name_scales_with_frame"] = "大小随框体缩放"
L["friends_name_coloring"] = "好友名字染色"
L["guild_friend_color"] = "公会好友"
L["battle_net_friend_color"] = "战网好友"
L["friend_color"] = "好友"
L["nick_name"] = "昵称"
L["nick_name_format"] = "昵称：%s"
L["nick_name_setting"] = "设置昵称"
L["show_nick_name_owns"] = "显示自己的昵称"
L["show_nick_name_to_others"] = "对他人显示我的昵称"
L["show_nick_name_others"] = "显示他人的昵称"
L["show_nick_name_to_others_tips"] = "勾选此项后其他人会看见你的昵称"
L["err_nickname_too_long"] = "昵称过长"
L["show_panel_label"] = "显示单位面板标签"
L["show_pet_panel_label"] = "显示宠物面板标签"
L["show_panel_label_tips"] = "当任意分组过滤仅勾选一项时，显示面板标签，如：小队N"
L["show_focus_indicator"] = "高亮显示焦点"
L["show_dispellable_debuff_indicator"] = "高亮可驱散Debuff"
L["show_dispellable_debuff_indicator_tips"] = "如果单位有你可以驱散的Debuff时，框体将会高亮"

L["template"] = "模板"
L["template_tips"] = "你可以将当前AshToAsh和暴雪皮肤的配置保存为模板，模板账号通用。需要时，你可以一键应用模板。\n|cffffffff在正式服，ATA和暴雪皮肤的配置随专精切换，在怀旧服则是随角色切换。\n模板不包含增益/减益列表，因为它们本就是账号通用的.\n\n注意：模板只是将其配置复制给当前角色或专精（由你的魔兽世界版本决定），更新模板不会使基于该模板的配置更新。|r"
L["add_template"] = "添加模板"
L["err_add_template"] = "模板名字不能为空或已有同名模板"
L["template_apply"] = "应用模板"
L["template_apply_confirm"] = "确定应用模板：|cff00ff00%s|r"
L["template_update"] = "更新模板"
L["template_update_tips"] = "将当前使用的配置更新到此模板"
L["template_update_confirm"] = "确定更新模板：|cff00ff00%s|r"
L["template_delete"] = "删除模板"
L["template_delete_confirm"] = "确定删除模板：|cffff0000%s|r"
L["template_apply_tips"] = "点击此选项选项将会重载界面。\n|cffff0000请注意：随着插件更新，旧版本的模板应用后可能会导致配置损坏，届时你可能需要删除引起错误的模板及对应角色的WTF内的AshToAsh.lua。|r"
L["template_default_apply"] = "应用默认模板"
L["template_default_apply_tips"] = "点击将会应用默认模板：8个垂直排列的小队面板"
L["template_default_apply_confirm"] = "确定应用默认模板？"

L["feared"] = "被恐惧"
L["charmed"] = "被魅惑"
L["stunned"] = "昏迷"
L["banished"] = "被放逐"
L["silenced"] = "沉默"
L["disoriented"] = "被迷惑"
L["out_of_control"] = "失控"
