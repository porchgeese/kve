module Modules.Kve.ServiceTemplate exposing (..)
import Html exposing (Html,div,text)
import Html.Events exposing (stopPropagationOn)
import Html.Attributes exposing (class, id)
import Json.Decode as Json exposing (..)
import Model.PxPosition exposing (PxPosition)
import Model.PxPosition exposing (PxPosition)
import Modules.Kve.Event.KveEvents exposing (Events(..))
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)

decodeServiceSelected: ServiceTemplate -> (Json.Decoder (Events, Bool))
decodeServiceSelected service =
    Json.map2
     (\x y -> (ServiceSelected {service = service, position = PxPosition(x)(y)}, True))
     (field "pageX" float)
     (field "pageY" float)


render: ServiceTemplate -> Html Events
render service = div[
    stopPropagationOn "mousedown" (decodeServiceSelected(service)),
    class  "service-template",
    id (service.id)
    ][text(service.name)
    ]