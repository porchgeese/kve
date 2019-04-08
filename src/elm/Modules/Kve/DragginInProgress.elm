module Modules.Kve.DragginInProgress exposing (render, subscriptions,init, Model, handleMouseMove, dragStarted, dragOver,handleDimensions)
import Html exposing (Html,div)
import Html.Attributes exposing (style,class)
import Model.PxDimensions exposing (PxDimensions,toPxlStr)
import Model.PxPosition exposing (PxPosition,toTranslateStr,subtractHafDimensions)
import Modules.Kve.Event.KveEvents exposing (Events(..))
import Browser.Events exposing (onMouseMove,onMouseUp)
import Task
import Browser.Dom exposing (getElement, Element)
import Modules.Kve.Decoder.Mouse exposing (decodeMouseUp, decodeMousePosition)


type alias DragInProgress elem = {element: elem, mouse: PxPosition, dimensions: Maybe PxDimensions}

type alias Model elem = {
    render : elem -> Html Events,
    dragInProgress: Maybe (DragInProgress elem)
 }

init : (elem -> Html Events) -> (Model elem, Cmd msg)
init html = (Model(html)(Nothing), Cmd.none)

dragStarted : Model elem -> elem -> PxPosition -> String -> (Model elem, Cmd Events)
dragStarted model elem position id =
    ({model | dragInProgress = Just(DragInProgress(elem)(position)(Nothing))} , elementDimensions(id))

dragOver : Model elem -> (Model elem, Cmd Events)
dragOver model  =
    ({model | dragInProgress = Nothing} , Cmd.none)

elementDimensions: String -> Cmd Events
elementDimensions id =
    Task.attempt
        (\result ->
            case result of
               Ok e -> SelectionDimensions(PxDimensions(e.element.width)(e.element.height))
               Err event -> EventError("Could not find dimensions for element.}")
          )
        (getElement(id))


handleDimensions:  PxDimensions -> Model elem -> (Model elem, Cmd Events)
handleDimensions dim model =
    case model.dragInProgress of
        Nothing ->
            (Model(model.render)(Nothing), Cmd.none)
        Just dragInProgress ->
            (Model(model.render)(Just({dragInProgress | dimensions = Just dim})), Cmd.none)

subscriptions: Model elem -> Sub Events
subscriptions model =
    Maybe.map
       (\_ -> [onMouseMove decodeMousePosition, onMouseUp decodeMouseUp])
       (model.dragInProgress) |> Maybe.withDefault [] |> Sub.batch

handleMouseMove:  PxPosition -> Model elem -> (Model elem, Cmd Events)
handleMouseMove position model =
    case model.dragInProgress of
        Nothing ->
            (Model(model.render)(Nothing), Cmd.none)
        Just dragInProgress ->
            (Model(model.render)(Just({dragInProgress | mouse = position})), Cmd.none)

render : Model elem -> Html Events
render model =
    let dimAndDip = Maybe.andThen (\dip -> Maybe.map (\dim -> (dim,dip)) dip.dimensions) model.dragInProgress
    in
      case dimAndDip of
        Nothing -> div[class "dragging-manager-off"][]
        Just (dimensions,dip) ->
            div[
               class "dragging-manager",
               style "top" "0px",
               style "left" "0p",
               style "transform" ((dimensions |> subtractHafDimensions(dip.mouse) |> toTranslateStr) ++ " rotate(4deg)") ,
               style "position" "absolute",
               style "display" "block",
               style "width" (dimensions.width |> toPxlStr),
               style "height" (dimensions.height |> toPxlStr)
            ][div[][model.render(dip.element)]]
