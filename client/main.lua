local nuiFocus = false
local showedUI = false
local speedrun = false
local god = false
local superjump = false
local invisible = false
local onduty = {}

-- Panel open
RegisterCommand(
    'adminpanel',
    function()
        ESX.TriggerServerCallback(
            'PlayerGroup',
            function(group)
                if AAP.AdminGroups[group] then
                    showedUI = not showedUI

                    if showedUI then
                        showUI(group)
                    else
                        hideUI()
                    end
                end
            end
        )
    end
)

RegisterKeyMapping('adminpanel', 'Admin Panel', 'keyboard', 'INSERT')

-- Functions


function showUI(group)
        SendNUIMessage(
            {
                AdminCommands = AAP.AdminCommands,
                playerCount = #GetActivePlayers(),
                group = group,
                action = 'showUI'
            }
        )
    SetNuiFocus(true, true)
end

function hideUI()
    SendNUIMessage(
        {
            action = 'hideUI'
        }
    )
    SetNuiFocus(false, false)
    showedUI = false
end

-- NUI Callback

RegisterNUICallback('close', hideUI)

RegisterNUICallback(
    'Speedrun',
    function()
        speedrun = not speedrun
        SendNUIMessage(
            {
                action = 'alert',
                msg = speedrun and 'Speedrun: bekapcsolva' or 'Speedrun: kikapcsolva',
                color = speedrun and 'success' or 'danger'
            }
        )
        SetRunSprintMultiplierForPlayer(PlayerId(), speedrun and 1.49 or 1.0)
    end
)

RegisterNUICallback(
    'Godmode',
    function()
        god = not god
        SendNUIMessage(
            {
                action = 'alert',
                msg = god and 'Godmode: bekapcsolva' or 'Godmode: kikapcsolva',
                -- title = 'Godmode',
                color = god and 'success' or 'danger'
            }
        )
        SetPlayerInvincible(PlayerId(), god)
    end
)

RegisterNUICallback(
    'SuperJump',
    function()
        CreateThread(
            function()
                superjump = not superjump
                SendNUIMessage(
                    {
                        action = 'alert',
                        msg = superjump and 'SuperJump: bekapcsolva' or 'SuperJump: kikapcsolva',
                        color = superjump and 'success' or 'danger'
                    }
                )
                while superjump do
                    SetSuperJumpThisFrame(PlayerId(), false)
                    Wait(0)
                end
            end
        )
    end
)

RegisterNUICallback(
    'Invisible',
    function()
        invisible = not invisible
        SetEntityVisible(PlayerPedId(), not invisible)
        SendNUIMessage(
            {
                action = 'alert',
                msg = invisible and 'Invisible: bekapcsolva' or 'Invisible: kikapcsolva',
                color = invisible and 'success' or 'danger'
            }
        )
    end
)

RegisterNUICallback(
    'Duty',
    function()
        if onduty[GetPlayerServerId(PlayerId())] then
            onduty[GetPlayerServerId(PlayerId())] = false
            SendNUIMessage(
                {
                    action = 'alert',
                    msg = 'Kiléptél az Admin szolgálatból',
                    title = 'Adminszolgálat',
                    color = 'danger'
                }
            )
            TriggerServerEvent("adam_adminpanel:SendToDiscord", 1752220, "Adminduty", GetPlayerName(PlayerId()).." kilépett a szolgálatból", AAP.DiscordWebhook)
        else
            onduty[GetPlayerServerId(PlayerId())] = true
            SendNUIMessage(
                {
                    action = 'alert',
                    msg = 'Beléptél az Admin szolgálatba',
                    title = 'Adminszolgálat',
                    color = 'success'
                }
            )
            TriggerServerEvent("adam_adminpanel:SendToDiscord", 1752220, "Adminduty", GetPlayerName(PlayerId()).." belépett a szolgálatba", AAP.DiscordWebhook)
        end
        TriggerServerEvent("setAdminsOnDuty", onduty)
    end
)


RegisterNUICallback(
    'CopyCoords',
    function(data, cb)
        local playerPed = PlayerPedId()
        local posX, posY, posZ = table.unpack(GetEntityCoords(playerPed))

        cb({position = posX .. ', ' .. posY .. ', ' .. posZ})
    end
)

