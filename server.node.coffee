express = require 'express'
fs = require 'fs'
path = require 'path'
parser = require 'body-parser'
db = require('mongojs').connect 'mongodb://localhost:27017/snake', ['levels', 'users', 'scores']
app = express()

db.users.find {name: 'default'}, (e, u) ->
  return if u[0]?
  db.scores.remove {}
  db.levels.remove {}
  db.users.remove {}
  db.users.save name: 'default', (e, u) ->
    levels = for file in fs.readdirSync 'levels'
      path.basename file, '.json'
    for name in levels
      lvl = get_lvl_from_file name
      lvl.uid = u._id
      db.levels.save lvl


app.set 'view engine', 'jade'
app.use parser.text()

get_lvl_from_file = (name) ->
  lvl_file = "./levels/#{name}.json"
  console.log "[FILE] #{lvl_file}"
  return null if not fs.existsSync lvl_file
  lvl = JSON.parse fs.readFileSync lvl_file, 'utf-8'
  lvl.name = name
  lvl.barrier = make_barrier lvl.barrier
  return lvl

save_level = (level, user_name, lvl_name) ->
  db.users.find {name: user_name}, (e, u) ->
    return unless u[0]?
    db.levels.find {name: lvl_name, uid: u[0]._id}, (e, l) ->
      level._id = l[0]._id if l[0]?
      level.name = lvl_name
      level.uid = u[0]._id
      db.levels.save level

save_score = (score, user_name, lvl_name) ->
  db.users.find {name: user_name}, (e, u) ->
    return unless u[0]? or not e
    score.uid = u[0]._id
    db.levels.find {name: lvl_name}, (e, l) ->
      return unless l[0]? or not e
      score.lid = l[0]._id
      db.scores.find {uid: u[0]._id, lid: l[0]._id}, (e, s) ->
        if s[0]?
          score._id = s[0]._id
          return if s[0].value > score.value
        score.time = Date.now()
        db.scores.save score

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
  db.levels.find().sort {name: 1}, (e, l) ->
    levels = for _l in l then _l.name
    res.render 'index', levels: levels, game: false

app.get '/:user/:level', (req, res) ->
  level = req.params.level
  user = req.params.user
  db.users.find {name: user}, (e, u) ->
    if e or u.length is 0
      res.redirect '/'
      return
    db.levels.find {name: level, uid: u[0]._id}, (e, l) ->
      if e or l.length is 0
        res.redirect '/'
        return
      level = l[0]
      db.scores.find {uid: u[0]._id, lid: level._id}, (e, s) ->
        level.high_score = 0
        level.high_score = s[0].value if s[0]?
        level.game = yes
        level.barrier = JSON.stringify level.barrier
        res.render 'index', level

app.post '/save_level/:user/:level', (req, res) ->
  level = JSON.parse req.body
  save_level level, req.params.user, req.params.level
  res.sendStatus 200

app.post '/save_score/:user/:level', (req, res) ->
  score = JSON.parse req.body
  save_score score, req.params.user, req.params.level
  res.sendStatus 200

app.listen 4242
