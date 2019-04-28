module Modules.Kve.Event.KveEvents exposing (
    Event(..),
    KubAreaEvents(..), HttpEvents(..)
 )
import Modules.Kve.ServiceTemplate.ServiceTemplateContainer.
import Modules.Kve.Model.KveModel exposing (ServiceTemplate, RegisteredService,NewService, RegisteredProject)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Browser.Dom exposing (Element)








type KubAreaEvents =
    KaAdd NewService |
    KaReject ServiceTemplate |
    KaSelected RegisteredService PxPosition |
    KaStart RegisteredService PxPosition Element |
    KaDragProgress RegisteredService PxPosition Element |
    KaDragStop RegisteredService PxPosition Element |
    KubernetesError String

type HttpEvents =
    ServiceUpdated {old: RegisteredService, new: RegisteredService} |
    ServiceUpdateFailed RegisteredService |
    ServiceCreated RegisteredService |
    ServiceCreationFailed NewService |
    ProjectFetched RegisteredProject |
    ProjectFetchedFailed

type Event =
    TemplateContainer TemplateContainerEvents |
    KubernetesArea KubAreaEvents |
    HttpEvents HttpEvents|
    EventError String

