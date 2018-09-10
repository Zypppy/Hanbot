local version = "3.0"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local common = module.load("ZypppyCaitlyn", "common")

local spellQ = {
range = 1250, 
width = 60, 
speed = 2200, 
delay = 0.25, 
boundingRadiusMod = 0
}


local spellW = {
range = 800, 
radius = 67.5, 
speed = math.huge, 
delay = 1.5, 
boundingRadiusMod = 0 
}

local spellE = {
range = 750, 
width = 70, 
speed = math.huge, 
delay = 0.35, 
boundingRadiusMod = 0,
collision = {
hero = false,
minion = true
} 
}


local menu = menu("ZypppyCaitlyn", "Caitlyn By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("ecombo", "Use E in Combo", true)

menu:menu("h", "Harass")
menu.h:boolean("qharass", "Use Q in Harass", true)
menu.h:slider("manaq", "Q Mana", 80, 1, 100, 1)

--[[menu:menu("ks", "KillSteal")
menu.ks:boolean("qks", "Use Q to KillSteal", true)]]

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)

menu:menu("misc", "Misc.")
menu.misc:menu("setq", "Q Settings")
menu.misc.setq:boolean("logicalq" , "On Trappped Enemies", true)
menu.misc:menu("setw", "W Settings")
menu.misc.setw:boolean("logicalw" , "On Hard CC'ed", true)
--menu.misc.setq:boolean("teleportw" , "On Teleport", true)
menu.misc:menu("Gap", "Gapcloser Settings")
menu.misc.Gap:boolean("GapE", "Use E for Anti-Gapclose", true)
menu.misc.Gap:boolean("GapW", "Use W for Anti-Gapclose", true)

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

local TargetSelectionGap = function(res, obj, dist)
	if dist < (spellE.range * 2) - 70 then
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

local waiting = 0
local uhhh = 0
local enemy = nil

local function EGapcloser()
if menu.misc.Gap.GapE:get() then
   for i = 0, objManager.enemies_n - 1 do
   local dasher = objManager.enemies[i]
       if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
          if dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
             player.pos:dist(dasher.path.point[1]) < spellE.range then
             if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
                player:castSpell("pos", 2, dasher.path.point2D[1])
             end
          end
       end
    end
end
end
local function WGapcloser()
if menu.misc.Gap.GapW:get() then
   for i = 0, objManager.enemies_n - 1 do
   local dasher = objManager.enemies[i]
       if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
          if dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
             player.pos:dist(dasher.path.point[1]) < spellW.range then
             if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
                player:castSpell("pos", 1, dasher.path.point2D[1])
             end
          end
       end
    end
end
end

local function Combo()
if menu.c.ecombo:get() then 
local target = GetTargetE()
   if common.IsValidTarget(target) and target then
   local pos = preds.linear.get_prediction(spellE, target)
   if pos and player.pos:to2D():dist(pos.endPos) <= spellE.range and not preds.collision.get_prediction(spellE, pos, target) then
      player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
   end
end
end
end 

local function Harass()
      if menu.h.qharass:get() then
	  local target = GetTargetQ()
	     if common.IsValidTarget(target) and target and (player.mana / player.maxMana) * 100 >= menu.h.manaq:get() then
		    if (target.pos:dist(player) < spellQ.range) and (target.pos:dist(player) > 650) then 
			local pos = preds.linear.get_prediction(spellQ, target)
			   if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
			   player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
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
	if menu.draws.draww:get() then
	   graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorq:get(), 50)
	end
	if menu.draws.drawe:get() then
	   graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colorq:get(), 50)
	end
 end
end 

local function AutoCC()
local enemy = common.GetEnemyHeroes()
      for i, enemies in ipairs(enemy) do
	      if enemies and common.IsValidTarget(enemies) and not common.CheckBuffType(enemies, 17) then
		     if menu.misc.setw.logicalw:get() and player:spellSlot(1).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) <= spellW.range then
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
local function AutoTrapped()
local enemy = common.GetEnemyHeroes()
      for i, enemies in ipairs(enemy) do
	      if enemies and common.IsValidTarget(enemies) then
		     if menu.misc.setq.logicalq:get() and player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) <= spellQ.range then
			 local pos = preds.linear.get_prediction(spellQ, enemies)
			    if (common.CheckBuff(enemies, "caitlynyordletrapdebuff")) then
			       if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
			       player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		           end
                end
             end
          end
       end		  
end	  

local function OnTick()
       AutoTrapped()
       AutoCC()
    if menu.misc.Gap.GapE:get() then
		EGapcloser()
	end
	if menu.misc.Gap.GapW:get() then
		WGapcloser()
	end	
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
end

cb.add(cb.draw, OnDraw)

orb.combat.register_f_pre_tick(OnTick)