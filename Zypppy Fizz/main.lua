local version = "3.0"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local common = module.load("ZypppyFizz", "common")

local spellQ = {range = 550}

local spellW = {range = 200}

local spellE = {
range = 400, 
radius = 300, 
speed = math.huge, 
delay = 0.25, 
boundingRadiusMod = 1 
}

local spellR = {
range = 445, 
width = 80, 
speed = 1300, 
delay = 0.25, 
boundingRadiusMod = 1
}

local spellR2 = {
range = 910, 
width = 80, 
speed = 1300, 
delay = 0.25, 
boundingRadiusMod = 1
}

local spellR3 = {
range = 1300, 
width = 80, 
speed = 1300, 
delay = 0.25, 
boundingRadiusMod = 1
}

local menu = menu("ZypppyFizz", "Fizz By Zypppy")
menu:menu("c", "Combo")
menu.c:boolean("qcombo", "Use Q in Combo", true)
menu.c:boolean("wcombo", "Use W in Combo", true)
menu.c:boolean("ecombo", "Use E in Combo", true)
menu.c:boolean("rcombo", "Use R in Combo", true)
menu.c:dropdown("rmode", "R Mode", 2, {"Smallest Range", "Medium Range", "Max Range"})

menu:menu("h", "Harass")
menu.h:boolean("qharass", "Use Q in Harass", true)
menu.h:slider("manaq", "Q Mana", 80, 1, 100, 1)
menu.h:boolean("wharass", "Use W in Harass", true)
menu.h:slider("manaw", "W Mana", 80, 1, 100, 1)

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
menu.draws:boolean("drawr", "Draw R", true)
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

TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist <= spellR3.range then
		res.obj = obj
		return true
	end
end

local TargetSelectionGap = function(res, obj, dist)
	if dist <(spellE.range * 2) - 70 then
		res.obj = obj
		return true
	end
end

local GetTarget = function()
	return TS.get_result(TargetSelection).obj
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

local QLevelDamage = {10, 25, 40, 55, 70}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
		common.CalculateMagicDamage(target,(QLevelDamage[player:spellSlot(0).level] +(common.GetTotalAP() * .55)), player)
	end
	return damage
end

local WLevelDamage = {50, 70, 90, 110, 130}
function WDamage(target)
	local damage = 0
	if player:spellSlot(1).level > 0 then
		damage =
		common.CalculateMagicDamage(target,(WLevelDamage[player:spellSlot(1).level] +(common.GetTotalAP() * 0.5)), player)
	end
	return damage
end

local ELevelDamage = {70, 120, 170, 220, 270}
function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
		common.CalculateMagicDamage(target,(WLevelDamage[player:spellSlot(2).level] +(common.GetTotalAP() * 0.75)), player)
	end
	return damage
end

local RLevelDamage = {150, 250, 325}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
		common.CalculateMagicDamage(target,(RLevelDamage[player:spellSlot(3).level] +(common.GetTotalAP() * .80)), player)
	end
	return damage
