module Modules.Kve.Http.Project exposing (saveService, fetchProject, updateServicePosition)

import Modules.Kve.Model.KveModel exposing (NewService)
import Http as Http
import Json.Encode
import Json.Decode as Decode
import Modules.Kve.Event.KveEvents as KveEvents
import Modules.Kve.Model.KveModel exposing (RegisteredService,RegisteredProject)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Http as Http
import Json.Encode as Encode

handleServiceCreationResult: NewService -> Result Http.Error RegisteredService -> KveEvents.HttpEvents
handleServiceCreationResult service result =
    case result of
        Result.Ok registeredService -> KveEvents.ServiceCreated registeredService
        Result.Err _ -> KveEvents.ServiceCreationFailed service

handleUpdatedCreationResult: RegisteredService -> Result Http.Error RegisteredService -> KveEvents.HttpEvents
handleUpdatedCreationResult service result =
    case result of
        Result.Ok newService -> KveEvents.ServiceUpdated {old = service, new = newService}
        Result.Err _ -> KveEvents.ServiceUpdateFailed service

handleFetchProjectResult: Result Http.Error RegisteredProject -> KveEvents.HttpEvents
handleFetchProjectResult result =
    case result of
            Result.Ok project -> KveEvents.ProjectFetched project
            Result.Err _ -> KveEvents.ProjectFetchedFailed

registeredServiceDecoder: Decode.Decoder RegisteredService
registeredServiceDecoder =
    Decode.map7
    (\id name kind x y width length -> RegisteredService
        id
        name
        kind
        (PxPosition x y)
        (PxDimensions width length)
     )
    (Decode.field "id" Decode.string)
    (Decode.field "name" Decode.string)
    (Decode.field "kind" Decode.string)
    (Decode.field "position" (Decode.field "x" Decode.float))
    (Decode.field "position" (Decode.field "y" Decode.float))
    (Decode.field "dimension" (Decode.field "width" Decode.float))
    (Decode.field "dimension" (Decode.field "length" Decode.float))

registeredProjectDecoder: Decode.Decoder RegisteredProject
registeredProjectDecoder =
    Decode.map3
      (\name id services -> RegisteredProject(id)(name)(services))
      (Decode.field "id" Decode.string)
      (Decode.field "name" Decode.string)
      (Decode.field "services" (Decode.list registeredServiceDecoder))


positionEncoder: PxPosition -> Encode.Value
positionEncoder pxPosition =
    Encode.object [
      ("x", Encode.float pxPosition.x),
      ("y", Encode.float pxPosition.y)
    ]
dimensionEncoder: PxDimensions -> Encode.Value
dimensionEncoder dimensions =
    Encode.object [
      ("width", Encode.float dimensions.width),
      ("length", Encode.float dimensions.height)
    ]
newServiceEncoder: NewService -> Encode.Value
newServiceEncoder service =
    Encode.object [
            ("name", Encode.string service.name),
            ("serviceType", Encode.string service.serviceType),
            ("position", positionEncoder service.position),
            ("dimension", dimensionEncoder service.dimensions)
        ]



fetchProject: Cmd (KveEvents.HttpEvents)
fetchProject = Http.get {
    url = "http://127.0.0.1:8089/projects/0ddd193a-8dbd-4cea-8540-954e17673e36",
    expect =  Http.expectJson(handleFetchProjectResult)(registeredProjectDecoder)
 }


saveService: NewService -> Cmd (KveEvents.HttpEvents)
saveService service = Http.post {
    url = "http://127.0.0.1:8089/projects/0ddd193a-8dbd-4cea-8540-954e17673e36/services",
    expect = Http.expectJson(handleServiceCreationResult(service))(registeredServiceDecoder),
    body = Http.jsonBody (newServiceEncoder(service))
 }

updateServicePosition: RegisteredService -> PxPosition -> Cmd (KveEvents.HttpEvents)
updateServicePosition service pxPosition = Http.request {
        method = "PATCH",
        url = "http://127.0.0.1:8089/projects/0ddd193a-8dbd-4cea-8540-954e17673e36/services/" ++ service.id ++ "/position",
        expect = Http.expectJson(handleUpdatedCreationResult(service))(registeredServiceDecoder),
        body = Http.jsonBody (Encode.object [("position", positionEncoder(pxPosition))]),
        headers = [],
        timeout = Nothing,
        tracker = Nothing
     }
