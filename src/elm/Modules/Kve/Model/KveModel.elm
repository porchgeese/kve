module Modules.Kve.Model.KveModel exposing (..)

import Model.PxPosition as PxPosition
import Model.PxDimensions as PxDimensions

type alias ServiceTemplate = {id: String, name: String, kind: String}
type alias NewService = {
    name: String,
    serviceType: String,
    position: PxPosition.PxPosition,
    dimensions: PxDimensions.PxDimensions
 }
type alias RegisteredService = {
    id: String,
    name: String,
    serviceType: String,
    position: PxPosition.PxPosition,
    dimensions: PxDimensions.PxDimensions
 }

type alias RegisteredProject = {
    id: String,
    name: String,
    services: List RegisteredService
 }