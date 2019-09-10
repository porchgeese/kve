module Pages.Kve.Page exposing (init,view,update,subscriptions, Model, Event, render)
import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Pages.Kve.ServiceTemplateContainer
import Pages.Kve.Model.KveModel exposing (ServiceTemplate)
import Pages.Kve.Event.KveEvents exposing (TemplateContainerEvents(..), KubAreaEvents(..),HttpEvents(..))
import Platform.Sub
import Pages.Kve.ServiceTemplateContainer
import Pages.Kve.KubernetesArea as KubernetesArea
import Pages.Kve.ServiceTemplateContainer as ServiceTemplateContainer
import Pages.Kve.Dragging as Dragging
import Pages.Kve.Http.Project as ProjectCalls
import Model.PxPosition as Position

type alias Model = {
    templateContainer: ServiceTemplateContainer.Model,
    kubernetesArea : KubernetesArea.Model,
        project: String

 }


type Event =
    TemplateContainer TemplateContainerEvents |
    KubernetesArea KubAreaEvents |
    HttpEvents HttpEvents

init : String -> (Model, Cmd Event)
init projectId = ({
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
    },
    project = projectId
 }, ProjectCalls.fetchProject(projectId) |> Cmd.map HttpEvents)

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
           (model, ProjectCalls.saveService(model.project)(service) |> Cmd.map HttpEvents)
       KubernetesArea (KaSelected service position) ->
           (model, KubernetesArea.startDrag(service)(position) |> Cmd.map KubernetesArea)
       KubernetesArea (KaStart service position elem) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withNewDrag(service)(position)(elem) }, Cmd.none)
       KubernetesArea (KaDragProgress service position element) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withMovedService service position element}, Cmd.none)
       KubernetesArea (KaDragStop service position elem ) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.dragStopped service position}, ProjectCalls.updateServicePosition(model.project)(service)(Position.relativePosition(position)(elem)) |> Cmd.map HttpEvents)
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
view: Model -> Browser.Document Event
view model = {
             title = "KVE",
             body = [render(model)]
            }

