module Model.PxDimensions exposing (PxDimensions, fromElement, toPxlStr)
import Model.Pixel as Pixel
import Browser.Dom exposing (Element)


type alias PxDimension = Float
type alias PxDimensions  = {
    width: PxDimension,
    height: PxDimension
 }


fromElement: Element -> PxDimensions
fromElement element = fromRecord({x = element.element.width, y = element.element.height})

fromRecord :{x: Float, y: Float} -> PxDimensions
fromRecord {x,y} = {width = x, height = y}

toHeightStr : PxDimensions -> String
toHeightStr pxDimensions = pxDimensions.height |> toPxlStr

toWidthStr : PxDimensions -> String
toWidthStr pxDimensions = pxDimensions.width |> toPxlStr


toPxlStr: PxDimension -> String
toPxlStr a = a |> Pixel.toPxStr
