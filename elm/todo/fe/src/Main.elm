module Main exposing (main)

import Api exposing (createTodo, deleteTodo, getTodos, updateTodoDoneStatus)
import Browser
import Html as H
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Todo exposing (Todo, doneTodos, undoneTodos, viewTodo)


type alias EditedTodo =
    { id : Maybe String
    , content : String
    }


type alias State =
    { todos : List Todo
    , editedTodo : EditedTodo
    }


defaultEditedTodo : EditedTodo
defaultEditedTodo =
    { id = Nothing
    , content = ""
    }


type Model
    = FirstLoad
    | Loaded State
    | Error Http.Error


type Msg
    = TodosLoaded (List Todo)
    | ApiError Http.Error
    | UpdateDoneStatus String Bool
    | ReceiveHttpResponse (Result Http.Error ())
    | UpdateEditedTodoContent String
    | CreateTodo String
    | TodoCreated (Result Http.Error Todo)
    | DeleteTodo String
    | TodoDeleted (Result Http.Error ())


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


handleTodoChangingResponse : Result Http.Error value -> Model -> ( Model, Cmd Msg )
handleTodoChangingResponse response model =
    case response of
        Ok _ ->
            ( model, getTodos toMsg )

        Err error ->
            ( Error error, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TodosLoaded todos ->
            case model of
                FirstLoad ->
                    ( Loaded { todos = todos, editedTodo = defaultEditedTodo }, Cmd.none )

                Loaded state ->
                    ( Loaded { todos = todos, editedTodo = state.editedTodo }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ApiError error ->
            ( Error error, Cmd.none )

        UpdateDoneStatus id done ->
            case model of
                Loaded state ->
                    let
                        updatedTodos =
                            List.map
                                (\todo ->
                                    if todo.id == id then
                                        { todo | done = done }

                                    else
                                        todo
                                )
                                state.todos
                    in
                    ( Loaded { state | todos = updatedTodos }, updateTodoDoneStatus id { done = done } ReceiveHttpResponse )

                _ ->
                    ( model, Cmd.none )

        ReceiveHttpResponse res ->
            case res of
                Ok _ ->
                    ( model, Cmd.none )

                Err error ->
                    ( Error error, Cmd.none )

        UpdateEditedTodoContent content ->
            case model of
                Loaded state ->
                    ( Loaded { state | editedTodo = { id = Nothing, content = content } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CreateTodo content ->
            case model of
                Loaded state ->
                    ( Loaded { state | editedTodo = defaultEditedTodo }, createTodo { content = content } TodoCreated )

                _ ->
                    ( model, Cmd.none )

        TodoCreated response ->
            handleTodoChangingResponse response model

        DeleteTodo id ->
            case model of
                Loaded _ ->
                    ( model, deleteTodo id TodoDeleted )

                _ ->
                    ( model, Cmd.none )

        TodoDeleted response ->
            handleTodoChangingResponse response model


view : Model -> H.Html Msg
view model =
    case model of
        FirstLoad ->
            H.p [] [ H.text "Loading..." ]

        Loaded state ->
            viewLoadedTodos state

        Error _ ->
            H.div [] [ H.p [] [ H.text "Error loading todos." ] ]


viewLoadedTodos : State -> H.Html Msg
viewLoadedTodos state =
    H.div [ class "todos-top-container" ]
        [ H.div [ class "todos-container" ]
            [ H.div []
                (if List.isEmpty (undoneTodos state.todos) then
                    [ H.text "No todos to do." ]

                 else
                    List.map
                        (\todo ->
                            viewTodo todo
                                (UpdateDoneStatus todo.id)
                                (DeleteTodo todo.id)
                        )
                        (undoneTodos state.todos)
                )
            ]
        , H.div []
            [ H.textarea [ placeholder "Write your todo here...", value state.editedTodo.content, onInput UpdateEditedTodoContent ] []
            , H.button [ onClick (CreateTodo state.editedTodo.content) ] [ H.text "Create todo" ]
            ]
        , H.div [ class "todos-container" ]
            [ H.div []
                (if List.isEmpty (doneTodos state.todos) then
                    [ H.text "No todos done." ]

                 else
                    List.map
                        (\todo ->
                            viewTodo todo
                                (UpdateDoneStatus todo.id)
                                (DeleteTodo todo.id)
                        )
                        (doneTodos state.todos)
                )
            ]
        ]
