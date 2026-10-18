-- Load every plugin, checking that each command trigger names a command its
-- plugin defines. finish() fails on any error a plugin's hooks report.
local lz = require("lz.n")

--- Specs of the plugins that haven't loaded yet, in name order.
local function pending()
  local specs = {}
  for name in pairs(Probe.plugins()) do
    -- lookup only finds plugins that haven't loaded.
    local spec = lz.lookup(name)
    if spec then table.insert(specs, spec) end
  end
  table.sort(specs, function(a, b) return a.name < b.name end)
  return specs
end

-- A stale command name still gets a loading stub, which lz.n removes when the
-- plugin loads; the command then doesn't exist.
for _, spec in ipairs(pending()) do
  if spec.cmd then
    lz.trigger_load(spec.name)
    for _, command in ipairs(spec.cmd) do
      Probe.assert_eq(spec.name .. " defines :" .. command, 2, vim.fn.exists(":" .. command))
    end
  end
end
-- Plugins with triggers before the libraries: their hooks load what they use
-- in the order it expects.
for _, spec in ipairs(pending()) do
  if spec.event or spec.keys or spec.colorscheme then lz.trigger_load(spec.name) end
end
for _, spec in ipairs(pending()) do
  lz.trigger_load(spec.name)
end
local missing = {}
for name, loaded in pairs(Probe.plugins()) do
  if not loaded then table.insert(missing, name) end
end
table.sort(missing)
Probe.assert_eq("every plugin loaded", "", table.concat(missing, ", "))
Probe.finish("load-all")
