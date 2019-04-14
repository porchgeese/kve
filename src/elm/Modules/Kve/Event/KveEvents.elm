module Modules.Kve.Event.KveEvents exposing (
    Event(..),TemplateContainerEvents(..),
    KubAreaEvents(..)
 )

import Modules.Kve.Model.KveModel exposing (Service, RegisteredService)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Browser.Dom exposing (Element)





type TemplateContainerEvents =
    TcSelected Service PxPosition |
    TcDragStart Service PxPosition PxDimensions |
    TcDragProgress PxPosition |
    TcDragStop PxPosition |
    TemplateContainerError String

type KubAreaEvents =
    KaAdd RegisteredService |
    KaReject Service |
    KaSelected RegisteredService PxPosition |
    KaStart RegisteredService PxPosition Element |
    KaDragProgress RegisteredService PxPosition Element |
    KaDragStop RegisteredService PxPosition Element |
    KubernetesError String

type Event =
    TemplateContainer TemplateContainerEvents |
    KubernetesArea KubAreaEvents |
    EventError String

