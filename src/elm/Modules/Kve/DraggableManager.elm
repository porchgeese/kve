module Modules.Kve.DraggableManager exposing (..)
import Html exposing (Html,div)
import Html.Attributes exposing (style,class)
import Model.PxDimensions exposing (PxDimensions,toPxlStr)
import Model.PxPosition exposing (PxPosition,toTranslateStr,subtractHafDimensions)


type alias DraggableElement model msg = {
    render : model -> Html msg,
    elem: model,
    position: PxPosition,
    dimensions: PxDimensions
 }

render : DraggableElement model msg -> Html msg
render elem = div
    [
        class "draggable-elem",
        style "top" "0px",
        style "left" "0p",
        style "transform" ((elem.dimensions |> subtractHafDimensions(elem.position) |> toTranslateStr) ++ " rotate(4deg)") ,
        style "position" "absolute",
        style "display" "block",
        style "width" (elem.dimensions.width |> toPxlStr),
        style "height" (elem.dimensions.height |> toPxlStr)
    ][div[][elem.render(elem.elem)]]
