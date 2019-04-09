module Main exposing (main)
import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.Model.KveModel exposing (Service)
import Platform.Sub
import Modules.Kve.ServiceTemplateContainer
import Modules.Kve.DragManager as DragManager
import Modules.Kve.ServiceTemplateContainer as ServiceTemplateContainer
import Modules.Kve.DragManager
import Tuple
type alias Model = {
    templateContainer: ServiceTemplateContainer.Model
 }

type Events = None |
    ServiceTemplateContainerEvents ServiceTemplateContainer.InternalEvents

init : () -> (Model, Cmd Events)
init _ =  ({
    templateContainer = {
        title = "Kve - Visual Editor",
        services = [
            {id = "1",name = "Service1"},
            {id = "2",name = "Service2"},
            {id = "3",name = "Service3"},
            {id = "4",name = "Service4"},
            {id = "5",name = "Service5"},
            {id = "6",name = "Service6"},
            {id = "6",name = "Service7"},
            {id = "6",name = "Service8"},
            {id = "6",name = "Service9"},
            {id = "6",name = "Service10"},
            {id = "6",name = "Service11"},
            {id = "6",name = "Service12"},
            {id = "6",name = "Service13"},
            {id = "6",name = "Service14"},
            {id = "6",name = "Service15"}
        ],
        drag = DragManager.Model(Nothing)(Nothing)(Nothing)
    }
 }, Cmd.none)


serviceTemplateContainerMapper: ServiceTemplateContainer.Events -> Events
serviceTemplateContainerMapper events = None


update : Events -> Model -> (Model, Cmd Events)
update msg model =
       case msg of
           ServiceTemplateContainerEvents internal ->
               ServiceTemplateContainer.update(serviceTemplateContainerMapper)(model.templateContainer)(internal)
               |>
               Tuple.mapFirst
               (\templateContainerM -> {model | templateContainer = templateContainerM})
           None ->
               (model, Cmd.none)

render: Model -> Html  Events
render model = div[class "kve"][
    (
        ServiceTemplateContainer.render(model.templateContainer)
        |>
        Html.map
        (\_ -> None)
    )
    ]


subscriptions: Model -> Sub Events
subscriptions model =
    ServiceTemplateContainer.subscriptions(model.templateContainer) |> Sub.map ServiceTemplateContainerEvents

main = Browser.document {
    init = init,
    view = \model -> {
     title = "KVE",
     body = [render(model)]
    },
    update = update,
    subscriptions = subscriptions
  }

