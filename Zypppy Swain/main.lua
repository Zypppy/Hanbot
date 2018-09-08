local version = "3.0"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local common = module.load("ZypppySwain", "common")

local spellQ = {
range = 725, 
width = 200, 
speed = math.huge, 
delay = 0.5, 
boundingRadiusMod = 0,
collision = {
hero = false,
minion = true
}
}

local spellW = {
range = 3500, 
radius = 325, 
speed = math.huge, 
delay = 2.5, 
boundingRadiusMod = 1 
}

local spellE = {
range = 850,
width = 100,
speed = 1000,
delay = 0.5,
boundingRadiusMod = 1,
collision = {
hero = false,
minion = true
}
} 

local spellR = {range = 650}

local menu = menu("ZypppySwain", "Swain By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("qcombo", "Use Q in Combo", true)
menu.c:boolean("wcombo", "Use W in Combo", true)
menu.c:dropdown("wmode", "W Mode", 2, {"Always", "Only Hard CC"})
menu.c:boolean("ecombo", "Use E in Combo", true)
menu.c:boolean("rcombo", "Use R", true)
menu.c:slider("rhit", "R Enemies Hit", 2, 1, 5, 1)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 255, 255, 255)

menu:menu("misc", "Misc.")
menu.misc:menu("sete", "E Settings")
menu.misc.sete:boolean("EDash", "Auto E on Dashes", true)
menu.misc.sete:boolean("ECC", "Auto E on CC'ed enemies", true)
menu.misc.sete:boolean("Einterr", "Auto E to Interrupt", true)
menu.misc.sete:menu("interruptmenue", "E Interrupting")
menu.misc:menu("setw", "W Settings")
menu.misc.setw:boolean("WCC", "Auto W on CC'ed enemies", true)
menu.misc:menu("Gap", "Gapcloser Settings")
menu.misc.Gap:boolean("GapA", "Use E for Anti-Gapclose", true)

local interruptableSpells = {
["anivia"] = {
{menuslot = "R", slot = 3, spellname = "glacialstorm", channelduration = 6}
},
["caitlyn"] = {
{menuslot = "R", slot = 3, spellname = "caitlynaceinthehole", channelduration = 1}
},
["ezreal"] = {
{menuslot = "R", slot = 3, spellname = "ezrealtrueshotbarrage", channelduration = 1}
},
["fiddlesticks"] = {
{menuslot = "W", slot = 1, spellname = "drain", channelduration = 5},
{menuslot = "R", slot = 3, spellname = "crowstorm", channelduration = 1.5}
},
["gragas"] = {
{menuslot = "W", slot = 1, spellname = "gragasw", channelduration = 0.75}
},
["janna"] = {
{menuslot = "R", slot = 3, spellname = "reapthewhirlwind", channelduration = 3}
},
["karthus"] = {
{menuslot = "R", slot = 3, spellname = "karthusfallenone", channelduration = 3}
}, --common.IsValidTargetTarget will prevent from casting @ karthus while he's zombie
["katarina"] = {
{menuslot = "R", slot = 3, spellname = "katarinar", channelduration = 2.5}
},
["lucian"] = {
{menuslot = "R", slot = 3, spellname = "lucianr", channelduration = 2}
},
["lux"] = {
{menuslot = "R", slot = 3, spellname = "luxmalicecannon", channelduration = 0.5}
},
["malzahar"] = {
{menuslot = "R", slot = 3, spellname = "malzaharr", channelduration = 2.5}
},
["masteryi"] = {
{menuslot = "W", slot = 1, spellname = "meditate", channelduration = 4}
},
["missfortune"] = {
{menuslot = "R", slot = 3, spellname = "missfortunebullettime", channelduration = 3}
},
["nunu"] = {
{menuslot = "R", slot = 3, spellname = "absolutezero", channelduration = 3}
},
	--excluding Orn's Forge Channel since it can be cancelled just by attacking him
["pantheon"] = {
{menuslot = "R", slot = 3, spellname = "pantheonrjump", channelduration = 2}
},
["shen"] = {
{menuslot = "R", slot = 3, spellname = "shenr", channelduration = 3}
},
["twistedfate"] = {
{menuslot = "R", slot = 3, spellname = "gate", channelduration = 1.5}
},
["varus"] = {
{menuslot = "Q", slot = 0, spellname = "varusq", channelduration = 4}
},
["warwick"] = {
{menuslot = "R", slot = 3, spellname = "warwickr", channelduration = 1.5}
},
["xerath"] = {
{menuslot = "R", slot = 3, spellname = "xerathlocusofpower2", channelduration = 3}
}
}



