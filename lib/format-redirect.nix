_: r:
let
  status = if r ? status then toString r.status else "301";
in
"${r.from} ${r.to} ${status}"
