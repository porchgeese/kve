module Modules.Kve.Event.KveEvents exposing (
    Event(..),
    HttpEvents(..)
 )
import Modules.Kve.Model.KveModel exposing (ServiceTemplate, RegisteredService,NewService, RegisteredProject)
import Model.PxPosition exposing (PxPosition)
import Browser.Dom exposing (Element)
import Modules.Kve.ServiceTemplate.ServiceTemplateContainer as STC
import Modules.Kve.KubernetesArea as KA



type HttpEvents =
    ServiceUpdated {old: RegisteredService, new: RegisteredService} |
    ServiceUpdateFailed RegisteredService |
    ServiceCreated RegisteredService |
    ServiceCreationFailed NewService |
    ProjectFetched RegisteredProject |
    ProjectFetchedFailed


type Event =
    TemplateContainer STC.TemplateContainerEvent |
    KubernetesArea KA.KubAreaEvents |
    HttpEvents HttpEvents|
    EventError String

