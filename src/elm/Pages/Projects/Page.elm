module Pages.Projects.Page exposing (Model, Event(..), render, init, update)

import Html exposing (Html)
import Html exposing (div,img, ul,li, text,span,i,Html)
import Html.Attributes exposing (id, class)
import Html.Events exposing (onClick)
import Http as Http
import Json.Encode
import Json.Decode as Decode


type alias Project = {
    id: String,
    name: String,
    created: String --no need to make this a timestamp for now
 }

type alias Model = {
    projects: Maybe (List Project)
 }


type Event =
    ProjectSelected String |
    ObtainedProjects (List Project) |
    UnexpectedError

init : () -> (Model, Cmd Event)
init () =  (Model(Nothing), fetchProjects)


update: Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
        ObtainedProjects projects ->
            ({model | projects = Just projects}, Cmd.none)
        _ ->
            (model, Cmd.none)


fetchProjects: Cmd Event
fetchProjects = Http.get {
    url = "http://127.0.0.1:8089/projects",
    expect =  Http.expectJson(handleFetchProjectsResult)(projectsDecoder)
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


render: Model -> Html Event
render model =
    div[id  "projects"][
        ul[](
           model.projects
           |> Maybe.map (\projects -> List.map renderListElem projects)
           |> Maybe.withDefault ([div[][]]) -- loading
        )
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