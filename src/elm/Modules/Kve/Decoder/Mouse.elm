module Modules.Kve.Decoder.Mouse exposing (decodeMousePosition, decodeMouseUp)
import Json.Decode as Decode
import Modules.Kve.Event.KveEvents exposing (Events(..))
import Model.PxPosition exposing (PxPosition)


decodeMousePosition: Decode.Decoder Events
decodeMousePosition =
    Decode.map2
      (\x y -> MouseMove(PxPosition(x)(y)))
      (Decode.field "clientX" Decode.float)
      (Decode.field "clientY" Decode.float)

decodeMouseUp: Decode.Decoder Events
decodeMouseUp = Decode.succeed MouseUp