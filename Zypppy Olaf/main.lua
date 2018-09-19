local version = "3.1"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local evade = module.internal("evade");
local common = module.load("ZypppyOlaf", "common")

local spellQ = {
range = 1000,
width = 90,
speed = 1600,
delay = 0.5,
boundingRadiusMod = 1
}

local spellW = {range = 250}

local spellE = {range = 325}



local menu = menu("ZypppyOlaf", "Olaf By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("qcombo", "Use Q in Combo", true)
menu.c:boolean("wcombo", "Use W in Combo", true)
menu.c:boolean("ecombo", "Use E in Combo", true)
menu.c:dropdown("emode", "E Mode", 1, {"Always", "Only as AA Reset"})
menu.c:slider("ecombohp", "E Only if HP >", 30, 1, 100, 1)

menu:menu("h", "Harass")
menu.h:boolean("qharass", "Use Q in Harass", true)
menu.h:slider("qharassmana", "Q Mana", 60, 1, 100, 1)

menu:menu("ks", "KillSteal")
menu.ks:boolean("qks", "Use Q to KillSteal", true)
menu.ks:boolean("eks", "Use E to KillSteal", true)

menu:menu("misc", "Misc")
menu.misc:boolean("autorcc" , "Auto R on CC", true)
menu.misc:menu("cctypes", "CC Types")
menu.misc.cctypes:boolean("blind", "Blind", true)
menu.misc.cctypes:boolean("stun", "Stun", true)
menu.misc.cctypes:boolean("silence", "Silence", true)
menu.misc.cctypes:boolean("snare", "Snare", true)
menu.misc.cctypes:boolean("taunt", "Taunt", true)
--menu.misc.cctypes:boolean("sleep", "Sleep", true)
menu.misc.cctypes:boolean("fear", "Fear", true)
menu.misc.cctypes:boolean("charm", "Charm", true)
menu.misc.cctypes:boolean("suppression", "Suppression", true)
menu.misc.cctypes:boolean("flee", "Flee", true)
menu.misc.cctypes:boolean("knockup", "Knockup", true)
menu.misc.cctypes:boolean("knockback", "Knockback", true)
menu.misc.cctypes:boolean("drowsy", "Drowsy", true)
menu.misc.cctypes:boolean("asleep", "Asleep", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)

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
	if dist <= 500 then
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

local QLevelDamage = {80, 125, 170, 245, 260}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
		common.CalculatePhysicalDamage(target,(QLevelDamage[player:spellSlot(0).level] +(common.GetTotalAD() * 1)), player)
	end
	return damage
end

local ELevelDamage = {70, 115, 160, 205, 250}
function EDamage(target)
	local damage = 0
	if player:spellSlot(1).level > 0 then
		damage =
		common.CalculatePhysicalDamage(target,(ELevelDamage[player:spellSlot(1).level] +(common.GetTotalAD() * 0.5)), player)
	end
	return damage
end

local enemy = nil

orb.combat.register_f_after_attack(
function()
    if menu.keys.combokey:get() then
	   if orb.combat.target and common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) <= spellE.range then
	      if menu.c.ecombo:get() and menu.c.emode:get() == 2 and player:spellSlot(2).state == 0 then
		  local targete = GetTargetE()
		  player:castSpell("obj", 2, targete)
		  player:attack(orb.combat.target)
		  return "on_after_attack_hydra"
		  
           end
		end
	end
	orb.combat.set_invoke_after_attack(false)
end
)
local function Combo()
    if menu.c.qcombo:get() and player:spellSlot(0).state == 0 then
	local target = GetTargetQ()
	   if common.IsValidTarget(target) and target then
	   local pos = preds.linear.get_prediction(spellQ, target)
	      if pos and player.pos:to2D():dist(pos.endPos) <= spellQ.range then
		  player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		  end
	   end
	end
	if menu.c.wcombo:get() and player:spellSlot(1).state == 0 then 
	local target = GetTargetW()
	   if common.IsValidTarget(target) and target then
		if (target.pos:dist(player) <= spellW.range) then
			player:castSpell("obj", 1, target)
		end
	   end	
	end
	if menu.c.ecombo:get() and menu.c.emode:get()== 1 and player:spellSlot(2).state == 0 and (player.health / player.maxHealth) * 100 > menu.c.ecombohp:get() then 
	local target = GetTargetE()
	   if common.IsValidTarget(target) and target then
		  if (target.pos:dist(player) <= spellE.range) then
			player:castSpell("obj", 2, target)
		  end
	   end	
	end 
end



local function Harass()
local target = GetTargetQ()
	if menu.h.qharass:get() then
	   if common.IsValidTarget(target) and target and (player.mana / player.maxMana) * 100 >= menu.h.qharassmana:get() then
		  local pos = preds.linear.get_prediction(spellQ, target)
	      if pos and player.pos:to2D():dist(pos.endPos) <= spellQ.range then
		  player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		  end
	   end
	end
end	  

local function AntiCC()
    if menu.misc.autorcc:get() and player:spellSlot(3).state == 0 then
       if menu.misc.cctypes.stun:get() and common.CheckBuffType(player, 5)
	   or menu.misc.cctypes.silence:get() and common.CheckBuffType(player, 7)
	   or menu.misc.cctypes.taunt:get() and common.CheckBuffType(player, 8)
	   or menu.misc.cctypes.snare:get() and common.CheckBuffType(player, 11)
	   --[[or menu.misc.cctypes.sleep:get() and common.CheckBuffType(player, 18)]]
	   or menu.misc.cctypes.fear:get() and common.CheckBuffType(player, 21)
	   or menu.misc.cctypes.charm:get() and common.CheckBuffType(player, 22)
	   or menu.misc.cctypes.suppression:get() and common.CheckBuffType(player, 24)
	   or menu.misc.cctypes.blind:get() and common.CheckBuffType(player, 25)
	   or menu.misc.cctypes.flee:get() and common.CheckBuffType(player, 28)
	   or menu.misc.cctypes.knockup:get() and common.CheckBuffType(player, 29)
	   or menu.misc.cctypes.knockback:get() and common.CheckBuffType(player, 30)
       or menu.misc.cctypes.drowsy:get() and common.CheckBuffType(player, 33)
       or menu.misc.cctypes.asleep:get() and common.CheckBuffType(player, 34) then
	   player:castSpell("obj", 3, player)
	   end
	end
end
	   
local function KillSteal()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.CheckBuffType(enemies, 17) then
			local hp = common.GetShieldedHealth("AD", enemies)
			if menu.ks.qks:get() then
				local distance = vec3(enemies.x, enemies.y, enemies.z):dist(player)
				if player:spellSlot(0).state == 0 and distance <= spellQ.range and QDamage(enemies) >= hp then
					local pos = preds.linear.get_prediction(spellQ, enemies)
					if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
						player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
			if menu.ks.eks:get() then
			   if player:spellSlot(2).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) <= spellE.range then
			      if EDamage(enemies) >= hp then
				  player:castSpell("obj", 2, enemies)
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
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 50)
		end
	end
end 

local function OnTick()
	KillSteal()
	AntiCC()
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