module Main exposing (main)
import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.Model.KveModel exposing (Service)
import Modules.Kve.Event.KveEvents exposing (Event(..),TemplateContainerEvents(..), KubAreaEvents(..))
import Platform.Sub
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.KubernetesArea as KubernetesArea
import Modules.Kve.ServiceTemplateContainer as ServiceTemplateContainer
import Modules.Kve.Dragging as Dragging
type alias Model = {
    templateContainer: ServiceTemplateContainer.Model,
    kubernetesArea : KubernetesArea.Model
 }

init : () -> (Model, Cmd Event)
init _ = ({
    templateContainer = {
        title = "Kve - Visual Editor",
        services = [
            Service("1")("Service1"),
            Service("2")("Service2"),
            Service("3")("Service3"),
            Service("4")("Service4"),
            Service("5")("Service5"),
            Service("6")("Service6"),
            Service("7")("Service7"),
            Service("8")("Service8"),
            Service("9")("Service9"),
            Service("10")("Service10"),
            Service("11")("Service11"),
            Service("12")("Service12"),
            Service("13")("Service13"),
            Service("14")("Service14"),
            Service("15")("Service15")
        ],
        drag = Dragging.Model(Nothing)
    },
    kubernetesArea = {
        services = [],
        drag = Nothing
    }

 }, Cmd.none)

render: Model -> Html  Event
render model = div[class "kve"][
    ServiceTemplateContainer.render(TemplateContainer)(model.templateContainer),
    KubernetesArea.render(KubernetesArea)(model.kubernetesArea)
 ]

update: Event -> Model -> (Model, Cmd Event)
update event model =
    Debug.log("Event:" ++ Debug.toString(event))(
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
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withService(service)}, Cmd.none)
       KubernetesArea (KaSelected service position) ->
           (model, KubernetesArea.startDrag(service)(position) |> Cmd.map KubernetesArea)
       KubernetesArea (KaStart service position elem) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withNewDrag(service)(position)(elem) }, Cmd.none)
       KubernetesArea (KaDragProgress service position element) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.withMovedService service position element}, Cmd.none)
       KubernetesArea (KaDragStop service position _ ) ->
           ({model | kubernetesArea = model.kubernetesArea |> KubernetesArea.dragStopped service position}, Cmd.none)
       _ -> (model, Cmd.none)
    )

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

