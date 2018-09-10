local version = "3.7"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local common = module.load("ZypppyVeigar", "common")

local spellQ = {
range = 850, 
width = 70, 
speed = 2000, 
delay = 0.25, 
boundingRadiusMod = 1,
collision = {
		hero = false,
		minion = true
	}
}

local spellW = {
range = 900, 
radius = 225, 
speed = math.huge, 
delay = 1.35, 
boundingRadiusMod = 1 
}

local spellE = {
range = 800, 
radius = 300, 
speed = math.huge, 
delay = 0.8, 
boundingRadiusMod = 1 
}

local spellR = {range = 650}

local menu = menu("ZypppyVeigar", "Veigar By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("qcombo", "Use Q in Combo", true)
menu.c:boolean("wcombo", "Use W in Combo", true)
menu.c:dropdown("wmode", "W Mode", 2, {"Always", "Only Hard CC", "Slowed"})
menu.c:boolean("ecombo", "Use E in Combo", true)
menu.c:boolean("rcombo", "Use R To Finsih Enemy", true)
menu.c:boolean("semirc", "Semi Manual R (check keybinds)", true)

menu:menu("h", "Harass")
menu.h:boolean("qharass", "Use Q in Harass", true)
menu.h:slider("manaq", "Q Mana", 80, 1, 100, 1)
menu.h:boolean("wharass", "Use W in Harass", true)
menu.h:slider("manaw", "W Mana", 80, 1, 100, 1)

menu:menu("lc", "Lane Clear")
menu.lc:boolean("qlc", "Use Q To Lane Clear", true)
menu.lc:dropdown("qlcmode", "Q Mode", 2, {"Push", "Only Last Hit"}) 
menu.lc:slider("manaqlc", "Q Mana", 30, 1, 100, 1)
menu.lc:boolean("wlc", "Use W To Lane Clear", true) 
menu.lc:slider("manawlc", "W Mana", 30, 1, 100, 1)


menu:menu("lh", "Last Hit")
menu.lh:boolean("qlh", "Use Q to Last Hit", true)
menu.lh:slider("manaqlh", "Q Mana", 30, 1, 100, 1)

menu:menu("ks", "KillSteal")
menu.ks:boolean("qks", "Use Q to KillSteal", true)
menu.ks:boolean("wks", "Use W to KillSteal", true)
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

menu:menu("misc", "Misc.")
menu.misc:menu("Gap", "Gapcloser Settings")
menu.misc.Gap:boolean("GapA", "Use E for Anti-Gapclose", true)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)
menu.keys:keybind("semir", "Semi Manual R", "T", nil)

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

local QLevelDamage = {70, 110, 150, 190, 230}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAP() * .60)), player)
	end
	return damage
end

local WLevelDamage = {100, 150, 200, 250, 300}
function WDamage(target)
	local damage = 0
	if player:spellSlot(1).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (WLevelDamage[player:spellSlot(1).level] + (common.GetTotalAP() * 1.0)), player)
	end
	return damage
end

local RLevelDamage = {175, 250, 325}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
		common.CalculateMagicDamage(target, (RLevelDamage[player:spellSlot(3).level] + (common.GetTotalAP() * .75)), player)
	end
	return damage
end
--[[function RMissingHP(target)
    local bonus = 0
	local MissingHealth = (target.maxHealth - target.health) * 100
	if MissingHealth <= 6.67 then
	   bonus = 10
	end
end]]

local waiting = 0
local uhhh = 0
local enemy = nil

local function EGapcloser()
if menu.misc.Gap.GapA:get() then
for i = 0, objManager.enemies_n - 1 do
local dasher = objManager.enemies[i]
if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
if
dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
player.pos:dist(dasher.path.point[1]) < spellE.range
then
if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
player:castSpell("pos", 2, dasher.path.point2D[1])
end
end
end
end
end
end

local function Combo()
if menu.c.wcombo:get() then 
local target = GetTargetW()
   if common.IsValidTarget(target) and target then
local pos = preds.circular.get_prediction(spellW, target)
   if menu.c.wmode:get() == 1 then
      if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range then
	     player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
	  end
   end
   if menu.c.wmode:get() == 2 then
      if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range and common.CheckBuffType(target, 11) 
	                                                                 or common.CheckBuffType(target, 5) 
																	 or common.CheckBuffType(target, 22) 
																	 or common.CheckBuffType(target, 8) 
																	 or common.CheckBuffType(target, 24) 
																     or common.CheckBuffType(target, 29) 
																	 or common.CheckBuffType(target, 32) 
																	 or common.CheckBuffType(target, 34) then
		player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
	  end
   end
   if menu.c.wmode:get() == 3 then
      if pos and player.pos:to2D():dist(pos.endPos) <= spellW.range and common.CheckBuffType(target, 10)
                                                                     or common.CheckBuffType(target, 33) then
         player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))	
      end	
   end	  
