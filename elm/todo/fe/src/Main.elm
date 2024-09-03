module Main exposing (main)

import Api exposing (getTodos, updateTodoDoneStatus)
import Browser
import Html as H
import Html.Attributes exposing (class)
import Http
import Todo exposing (Todo, doneTodos, undoneTodos, viewTodo)


type Model
    = FirstLoad
    | Loading (List Todo)
    | Loaded (List Todo)
    | Error Http.Error


type Msg
    = TodosLoaded (List Todo)
    | ApiError Http.Error
    | NoAction
    | UpdateDoneStatus String Bool
    | ReceiveHttpResponse (Result Http.Error ())


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

        UpdateDoneStatus id done ->
            case model of
                Loaded todos ->
                    let
                        updatedTodos =
                            List.map
                                (\todo ->
                                    if todo.id == id then
                                        { todo | done = done }

                                    else
                                        todo
                                )
                                todos
                    in
                    ( Loaded updatedTodos, updateTodoDoneStatus id { done = done } ReceiveHttpResponse )

                _ ->
                    ( model, Cmd.none )

        ReceiveHttpResponse res ->
            case res of
                Ok _ ->
                    ( model, Cmd.none )

                Err error ->
                    ( Error error, Cmd.none )


view : Model -> H.Html Msg
view model =
    case model of
        FirstLoad ->
            H.p [] [ H.text "Loading..." ]

        Loading _ ->
            H.p [] [ H.text "Loading Todos..." ]

        Loaded todos ->
            H.div [ class "todos-top-container" ]
                [ H.div [ class "todos-container" ]
                    [ H.div []
                        (if List.isEmpty (undoneTodos todos) then
                            [ H.text "No todos to do." ]

                         else
                            List.map
                                (\todo ->
                                    viewTodo todo (UpdateDoneStatus todo.id True) (UpdateDoneStatus todo.id False)
                                )
                                (undoneTodos todos)
                        )
                    ]
                , H.div [ class "todos-container" ]
                    [ H.div []
                        (if List.isEmpty (doneTodos todos) then
                            [ H.text "No todos done." ]

                         else
                            List.map
                                (\todo ->
                                    viewTodo todo (UpdateDoneStatus todo.id True) (UpdateDoneStatus todo.id False)
                                )
                                (doneTodos todos)
                        )
                    ]
                ]

        Error _ ->
            H.div [] [ H.p [] [ H.text "Error loading todos." ] ]
