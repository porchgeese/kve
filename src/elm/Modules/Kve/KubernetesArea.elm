module Modules.Kve.KubernetesArea exposing (..)
import Html exposing (Html,div,text)
import Html.Attributes exposing (class,id, style)
import Modules.Kve.Event.KveEvents exposing (Event(..))
import Modules.Kve.Decoder.Mouse exposing (decodeMouseUp, decodeMousePosition)
import Model.PxPosition exposing (PxPosition,toTranslateStr,relativePosition)
import Modules.Kve.Model.KveModel exposing (Service)
import Modules.Kve.KubernetesService as KubernetesService
import Browser.Events exposing (onMouseMove,onMouseUp)
import Browser.Dom exposing (getElement, Element)
import Task
import Result
import Maybe.Extra as MaybeE

type alias OngoingDrag = {position: PxPosition, elem: Service}
type alias ServiceInKubernetes = {position: PxPosition, service: Service}
type alias KubeServiceDimensions = {height: Float, width: Float}
type alias Model = {
    ongoingDrag: Maybe OngoingDrag,
    services: List ServiceInKubernetes,
    hover: Bool,
    dimensions: Element
 }

outOfView: Element
outOfView = {
   scene =  { width = -1, height =  -1},
   viewport = { x = -1, y = -1, width = -1, height = -1},
   element = { x = -1, y = -1, width = -1, height = -1}
  }

elementDimensions: String -> Cmd Event
elementDimensions id =
    Task.attempt
        (\result ->
            case result of
               Ok e -> ServiceAreaElement e
               Err event -> EventError("Could not find dimensions for element")
          )
        (getElement(id))


idName = "kubernetes-service-area"
className = "kubernetes-service-area"

init : (Model, Cmd Event)
init = (Model(Nothing)([])(False)(outOfView),elementDimensions(idName))

handleServiceArea: Element -> Model -> (Model, Cmd Event)
handleServiceArea element model = ({ model | dimensions = element}, Cmd.none)


handleDragStart: Service -> PxPosition -> Model -> (Model, Cmd Event)
handleDragStart service pxPosition model =
    ({model | ongoingDrag = Just(OngoingDrag(pxPosition)(service)), hover = False}, elementDimensions(idName))

handleDragStop: Model -> (Model, Cmd Event)
handleDragStop model =
    model.ongoingDrag
    |>
    MaybeE.filter
      (\drag -> isMouseHover(drag.position)(model.dimensions))
    |>
    Maybe.map
      (\drag ->
        ({model | services = (ServiceInKubernetes(relativePosition(drag.position)(model.dimensions))(drag.elem) :: model.services), ongoingDrag = Nothing}, Cmd.none)
      )
    |>
    Maybe.withDefault ({model | ongoingDrag = Nothing}, Cmd.none)

isMouseHover: PxPosition -> Element -> Bool
isMouseHover pxPosition model =
 let
    squareL = model.element.x - model.viewport.x
    squareR = squareL + model.element.width
    squareT = model.element.y - model.viewport.y
    squareB = squareT + model.element.height
    mouseInX    = pxPosition.x < squareR && pxPosition.x > squareL
    mouseInY    = pxPosition.y < squareB && pxPosition.y > squareT
 in
    mouseInY && mouseInX

handleMouseMove: PxPosition -> Model -> (Model, Cmd Event)
handleMouseMove pxPosition model =
    model.ongoingDrag
    |>
    Maybe.map
     (\drag -> ({model | hover = isMouseHover(pxPosition)(model.dimensions), ongoingDrag = Just({drag | position = pxPosition})}, Cmd.none))
    |> Maybe.withDefault (model, Cmd.none)



subscriptions: Model -> Sub Event
subscriptions model =
       model.ongoingDrag
       |>
       Maybe.map
        (\_ -> Sub.batch [onMouseMove decodeMousePosition, onMouseUp decodeMouseUp])
       |>
        Maybe.withDefault Sub.none

render: Model -> Html Event
render model = div[
    id idName,
    class className
    ](
        model.services
        |>
        List.map
            (\service -> div[
                class "kubernetes-service",
                style "transform" (toTranslateStr(service.position))
                ][KubernetesService.render(service.service)])
    )


