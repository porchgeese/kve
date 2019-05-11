module Pages.Login.Page exposing (page, Model,Event(..), render)

import Browser
import Html exposing (div,img, input,p, button,h2,text,Html)
import Html.Attributes exposing (id,class,src, type_)
import Html.Events exposing (onClick)

type alias Model = ()
type Event =
    LoginSuccessful

render: Model -> Html Event
render _ =
    div[ id "login"][
        div[class "header"][
            img[src "/logo.png"][],
            h2[][text "Kubernetes Visual Editor"]
        ],
        div[class "body"][
            div[][p[][text "username"]],
            div[][input[type_ "text"][]],
            div[][p[][text "password"]],
            div[][input[type_ "password"][]],
            div[class "submit" , onClick LoginSuccessful][button[][text("login")]]
        ]
 ]

page: Model -> Browser.Document Event
page model = {
        title = "Login",
        body = [render(model)]
    }





