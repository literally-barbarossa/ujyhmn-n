local filename = arg[1]
local file = io.open(filename, "r")
if not file then
    error("File could not be found.")
end

local lines = {}
for line in file:lines() do
    table.insert(lines, line)
end
file:close()

local line_number = 1
local open_var = ""
local memory = {}
local labels = {}
local ended = false

local function split(str, sep)
    local result = {}

    for word in string.gmatch(str, "[^" .. sep .. "]+") do
        table.insert(result, word)
    end

    return result
end

local function startswith(str, startstr)
    return string.sub(str, 1, #startstr) == startstr
end

local function endswith(str, endstr)
    return string.sub(str, -#endstr) == endstr
end

local function count_lines(filename)
    local count = 0
    for _ in io.lines(filename) do
        count = count + 1
    end
    return count
end

local line_number = 1
while line_number <= #lines do
    ::continue::
    local line = lines[line_number]

    local line = lines[line_number]
    local parts = split(line, " ")

    if startswith(line, "PRINT THE CHARACTER WITH THE ASCII VALUE") then
        local a = tonumber(parts[8])
        if a then
          io.write(string.char(a))
        else
          error("Error at line " .. tostring(line_number) .. ": Expected number, got: " .. parts[8])
        end
    end

    if startswith(line, "DECLARE THE NEW VARIABLE") then
        local a = parts[5]
        memory[a] = 0
    end

    if startswith(line, "OPEN THE VARIABLE") then
        local a = parts[4]
        if memory[a] ~= nil then
            open_var = a
        else
            error("Error at line " .. tostring(line_number) .. ": " .. a .. " is not defined.")
        end
    end

    if startswith(line, "ASSIGN") and endswith(line, "TO THE OPEN VARIABLE") then
        local a = tonumber(parts[2])
        if a == nil then
            error("Error at line " .. tostring(line_number) .. ": Expected a number to assign.")
        end
        if open_var == "" or memory[open_var] == nil then
            error("Error at line " .. tostring(line_number) .. ": No open variable to assign to.")
        end
        memory[open_var] = a
    end

    if startswith(line, "ADD") and endswith(line, "TO THE OPEN VARIABLE") then
        local a = parts[2]
        if memory[a] == nil then
            error("Error at line " .. tostring(line_number) .. ": " .. a .. " is not defined.")
        end

        if memory[open_var] == nil then
            error("Error at line " .. tostring(line_number) .. "The opened variable doesn't exist.")
        end

        if memory[a] ~= nil and memory[open_var] ~= nil then
            memory[open_var] = memory[open_var] + memory[a]
        end
    end

    if startswith(line, "MULTIPLY THE OPEN VARIABLE BY") then
        local a = parts[2]
        if memory[a] == nil then
            error("Error at line " .. tostring(line_number) .. ": " .. a .. " is not defined.")
        end

        if memory[open_var] == nil then
            error("Error at line " .. tostring(line_number) .. "The opened variable doesn't exist.")
        end

        if memory[a] ~= nil and memory[open_var] ~= nil then
            memory[open_var] = memory[open_var] * memory[a]
        end
    end

    if line == "PRINT THE OPEN VARIABLE'S CHARACTER" then
        if memory[open_var] == nil then
            error("Error at line " .. tostring(line_number) .. "The opened variable doesn't exist.")
        end

        if memory[open_var] ~= nil then
            io.write(string.char(memory[open_var]))
        end
    end

    if line == "PRINT THE OPEN VARIABLE'S VALUE" then
        if memory[open_var] == nil then
            error("Error at line " .. tostring(line_number) .. "The opened variable doesn't exist.")
        end

        if memory[open_var] ~= nil then
            io.write(memory[open_var])
        end
    end

    if startswith(line, "DEFINE THE NEW LABEL ") then
        local a = parts[5]
        labels[a] = line_number
    end

    local label, v0, v1 = string.match(line, "^JUMP TO ([%w_]+) IF ([%w_]+) IS EQUAL TO ([%w_]+)$")
    if label and v0 and v1 then
        if memory[v0] == memory[v1] then
            line_number = labels[label]
        end
        goto continue
    end

    label, v0, v1 = string.match(line, "^JUMP TO ([%w_]+) IF ([%w_]+) IS GREATER THAN ([%w_]+)$")
    if label and v0 and v1 then
        if memory[v0] > memory[v1] then
            line_number = labels[label]
        end
        goto continue
    end

    label, v0, v1 = string.match(line, "^JUMP TO ([%w_]+) IF ([%w_]+) IS LESS THAN ([%w_]+)$")
    if label and v0 and v1 then
        if memory[v0] < memory[v1] then
            line_number = labels[label]
        end
        goto continue
    end

    if line == "GET INPUT AND STORE INTO OPEN VARIABLE AS A CHARACTER" then
        if memory[open_var] == nil then
            error("Error at line " .. tostring(line_number) .. "The opened variable doesn't exist.")
        end

        if memory[open_var] ~= nil then
            local input = io.read()
            local char = input:sub(1,1)
            memory[open_var] = string.byte(char)
        end
    end

    if line == "GET INPUT AND STORE INTO OPEN VARIABLE AS A NUMBER" then
        if memory[open_var] == nil then
            error("Error at line " .. tostring(line_number) .. "The opened variable doesn't exist.")
        end

        if memory[open_var] ~= nil then
            local input = io.read()
            local num = tonumber(input)
            memory[open_var] = num
        end
    end

    if line == "END THIS PROGRAM" then
        ended = true
        break
    end

    line_number = line_number + 1
end

if not ended then
    os.execute("cls")
    print("You forgot to end your program. As punishment, I wiped your console so it DOES matter even though it's interpreted >:)")
end