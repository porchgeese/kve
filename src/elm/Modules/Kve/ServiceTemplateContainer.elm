module Modules.Kve.ServiceTemplateContainer exposing (render,Model)
import Elements.Title as Title
import Html exposing (Html,div)
import Html.Attributes exposing (class)
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Modules.Kve.Event.KveEvents exposing (Events)
import Modules.Kve.ServiceTemplate as ST


type alias Model = {
        title: String,
        serviceTemplates: List ServiceTemplate
    }
render : Model  -> Html Events
render model = div[class "service-template-container"][
        div [class "service-template-container-title"][Title.view({title = model.title}) ],
        div [class "service-template-container-items"](List.map ST.render model.serviceTemplates)
    ]
