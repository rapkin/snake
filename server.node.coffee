config = require './config.json'
express = require 'express'
fs = require 'fs'
md5 = require 'MD5'
path = require 'path'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'

db = require('mongojs').connect config.mongo_uri, ['levels', 'users', 'scores']

# Re-create the database
db.users.findOne {name: 'default'}, (e, user) ->
  return if user?
  db.scores.remove()
  db.levels.remove()
  db.users.remove()
  save_user 'default'
  console.log '[ DATABASE CREATED ]'

app = express()
app.set 'port', process.env.PORT or 4242
app.listen app.get('port'), -> console.log "Started on #{app.get('port')}"

app.set 'view engine', 'jade'
app.use bodyParser.json()
app.use cookieParser()
app.use bodyParser.urlencoded extended: true

pass_hash = (pass, time) -> md5("answer_42_#{pass}_#{time}")

save_user = (name, pass) ->
  time = Date.now()
  user = name: name, pass: pass_hash(pass, time), time: time
  user = name: name if name is 'default'
  db.users.save user, (e, user) ->
    levels = for file in fs.readdirSync 'levels'
      path.basename file, '.json'
    for name in levels
      lvl = get_lvl_from_file name
      lvl.uid = user._id
      db.levels.save lvl

get_lvl_from_file = (name) ->
  lvl_file = "./levels/#{name}.json"
  return null if not fs.existsSync lvl_file
  lvl = JSON.parse fs.readFileSync lvl_file, 'utf-8'
  lvl.name = name
  lvl.barrier = make_barrier lvl.barrier
  return lvl

save_level = (level, user_name, lvl_name, cur_user = user_name, callback) ->
  return if cur_user is 'default' or user_name isnt cur_user
  db.users.findOne {name: user_name}, (e, user) ->
    return unless user?
    db.levels.findOne {name: lvl_name, uid: user._id}, (e, lvl) ->
      level._id = lvl._id if lvl
      level.name = lvl_name
      level.uid = user._id
      db.levels.save level, -> callback()

save_score = (score, user_name, lvl_name) ->
  return if user_name is 'default'
  db.users.findOne {name: user_name}, (e, user) ->
    return if e or not user?
    score.uid = user._id
    db.levels.findOne {name: lvl_name, uid: user._id}, (e, lvl) ->
      return if e or not lvl?
      score.lid = lvl._id
      db.scores.findOne {uid: user._id, lid: lvl._id}, (e, last_score) ->
        if last_score?
          return if last_score.value > score.value
          score._id = last_score._id
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
  name = req.cookies.snake_user_name or 'default'
  db.users.findOne {name: name}, (e, user) ->
    if e or not user?
      res.redirect '/logout'
      return
    db.levels.find(uid: user._id).sort {name: 1}, (e, levels) ->
      names = for _l in levels then _l.name
      res.render 'levels', levels: names, user: name

app.get '/register', (req, res) ->
  if req.cookies.snake_user_name?
    res.redirect '/'
    return
  res.render 'register'

app.get '/login', (req, res) ->
  if req.cookies.snake_user_name?
    res.redirect '/'
    return
  res.render 'login'

app.get '/logout', (req, res) ->
  res.clearCookie 'snake_user_name'
  res.redirect '/'

app.get '/new_level', (req, res) ->
  name = req.cookies.snake_user_name or 'default'
  if name is 'default'
    res.redirect '/'
    return
  res.render 'new_level'

app.get '/delete_level/:user/:name', (req, res) ->
  if req.params.user is 'default'
    res.redirect '/'
    return
  db.users.findOne {name: req.params.user}, (e, user) ->
    if not e and user?
      db.levels.findOne {uid: user._id, name: req.params.name}, (e, lvl) ->
        if not e and lvl?
          db.scores.remove {lid: lvl._id}
          db.levels.remove {_id: lvl._id}, -> res.redirect '/'

app.get '/:user/:level', (req, res) ->
  user_name = req.cookies.snake_user_name or 'default'
  db.users.findOne {name: req.params.user}, (e, user) ->
    if e or not user?
      res.redirect '/'
      return
    db.levels.findOne {name: req.params.level, uid: user._id}, (e, lvl) ->
      if e or not lvl?
        res.redirect '/'
        return
      db.scores.findOne {uid: user._id, lid: lvl._id}, (e, score) ->
        lvl.high_score = 0
        lvl.high_score = score.value if score? and score.value?
        lvl.user = user.name
        lvl.barrier = JSON.stringify lvl.barrier
        res.render 'game', lvl

app.post '/save_level/:user/:level', (req, res) ->
  user = req.cookies.snake_user_name or 'default'
  level = req.body
  if level? and user isnt 'default'
    save_level level, req.params.user, req.params.level, user, -> res.sendStatus 200

app.post '/save_score/:user/:level', (req, res) ->
  score = req.body
  save_score score, req.params.user, req.params.level if score?
  res.sendStatus 200

app.post '/login', (req, res) ->
  name = req.body.name.trim()
  pass = req.body.pass.trim()
  if name is 'default'
    res.redirect '/login'
    return
  db.users.findOne {name: name}, (e, user) ->
    if e or not user?
      res.redirect '/login'
      return
    if user.pass is pass_hash(pass, user.time)
      res.cookie 'snake_user_name', name
      res.redirect '/'
    else res.redirect '/login'

app.post '/register', (req, res) ->
  regex = /^[a-z0-9_]{3,42}$/
  name = req.body.name.trim()
  pass = req.body.pass.trim()
  if name.match(regex) and pass.match(regex)
    db.users.findOne {name: name}, (e, user) ->
      if not user?
        save_user name, pass
        res.cookie 'snake_user_name', name
        res.redirect '/'
      else res.redirect '/register'
  else res.redirect '/register'

app.post '/new_level', (req, res) ->
  user = req.cookies.snake_user_name or 'default'
  return if user is 'default'
  lvl_name = req.body.name.trim()
  if not lvl_name.match(/^[a-z0-9_]{1,23}$/)
    res.redirect '/new_level'
    return
  save_level get_lvl_from_file(1), user, lvl_name, user, -> res.redirect '/'
