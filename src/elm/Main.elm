module Main exposing (main)
import Browser
import Html exposing (Html, div)
import Modules.Kve.ServiceTemplateContainer as TemplateContainer
import Modules.Kve.ServiceTemplate as ST
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Modules.Kve.Event.KveEvents exposing (Events(..))
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Model.PxDimensions as Dim
import Platform.Sub
import Browser.Dom exposing (getElement, Element)
import Task
import Result
import Modules.Kve.DraggableManager as DM
import Maybe.Extra exposing (toList)
import Browser.Events exposing (onMouseMove,onMouseUp)
import Json.Decode as Decode
import Browser.Dom exposing (Error)
import Browser.Dom exposing (Error)
import Debug
type alias Model = {
    sideBar: {
        title: String,
        serviceTemplates: List ServiceTemplate
    },
        selection : Maybe Events
 }

init : () -> (Model, Cmd Events)
init _ = ({
        sideBar = {
            title = "KVE - Kube Visual Editor",
            serviceTemplates =[
                {id = "1",name = "Service1"},
                {id = "2",name = "Service2"},
                {id = "3",name = "Service3"},
                {id = "4",name = "Service4"},
                {id = "5",name = "Service5"},
                {id = "6",name = "Service6"}
            ]
        } ,
        selection = Nothing
        },
        Cmd.none
 )

handleServiceSelected: ({service : ServiceTemplate, position : PxPosition}) -> (Result Error Element) -> Events
handleServiceSelected details result =
       case result of
           Ok elem -> ServiceSelectedAndDim {service = details.service, position = details.position, element = elem}
           Err _ -> EventError {description = "Failed to fetch element."}




update : Events -> Model -> (Model, Cmd Events)
update msg model =
       case msg of
           ServiceSelected details ->
            (model, Task.attempt(handleServiceSelected(details))(getElement(details.service.id)))
           ServiceSelectedAndDim details ->
            ({model | selection = Just (ServiceSelectedAndDim {service = details.service, position = details.position, element = details.element}) }, Cmd.none)
           MouseMove position ->
            ({model | selection = (getNewSelection model.selection position.position)}, Cmd.none)
           MouseUp ->
             ({model | selection = Nothing}, Cmd.none)
           EventError e ->
             Debug.log(e.description)
             (model, Cmd.none)



renderDrag: Events -> Maybe (Html Events)
renderDrag model =
   case model of
       ServiceSelectedAndDim details ->
         let de = DM.DraggableElement(ST.render)(details.service)(details.position)(Dim.fromElement(details.element))
         in Just(DM.render(de))
       _ ->
         Nothing



render: Model -> Html  Events
render model = div[](TemplateContainer.render(model.sideBar) :: (Maybe.andThen renderDrag model.selection |> toList))

getNewSelection: Maybe Events -> PxPosition  -> Maybe Events
getNewSelection model position =
       case model of
           Just(ServiceSelectedAndDim details) ->
            Just (ServiceSelectedAndDim {details | position = position})
           _ ->
            Nothing


decodeMousePosition: Decode.Decoder Events
decodeMousePosition =
    Decode.map2
      (\x y -> MouseMove {position = PxPosition(x)(y)})
      (Decode.field "clientX" Decode.float)
      (Decode.field "clientY" Decode.float)

decodeMouseUp: Decode.Decoder Events
decodeMouseUp =
    Decode.succeed MouseUp



subscriptions: Model -> Sub Events
subscriptions _ = Sub.batch [
        (onMouseMove decodeMousePosition),
        (onMouseUp decodeMouseUp)
    ]

main = Browser.document {
    init = init,
    view = \model -> {
     title = "KVE",
     body = [render(model)]
    },
    update = update,
    subscriptions = subscriptions
  }

