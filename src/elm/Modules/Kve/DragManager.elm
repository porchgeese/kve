module Modules.Kve.DragManager exposing (
    InternalEvents, Events(..), Model, render,
    update, startDrag, subscriptions
    )
import Html exposing (Html,div)
import Html.Attributes exposing (style,class)
import Model.PxDimensions exposing (PxDimensions,toPxlStr)
import Model.PxPosition exposing (PxPosition,toTranslateStr,AbsolutePosition, subtractHafDimensions)
import Browser.Events exposing (onMouseMove,onMouseUp)
import Task
import Browser.Dom exposing (getElement, Element,Error(..))
import Browser.Dom exposing (getElement, Element)
import Ext.Cmd as CmtExt exposing (cmd)
import Json.Decode as Decode

type Events =
    DragStart |
    DragProgress AbsolutePosition |
    DragCancelled AbsolutePosition |
    DragFinished AbsolutePosition |
    DragError String

type InternalEvents =
    ObtainedSelectionDimensions PxDimensions |
    MouseMoved PxPosition |
    MouseUp PxPosition |
    InternalError String

type alias ElementId = String
type alias Model elem = {
    elem: Maybe elem,
    dragInProgress: Maybe PxPosition,
    dimensions: Maybe PxDimensions
 }

startDrag : PxPosition -> ElementId -> elem -> (Model elem, Cmd InternalEvents)
startDrag position selector elem = (Model(Just elem)(Just position)(Nothing),(Cmd.batch [elementDimensions(selector)]))

elementDimensions: String -> Cmd InternalEvents
elementDimensions id =
    getElement(id)
    |>
    Task.map
    (\result -> ObtainedSelectionDimensions(PxDimensions(result.element.width)(result.element.height)))
    |>
    Task.mapError
    (\err -> case err of
      NotFound msg -> InternalError msg
    )
    |>
    Task.attempt
    (\result -> case result of
       Ok r -> r
       Err r -> r
    )

update: (Events -> event) -> Model elem -> InternalEvents -> (Model elem, Cmd event)
update commandMapper model event =
    case event of
        ObtainedSelectionDimensions dimensions ->
            ({model | dimensions = Just dimensions}, cmd (commandMapper(DragStart)))
        MouseMoved position ->
            ({model | dragInProgress = Just position}, cmd (commandMapper(DragProgress position)))
        MouseUp position ->
            ({model | dragInProgress = Nothing, dimensions = Nothing}, cmd (commandMapper(DragFinished position)))
        InternalError error ->
            ({model | dragInProgress = Nothing, dimensions = Nothing}, cmd (commandMapper(DragError error)))

subscriptions: Model elem -> Sub InternalEvents
subscriptions model =
   Maybe.map2
       (\_ _ -> [onMouseMove decodeMousePosition, onMouseUp decodeMouseUp])
       (model.dimensions) (model.dragInProgress)
   |> Maybe.withDefault []
   |> Sub.batch

decodeMousePosition: Decode.Decoder InternalEvents
decodeMousePosition =
    Decode.map2
      (\x y -> MouseMoved(PxPosition(x)(y)))
      (Decode.field "clientX" Decode.float)
      (Decode.field "clientY" Decode.float)

decodeMouseUp: Decode.Decoder InternalEvents
decodeMouseUp =
    Decode.map2
      (\x y -> MouseUp(PxPosition(x)(y)))
      (Decode.field "clientX" Decode.float)
      (Decode.field "clientY" Decode.float)

render : Model elem -> (elem -> Html msg) -> Html msg
render model renderF =
    Maybe.map3
        (\elem dip dimensions ->
            div[
             class "dragging-manager",
             style "top" "0px",
             style "left" "0p",
             style "transform" ((dimensions |> subtractHafDimensions(dip) |> toTranslateStr) ++ " rotate(4deg)") ,
             style "position" "absolute",
             style "display" "block",
             style "width" (dimensions.width |> toPxlStr),
             style "height" (dimensions.height |> toPxlStr)
            ][div[][renderF(elem)]]
        )
        (model.elem)
        (model.dragInProgress)
        (model.dimensions)
    |>
     Maybe.withDefault (div[class "dragging-manager-off"][])

