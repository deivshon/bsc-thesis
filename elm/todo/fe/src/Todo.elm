module Todo exposing (..)

import Html as H
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, bool, field, int, map5, string)
import Json.Encode


type alias Todo =
    { id : String
    , content : String
    , createdAt : Int
    , updatedAt : Int
    , done : Bool
    }


type alias TodoUpdateBody =
    { done : Maybe Bool
    , content : Maybe String
    }


type alias NewTodo =
    { content : String
    }


type TodoUpdate
    = StatusUpdate Bool
    | ContentUpdate String


todoDecoder : Decoder Todo
todoDecoder =
    map5 Todo
        (field "id" string)
        (field "content" string)
        (field "createdAt" int)
        (field "updatedAt" int)
        (field "done" bool)


newTodoEncoder : NewTodo -> Json.Encode.Value
newTodoEncoder newTodo =
    Json.Encode.object
        [ ( "content", Json.Encode.string newTodo.content ) ]


todoListDecoder : Decoder (List Todo)
todoListDecoder =
    Json.Decode.list todoDecoder



-- Ifs needed to avoid sending null values


todoUpdateEncoder : TodoUpdateBody -> Json.Encode.Value
todoUpdateEncoder todoDoneUpdate =
    if todoDoneUpdate.done == Nothing && todoDoneUpdate.content == Nothing then
        Json.Encode.object []

    else if todoDoneUpdate.done == Nothing then
        Json.Encode.object
            [ ( "content", maybeStringEncoder todoDoneUpdate.content ) ]

    else if todoDoneUpdate.content == Nothing then
        Json.Encode.object
            [ ( "done", maybeBoolEncoder todoDoneUpdate.done ) ]

    else
        Json.Encode.object
            [ ( "done", maybeBoolEncoder todoDoneUpdate.done )
            , ( "content", maybeStringEncoder todoDoneUpdate.content )
            ]


maybeBoolEncoder : Maybe Bool -> Json.Encode.Value
maybeBoolEncoder maybeBool =
    case maybeBool of
        Just bool ->
            Json.Encode.bool bool

        Nothing ->
            Json.Encode.null


maybeStringEncoder : Maybe String -> Json.Encode.Value
maybeStringEncoder maybeString =
    case maybeString of
        Just string ->
            Json.Encode.string string

        Nothing ->
            Json.Encode.null


doneTodos : List Todo -> List Todo
doneTodos todos =
    List.filter (\todo -> todo.done) todos


undoneTodos : List Todo -> List Todo
undoneTodos todos =
    List.filter (\todo -> not todo.done) todos


viewTodo : { a | done : Bool, id : b, content : String } -> ({ id : b, update : TodoUpdate } -> msg) -> msg -> ({ a | done : Bool, id : b, content : String } -> msg) -> H.Html msg
viewTodo todo onTodoStatusChange onDelete onEdit =
    H.div []
        [ if todo.done then
            H.div [ class "todo done", onClick (onTodoStatusChange { id = todo.id, update = StatusUpdate False }) ]
                [ H.text todo.content, H.button [ class "mark-undone-button" ] [ H.text "Mark udone" ] ]

          else
            H.div [ class "todo undone", onClick (onTodoStatusChange { id = todo.id, update = StatusUpdate True }) ]
                [ H.text todo.content, H.button [ class "mark-done-button" ] [ H.text "Mark done" ] ]
        , H.button [ class "delete-button", onClick onDelete ] [ H.text "Delete" ]
        , H.button [ class "edit-button", onClick (onEdit todo) ] [ H.text "Edit" ]
        ]
