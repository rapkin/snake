log = (str) -> console.log str

$ = (id) -> document.getElementById id

random_int = (min, max) -> Math.floor(Math.random() * (max - min + 1)) + min

def_comp = (a, b) -> return a is b

arr_comp = (a, b) -> return a[0] is b[0] and a[1] is b[1]

intersec_arrays = (A, B, comparator = def_comp) ->
  c = []
  d = do A.slice
  for a,i in A
    for b in B
      if comparator(a, b) then d[i] = no
  for a in d
    if a then c[c.length] = a
  return c
