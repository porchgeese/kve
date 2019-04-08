module Modules.Kve.KubernetesService exposing (..)
import Html exposing (Html,div,img)
import Html.Attributes exposing (class, src, draggable)
import Modules.Kve.Event.KveEvents exposing (Events(..))
import Modules.Kve.Model.KveModel exposing (Service)


render: Service -> Html Events
render service = div[
    class  "kubernetes-service"
    ][img[
        src ("https://api.adorable.io/avatars/75/" ++ service.name),
        draggable "false"
        ][]]