end
end
if menu.c.qcombo:get() then 
local target = GetTargetQ()
   if common.IsValidTarget(target) and target then
local pos = preds.linear.get_prediction(spellQ, target)  
   if pos and player.pos:to2D():dist(pos.endPos) <= spellQ.range and not preds.collision.get_prediction(spellQ, pos, target) then
	     player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
   end		 
end
end
if menu.c.ecombo:get() then 
local target = GetTargetE()
   if common.IsValidTarget(target) and target then
   local pos = preds.circular.get_prediction(spellE, target)
   if pos and player.pos:to2D():dist(pos.endPos) <= spellE.range - 50 then
      player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
   end
end
end
if menu.c.rcombo:get() then 
local target = GetTargetR()
   if common.IsValidTarget(target) and target and not common.CheckBuffType(target, 17) then
local hp = common.GetShieldedHealth("AP", target)
   if player:spellSlot(3).state == 0 and vec3(target.x, target.y, target.z):dist(player) < spellR.range and
      RDamage(target) >= hp then
	  player:castSpell("obj", 3, target)
   end  
end
end  
end 

local function SemiR()
if menu.keys.semir:get() and menu.c.semirc:get() then
local target = GetTargetR()
   if target and target.isVisible and common.IsValidTarget(target) and not common.CheckBuffType(target, 17) then
      if player:spellSlot(3).state == 0 and vec3(target.x, target.y, target.z):dist(player) < spellR.range then
	  player:castSpell("obj", 3, target)
	  end
   end
end
end   

local function Harass()
      if menu.h.qharass:get() then
	  local target = GetTargetQ()
	     if common.IsValidTarget(target) and target and (player.mana / player.maxMana) * 100 >= menu.h.manaq:get() then
		    if (target.pos:dist(player) < spellQ.range) then 
			local pos = preds.linear.get_prediction(spellQ, target)
			   if pos and pos.startPos:dist(pos.endPos) < spellQ.range and not preds.collision.get_prediction(spellQ, pos, target) then
			   player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			   end
			end
		 end
      end
	  if menu.h.wharass:get() then
	  local target = GetTargetW()
	     if common.IsValidTarget(target) and target and (player.mana / player.maxMana) * 100 >= menu.h.manaw:get() then
		    if (target.pos:dist(player) < spellW.range) then 
			local pos = preds.circular.get_prediction(spellW, target)
			   if pos and pos.startPos:dist(pos.endPos) < spellW.range then
			   player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			   end
			end
		 end
      end
end	  

