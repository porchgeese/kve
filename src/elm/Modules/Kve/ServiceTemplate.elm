module Modules.Kve.ServiceTemplate exposing (..)
import Html exposing (Html,div,img)
import Html.Events exposing (stopPropagationOn)
import Html.Attributes exposing (class, id,src, draggable)
import Json.Decode as Json exposing (..)
import Model.PxPosition exposing (PxPosition)
import Model.PxPosition exposing (PxPosition)
import Modules.Kve.Event.KveEvents exposing (Events(..))
import Modules.Kve.Model.KveModel exposing (Service)

decodeServiceSelected: Service -> (Json.Decoder (Events, Bool))
decodeServiceSelected service =
    Json.map2
     (\x y -> (ServiceSelected(service)(PxPosition(x)(y)), True))
     (field "pageX" float)
     (field "pageY" float)

render: Service -> Html Events
render service = div[
    stopPropagationOn "mousedown" (decodeServiceSelected(service)),
    class  "service-template",
    id (service.id)
    ][img[
        src ("https://api.adorable.io/avatars/75/" ++ service.name),
        draggable "false"
        ][]]