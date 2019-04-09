module Modules.Kve.ServiceTemplateContainer exposing (
    Model, subscriptions, render, InternalEvents, Events,update
 )
import Elements.Title as Title
import Html exposing (Html,div)
import Html.Attributes exposing (class)
import Modules.Kve.Model.KveModel exposing (Service)
import Modules.Kve.ServiceTemplate as ServiceTemplate
import Modules.Kve.DragManager as DragManager
import Model.PxPosition exposing (PxPosition,AbsolutePosition)


type alias Model = {
        title: String,
        services: List Service,
        drag: DragManager.Model Service
    }
type alias InternalEvents = DragManager.InternalEvents

type Events =
    DragginService PxPosition Service |
    DraggingStopped PxPosition Service |
    None

dragManagerMapper: DragManager.Events -> Events
dragManagerMapper events = None

serviceTemplateMapper: ServiceTemplate.Events -> Events
serviceTemplateMapper events = None


update: (Events -> event) -> Model -> InternalEvents -> (Model, Cmd event)
update eventMap model iEvent =
    DragManager.update(dragManagerMapper)(model.drag)(iEvent)
    |>
    Tuple.mapBoth
     (\dragM -> {model | drag = dragM})
     (Cmd.map(eventMap))

subscriptions: Model -> Sub InternalEvents
subscriptions model =
    DragManager.subscriptions(model.drag)

renderServiceTemplate: Service -> Html Events
renderServiceTemplate model =
    ServiceTemplate.render(model)
    |>
    Html.map
    serviceTemplateMapper


render : Model  -> Html Events
render model = div[class "service-template-container"][
        div [class "service-template-container-title"][Title.view({title = model.title})],
        div [class "service-template-container-items"](
            model.services |>
            List.map
            renderServiceTemplate
        ),
        DragManager.render(model.drag)(renderServiceTemplate)
    ]
