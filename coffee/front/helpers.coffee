log = (str) -> console.log str

$ = (id) -> document.getElementById id

value_tag = (tag) -> tag.getElementsByClassName('value')[0]

random_int = (min, max) -> Math.floor(Math.random() * (max - min + 1)) + min
