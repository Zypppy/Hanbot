local version = "3.1"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local evade = module.internal("evade");
local common = module.load("ZypppyYasuo", "common")

local spellQ1 = {
range = 430,
width = 30,
speed = 8700,
delay = 0.4,
boundingRadiusMod = 1
}
local spellQ2 = {
range = 430,
width = 30,
speed = math.huge,
delay = 0.4,
boundingRadiusMod = 1
}
local spellQ3 = {
range = 1000,
width = 90,
speed = 1200,
delay = 0.35,
boundingRadiusMod = 1
}
local spellW = {range = 400}
local spellE = {range = 475}
local spellR = {range = 1400}



local menu = menu("ZypppyYasuo", "Yasuo By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("qcombo", "Use Q in Combo", true)
menu.c:boolean("qnadopred", "Use Slow Pred for Q", true)
menu.c:boolean("ecombo", "Use E in Combo", true)
menu.c:boolean("gape", "Use E for Gapclose on Minion", true)

menu:menu("h", "Harass")
menu.h:boolean("qharass", "Use Q in Harass", true)
menu.h:boolean("qnadoharass", "Use Tornado in Harass", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 255, 255, 255)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

local TargetSelectionQ = function(res, obj, dist)
	if dist <= spellQ1.range then
	   res.obj = obj
	   return true
	end
	if dist <= spellQ2.range then
	   res.obj = obj
	   return true
	end
	if dist <= spellQ3.range then
	   res.obj = obj
	   return true
	end
end
local GetTargetQ = function()
	return TS.get_result(TargetSelectionQ).obj
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
local TargetSelectionR = function(res, obj, dist)
	if dist <= spellR.range then
		res.obj = obj
		return true
	end
end
local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
end
local TargetSelectionGap = function(res, obj, dist)
	if dist < (spellR.range) then
		res.obj = obj
		return true
	end
end
local GetTargetGap = function()
	return TS.get_result(TargetSelectionGap).obj
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
local function count_minions_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
		local enemy = objManager.minions[TEAM_ENEMY][i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end
local function GetClosestMobToEnemyForGap()
	local closestMinion = nil
	local closestMinionDistance = 9999
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) then
			for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
				local minion = objManager.minions[TEAM_ENEMY][i]
				if
					minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
						minion.pos:dist(player.pos) < spellE.range and
						minion.type == TYPE_MINION
				 then
						local minionPos = vec3(minion.x, minion.y, minion.z)
						if minionPos:dist(enemies) < spellE.range then
							local minionDistanceToMouse = minionPos:dist(enemies)

							if minionDistanceToMouse < closestMinionDistance then
								closestMinion = minion
								closestMinionDistance = minionDistanceToMouse
							end
						end
					end
				end
			end
		end

	return closestMinion
end
local QLevelDamage = {20, 45, 70, 95, 120}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
		common.CalculatePhysicalDamage(target,(QLevelDamage[player:spellSlot(0).level] +(common.GetTotalAD() * 1)), player)
	end
	return damage
end

local enemy = nil

local function Combo()
    if menu.c.qcombo:get() and player:spellSlot(0).state == 0 and not menu.c.qnadopred:get() then
	local target = GetTargetQ()
	   if common.IsValidTarget(target) and target and player:spellSlot(0).name ~= "YasuoQ3Wrapper" then
	   local pos = preds.linear.get_prediction(spellQ1, target)
	      if pos and player.pos:to2D():dist(pos.endPos) <= spellQ1.range then
		  player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		  end
	   end
	   if common.IsValidTarget(target) and target and player:spellSlot(0).name == "YasuoQ3Wrapper" then
	   local pos = preds.linear.get_prediction(spellQ3, target)
	      if pos and player.pos:to2D():dist(pos.endPos) <= spellQ3.range then
		  player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		  end
	   end
	end
	if menu.c.qcombo:get() and player:spellSlot(0).state == 0 and menu.c.qnadopred:get() then
	local target = GetTargetQ()
	   if common.IsValidTarget(target) and target and player:spellSlot(0).name ~= "YasuoQ3Wrapper" then
	   local pos = preds.linear.get_prediction(spellQ1, target)
	      if pos and player.pos:to2D():dist(pos.endPos) <= spellQ1.range and trace_filter(spellQ1, pos, target) then
		  player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		  end
	   end
	   if common.IsValidTarget(target) and target and player:spellSlot(0).name == "YasuoQ3Wrapper" then
	   local pos = preds.linear.get_prediction(spellQ3, target)
	      if pos and player.pos:to2D():dist(pos.endPos) <= spellQ3.range and trace_filter(spellQ3, pos, target) then
		  player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		  end
	   end
	end
	if menu.c.ecombo:get() then
	local target = GetTargetE()
	   if common.IsValidTarget(target) and target then
	      if target and vec3(target.x, target.y, target.z):dist(player.pos) <= spellE.range then
		  player:castSpell("obj", 2, target)
		  end
	   end
	end
	if menu.c.gape:get()then
	local targets = GetTargetGap()
	   if common.IsValidTarget(targets) and targets then
	      if (targets.pos:dist(player) > spellQ1.range) then
		  local minion = GetClosestMobToEnemyForGap()
		      if minion and vec3(minion.x, minion.y, minion.z):dist(player.pos) <= spellE.range then
			  player:castSpell("obj", 2, minion)
			  end
		  end
       end
    end
end	
local function Harass()
    if menu.h.qharass:get() and player:spellSlot(0).state == 0 then
	local target = GetTargetQ()
	   if common.IsValidTarget(target) and target and player:spellSlot(0).name ~= "YasuoQ3Wrapper" then
	   local pos = preds.linear.get_prediction(spellQ1, target)
	      if pos and player.pos:to2D():dist(pos.endPos) <= spellQ1.range then
		  player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		  end
	   end
	   if common.IsValidTarget(target) and target and player:spellSlot(0).name == "YasuoQ3Wrapper" and menu.h.qnadoharass:get() then
	   local pos = preds.linear.get_prediction(spellQ3, target)
	      if pos and player.pos:to2D():dist(pos.endPos) <= spellQ3.range then
		  player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		  end
	   end
	end
end
				 
local function OnDraw()
	if player.isOnScreen then 
		if menu.draws.drawq:get() and player:spellSlot(0).name ~= "YasuoQ3Wrapper" then
			graphics.draw_circle(player.pos, spellQ1.range, 2, menu.draws.colorq:get(), 50)
		end
		if menu.draws.drawq:get() and player:spellSlot(0).name == "YasuoQ3Wrapper" then
			graphics.draw_circle(player.pos, spellQ3.range, 2, menu.draws.colorq:get(), 50)
		end
		if menu.draws.drawr:get() then
			graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 50)
		end
	end
end 

local function OnTick()
	if menu.keys.combokey:get() then
	   Combo()
	end
	if menu.keys.harasskey:get() then
	   Harass()
	end
end

cb.add(cb.draw, OnDraw)
cb.add(cb.tick, OnTick)

orb.combat.register_f_pre_tick(OnTick)