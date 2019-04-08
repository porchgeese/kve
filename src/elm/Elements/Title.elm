module Elements.Title exposing (view,Title)
import Html exposing (..)


type alias Title = {title: String}
view : Title -> Html msg
view header = div[][h2[][text(header.title)]]