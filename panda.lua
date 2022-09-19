-- vim: set ts=4 sw=4 foldmethod=marker :

--[[
    This file is part of Panda.

    Panda is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Panda is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Panda.  If not, see <https://www.gnu.org/licenses/>.

    For further information about Panda you can visit
    http://cdelord.fr/panda
--]]

local pandoc = require "pandoc"
local utils = pandoc.utils
local system = pandoc.system

local api_1_22 = PANDOC_API_VERSION >= {1, 22}

local nullBlock, nullInline
if api_1_22 then
    nullBlock = pandoc.Null()
    nullInline = pandoc.Inline
else
    nullBlock = pandoc.Null
    nullInline = pandoc.Inline
end

local filters = {}

-- User Lua environment {{{

-- The global environment _G is used to execute Lua filters

_G.pandoc = pandoc
_G.utils = utils
_G.input_file = PANDOC_STATE.input_files[1]
_G.output_file = PANDOC_STATE.output_file

-- }}}

-- {{{ Trace
local function trace(name, object)
    local function dump(x, l)
        l = l or ""
        local l2 = l .. "    "
        local s
        if type(x) == "boolean" then
            s = tostring(x)
        elseif type(x) == "number" then
            s = tostring(x)
        elseif type(x) == "string" then
            s = '"' .. tostring(x) .. '"'
        elseif type(x) == "table" then
            s = "{\n"
            for i, xi in ipairs(x) do
                s = s .. l2 .. "["..i.."] = " .. dump(xi, l2) .. ",\n"
            end
            for k, xk in pairs(x) do
                if type(k) ~= "number" then
                    s = s .. l2 .. k .. " = " .. dump(xk, l2) .. ",\n"
                end
            end
            s = s .. l .. "}"
        else
            s = tostring(x)
        end
        return s
    end
    io.stderr:write(("%s: %s\n"):format(name, dump(object)))
end
-- }}}

-- {{{ Tools

local function has_class(item, class)
    return item.attr and item.attr.classes:find(class)
end

local function get_attr(item, name)
    return item.attr and item.attr.attributes[name]
end

local function iter_attr(item)
    return item.attr and pairs(item.attr.attributes)
end

local function has_attr(item, name)
    return get_attr(item, name) ~= nil
end

local function clean_attr(classes, attributes, attr)
    local attr = attr:clone()
    local classes = pandoc.List(classes)
    local attributes = pandoc.List(attributes)
    attr.classes = attr.classes:filter(function (c) return classes:find(c) == nil end)
    for _, a in ipairs(attributes) do attr.attributes[a] = nil end
    return attr
end

local function expand_path(path)
    if path:sub(1, 2) == "~/" then
        return os.getenv("HOME").."/"..path:sub(3)
    else
        return path
    end
end

local function file_exists(name)
    local f = io.open(name, 'r')
    if f then
        f:close()
        return true
    else
        return false
    end
end

local function file_content(name)
    local f = io.open(name, 'r')
    if f then
        local content = f:read("a")
        f:close()
        return content
    else
        return nil
    end
end

local function basename(name)
    return (name:gsub(".*/", ""))
end

local function dirname(name)
    return (name:gsub("[^/]*$", ""):gsub("^$", "."))
end

local function mkdir(path)
    if not file_exists(path) then
        os.execute("mkdir "..path)
    end
end

-- }}}

-- {{{ Forward declarations

local track_file -- forward declaration of the dependency tracking function
local include_codeblock

-- }}}

