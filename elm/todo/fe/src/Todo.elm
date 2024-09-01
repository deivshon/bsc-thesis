module Todo exposing (..)

import Json.Decode exposing (Decoder, bool, field, int, map5, string)


type alias Todo =
    { id : String
    , content : String
    , createdAt : Int
    , updatedAt : Int
    , done : Bool
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
