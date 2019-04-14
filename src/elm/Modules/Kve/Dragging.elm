module Modules.Kve.Dragging exposing (render, subscriptions, Model, DragInProgress)
import Html exposing (Html,div)
import Html.Attributes exposing (style,class)
import Model.PxDimensions exposing (PxDimensions,toPxlStr)
import Model.PxPosition exposing (PxPosition,toTranslateStr,centered)
import Browser.Events exposing (onMouseMove,onMouseUp)
import Json.Decode as Decode

import Modules.Kve.Decoder.Mouse as Mouse

type alias DragInProgress elem = {element: elem, mouse: PxPosition, dimensions: PxDimensions}
type alias Model elem = {
    dragging: Maybe (DragInProgress elem)
 }

subscriptions: (Mouse.Event -> event) -> Model elem -> Sub event
subscriptions mapping model =
    model.dragging
        |> Maybe.map (\_ -> [
            onMouseMove (Mouse.decodeMousePosition |> Decode.map mapping),
            onMouseUp (Mouse.decodeMouseUp |> Decode.map mapping)]
        )
        |> Maybe.withDefault []
        |> Sub.batch

render : (elem -> Html event) -> Model elem -> Html event
render elemRenderer model =
    model.dragging
        |> Maybe.map
            (\drag ->
                div[
                   class "dragging-manager",
                   style "top" "0px",
                   style "left" "0p",
                   style "transform" ((drag.mouse |> centered(drag.dimensions) |> toTranslateStr)) ,
                   style "position" "absolute",
                   style "display" "block",
                   style "width" (drag.dimensions.width |> toPxlStr),
                   style "height" (drag.dimensions.height |> toPxlStr)
                ][div[][elemRenderer(drag.element)]]
            )
        |> Maybe.withDefault (div[class "dragging-manager-off"][])



