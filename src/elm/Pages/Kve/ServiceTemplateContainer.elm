module Pages.Kve.ServiceTemplateContainer exposing (
    render,Model,subscriptions,
    withDragPosition, withDragStopped,
    withDrag,
    getDimensions
 )
import Elements.Title as Title
import Html exposing (Html,div)
import Html.Attributes exposing (class)
import Pages.Kve.Model.KveModel exposing (ServiceTemplate)
import Html exposing (Html,div,img)
import Html.Events exposing (stopPropagationOn)
import Html.Attributes exposing (class, id,src, draggable)
import Json.Decode as Json exposing (..)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Model.PxDimensions as PxDimensions
import Pages.Kve.Event.KveEvents exposing (TemplateContainerEvents(..))
import Pages.Kve.Model.KveModel exposing (ServiceTemplate)
import Pages.Kve.Dragging as Dragging
import Pages.Kve.Decoder.Mouse as Mouse
import Browser.Dom exposing (getElement)
import Task

type alias Model = {
        title: String,
        services: List ServiceTemplate,
        drag: Dragging.Model ServiceTemplate
 }

withDragPosition : PxPosition -> Model   -> Model
withDragPosition pxPosition model  =
    model.drag.dragging
    |> Maybe.map (\d -> {d | mouse = pxPosition})
    |> Maybe.map (\newDrag -> {model | drag = Dragging.Model(Just newDrag)})
    |> Maybe.withDefault model

withDrag: ServiceTemplate -> PxPosition -> PxDimensions -> Model -> Model
withDrag service pxPosition pxDimensions model =
    {model | drag = Dragging.Model(Just(Dragging.DragInProgress(service)(pxPosition)(pxDimensions)))}

withDragStopped : Model -> Model
withDragStopped model =
    {model | drag = Dragging.Model(Nothing)}

getDimensions: PxPosition -> ServiceTemplate -> Cmd TemplateContainerEvents
getDimensions position service =
    getElement(service.id)
    |> Task.attempt (\r ->
        r
            |> Result.toMaybe
            |> Maybe.map PxDimensions.fromElement
            |> Maybe.map (TcDragStart(service)(position))
            |> Maybe.withDefault (TemplateContainerError("Could not find service"))
    )

subscriptions: (TemplateContainerEvents -> event) -> Model -> Sub event
subscriptions mappings model =
    Dragging.subscriptions(subscriptionMapper)(model.drag)
    |> Sub.map mappings


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

decodeServiceSelected: ServiceTemplate -> (Json.Decoder (TemplateContainerEvents, Bool))
decodeServiceSelected service =
    Json.map2
     (\x y -> (TcSelected(service)(PxPosition(x)(y)), True))
     (field "pageX" float)
     (field "pageY" float)

renderServiceTemplate: ServiceTemplate -> Html TemplateContainerEvents
renderServiceTemplate service = div[
    stopPropagationOn "mousedown" (decodeServiceSelected(service)),
    class  "service-template",
    id (service.id)
    ][img[
        src ("https://robohash.org/" ++ service.id ++ ".png"),
        draggable "false"
        ][]]

subscriptionMapper: Mouse.Event -> TemplateContainerEvents
subscriptionMapper dragEvents =
    case dragEvents of
        Mouse.MouseMove pxPosition -> (TcDragProgress pxPosition)
        Mouse.MouseUp pxPosition -> (TcDragStop pxPosition)
