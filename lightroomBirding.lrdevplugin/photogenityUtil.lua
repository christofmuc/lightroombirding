util = {}

-- Recursive dump tables
function util.logDebug(name, value)
    if type(value) == 'table' then
        for key, row in pairs(value) do
            logDebug(name.."/"..key, row)
        end
    else
        logger:debug(name, value)
    end
end

-- Compatibility: Lua-5.0 (from http://lua-users.org/wiki/SplitJoin)
function util.split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function util.switch(c)
  local swtbl = {
    casevar = c,
    caseof = function (self, code)
      local f
      if (self.casevar) then
        f = code[self.casevar] or code.default
      else
        f = code.missing or code.default
      end
      if f then
        if type(f)=="function" then
          return f(self.casevar,self)
        else
          error("case "..tostring(self.casevar).." not a function")
        end
      end
    end
  }
  return swtbl
end

function util.isempty(s)
    return s == nil or s == ''
end

function util.writeIfNotNil(file, value, default)
    if not util.isempty(value) then
        file:write(value .. ",")
    else
        if not util.isempty(default) then
            file:write(default .. ",")
        else
            file:write(",")
        end
    end
end

function util.findMeta(metadata, key)
    for key2, value in pairs(metadata) do
        if value['id'] == key then
            return value['value']
        end
    end
    return nil
end

-- http://www.lua.org/pil/20.4.html
function util.fromCSV(s)
    s = s .. ',' -- ending comma
    local t = {} -- table to collect fields
    local fieldstart = 1
    repeat
        -- next field is quoted? (start with `"'?)
        if string.find(s, '^"', fieldstart) then
            local a, c
            local i = fieldstart
            repeat
                -- find closing quote
                a, i, c = string.find(s, '"("?)', i + 1)
                until c ~= '"' -- quote not followed by quote?
            if not i then error('unmatched "') end
            local f = string.sub(s, fieldstart + 1, i - 1)
            table.insert(t, (string.gsub(f, '""', '"')))
            fieldstart = string.find(s, ',', i) + 1
        else -- unquoted; find next comma
            local nexti = string.find(s, ',', fieldstart)
            table.insert(t, string.sub(s, fieldstart, nexti - 1))
            fieldstart = nexti + 1
        end
        until fieldstart > string.len(s)
    return t
end

