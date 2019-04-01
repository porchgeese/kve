module Modules.Kve.Event.KveEvents exposing (Events(..))

import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Model.PxPosition exposing (PxPosition)
import Browser.Dom exposing (Element)

type Events =
    ServiceSelected {service: ServiceTemplate, position: PxPosition} |
    ServiceSelectedAndDim {service: ServiceTemplate, position: PxPosition, element: Element} |
    EventError {description: String}

