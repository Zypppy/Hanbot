local version = "3.0"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local evade = module.internal("evade");
local common = module.load("ZypppyNasus", "common")

local spellQ = {range = 250}

local menu = menu("ZypppyNasus", "Nasus By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("qcombo", "Use Q in Combo", true)


menu:menu("lh", "Last Hit")
menu.lh:boolean("qlh", "Use Q to LastHit", true)
menu.lh:slider("qlhmana", "Q Mana", 60, 1, 100, 1)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)

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

local QLevelDamage = {30, 50, 70, 90, 110}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
		common.CalculatePhysicalDamage(target,(QLevelDamage[player:spellSlot(0).level] +(common.GetTotalAD())), player)
	end
	return damage
end

local enemy = nil

orb.combat.register_f_after_attack(
function()
    if menu.keys.combokey:get() then
	   if orb.combat.target and common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) <= spellQ.range then
	      if menu.c.qcombo:get() and player:spellSlot(0).state == 0 then
		  local targetq = GetTargetQ()
		  player:castSpell("self", 0)
		  player:attack(orb.combat.target)
		  return "on_after_attack_hydra"
		  
           end
		end
	end
	orb.combat.set_invoke_after_attack(false)
end
)

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

local function LastHit()
   if menu.lh.qlh:get() and player:spellSlot(0).state == 0 and (player.mana / player.maxMana) * 100 >= menu.lh.qlhmana:get() then
      for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
	   local minion = objManager.minions[TEAM_ENEMY][i]
	   local hp = common.GetShieldedHealth("AD", minion)
	     if minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and common.IsValidTarget(minion) then
		    if player.pos:dist(minion) <= spellQ.range and QDamage(minion) >= hp then
			player:castSpell("self", 0)
			player:attack(minion)
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
	if menu.keys.lastkey:get() or menu.keys.clearkey:get() then
		LastHit()
	end
end

cb.add(cb.draw, OnDraw)
cb.add(cb.tick, OnTick)

orb.combat.register_f_pre_tick(OnTick)