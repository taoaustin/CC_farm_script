local FARMER_CHANNEL = 6
local SERVER_CHANNEL = 9
local SLEEP_TIME = 300          -- 5 minutes

local strSize = "9 9"

if #arg == 0
then
    print("no arguments, defaulting 9x9")
elseif #arg ~= 2
then
    print("invalid # of args, requires 2 args for field dimension")
    os.exit()
else
    strSize = arg[1] .. " " .. arg[2]
end

local modem = peripheral.wrap("right")
modem.open(SERVER_CHANNEL)
print("Running... loops every "..SLEEP_TIME.." seconds. Ctrl+T to stop")
if arg ~= nil
then
    print(arg[1].."x"..arg[2].." field")
else
    print ("9x9 field")
end

while true
do
    modem.transmit(FARMER_CHANNEL, SERVER_CHANNEL, strSize)
    local _, _, _, _, message, _ = os.pullEvent("modem_message")
    if message == "READY"
    then
        os.sleep(SLEEP_TIME)
    end
end
