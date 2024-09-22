port module Ports.Ports exposing (..)


port storeToken : String -> Cmd msg


port removeToken : () -> Cmd msg


port noInteractionTokenChange : (Maybe String -> msg) -> Sub msg
