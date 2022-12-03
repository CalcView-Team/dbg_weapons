--

dbmView = dbmView or {}
d = false

dbmView.lookOff = Angle()
dbmView.lookAngles = Angle()

i = 90

hook.Add("InputMouseApply", "dbg-view", function(n, o, e, a)
    if d or false then
        if d then
            dbmView.lookOff.p = math.Clamp(dbmView.lookOff.p + e * i / 200, -45, 45)
            dbmView.lookOff.y = math.Clamp(dbmView.lookOff.y - o * i / 200, -60, 60)
        end
        if false then
            dbmView.lookAngles = dbmView.lookAngles + Angle(e, -o, 0) * i / 200
            dbmView.lookAngles.pitch = math.Clamp(dbmView.lookAngles.pitch, -65, 90)
        end
        n:SetMouseX(0)
        n:SetMouseY(0)
        return true
    elseif dbmView.lookOff.p ~= 0 or dbmView.lookOff.y ~= 0 then
        dbmView.lookOff.p =
            math.Approach(dbmView.lookOff.p, 0, math.max(math.abs(dbmView.lookOff.p), .2) * FrameTime() * 10)
        dbmView.lookOff.y =
            math.Approach(dbmView.lookOff.y, 0, math.max(math.abs(dbmView.lookOff.y), .2) * FrameTime() * 10)
    end
end)

local function hidehead(pl, s)
    if s then
        pl:ManipulateBoneScale(pl:LookupBone("ValveBiped.Bip01_Head1"), Vector(0.1,0.1,0.1))
    else
        pl:ManipulateBoneScale(pl:LookupBone("ValveBiped.Bip01_Head1"), Vector(1,1,1))
    end
end

local function inOutQuad(t, b, c, d)
    t = t / d * 2
    if t < 1 then return c / 2 * math.pow(t, 2) + b end
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end

local whitelistweps = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true,
    ["gmod_camera"] = true,
    ["weapon_357"] = true,
    ["sf2_tool"] = true,
    ["weapon_crossbow"] = true,
    ["weapon_shotgun"] = true,
    ["weapon_nkc"] = true,
    ["weapon_keypadchecker"] = true,
    ["arcticvr_glock"] = true,
    ["arcticvr_tmp"] = true,
    ["arcticvr_aniv_usptactical"] = true,
    ["weapon_mp52"] = true,
    ["arcticvr_mac10"] = true,
    ["re_hands"] = true,
}

hook.Add("CalcView", "Doberman.CopyRight.CalcView", function(ply, pos, ang)
    if not IsValid(ply) then return end

    local eyes = ply:GetAttachment(ply:LookupAttachment("eyes"))
    hidehead(ply, false)
    org = eyes.Pos + eyes.Ang:Forward() * 2.6
    anles = ang
    if not LocalPlayer():Alive() then
        if IsValid(LocalPlayer():GetNWEntity("RagdollOfPlayer")) then
            local ragEye = LocalPlayer():GetNWEntity("RagdollOfPlayer"):GetAttachment(LocalPlayer():GetNWEntity("RagdollOfPlayer"):LookupAttachment("eyes"))
            org = ragEye.Pos + ragEye.Ang:Forward() * 2.8
            anles = ragEye.Ang
        end
    end
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) then
        if wep.Category == "GRM-WEAPONS" then
            if wep:GetReady() then
                if not wep.AimPos then
                    return
                end

                local e = math.Approach(wep.aimProgress or 0, 1, FrameTime() * 1)
                wep.aimProgress = e
                if e <= 0 then
                    return
                end
                local t = inOutQuad(e, 0, 1, 1)
                local handAtt = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
                
                local worldVector, worldAngle = LocalToWorld(wep.AimPos, wep.AimAng, handAtt.Pos, handAtt.Ang)

                
                hidehead(ply, true)
                org = LerpVector(t, eyes.Pos, worldVector)
                anles = LerpAngle(t, ang, worldAngle)

                if IsValid(wep) and ply.CalcView then
                    local e = ply:CalcView(ply, pos, ang, fov)
                    if not e then
                        return
                    end
                    view.origin = e.origin
                end
            end
        end
    end

    local view = {
        origin = org,
        angles = anles,
        znear = 1.5,
        drawviewer = true,
    }

    return view
end)

--[[
Привет! Это 'послание' адресовано тебе, скриптхукер. Я, deathrow, правда старался и делал эту стрельбу для
добермана, я не нашел должных способов как-нибудь защитить код и надеюсь на тебя. Я считаю,
что труды не должны обесцениваться. 
Прошу тебя, если тебе нравится стрельба - играй на локалке с друзьями, но не используй на своих серверах.
Доброградовская стрельба работает контактируя с двумя файлами, core-weapons и core-view. Однако я смог это
реализовать в одном файле.

Единственное что - стрельба от бедра и некий эффект перед прицеливанием убран, так как это реализуемо только
октоторповским путем, как-бы как оно было изначально так оно и будет работать. Однако наш пак отличается,
и я такое не в силах сделать. У меня просто не работает хук)) 


Надеюсь на тебя, не обесценивай чужие труды, тем-более тут ничего не обфусцированно. Не кидай видео подобия:
"Привет, октоторп а я с вашей стрельбой играю на локалке)))", - это просто не имеет в себе смысла, ведь
стрельбу сделал я..

Удачи.
@coded deathrow
]]

hook.Add("RenderScene","octoweapons",function(pos, angle, fov)

    local view = hook.Run("CalcView", LocalPlayer(), pos, angle, fov)
    
    if not view then
        return
    end

    render.Clear(0, 0, 0, 255, true, true, true)
    
    render.RenderView({
            x = 0,
            y = 0,
            w = ScrW(),
            h = ScrH(),
            angles = view.angles,
            origin = view.origin,
            drawhud = true,
            drawviewmodel = false,
            dopostprocess = true,
            drawmonitors = true
        })

    return true

end)



hook.Add("HUDPaint", "PiskaPopa", function()
    local posEye = LocalPlayer():GetAttachment(LocalPlayer():LookupAttachment("eyes")).Pos
    local posHand = LocalPlayer():GetAttachment(LocalPlayer():LookupAttachment("anim_attachment_rh")).Pos

    if LocalPlayer():KeyDown( IN_ATTACK2 ) and LocalPlayer():KeyDownLast( IN_ATTACK2 ) and LocalPlayer():IsValid() and LocalPlayer():Alive() and IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) then

        local tr = {
            start = posHand,
            endpos = posHand,
            mins = Vector( -1, -1, 0 ),
            maxs = Vector( 1, 1, 1 )
        }

        local hullTrace = util.TraceHull( tr )

        if ( hullTrace.Hit && hullTrace.Entity:GetClass() ~= "player" && hullTrace.Entity:GetClass() ~= "gmod_sent_vehicle_fphysics_base" && LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP ) then
            draw.RoundedBox(0,0,0,ScrW(), ScrH(), Color(0,0,0,255))
        end
    else
        local tr = {
            start = posEye,
            endpos = posEye,
            mins = Vector( -1, -1, 0 ),
            maxs = Vector( 1, 1, 1 )
        }
        local hullTrace = util.TraceHull( tr )
        if ( hullTrace.Hit && hullTrace.Entity:GetClass() ~= "player" && hullTrace.Entity:GetClass() ~= "gmod_sent_vehicle_fphysics_base" && LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP ) then
            draw.RoundedBox(0,0,0,ScrW(), ScrH(), Color(0,0,0,255))
        end
    end
end)
