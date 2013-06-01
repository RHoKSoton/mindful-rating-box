async = require 'async'
i2c = require 'raspi2c'
MCP230xx = require 'raspi2c/lib/devices/MCP230xx'

mcp = new MCP230xx(0x20, 1, 16)

OUTPUT = 0
INPUT = 1

# The main loop
main = ->
  while 1
    mcp.inputAll (pins) ->
      console.log if pins[8] then "Off" else "On"

async.series
  init: (next) ->
    mcp.init next
  config: (next) ->
    mcp.config [8..15], INPUT
    mcp.config [0..7], OUTPUT
    mcp.pullup [8..15], 1, next
  main: main
