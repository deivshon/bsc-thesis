module Main exposing (main)

import Api exposing (getTodos)
import Browser
import Html as H
import Http
import Todo exposing (Todo)


type Model
    = FirstLoad
    | Loading (List Todo)
    | Loaded (List Todo)
    | Error Http.Error


type Msg
    = TodosLoaded (List Todo)
    | ApiError Http.Error
    | NoAction


toMsg : Result Http.Error (List Todo) -> Msg
toMsg result =
    case result of
        Ok todos ->
            TodosLoaded todos

        Err error ->
            ApiError error


init : () -> ( Model, Cmd Msg )
init _ =
    ( FirstLoad, getTodos toMsg )


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
        TodosLoaded todos ->
            ( Loaded todos, Cmd.none )

        ApiError error ->
            ( Error error, Cmd.none )

        NoAction ->
            ( model, Cmd.none )


view : Model -> H.Html Msg
view model =
    case model of
        FirstLoad ->
            H.p [] [ H.text "Loading..." ]

        Loading _ ->
            H.p [] [ H.text "Loading Todos..." ]

        Loaded todos ->
            H.div []
                (List.map (\todo -> H.p [] [ H.text todo.content ]) todos)

        Error _ ->
            H.div [] [ H.p [] [ H.text "Error loading todos." ] ]