-- {{{ Variable expansion

local var_pattern = "{{([%w_%.]-)}}"
local var_pattern_esc = "%%7B%%7B([%w_%.]-)%%7D%%7D"

local function get_env_var()
    for k, v in pairs(system.environment()) do
        _G[k] = v
    end
end

local function read_vars_in_meta(meta)
    for k, v in pairs(meta) do
        if type(v) == "table" and v.t == 'MetaInlines' then
            _G[k] = {table.unpack(v)}
        else
            _G[k] = pandoc.MetaString(utils.stringify(v))
        end
    end
end

local function read_vars_in_block(block)
    if has_class(block, "meta") then
        block = include_codeblock(block) or block
        assert(load(block.text, block.text, "t", _G))()
        return nullBlock
    end
end

local function expand_vars(s)
    s = s:gsub(var_pattern, function (var)
        return var and _G[var]~=nil and utils.stringify(_G[var])
    end)
    s = s:gsub(var_pattern_esc, function (var)
        return var and _G[var]~=nil and utils.stringify(_G[var])
    end)
    return s
end

local function expand_attr(attr)
    if attr then
        local attributes = {}
        for k, v in pairs(attr.attributes) do attributes[k] = expand_vars(v) end
        return pandoc.Attr(attr.identifier, attr.classes, attributes)
    end
end

local function expand_str(el)
    local has_variables = false
    local items = pandoc.List()
    local i = 1
    while i <= #el.text do
        local j, k = string.find(el.text, var_pattern, i)
        if j then
            -- i..j-1 => Str before the variable name
            if j > i then items:insert(pandoc.Str(string.sub(el.text, i, j-1))) end
            -- j..k => variable name
            local var = string.sub(el.text, j+2, k-2)
            local value = _G[var]
            if value then
                if type(value) == "string" then
                    value = utils.blocks_to_inlines(pandoc.read(value).blocks)
                    items:extend(value)
                elseif type(value) == "table" then
                    items:extend(value)
                else
                    items:insert(value)
                end
                has_variables = true
            else
                value = pandoc.Str(string.sub(el.text, j, k))
                items:insert(value)
            end
            i = k+1
        else
            items:insert(pandoc.Str(string.sub(el.text, i)))
            i = #el.text + 1
        end
    end
    if has_variables then
        if #items > 1 then
            return pandoc.Span(items)
        else
            return items[1]
        end
    end
end

local function expand(fields)
    local fs = {}
    for _, field in ipairs(fields) do
        if field == "attr" then
            fs[field] = expand_attr
        else
            fs[field] = expand_vars
        end
    end
    return function (object)
        object = object:clone()
        for a, f in pairs(fs) do
            object[a] = f(object[a])
        end
        return object
    end
end

local function expand_codeblock(block)
    if not has_class(block, "meta") then
        return expand{"text", "attr"}(block)
    end
end

-- }}}

-- Dependencies {{{

local deps = pandoc.List()

local function add_dep(filename)
    if not deps:find(filename) then
        deps:insert(filename)
    end
    if _G["PANDA_TARGET"] then
        local target = _G["PANDA_TARGET"]
        local depfile = _G["PANDA_DEP_FILE"] or target..".d"
        local f = assert(io.open(depfile, "w"), "Can not create "..depfile)
        f:write(target..": "..table.concat(deps, " ").."\n")
        f:close()
    end
end

track_file = function(filename)
    local filename = expand_vars(filename)
    add_dep(filename)
    local content = assert(io.open(filename)):read("a")
    return filename, content
end

-- }}}

-- Conditional blocks, commented blocks {{{

local function conditional(empty)
    return function(block)
        if has_class(block, "if") then
            local attributes_to_clean = {}
            local cond = true
            for k, v in pairs(block.attr.attributes) do
                local val = _G[k]
                if type(val) == "table" then
                    val = utils.stringify(val)
                else
                    val = tostring(val)
                end
                cond = cond and (val == v)
                table.insert(attributes_to_clean, k)
            end
            if cond then
                local block = block:clone()
                block.attr = clean_attr({"if"}, attributes_to_clean, block.attr)
                return block
            else
                return empty, false -- return pandoc.Null
            end
        end
    end
end

local function comment(block)
    if has_class(block, "comment") then
        return nullBlock, false
    end
end

-- }}}

-- {{{ File inclusion

local function apply_pattern(pattern, format, content)
    if pattern then
        local i, j = content:find(pattern)
        if i then
            content = content:sub(i, j)
            if format then
                content = content:gsub(pattern, format)
            end
        end
    end
    return content
end

local function parse_and_shift(text, shift)
    local doc = pandoc.read(text)
    local div = pandoc.Div(doc.blocks)
    if shift then
        div = pandoc.walk_block(div, {
            Header = function(h)
                h = h:clone()
                h.level = h.level + shift
                return h
            end })
    end
    for _, filter in ipairs(filters) do
        div = pandoc.walk_block(div, filter)
    end
    return div.content
end

local function include_div(block)
    local filename = get_attr(block, "include")
    if filename then
        local shift = tonumber(get_attr(block, "shift"))
        local pattern = get_attr(block, "pattern")
        local format = get_attr(block, "format")
        local filename, content = track_file(filename)
        content = apply_pattern(pattern, format, content)
        return parse_and_shift(content, shift), false
    end
end

include_codeblock = function(block)
    local filename = get_attr(block, "include")
    if filename then
        local from = tonumber(get_attr(block, "from") or get_attr(block, "fromline"))
        local to = tonumber(get_attr(block, "to") or get_attr(block, "toline"))
        local pattern = get_attr(block, "pattern")
        local format = get_attr(block, "format")
        local filename, content = track_file(filename)
        if from or to then
            from = from or 1
            to = to or math.huge
            local lines = {}
            local i = 1
            for line in string.gmatch(content, "[^\n]*") do
                if i >= from and i <= to then table.insert(lines, line) end
                i = i+1
            end
            content = table.concat(lines, "\n")
        end
        content = apply_pattern(pattern, format, content)
        local newblock = block:clone()
        newblock.text = content
        newblock.attr = clean_attr(
            {}, {"include", "from", "fromline", "to", "toline", "pattern", "format", "shift"},
            newblock.attr)
        return newblock, false
    end
end

-- }}}

