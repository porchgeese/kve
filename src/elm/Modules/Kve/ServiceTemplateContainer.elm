module Modules.Kve.ServiceTemplateContainer exposing (render,ServiceTemplateContainer, ServiceContainer)
import Elements.Title as Title
import Html exposing (Html,div)
import Html.Attributes exposing (class)
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Modules.Kve.Event.KveEvents exposing (Events)
import Modules.Kve.ServiceTemplate as ST


type alias ServiceTemplateContainer = {
                            title : String,
                            services: List Events
                        }

type alias ServiceContainer = {
        title: String,
        serviceTemplates: List ServiceTemplate
    }
render : ServiceContainer  -> Html Events
render model = div
    [
        class "service-template-container"
    ](Title.view({title = model.title}) :: (List.map ST.render model.serviceTemplates))