async = require 'async'
i2c = require 'raspi2c'
MCP230xx = require 'raspi2c/lib/devices/MCP230xx'

mcp = new MCP230xx(0x20, 1, 16)

OUTPUT = 0
INPUT = 1

async.series
  init: (next) ->
    mcp.init next
  config: (next) ->
    console.log "Trying it..."
    mcp.config 0, OUTPUT, next
  output: (next) ->
    mcp.output 0, 1, next
  wait: (next) ->
    setTimeout next, 1000
  off: (next) ->
    mcp.output 0, 0, next
  cleanup: (next) ->
    console.log "Done"
