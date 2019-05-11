module Routes.Routes exposing (Route(..),parseRoute)

import Browser.Navigation as Navigation
import Url.Parser as Parser
import Url.Parser exposing ((</>), string)
import Url

type Route =
    Home |
    LoginRoute |
    ProjectsRoute |
    ProjectRoute String |
    Loading |
    NotFound



parseRoute: Url.Url -> Route
parseRoute url =
    Parser.oneOf
      [
        Parser.map LoginRoute (Parser.s "login"),
        Parser.map LoginRoute (Parser.top),
        Parser.map ProjectsRoute (Parser.s "projects" ),
        Parser.map ProjectRoute (Parser.s "projects" </> string )
      ]
    |> (\x -> Parser.parse x (Debug.log("url")(url)))
    |> Maybe.withDefault NotFound
