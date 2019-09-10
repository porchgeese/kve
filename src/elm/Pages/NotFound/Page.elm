module Pages.NotFound.Page exposing (render)

import Html exposing (div,img, input,p, button,h2,text,Html)
import Html.Attributes exposing (id, src, class)

render: Html event
render =
    div[id "not-found"][
    div[class "description"][h2[][text("not found")]],
    div[class "logo"][img[src "/logo.png"][]]
    ]

