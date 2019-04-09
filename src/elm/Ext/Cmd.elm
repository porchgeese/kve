module Ext.Cmd exposing (..)

import Task exposing (Task)

cmd: msg -> Cmd msg
cmd msg = Task.succeed msg
            |> Task.perform identity
