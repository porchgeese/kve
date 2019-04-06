module Main exposing (main)
import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Modules.Kve.Event.KveEvents exposing (Events(..))
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Platform.Sub
import Debug
import Browser.Dom exposing (Element)
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.DraggableManager as DraggableManager
import Modules.Kve.ServiceTemplateContainer as ServiceTemplateContainer
import Modules.Kve.ServiceTemplate as ServiceTemplate
import Modules.Kve.ServicesArea as RunningServices

type alias Model = {
    templateContainer: ServiceTemplateContainer.Model,
    dragManager: DraggableManager.Model ServiceTemplate,
    serviceArea: RunningServices.Model
 }

init : () -> (Model, Cmd Events)
init _ =
    let (serviceArea, serviceAreaCmd) = RunningServices.init
        (dragManager, dragManagerCmd) = DraggableManager.init(ServiceTemplate.render)
    in (
    {
    templateContainer = {
        title = "Kve - Visual Editor",
        serviceTemplates = [
            {id = "1",name = "Service1"},
            {id = "2",name = "Service2"},
            {id = "3",name = "Service3"},
            {id = "4",name = "Service4"},
            {id = "5",name = "Service5"},
            {id = "6",name = "Service6"}
        ]
    },
    dragManager = dragManager,
    serviceArea = serviceArea
 }, Cmd.batch([serviceAreaCmd, dragManagerCmd]))

handleServiceSelected : Model -> PxPosition -> ServiceTemplate -> (Model, Cmd Events)
handleServiceSelected model position service =
    let
        (newDrag, dragSubs) = DraggableManager.dragStarted(model.dragManager)(service)(position)(service.id)
        (newServ, serSubs) = RunningServices.handleDragStart(position)(model.serviceArea)
        modelWNewDrag = {model | dragManager = newDrag}
        modelWNewServ = {modelWNewDrag | serviceArea = newServ}
    in (modelWNewServ, Cmd.batch [dragSubs, serSubs])

handleMouseMove:  Model -> PxPosition -> (Model, Cmd Events)
handleMouseMove model position =
    let
        (newDrag, dragSubs) = DraggableManager.handleMouseMove(position)(model.dragManager)
        (newServ, serSubs) = RunningServices.handleMouseMove(position)(model.serviceArea)
        modelWNewDrag = {model | dragManager = newDrag}
        modelWNewServ = {modelWNewDrag | serviceArea = newServ}
    in (modelWNewServ, Cmd.batch [dragSubs, serSubs])

handleMouseUp: Model -> (Model, Cmd Events)
handleMouseUp model  =
     let
       (newDrag, dragSubs) = DraggableManager.dragOver(model.dragManager)
       (newServ, serSubs) = RunningServices.handleDragStop(model.serviceArea)
       modelWNewDrag = {model | dragManager = newDrag}
       modelWNewServ = {modelWNewDrag | serviceArea = newServ}
     in (modelWNewServ, Cmd.batch [dragSubs, serSubs])

handleDimensions:  Model -> PxDimensions -> (Model, Cmd Events)
handleDimensions model dimensions =
    let (newModel, subs) = DraggableManager.handleDimensions(dimensions)(model.dragManager)
    in ({model | dragManager = newModel}, subs)

handleServiceAreaElement: Model -> Element -> (Model, Cmd Events)
handleServiceAreaElement model element =
    let (newServiceArea, cmd) = RunningServices.handleServiceArea(element)(model.serviceArea)
    in
        Debug.log(Debug.toString(element))
        ({model | serviceArea = newServiceArea },cmd)

update : Events -> Model -> (Model, Cmd Events)
update msg model =
       case msg of
           ServiceSelected service position ->
             handleServiceSelected model position service
           MouseMove position ->
             handleMouseMove model position
           SelectionDimensions dimensions ->
              handleDimensions model dimensions
           MouseUp ->
             handleMouseUp model
           ServiceAreaElement element ->
             handleServiceAreaElement model element
           EventError e ->
             Debug.log(e)
             (model, Cmd.none)

render: Model -> Html  Events
render model = div[class "kve"][
    ServiceTemplateContainer.render(model.templateContainer),
    RunningServices.render(model.serviceArea),
    DraggableManager.render(model.dragManager)
    ]

subscriptions: Model -> Sub Events
subscriptions model =
    Sub.batch[
        RunningServices.subscriptions(model.serviceArea),
        DraggableManager.subscriptions(model.dragManager)
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

