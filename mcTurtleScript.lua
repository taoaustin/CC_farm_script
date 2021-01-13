-- FINALLY WORKING FOR ALL RECTANGULAR DIMENSIONS I THINK

--[[ This script now just works with the "farmComputerControl" script so that all turtles running
     this "mcTurtleScript" will run and be controlled automatically by a computer running "farmComputerControl."

     First run this script on all (wireless) turtles you wish to use, then run the control script on a (wireless) computer ex: "control 9 9"--]]



local function getLava() -- refuels the turtle via a lava tank above it, assume slot 1 contains an empty bucket
    turtle.select(1)
    turtle.placeUp()
    turtle.refuel()
end

local function farmAndPlant() -- only harvests fully grown crops
    local flag, info = turtle.inspectDown()
    if flag
    then
        if info["state"]["age"] == 7
        then
            turtle.digDown()
            turtle.placeDown()
        end
    end
end

local function turnAround()
    turtle.turnRight()
    turtle.turnRight()
end


--[[
    With the turtle starting in the bottom-left corner of a rectangular field,
    (with x the side length where the turtle is facing forward, and y the side length to the right of the turtle)
    it harvest all crops and replants the seeds.
    Assume it starts fuel and at least 1 seed.
 --]]
function move(x, y)
    x = tonumber(x)
    y = tonumber(y)
    turtle.select(2) -- seed item slot is assume to be 2
    for i = 1, y, 1
    do
        for j = 1, x, 1
        do
            farmAndPlant()
            if j < x
            then
                turtle.forward()
            end
        end

        if i < y
        then
            if i % 2 == 1
            then
                turtle.turnRight()
                turtle.forward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                turtle.forward()
                turtle.turnLeft()
            end
        else
            if i % 2 == 0
            then
                turtle.turnRight()
                for k = 1, y-1, 1
                do
                    turtle.forward()
                end
                turtle.turnRight()
            else
                turtle.turnLeft()
                for k = 1, y-1, 1
                do
                    turtle.forward()
                end
                turtle.turnLeft()
                for k = 1, x-1, 1
                do
                    turtle.forward()
                end
                turnAround()
            end
        end

    end
end

local function dropAllCrop() -- drops all crops in a chest below the turtle
    index = 3                -- skips 1 and 2 since 1 will be fuel, and 2 are the seeds.
    while turtle.getItemDetail(index) ~= nil and index <= 16
    do
        turtle.select(index)
        turtle.dropDown()
        index = index + 1
    end
end

function mysplit (inputstr, sep) -- stolen from https://stackoverflow.com/questions/1426954/split-string-in-lua so thx
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end


-- MAIN
local FARMER_CHANNEL = 6
local SERVER_CHANNEL = 9

local modem = peripheral.wrap("left")
modem.open(FARMER_CHANNEL)

while true
do
    local _, _, _, _, message, _ = os.pullEvent("modem_message")
    local dimensions = mysplit(message, " ")
    if turtle.getFuelLevel() < 1000     -- makes sure theres enough fuel every cycle
    then
        getLava()
    end
    turtle.forward()
    move(tonumber(dimensions[1]), tonumber(dimensions[2]))
    turnAround()
    turtle.forward()
    turnAround()
    dropAllCrop()
    modem.transmit(SERVER_CHANNEL, FARMER_CHANNEL, "READY")
end
