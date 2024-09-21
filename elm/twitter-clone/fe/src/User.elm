module User exposing (..)

import Json.Decode as JD


type alias User =
    { username : String
    , id : String
    , createdAt : Int
    }


userDecoder : JD.Decoder User
userDecoder =
    JD.map3 User
        (JD.field "username" JD.string)
        (JD.field "id" JD.string)
        (JD.field "createdAt" JD.int)
