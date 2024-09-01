module Main exposing (main)

import Browser
import Html as H
import Html.Events exposing (onClick)


main : Program () Int Msg
main =
    Browser.sandbox { init = 0, update = update, view = view }


type Msg
    = NoAction


update : Msg -> Int -> Int
update _ model =
    model


view : Int -> H.Html Msg
view _ =
    H.p [ onClick NoAction ]
        [ H.text "Hello World!"
        ]