local function LaneClear()
if menu.lc.qlc:get()and player:spellSlot(0).state == 0 and (player.mana / player.maxMana) * 100 >= menu.lc.manaqlc:get() then
   local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
   for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
   local minion = objManager.minions[TEAM_ENEMY][i]
   if minion and not minion.isDead and common.IsValidTarget(minion) then
   local minion = objManager.minions[TEAM_ENEMY][i]
		 if minion and minion.pos:dist(player.pos) <= spellQ.range and menu.lc.qlcmode:get() == 1 and not minion.isDead and common.IsValidTarget(minion) then
		 local minionPos = vec3(minion.x, minion.y, minion.z)
			   if minionPos then
			   local seg = preds.linear.get_prediction(spellQ, minion)
					 if seg and seg.startPos:dist(seg.endPos) < spellQ.range and not preds.collision.get_prediction(spellQ, seg, minion) then
					 player:castSpell("pos", 0, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
					 end
			   end
         end
		 if minion and minion.pos:dist(player.pos) <= spellQ.range and menu.lc.qlcmode:get() == 2 and not minion.isDead and common.IsValidTarget(minion) then
		 local minionPos = vec3(minion.x, minion.y, minion.z)
		 delay = 0.25 + player.pos:dist(minion.pos) / 3000
			   if minionPos then
			   local seg = preds.linear.get_prediction(spellQ, minion)
					 if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150) and not preds.collision.get_prediction(spellQ, seg, minion) then
				         orb.core.set_pause_attack(1)
			         end
				     if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) and not preds.collision.get_prediction(spellQ, seg, minion)then
					     player:castSpell("pos", 0, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
				     end
			   end
         end
   end
   end
end
if menu.lc.wlc:get() and player:spellSlot(1).state == 0 and (player.mana / player.maxMana) * 100 >= menu.lc.manawlc:get() then
   local enemyMinionsW = common.GetMinionsInRange(spellW.range, TEAM_ENEMY)
   for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
   local minion = objManager.minions[TEAM_ENEMY][i]
   if minion and not minion.isDead and common.IsValidTarget(minion) then
   local minion = objManager.minions[TEAM_ENEMY][i]
		 if minion and minion.pos:dist(player.pos) <= spellW.range and not minion.isDead and common.IsValidTarget(minion) then
		 local minionPos = vec3(minion.x, minion.y, minion.z)
			   if minionPos then
			   local seg = preds.circular.get_prediction(spellW, minion)
					 if seg and seg.startPos:dist(seg.endPos) < spellW.range then
					 player:castSpell("pos", 1, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
					 end
			   end
         end
   end
   end
end
end   

local function LastHit()
if menu.lh.qlh:get() and player:spellSlot(0).state == 0 and (player.mana / player.maxMana) * 100 >= menu.lh.manaqlh:get() then
   for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
   local minion = objManager.minions[TEAM_ENEMY][i]
       if minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and common.IsValidTarget(minion) then
	   local minionPos = vec3(minion.x, minion.y, minion.z)
	   delay = 0.25 + player.pos:dist(minion.pos) / 3000
	   if minionPos then 
	   local seg = preds.linear.get_prediction(spellQ, minion)
	         if seg and seg.startPos:dist(seg.endPos) < spellQ.range and not preds.collision.get_prediction(spellQ, seg, minion)then
			    if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true) - 150) then
				    orb.core.set_pause_attack(1)
			    end
				if (QDamage(minion) >= orb.farm.predict_hp(minion, delay / 2, true)) then
					player:castSpell("pos", 0, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
				end
			 end
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
				   if player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range and
				   QDamage(enemies) >= hp then
				   local pos = preds.linear.get_prediction(spellQ, enemies)
				         if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
						 player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						 end
				   end
                end
				if menu.ks.wks:get() then
				   if player:spellSlot(1).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellW.range and
				   WDamage(enemies) >= hp then
				   local pos = preds.circular.get_prediction(spellW, enemies)
				         if pos and pos.startPos:dist(pos.endPos) < spellW.range then
						 player:castSpell("pos", 1, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
						 end
				   end
                end
				if menu.ks.rks:get() then
				   if player:spellSlot(3).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) <=spellR.range and
				   RDamage(enemies) >= hp then
				   player:castSpell("obj", 3, enemies)
				  end
                end
      end
end
end  
	  

function DrawDamagesE(target)
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
		 local Wdmg = 0
		 local Rdmg = 0
		 Qdmg = QDamage(obj)
		 Wdmg = WDamage(obj)
		 Rdmg = RDamage(obj)
		 
		 local damage = obj.health - (Qdmg + Wdmg + Rdmg)
		 local x1 = xPos + ((obj.health / obj.maxHealth) * 102)
				local x2 = xPos + (((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if ((Rdmg + Qdmg + Wdmg) < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if ((Rdmg + Qdmg + Wdmg) > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if (math.floor((WDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
				tostring(math.floor(WDamage(target) + RDamage(target) + QDamage(target))) ..
					" (" ..
						tostring(math.floor((WDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)) ..
							"%)" .. "Not Killable",
				20,
				pos.x + 55,
				pos.y - 80,
				graphics.argb(255, 255, 153, 51)
			)
		end
		if (math.floor((WDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
				tostring(math.floor(WDamage(target) + RDamage(target) + QDamage(target))) ..
					" (" ..
						tostring(math.floor((WDamage(target) + RDamage(target) + QDamage(target)) / target.health * 100)) ..
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
 if menu.draws.drawdamage:get() then
 local enemy = common.GetEnemyHeroes()
 for i, enemies in ipairs(enemy) do
    if enemies and common.IsValidTarget(enemies)and player.pos:dist(enemies) < 2000 and enemies.isOnScreen and not common.CheckBuffType(enemies, 17) then
	   DrawDamagesE(enemies)
	end
   end
  end
end 

local function OnTick()
    if menu.misc.Gap.GapA:get() then
		EGapcloser()
	end
	if menu.keys.lastkey:get() then
		LastHit()
	end
	KillSteal()
	if menu.keys.clearkey:get() then
		LaneClear()
		--JungleClear()
	end
	if menu.keys.harasskey:get() then
		Harass()
		LastHit()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.semir:get() then
		SemiR()
	end
end

cb.add(cb.draw, OnDraw)

orb.combat.register_f_pre_tick(OnTick)