module Modules.Kve.Event.KveEvents exposing (Events(..))

import Modules.Kve.Model.KveModel exposing (Service)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Browser.Dom exposing (Element)


type Events =
    ServiceSelected Service PxPosition |
    SelectionDimensions PxDimensions |
    ServiceAreaElement Element |
    MouseMove PxPosition |
    MouseUp  |
    EventError String

