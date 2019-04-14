module Modules.Kve.Event.KveEvents exposing (Event(..),TemplateContainerEvents(..))

import Modules.Kve.Model.KveModel exposing (Service)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Browser.Dom exposing (Element)




type TemplateContainerEvents =
    Selected Service PxPosition |
    DragStart Service PxPosition PxDimensions |
    DragProgress PxPosition |
    Dimensions PxDimensions |
    DragStop PxPosition |
    Error String

type Event =
    TemplateContainer TemplateContainerEvents |
    EventError String

