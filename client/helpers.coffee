log = (str) -> console.log str
warn = (str) -> console.warn str

$ = (id) -> document.getElementById id

value_tag = (tag) -> tag.getElementsByClassName('value')[0]

random_int = (min, max) -> Math.floor(Math.random() * (max - min + 1)) + min

getXmlHttp = ->
  try xmlhttp = new ActiveXObject 'Msxml2.XMLHTTP'
  catch e
    try xmlhttp = new ActiveXObject 'Microsoft.XMLHTTP'
    catch E then xmlhttp = false
    xmlhttp = new XMLHttpRequest() if not xmlhttp
  finally return xmlhttp

ajax = (path, object) ->
  req = getXmlHttp()
  req.open 'POST', path, true
  req.setRequestHeader 'Content-Type', 'application/json;charset=UTF-8'
  req.send JSON.stringify object
