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


type alias TodoDoneUpdate =
    { done : Bool
    }


todoDecoder : Decoder Todo
todoDecoder =
    map5 Todo
        (field "id" string)
        (field "content" string)
        (field "createdAt" int)
        (field "updatedAt" int)
        (field "done" bool)


todoListDecoder : Decoder (List Todo)
todoListDecoder =
    Json.Decode.list todoDecoder


todoDoneUpdateEncoder : TodoDoneUpdate -> Json.Encode.Value
todoDoneUpdateEncoder todoDoneUpdate =
    Json.Encode.object
        [ ( "done", Json.Encode.bool todoDoneUpdate.done ) ]


doneTodos : List Todo -> List Todo
doneTodos todos =
    List.filter (\todo -> todo.done) todos


undoneTodos : List Todo -> List Todo
undoneTodos todos =
    List.filter (\todo -> not todo.done) todos


viewTodo : { a | done : Bool, content : String } -> msg -> msg -> H.Html msg
viewTodo todo onTodoDone onTodoUndone =
    if todo.done then
        H.div [ class "todo done", onClick onTodoUndone ]
            [ H.text todo.content, H.button [ class "mark-undone-button" ] [ H.text "Mark udone" ] ]

    else
        H.div [ class "todo undone", onClick onTodoDone ]
            [ H.text todo.content, H.button [ class "mark-done-button" ] [ H.text "Mark done" ] ]
