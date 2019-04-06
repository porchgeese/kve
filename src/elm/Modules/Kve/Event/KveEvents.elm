module Modules.Kve.Event.KveEvents exposing (Events(..))

import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Browser.Dom exposing (Element)


type Events =
    ServiceSelected ServiceTemplate PxPosition |
    SelectionDimensions PxDimensions |
    ServiceAreaElement Element |
    MouseMove PxPosition |
    MouseUp  |
    EventError String

