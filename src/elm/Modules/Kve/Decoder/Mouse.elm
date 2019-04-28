module Modules.Kve.Decoder.Mouse exposing (decodeMouseMove, decodeMouseUp, Event(..))
import Json.Decode as Decode
import Model.PxPosition exposing (PxPosition)


type Event =
    MouseMove PxPosition |
    MouseUp   PxPosition




decodeMouseMove: Decode.Decoder PxPosition
decodeMouseMove =
    Decode.map2
      (\x y -> PxPosition(x)(y))
      (Decode.field "clientX" Decode.float)
      (Decode.field "clientY" Decode.float)

decodeMouseUp: Decode.Decoder PxPosition
decodeMouseUp =
        Decode.map2
          (\x y -> PxPosition(x)(y))
          (Decode.field "clientX" Decode.float)
          (Decode.field "clientY" Decode.float)