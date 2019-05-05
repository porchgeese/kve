module Modules.Kve.KubernetesArea exposing (..)
import Html exposing (Html,div)
import Html.Attributes exposing (class,id, style)
import Model.PxPosition as PxPosition
import Model.PxDimensions as PxDimensions
import Modules.Kve.Model.KveModel exposing (ServiceTemplate, NewService, RegisteredService)
import Browser.Dom exposing (Element)
import Browser.Dom exposing (getElement, Element)
import Task
import Html exposing (Html,div,img)
import Html.Attributes exposing (class, src, draggable)
import Html.Events exposing (stopPropagationOn)
import Json.Decode as Json exposing (..)
import Model.PxPosition exposing (PxPosition)
import Browser.Events exposing (onMouseMove,onMouseUp)
import Modules.Kve.Decoder.Mouse as Mouse
import Json.Decode as Decode



type alias Dragging = {
    service: RegisteredService,
    element: Element
 }
type alias Model = {
    services: List RegisteredService,
    drag: Maybe Dragging
 }

type Event =
    KaAdded NewService |
    KaReject ServiceTemplate |
    KaSelected RegisteredService PxPosition |
    KaStart RegisteredService PxPosition Element |
    KaDragProgress RegisteredService PxPosition Element |
    KaDragStop RegisteredService PxPosition Element |
    KubernetesError String

withService: RegisteredService -> Model -> Model
withService service model =
    {model | services = (service :: model.services)}

withServices: List RegisteredService -> Model -> Model
withServices newServices model =
    {model | services = (newServices ++ model.services)}

startDrag: RegisteredService -> PxPosition -> Cmd Event
startDrag registeredService pxPosition =
    getElement("kubernetes-service-area")
    |> Task.attempt  (\r ->
      r
      |> Result.toMaybe
      |> Maybe.map (\elem -> KaStart registeredService pxPosition elem)
      |> Maybe.withDefault (KubernetesError "Could not find element")
    )
dragStopped: RegisteredService -> PxPosition -> Model -> Model
dragStopped _ _ model =
    {model | drag = Nothing}




withUpdatedService: {old: RegisteredService, new: RegisteredService} -> Model -> Model
withUpdatedService update model =
    {model | services = Debug.log("New Service")(update.new) :: (model.services |> List.filter (\s -> s.id /= update.old.id))}

withMovedService: RegisteredService -> PxPosition -> Element -> Model -> Model
withMovedService registeredService pxPosition element model =
    let
      newService = {registeredService | position = PxPosition.relativePosition(pxPosition)(element)}
      withOutSer = model.services |> List.filter (\s -> s.id /= registeredService.id)
    in
      {model | services = newService :: withOutSer}


dropService: ServiceTemplate -> PxPosition.PxPosition -> PxDimensions.PxDimensions -> Cmd Event
dropService service pxPosition pxDimensions =
    getElement("kubernetes-service-area")
    |> Task.mapError (\_ -> "")
    |> Task.attempt (\r ->
        r
        |> Result.toMaybe
        |> Maybe.map (\elem ->
            (PxPosition.relativePosition(pxPosition)(elem), PxPosition.relativeBound(elem))
        )
        |> Maybe.map (\posAndBound ->
            let
                (position, bound) = posAndBound
                containsX = position.x > 0 && position.x < bound.x
                containsY = position.y > 0 && position.y < bound.y
            in (
             if (containsX && containsY) then
               KaAdded(NewService(service.id)(service.kind)(position)(pxDimensions))
             else
               KaReject service
             )
        )
        |> Maybe.withDefault (KubernetesError "Could not find element")
    )



subscriptions: Model -> Sub Event
subscriptions model =
    model.drag
        |> Maybe.map (\drag -> [
            onMouseMove (Mouse.decodeMouseMove |> Decode.map (\px -> KaDragProgress drag.service px drag.element)) ,
            onMouseUp (Mouse.decodeMouseUp |> Decode.map (\px -> KaDragStop drag.service px drag.element))
            ]
        )
        |> Maybe.withDefault []
        |> Sub.batch
-----
renderRegisteredService: RegisteredService -> Html Event
renderRegisteredService service = div[
    class  "kubernetes-service"
    ][img[
        src ("https://robohash.org/" ++ service.name ++ ".png"),
        stopPropagationOn "mousedown" (decodeServiceSelected(service)),
        draggable "false"
        ][]]


decodeServiceSelected: RegisteredService -> (Json.Decoder (Event, Bool))
decodeServiceSelected service =
    Json.map2
     (\x y -> (KaSelected(service)(PxPosition(x)(y)), True))
     (field "pageX" float)
     (field "pageY" float)

--------------------------------------------------------------------------------

update: Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
        KaSelected service position             -> (model, startDrag(service)(position))
        KaStart service _ elem                  -> ({model | drag = Just (Dragging(service)(elem))}, Cmd.none)
        KaDragProgress service position element -> (withMovedService(service)(position)(element)(model), Cmd.none)
        KaDragStop service position _           -> (dragStopped(service)(position)(model), Cmd.none)
        KaAdded _                               -> (model, Cmd.none)
        KaReject _                              -> (model, Cmd.none)
        KubernetesError _                       -> (model, Cmd.none)


render: Model -> Html event
render model = div[
    id "kubernetes-service-area",
    class "kubernetes-service-area"
    ]
     (model.services
        |> List.map (\service ->
            div[
                class "kubernetes-service-container",
                style "width" (service.dimensions.width |> PxDimensions.toPxlStr),
                style "height" (service.dimensions.height |> PxDimensions.toPxlStr),
                style "transform" ( service.position |>  PxPosition.centered(service.dimensions) |> PxPosition.toTranslateStr )
            ][renderRegisteredService(service)]
    )
    )






