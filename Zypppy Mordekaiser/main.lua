local version = "3.0"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local common = module.load("ZypppyMordekaiser", "common")

local spellQ = {
range = 625, 
width = 160, 
speed = math.huge, 
delay = 0.5, 
boundingRadiusMod = 0
}

local spellW = {
range = 375
}

local spellE = {
range = 800, 
width = 200, 
speed = 500, 
delay = 0.25, 
boundingRadiusMod = 0,
collision = {
		hero = false,
		minion = false,
		wall = true
	}
}

local spellR = {
range = 650
}

local menu = menu("ZypppyMordekaiser", "Mordekaiser By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("qcombo", "Use Q in Combo", true)
menu.c:boolean("wcombo", "Use W in Combo", false)
menu.c:slider("whealth", "W Health for Shield", 80, 1, 100, 1)
menu.c:boolean("ecombo", "Use E in Combo", true)

menu:menu("h", "Harass")
menu.h:boolean("qharass", "Use Q in Harass", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw Passive Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawr", "Draw R Range", true)
menu.draws:color("colorr", "  ^- Color", 255, 255, 255, 255)

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

local function Combo()
if menu.c.qcombo:get() then
   local target = GetTargetQ()
   if common.IsValidTarget(target) and target then
   local pos = preds.linear.get_prediction(spellQ, target)
      if pos and pos.startPos:dist(pos.endPos) <= spellQ.range and player:spellSlot(0).state == 0 then
         if target.pos:dist(player.pos) <= spellQ.range then
	     player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
         end
      end
   end
end

if menu.c.wcombo:get() and player:spellSlot(1).state == 0 then
   local target = GetTargetW()
   if common.IsValidTarget(target) and target then
      if (target.pos:dist(player) < spellW.range) then
	     if (player.health / player.maxHealth) * 100 <= menu.c.whealth:get() then
		 player:castSpell("self", 1)
		 end
	  end
   end
end

if menu.c.ecombo:get() and player:spellSlot(2).state == 0 then
   local target = GetTargetE()
   if common.IsValidTarget(target) and target then
   local pos = preds.linear.get_prediction(spellE, target)
   if pos and pos.startPos:dist(pos.endPos) <= spellE.range then
      if target.pos:dist(player.pos) <= spellE.range then
	     player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
      end
   end
end
end
end

local function Harass()
if menu.h.qharass:get() and player:spellSlot(0).state == 0 then
   local target = GetTargetQ()
   if common.IsValidTarget(target) and target then
   local pos = preds.linear.get_prediction(spellQ, target)
      if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
         if target.pos:dist(player.pos) <= spellQ.range then
	     player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
         end
      end
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
end
   
local function OnTick()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
end

TS.load_to_menu(menu)
cb.add(cb.draw, OnDraw)
cb.add(cb.tick, OnTick)