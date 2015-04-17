express = require 'express'
fs = require 'fs'
path = require 'path'
app = express()

app.set 'view engine', 'jade'

getLvl = (id) ->
  lvl_file = "./levels/#{id}.json"
  return null if not fs.existsSync lvl_file
  JSON.parse fs.readFileSync lvl_file, 'utf-8'

make_barrier = (barrier) ->
  return unless barrier?
  temp = []
  if barrier.lines? then for line in barrier.lines
    if line.by is 'x'
      for x in [line.range[0]..line.range[1]]
        temp.push [x, line.y]
    if line.by is 'y'
      for y in [line.range[0]..line.range[1]]
        temp.push [line.x, y]

  if barrier.points? then for point in barrier.points
    temp.push point
  return JSON.stringify temp


app.get '/', (req, res) ->
  levels = for file in fs.readdirSync 'levels'
    path.basename file, '.json'
  res.render 'index', levels: levels, game: false

app.get '/lvl/:id', (req, res) ->
  lvl = getLvl req.params.id
  res.render 'index',
    barrier: make_barrier(lvl.barrier) or '[]'
    width: lvl.width or 20
    height: lvl.height or 20
    size: lvl.size or 20
    speed: lvl.speed or 5
    game: true

app.listen 4242
