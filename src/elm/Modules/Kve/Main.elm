module Modules.Kve.Main exposing (init,view,update,subscriptions)
import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Modules.Kve.Event.KveEvents exposing (Event(..), HttpEvents(..))
import Platform.Sub
import Modules.Kve.KubernetesArea as KubernetesArea
import Modules.Kve.ServiceTemplate.ServiceTemplateContainer as ServiceTemplateContainer
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
        dragging = Nothing
    },
    kubernetesArea = {
        services = [],
        drag = Nothing
    }

 }, ProjectCalls.fetchProject |> Cmd.map HttpEvents)

render: Model -> Html  Event
render model = div[class "kve"][
    ServiceTemplateContainer.render(model.templateContainer) |> Html.map TemplateContainer,
    KubernetesArea.render(KubernetesArea)(model.kubernetesArea)
 ]

update: Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
       TemplateContainer (ServiceTemplateContainer.DragEnd pos dim elem) ->
         let (serviceTemplate, cmds) = ServiceTemplateContainer.update(model.templateContainer)
         ({model | templateContainer = serviceTemplate}, Cmd.batch [
            cmds |> Cmd.map TemplateContainer,
            KubernetesArea.dropService(elem)(pos)(dim) |> Cmd.map KubernetesArea
         ])
       TemplateContainer event ->
         let (serviceTemplate, cmds) = ServiceTemplateContainer.update event model.templateContainer
         ({model | templateContainer = serviceTemplate}, cmds |> Cmd.map TemplateContainer)
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
        ServiceTemplateContainer.subscriptions(model.templateContainer) |> Sub.map TemplateContainer,
        KubernetesArea.subscriptions(KubernetesArea)(model.kubernetesArea)
    ]
view: Model -> Browser.Document Event
view model = {
             title = "KVE",
             body = [render(model)]
            }
main = Browser.document {
    init = init,
    view = view ,
    update = update,
    subscriptions = subscriptions
  }

