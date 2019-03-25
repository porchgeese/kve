module Elements.Kve.ServiceTemplateContainer exposing (render,ServiceTemplateContainer,ServiceTemplate,ContainerEvent(..))
import Elements.Html.Title as Title
import Html exposing (Html,div,text)
import Html.Events exposing (onClick)
import Html.Styled.Attributes exposing (css)
import Css exposing (..)

type ContainerEvent = Selected ServiceTemplate
type alias ServiceTemplate = {name: String}
type alias ServiceContainer = {
        title: String,
        serviceTemplates: List ServiceTemplate
    }
type alias ServiceTemplateContainer = {
                            title : String,
                            services: List ServiceTemplate
                        }


serviceTemplateRender: ServiceTemplate -> Html ContainerEvent
serviceTemplateRender service = div[onClick (Selected service)][text(service.name)]

render : ServiceContainer  -> Html ContainerEvent
render model = div
    [] (Title.view({title = model.title}) :: (List.map serviceTemplateRender model.serviceTemplates))