for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.misc.sete.interruptmenue:boolean(
			string.format(tostring(enemy.charName) .. tostring(spell.menuslot)),
			"Interrupt " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
			true
			)
		end
	end
end

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

local function AutoInterrupt(spell)
	if menu.misc.see.Einterr:get() and player:spellSlot(2).state == 0 then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if menu.misc.setq.interruptmenuq[spell.owner.charName .. spellCheck.menuslot]:get() and 
					string.lower(spell.name) == spellCheck.spellname then
						if player.pos2D:dist(spell.owner.pos2D) <= spellE.range and common.IsValidTarget(spell.owner) and 
						player:spellSlot(2).state == 0 then 
							local pos = preds.linear.get_prediction(spellE, spell.owner)
							if pos and pos.startPos:dist(pos.endPos) <= spellE.range then
								if not preds.collision.get_prediction(spellE, pos, spell.owner) then
									player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end 
					end
				end
			end
		end
	end 
end  

local TargetSelectionQ = function(res, obj, dist)
	if dist <= spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetQ = function()
	return TS.get_result(TargetSelectionQ).obj
end
local TargetSelectionW = function(res, obj, dist)
	if dist <= spellW.range then
		res.obj = obj
		return true
	end
end
local GetTargetW = function()
	return TS.get_result(TargetSelectionW).obj
end
local TargetSelectionE = function(res, obj, dist)
	if dist <= spellE.range then
		res.obj = obj
		return true
	end
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
end

local TargetSelectionGap = function(res, obj, dist)
	if dist <(spellE.range * 2) - 70 then
		res.obj = obj
		return true
	end
end

local GetTargetGap = function()
	return TS.get_result(TargetSelectionGap).obj
end

local function count_enemies_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.enemies_n - 1 do
		local enemy = objManager.enemies[i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end

local trace_filter = function(input, segment, target)
	if preds.trace.linear.hardlock(input, segment, target) then
		return true
	end
	if preds.trace.linear.hardlockmove(input, segment, target) then
		return true
	end
	if segment.startPos:dist(segment.endPos) <= 625 then
		return true
	end
	if preds.trace.newpath(target, 0.033, 0.5) then
		return true
	end
end

local function EGapcloser()
	if menu.misc.Gap.GapA:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
				player.pos:dist(dasher.path.point[1]) < spellE.range then
					if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
						player:castSpell("obj", 2, player)
					end
				end
			end
		end
	end
end

local function Combo()
if menu.c.qcombo:get() then
	local target = GetTargetQ()
	if common.IsValidTarget(target) then
		local pos = preds.linear.get_prediction(spellQ, target)
		if pos and pos.startPos:dist(pos.endPos) <= spellQ.range and not preds.collision.get_prediction(spellQ, pos, target) then
			if target.pos:dist(player.pos) <= spellQ.range then
				player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			end
		end	
	end 
end

if menu.c.wcombo:get() then
	local target = GetTargetW()
	if common.IsValidTarget(target) then
		local pos = preds.circular.get_prediction(spellW, target) 
		if pos and pos.startPos:dist(pos.endPos) <= spellW.range then
			if target.pos:dist(player.pos) <= spellW.range and menu.c.wmode:get() == 1 then
				player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			end
			if target.pos:dist(player.pos) <= spellW.range and menu.c.wmode:get() == 2 then
				if common.CheckBuffType(target, 11) or
				common.CheckBuffType(target, 5) or
				common.CheckBuffType(target, 22) or 
				common.CheckBuffType(target, 8) or 
				common.CheckBuffType(target, 24) or 
				common.CheckBuffType(target, 29) or 
				common.CheckBuffType(target, 32) or 
				common.CheckBuffType(target, 34) then
					player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				end
			end
		end
	end
end

if menu.c.ecombo:get() then
	local target = GetTargetE()
   if common.IsValidTarget(target) then
	local pos = preds.linear.get_prediction(spellE, target) 
	if pos and pos.startPos:dist(pos.endPos) <= spellE.range then
		if target.pos:dist(player.pos) <= spellE.range and not preds.collision.get_prediction(spellE, pos, target) then
			player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		end
	end 
end 
end
	  
if menu.c.rcombo:get() then
   if #count_enemies_in_range(player.pos, spellR.range) >= menu.c.rhit:get() then 
      player:castSpell("self", 3)
   end
end
end
				 
local function OnDraw()
 if player.isOnScreen then 
    if menu.draws.drawq:get() then
	   graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 50)
	end
	if menu.draws.draww:get() then
	   graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorq:get(), 50)
	end
	if menu.draws.drawe:get() then
	   graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colorq:get(), 50)
	end
	if menu.draws.drawr:get() then
	   graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorq:get(), 50)
	end
 end
