local version = "3.5"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local common = module.load("ZypppyDiana", "common")

local spellQ = {
range = 900, 
radius = 150, 
speed = 1900, 
delay = 0.25, 
boundingRadiusMod = 1
}

local spellW = {range = 250}
local spellE = {range = 825}
local spellR = {range = 450}

local menu = menu("ZypppyDiana", "Diana By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("qcombo", "Use Q in Combo", true)
menu.c:boolean("ecombo", "Use E in Combo", true)
menu.c:boolean("wcombo", "Use W in Combo", true)
menu.c:boolean("rcombo", "Use R in Combo", true)
menu.c:slider("rhit", "R Enemies Hit", 2, 1, 5, 1)

menu:menu("h", "Harass")
menu.h:boolean("qharass", "Use Q in Harass", true)
menu.h:slider("manaq", "Q Mana", 80, 1, 100, 1)

menu:menu("ks", "KillSteal")
menu.ks:boolean("qks", "Use Q to KillSteal", true)
menu.ks:boolean("eks", "Use E to KillSteal", true)
menu.ks:boolean("rks", "Use R to KillSteal", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawdamage", "Draw Damage", true)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist <= spellQ.range then
		res.obj = obj
		return true
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

local TargetSelectionR = function(res, obj, dist)
	if dist <= spellR.range then
		res.obj = obj
		return true
	end
end
local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
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

local QLevelDamage = {60, 95, 130, 165, 200}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
		common.CalculateMagicDamage(target,(QLevelDamage[player:spellSlot(0).level] +(common.GetTotalAP() * .7)), player)
	end
	return damage
end
local ELevelDamage = {40, 60, 80, 100, 120}
function EDamage(target)
	local damage = 0
	if player:spellSlot(1).level > 0 then
		damage =
		common.CalculateMagicDamage(target,(ELevelDamage[player:spellSlot(2).level] +(common.GetTotalAP() * .4)), player)
	end
	return damage
end
local RLevelDamage = {200, 300, 400}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
		common.CalculateMagicDamage(target,(RLevelDamage[player:spellSlot(3).level] +(common.GetTotalAP() * .6)), player)
	end
	return damage
end

local waiting = 0
local uhhh = 0
local enemy = nil

local function Combo()
   if menu.c.qcombo:get() then
   local target = GetTargetQ()
      if common.IsValidTarget(target) and target then
	  local pos = preds.circular.get_prediction(spellQ, target)
	     if pos and player.pos:to2D():dist(pos.endPos) < spellQ.range then
		    player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		 end
      end
   end
   if menu.c.wcombo:get() then
   local target = GetTargetW()
      if common.IsValidTarget(target) and target then
	     if (target.pos:dist(player) < spellW.range) then
		    player:castSpell("self", 1)
		 end
	  end
   end
   if menu.c.rcombo:get() then
   local target = GetTargetR()
      if common.IsValidTarget(target) and target then
	     if #count_enemies_in_range(player.pos, spellR.range) >= menu.c.rhit:get() then
		    player:castSpell("self", 3)
		 end
	  end
   end
   if menu.c.ecombo:get() then
   local target = GetTargetE()
      if common.IsValidTarget(target) and target then
	     if (target.pos:dist(player) <= spellE.range) and (common.CheckBuff(target, "dianamoonlight")) then
		    player:castSpell("obj", 2, target)
		 end
	  end
   end	  
end

local function Harass()
   if menu.h.qharass:get() then
   local target = GetTargetQ()
	  if common.IsValidTarget(target) and target and (player.mana / player.maxMana) * 100 >= menu.h.manaq:get() then
		 if (target.pos:dist(player) <= spellQ.range) then 
		 local pos = preds.circular.get_prediction(spellQ, target)
			if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
			   player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			end
		 end
	  end
   end
end	  	 

local function KillSteal()
local enemy = common.GetEnemyHeroes()
   for i, enemies in ipairs(enemy) do
      if enemies and common.IsValidTarget(enemies) and not common.CheckBuffType(enemies, 17) then
	  local hp = common.GetShieldedHealth("AP", enemies)
	     if menu.ks.qks:get() then
		    if player:spellSlot(0).state == 0 and QDamage(enemies) >= hp then
			local pos = preds.circular.get_prediction(spellQ, enemies)
			   if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
			      player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			   end
			end
		 end
		 if menu.ks.eks:get() then
		    if player:spellSlot(2).state == 0 and EDamage(enemies) >= hp then
			   if (enemies.pos:dist(player) <= spellE.range) then
			      player:castSpell("obj", 2, enemies)
			   end
			end
		 end
		 if menu.ks.rks:get() then
		    if player:spellSlot(3).state == 0 and RDamage(enemies) >= hp then
			   if (enemies.pos:dist(player) <= spellR.range) then
			      player:castSpell("self", 3)
			   end
			end
		 end
	  end
   end  
end

function DrawDamages(target)
	if target.isVisible and not target.isDead then
		for i = 0, graphics.anchor_n - 1 do
			local obj = objManager.toluaclass(graphics.anchor[i].ptr)
			if obj.type == player.type and obj.team ~= player.team and obj.isOnScreen then
				local hp_bar_pos = graphics.anchor[i].pos
				local xPos = hp_bar_pos.x - 46
				local yPos = hp_bar_pos.y + 11.5
				if obj.charName == "Annie" then
					yPos = yPos + 2
				end
				local Qdmg = 0
				local Edmg = 0
				local Rdmg = 0
				Qdmg = QDamage(obj)
				Edmg = EDamage(obj)
				Rdmg = RDamage(obj)
		 
				local damage = obj.health -(Qdmg + Edmg + Rdmg)
				local x1 = xPos +((obj.health / obj.maxHealth) * 102)
				local x2 = xPos +(((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if((Qdmg + Edmg + Rdmg) < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if((Qdmg + Edmg + Rdmg) > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if(math.floor((EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
			tostring(math.floor(EDamage(target) + RDamage(target) + QDamage(target))) ..
			" (" ..
			tostring(math.floor((EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)) ..
			"%)" .. "Not Killable",
			20,
			pos.x + 55,
			pos.y - 80,
			graphics.argb(255, 255, 153, 51)
			)
		end
		if(math.floor((EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
			tostring(math.floor(EDamage(target) + RDamage(target) + QDamage(target))) ..
			" (" ..
			tostring(math.floor((EDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)) ..
			"%)" .. "Kilable",
			20,
			pos.x + 55,
			pos.y - 80,
			graphics.argb(255, 150, 255, 200)
			)
		end
	end
end		
	
local function OnDraw()
 if player.isOnScreen then 
    if menu.draws.drawq:get() and player:spellSlot(0).state == 0 then
	   graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 50)
	end
	if menu.draws.draww:get() and player:spellSlot(1).state == 0 then
	   graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorq:get(), 50)
	end
	if menu.draws.drawe:get() and player:spellSlot(2).state == 0 then
	   graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colorq:get(), 50)
	end
	if menu.draws.drawr:get() and player:spellSlot(3).state == 0 then
	   graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 50)
	end
 end
 if menu.draws.drawdamage:get() then
 local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
	   if enemies and common.IsValidTarget(enemies)and player.pos:dist(enemies) <= 2000 and enemies.isOnScreen and not common.CheckBuffType(enemies, 17) then
	    DrawDamages(enemies)
	   end
	end
 end
end 

local function OnTick()
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
	KillSteal()
end

cb.add(cb.draw, OnDraw)
cb.add(cb.tick, OnTick)