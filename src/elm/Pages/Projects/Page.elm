module Pages.Projects.Page exposing (Model, Event(..), render, init, update)

import Html exposing (Html)
import Html exposing (div,img, ul,li, text,span,i,Html, button, input)
import Html.Attributes exposing (id, class)
import Html.Events exposing (onClick, stopPropagationOn, onInput)
import Http as Http
import Json.Encode as Encode
import Json.Decode as Decode


type alias Project = {
    id: String,
    name: String,
    created: String --no need to make this a timestamp for now
 }

type alias Model = {
    projects: Maybe (List Project),
    projectCreationModal: Maybe (),
    projectCreationModalInputContents: String
 }


type Event =
    ProjectSelected String |
    ObtainedProjects (List Project) |
    OpenNewProjectModal |
    AddNewProject |
    NewProjectCreated |
    ProjectNameInput String|
    CloseModal |
    Ignore |
    UnexpectedError

init : () -> (Model, Cmd Event)
init () =  (Model(Nothing)(Nothing)(""), fetchProjects)


update: Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
        ObtainedProjects projects ->
            ({model | projects = Just projects}, Cmd.none)
        OpenNewProjectModal ->
            ({model | projectCreationModal = Just ()}, Cmd.none)
        AddNewProject ->
            (model, createNewProject model.projectCreationModalInputContents)
        NewProjectCreated ->
            ({model | projectCreationModal = Nothing}, fetchProjects)
        CloseModal ->
            ({model | projectCreationModal = Nothing}, Cmd.none)
        ProjectNameInput content ->
            ({model | projectCreationModalInputContents = content}, Cmd.none)
        _ ->
            (model, Cmd.none)


fetchProjects: Cmd Event
fetchProjects = Http.get {
    url = "http://127.0.0.1:8089/projects",
    expect =  Http.expectJson(handleFetchProjectsResult)(projectsDecoder)
 }

createNewProject: String -> Cmd Event
createNewProject projectName =
    Http.post {
        url = "http://127.0.0.1:8089/projects",
        expect =  Http.expectJson(handleProjectCreationResult)(projectCreationDecoder),
        body = Http.jsonBody(Encode.object[("name", Encode.string projectName)])
    }

handleFetchProjectsResult: Result Http.Error (List Project) -> Event
handleFetchProjectsResult result =
    case result of
            Result.Ok projects -> ObtainedProjects projects
            Result.Err _ -> UnexpectedError

projectsDecoder: Decode.Decoder (List Project)
projectsDecoder =
    Decode.list
    <| Decode.map3
      (\id name created -> Project(id)(name)(created))
      (Decode.field "id" Decode.string)
      (Decode.field "name" Decode.string)
      (Decode.field "created" Decode.string)

handleProjectCreationResult: Result Http.Error () -> Event
handleProjectCreationResult result =
    case result of
            Result.Ok () -> NewProjectCreated
            Result.Err _ -> UnexpectedError

projectCreationDecoder: Decode.Decoder ()
projectCreationDecoder = Decode.succeed ()

render: Model -> Html Event
render model =
    div[id  "projects"][
        model.projectCreationModal
            |> Maybe.map (\_ -> newProjectCreationModal)
            |> Maybe.withDefault (div[][])
        ,
        ul[](
           model.projects
           |> Maybe.map (\projects -> List.map renderListElem projects)
           |> Maybe.withDefault ([div[][]]) -- loading
        ),
        div[id "add-project"][
            button[onClick OpenNewProjectModal][i[class "ion-ios-add-circle"][]]
        ]
    ]

renderListElem: Project -> Html Event
renderListElem project = li[onClick(ProjectSelected project.id)][
    span[class  "name"][text(project.name)],
    div[class "actions"][
        i[class "ion-ios-play"][],
        i[class "ion-ios-cloud-download"][],
        i[class "ion-ios-trash"][]
    ]
 ]

newProjectCreationModal: Html Event
newProjectCreationModal = div[id "project-creation-modal", class "modal-background", onClick CloseModal][
    div[class "modal", stopPropagationOn("click")(Decode.succeed((Ignore,True)))][
        span[][text("project name: ")],
        input[onInput ProjectNameInput][],
        button[onClick (AddNewProject)][text("submit")]
     ]
 ]
