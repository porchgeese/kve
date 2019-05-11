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
    Kve KvePage.Event |
    Login LoginPage.Event |
    Projects ProjectPage.Event |
    Show Route.Route |
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
            Browser.Internal url-> (url |> Route.parseRoute |> Show)
            Browser.External _ -> None
    ),
    onUrlChange = (\url -> url |> Route.parseRoute |> Show)
 })


subscriptions: Model -> Sub Event
subscriptions model =
    model.kve
        |> Maybe.map ( \kveModel ->
            kveModel
            |> KvePage.subscriptions
            |> Sub.map (\e -> Kve e)
        )
        |> Maybe.withDefault Sub.none


update: Event -> Model -> (Model, Cmd Event)
update event model =
     case Debug.log ("Event")(event) of
        Show (Route.ProjectRoute project) ->
            KvePage.init (project)
                |> Tuple.mapFirst (\newKve -> {model | kve = Just newKve, route = Route.ProjectRoute project , auth = Just ()} )
                |> Tuple.mapSecond (Cmd.map Kve)
        Show Route.NotFound ->
             ({ model | route = Route.NotFound}, Cmd.none)
        Show Route.LoginRoute ->
           ({ model | route = Route.LoginRoute}, Cmd.none)
        Show Route.ProjectsRoute ->
            ProjectPage.init()
            |> Tuple.mapFirst (\newProjects -> {model | projects = Just(newProjects) , route = Route.ProjectsRoute})
            |> Tuple.mapSecond (Cmd.map Projects)
        Show a ->
           (model, Cmd.none)
        Kve kveEvent ->
            model.kve
                |> Maybe.map (\kveModel ->
                    kveModel
                        |> KvePage.update(kveEvent)
                        |> Tuple.mapFirst (\newModel -> ({model | kve = Just newModel}))
                        |> Tuple.mapSecond (Cmd.map Kve )
                )
                |> Maybe.withDefault (model, Cmd.none )
        Login LoginPage.LoginSuccessful ->
             (model, Navigation.pushUrl(model.key)("/projects"))
        Projects (ProjectPage.ProjectSelected id) ->
             (model, Navigation.pushUrl(model.key)("/projects/" ++ id)) --fix
        Projects projectEvent ->
              model.projects
              |> Maybe.map (\projects ->
                ProjectPage.update(projectEvent)(projects)
                |> Tuple.mapFirst(\newModel -> {model | projects = Just newModel})
                |> Tuple.mapSecond(Cmd.map Projects)
              )
              |> Maybe.withDefault (model, Cmd.none)
        None ->
            (model, Cmd.none)


init : Int -> Url.Url -> Nav.Key -> (Model, Cmd Event)
init _ url key =
    (Model(Nothing)(Nothing)(Nothing)(key)(Route.Loading), Task.succeed(Show (Route.parseRoute(url))) |> Task.perform identity)



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
renderLoginPage model = LoginPage.render () |> Html.map (\e -> Login e)

renderProjectsPage: Model -> Html Event
renderProjectsPage model =
    model.projects
    |> Maybe.map ( \m -> ProjectPage.render m  |> Html.map Projects )
    |> Maybe.withDefault LoadingPage.render

renderProjectPage: Model -> Html Event
renderProjectPage model =
    Maybe.map2
            (\_  kve -> KvePage.render(kve) |> Html.map (\e -> Kve e))
            (model.auth)
            (model.kve)
    |> Maybe.withDefault (renderLoadingPage(model))

renderNotFoundPage: Model -> Html Event
renderNotFoundPage model =
    NotFoundPage.render

renderLoadingPage: Model -> Html Event
renderLoadingPage model =
        LoadingPage.render





