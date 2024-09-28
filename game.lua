Handlers.add(
    "HandleAnnouncements",
    { Action = "Announcement"},
    function (msg)
        ao.send({ Target = Game, Action = "GetGameState" })
        print(msg.Event .. ": " .. msg.Data)
    end
)

Handlers.add(
    "UpdateGameState",
    { Action = "Announcement"}, 
    function (msg)
        local json = require("json")
        LatestGameState = json.decode(msg.Data)
        ao.send({Target = ao.id, Action = "UpdatedGameState"})
        print("Game state updated. Print \'LatestGameState\' for detailed view.")
    end
)

function inRange(x1, y1, x2, y2, range)
    return math.abs(x1 - x2) <= range and math.abs(y1 - y2) <= range
end

function decideNextAction()
    local player = LatestGameState.Players[ao.id]
    local targetInRange = false

    for target, state in pairs(LatestGameState.Players) do
        if target ~= ao.id and inRange(player.x, player.y, state.x, state.y, 1) then
            targetInRange = true
            break
        end
    end 

    if player.energy > 5 and targetInRange then 
        print("Player in range, Attacking")
        ao.send({ Target = Game, Action = "Attack", Player = ao.id, AttackEnergy = tostring(player.energy) })
    else 
        print("Player not in range, Moving")
        local directionMap = { "Up", "Down", "Left", "Right", "UpRight", "UpLeft", "DownRight", "DownLeft" }
        local randomIndex = math.random(#directionMap)
        ao.send({ Target = Game, Action = "Move", Player = ao.id, Direction = directionMap[randomIndex] })
    end
end

Handlers.add(
    "decideNextAction",
    { Action = "UpdatedGameState" },
    function ()
        if LatestGameState.GameMode ~= "Playing" then
            return
        end
        print("Deciding next action")
        decideNextAction()
    end
)

Handlers.add(
    "ReturnAttack",
    { Action = "Hit" },
    function (msg)
        local playerEnergy = LatestGameState.Players[ao.id].energy
        if playerEnergy == undefined then
            print("Unable to read energy")
            ao.send({ Target = Game, Action = "Attack-Failed", Reason = "Unable to read energy" })
        elseif playerEnergy == 0  then
            print("Player has insufficient energy")
            ao.send({ Target = Game, Action = "Attack-Failed", Reason = "Player has insufficient energy" })
        else 
            print("Attacked successfully")
            ao.send({ Target = Game, Action = "Attack-Success", Player = ao.id, AttackEnergy = tostring(playerEnergy) })
        end
        InAction = false
        ao.send({ Target = ao.id, Action = "Tick" })
    end
)

Handlers.add(
    "GetGameStateOnTick", 
    { Action = "Tick" }, 
    function ()
        if not InAction then
            ao.send({ Target = Game, Action = "GetGameState" })
        end
    end
)

Handlers.add(
    "AutoTransact",
    { Action = "AutoPay"},
    function ()
        ao.send({ Target = Game, Action = "Transfer", Recipient = Game, Quantity = "1000"})
    end
)