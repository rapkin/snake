express = require 'express'
fs = require 'fs'
path = require 'path'
parser = require 'body-parser'
db = require('mongojs').connect 'mongodb://localhost:27017/snake', ['levels']
app = express()

app.set 'view engine', 'jade'
app.use parser.text()

get_lvl_from_file = (id) ->
  lvl_file = "./levels/#{id}.json"
  console.log "[FILE] #{lvl_file}"
  return null if not fs.existsSync lvl_file
  lvl = JSON.parse fs.readFileSync lvl_file, 'utf-8'
  lvl._id = parseInt id
  lvl.barrier = make_barrier lvl.barrier
  return lvl

save_lvl = (level) ->
  level._id = parseInt level._id
  db.levels.save level

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
  return temp


app.get '/', (req, res) ->
  db.levels.count (e, n) ->
    if n > 0
      db.levels.find {}, (e, l) ->
        levels = for _l in l then _l._id
        res.render 'index', levels: levels, game: false
    else
      levels = for file in fs.readdirSync 'levels'
        path.basename file, '.json'
      res.render 'index', levels: levels, game: false
      for id in levels
        save_lvl get_lvl_from_file id

app.get '/lvl/:id', (req, res) ->
  id = parseInt req.params.id
  db.levels.find {_id: id}, (e, l) ->
    if e or l.length is 0
      res.redirect '/'
      return
    level = l[0]
    level.game = yes
    level.barrier = JSON.stringify level.barrier
    res.render 'index', level

app.post '/save_level', (req, res) ->
  save_lvl JSON.parse req.body
  res.sendStatus 200

app.listen 4242
