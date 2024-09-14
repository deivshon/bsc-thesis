module Main exposing (..)

import Browser
import Html as H exposing (Html)


type Model
    = None


type Msg
    = Placeholder


init : () -> ( Model, Cmd Msg )
init _ =
    ( None, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Placeholder ->
            ( model, Cmd.none )


view : Model -> Html Msg
view _ =
    H.div [] [ H.text "Hello, World!" ]
