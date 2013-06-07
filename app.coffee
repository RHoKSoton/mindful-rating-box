async = require 'async'
i2c = require 'raspi2c'
MCP230xx = require 'raspi2c/lib/devices/MCP230xx'

node = require '../nodestuff/play.js'

mcp = new MCP230xx(0x20, 1, 16)

OUTPUT = 0
INPUT = 1
HAPPY_BUTTON_PIN = 8
SAD_BUTTON_PIN = 9
VOL_MINUS_BUTTON_PIN = 10
VOL_PLUS_BUTTON_PIN = 11

# The main loop
main = ->
  state = {}
  async.forever (next) ->
    setTimeout ->
      mcp.inputAll (pins) ->
        # invert
        pins[i] = !p for p, i in pins
        NONE = 0
        SHORT = 1
        LONG = 2
        checkState = (pin, key, cb) ->
          pressType = NONE
          if pins[pin] isnt state[key]?
            console.log "Changed: #{pin} from #{state[key]?} to #{pins[pin]}"
            if state[key]
              duration = +new Date() - state[key]
              if duration > 1000
                pressType = LONG
              else
                pressType = SHORT
              delete state[key]
            else
              state[key] = +new Date()
          cb pressType
        checkState HAPPY_BUTTON_PIN, 'happyButton', (type) ->
          if type is SHORT
            node.happyPressed()
          else if type is LONG
            node.play()
        checkState SAD_BUTTON_PIN, 'sadButton', (type) ->
          if type is SHORT
            node.skipPressed()
          else if type is LONG
            node.pause()
        checkState VOL_MINUS_BUTTON_PIN, 'volMinusButton', (type) ->
          if type isnt NONE
            node.volumeDownPressed()
        checkState VOL_PLUS_BUTTON_PIN, 'volPlusButton', (type) ->
          if type isnt NONE
            node.volumeUpPressed()
        next()
    , 0

async.series
  init: (next) ->
    mcp.init next
  config: (next) ->
    mcp.config [8..15], INPUT
    mcp.config [0..7], OUTPUT, next
  turnOnLed: (next) ->
    console.log "Turning on the LED"
    mcp.output 0, 1, next
  pullup: (next) ->
    mcp.pullup [8..15], 1, next
  main: main
