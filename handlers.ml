module Handlers = struct
  let index_get _ =
    (`OK, "alt er fint")

  let index_post body =
    (`OK, "Got a POST with body: " ^ body)
end
