local version = "3.0"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local common = module.load("ZypppySivir", "common")

local spellQ = {
range = 1250, 
width = 90, 
speed = 1350, 
delay = 0.25, 
boundingRadiusMod = 0,
}

local spellW = {range = 500}

local spellE = {range = 500} 

local spellR = {range = 1000}

local menu = menu("ZypppySivir", "Sivir By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("qcombo", "Use Q in Combo", true)
menu.c:boolean("wcombo", "Use W in Combo", true)

menu:menu("h", "Harass")
menu.h:boolean("qharass", "Use Q in Harass", true)
menu.h:slider("qhmana", "Q Mana", 80, 1, 100, 1)
menu.h:boolean("wharass", "Use W in Harass", true)
menu.h:slider("whmana", "W Mana", 80, 1, 100, 1)

menu:menu("lc", "Lane Clear")
menu.lc:boolean("qlaneclear", "Use Q in Lane Clear", true)
menu.lc:slider("qlcmana", "Q Mana", 80, 1, 100, 1)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)

menu:menu("misc", "Misc.")
menu.misc:menu("Gap", "Gapcloser Settings")
menu.misc.Gap:boolean("GapA", "Use E for Anti-Gapclose", true)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

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
						player:castSpell("self", 2)
					end
				end
			end
		end
	end
end

orb.combat.register_f_after_attack(
function()
    if menu.keys.combokey:get() and player:spellSlot(1).state == 0 then
	   if orb.combat.target and common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) < 500 then
	      if menu.c.wcombo:get() then
		  player:castSpell("self", 1)
		  player:attack(orb.combat.target)
		  return "on_after_attack_hydra"
		  end
	   end
    end
	if menu.keys.harasskey:get() and player:spellSlot(1).state == 0 then
	   if orb.combat.target and common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) < 500 then
	      if menu.h.wharass:get() and (player.mana / player.maxMana) * 100 >= menu.h.whmana:get() then
		  player:castSpell("self", 1)
		  player:attack(orb.combat.target)
		  return "on_after_attack_hydra"
		  end
	   end
    end
	orb.combat.set_invoke_after_attack(false)
end
)

local function Combo()
if menu.c.qcombo:get() then
	local target = GetTargetQ()
	if common.IsValidTarget(target) then
		local pos = preds.linear.get_prediction(spellQ, target)
		if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
			if target.pos:dist(player.pos) <= spellQ.range then
				player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			end
		end	
	end 
end
end

local function Harass()
if menu.h.qharass:get() then
local target = GetTargetQ()
   if common.IsValidTarget(target) and target and (player.mana / player.maxMana) * 100 >= menu.h.qhmana:get() then
      if (target.pos:dist(player) < spellQ.range) then
	  local pos = preds.linear.get_prediction(spellQ, target)
	  if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
	     if target.pos:dist(player.pos) <= spellQ.range then
				player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		 end
	  end
	  end
   end
end
end
	
local function LaneClear()
if menu.lc.qlaneclear:get() and player:spellSlot(0).state == 0 and (player.mana / player.maxMana) * 100 >= menu.lc.qlcmana:get() then
local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
   for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do 
   local minion = objManager.minions[TEAM_ENEMY][i]
       if minion and not minion.isDead and common.IsValidTarget(minion) then
	   local minion = objManager.minions[TEAM_ENEMY][i]
	      if minion and minion.pos:dist(player.pos) <= spellQ.range and not minion.isDead and common.IsValidTarget(minion) then
		  local minionPos = vec3(minion.x, minion.y, minion.z)
		     if minionPos then
			 local seg = preds.linear.get_prediction(spellQ, minion)
			    if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
				player:castSpell("pos", 0, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
				end
			 end
		   end
		end
	end
end
end
	
local function OnDraw()
 if player.isOnScreen then 
    if menu.draws.drawq:get() then
	   graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 50)
	end
 end
end

local function OnTick()
    if menu.misc.Gap.GapA:get() then
		EGapcloser()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
	    Harass()
	end	
	if menu.keys.clearkey:get() then
	    LaneClear()
	end	
end

TS.load_to_menu(menu)
cb.add(cb.draw, OnDraw)
cb.add(cb.tick, OnTick)