module  Model.PxPosition exposing (PxPosition,toTranslateStr,subtractHafDimensions)
import Model.PxDimensions exposing (PxDimensions)
import Model.Pixel as Pixel

type alias Coordinate = Float
type alias PxPosition = {
    x : Coordinate,
    y : Coordinate
 }

toTranslateStr: PxPosition -> String
toTranslateStr p = "translate(" ++ (p.x |> Pixel.toPxStr) ++ "," ++ (p.y |> Pixel.toPxStr) ++ ")"

subtractHafDimensions: PxPosition -> PxDimensions -> PxPosition
subtractHafDimensions position pxDimensions =
       PxPosition(position.x - pxDimensions.width/2)(position.y - pxDimensions.height/2)





