import Browser
import Html exposing (Html, div,text)
import Elements.Kve.ServiceTemplateContainer as ServTemplateContainer


type alias Model = {
    sideBar: {
        title: String,
        serviceTemplates: List ServTemplateContainer.ServiceTemplate
    },
    selectedService: Maybe ServTemplateContainer.ServiceTemplate
    }

init : Model
init = {
        sideBar = {
            title = "KVE - Kube Visual Editor",
            serviceTemplates =[
                {name = "Service1"},
                {name = "Service2"}
            ]
        } ,
        selectedService = Nothing
        }

update : ServTemplateContainer.ContainerEvent -> Model -> Model
update event model = case event of
        ServTemplateContainer.Selected service -> {model | selectedService = Just service }


view: Model -> Html ServTemplateContainer.ContainerEvent
view model = div[][ServTemplateContainer.render(model.sideBar), text(Maybe.map .name model.selectedService |> Maybe.withDefault "-")]

main = Browser.sandbox {init = init,update = update,view = view}
