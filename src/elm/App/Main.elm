module App.Main exposing (main)
import Browser
import Pages.Kve.Page as KvePage
import Url
import Browser.Navigation as Nav
import Pages.Login.Page as LoginPage
import Html exposing (Html)
import Platform.Sub
import Debug
import Maybe
import Browser.Navigation as Navigation
import Routes.Routes as Route
import Pages.NotFound.Page as NotFoundPage
import Pages.Loading.Page as LoadingPage
import Pages.Projects.Page as ProjectPage
import Task

type Event =
    KvePageEvent KvePage.Event |
    LoginPageEvent LoginPage.Event |
    ProjectsPageEvent ProjectPage.Event |
    Navigation Route.Route |
    None

type alias Model = {
    kve: Maybe KvePage.Model,
    projects: Maybe ProjectPage.Model,
    auth: Maybe (),
    key: Navigation.Key,
    route: Route.Route
 }

main = Browser.application ({
    init = init,
    view = render,
    update = update,
    subscriptions =  subscriptions ,
    onUrlRequest = (\x ->
        case x of
            Browser.Internal url-> (url |> Route.parseRoute |> Navigation)
            Browser.External _ -> None
    ),
    onUrlChange = (\url -> url |> Route.parseRoute |> Navigation)
 })

init : Int -> Url.Url -> Nav.Key -> (Model, Cmd Event)
init _ url key =
    (Model(Nothing)(Nothing)(Nothing)(key)(Route.Loading), Task.succeed(Navigation (Route.parseRoute(url))) |> Task.perform identity)

subscriptions: Model -> Sub Event
subscriptions model =
    model.kve
        |> Maybe.map ( \kveModel ->
            kveModel
            |> KvePage.subscriptions
            |> Sub.map (\e -> KvePageEvent e)
        )
        |> Maybe.withDefault Sub.none


update: Event -> Model -> (Model, Cmd Event)
update event model =
     case Debug.log ("Event")(event) of
        Navigation (Route.ProjectRoute project) ->
            KvePage.init (project)
                |> Tuple.mapFirst (\newKve -> {model | kve = Just newKve, route = Route.ProjectRoute project , auth = Just ()} )
                |> Tuple.mapSecond (Cmd.map KvePageEvent)
        Navigation Route.NotFound ->
             ({ model | route = Route.NotFound}, Cmd.none)
        Navigation Route.LoginRoute ->
           ({ model | route = Route.LoginRoute}, Cmd.none)
        Navigation Route.ProjectsRoute ->
            ProjectPage.init()
            |> Tuple.mapFirst (\newProjects -> {model | projects = Just(newProjects) , route = Route.ProjectsRoute})
            |> Tuple.mapSecond (Cmd.map ProjectsPageEvent)
        Navigation unknown ->
           ({model | route = unknown}, Cmd.none)
        LoginPageEvent LoginPage.LoginSuccessful ->
             (model, Navigation.pushUrl(model.key)("/projects"))
        ProjectsPageEvent (ProjectPage.ProjectSelected id) ->
             (model, Navigation.pushUrl(model.key)("/projects/" ++ id))
        ProjectsPageEvent projectEvent ->
            (model, projectEvent) |> delegate(\m -> m.projects)(ProjectPage.update)(\new -> {model | projects = new})(ProjectsPageEvent)
        KvePageEvent kveEvent ->
            (model, kveEvent) |> delegate(\m -> m.kve)(KvePage.update)(\new -> ({model | kve = new}))(KvePageEvent)
        None ->
            (model, Cmd.none)

render: Model -> Browser.Document Event
render model = {
    title = "Kve - Visual Editor",
    body = [
        case model.route of
            Route.LoginRoute -> renderLoginPage(model)
            Route.ProjectsRoute -> renderProjectsPage(model)
            Route.ProjectRoute _ -> renderProjectPage(model)
            Route.Loading -> renderLoadingPage(model)
            Route.NotFound -> renderNotFoundPage(model)
            Route.Home -> renderLoginPage(model)
         ]
 }

renderLoginPage: Model -> Html Event
renderLoginPage _ = LoginPage.render () |> Html.map (\e -> LoginPageEvent e)

renderProjectsPage: Model -> Html Event
renderProjectsPage model =
    model.projects
    |> Maybe.map ( \m -> ProjectPage.render m  |> Html.map ProjectsPageEvent )
    |> Maybe.withDefault LoadingPage.render

renderProjectPage: Model -> Html Event
renderProjectPage model =
    Maybe.map2
            (\_  kve -> KvePage.render(kve) |> Html.map (\e -> KvePageEvent e))
            (model.auth)
            (model.kve)
    |> Maybe.withDefault (renderLoadingPage(model))

renderNotFoundPage: Model -> Html Event
renderNotFoundPage _ =
    NotFoundPage.render

renderLoadingPage: Model -> Html Event
renderLoadingPage _ =
        LoadingPage.render

delegate: (Model -> Maybe model) -> (msg -> model -> (model, Cmd msg) ) -> (Maybe model -> Model) -> (msg -> Event) -> (Model, msg) -> (Model, Cmd Event)
delegate subModelGetter modelUpdate modelMapper eventMapper (model, event) =
    subModelGetter(model)
    |> Maybe.map ( \m ->
        m
        |> modelUpdate(event)
        |> Tuple.mapFirst Just
        |> Tuple.mapFirst modelMapper
        |> Tuple.mapSecond (Cmd.map eventMapper)
    )
    |> Maybe.withDefault (model, Cmd.none)