-- {{{ Scripts

local function make_script_cmd(cmd, arg, ext)
    arg = arg..ext
    local n1, n2
    cmd, n1 = cmd:gsub("%%s"..(ext and "%"..ext or ""), arg)
    cmd, n2 = cmd:gsub("%%s", arg)
    if n1+n2 == 0 then cmd = cmd .. " " .. arg end
    return cmd
end

local scripttypes = {
    {cmd="^python",         ext=".py"},
    {cmd="^lua",            ext=".lua"},
    {cmd="^bash",           ext=".sh"},
    {cmd="^zsh",            ext=".sh"},
    {cmd="^sh",             ext=".sh"},
    {cmd="^cmd",            ext=".cmd"},
    {cmd="^command",        ext=".bat"},
    {cmd="^dotnet%s+fs",    ext=".fs"}
}

local function script_ext(cmd)
    local ext = cmd:match("%%s(%.%w+)") -- extension given by the command line
    if ext then return ext end
    for _, scripttype in ipairs(scripttypes) do
        if cmd:match(scripttype.cmd) then return scripttype.ext end
    end
    return ""
end

local function run_script(cmd, content)
    return system.with_temporary_directory("panda_script", function (tmpdir)
        local name = tmpdir.."/script"
        local ext = script_ext(cmd)
        local f = assert(io.open(name..ext, "w"))
        f:write(content)
        f:close()
        local p = assert(io.popen(make_script_cmd(cmd, name, ext)))
        local output = assert(p:read("a"))
        local ok, _, err = p:close()
        if ok then
            return output:gsub("%s*$", "")
        else
            error("script error")
        end
    end)
end

local function script(conf)
    return function(block)
        local cmd = get_attr(block, "cmd")
        local icmd = get_attr(block, "icmd")
        local shift = tonumber(get_attr(block, "shift"))
        if cmd or icmd then
            local code = block:clone()
            code.text = run_script(cmd or icmd, code.text)
            code.attr = clean_attr({}, {"cmd", "icmd", "shift"}, code.attr)
            if icmd then
                code = parse_and_shift(code.text)
                code = conf.inline and utils.blocks_to_inlines(code) or code
            end
            return code, false
        end
    end
end

-- }}}

