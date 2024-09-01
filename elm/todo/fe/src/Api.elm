module Api exposing (..)

import Http
import Todo


getTodos : (Result Http.Error (List Todo.Todo) -> msg) -> Cmd msg
getTodos toMsg =
    Http.get
        { url = "http://localhost:3000/todos"
        , expect = Http.expectJson toMsg Todo.todoListDecoder
        }
