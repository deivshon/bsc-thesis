module Api exposing (..)

import Http
import Todo


baseUrl : String
baseUrl =
    "http://localhost:3000"


getTodos :
    (Result Http.Error (List Todo.Todo)
     -> msg
    )
    -> Cmd msg
getTodos toMsg =
    Http.get
        { url = baseUrl ++ "/todos"
        , expect = Http.expectJson toMsg Todo.todoListDecoder
        }


updateTodo :
    String
    -> Todo.TodoUpdateBody
    -> (Result Http.Error () -> msg)
    -> Cmd msg
updateTodo id todoUpdate toMsg =
    Http.request
        { method = "PATCH"
        , headers = []
        , url = baseUrl ++ "/todos/" ++ id
        , body =
            Http.jsonBody
                (Todo.todoUpdateEncoder todoUpdate)
        , expect = Http.expectWhatever toMsg
        , timeout = Nothing
        , tracker = Nothing
        }


createTodo : Todo.NewTodo -> (Result Http.Error Todo.Todo -> msg) -> Cmd msg
createTodo content toMsg =
    Http.post
        { url = baseUrl ++ "/todos"
        , body = Http.jsonBody (Todo.newTodoEncoder content)
        , expect = Http.expectJson toMsg Todo.todoDecoder
        }


deleteTodo : String -> (Result Http.Error () -> msg) -> Cmd msg
deleteTodo id toMsg =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = baseUrl ++ "/todos/" ++ id
        , body = Http.emptyBody
        , expect = Http.expectWhatever toMsg
        , timeout = Nothing
        , tracker = Nothing
        }
