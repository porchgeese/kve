module Modules.Kve.Model.KveModel exposing (..)

import Model.PxPosition as PxPosition
import Model.PxDimensions as PxDimensions

type alias Service = {id: String, name: String}
type alias RegisteredService = {
    id: Int,
    service: Service,
    position: PxPosition.PxPosition,
    dimensions: PxDimensions.PxDimensions
 }