end

local function AutoCC()
local enemy = common.GetEnemyHeroes()
      for i, enemies in ipairs(enemy) do
	      if enemies and common.IsValidTarget(enemies) and not common.CheckBuffType(enemies, 17) then
		     if menu.misc.sete.ECC:get() and player:spellSlot(2).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range then
			 local pos = preds.linear.get_prediction(spellE, enemies)
			    if common.CheckBuffType(enemies, 11) or 
				   common.CheckBuffType(enemies, 5) or 
				   common.CheckBuffType(enemies, 22) or
				   common.CheckBuffType(enemies, 8) or
				   common.CheckBuffType(enemies, 24) or
				   common.CheckBuffType(enemies, 29) or
				   common.CheckBuffType(enemies, 32) or
				   common.CheckBuffType(enemies, 34) then
				   if pos and pos.startPos:dist(pos.endPos) < spellE.range and not preds.collision.get_prediction(spellE, pos, enemies) then
				   player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				   end
				 end
			 end
             if menu.misc.setw.WCC:get() and player:spellSlot(1).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellW.range then
			 local pos = preds.circular.get_prediction(spellW, enemies)
			    if common.CheckBuffType(enemies, 11) or 
				   common.CheckBuffType(enemies, 5) or 
				   common.CheckBuffType(enemies, 22) or
				   common.CheckBuffType(enemies, 8) or
				   common.CheckBuffType(enemies, 24) or
				   common.CheckBuffType(enemies, 29) or
				   common.CheckBuffType(enemies, 32) or
				   common.CheckBuffType(enemies, 34) then
				   if pos and pos.startPos:dist(pos.endPos) < spellW.range then
				   player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				   end
				 end
			 end			 
		  end
       end		  
end

local function AutoDash()
	local seg = {}
	local target =
		TS.get_result(
		function(res, obj, dist)
			if dist <= spellE.range and obj.path.isActive and obj.path.isDashing and not common.CheckBuffType(enemies, 17) then
				res.obj = obj
				return true
			end
		end
	).obj
	if target then
		local pred_pos = preds.core.lerp(target.path, network.latency + spellE.delay, target.path.dashSpeed)
		if pred_pos and pred_pos:dist(player.path.serverPos2D) <= spellE.range then
			seg.startPos = player.path.serverPos2D
			seg.endPos = vec2(pred_pos.x, pred_pos.y)

			if not preds.collision.get_prediction(spellE, seg, target.pos:to2D()) then
				player:castSpell("pos", 2, vec3(pred_pos.x, target.y, pred_pos.y))
			end
		end
	end
end
 
local function OnTick()
        AutoCC()
	    AutoDash()
    if menu.misc.Gap.GapA:get() then
		EGapcloser()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
end

TS.load_to_menu(menu)
cb.add(cb.draw, OnDraw)
cb.add(cb.tick, OnTick)