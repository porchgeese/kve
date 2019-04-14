module Modules.Kve.ServiceTemplateContainer exposing (
    render,Model,subscriptions,
    withDragPosition, withDragStopped,
    withDrag,
    getDimensions
 )
import Elements.Title as Title
import Html exposing (Html,div)
import Html.Attributes exposing (class)
import Modules.Kve.Model.KveModel exposing (Service)
import Modules.Kve.Event.KveEvents exposing (Event)
import Html exposing (Html,div,img)
import Html.Events exposing (stopPropagationOn)
import Html.Attributes exposing (class, id,src, draggable)
import Json.Decode as Json exposing (..)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Model.PxDimensions as PxDimensions
import Modules.Kve.Event.KveEvents exposing (TemplateContainerEvents(..), Event(..))
import Modules.Kve.Model.KveModel exposing (Service)
import Modules.Kve.Dragging as Dragging
import Modules.Kve.Decoder.Mouse as Mouse
import Browser.Dom exposing (getElement)
import Task

type alias Model = {
        title: String,
        services: List Service,
        drag: Dragging.Model Service
 }

withDragPosition : PxPosition -> Model   -> Model
withDragPosition pxPosition model  =
    model.drag.dragging
    |> Maybe.map (\d -> {d | mouse = pxPosition})
    |> Maybe.map (\newDrag -> {model | drag = Dragging.Model(Just newDrag)})
    |> Maybe.withDefault model

withDrag: Service -> PxPosition -> PxDimensions -> Model -> Model
withDrag service pxPosition pxDimensions model =
    {model | drag = Dragging.Model(Just(Dragging.DragInProgress(service)(pxPosition)(pxDimensions)))}

withDragStopped : Model -> Model
withDragStopped model =
    {model | drag = Dragging.Model(Nothing)}

getDimensions: PxPosition -> Service -> Cmd TemplateContainerEvents
getDimensions position service =
    getElement(service.id)
    |> Task.attempt (\r ->
        r
            |> Result.toMaybe
            |> Maybe.map PxDimensions.fromElement
            |> Maybe.map (DragStart(service)(position))
            |> Maybe.withDefault (Error("Could not find service"))
    )

subscriptions: Model -> Sub Event
subscriptions model =
    Dragging.subscriptions(subscriptionMapper)(model.drag)


render : (TemplateContainerEvents -> event) -> Model  -> Html event
render mapper model =
    div[class "service-template-container"][
        div [class "service-template-container-title"][Title.view({title = model.title}) ],
        div [class "service-template-container-items"](
            List.map renderServiceTemplate model.services
        ),
        div [class "service-template-container-drag"][
            Dragging.render(renderServiceTemplate)(model.drag)
        ]
    ]
    |> Html.map mapper

-----

decodeServiceSelected: Service -> (Json.Decoder (TemplateContainerEvents, Bool))
decodeServiceSelected service =
    Json.map2
     (\x y -> (Selected(service)(PxPosition(x)(y)), True))
     (field "pageX" float)
     (field "pageY" float)

renderServiceTemplate: Service -> Html TemplateContainerEvents
renderServiceTemplate service = div[
    stopPropagationOn "mousedown" (decodeServiceSelected(service)),
    class  "service-template",
    id (service.id)
    ][img[
        src ("https://api.adorable.io/avatars/75/" ++ service.name),
        draggable "false"
        ][]]

subscriptionMapper: Mouse.Event -> Event
subscriptionMapper dragEvents =
    case dragEvents of
        Mouse.MouseMove pxPosition -> TemplateContainer (DragProgress pxPosition)
        Mouse.MouseUp pxPosition -> TemplateContainer (DragStop pxPosition)
