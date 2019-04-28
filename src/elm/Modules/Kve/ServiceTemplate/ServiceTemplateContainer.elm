module Modules.Kve.ServiceTemplate.ServiceTemplateContainer exposing (
    render,update,subscriptions,TemplateContainerEvent,TemplateContainerEvent(..),
    Model
 )
import Elements.Title as Title
import Html exposing (Html,div)
import Html.Attributes exposing (class)
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Html exposing (Html,div,img)
import Html.Events exposing (stopPropagationOn)
import Html.Attributes exposing (class, id,src, draggable)
import Json.Decode as Json exposing (..)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Model.PxDimensions as PxDimensions
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Modules.Kve.Decoder.Mouse as Mouse
import Browser.Dom exposing (getElement)
import Task
import Html exposing (Html,div)
import Html.Attributes exposing (style,class)
import Model.PxDimensions exposing (PxDimensions,toPxlStr)
import Model.PxPosition exposing (PxPosition,toTranslateStr,centered)
import Browser.Events exposing (onMouseMove,onMouseUp)
import Json.Decode as Decode

type alias DragInProgress = {element: ServiceTemplate, mouse: PxPosition, dimensions: PxDimensions}
type alias Model = {
        title: String,
        services: List ServiceTemplate,
        dragging: Maybe DragInProgress
 }
type Progress = Moved | MouseUp
type TemplateContainerEvent =
    Selected ServiceTemplate PxPosition |
    DragStart ServiceTemplate PxPosition PxDimensions  |
    DragProgress Progress PxPosition |
    DragEnd PxPosition PxDimensions ServiceTemplate |
    TemplateContainerError String

withDragPosition : PxPosition -> Model   -> Model
withDragPosition pxPosition model  =
    model.dragging
    |> Maybe.map (\d -> {d | mouse = pxPosition})
    |> Maybe.map (\newDrag -> {model | dragging = Just newDrag})
    |> Maybe.withDefault model

withDrag: ServiceTemplate -> PxPosition -> PxDimensions -> Model -> Model
withDrag service pxPosition pxDimensions model =
    {model | dragging = Just(DragInProgress(service)(pxPosition)(pxDimensions))}

withDragStopped : Model -> Model
withDragStopped model =
    {model | dragging = Nothing}


toCmd : TemplateContainerEvent -> Cmd TemplateContainerEvent
toCmd templateContainerEvent =
    Task.succeed templateContainerEvent |> Task.perform identity

-----

obtainElementDimensions: PxPosition -> ServiceTemplate -> Cmd TemplateContainerEvent
obtainElementDimensions position service =
    getElement(service.id)
    |> Task.attempt (\r ->
        r
            |> Result.toMaybe
            |> Maybe.map PxDimensions.fromElement
            |> Maybe.map (DragStart(service)(position))
            |> Maybe.withDefault (TemplateContainerError("Could not find service"))
    )

decodeServiceSelected: ServiceTemplate -> (Json.Decoder (TemplateContainerEvent, Bool))
decodeServiceSelected service =
    Json.map2
     (\x y -> (Selected(service)(PxPosition(x)(y)), True))
     (field "pageX" float)
     (field "pageY" float)

subscriptions: Model -> Sub TemplateContainerEvent
subscriptions model =
    model.dragging
        |> Maybe.map (\_ -> [
            onMouseMove (Mouse.decodeMouseMove |> Decode.map (\p -> DragProgress Moved p)),
            onMouseUp (Mouse.decodeMouseUp |> Decode.map (\p -> DragProgress MouseUp p))
          ]
        )
        |> Maybe.withDefault []
        |> Sub.batch


update: TemplateContainerEvent -> Model -> (Model, Cmd TemplateContainerEvent)
update event model =
       case event of
        Selected service position             ->
          (model, obtainElementDimensions(position)(service))
        DragStart service position dimensions ->
          (model |> (withDrag service position dimensions), Cmd.none)
        DragProgress Moved position           ->
          (model |> withDragPosition position , Cmd.none)
        DragProgress MouseUp position         ->
          (model |> withDragPosition position , model.dragging |> Maybe.map (\d -> DragEnd position d.dimensions d.element |> toCmd) |> Maybe.withDefault Cmd.none)
        DragEnd _ _ _                          ->
          (model |> withDragStopped, Cmd.none)
        TemplateContainerError error          ->
          Debug.log("Error")((model |> withDragStopped ,Cmd.none))

renderServiceTemplate: ServiceTemplate -> Html TemplateContainerEvent
renderServiceTemplate service = div[
    stopPropagationOn "mousedown" (decodeServiceSelected(service)),
    class  "service-template",
    id (service.id)
    ][img[
        src ("https://robohash.org/" ++ service.id ++ ".png"),
        draggable "false"
        ][]]

render : Model  -> Html event
render  model =
    div[class "service-template-container"][
        div [class "service-template-container-title"][Title.view({title = model.title}) ],
        div [class "service-template-container-items"](
            List.map renderServiceTemplate model.services
        ),
        div [class "service-template-container-drag"][
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
                            ][div[][renderServiceTemplate(drag.element)]]
                  )
                |> Maybe.withDefault (div[class "dragging-manager-off"][])
        ]

    ]
