module Modules.Kve.Decoder.Mouse exposing (decodeMousePosition, decodeMouseUp, Event(..))
import Json.Decode as Decode
import Model.PxPosition exposing (PxPosition)


type Event =
    MouseMove PxPosition |
    MouseUp   PxPosition

decodeMousePosition: Decode.Decoder Event
decodeMousePosition =
    Decode.map2
      (\x y -> MouseMove(PxPosition(x)(y)))
      (Decode.field "clientX" Decode.float)
      (Decode.field "clientY" Decode.float)

decodeMouseUp: Decode.Decoder Event
decodeMouseUp =
    Decode.map2
      (\x y -> MouseUp(PxPosition(x)(y)))
      (Decode.field "clientX" Decode.float)
      (Decode.field "clientY" Decode.float)