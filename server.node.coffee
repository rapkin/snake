express = require 'express'
fs = require 'fs'
md5 = require 'MD5'
path = require 'path'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
db = require('mongojs').connect 'mongodb://localhost:27017/snake', ['levels', 'users', 'scores']

# Re-create the database
db.users.find {name: 'default'}, (e, u) ->
  return if u[0]?
  db.scores.remove {}
  db.levels.remove {}
  db.users.remove {}
  save_user 'default'
  console.log "[ DATABASE CREATED ]"

app = express()
app.listen 4242
app.set 'view engine', 'jade'
app.use bodyParser.text()
app.use cookieParser()
app.use bodyParser.urlencoded extended: true

pass_hash = (pass, time) ->
  md5("answer_42_#{pass}_#{time}")

save_user = (name, pass) ->
  time = Date.now()
  user = name: name, pass: pass_hash(pass, time), time: time
  user = name: name if name is 'default'
  db.users.save user, (e, u) ->
    levels = for file in fs.readdirSync 'levels'
      path.basename file, '.json'
    for name in levels
      lvl = get_lvl_from_file name
      lvl.uid = u._id
      db.levels.save lvl

get_lvl_from_file = (name) ->
  lvl_file = "./levels/#{name}.json"
  return null if not fs.existsSync lvl_file
  lvl = JSON.parse fs.readFileSync lvl_file, 'utf-8'
  lvl.name = name
  lvl.barrier = make_barrier lvl.barrier
  return lvl

save_level = (level, user_name, lvl_name) ->
  return if user_name is 'default'
  db.users.find {name: user_name}, (e, u) ->
    return unless u[0]?
    db.levels.find {name: lvl_name, uid: u[0]._id}, (e, l) ->
      level._id = l[0]._id if l[0]?
      level.name = lvl_name
      level.uid = u[0]._id
      db.levels.save level

save_score = (score, user_name, lvl_name) ->
  return if user_name is 'default'
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
  name = req.cookies.snake_user_name or 'default'
  db.users.find {name: name}, (e, u) ->
    if e or not u[0]?
      res.redirect '/logout'
      return
    db.levels.find(uid: u[0]._id).sort {name: 1}, (e, l) ->
      levels = for _l in l then _l.name
      res.render 'index', levels: levels, game: false, template: 'levels', user: name

app.get '/register', (req, res) ->
  if req.cookies.snake_user_name?
    res.redirect '/'
    return
  res.render 'index', template: 'register', head_title: 'Registration'

app.get '/login', (req, res) ->
  if req.cookies.snake_user_name?
    res.redirect '/'
    return
  res.render 'index', template: 'login', head_title: 'Login'

app.get '/logout', (req, res) ->
  res.clearCookie 'snake_user_name'
  res.redirect '/'

app.get '/new_level', (req, res) ->
  name = req.cookies.snake_user_name or 'default'
  if name is 'default'
    res.redirect '/'
    return
  res.render 'index', template: 'new_level', head_title: 'New level'

app.get '/delete_level/:user/:name', (req, res) ->
  if req.params.user is 'default'
    res.redirect '/'
    return
  db.users.find {name: req.params.user}, (e, u) ->
    if not e and u[0]?
      db.levels.remove {uid: u[0]._id, name: req.params.name}
    res.redirect '/'

app.get '/:user/:level', (req, res) ->
  user_name = req.cookies.snake_user_name or 'default'
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
        level.template = 'game'
        level.user = user_name
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

app.post '/login', (req, res) ->
  name = req.body.name
  pass = req.body.pass
  if name is 'default'
      res.redirect '/login'
      return
  db.users.find {name: name}, (e, u) ->
    if e or not u[0]?
      res.redirect '/login'
      return
    if u[0].pass is pass_hash(pass, u[0].time)
      # console.log u[0].pass + " " + pass_hash(pass, u[0].time)
      res.cookie 'snake_user_name', req.body.name
      res.redirect '/'
      return
    res.redirect '/login'

app.post '/register', (req, res) ->
  regex = /^[a-z0-9_]{3,42}$/
  name = req.body.name
  pass = req.body.pass
  if name.match(regex) and pass.match(regex)
    db.users.find {name: name}, (e, u) ->
      if u.length is 0
        save_user name, pass
        res.cookie 'snake_user_name', name
        res.redirect '/'
      else res.redirect '/register'
  else
    res.redirect 'register'

app.post '/new_level', (req, res) ->
  user = req.cookies.snake_user_name or 'default'
  return if user is 'default'
  lvl_name = req.body.name
  return unless lvl_name.match(/^[a-z0-9_]+$/)
  save_level get_lvl_from_file(1), user, lvl_name
  res.redirect '/'
