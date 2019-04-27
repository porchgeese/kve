module Main exposing (main)
import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Modules.Kve.Event.KveEvents exposing (Event(..),TemplateContainerEvents(..), KubAreaEvents(..),HttpEvents(..))
import Platform.Sub
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.KubernetesArea as KubernetesArea
import Modules.Kve.ServiceTemplateContainer as ServiceTemplateContainer
import Modules.Kve.Dragging as Dragging
import Modules.Kve.Http.Project as ProjectCalls
import Model.PxPosition as Position

type alias Model = {
    templateContainer: ServiceTemplateContainer.Model,
    kubernetesArea : KubernetesArea.Model
 }

init : () -> (Model, Cmd Event)
init _ = ({
    templateContainer = {
        title = "Kve - Visual Editor",
        services = [
            ServiceTemplate("1")("Service1")(""),
            ServiceTemplate("2")("Service2")(""),
            ServiceTemplate("3")("Service3")(""),
            ServiceTemplate("4")("Service4")(""),
            ServiceTemplate("5")("Service5")(""),
            ServiceTemplate("6")("Service6")(""),
            ServiceTemplate("7")("Service7")(""),
            ServiceTemplate("8")("Service8")(""),
            ServiceTemplate("9")("Service9")(""),
            ServiceTemplate("10")("Service10")(""),
            ServiceTemplate("11")("Service11")(""),
            ServiceTemplate("12")("Service12")(""),
            ServiceTemplate("13")("Service13")(""),
            ServiceTemplate("14")("Service14")(""),
            ServiceTemplate("15")("Service15")("")
        ],
        drag = Dragging.Model(Nothing)
    },
    kubernetesArea = {
        services = [],
        drag = Nothing
    }

 }, ProjectCalls.fetchProject |> Cmd.map HttpEvents)

render: Model -> Html  Event
render model = div[class "kve"][
    ServiceTemplateContainer.render(TemplateContainer)(model.templateContainer),
    KubernetesArea.render(KubernetesArea)(model.kubernetesArea)
 ]

update: Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
       TemplateContainer (TcSelected service position) ->
        (model, ServiceTemplateContainer.getDimensions(position)(service) |> Cmd.map TemplateContainer)
       TemplateContainer (TcDragStart service position dimensions) ->
        ({model | templateContainer = (model.templateContainer |> ServiceTemplateContainer.withDrag service position dimensions)}, Cmd.none)
       TemplateContainer (TcDragProgress position) ->
        ({model | templateContainer = model.templateContainer |> ServiceTemplateContainer.withDragPosition position }, Cmd.none)
       TemplateContainer (TcDragStop position) ->
        (
         {model | templateContainer = (model.templateContainer |> ServiceTemplateContainer.withDragStopped) },
         model.templateContainer.drag.dragging
            |> Maybe.map (\drag -> KubernetesArea.dropService(drag.element)(position)(drag.dimensions))
            |> Maybe.withDefault Cmd.none
            |> Cmd.map KubernetesArea
        )
       KubernetesArea (KaAdd service) ->
           (model, ProjectCalls.saveService(service) |> Cmd.map HttpEvents)
       KubernetesArea (KaSelected service position) ->
           (model, KubernetesArea.startDrag(service)(position) |> Cmd.map KubernetesArea)
       KubernetesArea (KaStart service position elem) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withNewDrag(service)(position)(elem) }, Cmd.none)
       KubernetesArea (KaDragProgress service position element) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withMovedService service position element}, Cmd.none)
       KubernetesArea (KaDragStop service position elem ) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.dragStopped service position}, ProjectCalls.updateServicePosition(service)(Position.relativePosition(position)(elem)) |> Cmd.map HttpEvents)
       HttpEvents (ServiceCreated service) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withService(service)}, Cmd.none)
       HttpEvents (ProjectFetched project) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withServices(project.services)}, Cmd.none)
       HttpEvents (ServiceUpdated updateRes) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withUpdatedService(updateRes)}, Cmd.none)
       _ -> (model, Cmd.none)

subscriptions: Model -> Sub Event
subscriptions model =
    Sub.batch[
        ServiceTemplateContainer.subscriptions(TemplateContainer)(model.templateContainer),
        KubernetesArea.subscriptions(KubernetesArea)(model.kubernetesArea)
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

