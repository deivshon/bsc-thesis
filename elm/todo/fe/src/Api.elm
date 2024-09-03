module Api exposing (..)

import Http
import Todo


getTodos : (Result Http.Error (List Todo.Todo) -> msg) -> Cmd msg
getTodos toMsg =
    Http.get
        { url = "http://localhost:3000/todos"
        , expect = Http.expectJson toMsg Todo.todoListDecoder
        }


updateTodoDoneStatus : String -> Todo.TodoDoneUpdate -> (Result Http.Error () -> msg) -> Cmd msg
updateTodoDoneStatus id todoDoneUpdate toMsg =
    Http.request
        { method = "PATCH"
        , headers = []
        , url = "http://localhost:3000/todos/" ++ id
        , body = Http.jsonBody (Todo.todoDoneUpdateEncoder todoDoneUpdate)
        , expect = Http.expectWhatever toMsg
        , timeout = Nothing
        , tracker = Nothing
        }
