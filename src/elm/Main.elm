module Main exposing (main)
import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.Model.KveModel exposing (Service)
import Modules.Kve.Event.KveEvents exposing (Event(..),TemplateContainerEvents(..))
import Platform.Sub
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.ServiceTemplateContainer as ServiceTemplateContainer
import Modules.Kve.Dragging as Dragging
type alias Model = {
    templateContainer: ServiceTemplateContainer.Model
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
            Service("6")("Service7"),
            Service("6")("Service8"),
            Service("6")("Service9"),
            Service("6")("Service10"),
            Service("6")("Service11"),
            Service("6")("Service12"),
            Service("6")("Service13"),
            Service("6")("Service14"),
            Service("6")("Service15")
        ],
        drag = Dragging.Model(Nothing)
    }
 }, Cmd.none)

render: Model -> Html  Event
render model = div[class "kve"][
    ServiceTemplateContainer.render(TemplateContainer)(model.templateContainer)
 ]

update: Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
       TemplateContainer (Selected service position) ->
        (model, ServiceTemplateContainer.getDimensions(position)(service) |> Cmd.map TemplateContainer)
       TemplateContainer (DragStart service position dimensions) ->
        ({model | templateContainer = (model.templateContainer |> ServiceTemplateContainer.withDrag service position dimensions)}, Cmd.none)
       TemplateContainer (DragProgress position) ->
        ({model | templateContainer = model.templateContainer |> ServiceTemplateContainer.withDragPosition position }, Cmd.none)
       TemplateContainer (DragStop position) ->
        ({model | templateContainer = (model.templateContainer |> ServiceTemplateContainer.withDragStopped) }, Cmd.none)
       _ -> (model, Cmd.none)


subscriptions: Model -> Sub Event
subscriptions model =
    Sub.batch[
        ServiceTemplateContainer.subscriptions(model.templateContainer)
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