end
local RLevelDamage2 = {225, 325, 425}
function RDamage2(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
		common.CalculateMagicDamage(target,(RLevelDamage[player:spellSlot(3).level] +(common.GetTotalAP() * 1)), player)
	end
	return damage
end
local RLevelDamage3 = {300, 400, 500}
function RDamage3(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
		common.CalculateMagicDamage(target,(RLevelDamage[player:spellSlot(3).level] +(common.GetTotalAP() * 1.2)), player)
	end
	return damage
end

local waiting = 0
local uhhh = 0
local enemy = nil

local function EGapcloser()
	if menu.misc.Gap.GapA:get() then
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


orb.combat.register_f_after_attack(
function()
	if menu.keys.combokey:get() and player:spellSlot(1).state == 0 then
		if orb.combat.target then
			if orb.combat.target and common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) < 300 then
				if menu.c.wcombo:get() then
					player:castSpell("self", 1)
					player:attack(orb.combat.target)
					return "on_after_attack_hydra"
				end
			end
		end
	end
	if menu.keys.harasskey:get() and player:spellSlot(1).state == 0 then
		if orb.combat.target then
			if orb.combat.target and common.IsValidTarget(orb.combat.target) and player.pos:dist(orb.combat.target.pos) < 300 then
				if menu.h.wharass:get() and(player.mana / player.maxMana) * 100 >= menu.h.manaw:get() then
					player:castSpell("self", 1)
					player:attack(orb.combat.target)
					return "on_after_attack_hydra"
				end
			end
		end
	end		   
	orb.combat.set_invoke_after_attack(false)
end
)


local function Combo()
	local target = GetTarget()
	if menu.c.ecombo:get() and common.IsValidTarget(target) and target then
		local pos = preds.circular.get_prediction(spellE, target)
		if pos and player.pos:to2D():dist(pos.endPos) <= spellE.range then
			player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		end
	end	
	if menu.c.qcombo:get() and common.IsValidTarget(target) and target then
		if(target.pos:dist(player) <= spellQ.range) then
			player:castSpell("obj", 0, target)
		end		 
	end
	if menu.c.rcombo:get() and common.IsValidTarget(target) and target and not common.CheckBuffType(target, 17) then
		if menu.c.rmode:get() == 1 then
			local pos = preds.linear.get_prediction(spellR, target)
			if pos and player.pos:to2D():dist(pos.endPos) <= spellR.range then
				player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			end
		end
		if menu.c.rmode:get() == 2 then
			local pos = preds.linear.get_prediction(spellR2, target)
			if pos and player.pos:to2D():dist(pos.endPos) <= spellR2.range and player.pos:to2D():dist(pos.endPos) > spellR.range then
	     --if trace_filter(spellR2, pos, target) then
				player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
	     --end
			end
		end 
		if menu.c.rmode:get() == 3 then
			local pos = preds.linear.get_prediction(spellR3, target)
			if pos and player.pos:to2D():dist(pos.endPos) <= spellR3.range and player.pos:to2D():dist(pos.endPos) > spellR2.range then
	     --if trace_filter(spellR3, pos, target) then
				player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
	     --end
			end
		end
	end 
end

local function Harass()
	local target = GetTarget()
	if menu.h.qharass:get() then
		if common.IsValidTarget(target) and target and(player.mana / player.maxMana) * 100 >= menu.h.manaq:get() then
			if(target.pos:dist(player) <= spellQ.range) then
				player:castSpell("obj", 0, target)
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
				if player:spellSlot(0).state == 0 and
				QDamage(enemies) >= hp then
					if(enemies.pos:dist(player) <= spellQ.range) then
						player:castSpell("obj", 0, enemies)
					end		  
				end
			end
			if menu.ks.eks:get() then
				if player:spellSlot(2).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range and
				EDamage(enemies) >= hp then
					local pos = preds.circular.get_prediction(spellE, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellE.range then
						player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
			if menu.ks.rks:get() then
				local distance = vec3(enemies.x, enemies.y, enemies.z):dist(player)
				if player:spellSlot(3).state == 0 and distance <= 455 then
					local pos = preds.linear.get_prediction(spellR, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellR.range and RDamage(enemies) >= hp then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
				if player:spellSlot(3).state == 0 and distance <= 910 and distance > 445 then
					local pos = preds.linear.get_prediction(spellR2, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellR2.range and RDamage2(enemies) >= hp then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
				if player:spellSlot(3).state == 0 and distance <= 1300 and distance > 910 then
					local pos = preds.linear.get_prediction(spellR3, enemies)
					if pos and pos.startPos:dist(pos.endPos) < spellR3.range and RDamage3(enemies) >= hp then
						player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
					end
				end
			end
		end
	end
end  

function DrawDamagesE2(target)
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
				local Edmg = 0
				local Rdmg2 = 0
				Qdmg = QDamage(obj)
				Wdmg = WDamage(obj)
				Edmg = EDamage(obj)
				Rdmg2 = RDamage2(obj)
		 
				local damage = obj.health -(Qdmg + Wdmg + Edmg + Rdmg2)
				local x1 = xPos +((obj.health / obj.maxHealth) * 102)
				local x2 = xPos +(((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if((Qdmg + Wdmg + Edmg + Rdmg3) < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if((Qdmg + Wdmg + Edmg + Rdmg2) > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if(math.floor((WDamage(target) + RDamage2(target) + EDamage(target) + QDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
			tostring(math.floor(WDamage(target) + RDamage2(target) + EDamage(target) + QDamage(target))) ..
			" (" ..
			tostring(math.floor((WDamage(target) + RDamage2(target) + EDamage(target) + QDamage(target)) / target.health * 100)) ..
			"%)" .. "Not Killable",
			20,
			pos.x + 55,
			pos.y - 80,
			graphics.argb(255, 255, 153, 51)
			)
		end
		if(math.floor((WDamage(target) + RDamage2(target) + EDamage(target) + QDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
			tostring(math.floor(WDamage(target) + RDamage2(target) + EDamage(target) + QDamage(target))) ..
			" (" ..
			tostring(math.floor((WDamage(target) + RDamage2(target) + EDamage(target) + QDamage(target)) / target.health * 100)) ..
			"%)" .. "Kilable",
			20,
			pos.x + 55,
			pos.y - 80,
			graphics.argb(255, 150, 255, 200)
			)
		end
	end
end	

function DrawDamagesE3(target)
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
				local Edmg = 0
				local Rdmg3 = 0
				Qdmg = QDamage(obj)
				Wdmg = WDamage(obj)
				Edmg = EDamage(obj)
				Rdmg3 = RDamage3(obj)
		 
				local damage = obj.health -(Qdmg + Wdmg + Edmg + Rdmg3)
				local x1 = xPos +((obj.health / obj.maxHealth) * 102)
				local x2 = xPos +(((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if((Qdmg + Wdmg + Edmg + Rdmg2) < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if((Qdmg + Wdmg + Edmg + Rdmg3) > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if(math.floor((WDamage(target) + RDamage3(target) + EDamage(target) + QDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
			tostring(math.floor(WDamage(target) + RDamage3(target) + EDamage(target) + QDamage(target))) ..
			" (" ..
			tostring(math.floor((WDamage(target) + RDamage3(target) + EDamage(target) + QDamage(target)) / target.health * 100)) ..
			"%)" .. "Not Killable",
			20,
			pos.x + 55,
			pos.y - 80,
			graphics.argb(255, 255, 153, 51)
			)
		end
		if(math.floor((WDamage(target) + RDamage3(target) + EDamage(target) + QDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
			tostring(math.floor(WDamage(target) + RDamage3(target) + EDamage(target) + QDamage(target))) ..
			" (" ..
			tostring(math.floor((WDamage(target) + RDamage3(target) + EDamage(target) + QDamage(target)) / target.health * 100)) ..
			"%)" .. "Kilable",
			20,
			pos.x + 55,
			pos.y - 80,
			graphics.argb(255, 150, 255, 200)
			)
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
				local Edmg = 0
				local Rdmg = 0
				Qdmg = QDamage(obj)
				Wdmg = WDamage(obj)
				Edmg = EDamage(obj)
				Rdmg = RDamage(obj)
		 
				local damage = obj.health -(Qdmg + Wdmg + Edmg + Rdmg)
				local x1 = xPos +((obj.health / obj.maxHealth) * 102)
				local x2 = xPos +(((damage > 0 and damage or 0) / obj.maxHealth) * 102)
				if((Rdmg + Rdmg2 + Rdmg3 + Qdmg + Wdmg) < obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFFEE9922)
				end
				if((Rdmg + Edmg + Qdmg + Wdmg) > obj.health) then
					graphics.draw_line_2D(x1, yPos, x2, yPos, 10, 0xFF2DE04A)
				end
			end
		end
		local pos = graphics.world_to_screen(target.pos)
		if(math.floor((WDamage(target) + RDamage(target) + EDamage(target) + QDamage(target)) / target.health * 100) < 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 255, 153, 51))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 255, 153, 51))

			graphics.draw_text_2D(
			tostring(math.floor(WDamage(target) + RDamage(target) + EDamage(target) + QDamage(target))) ..
			" (" ..
			tostring(math.floor((WDamage(target) + RDamage(target) + EDamage(target) + QDamage(target)) / target.health * 100)) ..
			"%)" .. "Not Killable",
			20,
			pos.x + 55,
			pos.y - 80,
			graphics.argb(255, 255, 153, 51)
			)
		end
		if(math.floor((WDamage(target) + RDamage(target) + EDamage(target) + QDamage(target)) / target.health * 100) >= 100) then
			graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
			graphics.draw_text_2D(
			tostring(math.floor(WDamage(target) + RDamage(target) + EDamage(target) + QDamage(target))) ..
			" (" ..
			tostring(math.floor((WDamage(target) + RDamage(target) + EDamage(target) + QDamage(target)) / target.health * 100)) ..
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
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 50)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 50)
		end
		if menu.draws.drawr:get() then
			if menu.c.rmode:get() == 1 then
				graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 50)
			end
			if menu.c.rmode:get() == 2 then
				graphics.draw_circle(player.pos, spellR2.range, 2, menu.draws.colorr:get(), 50)
			end
			if menu.c.rmode:get() == 3 then
				graphics.draw_circle(player.pos, spellR3.range, 2, menu.draws.colorr:get(), 50)
			end
		end
	end
	if menu.draws.drawdamage:get() then
		local enemy = common.GetEnemyHeroes()
		for i, enemies in ipairs(enemy) do
			if enemies and common.IsValidTarget(enemies)and player.pos:dist(enemies) <= 455 and enemies.isOnScreen and not common.CheckBuffType(enemies, 17) then
				DrawDamagesE(enemies)
			end
			if enemies and common.IsValidTarget(enemies)and player.pos:dist(enemies) <= 910 and player.pos:dist(enemies) > 455 and enemies.isOnScreen and not common.CheckBuffType(enemies, 17) then
				DrawDamagesE2(enemies)
			end
			if enemies and common.IsValidTarget(enemies)and player.pos:dist(enemies) < 2000 and player.pos:dist(enemies) > 910 and enemies.isOnScreen and not common.CheckBuffType(enemies, 17) then
				DrawDamagesE3(enemies)
			end
		end
	end
end 

local function OnTick()
	if menu.misc.Gap.GapA:get() then
		EGapcloser()
	end
	KillSteal()
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
end

cb.add(cb.draw, OnDraw)

orb.combat.register_f_pre_tick(OnTick)