-- {{{ Diagrams

local function set_diagram_env()

    local path = dirname(PANDOC_SCRIPT_FILE)
    if not _G["PLANTUML"] then _G["PLANTUML"] = path.."/plantuml.jar" end
    if not _G["DITAA"] then _G["DITAA"] = path.."/ditaa.jar" end

    local default_ext = "svg"
    if FORMAT == "html" then default_ext = "svg" end
    if FORMAT == "html5" then default_ext = "svg" end
    if FORMAT == "latex" then default_ext = "pdf" end
    if FORMAT == "beamer" then default_ext = "pdf" end

    local function engines(exes, exts, cmd, post)
        post = post or function(_, c) return c end
        for exe in exes:gmatch "%S+" do
            for ext in exts:gmatch "%S+" do
                _G[exe.."."..ext] = expand_vars(post(ext, cmd:gsub("%%exe", exe):gsub("%%ext", ext):gsub("%%o", "%%o."..ext)))
            end
            _G[exe] = expand_vars(post(default_ext, cmd:gsub("%%exe", exe):gsub("%%ext", default_ext):gsub("%%o", "%%o."..default_ext)))
        end
    end
    engines("dot neato twopi circo fdp sfdp patchwork osage", "svg png pdf", "%exe -T%ext -o %o %i")
    engines("plantuml", "svg png pdf", "java -jar {{PLANTUML}} -pipe -charset UTF-8 -t%ext < %i > %o")
    engines("asy", "svg png pdf", "%exe -f %ext -o %o %i")
    engines("mmdc", "svg png pdf", "%exe -i %i -o %o")
    engines("actdiag blockdiag  nwdiag  packetdiag  rackdiag  seqdiag", "svg png pdf", "%exe -a -T%ext -o %o %i")
    engines("ditaa", "svg png", "java -jar {{DITAA}} %svg -o -e UTF-8 %i %o", function(ext, cmd)
        return cmd:gsub("%%svg", ext=="svg" and "--svg" or "")
    end)
    engines("gnuplot", "svg png pdf", "%exe -e 'set terminal %ext' -e 'set output \"%o\"' -c %i")
end

local function get_ext(s)
    return s:match("%%o(%.%w+)") or ""
end

local function make_diagram_cmd(src, img, render)
    return render:gsub("%%i", src):gsub("%%o", img)
end

local function render_diagram(cmd, contents)
    local p = assert(io.popen(cmd))
    local output = p:read("a")
    local ok, _, err = p:close()
    if not ok then
        error("diagram error: "..output)
    end
end

local function default_image_cache()
    return _G["PANDA_CACHE"] or ".panda"
end

local function diagram(block)
    local render = get_attr(block, "render")
    if render then
        local contents = block.text
        local ext = get_ext(render)
        local img = get_attr(block, "img")
        local output_path = get_attr(block, "out")
        local target = get_attr(block, "target")
        local hash_digest = pandoc.sha1(render..contents)
        if not img then
            local image_cache = default_image_cache()
            mkdir(image_cache)
            img = image_cache.."/"..hash_digest
        else
            img = img:gsub("%%h", hash_digest)
        end
        local out = expand_path(output_path and (output_path.."/"..basename(img)) or img)
        local meta = out..ext..".meta"
        local meta_content = "source: "..hash_digest.."\n"..
                             "render: "..render.."\n"..
                             "img: "..img.."\n"..
                             "out: "..out.."\n"..
                             "\n"..contents

        local old_meta = file_content(meta) or ""
        if not file_exists(out..ext) or meta_content ~= old_meta then
            system.with_temporary_directory("panda_diagram", function (tmpdir)
                local name = tmpdir.."/diagram"
                local f = io.open(name, "w")
                f:write(contents)
                f:close()
                local f = assert(io.open(meta, "w"), "Can not create "..meta)
                f:write(meta_content)
                f:close()
                render = make_diagram_cmd(name, out, render)
                render_diagram(render, contents)
            end)
        end

        local caption = get_attr(block, "caption")
        local title = get_attr(block, "title") -- deprecated, use caption
        caption = caption or title or ""
        local alt = get_attr(block, "alt") or caption
        local attrs = clean_attr({}, {"render", "img", "out", "target", "caption", "title", "alt"}, block.attr)
        local image = pandoc.Image(alt, img..ext, caption, attrs)
        if target then
            return pandoc.Para{pandoc.Link(image, target, caption)}, false
        else
            return pandoc.Para{image}, false
        end
    end
end

-- }}}

get_env_var()
set_diagram_env()

filters = {
    traverse = 'topdown',

    -- Macro expansion
    { Meta = read_vars_in_meta },
    { CodeBlock = read_vars_in_block },
    { Str = expand_str,
      CodeBlock = expand_codeblock,
      Div = expand{"attr"},
      Header = expand{"attr"},
      RawBlock = expand{"attr"},
      Table = expand{"attr"},
      Code = expand{"text", "attr"},
      Image = expand{"attr", "src", "title"},
      Link = expand{"attr", "target", "title"},
      Math = expand{"text"},
      RawInline = expand{"text"},
      Span = expand{"attr"},
      TableBody = expand{"attr"},
      TableFoot = expand{"attr"},
      TableHeader = expand{"attr"},
    },

    -- Conditional blocks
    { Block = conditional(nullBlock),
      Inline = conditional(nullInline),
    },

    -- Commented blocks
    { Block = comment },

    -- File inclusion
    { CodeBlock = include_codeblock,
      Div = include_div,
    },

    -- Scripts
    { CodeBlock = script{inline=false},
      Code = script{inline=true},
    },

    -- Diagrams
    { CodeBlock = diagram },
}

return filters
