module Model.Pixel exposing (..)

type alias Pixel = Float
toPxStr: Pixel -> String
toPxStr a = a |> String.fromFloat |> \f -> f ++"px"

