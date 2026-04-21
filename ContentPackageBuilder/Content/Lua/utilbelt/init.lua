LuaUtilityBelt = {}
Lub = LuaUtilityBelt
---@type string
Lub.Path = ...
Lub.Test = false

require "utilbelt.extensions.table"
require "utilbelt.tools.diagnostics"

Lub.LiteOO = require "utilbelt.tools.liteoo"
Class = Lub.LiteOO.declare
New = Lub.LiteOO.new

Lub.Logger = require "utilbelt.logger"
Lub.Think = require "utilbelt.think"
Lub.Wait = require "utilbelt.wait"
Lub.Localization = require "utilbelt.l10n"
Lub.Chat = require "utilbelt.chat"
Lub.Dialog = require "utilbelt.dialog"
Lub.SPEdit = require "utilbelt.spedit"
Lub.ItemBuilder = require "utilbelt.itbu"
Lub.ItemBatch = require "utilbelt.itbat"

require "utilbelt.csharpmodule.Shared.Utils"
